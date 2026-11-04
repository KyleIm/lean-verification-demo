# P14 classification

| Component | Classification | Evidence / boundary |
| --- | --- | --- |
| Equal length l, two mathematical pendulums, weightless spring k | Source text | Original problem 638 |
| Vertical equilibrium, undeformed spring, equal-angle in/antiphase planar motions | Source text | Original problem statement, not supplied solution |
| **m = equal bob mass** | **Source image** | **Both bobs labelled m in the directly inspected original Fig. 228** |
| Distinct fixed suspension points; direct spring-to-bob attachment; horizontal equilibrium connector | Source image | Original Fig. 228, not Fig. 479 |
| CoupledPendulumData, positive parameters, gravity g and separation D | P14-specific modeling | D and coordinates quantify the picture; g is the ideal gravitational parameter |
| firstBob / secondBob / partnerAngle | P14-specific geometric representation | Signed circular coordinates for the two requested modes |
| springExtension / springLength | P14-specific geometry | Signed coordinate extension; verified against Euclidean length locally |
| SimplePendulum, inertia, torque_apply | Existing stable Physlib physics | Formal gravitational torque and point-bob inertia |
| HarmonicOscillator.force_eq_linear | Existing stable Physlib physics | Reused Hooke law with correct first/second force signs |
| SimplePendulum.toHarmonicOscillator / toHarmonicOscillator_ω | Existing stable Physlib small-angle model | Formal single-pendulum linearization and frequency bridge |
| HarmonicOscillator.ω / ω_pos / ω_sq | Existing stable Physlib physics | Positive angular frequency of a linear oscillator |
| equal_bob_heights / in_phase_extension / anti_phase_extension | Candidate-derived geometry | Exact trigonometric geometry, not caption or solution premises |
| bobs_ordered_near_equilibrium / physical_extension_near_equilibrium | Candidate-derived geometric domain | Positive D keeps the actual spring on the local uncrossed branch |
| first_horizontal_tangent / spring_torque_projection | Candidate-derived geometry/physics | Angular tangent and horizontal-force torque projection |
| anti_phase_torque / source_restoring_force | Candidate-derived physics | Printed Fr is recovered from signed torque |
| Derivative-at-equilibrium linearized dynamics | Small-oscillation model interpretation | Source requests small oscillations; no finite-angle sin φ=φ or cos φ=1 premise |
| Torque derivatives and both bob linearized equations | Derived physics / pure calculus | Exact differentiation of the modeled nonlinear mode slices |
| antiPhaseOscillator | P14-local specialization of reusable physics | Upstream oscillator with derived inertia and rotational stiffness |
| IsModeFrequency / IsModeFrequencySolution / TrustedPhysicsProblem | Semantic problem specification | Positive frequencies satisfying both bob equations; no expected formulas |
| solutionFrequencies / solution | Candidate-constructed answer | Explicit square roots appear on Candidate side; uniqueness within the linearized model |
| WithDim / HarmonicOscillatorWithDim | Existing stable Physlib dimensions | Typed radicands, Hooke stiffness and angular-frequency dimension |
| sourceForm / root dimension / typed bridges | Dimensional verification | Not extra physical assumptions; scalar proof and typed check agree |
| Fig. 479 and supplied force annotations | Solution-side reference | No separate image inspected; supplied text audited, no original-figure premises inferred |
| problem_diagram.svg / generator | New visual restatement of original source image | Direct Fig. 228 analysis; rendering choices, no trusted-caption intermediary or Fig. 479 content |

PhyslibTemp: **no addition**. The existing upstream pendulum/small-angle/Hooke/
oscillator APIs supply the reusable physics. The coupled apparatus and mode-slice
geometry stay local. Lean proves consequences of the interpreted physical model;
it does not certify the visual extraction itself.
