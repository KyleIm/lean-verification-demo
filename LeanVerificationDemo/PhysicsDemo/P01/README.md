# P01 — Stratified Transparent Plate

Problem ID: `physics-stratified-plate`

## Original Problem

A thick transparent plate has refractive index changing from `n₁` at the upper
face to `n₂` at the lower face.  A beam enters at angle `α`.  Under the modeled
assumptions, prove that the outgoing angle `β` equals the incoming angle `α`.

## Modeling Assumptions

The problem uses a finite stack of parallel sampled layers.  Each adjacent
interface carries local Snell-law evidence.  The external refractive index is
the same above and below the plate.

The continuous profile `n : ℝ → RefractiveIndex` is retained as problem data,
but the current proof uses the finite-layer invariant, not a continuous limiting
argument.

## Trusted Lean Proposition

```lean
def TrustedPhysicsProblem (data : PlateData) (ray : RayThroughPlate data) : Prop :=
  ray.β = data.α
```

The original problem remains parameterized by `α`.

## Candidate Solution Structure

The candidate proof chains:

```text
Entrance:  n₀ sin α  = n₁ sin θ₁
Internal:  n₁ sin θ₁ = n₂ sin θ₂
Exit:      n₂ sin θ₂ = n₀ sin β
```

Then it cancels the nonzero external refractive index and uses sine injectivity
on the physical angle interval to conclude `β = α`.

## Primitive Physics Reused From PhyslibTemp

The reusable primitive is `SnellLaw` from
`LeanVerificationDemo/PhyslibTemp/Optics/Refraction.lean`.

## Finite Stratified Model

`FiniteStratifiedStack` stores local adjacent-interface Snell-law evidence:

```lean
adjacent_snell :
  ∀ i, i < layerCount →
    SnellLaw (index i) (index (i + 1)) (angle i) (angle (i + 1))
```

## Derived Finite-Layer Invariant

`stratified_parallel_layer_invariant` chains adjacent Snell-law equalities and
rewrites the endpoints to the plate boundary indices.

## Stage 1 — Compilation Check

The problem verifier compiles:

- `Problem.lean`
- `Candidate.lean`

## Stage 2 — Proposition / Proof Pairing

The explicit pairing is:

```lean
example (data : PlateData) (ray : RayThroughPlate data) :
    TrustedPhysicsProblem data ray :=
  Candidate.solution data ray
```

Lean elaborates this declaration and checks the resulting type judgment.

## Stage 3 — Six-Mutation Summary

| ID | Category | Expected | Details |
| --- | --- | --- | --- |
| `PHYS-P001` | Entrance relation corruption | REJECT | [P001](../../../mutations/PhysicsDemo/P01/P001.md) |
| `PHYS-P002` | Internal relation corruption | REJECT | [P002](../../../mutations/PhysicsDemo/P01/P002.md) |
| `PHYS-P003` | Exit relation corruption | REJECT | [P003](../../../mutations/PhysicsDemo/P01/P003.md) |
| `PHYS-P004` | Target specialization | REJECT | [P004](../../../mutations/PhysicsDemo/P01/P004.md) |
| `PHYS-P005` | Irrelevant addition | ACCEPT | [P005](../../../mutations/PhysicsDemo/P01/P005.md) |
| `PHYS-P006` | Required internal-link deletion | REJECT | [P006](../../../mutations/PhysicsDemo/P01/P006.md) |

## Stage 4 — Annotated Proof

`CandidateAnnotated.lean` contains the same proof with human-facing comments.
Lean checks the Lean code in the annotated file.  It does not machine-check the
truth of the English comments.

## Continuous-Medium Limitation

This prototype does not prove the full continuous stratified-medium invariant by
a limiting argument.  The current PhyslibTemp API does not yet contain the
needed ray-path geometry, layered approximations, or limiting theorem.

## Current Verification Result

Current direct checks:

```text
lake build                                      PASS
LeanVerificationDemo/PhysicsDemo/P01/Verify.lean  PASS
PHYS-P001                                      REJECT -> PASS
PHYS-P002                                      REJECT -> PASS
PHYS-P003                                      REJECT -> PASS
PHYS-P004                                      REJECT -> PASS
PHYS-P005                                      ACCEPT -> PASS
PHYS-P006                                      REJECT -> PASS
CandidateAnnotated.lean                        PASS
```

## How To Run This Problem

Use the problem-centric verifier:

```bash
python3 scripts/verify.py P01
```

For manual/direct Lean checks:

```bash
lake build
lake env lean LeanVerificationDemo/PhysicsDemo/P01/Verify.lean
lake env lean LeanVerificationDemo/PhysicsDemo/P01/CandidateAnnotated.lean
```
