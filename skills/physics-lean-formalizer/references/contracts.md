# Single-problem API contracts v1

Canonical shapes are `schemas/input.schema.json` and `schemas/run-report.schema.json`
(Draft 2020-12). Validate with the bundled validator; jsonschema>=4 is a small
host-side prerequisite, not a Lean project dependency. `evals/input.example.json`
is a complete portable request example. JSON-schema validation does not verify
provenance or the truth of reported checks.

## Input interpretation

Exactly one problem_id and one desired_code per invocation. `problem_text` is
required; `supplied_solution` may be absent/null. `source_data` is an object
(possibly empty), with native numeric strings, units, table axes, all entries and
provenance. Each optional figure has a problem/solution_reference role, caption,
path (nullable), structured geometry and provenance. Missing image does not mean
its caption was independently checked. No figure is required when text suffices.

`target_repository` identifies an existing checkout; `base_commit` and
`dependency_context` identify its reproducible starting state. The latter carries
Lean toolchain and resolved Mathlib/Physlib commits, not a moving latest branch.
Resolve relative paths against the request file's directory; report normalized
repository and output paths. Validate target code, path containment and initial
dirty state before editing. Existing target defaults to forbidden; allow it only
for an explicitly scoped repair request, preserving initial changes. Do not
reset/overwrite other files or update pins.

`budget.wall_seconds` and `max_proof_attempts` bound work. An attempt means one
coherent proof/model strategy, not each compiler diagnostic. Record attempted
strategies; stop on a repeated unresolved blocker or budget exhaustion. The
host should independently enforce wall/tool/token limits because a Markdown
instruction cannot enforce process resource bounds. No problem-list field exists.

Missing solution → derive independently. Missing nonessential figure → record
absence and continue. Material ambiguity → structured deferral. Missing major
physics/PDE infrastructure → library-project deferral, not an invented law. A
conventional choice can proceed when physically justified and nonmaterial,
explicitly labeled; a choice altering the answer needs review.

## Final report

Write `run-report.json` and return the same JSON object (no surrounding prose for
API calls). `status`: success, deferred or failed. `problem_id` is the source ID;
`problem_code` is local PXX; `formalization_path` can be null for early failure.
`input_sha256` hashes the exact request bytes; `repository_commit` records actual
HEAD and notes disclose dirty state. `skill_version` is the reviewed skill release.

`physlib_reused` lists real declarations and their roles, not decorative imports.
`physlibtemp_added` lists each new path, APIs, actual Candidate dependency and
independent examples; empty array means no new module. `units_checked`,
`build_status`, and verification subchecks use a shared shape:
`{status, evidence: [paths/declarations], reason: string|null}`. Pass requires
evidence; skipped/not_run/not_applicable requires a reason. `approximation_audit`
records exact_only/certified/not_applicable/unresolved and its claims/evidence.

Verification subchecks separate pairing, annotation, walkthrough, axioms,
non-vacuity, negatives, mutations, regressions, source fidelity, answer separation
and reuse dependency. Non-vacuity may be a direct unconditional construction;
only meaningful conditional claims need model witnesses. Exact library dependency
inspection can be manual and its evidence must say what was inspected. A lexical
check does not complete source_fidelity/answer_separation/reuse_dependency.

Successful reports require a passed build, core verification/semantic reviews,
resolved approximation, applicable units checks, no failure_category and a hashed
artifact inventory. Allowed skips still need reasons. Failed/deferred reports
require a taxonomy category, last completed stage, retry recommendation and notes.
Retain partial files and all diagnostic logs without certifying them as complete.
`evidence_path` points to check_run's evidence.json when checks were attempted.
`omitted_artifacts` explains relevant absent files. Artifacts and evidence are
repository relative where possible; paths outside it are explicitly absolute.

The report is a new adapter contract. Do not replace legacy verification.json
or pretend source.jsonl already follows this schema. An orchestrator should
validate the JSON, compare its evidence/hashes with retained files, and gate
commits on its own acceptance policy. Never infer success from HTTP 200, a
model's final sentence, or the legacy verifier exit code alone.
