# P13 classification

| Component | Classification | Boundary |
| --- | --- | --- |
| L=50 cm, d=1 mm, T=2450 dyn, ρ=7.8 g/cm³ | Source facts | Native units preserved in SourceData and source.jsonl |
| Printed ν₀=2 and νₙ=2n | Source-solution numerical conclusions | Audited as approximate, not trusted equalities |
| Both fixed ends, uniform ideal flexible string | Source-solution physical interpretation | Not a literal claim that the question specifies supports or that real-steel stiffness was analyzed |
| Physlib WaveEquation / planeWave_waveEquation | Existing formal Physlib infrastructure | Travelling-wave PDE solutions; not a fixed-string/tension quantization law |
| Physlib harmonicWave | Existing formal wave definition | Angular-frequency time dependence; not a fixed-end spectrum theorem |
| RigidBody small-oscillation informal lemma | Informal-only related material | Not used as formal mechanics |
| Alpha tight-binding standing waves | Alpha-only specialized quantum model | Not imported as a classical string law |
| PhyslibTemp FixedString / waveSpeed / frequency | Reusable physical-model definitions | Ideal c=√(T/μ), fₙ=nc/(2L); no PDE/spectral derivation claimed |
| Positivity / harmonic_scaling / first_frequency | Reusable derived physics | Consequences of the adopted model |
| wavelength / modeShape endpoint checks | Reusable geometry/model validation | Fixed-end compatible sine profile, not completeness of PDE eigenfunctions |
| StringData, diameterCm, radiusCm, areaCm2 | P13-local physical representation/geometry | Cylinder and native-unit parameter bundle; no steel ontology |
| circular_area / linear_density_formula | Derived geometry/physics | A=πd²/4 and μ=ρA |
| cylindrical_frequency / fundamental_formula | Derived physics | Combined source formula follows from the reusable law and geometry |
| Fundamental sqrt(490/(39π)) | Derived exact source result | Real.pi retained; no false =2 identity |
| Bounds 1.9998<f₁<1.9999 | Pure mathematics / derived strengthening | Mathlib proven π bounds, not claimed source precision |
| RoundsToWholeHz | Formalization/rounding choice | Nearest integer Hz, ties toward +∞; consistent with printed 2 |
| printed_fundamental_not_exact / source_mode_exact | Derived source-solution audit | f₁≠2; exact family n√(490/(39π)) |
| mode_approximation_error | Derived approximation bound | Error <n/5000; no uniform-Hz rounding claim for all modes |
| n : ℕ+ | Model domain | Zero is excluded from physical modes |
| WithDim, Dimension, Dimensionful, named base units, Frequency | Existing Physlib unit system | Actual products/divisions/unit conversion and inverse-time output type |
| Mechanical CGS unit choice / dyne wrapper | P13-local source-unit interpretation | Existing LTMCT machinery; no new unit framework or electromagnetic-CGS claim |
| Root half-power dimension proofs / local expression wrappers | Dimensional verification | Existing rational dimension powers; no general quantity sqrt/covariance API added |
| typed_source_CGS / typed_source_SI | Dimensional and numerical consistency | Both unit systems agree with the actual Candidate result |
| Independent VibratingStringExamples | Reusable-layer validation | No P13 material/source constants |

The new PhyslibTemp layer contains only generic ideal string mechanics. Cylinder
geometry, unit conversions, steel density and the printed approximation remain
local. The mathematical primitive Real.sqrt does not itself supply the physical
string law; that law is explicitly adopted and classified in the reusable model.
