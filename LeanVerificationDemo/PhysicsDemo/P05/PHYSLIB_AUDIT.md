# P05 pinned Physlib mechanics audit

## Revision and source search

Physlib `96a6bc5e3c50a2856c64a6c9951c0a1c23790b58`, Mathlib/Lean 4.35.0,
exactly as pinned in this repository. No dependency pin was changed.

Broad searches were run over all stable `Physlib/` and separately identified
`PhyslibAlpha/`, in addition to reading the force, rigid-body, point-particle and
reference-frame modules in full relevant context:

```bash
rg -n -i 'friction|coulomb.friction|static.equilibrium|force.balance|torque|moment.of.force|moment.arm|support.reaction|normal.reaction|contact.force|statics' Physlib PhyslibAlpha
rg -n -i 'static.?equilibrium|force.?balance|moment.?arm|coulomb.?friction|limiting.?friction|friction|support.?reaction|normal.?reaction|contact.?force|planar.?statics' Physlib PhyslibAlpha
rg -l -i '\btorque\b|moment.of.force' Physlib PhyslibAlpha
rg -n -i 'friction|support.reaction|normal.reaction|static.equilibrium|static.friction|limiting.friction|moment.of.force' Physlib PhyslibAlpha
```

The expanded friction/contact search returned only continuum stress/contact-force
discussion in `Physlib/FluidDynamics/CauchyFlow/Basic.lean:19,56` and the explicitly
frictionless Norton dome description in Alpha. No Coulomb static-friction bound,
limiting-friction or support-reaction API was found. Torque hits in stable were
rigid-body informal entries and simple-pendulum modules; these were inspected,
not dismissed based on a missing exact identifier.

Read/inspected:

- `Physlib/ClassicalMechanics/Force.lean`;
- `Physlib/SpaceAndTime/ReferenceFrame.lean`, `Space/Basic.lean`, `Time/Basic.lean`;
- `Physlib/ClassicalMechanics/RigidBody/{Basic,Motion,AngularVelocity,AngularMomentum}.lean`;
- `Physlib/ClassicalMechanics/PointParticle/Basic.lean` and `PointParticle/NewtonianSystem/Basic.lean`;
- `Physlib/ClassicalMechanics/Pendulum/SimplePendulum/Basic.lean` and related torque/equilibria hits;
- `Physlib/Meta/Informal/Basic.lean` to distinguish metadata from actual proof terms;
- secondary `PhyslibAlpha/ClassicalMechanics/NortonDome/Basic.lean`.

## Actual formal stable declarations

| File and line | Full declaration | Exact type / role | Used? |
| --- | --- | --- | --- |
| `Physlib/SpaceAndTime/ReferenceFrame.lean:48` | `ClassicalMechanics.ReferenceFrame` | `(d : ℕ) → Type`; time origin, origin trajectory and basis | Yes, fixed Cartesian lab frame |
| same file:114 | `ClassicalMechanics.ReferenceFrame.IsInertial` | `{d : ℕ} → ReferenceFrame d → Prop`; uniform origin and fixed basis | Yes |
| same file:103 | `ClassicalMechanics.ReferenceFrame.Orthonormal` | `{d : ℕ} → ReferenceFrame d → Prop` | Yes |
| same file:145 | `ClassicalMechanics.ReferenceFrame.Vector` | `{d : ℕ} → ReferenceFrame d → Type`; field `components : Fin d → ℝ` | Yes, position displacements and force values |
| `Physlib/ClassicalMechanics/Force.lean:45` | `ClassicalMechanics.ReferenceFrame.Force` | `{d : ℕ} → (frame : ReferenceFrame d) → (Object : Type) → Type`; `value : ℝ → frame.Vector`, `target : Object` | Yes, four constant applied forces targeting Unit |
| same file:74 | `ClassicalMechanics.ReferenceFrame.netForce` | For fixed frame/Object: `(object : Object) → Multiset (frame.InternalForce Object) → Multiset (frame.Force Object) → ℝ → frame.Vector` | Available; P05 sums four single-target Force components directly |
| `Physlib/ClassicalMechanics/RigidBody/Basic.lean:44,51,63` | `RigidBody`, `RigidBody.mass`, `RigidBody.inertiaTensor` | `(d : ℕ) → Type`; `{d : ℕ} → RigidBody d → ℝ`; `{d : ℕ} → RigidBody d → Matrix (Fin d) (Fin d) ℝ` | Formal but not a contact/statics law |
| `Physlib/ClassicalMechanics/RigidBody/AngularMomentum.lean:34,44` | `RigidBody.angularMomentum`, `angularMomentum_eq_inertiaTensor_mulVec` | `(R : RigidBody 3) → (Fin 3 → ℝ) → (Fin 3 → ℝ)`; `R.angularMomentum ω = R.inertiaTensor *ᵥ ω` | Formal rotational inertia/momentum, not torque balance of applied contact forces |
| `Physlib/ClassicalMechanics/PointParticle/NewtonianSystem/Basic.lean:53` | `ClassicalMechanics.PointParticle.NewtonianSystem` | `(d : ℕ) → Type`, with formal Newton-second/third-law fields | Real mechanics, but point-particle dynamics rather than this rigid contact system |
| `Physlib/ClassicalMechanics/Pendulum/SimplePendulum/Basic.lean:582,593` | `ClassicalMechanics.SimplePendulum.torque`, `torque_apply` | `(S : SimplePendulum) → EuclideanSpace ℝ (Fin 1) → EuclideanSpace ℝ (Fin 1)`; `S.torque x 0 = -(S.m * S.g * S.ℓ * Real.sin (x 0))` | Formal pendulum-specific generalized torque, not a reusable arbitrary-force moment/contact solver |

The frame-vector implementation intentionally does not encode physical dimensions
(see ReferenceFrame.lean's vector documentation). P05 uses coherent SI coordinates
with roles explicitly documented rather than inventing a replacement Force type.

## Informal entries are not formal mechanics theorems

At `Physlib/ClassicalMechanics/RigidBody/Basic.lean`:

- line 217: `RigidBody.translational_equation_inertial`;
- line 224: `RigidBody.rotational_equation_inertial`;
- line 303: `RigidBody.euler_equations`;
- line 322: `RigidBody.reduction_to_two_body`.

Each is declared with `informal_lemma`, not `lemma`/`theorem` of its advertised
physics proposition. `Physlib/Meta/Informal/Basic.lean:66–67` expands that syntax to
`def name : InformalLemma ...`: a record of informal metadata. They cannot be
used as evidence of zero external torque or a rigid-body equation of motion.
The distinction was checked by Lean:

```text
RigidBody.translational_equation_inertial : InformalLemma
RigidBody.rotational_equation_inertial : InformalLemma
RigidBody.euler_equations : InformalLemma
RigidBody.reduction_to_two_body : InformalLemma
RigidBody.angularMomentum_eq_inertiaTensor_mulVec (R : RigidBody 3) (ω : Fin 3 → ℝ) :
  R.angularMomentum ω = R.inertiaTensor.mulVec ω
```

## Alpha and documentation-only material

`PhyslibAlpha/ClassicalMechanics/NortonDome/Basic.lean:19` describes sliding
**without friction**; its `ClassicalMechanics.NortonDome` parameters at line 122
are a different model. It offers no static Coulomb contact layer. It was not
imported. The overview `Physlib/ClassicalMechanics/Basic.lean` explicitly states
it introduces no declarations. Continuum stress/contact documentation is not a
lumped friction/support-reaction law. These were not reported as usable APIs.

## Geometry/math inspection

Mathlib already supplies `crossProduct` and `cross_apply` in
`Mathlib/LinearAlgebra/CrossProduct.lean:47,63`, orthonormal Cartesian bases via
`EuclideanSpace.basisFun`, and sin/cos sign lemmas for acute angles. P05 uses them.
The reusable moment embeds planar displacement/force coordinates into ℝ³ and
takes the out-of-plane component of the existing cross product. It is not a new
implementation of cross-product algebra.

The small source-specific coordinate parametrization uses
`B=(-L cos α,L sin α)` and `A=(-s cos α,s sin α)`. This supplies the projection
geometry without a separate Euclidean-angle/segment framework. P05 derives the
source moment equation after substituting these coordinates into the general
moment model. We do not claim to prove this source geometry from a bitmap figure.

## Minimum extension: implemented split

- **Stable reuse:** actual `ReferenceFrame`, `Vector`, `Force`, force values,
  inertial/orthonormal predicates. No new force object or rigid-body type.
- **New PhyslibTemp:** `planarMoment` / its component formula and
  `PlanarStaticEquilibrium` for any finite collection of single-target forces;
  `StaticFriction` / `LimitingStaticFriction` for arbitrary signed tangential
  force, nonnegative coefficient and normal reaction. No ladder labels/geometry.
- **P05 model:** chosen lab frame, constant force directions and application
  points, weightless ladder, smooth wall, rough horizontal floor, acute fixed
  geometry, G > 0, μ ≥ 0, position restricted to [0,L].
- **Derived:** the scalar force/moment equations, required reactions, strict
  increase of required friction, exact threshold, explicit admissible reactions,
  saturation and nonexistence above threshold.
- **Pure math:** finite sums, cross-product expansion, trigonometric positivity,
  positive cancellation, order equivalences and field/ring normalization.

Why temporary: the upstream typed force layer exists, but the audited revision
has no corresponding finite planar static-balance/contact-friction layer. The
additions encode reusable physics without pretending the informal rigid-body
entries are proved. Zero force/moment is an adopted equilibrium principle,
not derived from upstream full Newton-Euler contact dynamics. Friction is an
inequality; equality belongs only to the separate limiting relation.

## Checked upstream signatures

Obtained by `lake env lean` importing the pinned source modules and `#check`:

```text
ClassicalMechanics.ReferenceFrame.Force {d : ℕ} (frame : ClassicalMechanics.ReferenceFrame d) (Object : Type) : Type
ClassicalMechanics.ReferenceFrame.Force.value {d : ℕ} {frame : ClassicalMechanics.ReferenceFrame d} {Object : Type}
  (self : frame.Force Object) : ℝ → frame.Vector
ClassicalMechanics.ReferenceFrame.netForce {d : ℕ} {frame : ClassicalMechanics.ReferenceFrame d} {Object : Type}
  (object : Object) (internalForces : Multiset (frame.InternalForce Object))
  (externalForces : Multiset (frame.Force Object)) (t : ℝ) : frame.Vector
ClassicalMechanics.ReferenceFrame.Vector {d : ℕ} (frame : ClassicalMechanics.ReferenceFrame d) : Type
RigidBody (d : ℕ) : Type
RigidBody.mass {d : ℕ} (R : RigidBody d) : ℝ
RigidBody.inertiaTensor {d : ℕ} (R : RigidBody d) : Matrix (Fin d) (Fin d) ℝ
RigidBody.angularMomentum (R : RigidBody 3) (ω : Fin 3 → ℝ) : Fin 3 → ℝ
ClassicalMechanics.PointParticle.NewtonianSystem (d : ℕ) : Type
ClassicalMechanics.SimplePendulum.torque (S : ClassicalMechanics.SimplePendulum) (x : EuclideanSpace ℝ (Fin 1)) :
  EuclideanSpace ℝ (Fin 1)
ClassicalMechanics.SimplePendulum.torque_apply (S : ClassicalMechanics.SimplePendulum) (x : EuclideanSpace ℝ (Fin 1)) :
  (S.torque x).ofLp 0 = -(S.m * S.g * S.ℓ * Real.sin (x.ofLp 0))
EuclideanSpace.basisFun.{u_1, u_3} (ι : Type u_1) (𝕜 : Type u_3) [RCLike 𝕜] [Fintype ι] :
  OrthonormalBasis ι 𝕜 (EuclideanSpace 𝕜 ι)
OrthonormalBasis.orthonormal.{u_1, u_3, u_4} {ι : Type u_1} {𝕜 : Type u_3} [RCLike 𝕜] {E : Type u_4}
  [NormedAddCommGroup E] [InnerProductSpace 𝕜 E] [Fintype ι] (b : OrthonormalBasis ι 𝕜 E) : Orthonormal 𝕜 ⇑b
Real.cos_pos_of_mem_Ioo {x : ℝ} (hx : x ∈ Set.Ioo (-(Real.pi / 2)) (Real.pi / 2)) : 0 < Real.cos x
Real.sin_pos_of_pos_of_lt_pi {x : ℝ} (h0x : 0 < x) (hxp : x < Real.pi) : 0 < Real.sin x
cross_apply.{u_1} {R : Type u_1} [CommRing R] (a b : Fin 3 → R) :
  (crossProduct a) b = ![a 1 * b 2 - a 2 * b 1, a 2 * b 0 - a 0 * b 2, a 0 * b 1 - a 1 * b 0]
strictMono_mul_left_of_pos.{u_2} {M₀ : Type u_2} [MonoidWithZero M₀] [PartialOrder M₀] {a : M₀} [PosMulStrictMono M₀]
  (ha : 0 < a) : StrictMono fun x => a * x
div_le_iff₀.{u_3} {G₀ : Type u_3} [GroupWithZero G₀] [PartialOrder G₀] [MulPosReflectLT G₀] {a b c : G₀} (hc : 0 < c) :
  b / c ≤ a ↔ b ≤ a * c
le_div_iff₀.{u_3} {G₀ : Type u_3} [GroupWithZero G₀] [PartialOrder G₀] [MulPosReflectLT G₀] {a b c : G₀} (hc : 0 < c) :
  a ≤ b / c ↔ a * c ≤ b
mul_le_mul_iff_right₀.{u_1} {α : Type u_1} [Mul α] [Zero α] [Preorder α] {a b c : α} [PosMulMono α] [PosMulReflectLE α]
  (a0 : 0 < a) : a * b ≤ a * c ↔ b ≤ c
```

Pinned source links:
[Force](https://github.com/leanprover-community/physlib/blob/96a6bc5e3c50a2856c64a6c9951c0a1c23790b58/Physlib/ClassicalMechanics/Force.lean#L45),
[rigid-body informal equations](https://github.com/leanprover-community/physlib/blob/96a6bc5e3c50a2856c64a6c9951c0a1c23790b58/Physlib/ClassicalMechanics/RigidBody/Basic.lean#L217),
[formal pendulum torque](https://github.com/leanprover-community/physlib/blob/96a6bc5e3c50a2856c64a6c9951c0a1c23790b58/Physlib/ClassicalMechanics/Pendulum/SimplePendulum/Basic.lean#L582).
