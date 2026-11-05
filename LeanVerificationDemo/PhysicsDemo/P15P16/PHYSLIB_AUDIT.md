# P15/P16 pinned-library and source-solution audit

## Revisions and evidence

Lean `leanprover/lean4:v4.35.0`; Mathlib
`56a005855ea17e0b0958f73ec801ae140b0a1679`; Physlib
`96a6bc5e3c50a2856c64a6c9951c0a1c23790b58`. Actual checkout HEADs agree with
the repository pins. No pins changed. Both source screenshots were directly
opened and identified before assigning figure metadata or drawing.

Searches included whole stable/Alpha trees, with focused optics, electromagnetic
and classical-wave contexts. Alpha was only secondary reference:

```bash
rg --files Physlib/Optics
rg -ni 'interferen|coheren|path.differ|constructive|destructive|lloyd|phase.shift|phase.revers|optical.phase' Physlib PhyslibAlpha
rg -ni 'superposition|poynting|intensity|time.average|phase.difference' Physlib/Electromagnetism Physlib/ClassicalMechanics/WaveEquation Physlib/Optics
rg -n 'cos_eq_one_iff|cos_add_pi|cos_int_mul_two_pi|cos_int_mul_two_pi_add_pi' Mathlib/Analysis/SpecialFunctions/Trigonometric/Basic.lean
rg --files LeanVerificationDemo/PhyslibTemp/Optics
```

Read stable Optics/Basic, Wavelength, Frequency, Polarization/Basic; relevant
EM/Vacuum/HarmonicWave and IsPlaneWave context; classical WaveEquation/HarmonicWave;
existing PhyslibTemp Reflection/Refraction; neighboring matching phase/coherence
declarations. No suitable classical coherent two-beam interference/extrema API
was found by these semantic searches, not just by an absent filename.

## Actual existing support and mismatches

| File / declaration | Exact relevant type or status | Decision |
| --- | --- | --- |
| `Physlib/Optics/Wavelength.lean:70`, global `Wavelength` | `abbrev Wavelength : Type := WithDim L𝓭 ℝ≥0` | Actually reused in ScreenData and the shared optical phase |
| Same, `Wavelength.ofFrequency` | `(c : WithDim (L𝓭*T𝓭⁻¹) ℝ≥0) (ν : Frequency) (_ν_pos : 0 < ν.val) : Wavelength` | Real formal wavelength API, but frequency conversion is not needed here |
| Same:200, `speedEqWavelengthMulFrequency_isDimensionallyCorrect` | Existing formal dimension check for λν=c | Related support; not an interference model |
| `Physlib/Optics/Basic.lean` | Documentation placeholder | Not a formal reflection/interference law |
| `Physlib/Optics/Polarization/Basic.lean` | Documentation context, no applicable two-beam phase/intensity theorem found | Do not claim missing all optics merely because this API is absent |
| `Physlib/Electromagnetism/Vacuum/HarmonicWave.lean:78`, `Electromagnetism.ElectromagneticPotential.harmonicWaveX` | `(𝓕 : FreeSpace) (k : ℝ) (E₀ φ : Fin d → ℝ) : ElectromagneticPotential d.succ` | Formal free-space wave with phase inputs, not a detector/interference fringe criterion |
| Same:444, `harmonicWaveX_isExtrema` | `(𝓕) (k) (hk : k ≠ 0) (E₀ φ : Fin d → ℝ) : IsExtrema 𝓕 (harmonicWaveX 𝓕 k E₀ φ) 0` | Actual formal Maxwell/free-space result, not an informal statement; unnecessary field-level dependency here |
| `Physlib/ClassicalMechanics/WaveEquation/HarmonicWave.lean:77` | General Fourier superposition is a TODO | Not a proved time-averaged optical intensity API |
| `Physlib/Particles/FlavorPhysics/CKMMatrix/Basic.lean` and neutrino phase shifts | Formal matrix rephasings | Physically different from optical path phase; not reused |
| `PhyslibAlpha/QuantumMechanics/QuantumHarmonicOscillator.lean` | Alpha-only coherent-state amplitudes/Fock space | Different quantum model; no Alpha import |
| Local `PhyslibTemp/Optics/Reflection.lean`, `PlaneMirror.reflect` | Ideal geometric direction reflection over Mathlib orthogonal reflection | Inspected P11 precedent; does not determine optical phase π or Fresnel coefficients |

No claim is made that Physlib lacks wave equations, electromagnetic phases or
generic mathematical superposition. The scoped gap is a small classical
coherent two-beam phase/intensity/extrema semantic API.

## Reused Mathlib and units

Paths below are relative to Mathlib unless marked Physlib:

```lean
-- Analysis/SpecialFunctions/Trigonometric/Basic.lean:320
Real.cos_add_pi (x : ℝ) : Real.cos (x + Real.pi) = -Real.cos x
-- Same:545
Real.cos_eq_one_iff (x : ℝ) :
  Real.cos x = 1 ↔ ∃ n : ℤ, (n : ℝ) * (2 * Real.pi) = x
-- Same:348,402
Real.cos_int_mul_two_pi (n : ℤ) : Real.cos (n * (2 * Real.pi)) = 1
Real.cos_int_mul_two_pi_add_pi (n : ℤ) : Real.cos (n * (2 * Real.pi) + Real.pi) = -1
```

`Real.cos_le_one`/`neg_one_le_cos` give intensity bounds for positive beam
amplitudes. Integer arithmetic/casts, positive cancellation and exact ring/field
algebra solve phase orders. `Real.sq_sqrt` and root nonnegativity prove exact
path-square geometry; `Real.pi_pos` permits phase cancellation.

Physlib `Units/WithDim/Basic.lean` supplies `WithDim`, typed HMul/HDiv, equal-
dimension addition, real scalar multiplication, `WithDim.cast` and extensionality.
`Units/Dimension.lean` supplies the actual dimension algebra. `Units.lean` checks
`L*L/L=L` and `L/L=1`, and ties the typed spacing, shift, geometric path model
and optical phase to the exact scalar expressions used in Candidate. No new
unit framework, numerical conversion or source uncertainty is introduced.

## New reusable physical layer

Namespace `LeanVerificationDemo.PhyslibTemp.Optics.TwoBeamInterference`:

```lean
phase (wavelength : Wavelength) (pathDifference offset : ℝ) : ℝ
intensity (a b θ : ℝ) : ℝ
IsMaximum (θ : ℝ) : Prop  -- cos θ = 1
IsMinimum (θ : ℝ) : Prop  -- cos θ = -1
```

The physical model adopts phase `2πδ/λ+offset` and normalized intensity
`a²+b²+2ab cos θ`. Theorems prove bounds, intensity-extrema equivalences for
positive amplitudes, integer/half-integer phase and path orders, π reversal of
extrema and the half-wavelength path offset. No Lloyd, screen, paraxial geometry,
reflection-material phase or computed spacing is in the reusable module.

This is not a qualitative channel-decomposition framework like the earlier
P06-local model: it is the source-independent quantitative coherent two-beam
law, with physical intensity bounds and independently checked examples. Young's
slits, ideal interferometers and thin-film phase comparisons are independent
reuse cases. See TwoBeamInterference.md for adopted-law limits/upstream path.

Actual Candidate dependencies:

- 764 validity → phase_order_location → `phase_order_iff`; full bright-lattice
  validity → `maximum_iff` → Mathlib cosine classification.
- 766 validity → phase_translation → reflection_path_offset →
  `half_wavelength_adds_pi`; separately derived extrema interchange → `maximum_pi_iff`/`minimum_pi_iff`
  → `Real.cos_add_pi`.
- Both use the shared **solution-side** exact range-square derivation before
  simplifying the adopted denominator closure. No Candidate answer is a premise.

The positive-parameter independent examples use a different wavelength and unequal
amplitudes, including nonzero destructive intensity and rejection of phase π as
a maximum. This verifies a physical API beyond an unused import or one-line alias.

## Approximation, reflection and source terminology audit

Finite exact geometry gives `(d₂+d₁)(d₂−d₁)=2hl`, but the center sum is strictly
greater than 2D for l>0. The far-field/near-axis **model** replaces the denominator
by 2D; Candidate derives its linear path law. This is not an exact center Taylor
derivative for finite separation, nor a theorem of accuracy under all positive
parameters. There is no invented quantitative threshold for ≫.

The ordinary equal-phase reference is taken from the supplied solution, not from
coherence alone. The Lloyd π offset is also an adopted supplied-solution optical
assumption, independent of geometric reflection. Generic phase reversal swaps
extrema for any path model, while a constant spatial half-period translation
uses the shared linear paraxial model. Full finite-aperture visibility, O's grazing
limit, nonparaxial nonuniform fringes and real reflection coefficients are outside
scope and explicitly documented.

Bright-to-bright and dark-to-dark spacing is P=λD/l. Adjacent bright/dark centers
are P/2 apart. Lloyd maxima occupy the ordinary half-integer sites, giving a P/2
offset; a full P shift would leave the pattern unchanged. The source phrase
“width of a light (or dark) band” is interpreted through that derived center
offset; a continuous-intensity band has no intrinsic sharp edge without a threshold.
Unwrapped phase translation fixes one representative; physical intensity shifts
are understood modulo P, so no unjustified absolute uniqueness is claimed.

## Pairing and direct-image policy

Fig. 253 = user screenshot 15-43-07, Fig. 255 = 15-43-52, identified by actually
opening both files, not by guessing filenames. Their SHA-256 values and observed
source facts are recorded separately. No solution figure was supplied or used.
The new SVGs are drawn from the original images, not caption inputs or source
scan copies. The Fig. 253 drawing excludes solution-only C/hₖ/d₁/d₂/rays; Fig. 255
retains its original direct/reflected rays and dashed virtual-source guides.

Problem766 and Candidate766 import neither Problem764 nor Candidate764. Their
comparison defines both phases directly. The shared helper contains geometric
derivations, not a previous-problem answer. The runner's only extension is
list-or-object configuration discovery; each selector has its own Problem,
Candidate and annotated proof while sharing the explicitly paired Verify file.
