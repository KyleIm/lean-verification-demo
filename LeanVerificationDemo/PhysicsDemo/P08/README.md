# P08 — Three fragment velocities lie in one linear plane

Source problem **77**. [Source record](source.jsonl) ·
[Pinned-library audit](PHYSLIB_AUDIT.md) · [Classification](CLASSIFICATION.md) ·
[Reusable mechanics API](../../PhyslibTemp/ClassicalMechanics/ConstantAcceleration.md).

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
Given three positive-mass fragment velocities and conserved total momentum
across the explosion at this derived apex time, prove that all three velocities
lie in one real linear subspace through zero of dimension at most two.

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
velocity is evaluated immediately before it. Across-event momentum conservation
remains a separate short-event approximation. The implementation does not prove
literal zero gravitational impulse, zero duration or subsequent fragment dynamics.

Linear coplanarity, rather than affine coplanarity of three endpoints, is kept.
Zero/collinear velocities are valid: the containing subspace may have dimension
zero or one. No independence or nonzero-fragment-velocity assumption is added.

## Exact inputs and abstraction boundary

`ExplosionData` contains positive fragment masses, three fragment velocity
vectors, an upstream `labFrame.Particle`, positive `initialSpeed = u`, and positive
g. Its upstream particle includes a positive mass, a position function and the
inertial-frame differentiability of position and velocity. The lab frame is a
fixed Cartesian frame; `up` is its third coordinate direction.

The exact `SourceData` fields are:

```lean
constant_acceleration : HasConstantAcceleration data.rocket ((-data.g) • up)
initial_velocity : data.rocket.velocity 0 = data.initialSpeed • up
momentum_conserved : totalMomentum data = preMomentum data
```

The first is the uniform-gravity/coasting kinematic model assumption, not a
proved force-to-acceleration theorem. No F = mg or Newtonian system is constructed
in this specialization. The initial condition makes the motion vertical. Without
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

The upstream particle's actual mass is now used for pre-event momentum. No
additional mass-balance premise is needed for this zero-momentum argument.
The consistency example chooses rocket mass equal to the sum of fragment masses.
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

total_momentum_zero
  adopted across-event conservation → p₁+p₂+p₃ = 0

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
is distinct from the source's negligible-external-impulse approximation, which
still supplies the across-explosion conservation relation. Exact mechanics here
means deductions under the stated ideal kinematics, not a full proof of gravity
or rocket flight from Newton's laws.

`CandidateAnnotated.lean` distinguishes upstream/reusable mechanics, P08-specific
vertical/apex specialization, approximate explosion physics and pure linear
algebra. No plane or zero post-event momentum is trusted input.

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
P08 vertical/coasting/apex specialization and event approximation
```

The constant-acceleration abstraction knows no vertical direction, gravity,
rockets, explosions or highest points. It operates on upstream Particle directly.
A separate UniformGravity module is deferred because merely renaming the constant
vector would add no physics. A useful future layer could derive acceleration g
from gravitational force `m • g` plus Newton II; that bridge is not claimed here.

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
basis negative test for `LinearCoplanar`. Source inputs remain satisfiable.

The source question and supplied printed-solution substance in `source.jsonl`
remain unchanged. Any solution image is explanatory text, not trusted geometry;
no diagram caption or reconstructed figure is introduced.

```bash
lake build
python3 scripts/verify.py P08
lake env lean LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/ConstantAcceleration.lean
lake env lean LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/ConstantAccelerationExamples.lean
```

Mutations remain explicitly deferred, as in P03–P07. Dependency pins and the
previous demos' physical APIs are unchanged.

### Validation results for this refinement

- `lake build`: PASS (3645 jobs); module-interoperability warnings remain.
- M00 and P01–P08: all PASS; M00/P01/P02 mutations 6/6 each, P03–P08 explicitly SKIPPED.
- Both new mechanics modules directly compiled with `lake env lean`: PASS.
- Library checks include arbitrary dimension/reference time, zero acceleration,
  zero initial velocity, stationary motion, and dimensions 4 and 0.
- Apex consistency witnesses and existing fragment/standard-basis checks: PASS.
- Printed proof terms confirm pre-momentum depends on derived apex velocity and
  Fermat's theorem consumes the proved maximum and actual height derivative.
- Coplanarity definition, target and linear-algebra lemma bodies are unchanged.
- Final theorem and generic velocity/position law axioms remain
  `[propext, Classical.choice, Quot.sound]`; no `sorry` or new axioms.
- `git diff --check`: PASS; dependency pins and prior demo implementations unchanged.
