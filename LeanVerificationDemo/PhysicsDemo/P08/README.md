# P08 — Three fragment velocities lie in one linear plane

Source problem **77**. [Source record](source.jsonl) ·
[Pinned-library audit](PHYSLIB_AUDIT.md) · [Classification](CLASSIFICATION.md) ·
[Reusable kinematics](../../PhyslibTemp/ClassicalMechanics/ConstantAcceleration.md) ·
[Impulse–momentum API](../../PhyslibTemp/ClassicalMechanics/ImpulseMomentum.md).

## Source question vs formalized question

### BEFORE — original source problem

> 77. A rocket launched vertically upward explodes at the highest point it reaches. The explosion produces three fragments. Prove that the vectors of the initial velocities of all three fragments are in one plane.

The supplied solution states that apex velocity is zero and adopts momentum
conservation during a very short explosion by neglecting gravitational impulse.
It then asserts that three zero-sum momenta, and hence the velocities, are coplanar.

### AFTER — Lean-facing formalized problem

Use an upstream Physlib particle as an ideal vertical coasting reference
trajectory. Assume constant downward acceleration `(-g) • up` with g > 0 and
initial velocity `u • up` with u > 0. Derive its velocity and height laws, prove
that `t_apex = u/g` is a highest point, and derive its velocity there is zero.
For each positive event duration ε, model constituent momentum histories obeying
Newton II in momentum form, pairwise Newton III and constant external gravity.
Initially the constituents share the rocket's apex velocity; their masses sum
to its mass. Define the immediate post-event momenta as the limits of the
finite-duration endpoint momenta as ε → 0⁺. Derive vanishing external impulse,
across-event momentum equality and zero total fragment momentum. Prove that all
three immediate post-event velocities lie in one real linear subspace through
zero of dimension at most two.

The final source-facing target is unchanged:

```lean
∃ plane : Submodule ℝ Vector3,
  Module.finrank ℝ plane ≤ 2 ∧ ∀ i, data.velocity i ∈ plane
```

`Vector3 = EuclideanSpace ℝ (Fin 3)`. Its subspaces are finite-dimensional, so
finrank has the ordinary dimension meaning. The checked judgment remains
`Candidate.solution data source : TrustedPhysicsProblem data`.

### What changed

The previous implementation supplied `apex_at_rest` directly. That premise and
the independent `apexVelocity` data field have been removed. A reusable
constant-acceleration layer now derives the kinematics, and the P08 specialization
proves highest height and zero apex velocity. P08's source inputs do **not**
include either the zero-velocity conclusion or the quadratic height formula.

This refinement adds an explicit ideal uniform-downward-acceleration coasting
model that the short source argument leaves implicit. It does not model powered
ascent, propulsion, fuel or rotation. The smooth reference trajectory is
mathematically extended through the apex; after the explosion it is a reference
continuation, **not** the actual path of any surviving intact rocket or fragment.
The library laws currently use all real frame-time coordinates. Their physical
interpretation here is the pre-explosion coasting stage and its smooth extension.

“Initial fragment velocities” means immediately after the explosion; the rocket
velocity is evaluated immediately before it. The old `momentum_conserved` field
is also removed. Across-event equality is now a consequence of finite-duration
Newton balance and an explicit zero-duration limit. No finite positive duration
is silently identified with the immediate post-event state, and no physical
explosion is claimed to take literally zero time.

Linear coplanarity, rather than affine coplanarity of three endpoints, is kept.
Zero/collinear velocities are valid: the containing subspace may have dimension
zero or one. No independence or nonzero-fragment-velocity assumption is added.

## The source solution is also part of the formalization audit

Formalizing this problem–solution pair required auditing the supplied explanation,
not only the question. The printed solution contains steps with different formal status:

| Source-solution step | Formal treatment |
| --- | --- |
| The rocket is at rest at its highest point | Omitted reasoning, now derived under the explicit vertical coasting model |
| Gravitational impulse is negligible during the short explosion | Textbook approximation language refined into an exact zero-duration impulse limit |
| Internal explosion forces do not change total momentum | Physical Newton-III assumption; cancellation and its total-momentum consequence are derived |

For the first step, the reusable mechanics and P08 specialization prove the
velocity/height laws, the maximum-height time and zero velocity there. This is
conditional on the chosen constant downward acceleration and initial upward
velocity, which are model assumptions rather than facts proved from the source
wording. The zero apex velocity is no longer a trusted equality field.

For fixed ε > 0, the external gravitational impulse is `ε • Fg`, generally
nonzero. Lean now proves `Jg(ε) → 0` as ε → 0⁺ and derives equality of the event
states by uniqueness of limits. The source's finite-time approximation has not
become an exact finite-time conservation claim.

The internal-force condition matters independently: vanishing external impulse
alone does not rule out an imposed momentum jump. Pairwise equal-and-opposite
internal forces cancel when the constituent Newton-II equations are summed.
Their individual magnitudes may diverge as ε shrinks; the verification witness
uses forces proportional to 1/ε. The event family, initial matching and endpoint
convergence are still explicit physical/model idealizations. The theorem does
not prove that every real explosion admits this regularization, or that its
external impulse is negligible at any particular nonzero duration.

This distinction motivates the repository's [problem–solution review standard](../../../README.md#auditing-source-problemsolution-pairs).
Audit both sides: separate problem data, omitted derivations, reusable physical
principles, model approximations, intermediate results and the source answer.
Then check the actual Candidate dependencies. The purpose is to reconstruct and
verify the reasoning with clear boundaries, not trust every printed assertion or
force the Lean proof to reproduce each sentence mechanically.

## Exact inputs and abstraction boundary

`ExplosionData` contains positive fragment masses, three fragment velocity
vectors, an upstream `labFrame.Particle`, positive `initialSpeed = u`, and positive
g, plus `eventMomentum ε i t` and `internalForce ε i j t`. Here t is elapsed
time from the apex, so absolute time is `t_apex + t`. Its upstream particle
includes a positive mass, a position function and inertial-frame
differentiability of position and velocity. The lab frame is a
fixed Cartesian frame; `up` is its third coordinate direction.

The exact `SourceData` fields are:

```lean
constant_acceleration : HasConstantAcceleration data.rocket ((-data.g) • up)
initial_velocity : data.rocket.velocity 0 = data.initialSpeed • up
mass_balance : ∑ i, data.mass i = data.rocket.mass.val
event_balance : ∀ ε > 0, MomentumBalance (data.eventMomentum ε) (data.internalForce ε)
  (fun i _ => data.mass i • gravityAcceleration data)
event_initial : ∀ ε > 0, ∀ i,
  data.eventMomentum ε i 0 = data.mass i • apexVelocity data
post_event_limit : ∀ i, Tendsto (fun ε => data.eventMomentum ε i ε)
  (𝓝[>] (0 : ℝ)) (𝓝 (momentum data i))
```

`MomentumBalance` expands into particlewise momentum derivatives equal to
external plus internal forces, and pairwise antisymmetry of internal forces.
The interface currently uses differentiable histories on all real elapsed times;
only [0, ε] is integrated. It contains no total-conservation equality. The
external-force specification excludes other external forces and singular
external impulses from the adopted model.

The first is the uniform-gravity/coasting kinematic model assumption, not a
proved force-to-acceleration theorem. In the event model the gravitational
force is explicitly specified as `mass i • gravityAcceleration`; no full
upstream NewtonianSystem value is constructed. The initial condition makes
the coasting motion vertical. Without
it, maximum height alone would leave possible horizontal velocity components.

Local definitions are:

```text
pᵢ = mᵢ • vᵢ
height(t) = third component of rocket.pos(t)
t_apex = u/g
apexVelocity = Cartesian components of rocket.velocity(t_apex)
Pbefore = rocket.mass • apexVelocity
Pafter = p₁+p₂+p₃.
```

The upstream particle's actual mass is used for pre-event momentum.
The new mass-balance premise identifies the sum of the initial constituent
momenta with that rocket momentum and the total gravitational force with
`rocket.mass • gravityAcceleration`. It is source-level system closure, not a
coplanarity or final-answer premise.
All quantities are coordinates in one fixed inertial frame and coherent unit
convention. Physical dimensions are not encoded by the vector carrier. The
upstream frame-vector components are explicitly converted to the Euclidean
coordinate space used by fragment velocities; zero is preserved by this map.

## Reviewer-facing derivation

```text
HasConstantAcceleration.velocity_eq / position_eq
  upstream derivative-based acceleration → generic velocity / position laws

vertical_velocity_evolution / height_evolution
  v(t) = (u - gt) up
  height(t) = height(0) + ut - gt²/2

apex_height_maximal / apex_isLocalMax
  height(u/g) - height(t) = (g/2)(t - u/g)² ≥ 0

height_hasDerivAt / apex_vertical_velocity_zero
  Mathlib Fermat theorem at the proved maximum → u - g t_apex = 0

apex_frame_velocity_zero / apex_velocity_zero / pre_momentum_zero
  vertical vector law → full velocity zero → pre-event momentum zero

internal_forces_cancel / finite_duration_momentum_balance
  pairwise Newton III + summed Newton II + FTC
  → Σᵢ pᵢ(ε, ε) - Pbefore = Jg(ε)

gravitational_impulse_eq / gravitational_impulse_tendsto_zero
  Jg(ε) = ε • Fg → Jg(ε) → 0 as ε → 0⁺

total_momentum_endpoint_limit / event_momentum_eq
  constituent endpoint limits + vanishing impulse
  → Pafter = Pbefore by uniqueness of limits

total_momentum_zero
  derived event equality + derived apex rest → p₁+p₂+p₃ = 0

first_momentum_eq_neg_sum / first_momentum_in_span
  p₁ = -(p₂+p₃) → p₁ ∈ span{p₂,p₃}

momenta_in_plane / momentum_plane_finrank / momenta_coplanar
  all momenta in that span; dimension ≤ 2

velocity_mem_of_momentum_mem / solution
  vᵢ = mᵢ⁻¹ • pᵢ stays in the same linear subspace.
```

The maximum-height argument actually participates in the final proof: Fermat's
`IsLocalMax.hasDerivAt_eq_zero` uses the proved local maximum and genuine height
derivative; `pre_momentum_zero` calls the derived apex-velocity lemma. This is
not a renamed rest premise or an unused ancillary calculation.

Gravity is not needed for the **mathematical fact** that a differentiable height
function has zero derivative at an interior local maximum. Here constant downward
acceleration supplies the concrete height law and identifies that maximum. This
is distinct from the source's short-event approximation, now sharpened into an
exact limit conditional on the force/event model. Exact mechanics means
deductions under those stated idealizations, not a proof of real rocket flight
or explosion microphysics.

`CandidateAnnotated.lean` distinguishes upstream/reusable mechanics, P08-specific
vertical/apex specialization, idealized event-limit mechanics and pure linear
algebra. No plane or zero post-event momentum is trusted input.

## Reusable constant-acceleration layer

The reusable mechanics is implemented in
[ConstantAcceleration.lean](../../PhyslibTemp/ClassicalMechanics/ConstantAcceleration.lean),
with design and upstream-integration notes in
[ConstantAcceleration.md](../../PhyslibTemp/ClassicalMechanics/ConstantAcceleration.md)
and independent consistency checks in
[ConstantAccelerationExamples.lean](../../PhyslibTemp/ClassicalMechanics/ConstantAccelerationExamples.lean).

The module uses upstream `ReferenceFrame.Particle` and defines
`HasConstantAcceleration particle a`. It proves generic velocity and quadratic
position evolution in arbitrary spatial dimension; it contains no rocket,
explosion, highest-point, vertical-direction or gravity-specific abstraction.
P08 consumes those laws to derive its vertical trajectory's highest point and
zero apex velocity, then applies the separate impulse/event-limit branch.

The accompanying `.md` file explains why this layer is reusable and how it might
fit upstream. It is **design documentation, not part of the P08 source
assumptions**. The executable kinematic premise is the explicit
`SourceData.constant_acceleration` field; the library evolution laws are proved
from it. Likewise, the quadratic particles in the examples are verification
witnesses, not prescribed source trajectories.

## Reusable impulse–momentum layer and event semantics

[ImpulseMomentum.lean](../../PhyslibTemp/ClassicalMechanics/ImpulseMomentum.lean)
provides finite indexed force balance, internal cancellation, total momentum

```text
d(Σ pᵢ)/dt = Σ Fext,ᵢ
ΔP = ∫ Σ Fext,ᵢ dt
```

and continuous-force shrinking-interval limits. The constant-gravity specialization
is exact: `Jg(ε) = ε • Fg`, with `Jg(ε) → 0` from positive durations.
[Design notes](../../PhyslibTemp/ClassicalMechanics/ImpulseMomentum.md) and
[independent examples](../../PhyslibTemp/ClassicalMechanics/ImpulseMomentumExamples.lean)
explain the reusable boundary and checks. Two upstream adapters additionally
prove the momentum derivative for an actual NewtonianSystem particle and internal
multiset cancellation from its actual Newton-III field. P08 uses the indexed
momentum interface directly; a complete adapter from the upstream multiset
system to that interface is not claimed.

The event state uses a **right-hand duration limit of a family**:

```text
pᵢ,ε(t)    0 ≤ t ≤ ε          finite-duration interaction
pᵢ,after = lim ε → 0⁺ pᵢ,ε(ε)  immediate post-event snapshot
```

This is not a right-hand limit of one globally differentiable intact-rocket
trajectory. It separates the shared initial state, finite-duration interactions,
and their limiting endpoint. It allows finite internal impulses, unlike a
single smooth bounded-force trajectory that would force each momentum to be
continuous individually. No individual fragment momentum conservation is assumed.

For constant gravity, elapsed-time integration over [0, ε] equals integration
over [t_apex, t_apex + ε], by the constant-impulse formula. Only total momentum
is continuous in this ideal event limit; individual momenta can jump.

## Potential upstream Physlib layering

```text
Physlib.ClassicalMechanics.PointParticle.Basic
  Particle.pos / velocity / acceleration, inertial ReferenceFrame
                         ↓
PhyslibTemp.ClassicalMechanics.ConstantAcceleration
  generic velocity and quadratic position laws, arbitrary dimension
                         ↓
UniformGravity (optional future layer; not added now)
                         ↓
P08 vertical/coasting/apex specialization
```

The constant-acceleration abstraction knows no vertical direction, gravity,
rockets, explosions or highest points. It operates on upstream Particle directly.
A separate UniformGravity module is deferred because merely renaming the constant
vector would add no physics. A useful future layer could derive acceleration g
from gravitational force `m • g` plus Newton II; that bridge is not claimed here.


A second possible upstream branch is:

```text
PointParticle / Force / NewtonianSystem
                  ↓
ImpulseMomentum (possible future upstream layer)
  total Newton II/III → finite impulse balance → event limits
                  ↓
event / collision / breakup applications
```

The kinematics branch supplies pre-event rest; the impulse branch supplies event
momentum transfer. They meet in P08 before the unchanged linear-algebra proof.
The indexed force interface is an explicitly documented prototype, not a claim
that full upstream trajectory/contact semantics has been implemented.

The temporary API is an **upstream-oriented prototype requiring maintainer/API
review**, not an accepted contribution. A possible upstream location is
`Physlib.ClassicalMechanics.ConstantAcceleration`, followed by an optional
`UniformGravity` layer and problem-specific applications. Namespaces, frame
instances, real coordinate time versus affine Time, and interval-local versions
need review before upstreaming. P08 consumes the generic layer rather than
serving as its semantic definition.

Future users include free fall, vertical launch, projectile motion, constant-force
motion, uniform-electric-field motion, turning points, time to apex and maximum
height. These examples are not all implemented; their force laws would need
separate premises or derivations.

## Verification and source provenance

`ConstantAccelerationExamples.lean` supplies upstream quadratic-particle
consistency witnesses and library checks for velocity difference, position
law, zero acceleration, zero initial velocity and stationary motion in arbitrary
dimension, with explicit dimensions 4 and 0. The P08 model itself accepts any
upstream particle satisfying the acceleration condition, not a prescribed parabola.

`Verify.lean` uses a parabola only as a consistency witness, checks apex-height
and velocity results, preserves zero/nonzero balanced fragments and the standard
basis negative test for `LinearCoplanar`. Its explicit event regularization
starts at rest, develops nonzero balanced internal momenta, and has the required
endpoint limits. It also proves that gravitational impulse is nonzero for every
positive duration under the model's positive mass/g assumptions, while tending
to zero. Source inputs remain satisfiable.

The source question and supplied printed-solution substance in `source.jsonl`
remain unchanged. Any solution image is explanatory text, not trusted geometry;
no diagram caption or reconstructed figure is introduced.

```bash
lake build
python3 scripts/verify.py P08
lake env lean LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/ConstantAcceleration.lean
lake env lean LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/ConstantAccelerationExamples.lean
lake env lean LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/ImpulseMomentum.lean
lake env lean LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/ImpulseMomentumExamples.lean
```

Mutations remain explicitly deferred, as in P03–P07. Dependency pins and the
previous demos' physical APIs are unchanged.

### Validation results

- `lake build`: PASS (3648 jobs); existing module-interoperability warnings remain.
- `python3 scripts/verify.py M00` and P01–P08: all PASS.
- M00/P01/P02 mutation checks: 6/6 each; P03–P08 explicitly SKIPPED.
- Direct `lake env lean` compilation of ImpulseMomentum and its examples: PASS.
- Source consistency: zero and nonzero balanced fragment examples have explicit
  event histories, force balance, initial matching and endpoint limits.
- Finite-duration gravitational impulse is nonzero for every ε > 0 under the
  positive mass/g assumptions; its ε → 0⁺ limit is zero.
- Standard-basis negative check, original source wording, linear-coplanarity
  definition/target and existing span/dimension/inverse-mass lemmas are preserved.
- Printed proof terms confirm pre-momentum uses derived apex rest, and event
  equality uses finite Newton/FTC balance plus endpoint and impulse limits.
- Candidate and CandidateAnnotated solution axioms:
  `[propext, Classical.choice, Quot.sound]`; no additional axioms or `sorry`.
- Documentation links and `git diff --check`: PASS.
- Dependency pins and previous demos' implementations are unchanged.
