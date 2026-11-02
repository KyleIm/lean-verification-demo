# Failure and deferral taxonomy (v1)

Use snake_case categories from the report schema. `deferred` means the model/task
boundary cannot currently be justified or required resources/input are unavailable;
`failed` means an attempted check or proof failed. Neither is a partial success.
Set one primary category and list secondary causes in notes with evidence.
Retry recommendations are advisory; the orchestrator controls retries.

| Category | Trigger / next action |
| --- | --- |
| invalid_input | Contract violation, unsafe path or duplicate target; correct request |
| source_ambiguity | Multiple materially different source interpretations; clarify |
| missing_diagram_information | Essential labels/topology absent; supply source geometry |
| source_solution_inconsistency | Inconsistent claims not resolved by a justified correction; review source |
| missing_reusable_physics | A bounded reusable law is missing and its model adoption is unresolved; model review |
| physlib_gap_too_large | Needed reusable extension exceeds this invocation; separate library project |
| pde_analysis_infrastructure_missing | Required PDE/eigenfunction/analysis derivation unavailable; do not substitute an adopted model silently |
| numerical_approximation_ambiguity | Resolution/significant-figure/error convention changes the result; clarify |
| unit_infrastructure_gap | A necessary unit interpretation/conversion cannot be established; resolve units |
| dependency_environment_failure | Missing/mismatched toolchain, package/cache/network; repair environment, preserve pins |
| lean_proof_failure | Elaborator/kernel rejects attempted proof; retain diagnostics and last valid stage |
| verification_failure | Pairing, mutation diagnostic, non-vacuity or regression fails; inspect failed obligation |
| timeout_resource_limit | Declared time/tool/token budget exhausted; retry only with a changed budget/strategy |
| copyright_source_data_issue | Actual unavailable/unauthorized source-data constraint; request lawful provided material; do not invent blanket legal requirements |
| human_review_required | Specific unresolved semantic/fidelity/assumption decision; name it |

On any unsuccessful run still emit schema-valid run-report.json, source provenance
if available, partial artifact list, last completed stage and diagnostics. Missing
proof artifacts must not cause report loss. Do not fill missing Lean files with
sorry to satisfy an artifact check. No automatic unbounded retry loop. A resolved
printed approximation like P13 is an audit note, not necessarily a failure.
