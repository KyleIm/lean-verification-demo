# P12 classification

| Component | Classification | Trust/reuse boundary |
| --- | --- | --- |
| Problem 48 wording; tyre/pressure context | Source problem/provenance | Preserved in source.jsonl; no additional source book consulted |
| Pavement, speedKmh, brakingDistance | P12-local source data | Seven categories, ten speeds, all 70 original distances; exact decimal reals |
| Source solution's answer list | Source solution conclusions | Recorded for comparison, not used as trusted Lean fields |
| Numerical gravity=49/5 | Formalization/model specialization | Source solution uses symbolic g; not a Table 1 value |
| speedSI=(5/18)speedKmh | Exact unit conversion | Upstream quantity conversion checked separately in Units |
| ReferenceFrame.Particle, pos/velocity/acceleration | Existing Physlib mechanics | Derivative-based trajectory and positive mass; no parallel particle type |
| HasConstantAcceleration.velocity_eq / position_eq | Existing PhyslibTemp reusable physics | Generic kinematics reused directly, with no change to the module |
| BrakingRun and one-dimensional trackFrame | P12-specific physical representation | Parameters/coordinate continuation, not a Vehicle or Pavement ontology |
| BrakingModel normal balance, saturated braking friction, scalar Newton II | Source-solution physical/model inputs | Horizontal road, maximum friction opposing motion; no derivation of tyre/contact behavior |
| Fixed force continuation during the modeled observation | Source-solution constant-acceleration idealization | Newton II derives constant acceleration; only [0,duration] is physical |
| friction_acceleration / constant_deceleration | Derived physics | N=mg and F=μN yield a=μg and a fixed negative coordinate acceleration |
| braking_velocity / braking_travel | Reusable physics specialization | Project the generic velocity and position laws |
| braking_speed_nonnegative | Derived physics/mathematics | No reversal before rest; coordinate displacement is the braking path coordinate |
| stopping_relation / friction_estimator | Derived physics | Eliminate time, then derive μ=v²/(2gs); no stopping-formula premise |
| frictionEstimate / tableEstimate | P12 estimation specification | Given expression whose physical correctness is proved and used in the final certificate |
| IsTenth / RoundsToTenth | Formalization choice and pure mathematics | Tenth grid; half-open nearest-tenth bands, ties toward +∞ |
| Candidate.coefficient | Candidate-computed witness | floor(10 × first-row estimate + 1/2)/10; no supplied answer mapping in Problem |
| rounded_numerators / coefficient_values | Derived data | First explicit numerical answer claims in Lean, proved from source values |
| Seven row lemmas / all_estimates_inside_bands | Exact table arithmetic | All 70 estimates strictly inside the bands, not just one selected speed |
| rounding_unique / table_solution_unique | Pure mathematics | Integer-grid disjointness; uniqueness among all assignments satisfying the specification |
| PhysicalTableCompatibility | Model/specification linkage | Every braking run matching a row must have the same rounded coefficient; Candidate uses the derived estimator |
| TrustedPhysicsProblem | Trusted open specification | ∃! coefficient assignment satisfying full-table rounding and physical compatibility; no seven answer constants |
| WithDim, Dimensionful, SI and DimSpeed conversion | Existing Physlib unit/dimension system | Dimension checks do not establish a friction law |
| Units.typed_table_estimate | Additive dimensional/numerical bridge | Typed dimensionless expression agrees with the scalar estimator; no repeated 70-cell typed proof |
| Verify row witnesses | Consistency verification | Actual quadratic trajectories for every table cell; μ chosen from F/N, not the rounded answer |
| Speed independence | Derived at requested resolution | Raw estimates may differ; no exact common μ or universal real-world speed independence asserted |

No new PhyslibTemp concept is introduced. P09's collision-specific data, static
friction admissibility, planar statics and event impulse semantics are not
imported as braking laws. The only reusable local mechanics dependency is the
existing ConstantAcceleration module; generic units come directly from Physlib.
