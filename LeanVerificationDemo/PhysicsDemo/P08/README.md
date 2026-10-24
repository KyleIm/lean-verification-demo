# P08 — Three fragment velocities lie in one linear plane

Source problem **77**. [Source record](source.jsonl) ·
[Pinned-library audit](PHYSLIB_AUDIT.md) · [Classification](CLASSIFICATION.md).

## Source question vs formalized question

### BEFORE — original source problem

> 77. A rocket launched vertically upward explodes at the highest point it reaches. The explosion produces three fragments. Prove that the vectors of the initial velocities of all three fragments are in one plane.

The supplied printed solution uses rest at the apex and negligible gravitational
impulse during the short explosion to obtain zero total post-explosion momentum.
It then asserts the coplanarity of three zero-sum momentum vectors and transfers
that conclusion to velocities.

### AFTER — Lean-facing formalized problem

Given three positive masses and their immediate post-explosion velocity vectors
in a common three-dimensional real coordinate space, assume the rocket's apex
velocity is zero and total momentum is conserved across the explosion in the
adopted approximation. Prove that **there exists a real linear subspace through
the origin of dimension at most two containing all three velocities**.

```lean
Candidate.solution data source : TrustedPhysicsProblem data
```

The exact expanded target is:

```lean
∃ plane : Submodule ℝ Vector3,
  Module.finrank ℝ plane ≤ 2 ∧ ∀ i, data.velocity i ∈ plane
```

`Vector3 = EuclideanSpace ℝ (Fin 3)`. All its subspaces are finite-dimensional,
so the natural-number finrank has its ordinary dimension meaning.

### What changed

“Initial” means immediately **after** the explosion; the apex condition refers
to the instant immediately **before** it. A problem-local snapshot replaces the
full rocket, its trajectory and fragment motion. The printed negligible-impulse
argument becomes an explicit event-conservation premise; no finite-duration
force integration or error estimate is formalized.

The mathematical conclusion is made precise as **linear** coplanarity. Affine
coplanarity of the three velocity endpoints would be automatic for any three
points and would not express the source argument. Zero velocities, collinear
vectors and a zero-dimensional span are allowed; no independence hypothesis is
added. The “plane” witness may therefore be a line or {0}, contained in a plane.

The physical meaning of the source explanation is preserved under its adopted
approximation, while its last linear-algebra assertion is genuinely proved,
rather than assumed. The transformation is **qualitative event-momentum
reasoning → explicit source premises → a constructed linear-subspace witness**.

## Local physical representation and exact premises

`ExplosionData` stores `mass : Fin 3 → ℝ`, `mass_pos`,
`velocity : Fin 3 → Vector3`, and `apexVelocity : Vector3`.
Indices 0,1,2 are the source's fragments 1,2,3. There is no reusable `Rocket` or
`Explosion` object. All values are coordinates in one fixed inertial frame and
coherent units (for example kg, m/s and kg·m/s); dimensions are not encoded in
the vector type. Sharing the coordinate space permits the direction/span
argument, but is not a unit-covariance theorem.

The local definitions explicitly express the classical snapshot relations:

```text
pᵢ = mᵢ • vᵢ
Pbefore = (m₁+m₂+m₃) • vapex
Pafter = p₁+p₂+p₃.
```

The pre-event expression models the rocket constituents as co-moving with its
translational velocity. Rotation is not part of this source model. Positive
masses are physical data; in the transfer argument only their nonzeroness is
used. Neither a plane nor a zero post-event momentum is an input field.

The two exact evidence fields in `source : SourceData data` are:

```lean
apex_at_rest : data.apexVelocity = 0
momentum_conserved : totalMomentum data = preMomentum data
```

The first is the apex-rest source fact, not derived from a modeled vertical
trajectory. The second is the exact rule **within** the adopted short-event
approximation. The printed explanation justifies neglecting external gravity
impulse because the event is very short; Lean does not prove gravity literally
has zero impulse or that duration is mathematically zero. Momentum need not
remain zero during subsequent fragment motion in gravity, and no such dynamics
is claimed.

## Candidate derivation

The reviewer-facing Candidate exposes these named stages:

```text
pre_momentum_zero
  vapex = 0 → Pbefore = 0

total_momentum_zero
  event conservation → p₁+p₂+p₃ = 0

first_momentum_eq_neg_sum / first_momentum_in_span
  p₁ = -(p₂+p₃) → p₁ ∈ span{p₂,p₃}

momenta_in_plane / momentum_plane_finrank / momenta_coplanar
  all three momenta belong to that span; its dimension is at most 2

velocity_mem_of_momentum_mem
  vᵢ = mᵢ⁻¹ • pᵢ; positive mᵢ makes this legitimate

solution
  the same real linear subspace contains all three velocities.
```

Membership of the generators, addition and negation prove the momentum part;
Mathlib's finite-span dimension bound proves the plane's size. Inverse scaling
preserves membership because it is a linear subspace through zero. No division
by a velocity, no cross-product nondegeneracy and no linear independence is
required. The final theorem explicitly displays its existential target before
assembling the already-proved dimension bound and velocity membership.

`CandidateAnnotated.lean` labels source/model physics, derived physics and pure
linear algebra. It follows the actual dependency chain; comments are explanatory,
not additional evidence checked by Lean.

## Libraries and reusability

Mathlib supplies vectors, spans, submodule closure and dimension machinery.
Physlib has genuine formal definitions of particle/system momentum and genuine
conservation theorems in other models. Its Newtonian particle API requires
trajectories and a full inertial Newtonian system; its free-particle conservation
theorem does not cover a one-to-three breakup under a short-impulse approximation.
These were inspected, not imported and misrepresented as an explosion proof.
The local snapshot multiplication is the same classical `p = mv` relation.

**No PhyslibTemp declaration is added.** The missing across-event semantic
premise stays local, and the short span proof belongs to ordinary linear algebra,
not a new reusable physics API. See the audit for exact sources and search scope.

There is no diagram-dependent geometry. Any supplied solution image serves only
as the textual explanation's provenance, not a trusted diagram; no caption,
figure interpretation or reconstructed image is introduced.

## Verification

```bash
lake build
python3 scripts/verify.py P08
# Source problem ID also works:
python3 scripts/verify.py 77
```

`Verify.lean` checks the candidate/target pairing, constructs balanced positive-mass
inputs for arbitrary two vectors (including zero), and checks a nonzero example.
It also proves that three standard basis vectors are **not** linearly coplanar,
so the target predicate is not the trivial three-point affine property.
The parameter and source-evidence domains are satisfiable; the result is not
obtained from contradictory assumptions.

Mutation cases are explicitly deferred (`mutations.json` is empty), consistent
with P03–P07. `PairingWalkthrough.lean` checks the main lemma types and prints the
final theorem axioms. Dependency pins and prior demo implementations are unchanged.

### Validation results

- `lake build`: PASS (3642 jobs); existing module-interoperability warnings remain.
- M00 and P01–P08 verification: PASS.
- M00/P01/P02 mutation cases: 6/6 each; P03–P08 explicitly SKIPPED.
- Positive-mass source consistency, zero/nonzero balancing examples and the
  standard-basis noncoplanarity check: PASS.
- Final theorem axioms: `[propext, Classical.choice, Quot.sound]`; no `sorry` or new axioms.
- `git diff --check`: PASS. No dependency pins, PhyslibTemp modules or prior demo implementations changed.
