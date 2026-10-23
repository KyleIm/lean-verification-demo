# P05 component classification

| Component | Classification | Boundary |
| --- | --- | --- |
| Physlib `ReferenceFrame`, `Vector`, `Force`, `Force.value` | Existing Physlib primitive | Actual formal frame-dependent forces, imported rather than copied |
| `ReferenceFrame.IsInertial`, `Orthonormal` | Existing Physlib primitive | Required by the reusable static-balance model, verified for the chosen lab frame |
| Mathlib `crossProduct`, finite sums, trigonometry | Pure mathematics | Reused algebra and geometry tools, not a ladder law |
| `planarMoment`, `planarMoment_eq` | PhyslibTemp reusable addition | Out-of-plane cross-product moment of any planar applied force, using upstream frame vectors |
| `PlanarStaticEquilibrium` | PhyslibTemp reusable addition | Finite-force inertial-Cartesian snapshot with zero force and moment; an adopted balance model, not Newton-Euler dynamics |
| `StaticFriction`, `LimitingStaticFriction` | PhyslibTemp reusable addition | Nonnegative μ/N, signed-force absolute bound and saturation; no kinetic friction or fixed equality below threshold |
| `labFrame`, `LadderData`, `height`, `OnLadder` | P05-specific modeling | Fixed Cartesian ladder/wall/floor setup; L/G positive, angle acute, μ nonnegative |
| `positions` / labels A,B,C,O and projection s cos α | P05-specific modeling | Straight-line coordinate geometry interpreted from the source solution and explanatory Fig. 311, not trusted problem-image data |
| `Reactions`, `constantForce`, `forces` | P05-specific modeling | N1, N2, Ffr, G; smooth wall, horizontal floor, neglected ladder weight |
| `EquilibriumAt`, `AdmissibleAt` | P05-specific modeling | Instantiate generic balance/contact relations; do not contain the final threshold inequality as a premise |
| `requiredFriction`, `criticalPosition`, `ReachableThreshold`, `TrustedPhysicsProblem` | P05-specific modeling | Candidate formulas and proof obligation; no input evidence that the formulas hold |
| `equilibrium_iff`, `reactions_required` | Derived physics | Derive N2 = G, Ffr = N1 and N1 H = G cos α s from the explicit applied forces/moments |
| `balancing_equilibrium` | Derived physics | Construct support forces before imposing friction availability |
| `required_strictMono`, `admissible_iff` | Derived physics | Increasing requirement and iff characterization of static feasibility |
| `limiting_at_critical`, `reachable_threshold`, `unreachable_threshold` | Derived physics | Correct the source generalization: reachable saturation versus equilibrium at every position for an unreachable threshold |
| `required_at_critical`, final saturation/nonexistence | Derived physics | Explicit threshold is a strengthening of the source explanation, with reachability kept separate |
| Positive division, cancellation, inequalities, ring/field normalization | Pure mathematics | No hidden physical assumptions |

The general rigid-body force/torque entries audited as `InformalLemma` are not
formal theorems used by this proof. Formal pendulum torque and Newtonian particle
systems are related but not reused as a general ladder-contact model. No Alpha
module is imported. See [PHYSLIB_AUDIT.md](PHYSLIB_AUDIT.md).

Fig. 311 is solution-side explanation, not trusted problem input. The parameterized
geometry and force directions are explicit modeling choices matching that source
interpretation. The static-balance principle itself is adopted, not derived from
full rigid-body mechanics. “Slip” denotes loss of a friction-admissible equilibrium
above an inclusive threshold, not an asserted time-dependent motion.

`LadderData` is only a parameter bundle. Together with `height`, `positions`,
`forces` and the static-equilibrium model it forms a problem-local physical
representation of the source ladder, not a general reusable ladder object.
The source's qualitative explanation is preserved; the strengthened trusted
problem explicitly distinguishes reachable and unreachable thresholds.
`ReachableThreshold` is a definition, not extra trusted evidence. No change to
Physlib/PhyslibTemp APIs or physical assumptions is required for these cases.
