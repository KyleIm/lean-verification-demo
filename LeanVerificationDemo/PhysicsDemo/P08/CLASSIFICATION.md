# P08 classification

| Component | Classification | Boundary |
| --- | --- | --- |
| Physlib ReferenceFrame, Particle.pos / velocity / acceleration | Existing reusable physics infrastructure | Actual upstream derivative-based trajectories are reused |
| Physlib NewtonianSystem and Force | Existing physics infrastructure, audited | No new gravity-force/Newton-II derivation is claimed |
| HasConstantAcceleration and its generic velocity / position laws | PhyslibTemp reusable mechanics | Any spatial dimension and inertial frame, no gravity/vertical/source-specific data |
| ConstantAccelerationExamples | Library-level mathematical verification | Upstream quadratic-particle witnesses, not another particle model |
| UniformGravity | Deferred possible reusable physical specialization | No separate module: a renamed acceleration vector alone adds no physical layer |
| P08 labFrame, up, initial upward speed and downward acceleration | Problem-specific use of reusable mechanics | Ideal coasting reference trajectory, no propulsion or post-event trajectory |
| highest point / apexTime / height | P08 kinematics and derived geometry | Computed u/g and proved maximum; no assumed apex-rest equality |
| apex_vertical_velocity_zero, apex_velocity_zero | Derived mathematics / kinematics | Proven maximum + actual derivative + Mathlib Fermat theorem + vertical velocity law |
| SourceData.constant_acceleration / initial_velocity | Source/model kinematics | Physical idealization and initial condition, not final answers |
| SourceData.momentum_conserved | Source/model physical approximation | Across-explosion negligible-impulse approximation remains a premise |
| preMomentum | P08 physical modeling | Upstream particle mass times derived apex velocity |
| pre_momentum_zero / total_momentum_zero | Derived physics | Proved zero velocity, then adopted across-event conservation |
| fragment momentum, positive masses | P08 snapshot modeling | Same m • v convention and mass nonzeroness as before |
| LinearCoplanar / TrustedPhysicsProblem | Unchanged P08 mathematical target | Real linear subspace through zero with dimension ≤ 2 |
| span construction, dimension bound, inverse mass scaling | Mathlib linear algebra | Existing coplanarity proof retained; degeneracies allowed |
| standard-basis negative check | Pure mathematics | Three independent vectors do not satisfy the linear-coplanarity target |

There is no PhyslibTemp Rocket, VerticalProjectile, HighestPoint or explosion
ontology. The reusable module is constant-acceleration mechanics; the vertical
apex and approximate explosion are its problem-specific consumer.
