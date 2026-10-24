# P08 pinned-library audit

Inspected the dependency sources actually selected by `lake-manifest.json`:

- Physlib: `96a6bc5e3c50a2856c64a6c9951c0a1c23790b58`.
- Mathlib: `56a005855ea17e0b0958f73ec801ae140b0a1679` (`v4.35.0`).
- Lean: `4.35.0`. No dependency pins changed.

Paths below are relative to the respective package root. Types are shown in the
specialization used here where generic typeclass parameters would obscure them.

## Search evidence

```bash
rg -n -i 'momentum|impulse|collision|explosion' Physlib/ClassicalMechanics PhyslibAlpha/ClassicalMechanics
rg -n -i 'impulse|collision|explosion|momentum.*conserv|conserv.*momentum' Physlib PhyslibAlpha
rg -n 'finrank_span|mem_span_pair|span_pair' Mathlib/LinearAlgebra
rg -n 'def Coplanar|coplanar_triple|coplanar_insert' Mathlib/LinearAlgebra/AffineSpace
rg -n 'linearIndependent_iff_card_eq_finrank_span|smul_mem_iff' Mathlib/LinearAlgebra Mathlib/Algebra/Module/Submodule
```

Inspected the formal definitions below, along with
`Physlib/ClassicalMechanics/Force.lean`, `RigidBody/Motion.lean`,
`RigidBody/Basic.lean`, the Lagrangian API map and the related Alpha search hits.
No event-level explosion/collision or impulse-to-conserved-momentum API was
found in these whole-tree searches. This does not mean momentum or momentum
conservation is missing from Physlib: formal examples do exist, as follows.

## Stable Physlib mechanics

| Location and declaration | Type / meaning | Applicability |
| --- | --- | --- |
| `ClassicalMechanics/PointParticle/Basic.lean:47`, `ClassicalMechanics.ReferenceFrame.Particle` | `(frame : ReferenceFrame d) → Type`; fields include `mass : {m : ℝ // 0 < m}`, `pos : ℝ → frame.Vector`, inertial-frame twice-differentiability evidence | Actual formal positive-mass particles with trajectories; not an event snapshot |
| Same file:64, `ClassicalMechanics.ReferenceFrame.Particle.velocity` | `(particle : frame.Particle) → [Fact (Differentiable ℝ particle.pos)] → ℝ → frame.Vector`, defined by `deriv particle.pos` | Formal derivative velocity; imposing a global trajectory would add unnecessary structure here |
| `ClassicalMechanics/PointParticle/NewtonianSystem/Basic.lean:103`, `ClassicalMechanics.PointParticle.NewtonianSystem.Particle.momentum` | `{system : NewtonianSystem d} (particle : system.Particle) (t : ℝ) : system.Vector`, defined as `particle.mass • particle.velocity t` | Formal `p = mv`, but requires a whole inertial Newtonian system |
| Same file:194, `ClassicalMechanics.PointParticle.NewtonianSystem.momentum` | `(system : NewtonianSystem d) (t : ℝ) : system.Vector`, the finite sum of particle momenta | Formal total momentum for a fixed particle system, not a one-body-to-three-body transition rule |
| `ClassicalMechanics/FreeParticle/Basic.lean:110`, `ClassicalMechanics.FreeParticle.linearMomentum` | `(s : FreeParticle) (q : Trajectory) (t : Time) : ℝ`, defined as mass times scalar velocity | Formal one-dimensional free-particle observable |
| Same file:183, `ClassicalMechanics.FreeParticle.linearMomentum_conserved` | `(s : FreeParticle) (q : Trajectory) (h : ∀ t, s.NewtonsSecondLaw q t) (hcont : ContDiff ℝ 2 q) : ∃ p, ∀ t, s.linearMomentum q t = p` | Actual formal conservation theorem for a smooth free particle; does not cover breakup or neglect of a finite gravitational impulse |
| `ClassicalMechanics/RigidBody/Motion.lean:71`, `RigidBodyMotion.linearMomentum` | `{d : ℕ} (M : RigidBodyMotion d) : Time → EuclideanSpace ℝ (Fin d)`, `M.mass • M.centerOfMassVelocity t` | Formal rigid-body momentum; no across-explosion bridge |

The full Newtonian system requires inertial-frame particles, differentiable
positions/velocities and Newton's second/third laws. P08 does not construct those
trajectories merely to obtain the elementary snapshot expression `m • v`.
Its local momentum definition records that expression transparently. No stable
Physlib mechanics declaration is directly imported or claimed as a proof of this
explosion approximation; the executable library reuse in P08 is Mathlib.

## Informal and secondary references

`RigidBody/Basic.lean:217` (`translational_equation_inertial`) and related entries
are `informal_lemma` declarations. `Meta/Informal/Basic.lean:67` expands that syntax
into a `def ... : InformalLemma`, not a theorem proving the advertised equation.
The Lagrangian `API-map.md:34` lists momentum conservation via Noether as TODO.
Neither is used as a formal proof.

Alpha Norton-dome, central-force and Galilean moment-map modules have momentum
or angular-momentum observables in their specific models; they do not provide a
three-fragment event rule. Quantum crystal-momentum sectors and continuum fluid
momentum equations are also unrelated to this snapshot transition. No Alpha
module is imported.

## Mathlib support and chosen representation

| Location and declaration | Used type / role |
| --- | --- |
| `Analysis/InnerProductSpace/PiL2.lean:114`, `EuclideanSpace` | `EuclideanSpace ℝ (Fin 3)` supplies the real vector space, scalar action and finite-dimensional structure |
| Same file:225, `finrank_euclideanSpace_fin` | `Module.finrank ℝ (EuclideanSpace ℝ (Fin 3)) = 3`; every submodule is finite-dimensional |
| `LinearAlgebra/Span/Defs.lean:46`, `Submodule.span` | `(s : Set Vector3) → Submodule ℝ Vector3` |
| Same file:75, `Submodule.subset_span` | `s ⊆ Submodule.span ℝ s`; generators are members |
| Same file:519, `Submodule.mem_span_pair` | `z ∈ span ℝ {x,y} ↔ ∃ a b : ℝ, a • x + b • y = z`; inspected alternative, not required by the closure proof |
| `Algebra/Module/Submodule/Defs.lean`, `Submodule.add_mem`, `neg_mem`, `smul_mem` | Subspaces are closed under addition, negation and scalar multiplication; used directly |
| `LinearAlgebra/Dimension/Constructions.lean:450`, `finrank_span_finset_le_card` | For finite s, `Module.finrank ℝ (span ℝ (s : Set Vector3)) ≤ s.card`; combined with `Finset.card_le_two` |
| `Algebra/Module/Submodule/Basic.lean:172`, `Submodule.smul_mem_iff` | For nonzero c, `c • v ∈ S ↔ v ∈ S`; inspected equivalent route. Candidate instead explicitly applies inverse scalar multiplication |
| `LinearAlgebra/Dimension/OrzechProperty.lean:41`, `linearIndependent_iff_card_eq_finrank_span` | Relates finite-family independence to span dimension; no independence hypothesis is needed here |

`LinearAlgebra/AffineSpace/FiniteDimensional.lean:780` defines **affine**
`Coplanar k s` using the vector space of point differences. Its
`coplanar_triple` at line 904 proves every three points coplanar. That would make
the source's conservation argument irrelevant, so P08 does not use it. The
problem-local `LinearCoplanar` is an explicit existential over a real linear
submodule through zero with finrank ≤ 2, with membership for every vector.
It is not a Boolean placeholder, nor a new general-purpose library API.

## Minimum extension decision

- Stable Physlib mechanics: definitions audited and consistent with the adopted
  scalar-action model, but no directly applicable event conservation bridge.
- Mathlib: real Euclidean vectors, submodule span/closure and finite dimension.
- PhyslibTemp: **no additions**. General linear algebra belongs in Mathlib;
  the small local proof does not justify another physics module.
- P08: three masses/velocities, apex-rest data, pre/post event conservation,
  explicit momentum expressions and the linear-coplanarity target.

The chosen proof constructs span{p₂,p₃}, derives membership of p₁ from the
zero sum, bounds its dimension by two, and recovers each vᵢ by mᵢ⁻¹ • pᵢ.
No nonzero-velocity or independence assumption is used. Verify also rejects
linear coplanarity of the three standard basis vectors, distinguishing this
predicate from the unsuitable affine three-point property.
