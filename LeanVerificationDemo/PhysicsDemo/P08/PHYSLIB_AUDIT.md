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

The refined P08 imports upstream Particle via the new constant-acceleration
layer and uses actual `Particle.pos`, `velocity`, `acceleration` and
`pos_twice_differentiable`. It does not construct a full NewtonianSystem or claim
that a smooth free-particle theorem proves across-explosion conservation.
Fragment momenta remain snapshot expressions; the rocket's pre-event momentum
now uses its upstream Particle mass and its derived apex velocity.

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

## Refined constant-acceleration / apex audit

Before adding a library layer, re-searched all stable and secondary Alpha trees:

```bash
rg -n -i 'constant.acceler|uniform.*acceler|free.fall|uniform.gravit|projectile' Physlib PhyslibAlpha
rg -n -i 'turning.point|apex|gravitational' Physlib/ClassicalMechanics PhyslibAlpha/ClassicalMechanics
```

No dimension-generic constant-acceleration velocity/quadratic-position API was
found at this pin. The formal FreeParticle zero-acceleration/constant-velocity
results above are one-dimensional. Pendulum gravitational parameters and Alpha
Norton-dome apex/gravity theorems are specialized models; they are not uniform
free fall or the desired general particle kinematics. The upstream Force and
NewtonianSystem definitions were re-inspected: no direct uniform-gravity force
specialization was found that could be reused here without building another
system model. No Alpha declaration is imported.

Additional Mathlib APIs used:

* `Analysis/Calculus/MeanValue.lean:751`, `is_const_of_deriv_eq_zero`:
  for a differentiable real-parameter normed-space-valued function f whose
  derivative vanishes everywhere, `f x = f y`. This proves the generic velocity
  and position laws after subtracting their proposed polynomial terms.
* Derivative arithmetic (`HasDerivAt.sub`, `smul_const`, `pow`, `div_const`)
  works on upstream frame vectors under `Fact frame.IsInertial`.
* `Analysis/Calculus/LocalExtr/Basic.lean:247`,
  `IsLocalMax.hasDerivAt_eq_zero`: `IsLocalMax f t → HasDerivAt f v t → v = 0`
  for scalar height f. P08 uses it with a genuine proved height derivative;
  it does not rely on `deriv`'s fallback value for nondifferentiable functions.

## Minimum extension decision (revised)

- Stable Physlib directly reused: `ReferenceFrame`, its inertial metric/vector
  infrastructure, `ReferenceFrame.Particle`, `pos_twice_differentiable`,
  `Particle.pos`, `Particle.velocity` and `Particle.acceleration`.
- New PhyslibTemp `ConstantAcceleration.lean`: `HasConstantAcceleration`,
  `hasDerivAt_velocity`, `velocity_eq`, `position_eq`, `velocity_sub` and
  `velocity_eq_of_zero`, all dimension-generic and gravity-independent.
- `ConstantAccelerationExamples.lean`: verification witnesses built as upstream
  particles, plus zero-acceleration, zero-initial-velocity, arbitrary-reference-time
  and position-law checks, with explicit dimensions 4 and 0.
- No `UniformGravity` module yet: merely renaming a constant acceleration vector
  adds no physical theorem. A future layer should supply a force/Newton-II bridge.
- P08 supplies its fixed vertical direction, downward acceleration, initial speed,
  height and apex specialization. Highest height and zero apex velocity are
  derived; across-explosion momentum conservation remains a source approximation.

The previous `apex_at_rest` source field is removed. The new exact premises are
constant downward acceleration of an upstream particle, initial upward velocity,
and conserved momentum across the explosion. Upward speed and g are positive
model parameters; regularity is inherited from the upstream particle structure.

The constant-acceleration proof uses all real frame-time coordinates and exactly
the differentiability upstream Particle supplies. No continuous second derivative
or full rocket-force model is assumed. The coasting trajectory's extension beyond
the event is a smooth reference continuation, not actual intact-rocket motion.

The linear coplanarity representation and its span/dimension/inverse-mass proof
are unchanged. The generic mechanics code is an upstream-oriented prototype;
namespace/time/interval API adaptation would require maintainer review. See the
P08 README and the adjacent ConstantAcceleration documentation for layering and
future uses.
