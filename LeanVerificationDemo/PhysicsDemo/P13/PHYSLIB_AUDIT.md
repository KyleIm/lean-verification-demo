# P13 pinned-library and source-solution audit

## Revisions and search evidence

Inspected the repository's pinned Physlib
`96a6bc5e3c50a2856c64a6c9951c0a1c23790b58` and Mathlib
`56a005855ea17e0b0958f73ec801ae140b0a1679` (Lean 4.35.0).
No dependency pin changed. Searches covered the whole stable and Alpha trees,
not just a possible vibrating-string filename:

```bash
rg --files Physlib PhyslibAlpha | rg -i 'waveequation|harmonicwave|standing|string|normalmode'
rg -ni 'fixed.?string|standing.?wave|linear.?density|mass.per.length|string.tension|normal.mode|fixed.end|wave.speed' Physlib PhyslibAlpha
rg -ni 'dyne|dynes|gram|centimeter|millimeter' Physlib/Units Physlib/ClassicalMechanics/Mass Physlib/SpaceAndTime
rg -n 'sqrt|rpow' Physlib/Units/WithDim/*.lean
rg -n 'WaveEquation|wave equation|standing wave' Mathlib/Analysis
```

Read both `Physlib/ClassicalMechanics/WaveEquation/Basic.lean` and
`HarmonicWave.lean` in context. Also inspected relevant hits in
`Electromagnetism/Vacuum/HarmonicWave.lean`, the quantum harmonic oscillator,
rigid-body small oscillations and Alpha's tight-binding chain. “StringTheory”
files concern particle/string theory, not the mechanical string here.

## Actual upstream formal wave declarations

Paths below are relative to Physlib. These are real Lean definitions/theorems,
not documentation-only statements. Namespace: `ClassicalMechanics`.

```lean
-- ClassicalMechanics/WaveEquation/Basic.lean:60
WaveEquation {d} (f : Time → Space d → EuclideanSpace ℝ (Fin d))
    (t : Time) (x : Space d) (c : ℝ) : Prop :=
  c^2 • Δᵥ (f t) x - ∂ₜ (fun t => ∂ₜ (fun t => f t x) t) t = 0

-- Same file:77
planeWave (f₀ : ℝ → EuclideanSpace ℝ (Fin d)) (c : ℝ) (s : Space.Direction d) :
  Time → Space d → EuclideanSpace ℝ (Fin d)

-- Same file:277
planeWave_waveEquation (c : ℝ) (s : Space.Direction d)
    (f₀ : ℝ → EuclideanSpace ℝ (Fin d)) (hf₀ : ContDiff ℝ 2 f₀) :
  ∀ t x, WaveEquation (planeWave f₀ c s) t x c

-- ClassicalMechanics/WaveEquation/HarmonicWave.lean:37
harmonicWave (a g : ℝ → Space d → ℝ) (ω : WaveVector d → ℝ) (k : WaveVector d) :
  Time → Space d → ℝ
```

The plane wave is `f₀(⟪x,s.unit⟫−ct)`. The harmonic definition uses
`a(ωk,r) cos(ωk t−g(ωk,r))`: ω is **angular** frequency. Its formal
`transverseHarmonicPlaneWave_eq_planeWave` theorem (line 58) relates particular
travelling-wave representations. It does not quantize a bounded fixed string.
The file's general-disturbance/Fourier statement (line 77) is a **TODO**, not a
proved spectral decomposition.

The existing PDE material takes c as an input; it does not establish
`c²=tension/linearDensity`. No applicable stable declaration for fixed-end
mechanical-string frequencies, linear mass density or the combined cylindrical
formula was found in the whole-tree searches.

Related but insufficient results are kept distinct:

- `ClassicalMechanics/RigidBody/Basic.lean:336`,
  `RigidBody.small_oscillations_about_equilibrium`, is an **informal_lemma**.
  It is not a formal normal-mode API and is not used.
- `QuantumMechanics/HarmonicOscillator/Basic.lean` has prescribed natural
  oscillator frequencies, not the fixed-string boundary spectrum.
- Alpha `CondensedMatter/TightBindingChain/Current/Eigenstates.lean` formally
  uses standing sine waves/current eigenstates of a discrete quantum chain.
  That is not the classical tension/linear-density string law. No Alpha import
  is introduced.

## PDE/reusable-layer decision

The upstream travelling-wave theorem is useful infrastructure but does not
provide the physical coefficient law, fixed-boundary quantization or spectral
completeness. One could build standing waves and new boundary adapters on top
of it; that does not automatically derive the complete mode law required here.
This implementation chooses the explicitly permitted ideal-model boundary
instead of adding a separation-of-variables/eigenfunction framework.

`PhyslibTemp/ClassicalMechanics/VibratingString.lean` now introduces
`FixedString`, namespace `LeanVerificationDemo.PhyslibTemp.ClassicalMechanics`:

```lean
FixedString                    -- length, tension, linearDensity, each >0
FixedString.waveSpeed s         -- sqrt(s.tension/s.linearDensity)
FixedString.fundamental s       -- waveSpeed/(2*length)
FixedString.frequency s (n : ℕ+) -- n/(2*length)*waveSpeed
```

The speed and allowed-mode laws are **adopted reusable physical-model
definitions**, not claimed PDE-derived theorems. Positivity, c²=T/μ, harmonic
scaling, the fundamental formula and wavelength relation are proved from that
model. `modeShape` uses sin(nπx/L); its endpoint zeros are proved, without
claiming PDE completeness or deriving every permissible eigenvalue.

The abstraction is source-independent and useful for tension/length tuning,
comparing harmonics, inferring linear density and other string geometries.
It has no steel, cylinder, source units or P13 constants. Independent examples
and adjacent design notes validate/document the boundary and possible upstream
path. No unused PDE import is presented as proof of a missing physical law.

## Mathlib reused

| File/declaration | Exact relevant statement/use |
| --- | --- |
| `Analysis/Real/Sqrt.lean`, `Real.sq_sqrt` | `0≤x → (sqrt x)^2=x`; positive square-root simplification |
| Same file, `Real.sqrt_pos`, `sqrt_nonneg` | Positive/nonnegative roots |
| `Algebra/Order/GroupWithZero/Basic.lean`, `sq_eq_sq₀` | For nonnegative a,b, `a²=b² ↔ a=b` |
| `Analysis/SpecialFunctions/Trigonometric/Basic.lean`, `Real.sin_nat_mul_pi` | `sin(nπ)=0`; fixed-end sine profile |
| `Analysis/Real/Pi/Bounds.lean:178,184` | `Real.pi_gt_d6 : 3.141592 < π`; `pi_lt_d6 : π < 3.141593` |
| `Data/PNat/Basic.lean` | Positive-natural indexing; no physical mode zero |

No floating-point approximation or native-evaluation proof is used.

## Units: actual pinned Physlib surface

The primary coordinates are coherent **mechanical CGS**. The original mm
diameter is explicitly converted before arithmetic. LTMCT is sufficient for
mechanical dimensions; unused charge/temperature choices do not assert an
electromagnetic CGS convention.

| File/declaration | Type/role |
| --- | --- |
| `Units/WithDim/Basic.lean:33`, `WithDim` | `WithDim d M`, numerical `val : M` |
| Same file:248,318 | Heterogeneous multiplication/division producing product/quotient dimensions |
| Same file:356, `WithDim.cast` | Cast between dimensions using a proved equality |
| `Units/Dimension.lean:147,151` | Rational dimension powers and `Dimension.qpow_exponent` |
| `Units/Exponent.lean`, `Exponent.coe_inj` and rational coercion lemmas | Exact half-exponent arithmetic |
| `Units/Basic.lean:102,435,460` | `LTMCTUnitChoices.dimScale`; `CarriesDimension.toDimensionful : M ≃ Dimensionful M`; existing change-of-unit law |
| `SpaceAndTime/Space/LengthUnit.lean:101,104` | Named `millimeters`, `centimeters` |
| `ClassicalMechanics/Mass/MassUnit.lean:77` | Named `grams` |
| `Optics/Frequency.lean:50` | `Frequency := WithDim T𝓭⁻¹ ℝ≥0`, reused for nonnegative physical outputs |

No named dyne API was found. A P13-local dyne is one coherent CGS Force quantity;
`dyne_definition` proves its g·cm/s² meaning and `dyne_in_SI` proves 10⁻⁵ N.
`diameter_in_CGS` verifies the native mm conversion. `source_in_SI` proves all
four conversions: 0.5 m, 0.001 m, 0.0245 N and 7800 kg/m³.

The pinned WithDim tree has no dimensionful square-root operator. `Units.lean`
uses existing rational dimension powers to prove root dimensions, and two
local expression wrappers tag `Real.sqrt` accordingly. This is not a new unit
framework or a claimed generic square-root covariance theorem. Typed formulas
are connected to the Candidate, and `typed_source_CGS` / `typed_source_SI`
prove that both coherent evaluations give the same actual fundamental. The
inverse-time CGS/SI scale factor is also proved equal to 1.

## Critical source-solution arithmetic audit

Using 1 mm=0.1 cm and the four original values, Candidate proves

```text
f₁² = 490/(39π)
f₁ = sqrt(490/(39π))
1.9998 < f₁ < 1.9999 < 2.
```

Thus the printed `f₁=2` is false as an exact equality with Real.pi. Equality
would require π=245/78. Verification checks that π=3.14 and π=22/7 do not make
the square exactly 4 either. There is no evidence here for a hidden source π
convention; the formalization does not invent one.

The integer answer is interpreted by an explicit nearest-whole-Hz half-open
band `[k−1/2,k+1/2)`. The exact family is n√(490/(39π)), n positive. The printed
2n family is justified as a coefficient approximation with error <n/5000 Hz,
not an exact identity or unit-Hz rounding claim at every arbitrarily high mode.
The tight bound is a derived strengthening; the source is not credited with
four-decimal precision or an explicit rounding rule.

## Final split

```text
Stable Physlib:
  audited formal general waves; reused units, conversions and Frequency

New PhyslibTemp:
  source-independent ideal FixedString wave-speed/fixed-mode model
  proved harmonic/positivity/wavelength properties and boundary compatibility

P13-local:
  native source parameters, cylinder geometry, linear density
  source-unit wrappers/conversions, source formula and numerical specialization
  rounding interpretation and corrected approximate answer

Pure mathematics:
  square roots, positive cancellation, π bounds and exact rational inequalities
```

## Witness-producing specification and dependency audit

The refined `Problem.lean` asks for `∃! freq, IsNaturalFrequencySolution data freq`.
The success criterion is pointwise agreement with `(fixedString data).frequency`;
that model is constructed only from source-native length/tension, circular area
and material density. The former `ExactSpectrum`/`HarmonicSpectrum` target
predicates were removed. Rounding moved to `Candidate.RoundsToWholeHz`; neither
rounding nor a numerical answer occurs in the trusted target.

The exact returned family is constructed in `Candidate.solutionFrequency`.
Its validity depends on `source_mode_exact` → `natural_harmonics` and
`fundamental_exact_source` → `fundamental_squared_source` → `fundamental_formula`
→ `cylindrical_frequency` → `wave_speed_from_volume_density`.
These invoke actual reusable `FixedString.harmonic_scaling`, `first_frequency`,
`frequency`, `waveSpeed_squared` and `waveSpeed_pos` declarations. Thus
**P13 Candidate genuinely depends on VibratingString: YES**. No local copy of
the fixed-string mode law replaces that dependency. Function extensionality
proves uniqueness within this adopted model; no PDE-spectrum completeness is
inferred. Existing unit conversions/dimensional bridges and the independent
VibratingString examples remain unchanged.

Verification checks the semantic witness and uniqueness, and rejects the exact
`2n` family using the proved fundamental non-equality. Numerical bounds and the
approximation remain separately verified Candidate theorems. The reusable
module contains no P13 geometry, unit-conversion or source constants.
