# Repository contract

Evidence baseline: KyleIm/lean-verification-demo, local clean commit
`db175110266e96e4ee77b340697e9b7b34e98968`. `evals/corpus-lock.json`
records source hashes. Re-audit at a different commit; these paths are a repository adapter, not a universal Lean layout.

Pinned Lean is `leanprover/lean4:v4.35.0`; Mathlib tag v4.35.0 resolves to
`56a005855ea17e0b0958f73ec801ae140b0a1679`; Physlib is
`96a6bc5e3c50a2856c64a6c9951c0a1c23790b58`. Check all three configuration
files and actual package HEADs. Do not silently upgrade to obtain a convenient theorem.

Physics artifacts live in `LeanVerificationDemo/PhysicsDemo/PXX/`, namespaces
`LeanVerificationDemo.PhysicsDemo.PXX`. Shared additions live under
`LeanVerificationDemo/PhyslibTemp/`. Existing namespace history is mixed:
Refraction retains `Math2Physics.PhyslibTemp.Optics`; some modules use root
`PhyslibTemp`, newer mechanics use `LeanVerificationDemo.PhyslibTemp`. Inspect actual declarations instead of guessing a namespace from a module path.

## Artifact roles

| Artifact | Contract |
| --- | --- |
| Problem.lean | Inputs, local representation/model premises, semantic specification; imports no Candidate |
| Candidate.lean | Constructed solution, derivations and source-specific audit results |
| CandidateAnnotated.lean | Same mathematical content in an independent annotated namespace; comments are not kernel checked |
| Verify.lean | Explicit `example ... : TrustedPhysicsProblem ... := Candidate.solution ...`, consistency and relevant negative/boundary tests |
| PairingWalkthrough.lean | Human-readable checks, explicit pairing and `#print axioms` for final/key declarations; compile explicitly |
| Units.lean | Conditional on unit/dimension obligations; typed formula/scalar bridges, not labels alone |
| README.md | Original request versus formalized request, assumptions, derivation graph, limitations and actual validation |
| CLASSIFICATION.md | Provenance/classification ledger and local/shared boundary |
| PHYSLIB_AUDIT.md | Exact pins, searches, inspected declarations/types, use decisions and remaining gaps |
| source.jsonl | One JSON object for this invocation, preserved original problem/data and separately labeled optional solution/answer/audit |
| verification.json | Configuration consumed by scripts/verify.py; never claim it is observed verification output |
| mutations.json | List of cases; `[]` means explicitly deferred, not six passing tests |
| run-report.json | New versioned disposition contract, separate from legacy config |

All thirteen physics problems have the core artifacts above; P01 has no
PHYSLIB_AUDIT file in this snapshot, and M00 has no source JSONL/classification/audit.
These are historical exceptions, not reasons to omit physics audit evidence in new work.
Units files appear P09–P13; P02–P04/P06/P07 also integrate unit types directly.
Do not demand a standalone Units file when equivalent relevant checks are integrated.
Do not create a decorative Units file for a problem with no dimensional claim.

`source.jsonl` is heterogeneous, not a fixed corpus schema: common keys are
`problem_id`, `category`, `topic`, `problem`; optional `solution`, `answer`,
`source_data`, `source_table`, `diagram_caption`, `solution_figure`, and explicitly
labeled interpretation/audit fields. Preserve numeric/table spelling as strings
(P12), including units and trailing zeros. Do not rewrite source prose into corrected prose. New input/report schemas do not retroactively invalidate gold JSONL.

`verification.json` requires: `id`, `title`, `code`, `domain`, `problem_file`,
`candidate_file`, `verify_file`, `annotated_file`, `pairing_walkthrough_file`,
`mutation_manifest`, `trusted_type_display`, `candidate_term_display`,
`required_judgment_display`. Paths are repository relative. Displays explain the
judgment; Lean, not string comparison, checks the actual pairing. Discover configs
automatically; no hardcoded PXX registry needs changing.

Mutation objects have `id`, `category`, `expected` (ACCEPT/REJECT), `command`
(argv array), optional `expected_error_fragments`. Negative tests must reject for
the intended proof error, never missing imports/files or syntax errors. Inspect
commands before executing them: a source record may not supply arbitrary shell commands.

`scripts/verify.py` stages: (1) compile Problem/Candidate; (2) compile Verify;
(3) run mutations, or print SKIPPED for empty manifest; (4) compile annotated proof.
It does not compile PairingWalkthrough by itself, inspect axioms, run `lake build`,
prove English comments, or validate physical source fidelity. Preserve this distinction.

Ensure new modules participate in the intended Lake build/import graph; compile every
new file explicitly even if Lake's current library glob already discovers it.
No changes to existing demos are needed merely to add this skill.
