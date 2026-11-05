# Paired P15/P16 classification

| Component | Classification | Evidence / semantic boundary |
| --- | --- | --- |
| 764: coherent S₁,S₂, l, wavelength, D≫l, near A | Source text | Original Problem 764; no final spacing given |
| 764: transverse source pair, l/D dimension lines, vertical screen and A | Source image | Directly inspected Fig. 253, screenshot 15-43-07 |
| 766: S and virtual S′ in mirror AO; reference to Problem 764 | Source text | Original wording preserved in the second JSONL record |
| 766: mirror/screen at O, source/image positions, direct/reflected rays and dashed extensions | Source image | Directly inspected Fig. 255, screenshot 15-43-52 |
| C, hₖ, d₁, d₂ notation | Supplied-solution construction | Not original Fig. 253 labels; absent from its new schematic |
| Equal-initial-phase ordinary reference | Source-solution/model interpretation | Coherence alone only requires a fixed relative phase |
| Extra reflected-wave phase π | Supplied-solution physical assumption | Not a geometric mirror theorem or universal reflection law |
| Wavelength | Existing stable Physlib primitive | Positive length-tagged NNReal in ScreenData |
| WithDim / Dimension / typed arithmetic | Existing stable Physlib dimensions | Actual typed formulas and scalar bridges in Units |
| PlaneMirror direction law from P11 | Existing PhyslibTemp, inspected but not imported | Supplies geometric reflection, not optical reflection phase |
| TwoBeamInterference.phase / intensity | New reusable PhyslibTemp physical model | Monochromatic coherent scalar beams; adopted intensity law, not Maxwell derivation |
| Intensity bounds and extrema/order equivalences | Reusable derived physics/mathematics | Positive arbitrary amplitudes; minimum may be nonzero |
| Pi-reversal and half-wavelength theorems | Reusable derived optics | Additive phase input, no screen/Lloyd/source-specific constants |
| ScreenData, range coordinates and paraxialDifference | Pair-local modeling | Positive parameters; explicit 2D denominator closure |
| l,D,wavelength for 766 | Formalization parameters | Quantify real/virtual source separation and comparison model; not symbols read from Fig. 255 |
| Squared/factored path difference | Derived exact Euclidean geometry | Solution-side GeometryDerivation, not answer premises |
| Center path sum strictly greater than 2D | Derived exact geometry / approximation audit | Rejects false exact finite-distance replacement |
| Far-screen near-axis closure | Approximation/model choice | Source regime, no invented threshold for ≫ or claimed finite error bound |
| IsFringeSpacing / TrustedPhysicsProblem764 | Semantic problem specification | Find positive consecutive phase-order/bright-lattice spacing, no supplied closed form |
| Candidate764 spacing and bright/dark lattices | Derived physics | λD/l is constructed and validated on Candidate side |
| IsRelativeShift / TrustedPhysicsProblem766 | Self-contained comparison specification | Find positive unwrapped phase translation; extrema correspondence is Candidate-derived |
| Candidate766 shift and extrema interchange | Derived physics | λD/(2l); no dependency on previous Candidate |
| Unwrapped π branch | Formalization convention | Fixes a unique representative; intensity shifts alone are periodic/nonunique |
| Band width terminology | Supplied-solution terminology audit | Derived half-period center offset; no sharp brightness edges invented |
| Two SVGs and generator | New source-faithful visual restatements | Direct original-image references, not caption input or copied scans |
| verification.json list / evidence collector compatibility | Minimal paired-config adapter | Independent selectors; legacy formats/stages retained; evidence still collected for one selected problem |
| Units typed spacing, shift, path and phase | Dimensional verification | Length outputs, dimensionless optical phase/π |
| Cancellation, integer orders, real algebra, cosine identities | Pure mathematics | Mathlib/kernel proofs; no floating-point/native evaluation |

The original textbook cross-reference remains in prose and provenance. Lean
replaces it with shared local geometry and reusable optics, not with a hidden
`Candidate764.solution` premise. Both target definitions remain answer-free.
The mathematical paraxial extension covers all real h; physical interpretation
is limited to near-axis observation and, for Lloyd, beam overlap. No global
finite-aperture or nonparaxial rigid-translation theorem is claimed.
