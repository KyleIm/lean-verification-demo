# P09 — pinned mechanics and source-solution audit

Audited the installed dependency sources selected by this repository, not GitHub
HEAD. No pins are changed:

- Physlib `96a6bc5e3c50a2856c64a6c9951c0a1c23790b58`;
- Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`;
- Lean `4.35.0`.

Paths below are relative to the respective library root. Declarations are actual
Lean definitions/theorems unless explicitly marked informal or documentation.

## Search evidence and inspected scope

```bash
rg -n -i 'friction|elastic|collision|restitution|normal.*(force|reaction)|contact.force|kineticEnergy|kinetic.energy|constant.acceler|decelerat' Physlib/ClassicalMechanics PhyslibAlpha/ClassicalMechanics
rg -n -i 'friction|restitution|collision|elastic|impact|sliding|normal.reaction' Physlib PhyslibAlpha
rg -n -i 'dissipat|drag|reflect|restitut|elastic|kineticEnergy|kinetic.energy|contact|coulomb' Physlib/ClassicalMechanics PhyslibAlpha/ClassicalMechanics
rg -n -i 'collision|restitut|elastic|friction|wall.*reflect|reflect.*wall' Physlib PhyslibAlpha
rg -n 'sq_eq_sq_iff_abs_eq_abs' Mathlib/Algebra/Order/Ring
```

Read the full stable `PointParticle/Basic.lean`, the NewtonianSystem structure,
particle and aggregate definitions, `FreeParticle/Basic.lean`, and relevant
`Force.lean`, `RigidBody/Motion.lean`, `RigidBody/KineticEnergy.lean`,
`RigidBody/Basic.lean`, and `Pendulum/SlidingPendulum.lean` declarations.
Inspected the local ConstantAcceleration, StaticFriction, PlanarStatics and
ImpulseMomentum modules, plus ConstantAccelerationExamples used in verification.

The whole-tree friction/elastic/collision searches did not find a formal sliding
friction or fixed-wall elastic/restitution API at this pin. "SlidingPendulum"
contains a support-position/angle configuration space, not a friction law.
Alpha NortonDome is explicitly frictionless and supplies specialized energy and
arc-length mechanics, not a board collision or kinetic-friction law. Reflection
or Coulomb terminology elsewhere must not be mistaken for a mechanical wall
impact or a Coulomb contact law. No Alpha module is imported.

## Stable formal support

All namespaces in this table are actual Lean namespaces; the package name
Physlib is not silently added to declaration names.

| File / declaration | Exact type or defining fields (surrounding variables understood) | P09 use |
| --- | --- | --- |
| `SpaceAndTime/ReferenceFrame.lean:145`, `ClassicalMechanics.ReferenceFrame.Vector` | `(frame : ReferenceFrame d) : Type`, field `components : Fin d → ℝ` | Reused for abstract one-dimensional path coordinates |
| `ClassicalMechanics/PointParticle/Basic.lean:47`, `ClassicalMechanics.ReferenceFrame.Particle` | `(frame : ReferenceFrame d) : Type`; `mass : {m : ℝ // 0 < m}`, `pos : ℝ → frame.Vector`, `pos_twice_differentiable : frame.IsInertial → Differentiable ℝ pos ∧ Differentiable ℝ (deriv pos)` | Reused directly twice, one reference trajectory per sliding leg |
| Same file:64, `ReferenceFrame.Particle.velocity` | `(particle : frame.Particle) [Fact (Differentiable ℝ particle.pos)] : ℝ → frame.Vector`, defined by `deriv particle.pos` | Actual derivative velocity, projected to scalar path velocity |
| Same file:72, `ReferenceFrame.Particle.acceleration` | `(particle : frame.Particle) [Fact (Differentiable ℝ particle.pos)] [Fact (Differentiable ℝ particle.velocity)] : ℝ → frame.Vector`, defined by `deriv particle.velocity` | Actual derivative acceleration in the local Newton-II premises |
| `ClassicalMechanics/Force.lean:45`, `ReferenceFrame.Force` | `(frame : ReferenceFrame d) (Object : Type) : Type`, fields `value : ℝ → frame.Vector`, `target : Object` | Formal time-dependent force carrier; full contact-force system unnecessary here |
| `ClassicalMechanics/PointParticle/NewtonianSystem/Basic.lean:64`, `PointParticle.NewtonianSystem.newton_second_law` | For system s: `∀ p : s.particles, ReferenceFrame.netForce p s.internalForces s.externalForces = p.1.mass • p.1.acceleration` | Genuine system-law field; P09 uses its scalar Newton-II specialization locally without constructing a multiset system |
| Same file:103, `NewtonianSystem.Particle.momentum` | `{system : NewtonianSystem d} (particle : system.Particle) (t : ℝ) : system.Vector`, `particle.mass • particle.velocity t` | Formal but momentum conservation is not the needed wall-impact principle |
| Same file:106, `NewtonianSystem.Particle.kineticEnergy` | `{system : NewtonianSystem d} (particle : system.Particle) (t : ℝ) : ℝ`, `particle.mass * ‖particle.velocity t‖ ^ 2 / 2` | Correct energy observable; no elastic collision theorem follows from the definition alone |
| Same file:202, `NewtonianSystem.kineticEnergy` | `(system : NewtonianSystem d) (t : ℝ) : ℝ`, sum of particle kinetic energies | Formal finite-system energy, not a collision rule |
| `ClassicalMechanics/FreeParticle/Basic.lean:120`, `ClassicalMechanics.FreeParticle.kineticEnergy` | `(s : FreeParticle) (q : Time → ℝ) (t : Time) : ℝ`, `(1/2) * s.mass * (s.velocity q t)^2` | Formal scalar energy, but its free-particle motion excludes friction |
| Same file:130, `FreeParticle.NewtonsSecondLaw` | `(s : FreeParticle) (q : Time → ℝ) (t : Time) : Prop`, `s.mass * Time.deriv (s.velocity q) t = 0` | Zero-force law, unsuitable for nonzero sliding deceleration |
| Same file:198, `FreeParticle.kineticEnergy_conserved` | `(s : FreeParticle) (q : Time → ℝ) (h : ∀ t, s.NewtonsSecondLaw q t) (hcont : ContDiff ℝ 2 q) : ∃ E, ∀ t, s.kineticEnergy q t = E` | Formal conservation theorem, but zero-force smooth motion is not a fixed-board impact |
| `ClassicalMechanics/RigidBody/KineticEnergy.lean:84`, `RigidBodyMotion.kineticEnergy` | `{d : ℕ} (M : RigidBodyMotion d) (t : Time) : ℝ` | Actual rigid-body energy; rotational/translational decomposition theorems in this file do not prove wall elasticity |

`RigidBody/Basic.lean:217` (`translational_equation_inertial`), line 231
(`kinetic_energy_decomposition`) and line 329 (`rigid_body_work_and_power`) use
`informal_lemma`. They are `InformalLemma` records, not proofs of the advertised
equations. In contrast the separate `RigidBody/KineticEnergy.lean` contains real
energy theorems; neither should be conflated with a collision conservation law.

No general constant nonzero acceleration API was found in the stable search.
FreeParticle's zero-acceleration/constant-velocity theorem is related but not the
required two-leg kinematics. The existing local module already fills this gap.

## Existing PhyslibTemp inspected

Paths are below `LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/` and names
are in `LeanVerificationDemo.PhyslibTemp.ClassicalMechanics`.

| File / declaration | Type / meaning | Decision |
| --- | --- | --- |
| `ConstantAcceleration.lean`, `HasConstantAcceleration` | `{d} {frame : ReferenceFrame d} [Fact frame.IsInertial] (particle : frame.Particle) (a : frame.Vector) : Prop := ∀ t, particle.acceleration t = a` | Reused, after deriving the acceleration from each segment's scalar force equation |
| `HasConstantAcceleration.velocity_eq` | For h as above, `(t₀ t : ℝ) : particle.velocity t = particle.velocity t₀ + (t-t₀) • a` | Reused independently before/after impact |
| `HasConstantAcceleration.position_eq` | `(t₀ t : ℝ) : particle.pos t = particle.pos t₀ + (t-t₀) • particle.velocity t₀ + ((t-t₀)^2/2) • a` | Reused to derive the squared-speed/distance relation by eliminating time |
| `ConstantAccelerationExamples.lean`, `Examples.quadraticParticle` | Positive mass and frame vectors q,v,a give an actual upstream particle with position `q + t • v + (t²/2) • a` | Verification witness only |
| `StaticFriction.lean`, `StaticFriction` | `(μ N Ft : ℝ) : Prop := 0 ≤ μ ∧ 0 ≤ N ∧ |Ft| ≤ μ*N` | Sticking/admissibility bound, not a kinetic-friction motion law |
| Same file, `LimitingStaticFriction` | `(μ N Ft : ℝ) : Prop := 0 ≤ μ ∧ 0 ≤ N ∧ |Ft| = μ*N` | Audited; the source borrows this magnitude convention while sliding. Keep the sliding interpretation local rather than importing static-equilibrium semantics |
| `PlanarStatics.lean`, `PlanarStaticEquilibrium` | For finite applied forces/positions: inertial orthonormal frame, zero net force and moment | A sliding decelerating puck is not in static equilibrium |
| `ImpulseMomentum.lean`, `MomentumBalance` and `total_change_eq_integral` | Particlewise momentum-form Newton II/III imply total change equals external-force impulse | Does not establish elasticity, which requires an independent energy/reflection condition; unnecessary for this simple speed/path problem |
| Same file, constant/continuous impulse and event-limit theorems | Short-time force integrals and matching momentum limits | Not required; no finite-time impact process is solved in P09 |

## Source-solution audit and minimal split

**From stable Physlib:** inertial frame, positive-mass Particle and derivative
position/velocity/acceleration.

**From existing PhyslibTemp:** ConstantAcceleration velocity/position laws;
quadratic particles only in verification.

**New PhyslibTemp:** none. A new SlidingFriction, ElasticCollision or ContactMechanics
module would be unnecessary. The narrow source-specific constitutive and impact
relations fit locally; algebraic time elimination is mathematics, not new physics
infrastructure.

**P09-local model inputs:** horizontal support `N = mg`, uniform sliding
`F = μN`, equal mass and the two scalar Newton-II equations, source speed/path
matching, a nonnegative incoming segment velocity, fixed-board elastic equality
of squared speeds, and final rest. μ is nonnegative, while masses, g, durations
and path lengths are positive. Numerical g = 9.8 is an explicit specialization,
not quoted problem data. The reference paths are not one globally accelerated
trajectory through the direction-changing impact.

**Derived physics/kinematics:** `a = F/m = μg`, identical nonnegative deceleration,
both constant-acceleration laws, nonnegative interval velocities, impact speed
magnitude matching, the individual squared-speed relations and the combined
stopping relation. Elasticity's equal-squared-speed premise is the local physical
interpretation of the source's words, not a derivation from an upstream collision
model. Support balance and the sliding law remain physical/model premises.

**Pure Mathlib reasoning:**
`Algebra/Order/Ring/Abs.lean:140`, `sq_eq_sq_iff_abs_eq_abs (x y : ℝ)` has type
`x^2 = y^2 ↔ |x| = |y|`; `abs_of_nonneg` relates magnitude to each nonnegative
path velocity. Algebra eliminates the two durations, cancels matched impact
speeds, adds 10 + 5/2, divides by positive mass/g/total path, and proves exact
rational and decimal bounds. `ring`, `field_simp`, `linarith`, `nlinarith` and
`norm_num` certify these manipulations. No floating-point arithmetic is used.

The textbook's `a = v₀²/(2s)` is **derived**, not supplied as a premise. Adding
the two path lengths in the stopping formula depends on the proved impact-speed
match and equal deceleration. The total distance is not a spatial displacement
through the reflection. No board-angle assumption is necessary.

## Final target and consistency

The checked judgment is `Candidate.solution data source : TrustedPhysicsProblem data`,
whose target is `μ = 5/49 ∧ |μ - 102/1000| < 1/2000`. The symbolic coefficient
theorem and tighter `0.1020408 < μ < 0.1020409` interval are also proved.

Verification constructs unit-mass quadratic segments with deceleration 1,
initial speeds 5 and √5, and durations 5−√5 and √5. It checks all force, path,
impact and stop premises directly. The coefficient is set from F/N, with no
final coefficient theorem or stopping relation supplied as source evidence.
The physical/model inputs are therefore satisfiable, including the numeric data.

## Additive unit/dimension audit

The same pinned sources were re-inspected for the requested unit layer. The
suggested `Physlib/Foundations/SI.lean` and `SIDeriv.lean` paths do not exist at
this pin; the actual framework is under `Physlib/Units/`.

```bash
rg --files Physlib/Units
rg -n 'structure |class |instance |def |abbrev |lemma ' Physlib/Units/Dimension.lean Physlib/Units/LTMCTDimensionBase.lean Physlib/Units/Basic.lean Physlib/Units/WithDim/Basic.lean
rg -n 'Mass|Velocity|Acceleration|Force|Energy|Momentum|DimSpeed|joule|oneMeterPerSecond' Physlib/Units
rg -n 'scaleUnit|toDimensionful|dimScale|cast|HDiv|HMul|pow_two' Physlib/Units
```

Also read `SIUnitChoices.lean`, `ISQDimensionBase.lean`, `UnitSystem.lean`,
`UnitDependent.lean`, `WithDim/Mass.lean`, `Velocity.lean`, `Speed.lean`,
`Energy.lean`, `Momentum.lean`, and P02's existing MolarIdealGas aliases.

### Exact upstream declarations used

Generic dimension-basis/typeclass parameters are given explicitly where needed;
SI-choice-specific declarations below use the LTMCT basis.

| File / declaration | Lean type / definition | Use |
| --- | --- | --- |
| `Units/Dimension.lean:67`, `Dimension` | `(B : Type) [DimensionBasis B] : Type` | Existing dimension carrier; not redefined in P09 |
| Same file:111, `Dimension.instCommGroup` | `[DimensionBasis B] : CommGroup (Dimension B)` | Dimension multiplication/division/inversion and powers; dimensionless identity is 1 |
| Same file:88, `Dimension.ext` | `{d1 d2 : Dimension B} (h : ∀ b, d1.exponent b = d2.exponent b) : d1 = d2` | Certifies equal base exponents |
| Same file:100/136/141, `mul_exponent`, `div_exponent`, `npow_exponent` | `(d1*d2).exponent b = d1.exponent b + d2.exponent b`; `(d1/d2).exponent b = d1.exponent b - d2.exponent b`; `(d^n).exponent b = n • d.exponent b` | Executable force, stopping, coefficient and negative dimension checks |
| `Units/LTMCTDimensionBase.lean:273/291/309`, `Dimension.L𝓭`, `T𝓭`, `M𝓭` | Each has type `Dimension LTMCTDimensionBase`; unit length/time/mass exponent generators | Mechanical SI dimensions in the existing five-base system |
| `Units/WithDim/Basic.lean:33`, `WithDim` | `{B : Type} [DimensionBasis B] (d : Dimension B) (M : Type) : Type`; field `val : M` | All local quantities are aliases of this type |
| Same file:47/51, HasDim instance / `WithDim.dim_apply` | `dim (WithDim d M) = d` for `d : Dimension LTMCTDimensionBase` | Explicit coefficient dimension-one fact |
| Same file:40, `WithDim.ext` | `(x y : WithDim d M) (h : x.val = y.val) : x = y` | Lift fixed-SI scalar equalities from Candidate |
| Same file:247, `WithDim.instHMulRealHMulDimension` | `{B} [DimensionBasis B] {d1 d2 : Dimension B} : HMul (WithDim d1 ℝ) (WithDim d2 ℝ) (WithDim (d1*d2) ℝ)` | Actual dimension-changing quantity multiplication |
| Same file:317, `WithDim.instHDivRealHMulDimensionInv` | `{B} [DimensionBasis B] (d1 d2 : Dimension B) : HDiv (WithDim d1 ℝ) (WithDim d2 ℝ) (WithDim (d1*d2⁻¹) ℝ)` | Actual dimension-changing quotient in v²/(2gs) |
| Same file:232/243, `WithDim.instModuleReal`, `real_smul_val` | With real module M: `Module ℝ (WithDim d M)` and `(r • x).val = r • x.val` | 2 and 1/2 are dimensionless real factors |
| Same file:251/322, `withDim_hMul_val`, `val_div_val` | `(x*y).val = x.val*y.val`; `x.val/y.val = (x/y).val` | Exact numerical evaluation of typed arithmetic |
| Same file:278, `val_pow_two_eq_mul` | `(x : WithDim d ℝ) : x.val^2 = (x*x).val` | Audited convention for quantity squaring; P09 uses x*x with its computed dimension |
| Same file:356, `WithDim.cast` | `{B} [DimensionBasis B] {d d2 : Dimension B} {M} (x : WithDim d M) (h : d = d2) : WithDim d2 M` | Dimension normalization only after an equality proof |
| Same file:341, `scaleUnit_dim_eq_zero` | `{d : Dimension LTMCTDimensionBase} (x : WithDim d ℝ) (u1 u2 : LTMCTUnitChoices) (h : d = 1) : UnitDependent.scaleUnit u1 u2 x = x` | Dimensionless coefficient is invariant under unit rescaling |
| `Units/Basic.lean:254`, `LTMCTUnitChoices.SI` | `LTMCTUnitChoices` | Coherent metre/second/kilogram/coulomb/kelvin choice |
| Same file:382, `Dimensionful` | `(M : Type) [CarriesDimension M] : Type := Subtype (HasDimension (M := M))` | Unit-dependent quantities, rather than unlabelled numerical values |
| Same file:435, `CarriesDimension.toDimensionful` | `{M} [CarriesDimension M] (u : LTMCTUnitChoices) : M ≃ Dimensionful M` | Initialize source quantities at SI; the equivalence inverse evaluates at that choice |
| `Units/UnitDependent.lean:40`, `UnitDependent.scaleUnit` | `{M} [UnitDependent M] : LTMCTUnitChoices → LTMCTUnitChoices → M → M` | Unit rescaling; coefficient invariance uses the upstream theorem |
| `SpaceAndTime/Space/LengthUnit.lean:86`, `LengthUnit.meters` | `LengthUnit` | SI length choice |
| `SpaceAndTime/Time/TimeUnit.lean:66`, `TimeUnit.seconds` | `TimeUnit` | SI time choice |
| `ClassicalMechanics/Mass/MassUnit.lean:68`, `MassUnit.kilograms` | `MassUnit` | SI mass choice |
| `Units/WithDim/Speed.lean:24`, `DimSpeed` | `Dimensionful (WithDim (L𝓭*T𝓭⁻¹) ℝ≥0)` | Existing named speed API, checked against 5 m/s |
| Same file:38, `DimSpeed.oneMeterPerSecond` | `DimSpeed` | Named m/s unit consistency check |
| `Units/WithDim/Energy.lean:24`, `DimEnergy` | `Dimensionful (WithDim (M𝓭*L𝓭*L𝓭*T𝓭⁻¹*T𝓭⁻¹) ℝ)` | Actual energy quantity API, with squared length despite the header's abbreviated wording |
| Same file:30, `DimEnergy.joule` | `DimEnergy` | Formal J = N·m check in SI |

The generated heterogeneous-instance names were confirmed with `#synth`; the
other main signatures were checked in the pinned Lean environment. The
`toDimensionful` equivalence's Mathlib `symm_apply_apply` law proves
`coordinate_at_SI`, not a new conversion axiom.

### Named APIs, basis choice and limits

`Units/WithDim/Mass.lean` and `Velocity.lean` contain documentation but no named
quantity declarations at this pin. No separate named acceleration/force wrapper
module exists there. This is not a missing dimensional framework: existing
WithDim naturally represents all of them. P09 adds local **type aliases**, not
new structures or a parallel framework. Its `metre`, `second`, `kilogram`,
`newton` and source values are local quantities constructed using upstream SI,
not claims of upstream declarations with those names.

P02 uses ISQ for independent amount of substance. P09 needs only L/T/M, so the
LTMCT basis and its SI choice avoid unnecessary basis conversion and give direct
access to the mature HasDim/Dimensionful/scaleUnit interfaces. The separate
seven-base `SIUnitChoices.SI` was inspected; no claim is made that the five-base
LTMCT basis is the full seven-base SI/ISQ set.

Quantity multiplication and division support the required operations. A quantity
square is x*x; the dimension itself also supports powers. Products whose indices
are mathematically but not definitionally equal are normalized using upstream
`WithDim.cast` with proved dimension equality. No unchecked retagging substitutes
for a dimensional check.

### Additive checks and semantics

`P09/Units.lean` proves:

- `friction_dimensions_iff`: d·Force = Force iff d = 1;
- `newton_dimensions`: Mass·Acceleration = Force;
- `stopping_dimensions` / `speed_squared_dimensions`: Velocity² = Acceleration·Length;
- `coefficient_dimensions`: Velocity²/(Acceleration·Length) = 1;
- typed friction, Newton-magnitude, acceleration, stopping and coefficient equations;
- typed source values 5 m/s, 10 m, 5/2 m and 49/5 m/s², total 25/2 m, and
  `source_coefficient_in_SI` with exact dimensionless value 5/49;
- `energy_dimensions` and `joule_is_newton_metre`, independent dimensional/SI checks;
- coefficient unit invariance and the negative result v/(gs) has dimension T/L ≠ 1.

The necessity of dimensionless μ is a dimension-homogeneity theorem, not an
inference from arbitrary numerical force equalities. Physical law F = μN still
comes from SlidingModel. The scalar mechanics Candidate remains the source of
physical coefficient/stopping results; WithDim.ext lifts them into already
correctly indexed quantities. Type consistency cannot establish the friction
law, elasticity or the stopping mechanics by itself.

The unit layer certifies the formulas and fixed-SI bridge. It does not make the
whole ReferenceFrame.Particle trajectory calculus dimension-indexed or prove
full unit covariance of PuckData. `typed_newton` is the algebraic identity for
F/m; its interpretation as actual deceleration is established in the existing
Candidate. No physical premise or trusted proposition changed. No new PhyslibTemp
code, unit framework, collision/friction abstraction or mutation case is added.
