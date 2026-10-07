# Physics Demo: Stratified Plate Refraction

This demo tests the same four-stage verifier on a simple optics problem:

> A thick transparent plate has refractive index changing from `n₁` at the
> upper face to `n₂` at the lower face. A beam enters at angle `α`. What is the
> outgoing angle `β`?

Under the explicit model assumptions, the verified conclusion is:

```lean
ray.β = data.α
```

## Files

- `LeanVerificationDemo/Physics/Problem.lean`: trusted physics model and target.
- `LeanVerificationDemo/Physics/Candidate.lean`: candidate physics proof.
- `LeanVerificationDemo/Physics/Verify.lean`: Stage 2 type check.
- `LeanVerificationDemo/Physics/CandidateAnnotated.lean`: commented proof for human audit.
- `mutations/physics/EntranceSnellMutation.lean`: corrupts the entrance relation.
- `mutations/physics/InternalStratifiedMutation.lean`: corrupts a local internal Snell relation.
- `mutations/physics/PhysicsConclusionMutation.lean`: corrupts the conclusion.

## Primitive Physics Reused

The demo reuses the existing Snell-law API from Math2Physics/PhyslibTemp:

```lean
def SnellLaw
    (nIncident nTransmitted : RefractiveIndex)
    (θIncident : IncidentAngle) (θTransmitted : TransmittedAngle) : Prop :=
  snellExpression nIncident θIncident = snellExpression nTransmitted θTransmitted
```

This is imported from:

```text
Math2Physics.PhyslibTemp.Optics.Refraction
```

No duplicate Snell law is introduced.

## Finite Stratified Model

The continuous refractive-index profile is represented as problem data:

```lean
n : ℝ → RefractiveIndex
n_continuousOn : ContinuousOn (fun z => (n z : ℝ)) (Set.Icc 0 L)
n_upper : n 0 = n₁
n_lower : n L = n₂
```

The executable proof uses a finite sampled stack of parallel layers:

```lean
structure FiniteStratifiedStack where
  layerCount : Nat
  index : Nat → RefractiveIndex
  angle : Nat → NormalAngle
  adjacent_snell :
    ∀ i, i < layerCount →
      SnellLaw (index i) (index (i + 1)) (angle i) (angle (i + 1))
```

Only local adjacent-interface Snell-law evidence is stored. The endpoint
invariant is not stored as a field.

## Derived Physics

The finite-layer invariant is genuinely derived by Lean:

```lean
theorem snellExpression_chain
    (stack : FiniteStratifiedStack) :
    snellExpression (stack.index 0) (stack.angle 0) =
      snellExpression (stack.index stack.layerCount) (stack.angle stack.layerCount)
```

It is proved by induction and equality transitivity over adjacent local Snell
equalities. The plate-level theorem then rewrites the endpoints:

```lean
theorem stratified_parallel_layer_invariant
    (data : PlateData) (ray : RayThroughPlate data) :
    snellExpression data.n₁ (ray.stack.angle 0) =
      snellExpression data.n₂ (ray.stack.angle ray.stack.layerCount)
```

## Final Proof

The final candidate proof combines:

1. Entrance Snell law: `n₀ sin α = n₁ sin θ_upper`.
2. Derived finite-layer invariant: `n₁ sin θ_upper = n₂ sin θ_lower`.
3. Exit Snell law: `n₂ sin θ_lower = n₀ sin β`.
4. Pure math: chain equalities, cancel positive `n₀`, use sine injectivity.
5. Conclusion: `β = α`.

## Mutation Tests

| Mutation | Corruption | Expected result |
| --- | --- | --- |
| Entrance | starts the chain from the wrong internal expression | Lean type mismatch |
| Internal | pairs transmitted refractive index with the incident angle | Lean type mismatch |
| Conclusion | checks the valid proof against `β ≠ α` | Lean type mismatch |

The internal mutation intentionally changes one meaningful component of a local
adjacent-interface relation:

```lean
-- Correct
SnellLaw (index i) (index (i + 1)) (angle i) (angle (i + 1))

-- Mutated
snellExpression (index i) (angle i) =
  snellExpression (index (i + 1)) (angle i)
```

## Classification

| Component | Classification |
| --- | --- |
| PhyslibTemp `SnellLaw` | Primitive physics |
| Local entrance, exit, and adjacent-interface Snell applications | Primitive physics |
| Finite sampled layer representation | Problem-specific modeling |
| Continuous profile and endpoint values | Problem-specific modeling |
| Finite induction and equality chaining | Pure mathematics |
| Cancellation and sine injectivity | Pure mathematics |
| Finite-layer Snell invariant | Derived physics |
| Final `β = α` result | Derived physics plus pure mathematics |

## Continuous-Medium Limitation

This prototype does **not** prove the full continuous gradient-index invariant:

```text
n(z) * sin(theta(z)) = constant
```

The continuous profile is represented mathematically, but the executable proof
establishes the Snell invariant only for a finite stratified parallel-layer
model. A rigorous limit from arbitrarily fine layered approximations to the
continuous medium requires additional ray-geometry and limiting machinery that
is not currently present in PhyslibTemp.
