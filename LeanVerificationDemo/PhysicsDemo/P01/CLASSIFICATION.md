# P01 Physics / Math Classification

This document classifies concepts used in the stratified-plate proof.  The
classification helps decide which concepts should eventually accumulate in
PhyslibTemp.

| Component | Classification |
| --- | --- |
| `SnellLaw` from PhyslibTemp | Primitive physics; PhyslibTemp-reusable concept |
| `snellExpression` | Reusable optics expression in PhyslibTemp |
| Entrance relation `n₀ sin α = n₁ sin θ₁` | Primitive physics applied at the upper interface |
| Exit relation `n₂ sin θ₂ = n₀ sin β` | Primitive physics applied at the lower interface |
| Local `adjacent_snell` links | Primitive physics applied at each adjacent parallel interface |
| `stratified_parallel_layer_invariant` | Derived physics for the finite parallel-layer model |
| `FiniteStratifiedStack.snellExpression_chain` | Pure mathematics: induction and equality transitivity |
| `n : ℝ → RefractiveIndex` | Problem-specific modeling |
| `ContinuousOn (fun z => (n z : ℝ)) (Set.Icc 0 L)` | Problem-specific modeling / pure topology |
| Endpoint conditions `n 0 = n₁`, `n L = n₂` | Problem-specific modeling |
| Same external medium `n₀` above and below | Problem-specific modeling |
| Finite sampled stack of layers | Problem-specific modeling |
| Physical angle range assumptions | Problem-specific modeling |
| Chaining equalities | Pure mathematics / Lean equality reasoning |
| Cancelling positive `n₀` | Pure mathematics / Mathlib reasoning |
| Sine injectivity on the physical interval | Pure mathematics / Mathlib reasoning |
