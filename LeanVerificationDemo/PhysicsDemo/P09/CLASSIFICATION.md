# P09 classification

| Component | Classification | Boundary |
| --- | --- | --- |
| Physlib ReferenceFrame / Particle | Existing Physlib primitives | Positive mass and real-time trajectory; no force law from the particle alone |
| Particle.pos / velocity / acceleration | Existing Physlib mechanics infrastructure | Actual derivatives in an inertial frame, not independent velocity/acceleration data |
| NewtonianSystem / kineticEnergy / FreeParticle | Existing Physlib, audited | Full system/zero-force energy APIs do not supply sliding friction or wall elasticity here |
| HasConstantAcceleration.velocity_eq / position_eq | Existing PhyslibTemp reusable physics | Separate generic kinematics on each leg, no constant vector through collision |
| Examples.quadraticParticle | Existing verification helper | Consistency witness only; not a trusted source trajectory |
| PuckData, trackFrame, tangent, speed, travel | P09-specific physical representation | Two abstract oriented path charts, fixed coherent SI; no shared spatial board-angle geometry |
| v₀ = 5, s₁ = 10, s₂ = 5/2 | Source data | Question's explicit speed and travelled path lengths |
| g = 49/5 | Explicit numerical model specialization | Standard 9.8 m/s² choice, not a numerical datum quoted in the question |
| positive mass/time/paths/g and nonnegative μ | Physical model domain | No nonzero denominator is hidden |
| same_mass / normal_balance | P09-specific modeling | Same puck mass; vertical support N = mg is supplied, not derived from full contact geometry |
| sliding_friction | Source convention / local physical law | F = μN while sliding; equality with maximum static-friction magnitude does not mean static rest |
| newton_before / newton_after | P09-specific use of Newton II | m times derivative-based tangential acceleration equals −F; only tangential force is friction |
| initial_speed, first_path, second_path, incoming_nonneg, final_at_rest | Source/model boundary data | Actual motions are restricted to the two positive-duration intervals |
| ElasticFixedBoardImpact / model.elastic_impact | P09-local physical interpretation | Equal squared speeds models same-mass fixed-board elasticity; no generic collision theorem assumed |
| friction_acceleration / deceleration_nonneg | Derived physics | Positive-mass cancellation gives a = μg ≥ 0 |
| segment_deceleration_before / after | Derived physics | Newton force equations give constant acceleration in each path chart |
| segment_velocity / segment_travel | Derived kinematics | Projections of existing generic velocity/position evolution |
| segment_speed_squared | Pure mathematics applied to derived kinematics | Time elimination proves v_f² = v_i² − 2as |
| sliding_speeds_nonnegative | Derived kinematics | No reversal on each physical interval; continued parabolas are not actual motion after stopping |
| impact_preserves_speed / impact_speed_eq | Derived physical consequence | Square equality gives magnitude equality, and interval signs identify scalar speeds |
| stopping_relation | Derived physics | Two segment losses add after the matched intermediate speed cancels |
| total_path | Pure mathematics / source arithmetic | 10 + 5/2 = 25/2; physical use of the sum is justified separately |
| deceleration_from_stopping / coefficient_from_deceleration / coefficient_symbolic / exact / source_value / decimal_interval | Derived answer and pure mathematics | μ = v₀²/[2g(s₁+s₂)] = 5/49 with rigorously bounded decimal approximation |

No new PhyslibTemp API is introduced. StaticFriction's sticking inequality,
PlanarStatics' equilibrium model and ImpulseMomentum's interaction equations
were inspected and are not substituted for the source's sliding law or elastic
fixed-board condition. No general contact/collision solver, ontology-level Puck,
or board-reflection geometry is added.
