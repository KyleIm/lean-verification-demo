# P08 classification

| Component | Classification | Boundary |
| --- | --- | --- |
| Physlib ReferenceFrame, Particle.pos / velocity / acceleration | Existing reusable physics infrastructure | Upstream derivative-based kinematics |
| Physlib NewtonianSystem.Particle.momentum, newton_second_law, newton_third_law, InternalForce.reverse | Existing formal mechanics infrastructure | Used in the new upstream adapters; the event family itself uses a coordinate force interface |
| HasConstantAcceleration and velocity / position laws | PhyslibTemp reusable mechanics | Arbitrary dimension, inertial frame, no gravity or event data |
| newtonian_particle_momentum_hasDerivAt / newtonian_internal_force_sum_zero | PhyslibTemp reusable adapters | Derivative of actual upstream momentum and cancellation of its internal-force multiset |
| MomentumBalance.newton_second / newton_third | PhyslibTemp reusable physical relations | Momentum-form Newton II and pairwise Newton III, not a total-conservation axiom |
| internal_sum_zero / total_hasDerivAt / total_change_eq_integral | Derived reusable mechanics | Finite sums and FTC eliminate internal forces and integrate total momentum |
| continuous_impulse_tendsto_zero / constant_impulse_tendsto_zero | Reusable mathematical consequence for forces | Mathlib integral continuity, positive-duration limit; no finite-duration zero assertion |
| event_momentum_eq_of_impulse_limit | Reusable event-limit consequence | Requires derived finite balance, endpoint convergence and vanishing impulse |
| ConstantAccelerationExamples / ImpulseMomentumExamples | Library verification | Independent explicit witnesses, not P08 source assumptions |
| UniformGravity | Deferred physical specialization | No new module or gravity/Newton-II force-to-acceleration derivation |
| labFrame, up, initial upward speed and downward acceleration | P08 model kinematics | Ideal coasting reference trajectory, no powered flight |
| apexTime / height maximum / zero apex velocity | Derived mathematics and kinematics | Reusable laws, completed square and Mathlib Fermat theorem |
| eventMomentum / internalForce | P08 event regularization data | Family indexed by positive duration; elapsed-time momentum and force functions |
| SourceData.mass_balance / event_initial | P08 system/initial-state modeling | Closed system mass accounting; constituents initially co-move with the rocket |
| SourceData.event_balance | P08 use of reusable Newton relations | Constituent momentum equations and equal-and-opposite internal forces |
| SourceData.post_event_limit | P08 idealized event semantics | Existence and identification of endpoint limits; not an equality of total pre/post momenta |
| gravitationalForce / gravitationalImpulse | P08 gravity specialization | Constant mass-weighted downward force; integral over finite elapsed duration |
| finite_duration_momentum_balance | Derived physics | Total change equals finite, generally nonzero gravitational impulse |
| gravitational_impulse_tendsto_zero | Derived limit | Textbook approximation language sharpened to an exact instantaneous-event limit |
| event_momentum_eq / total_momentum_zero | Derived event mechanics | Uniqueness of endpoint/impulse limits, then derived apex rest |
| fragment momentum and positive masses | P08 snapshot modeling | p = m • v for the immediate post-event limiting snapshot |
| LinearCoplanar / TrustedPhysicsProblem | Unchanged mathematical target | Linear subspace through zero, dimension ≤ 2; includes degeneracies |
| span, finrank bound, inverse-mass scaling | Mathlib linear algebra | Existing proof retained; no affine-coplanarity shortcut |
| regularized consistency witnesses and standard-basis negative test | Verification | Nonzero internal momentum transfer, finite nonzero gravity impulse and its zero limit; coplanarity is not automatic |

The removed `SourceData.momentum_conserved` is not replaced by an opaque event
conservation equality. Finite-duration particlewise equations, initial matching
and limiting-state identification are the physical/model inputs. They do not
prove that a real explosion has literally zero duration or that every physical
explosion admits this regularization. No generic rocket or explosion ontology
is added. The two reusable mechanics branches are documented prototypes.
