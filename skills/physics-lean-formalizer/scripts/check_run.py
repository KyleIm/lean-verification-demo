#!/usr/bin/env python3
"""Collect technical evidence for ONE problem. Never issue semantic acceptance.

No network installation, pin changes, shell interpolation or proof generation.
Run only in a reviewed repository: Lake and the repository verifier execute code.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import sys
import tempfile
import time

ALLOWED_AXIOMS = {'propext', 'Classical.choice', 'Quot.sound'}
CORE = ['Problem.lean', 'Candidate.lean', 'CandidateAnnotated.lean', 'Verify.lean',
        'PairingWalkthrough.lean', 'README.md', 'CLASSIFICATION.md',
        'PHYSLIB_AUDIT.md', 'source.jsonl', 'verification.json']


def lean_code(text):
    """Remove nested block/line comments and strings for heuristic token checks."""
    result = []; i = 0; depth = 0; quoted = False
    while i < len(text):
        pair = text[i:i+2]
        if depth:
            if pair == '/-': depth += 1; i += 2
            elif pair == '-/': depth -= 1; i += 2
            else: result.append('\n' if text[i] == '\n' else ' '); i += 1
        elif quoted:
            if text[i] == '\\': i += 2
            elif text[i] == '"': quoted = False; i += 1
            else: result.append('\n' if text[i] == '\n' else ' '); i += 1
        elif pair == '/-': depth = 1; result.append(' '); i += 2
        elif pair == '--':
            end = text.find('\n', i); i = len(text) if end == -1 else end
        elif text[i] == '"': quoted = True; result.append(' '); i += 1
        else: result.append(text[i]); i += 1
    return ''.join(result)


def contained(root, value):
    path = (root / value).resolve()
    if not path.is_relative_to(root): raise ValueError(f'Path escapes repository: {value}')
    return path


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--repo', required=True, type=Path)
    ap.add_argument('--code', required=True)
    ap.add_argument('--out', required=True, type=Path)
    ap.add_argument('--timeout', type=int, default=600, help='Per-command seconds; host enforces total budget')
    ap.add_argument('--axiom', action='append', required=True, help='Fully qualified final theorem; repeat for annotated/key theorems')
    ap.add_argument('--extra-lean', action='append', default=[], help='Repository-relative new shared example file')
    ap.add_argument('--regression', action='store_true', help='Run fixed gold regression M00/P01-P13, not new problem scheduling')
    ap.add_argument('--forbid-answer-token', action='append', default=[], help='Problem-closure review warning only')
    args = ap.parse_args()
    if not re.fullmatch(r'(P[0-9]{2,}|M00)', args.code) or args.timeout < 1:
        ap.error('Invalid code or timeout')
    if any(not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_.]*', n) for n in args.axiom):
        ap.error('Use ordinary fully qualified theorem names')
    root = args.repo.resolve(); out = args.out.resolve()
    if out.exists(): ap.error('Evidence output must be a new directory (do not overwrite a prior run)')
    out.mkdir(parents=True)
    evidence = {'schema_version':'1.0.0', 'code':args.code, 'repository':str(root),
                'commands':[], 'errors':[], 'warnings':[], 'axioms':{},
                'mutations_status':'not_run', 'technical_pass':False,
                'semantic_acceptance':'not_evaluated', 'artifacts':[]}

    def run(label, command):
        index = len(evidence['commands']); log = out / f'{index:02}-{label}.log'
        start = time.monotonic(); timed_out = False
        with log.open('wb') as stream:
            try:
                proc = subprocess.Popen(command, cwd=root, stdout=stream, stderr=subprocess.STDOUT,
                                        start_new_session=True)
                try: rc = proc.wait(timeout=args.timeout)
                except subprocess.TimeoutExpired:
                    timed_out = True; os.killpg(proc.pid, signal.SIGKILL); proc.wait(); rc = 124
            except OSError as exc:
                stream.write(str(exc).encode()); rc = 127
        record = {'label':label, 'argv':command, 'cwd':str(root), 'exit_code':rc,
                  'timed_out':timed_out, 'elapsed_seconds':round(time.monotonic()-start,3), 'log':str(log)}
        evidence['commands'].append(record)
        if rc: evidence['errors'].append(f'{label}: exit {rc}; see {log}')
        return record, log.read_text(errors='replace')

    try:
        _, head = run('head', ['git','rev-parse','HEAD']); evidence['repository_commit'] = head.strip()
        _, dirty = run('initial-status', ['git','status','--short']); evidence['initial_dirty_state'] = dirty
        config_paths = list((root/'LeanVerificationDemo').rglob('verification.json'))
        configs = [json.loads(p.read_text()) for p in config_paths]
        matches = [c for c in configs if c['code'] == args.code]
        if len(matches) != 1: raise ValueError('Expected exactly one matching verification config')
        config = matches[0]; directory = contained(root, config['problem_file']).parent
        # Inspect the selected verifier configuration instead of assuming filenames alone.
        for key in ['problem_file','candidate_file','verify_file','annotated_file',
                    'pairing_walkthrough_file','mutation_manifest']:
            if not contained(root, config[key]).is_file(): raise ValueError(f'Missing configured {key}')
        required = CORE if args.code != 'M00' else [n for n in CORE if n not in
                    ['source.jsonl','CLASSIFICATION.md','PHYSLIB_AUDIT.md']]
        if args.code == 'P01': required = [n for n in required if n != 'PHYSLIB_AUDIT.md']
        for name in required:
            if not (directory/name).is_file(): evidence['errors'].append(f'Missing artifact: {name}')
        sources = list(directory.glob('*.lean'))
        temp_root = root/'LeanVerificationDemo/PhyslibTemp'
        shared = list(temp_root.rglob('*.lean'))
        for path in [*sources, *shared]:
            code = lean_code(path.read_text())
            hits = re.findall(r'\b(?:sorry|admit|axiom|native_decide|sorryAx)\b', code)
            if hits: evidence['errors'].append(f'Admission/axiom shortcut screen: {path.relative_to(root)}: {hits}')
        problem = lean_code((directory/'Problem.lean').read_text())
        if re.search(r'^\s*import\s+.*\.(Candidate|CandidateAnnotated|Verify|Units)\b', problem, re.M):
            evidence['errors'].append('Problem imports a solution-side module')
        for token in args.forbid_answer_token:
            if token in problem: evidence['warnings'].append(f'Answer-token review needed: {token!r}')
        source = directory/'source.jsonl'
        if source.exists():
            records = [json.loads(line) for line in source.read_text().splitlines() if line.strip()]
            if len(records) != 1: evidence['errors'].append('Expected one source JSONL record')
        cases = json.loads(contained(root, config['mutation_manifest']).read_text())
        if not isinstance(cases,list): raise ValueError('Mutation manifest must be a list')
        # Commands are executed by the existing reviewed repository verifier, not from input source data.
        evidence['mutation_count'] = len(cases)
        manifest = json.loads((root/'lake-manifest.json').read_text())
        evidence['dependency_context'] = {'lean_toolchain':(root/'lean-toolchain').read_text().strip()}
        for name, key in [('mathlib','mathlib_rev'),('Physlib','physlib_rev')]:
            package = next(x for x in manifest['packages'] if x['name'] == name)
            evidence['dependency_context'][key] = package['rev']
            _, actual = run(f'pin-{name}', ['git','-C',str(root/'.lake/packages'/name),'rev-parse','HEAD'])
            if actual.strip() != package['rev']: evidence['errors'].append(f'Installed {name} revision mismatches manifest')
        build, _ = run('build', ['lake','build'])
        if build['exit_code'] == 0:
            verifier, _ = run('verifier', ['python3','scripts/verify.py',args.code,'--verbose'])
            evidence['mutations_status'] = ('skipped' if not cases else
                                            'passed' if verifier['exit_code'] == 0 else 'unconfirmed')
            for path in sorted(sources) + [contained(root,x) for x in args.extra_lean]:
                run('lean-'+path.stem, ['lake','env','lean',str(path.relative_to(root))])
            imports = ['.'.join(p.relative_to(root).with_suffix('').parts) for p in sources]
            probe = '\n'.join('import '+m for m in sorted(set(imports)))+'\n'
            probe += '\n'.join('#print axioms '+name for name in args.axiom)+'\n'
            with tempfile.TemporaryDirectory(prefix='physics-lean-axioms-') as tmp:
                probe_path = Path(tmp)/'Axioms.lean'; probe_path.write_text(probe)
                (out/'axioms-probe.lean').write_text(probe)
                ax, output = run('axioms', ['lake','env','lean',str(probe_path)])
            if ax['exit_code'] == 0:
                for name in args.axiom:
                    pattern = "'"+re.escape(name)+r"' depends on axioms:\s*\[([^\]]*)\]"
                    match = re.search(pattern, output)
                    if match:
                        deps = [x.strip() for x in match.group(1).split(',') if x.strip()]
                    elif re.search("'"+re.escape(name)+r"' does not depend on any axioms",output): deps = []
                    else:
                        evidence['errors'].append(f'No parseable axiom result for {name}'); continue
                    evidence['axioms'][name] = deps
                    if set(deps)-ALLOWED_AXIOMS: evidence['errors'].append(f'Unexpected axioms for {name}: {deps}')
            if args.regression:
                for code in ['M00', *[f'P{i:02}' for i in range(1,14)]]:
                    run('regression-'+code, ['python3','scripts/verify.py',code])
        else:
            evidence['warnings'].append('Build failed: downstream Lean checks not run')
        run('whitespace', ['git','diff','--check'])
        # Include untracked source files; git diff --check alone does not cover them.
        for path in directory.rglob('*'):
            if path.is_file():
                evidence['artifacts'].append({'path':str(path.relative_to(root)),
                    'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
                if path.suffix in ['.lean','.md','.json','.jsonl','.py','.txt']:
                    for n,line in enumerate(path.read_text().splitlines(),1):
                        if line.rstrip() != line: evidence['errors'].append(f'Trailing whitespace {path}:{n}')
        evidence['technical_pass'] = not evidence['errors']
    except (ValueError,KeyError,StopIteration,OSError) as exc:
        evidence['errors'].append(str(exc))
    (out/'evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
    print(json.dumps({'technical_pass':evidence['technical_pass'], 'semantic_acceptance':'not_evaluated',
                      'evidence':str(out/'evidence.json'), 'errors':evidence['errors']}))
    return 0 if evidence['technical_pass'] else 1


if __name__ == '__main__':
    sys.exit(main())
