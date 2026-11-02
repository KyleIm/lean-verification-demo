# Archaeology and policy ledger — draft 0.1.0

## Evidence and scope

Primary behavioral specification: local clean checkout of
https://github.com/KyleIm/lean-verification-demo at
`db175110266e96e4ee77b340697e9b7b34e98968` (P13 witness refactor).
The public GitHub page fetched during this review exposed an older M00/P01
snapshot; use the recorded local commit/hashes for this report rather than
claiming remote HEAD equality. `evals/corpus-lock.json` inventories source hashes.
Root README, verifier/configs, M00 and P01–P13 artifacts, shared APIs and selected
history were examined; P08/P09 and P11–P13 were studied at model/Candidate/test
level. This is a first extracted policy, not a claim of comprehensive physics coverage.

## What the corpus actually teaches

| Case | Workflow evidence and corrections | Generalizable lesson / limitation |
| --- | --- | --- |
| M00 | Independent proposition/proof and explicit pairing; six controlled mutations including irrelevant addition accepted | Kernel pairing is a separate stage from source fidelity; no physics ontology needed |
| P01 | Local adjacent Snell evidence chained by induction, physical-angle injectivity; continuous profile unused; transmission supplied | Derive global links, disclose unused assumptions and finite-layer/continuous-model gap; its closed answer target is historical |
| P02 | Stable unit infrastructure reused; normalized microscopic ideal gas rejected as a direct molar API; amount relation plus molar law | Inspect actual types/normalizations, distinguish unit scales from quantities; phenomenological law adoption is explicit |
| P03 | Plane model, optional indexed breakdown, inclusive maximum with attainability; source-derived glass margin local | Separate generic component semantics from optional failure specifications; circuit series assumptions remain local, not a Maxwell derivation |
| P04 | Caption edge list, nodal neutrality, derive internal potentials and terminal charge; solvability/nonnegative equivalent C | Derive symmetry/equipotentials, don't assume them; generic network separate from plane geometry; final 6C/5 in Problem is superseded for new find requests |
| P05 | Force/moment snapshots over upstream objects; static bound not saturation everywhere; reachable/unreachable ladder threshold | Include regimes and physical-domain reachability; no post-slip dynamics claim; solution Fig.311 isn't source geometry |
| P06 | Wavelength reused; explicit retained-channel approximation; no new shared propagation ontology | Qualitative approximation can be legitimate but may not become an absolute real-world impossibility theorem |
| P07 | Differentiate flux, solve local Faraday/Ohm profile, integrate annular contributions; historical unit factor retained | Do not identify H with SI B or scalar ring profile with vector J; image provenance is explicitly imperfect, not clean figure gold |
| P08 | Replaced apex_at_rest premise with reusable acceleration → height maximum → rest; removed momentum_conserved field in favor of Newton II/III → finite impulse → duration limit → event equality | Refine omissions/approximations when justified, expose regularity/event-limit assumptions; linear coplanarity allows zero/collinear cases |
| P09 | Reuses generic acceleration for separate segments; derives a=μg and stopping identity, elastic speed matching; exact 5/49 vs approximate .102; additive typed units | Don't assume v²=2as, conflate static/moving friction, or extend physical deceleration after stopping; numerical target still legacy |
| P10 | Caption polyline → exact integrals/nonnegativity → path/displacement and means; units in cm/s | Minimal representation: no unnecessary particle/force object; graph vertices are input, areas are derived; means in target are legacy |
| P11 | Fig.237 source vs Fig.494 solution; derived intersections/regimes; correct channel/orientation terminology; initial no-extension decision revised to reusable Reflection over Mathlib | Pure math primitive alone isn't physical semantics; source-independent optics belongs shared, screen thresholds stay local; avoid copying explicit conclusions into new find targets |
| P12 | All 70 original decimal strings preserved, km/h conversion; derive estimator; compute coefficient witness from first sample, validate all samples; physical compatibility plus per-row consistency; rounding uniqueness | Experimental rows can differ exactly but agree at requested resolution; don't synthesize data or introduce uncertainty; final theorem must use physics, not just table arithmetic |
| P13 | Native CGS and SI bridge; adopted reusable ideal FixedString law, cylinder derivation local; exact sqrt(490/(39π)) and strict bounds, printed 2 audited; final refactor constructs frequency witness | Open semantic specification replaces answer-bearing exact/harmonic predicates; reusable model law is allowed, combined source answer is Candidate; sine endpoints aren't PDE completeness |

## Reconstructed invariant stages

The actual workflow is a two-track audit joined by a checked certificate:
source provenance → classification/model reconstruction → pinned-library audit →
local/shared boundary decision → semantic request specification → explicit
Candidate derivation/construction → numerical/unit audits → consistency/negative
checks → kernel pairing and regressions → documented scope/evidence.

Physics assumptions and source fidelity remain a human/modeling obligation even
when all Lean code compiles. The verifier's four stages are compilation, pairing,
mutations, annotated compilation; library search, units, axiom inspection,
walkthrough compilation and interpretation reviews sit outside that verifier.
P03–P13 explicitly defer mutation manifests, so “all PASS” does not mean all
problems have adversarial mutation coverage. The new report must expose this.

## Stable enough to encode now

- One invocation, one source problem; preserve source separately and pin context.
- Audit supplied solutions and classify every consequential assumption/derivation.
- Open find requests use semantic criteria and constructed answers; don't trust the
  problem-specific numerical/closed-form answer. Reusable physical semantics may
  occur in the model, with their adopted/derived status visible.
- Search actual stable declarations before a gap claim; distinguish informal,
  Alpha, unrelated normalizations and pure mathematics from reusable physics.
- Shared physics is source-independent, minimal and demonstrably used.
- Unit conversion and typed/scalar bridges are explicit where material.
- Exact, approximate, requested rounding and uncertainty are different claims.
- Source geometry and solution-reference diagrams stay separate.
- Non-vacuity, appropriate negatives, axiom inspection and real compilation evidence
  complement pairing; skip states are preserved honestly.
- Report a justified deferral instead of unsupported assumptions or admissions.

## Experimental / proposed policies

These are **design additions for scaling**, not established corpus facts:
- v1 JSON request/report schema, failure categories and retry advice; evaluate on
  new failures before freezing a stable 1.0 contract.
- General preference for witness specifications is strongly supported by P12/P13;
  application to gauge theories, nonunique extrema, inverse problems and continuum
  spectra needs review. Uniqueness is never a mechanical requirement.
- Automatic leakage/dependency lints are only heuristics; there is no reliable
  general semantic leakage oracle in the corpus.
- Exact boundaries for promoting shared APIs and accepting phenomenological models
  require domain review; no universal “minimum number of uses” rule is justified.
- P12's nearest-tenth and P13's integer-Hz conventions do not establish a universal
  significant-figure or measurement-uncertainty policy.
- PDE completeness, advanced asymptotics, uncertainty propagation and robust
  numerical-analysis automation are not demonstrated by these examples.
- Resource budgets, proof-attempt counting and automatic retry routing require
  host enforcement and calibration; no claim of throughput over thousands yet.
- Requiring source-independent examples for every substantial new shared API
  follows the later layers; how much example coverage is enough remains unsettled.

## Skill methodology and portability

Anthropic skill-creator was inspected as a methodology: draft, realistic prompts,
objective and qualitative evaluation, feedback and iteration. Its Claude-specific
CLI/subagent/eval-viewer dependencies are not required by this skill. No automatic
trigger-description optimization against a Claude CLI is assumed.

OpenAI/Codex guidance supports a name/description frontmatter, instructions and
progressively loaded supporting files. The core uses only portable SKILL.md,
relative references, Python checks and existing Lean/Lake tools; no MCP server,
plugin manifest, model name, provider key or vendor-specific agent API is required.
API loading details live in operation.md, not in physical-model policies.

Sources inspected for methodology (accessed 2026-11-01):
- https://github.com/anthropics/claude-plugins-official/blob/main/plugins/skill-creator/skills/skill-creator/SKILL.md
- https://learn.chatgpt.com/docs/build-skills
- https://developers.openai.com/api/docs/guides/tools-skills
- https://developers.openai.com/plugins/build/skills

Architecture: SKILL.md routes to repository-contract, contracts,
problem-candidate-separation, source-solution-audit, physlib-reuse,
physlibtemp-policy, units-and-dimensions, approximation-and-data, figures,
verification and failure-taxonomy. schemas hold machine contracts; scripts retain
technical evidence; evals hold locked corpus references, prompts and grading
criteria. operation documents installation, invocation, testing and versioning.
This document is review evidence, loaded only for policy evolution.
