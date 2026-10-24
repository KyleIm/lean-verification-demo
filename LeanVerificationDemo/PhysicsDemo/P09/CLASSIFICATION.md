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

## Additive dimension/unit layer

| Component | Classification | Boundary |
| --- | --- | --- |
| Dimension / LTMCTDimensionBase / WithDim | Existing upstream physical-dimension system | Uses length/time/mass subset of the existing basis; no parallel quantity structures |
| LTMCTUnitChoices.SI / Dimensionful / toDimensionful | Existing upstream unit machinery | Common coherent SI coordinates plus covariance between unit choices |
| WithDim HMul / HDiv / cast / scalar actions | Existing upstream quantity algebra | Products and quotients carry their computed dimensions; casts require proofs |
| DimSpeed.oneMeterPerSecond / DimEnergy.joule | Existing named upstream units | Checked against the local real-valued SI representation |
| Units quantity aliases and source SI values | P09-local presentation of typed source/model data | 5 m/s, 10 m, 5/2 m; explicit g = 49/5 m/s² specialization |
| friction_dimensions_iff / newton_dimensions | Dimensional verification | Force homogeneity and Mass × Acceleration = Force, not friction/Newton assumptions |
| stopping_dimensions / coefficient_dimensions | Dimensional verification | Velocity² = Acceleration × Length and v²/(gs) has dimension 1 |
| typed_friction / typed_friction_acceleration / typed_stopping_relation / typed_coefficient_equation | Bridge to existing physical/model result | Value equalities come from existing premises/Candidate; dimension equalities are proved separately |
| typed_newton | Algebraic identity in typed quantities | F = m(F/m); connection to trajectory acceleration remains in Candidate |
| source_coefficient_in_SI | Exact typed numerical specialization | Evaluates the expression to WithDim 1 ℝ with value 5/49; does not establish the mechanics |
| coefficient_source_value | Unchanged scalar numerical approximation | Existing rounding theorem still derives from exact mechanics answer |
| energy_dimensions / joule_is_newton_metre | Optional dimensional/SI check | mv² is energy and J = N·m; no new energy proof of P09 |
| coefficient_unit_invariant | Upstream unit-covariance consequence | Dimensionless quantity coordinates do not rescale |
| incorrect_formula_not_dimensionless | Negative dimensional verification | v/(gs) has dimension T/L and is not dimensionless; no deliberately broken file |

No new PhyslibTemp declaration is required. The mechanics data/proposition and
Candidate proofs remain byte-for-byte unchanged; Units is an additive checked
layer and does not turn dimensional consistency into a physical assumption.
