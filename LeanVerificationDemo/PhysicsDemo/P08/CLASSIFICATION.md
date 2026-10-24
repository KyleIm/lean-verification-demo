# P08 classification

| Component | Classification | Boundary |
| --- | --- | --- |
| Physlib particle/system momentum and free-particle conservation | Existing Physlib formal primitives/results, audited but not imported | Trajectory/system APIs, not a breakup-event rule |
| EuclideanSpace, Submodule.span, span membership/closure, finrank bounds | Pure mathematics / existing Mathlib | Actual executable library reuse |
| `Vector3`, `ExplosionData` | Problem-specific modeling | Three snapshot velocities and positive masses in a common inertial basis; no rocket ontology |
| `momentum`, `preMomentum`, `totalMomentum` | Problem-specific physical modeling | Classical p = mv and additive momentum, explicitly written as scalar/vector operations |
| `SourceData.apex_at_rest` | Source/model physics | Apex velocity zero supplied from the vertical-flight explanation; no trajectory theorem |
| `SourceData.momentum_conserved` | Source/model physical approximation | Neglected external impulse across the short explosion; no exact gravity/zero-duration theorem |
| `LinearCoplanar`, `TrustedPhysicsProblem` | Problem-specific mathematical target | A linear subspace through zero of dimension ≤ 2, not affine coplanarity of endpoints |
| `pre_momentum_zero`, `total_momentum_zero` | Derived physics | Consequences of apex rest, momentum expressions and conservation |
| `first_momentum_eq_neg_sum`, `first_momentum_in_span` | Pure linear algebra | Zero sum puts the first vector in the other two's span |
| `momentumPlane`, `momenta_in_plane`, `momentum_plane_finrank` | Pure linear algebra | Explicit span witness and cardinality bound; degeneracies allowed |
| `momenta_coplanar` | Derived mathematical consequence of physics | No plane was supplied as evidence |
| `velocity_mem_of_momentum_mem` | Pure linear algebra applied to physical mass relation | Invert nonzero mass to preserve membership in the same subspace |
| `Candidate.solution` | Derived physics / mathematics | Conclude linear coplanarity of immediate fragment velocities |
| Verify balancing/zero examples and standard-basis negative check | Pure mathematics | Input consistency, degenerate cases and nontriviality of the target predicate |

P08 introduces **no PhyslibTemp concept**. No source solution image is treated as
geometric input, and no diagram caption or reconstruction is introduced.
