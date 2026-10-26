# P10 classification

| Component | Classification | Boundary |
| --- | --- | --- |
| Axis quantities/units, nine vertices, straight joins, t₁/t₂ | Trusted source/caption geometry | No areas or averages in caption input; no original-image comparison claimed |
| time / ordinate / linearSegment / segment / velocity | P10-specific graph encoding | Direct input velocity, not position or a derivative-based particle |
| velocity_at_vertices / velocity_on_segment | Verified caption interpretation | Every vertex and closed segment, including endpoints |
| displacement / pathTravelled | P10-local kinematic interpretation | ∫v and ∫|v|, no general arc-length theory |
| meanVelocity / meanAcceleration | P10-local standard definitions | Integral/time and endpoint difference/time, respectively |
| Mathlib interval integral and FTC | Existing mathematical infrastructure | Actual integration with proved antiderivative and integrability |
| integral_linear_segment / segment_areas / integral joins | Derived mathematics | Trapezoid integrals computed from geometric endpoints, not assumed |
| velocity_nonnegative_on_zero_ten / path_eq_displacement | Derived kinematics and mathematics | Path equals displacement only for this nonnegative source graph |
| distance_first_five / distance_first_ten | Derived graph result | 21/2 cm and 25 cm |
| four mean-value lemmas / solution | Derived source answer | Exact rational means, no solution value is an input assumption |
| Physlib Dimension / WithDim / SI choice / centimeters | Existing upstream units | Reused directly; no PhyslibTemp or new quantity structures |
| Units local aliases and typed answers | P10 unit verification | cm-second convention; velocity·time = length, velocity/time = acceleration |
| problem_diagram.svg and generator | Caption-derived presentation | Only geometry JSON is read; source solution/proof/images are not graph inputs |
| source solution | Provenance plus targets | Separately recorded; its claimed areas and means are checked |

No forces, masses, Newtonian trajectories, general graph ontology or new
PhyslibTemp mechanics/unit API is introduced.
