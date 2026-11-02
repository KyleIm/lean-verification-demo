# Verification and acceptance

Record every command argv, cwd, exit code, elapsed time and full log. Use pinned
`lake env lean`; build dependencies before relying on imported oleans. Never
report a historical README PASS as a current execution result.

1. Compile `lake build`, then every selected Lean artifact including Units if
   present, PairingWalkthrough and independent new shared examples.
2. Run `python3 scripts/verify.py PXX --verbose`. Explicit pairing must retain
   the same source/model variables and trusted proposition. Compile annotated
   proof and review its parity; comments are not kernel checked.
3. Compile a `#print axioms` probe for Candidate.solution, annotated solution,
   and any crucial new theorem. The baseline permits propext, Classical.choice,
   Quot.sound; reject sorryAx and any new unapproved axiom. `native_decide` or
   evaluation shortcuts are not substitutes for the audited proof route. Record
   actual axiom output. A source regex for sorry is a preliminary screen only.
4. Supply consistency witnesses for substantive source/model premises. For
   conditional regimes cover attainable cases/boundaries (P11); for experimental
   compatibility use per-row witnesses (P12). Proving A→B says nothing about
   existence of A. State residual consistency gaps and defer acceptance if material.
5. Check meaningful negatives: wrong witness, wrong dimension, false exact printed
   value, missing physical link, or degenerate domain as appropriate. Do not insist
   on exactly six mutations per problem. Baseline M00/P01/P02 have six each;
   P03–P13 have empty manifests and Stage 3 SKIPPED. Record skipped with reason.
6. Run gold regression verifiers M00 and P01–P13 for changes touching shared physics
   or infrastructure; for a strictly additive problem run selected and affected
   regressions, documenting selection. Never run parallel builds sharing mutable
   outputs in one checkout. Mutation rejection must match its intended diagnostic;
   missing imports/syntax/environment failures do not count as successful negatives.
7. Run `git diff --check`; inspect untracked files too (git diff omits them).
   Retain a file/hash manifest and confirm pins/previous demos remain unchanged.

The bundled check_run.py runs repeatable technical checks, hashes artifacts and
retains logs. It reports `technical_pass` separately and never auto-certifies
source fidelity. It accepts final theorem names explicitly because legacy
namespace conventions vary. Its lexical lints and optional banned-answer tokens
are bounded heuristics, not proofs of semantic nonleakage or API use. Manual
review covers transitive premises, actual shared dependencies, model boundary,
source classification, units bridges and exact/approximate meaning.

If a shared API is introduced, inspect the proof dependency graph (including
model definitions unfolded by simp/rfl) and independent examples. Name the actual
chain in PHYSLIB_AUDIT. Grepping an import or theorem name cannot establish this.

Success combines passed technical checks and completed semantic review. Empty
mutations can coexist with success when justified, but mutation status remains
skipped. A build failure, unknown axiom result, incomplete material units or
unresolved fidelity question cannot be relabeled success.
