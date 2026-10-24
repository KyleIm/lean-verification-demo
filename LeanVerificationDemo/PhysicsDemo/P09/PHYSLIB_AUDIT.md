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
