# P09 — Sliding puck, elastic board impact and friction

Source problem **47** from the Russian physics problem set.
[Source pair](source.jsonl) · [Pinned-library audit](PHYSLIB_AUDIT.md) ·
[Classification](CLASSIFICATION.md).

## Source question vs formalized question

### BEFORE — original source problem

> A puck with an initial velocity of 5 m/s travels over a distance of 10 metres and strikes the boards. After the impact, which may be considered absolutely elastic, the puck travelled another 2.5 metres and stopped. Find the coefficient of friction between the puck and the ice. Consider the force of sliding friction in this and subsequent problems to be equal to the maximum force of friction of rest.

The supplied solution uses `ma = kmg`, hence `k = a/g`. The fixed-board elastic
impact preserves speed while changing direction, so both sliding path lengths
contribute to the same stopping relation. It uses `s = 12.5 m` and obtains
`k = v²/(2gs) = 0.102`. Source `k` is called `μ` in Lean.

### AFTER — Lean-facing formalized problem

Given two upstream Physlib particle reference trajectories in separate oriented
path coordinates, assume positive segment durations and lengths, equal positive
mass, a positive initial speed and g, and nonnegative μ. Supply horizontal support
balance `N = mg`, the source's sliding law `F = μN`, and scalar Newton II with
force `-F` on each sliding segment. Match the first initial speed and the two
segment displacements to the source data; require no initial reversal at impact,
fixed-board elastic equality of squared speeds, and final rest.

Derive the same constant deceleration on both legs, their velocity/displacement
laws, nonnegative velocities over the physical intervals, elastic speed matching,
and the stopping relation. Solve

```text
μ = v₀² / (2g(s₁+s₂)).
```

Specialize `v₀ = 5 m/s`, `s₁ = 10 m`, `s₂ = 2.5 m` and **the explicit numerical
choice** `g = 9.8 m/s²` to prove

```lean
data.μ = (5 : ℝ) / 49 ∧ |data.μ - (102 : ℝ) / 1000| < 1 / 2000
```

This is `TrustedPhysicsProblem data`, checked by
`Candidate.solution data source : TrustedPhysicsProblem data`. The additional
decimal interval is

```text
0.1020408 < μ < 0.1020409.
```

### What changed

The coefficient question becomes an explicit conditional derivation with source
numbers separated from physical model relations. The final formula and stopping
relation are not trusted inputs. The source's compressed kinematics is expanded
into two derived segment relations, and its rounded answer is separated from the
exact rational result. The source question does not state g numerically; 9.8 is
an explicit specialization yielding the supplied decimal.

The real puck is represented by positive mass, two local path-coordinate
trajectories, segment durations and distances, a normal reaction and sliding
friction magnitude. There is no reusable Puck, Board or contact ontology. Each
segment's coordinate increases along its own direction of travel; the two
coordinates are **not** one global axis implying a head-on impact. The board
angle and a spatial reflection map are unnecessary for this scalar conclusion.

Coordinates are fixed coherent SI: metres, seconds, kilograms, newtons, m/s and
m/s². μ is dimensionless. Physical dimensions are documented rather than encoded
in these real/frame-coordinate types, matching the mechanics demos' convention.

P09 makes the textbook reasoning more explicit and preserves its physical
meaning under the stated horizontal-friction and fixed-board elastic model.

## Trusted inputs and physical boundary

`PuckData` contains two actual upstream `trackFrame.Particle` values with positive
masses and differentiable position/velocity, positive durations, initial speed,
path lengths and g, nonnegative μ, and normal/friction scalar parameters.
`deceleration = frictionMagnitude / before.mass` is a definition; neither its
value nor `a = μg` is an input conclusion.

`SlidingModel data` contains exactly:

| Field | Input meaning |
| --- | --- |
| `same_mass` | The two segment particles describe the same puck mass |
| `normal_balance` | `N = m g`, adopted vertical support balance on horizontal ice |
| `sliding_friction` | `F = μ N`, the source's sliding-friction convention |
| `newton_before`, `newton_after` | For each reference time, `m · acceleration_component = -F` along that segment |
| `initial_speed` | First initial coordinate velocity equals the positive input v₀ |
| `first_path`, `second_path` | Segment coordinate displacements equal the supplied positive travelled distances |
| `incoming_nonneg` | The incoming coordinate velocity has not reversed at the board |
| `elastic_impact` | Local fixed-board elastic interpretation: incoming² = outgoing² |
| `final_at_rest` | Second terminal coordinate velocity is zero |

`SourceData data` consists of this model and four number equalities:
`v₀ = 5`, `s₁ = 10`, `s₂ = 5/2`, `g = 49/5`. It contains no coefficient result,
total stopping relation, precomputed deceleration or squared-speed kinematic law.

The scalar Newton-II and support equations are explicit problem-local physical
premises. P09 does not construct a complete upstream NewtonianSystem with force
targets and vertical contact geometry. Friction is the only tangential force in
the model; no other dissipation and no impact energy loss are included. This
is a translational puck model: spin, rotational energy transfer and a moving
board are not represented by the local elastic condition.

The globally differentiable trajectories are **separate reference continuations**,
used to reuse ConstantAcceleration's global API. Only `[0, firstDuration]` and
`[0, secondDuration]` describe actual sliding. The negative acceleration on a
continued reference parabola is not asserted to describe physical motion after
stopping. No single constant acceleration vector is imposed through the impact.

`sliding_speeds_nonnegative` proves no reversal during either physical interval.
This supports interpreting oriented displacement as travelled distance. A general
arc-length integral or reconstruction of the two paths in a shared physical
plane is not implemented.

## Audit of the supplied solution

| Source-solution step | Formal status |
| --- | --- |
| Sliding friction equals the maximum static-friction magnitude | Source convention modeled locally as F = μN; not a claim of static equilibrium |
| Normal reaction equals weight | Explicit horizontal-support model premise; not derived from a 3D contact system |
| Newton II gives ma = F | Scalar force/acceleration relation supplied on each leg, using genuine upstream acceleration |
| a = μg | Derived by support/friction substitution and positive-mass cancellation |
| Absolutely elastic impact changes direction only | Narrow local interpretation is equal squared speed for the same-mass puck at a fixed board |
| Impact speed magnitude is preserved | Derived from that interpretation; no general collision theorem is claimed |
| v_f² = v_i² − 2as | Derived from existing velocity and quadratic position evolution, not assumed |
| Both path lengths may be combined | Derived by canceling the matched impact speed in the two leg equations |
| s = 10 + 2.5 = 12.5 | Arithmetic after the physical path combination is justified |
| μ = 5/49, approximately 0.102 | Derived symbolic solution, exact numerical substitution, and proved rounding bound |

The static-friction API was inspected but not used to model a sliding puck:
`|Ft| ≤ μN` describes a sticking bound, while the source adopts equality of the
**sliding magnitude** with the maximum static-friction magnitude. Only that
coefficient/magnitude convention is shared; horizontal static balance is not
imposed on the moving puck.

## Reuse and problem-local concepts

Stable Physlib supplies `ReferenceFrame`, `ReferenceFrame.Particle`, positive
mass and derivative-based `pos`, `velocity`, `acceleration`. The audit also found
formal NewtonianSystem and kinetic-energy infrastructure, but no applicable
sliding-friction/fixed-board collision theorem at this pin. FreeParticle's energy
conservation assumes zero force and cannot justify this frictional motion or an
impact.

Existing PhyslibTemp `HasConstantAcceleration.velocity_eq` and `position_eq` are
reused separately on both legs. Its `Examples.quadraticParticle` constructor is
used only for consistency checks. StaticFriction, PlanarStatics and
ImpulseMomentum were inspected; none supplies the missing sliding/elastic law
for this problem, and a finite collision model is unnecessary here.

**No new PhyslibTemp module or declaration is added.** The local
`ElasticFixedBoardImpact`, force premises, path coordinates and numerical source
specialization remain in P09. Pure algebra stays in Candidate, not in a new
physics library.

## Reviewer-facing dependency chain

```text
normal_balance + sliding_friction
  → friction_acceleration: a = F/m = μg ≥ 0

newton_before / newton_after + equal mass
  → segment_deceleration_before / segment_deceleration_after
  → existing ConstantAcceleration.velocity_eq / position_eq
  → segment_velocity / segment_travel
  → segment_speed_squared: v_f² = v_i² − 2as

nonnegative interval velocities + ElasticFixedBoardImpact
  → impact_preserves_speed → impact_speed_eq

two segment squared-speed relations + elastic matching + final rest
  → stopping_relation: v₀² = 2a(s₁+s₂)

stopping_relation + friction_acceleration
  → deceleration_from_stopping: a = v₀²/[2(s₁+s₂)]
  → coefficient_from_deceleration: μ = a/g
  → coefficient_symbolic: μ = v₀²/(2g(s₁+s₂))
  → total_path = 25/2
  → coefficient_exact: μ = 5/49
  → coefficient_source_value: |μ − 0.102| < 0.0005
```

`Candidate.solution` explicitly displays the rational and rounding targets.
`CandidateAnnotated.lean` explains the actual physical and mathematical
dependencies. The total-path argument is not merely `10 + 2.5`: elastic matching
is necessary for the intermediate speed to cancel without an extra energy-loss
term.

## Verification

`Verify.lean` constructs two upstream quadratic particles with unit mass and
unit friction force, so the witness deceleration is 1 m/s². They start at speeds
5 and √5; durations are `5 − √5` and `√5`. Direct differentiation and arithmetic
verify the source distances 10 and 2.5, support/friction/Newton relations,
elastic speed matching and final rest. The witness coefficient is assigned as
`F/N = 1/(49/5)` and all physical/source relations are checked; the final theorem
or stopping equation is not inserted as evidence.

Checks include satisfiable source inputs, nonzero initial speed, positive path
lengths, impact speed, final rest, exact coefficient, the source rounding bound
and the tighter decimal interval. A check also proves μ is **not exactly** 0.102.
Mutation cases are explicitly deferred, consistent with P03–P08.

```bash
lake build
python3 scripts/verify.py --list
python3 scripts/verify.py P09
lake env lean LeanVerificationDemo/PhysicsDemo/P09/PairingWalkthrough.lean
git diff --check
```

Dependency pins and existing demos are unchanged. No external source book,
diagram or additional empirical data is used.

### Validation results

- `lake build`: PASS (3653 jobs); existing module-interoperability warnings remain.
- M00 and P01–P09 verification: all PASS.
- M00/P01/P02 mutations: 6/6 each; P03–P09 explicitly SKIPPED.
- `--list` recognizes P09 with source ID 47.
- Source consistency, positive paths, nonzero initial speed, impact speed,
  final rest, exact coefficient and both approximation checks: PASS.
- Printed proof terms confirm the final coefficient depends on the derived
  stopping relation and on the existing velocity/position laws.
- Candidate and CandidateAnnotated solution axioms:
  `[propext, Classical.choice, Quot.sound]`; no `sorry` or new axioms.
- JSON/links, new-file whitespace and `git diff --check`: PASS.
- No dependency pin or existing PhyslibTemp/demo implementation changed.
