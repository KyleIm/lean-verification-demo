# physics-lean-formalizer 0.1.0 — first review draft

The draft lives at [SKILL.md](../../skills/physics-lean-formalizer/SKILL.md).
Existing Lean demos, shared physics and dependency pins are unchanged.
The inspected local gold baseline is db175110266e96e4ee77b340697e9b7b34e98968.
This is a reviewable directory addition. No automatic skill installation was
performed; publication is tracked in the repository Git history.

## Deliverables map

| Requested item | File |
| --- | --- |
| Extracted workflow, stable/experimental policy, superseded examples | [workflow-analysis.md](../../skills/physics-lean-formalizer/references/workflow-analysis.md) |
| Complete focused entrypoint | [SKILL.md](../../skills/physics-lean-formalizer/SKILL.md) |
| Repository artifact/config conventions | [repository-contract.md](../../skills/physics-lean-formalizer/references/repository-contract.md) |
| Input/output interpretation and failure behavior | [contracts.md](../../skills/physics-lean-formalizer/references/contracts.md) and schemas/ |
| Detailed physical/formalization policies | references/ files routed by SKILL.md |
| Reproducible technical evidence collector | scripts/check_run.py |
| Contract validation | scripts/validate_contract.py |
| Eight initial methodology evals and transfer variants | [evals.json](../../skills/physics-lean-formalizer/evals/evals.json) |
| Source fixtures and immutable evidence inventory | evals/*.source.json and evals/corpus-lock.json |
| Codex/API invocation, evaluation protocol, versioning | [operation.md](../../skills/physics-lean-formalizer/references/operation.md) |
| Actual technical validation results | [baseline-summary.json](baseline-summary.json) and evidence/ |

```text
skills/physics-lean-formalizer/
├── SKILL.md
├── references/
│   ├── workflow-analysis.md
│   ├── repository-contract.md
│   ├── contracts.md
│   ├── problem-candidate-separation.md
│   ├── source-solution-audit.md
│   ├── physlib-reuse.md
│   ├── physlibtemp-policy.md
│   ├── units-and-dimensions.md
│   ├── approximation-and-data.md
│   ├── figures.md
│   ├── verification.md
│   ├── failure-taxonomy.md
│   └── operation.md
├── schemas/{input,run-report}.schema.json
├── scripts/{check_run,validate_contract}.py
└── evals/  # prompts, raw fixtures, corpus lock, contract tests
```

## Main conclusions

P12/P13's semantic witness construction supersedes answer-bearing targets for
new open-ended find tasks, while general reusable physics remains permissible
trusted model semantics. P08 makes derivable apex/event steps explicit without
turning small finite impulse into zero. P11 separates source and solution
figures and corrects physical channel terminology. P12 proves agreement at the
requested rounding resolution without falsifying raw data. P13 preserves the
exact π-dependent result and separately audits printed integer-Hz approximations.
These are encoded as policies, not hardcoded corpus answers.

The core operates on one problem. Machine-readable status and categorized
deferrals are exposed for a later orchestrator; no bulk formalization runner is
included. The v1 contracts, retry advice and extension-promotion judgments remain
explicitly experimental pending unseen problems.

## Executed validation

- Existing pinned `lake build` passed (3685 jobs; existing module-system warnings).
- M00 and P01–P13 repository verifiers passed. M00/P01/P02 passed six mutation
  checks each; P03–P13 correctly reported mutation SKIPPED.
- New evidence collector passed on existing P09/P11/P12/P13, including selected
  files, Units, PairingWalkthrough, independent library examples, and final
  Candidate/annotated axiom probes. Each final theorem used only propext,
  Classical.choice and Quot.sound.
- Seven contract/scanner tests passed; missing-target integration test returned
  nonzero and retained structured failure evidence.
- Skill validator passed; JSON parsed; local Markdown links resolved; original
  corpus hash inventory showed no changes.

Raw execution logs were copied from /tmp into evidence/PXX for durable review.
The original evidence JSON retains original execution/log paths; the same-named
copied log is in the adjacent review evidence directory.

These are technical baselines on the existing gold code. **The eight fresh
agent-generation methodology evals are defined but not run.** They require
isolated agent workspaces with the target gold answer hidden, plus semantic
review. Baseline gold PASS does not measure the new skill's behavioral quality.
No throughput or correctness claim for hundreds/thousands of unseen problems is
made by this first draft.

## Review/test entrypoints

From repository root:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover \
  -s skills/physics-lean-formalizer/evals -p 'test_*.py' -v
python3 skills/physics-lean-formalizer/scripts/validate_contract.py input \
  skills/physics-lean-formalizer/evals/input.example.json
```

Use the explicit-path Codex prompt and one-request API prompt in operation.md.
The runtime needs real Lean execution tools and a provisioned pinned workspace;
a plain text-only API completion cannot perform compile verification.
