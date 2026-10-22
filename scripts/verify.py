#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Any, NamedTuple


ROOT = Path(__file__).resolve().parents[1]
LAKE = os.environ.get("LAKE", "lake")


class ProblemConfig(NamedTuple):
    id: str
    title: str
    code: str
    domain: str
    problem_file: Path
    candidate_file: Path
    verify_file: Path
    annotated_file: Path
    pairing_walkthrough_file: Path
    mutation_manifest: Path
    trusted_type_display: str
    candidate_term_display: str
    required_judgment_display: str


class MutationCase(NamedTuple):
    id: str
    category: str
    expected: str
    command: list[str]
    expected_error_fragments: tuple[str, ...]


class MutationResult(NamedTuple):
    id: str
    category: str
    expected: str
    actual: str
    passed: bool
    output: str
    command_display: str
    diagnostic_ok: bool
    unrelated_failure: bool


UNRELATED_FAILURE_MARKERS = (
    "unknown module prefix",
    "No such file",
    "unexpected token",
    "invalid import",
    "failed to load",
    "file does not exist",
    "error during download",
    "failed to fetch cache",
)


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def dotted(label: str, value: str, width: int = 32) -> str:
    return f"  {label} {'.' * max(1, width - len(label))} {value}"


def command_display(command: list[str]) -> str:
    return " ".join("lake" if part == LAKE else part for part in command)


def run_command(command: list[str]) -> subprocess.CompletedProcess[str]:
    resolved = [LAKE if part == "lake" else part for part in command]
    return subprocess.run(
        resolved,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )


def lean_file(path: Path) -> list[str]:
    return ["lake", "env", "lean", rel(path)]


def discover_problems() -> list[ProblemConfig]:
    configs: list[ProblemConfig] = []
    for path in sorted((ROOT / "LeanVerificationDemo").rglob("verification.json")):
        raw: dict[str, Any] = json.loads(path.read_text(encoding="utf-8"))
        configs.append(
            ProblemConfig(
                id=raw["id"],
                title=raw["title"],
                code=raw["code"],
                domain=raw["domain"],
                problem_file=ROOT / raw["problem_file"],
                candidate_file=ROOT / raw["candidate_file"],
                verify_file=ROOT / raw["verify_file"],
                annotated_file=ROOT / raw["annotated_file"],
                pairing_walkthrough_file=ROOT / raw["pairing_walkthrough_file"],
                mutation_manifest=ROOT / raw["mutation_manifest"],
                trusted_type_display=raw["trusted_type_display"],
                candidate_term_display=raw["candidate_term_display"],
                required_judgment_display=raw["required_judgment_display"],
            )
        )
    return configs


def print_problem_list(configs: list[ProblemConfig]) -> None:
    print("Available problems:\n")
    for config in configs:
        print(f"  {config.code:<4} {config.id:<28} {config.title}")
    print("\nRun:")
    for config in configs:
        print(f"  python3 scripts/verify.py {config.code}")


def select_problem(configs: list[ProblemConfig], selector: str | None) -> ProblemConfig | None:
    lookup: dict[str, ProblemConfig] = {}
    for config in configs:
        lookup[config.code.lower()] = config
        lookup[config.id.lower()] = config

    if selector:
        return lookup.get(selector.lower())

    print_problem_list(configs)
    try:
        response = input("\nProblem code or ID: ").strip()
    except EOFError:
        return None
    if not response:
        return None
    return lookup.get(response.lower())


def load_mutations(manifest: Path) -> list[MutationCase]:
    raw_cases: list[dict[str, Any]] = json.loads(manifest.read_text(encoding="utf-8"))
    return [
        MutationCase(
            id=raw["id"],
            category=raw["category"],
            expected=raw["expected"],
            command=list(raw["command"]),
            expected_error_fragments=tuple(raw.get("expected_error_fragments", ())),
        )
        for raw in raw_cases
    ]


def print_output_if_needed(output: str) -> None:
    if output.strip():
        print(output.rstrip())


def run_stage1(config: ProblemConfig, verbose: bool) -> bool:
    print("Stage 1 - Valid source compilation\n")
    checks = [
        ("Problem.lean", config.problem_file),
        ("Candidate.lean", config.candidate_file),
    ]
    results: list[bool] = []
    for label, path in checks:
        result = run_command(lean_file(path))
        ok = result.returncode == 0
        results.append(ok)
        print(dotted(label, "PASS" if ok else "FAIL", width=30))
        if verbose or not ok:
            print(f"  $ {command_display(lean_file(path))}")
            print_output_if_needed(result.stdout)
    stage_ok = all(results)
    print()
    print(dotted("Stage 1 result", "PASS" if stage_ok else "FAIL", width=30))
    return stage_ok


def run_stage2(config: ProblemConfig, verbose: bool) -> bool:
    print("\nStage 2 - Proposition / proof pairing\n")
    print("  Trusted proposition:")
    print(f"    {config.trusted_type_display}")
    print("\n  Candidate proof:")
    print(f"    {config.candidate_term_display}")
    print("\n  Required judgment:")
    print(f"    {config.required_judgment_display}")

    result = run_command(lean_file(config.verify_file))
    ok = result.returncode == 0
    print("\n  Lean result:")
    print(f"    {'ACCEPT' if ok else 'REJECT'}")
    if verbose or not ok:
        print(f"\n  $ {command_display(lean_file(config.verify_file))}")
        print_output_if_needed(result.stdout)
    print()
    print(dotted("Stage 2 result", "PASS" if ok else "FAIL", width=30))
    return ok


def run_mutation(case: MutationCase, verbose: bool) -> MutationResult:
    result = run_command(case.command)
    output = result.stdout
    actual = "ACCEPT" if result.returncode == 0 else "REJECT"
    diagnostic_ok = True
    unrelated_failure = False

    if case.expected == "REJECT":
        diagnostic_ok = all(fragment in output for fragment in case.expected_error_fragments)
        unrelated_failure = any(marker in output for marker in UNRELATED_FAILURE_MARKERS)
        passed = actual == case.expected and diagnostic_ok and not unrelated_failure
    else:
        passed = actual == case.expected

    if verbose or not passed:
        print(f"\n  [{case.id}] $ {command_display(case.command)}")
        print_output_if_needed(output)
        if actual == "REJECT" and case.expected == "REJECT" and not diagnostic_ok:
            print("  Diagnostic signature did not match expected fragments.")
        if unrelated_failure:
            print("  Rejection looked like an unrelated environment/import/file failure.")

    return MutationResult(
        id=case.id,
        category=case.category,
        expected=case.expected,
        actual=actual,
        passed=passed,
        output=output,
        command_display=command_display(case.command),
        diagnostic_ok=diagnostic_ok,
        unrelated_failure=unrelated_failure,
    )


def run_stage3(config: ProblemConfig, verbose: bool) -> bool:
    print("\nStage 3 - Mutation verification\n")
    cases = load_mutations(config.mutation_manifest)
    if not cases:
        print("  Stage 3 result ................ SKIPPED (no mutation cases configured)")
        return True
    results = [run_mutation(case, verbose) for case in cases]

    category_width = max(28, *(len(result.category) + 2 for result in results))
    for result in results:
        test = "PASS" if result.passed else "FAIL"
        transition = f"{result.expected} -> {result.actual}"
        print(f"  {result.id:<11}{result.category:<{category_width}}{transition:<18}{test}")

    passed_count = sum(1 for result in results if result.passed)
    stage_ok = passed_count == len(results)
    print()
    print(dotted("Mutation result", f"{passed_count} / {len(results)} PASS", width=30))
    return stage_ok


def run_stage4(config: ProblemConfig, verbose: bool) -> bool:
    print("\nStage 4 - Human-readable proof audit\n")
    result = run_command(lean_file(config.annotated_file))
    ok = result.returncode == 0
    print(dotted("CandidateAnnotated.lean", "PASS" if ok else "FAIL", width=30))
    if verbose or not ok:
        print(f"  $ {command_display(lean_file(config.annotated_file))}")
        print_output_if_needed(result.stdout)
    print("\n  Lean checks the Lean code in the annotated file.")
    print("  The English comments are a human-audit layer, not a machine-checked proof.")
    print()
    print(dotted("Stage 4 result", "PASS" if ok else "FAIL", width=30))
    return ok


def verify_problem(config: ProblemConfig, verbose: bool) -> int:
    print("=" * 60)
    print(f"Problem: {config.code} ({config.id})")
    print(config.title)
    print("=" * 60)
    print()

    ok_stage1 = run_stage1(config, verbose)
    ok_stage2 = run_stage2(config, verbose)
    ok_stage3 = run_stage3(config, verbose)
    ok_stage4 = run_stage4(config, verbose)

    all_ok = ok_stage1 and ok_stage2 and ok_stage3 and ok_stage4
    print("\n" + "=" * 60)
    print(f"PROBLEM RESULT: {'PASS' if all_ok else 'FAIL'}")
    print("=" * 60)
    return 0 if all_ok else 1


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Verify one formalized Lean problem.",
        add_help=True,
    )
    parser.add_argument("problem", nargs="?", help="Problem code or ID, e.g. M00 or P01.")
    parser.add_argument("--list", action="store_true", help="List available problems.")
    parser.add_argument("--verbose", action="store_true", help="Show raw Lean diagnostics.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    configs = discover_problems()
    if not configs:
        print("No verification.json files found under LeanVerificationDemo/.")
        return 1

    if args.list:
        print_problem_list(configs)
        return 0

    config = select_problem(configs, args.problem)
    if config is None:
        if args.problem:
            print(f"Unknown problem: {args.problem}\n")
            print_problem_list(configs)
            return 2
        print("No problem selected.")
        return 2

    return verify_problem(config, args.verbose)


if __name__ == "__main__":
    sys.exit(main())
