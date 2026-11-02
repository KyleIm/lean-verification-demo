# PhyslibTemp boundary

Add a module only after the reuse audit establishes a meaningful missing reusable
physical concept. Explain at least one independent application beyond this
exercise. Reuse upstream physical objects and mathematics. Define relations or
models with explicit assumptions; do not introduce new Lean axioms to assert
physics or cover proof gaps.

Keep source constants, material names, table categories, exercise topology,
thresholds, requested rounding and source-specific unit interpretation local.
A generic law may be adopted as a physical-model definition if the requested task
permits that model boundary; distinguish that from deriving it from deeper laws.
If the request requires the deeper derivation and infrastructure is missing,
defer rather than redefine the answer as a law.

Validated corpus examples:
- ConstantAcceleration extends upstream ReferenceFrame.Particle in arbitrary
  dimension, deriving velocity/position from derivative-based acceleration;
  no rocket or gravity-specific ontology.
- ImpulseMomentum provides finite-system Newton II/III cancellation, integration,
  shrinking-interval/event-limit results and upstream adapters; no explosion law.
- Reflection provides unit-normal mirror semantics and invariants over Mathlib
  orthogonal reflection; screen/object/shadow sets stay local.
- VibratingString adopts an ideal uniform flexible fixed-string law, proves
  positivity/harmonics and endpoint-compatible sine shapes; it does not prove
  PDE spectral completeness. Cylinder/steel/source-unit data stay in P13.
- CapacitorBasics is independent of plane geometry; BreakdownSpec is optional
  and indexed by a capacitor, not mandatory failure data on every capacitor.

Supply design notes (scope, assumptions, upstream path, limits) and an independent
Examples.lean using different parameters/geometries or edge dimensions where
meaningful. Compile examples. Document the dependency from final Candidate
validity through actual shared APIs. An import, an unused theorem, or a duplicate
local implementation is insufficient. Inspect proof dependencies/unfolded model
use; lexical occurrences alone are not proof of use. If the new module can be
removed without affecting the claimed physical derivation, revisit the design.

Do not generalize merely because a second exercise looks similar: P12 deliberately
keeps short scalar projections local and reuses generic kinematics. Promotion and
API shape remain research judgments, reviewed under the experimental-policy ledger.
