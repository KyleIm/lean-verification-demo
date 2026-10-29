import LeanVerificationDemo.PhysicsDemo.P13.Candidate
import Physlib.Optics.Frequency

set_option backward.isDefEq.respectTransparency false

namespace LeanVerificationDemo.PhysicsDemo.P13.Units
open Dimension LTMCTUnitChoices CarriesDimension UnitDependent NNReal
open LeanVerificationDemo.PhyslibTemp.ClassicalMechanics

abbrev areaDim : Dimension LTMCTDimensionBase := L𝓭 ^ (2 : ℕ)
abbrev densityDim : Dimension LTMCTDimensionBase := M𝓭 / L𝓭 ^ (3 : ℕ)
abbrev linearDim : Dimension LTMCTDimensionBase := M𝓭 / L𝓭
abbrev forceDim : Dimension LTMCTDimensionBase := M𝓭 * L𝓭 / T𝓭 ^ (2 : ℕ)
abbrev velocityDim : Dimension LTMCTDimensionBase := L𝓭 / T𝓭
abbrev radicalDim : Dimension LTMCTDimensionBase := L𝓭 ^ (2 : ℕ) / T𝓭
abbrev frequencyDim : Dimension LTMCTDimensionBase := T𝓭⁻¹
abbrev Length := WithDim L𝓭 ℝ
abbrev Mass := WithDim M𝓭 ℝ
abbrev Duration := WithDim T𝓭 ℝ
abbrev Force := WithDim forceDim ℝ
abbrev Density := WithDim densityDim ℝ
abbrev LinearDensity := WithDim linearDim ℝ
abbrev Velocity := WithDim velocityDim ℝ
abbrev RealFrequency := WithDim frequencyDim ℝ

lemma linear_density_dimension : densityDim * areaDim = linearDim := by decide

lemma wave_speed_root_dimension : (forceDim / linearDim) ^ (1 / 2 : ℚ) = velocityDim := by
  ext b
  cases b <;> norm_num [forceDim, linearDim, velocityDim, Dimension.div_exponent,
    Dimension.mul_exponent, Dimension.npow_exponent, Dimension.qpow_exponent]
  all_goals
    apply Exponent.coe_inj.mp
    norm_num [Exponent.ofRat]

lemma volume_density_root_dimension : (forceDim / densityDim) ^ (1 / 2 : ℚ) = radicalDim := by
  ext b
  cases b <;> norm_num [forceDim, densityDim, radicalDim, Dimension.div_exponent,
    Dimension.mul_exponent, Dimension.npow_exponent, Dimension.qpow_exponent]
  all_goals
    apply Exponent.coe_inj.mp
    norm_num [Exponent.ofRat]

lemma frequency_dimension : velocityDim / L𝓭 = frequencyDim := by decide

lemma source_formula_dimension : radicalDim / (L𝓭 * L𝓭) = frequencyDim := by decide

/-- The pinned WithDim has no quantity sqrt operator. Locally tag Real.sqrt
with the upstream half-power dimension and cast using the proved identity.
This is a dimension/value check, not a new general unit or covariance API. -/
noncomputable def waveSpeedQuantity (T : Force) (μ : LinearDensity) : Velocity :=
  (⟨Real.sqrt (T / μ).val⟩ : WithDim ((forceDim / linearDim) ^ (1 / 2 : ℚ)) ℝ).cast
    wave_speed_root_dimension

noncomputable def volumeDensityRadical (T : Force) (ρ : Density) : WithDim radicalDim ℝ :=
  (⟨Real.sqrt (T / ((Real.pi : ℝ) • ρ)).val⟩ :
    WithDim ((forceDim / densityDim) ^ (1 / 2 : ℚ)) ℝ).cast volume_density_root_dimension

noncomputable def frequencyQuantity (L : Length) (T : Force) (μ : LinearDensity) : RealFrequency :=
  (waveSpeedQuantity T μ / ((2 : ℝ) • L)).cast frequency_dimension

noncomputable def sourceFormulaQuantity (L d : Length) (T : Force) (ρ : Density) : RealFrequency :=
  (volumeDensityRadical T ρ / (L * d)).cast source_formula_dimension

/-- Coherent CGS uses upstream named centimetres, grams and seconds. The charge
and temperature slots are irrelevant to every dimension used here. -/
noncomputable def CGS : LTMCTUnitChoices :=
  { SI with length := LengthUnit.centimeters, mass := MassUnit.grams }
noncomputable def mmSystem : LTMCTUnitChoices := { SI with length := LengthUnit.millimeters }

noncomputable def lengthQuantity (data : StringData) : Dimensionful Length :=
  toDimensionful CGS ⟨data.lengthCm⟩
noncomputable def diameterQuantity (data : StringData) : Dimensionful Length :=
  toDimensionful mmSystem ⟨data.diameterMm⟩
noncomputable def tensionQuantity (data : StringData) : Dimensionful Force :=
  toDimensionful CGS ⟨data.tensionDyn⟩
noncomputable def densityQuantity (data : StringData) : Dimensionful Density :=
  toDimensionful CGS ⟨data.densityGcm3⟩

/-- No named dyne was found upstream; this local source-unit definition is
one coherent CGS force, not an invented force dimension. -/
noncomputable def dyne : Dimensionful Force := toDimensionful CGS ⟨1⟩

lemma coordinate_at {d : Dimension LTMCTDimensionBase} (units : LTMCTUnitChoices)
    (q : WithDim d ℝ) : (toDimensionful units q) units = q :=
  (toDimensionful units).symm_apply_apply q

/-- Short local adapter for the existing upstream change-of-units law. -/
lemma converted_value (u v : LTMCTUnitChoices) (d : Dimension LTMCTDimensionBase) (x : ℝ) :
    ((toDimensionful u (⟨x⟩ : WithDim d ℝ)) v).val = (u.dimScale v d : ℝ) * x := by
  rw [CarriesDimension.toDimensionful_apply_apply, WithDim.smul_val,
    NNReal.smul_def, smul_eq_mul]
  rw [WithDim.dim_apply]

lemma diameter_in_CGS (data : StringData) :
    diameterQuantity data CGS = (⟨diameterCm data⟩ : Length) := by
  apply WithDim.ext
  unfold diameterQuantity
  rw [converted_value]
  norm_num [LTMCTUnitChoices.dimScale_apply, mmSystem, CGS,
    LengthUnit.millimeters, LengthUnit.centimeters, PositiveRealUnitCore.ratio, NNReal.coe_pow, NNReal.coe_rpow,
    NNReal.coe_mul, NNReal.coe_div, diameterCm]
  simp only [NNReal.toReal, NNReal.coe_rpow, NNReal.coe_div, NNReal.coe_mul, NNReal.coe_pow] <;> norm_num
  <;> ring

lemma dyne_in_SI : dyne SI = (⟨1 / 100000⟩ : Force) := by
  apply WithDim.ext
  unfold dyne
  rw [converted_value]
  norm_num [LTMCTUnitChoices.dimScale_apply, CGS, SI, forceDim,
    M𝓭, LengthUnit.centimeters, MassUnit.grams,
    PositiveRealUnitCore.ratio, NNReal.coe_pow, NNReal.coe_rpow, NNReal.coe_mul, NNReal.coe_div]
  simp only [NNReal.toReal, NNReal.coe_rpow, NNReal.coe_div, NNReal.coe_mul, NNReal.coe_pow] <;> norm_num

lemma source_in_SI (data : StringData) (source : SourceData data) :
    lengthQuantity data SI = (⟨1 / 2⟩ : Length) ∧
    diameterQuantity data SI = (⟨1 / 1000⟩ : Length) ∧
    tensionQuantity data SI = (⟨49 / 2000⟩ : Force) ∧
    densityQuantity data SI = (⟨7800⟩ : Density) := by
  constructor
  · apply WithDim.ext
    unfold lengthQuantity
    rw [converted_value, source.length_value]
    norm_num [LTMCTUnitChoices.dimScale_apply, CGS, SI,
      LengthUnit.centimeters, PositiveRealUnitCore.ratio, NNReal.coe_pow, NNReal.coe_rpow, NNReal.coe_mul, NNReal.coe_div]
    simp only [NNReal.toReal, NNReal.coe_rpow, NNReal.coe_div, NNReal.coe_mul, NNReal.coe_pow] <;> norm_num
  constructor
  · apply WithDim.ext
    unfold diameterQuantity
    rw [converted_value, source.diameter_value]
    norm_num [LTMCTUnitChoices.dimScale_apply, mmSystem, SI,
      LengthUnit.millimeters, PositiveRealUnitCore.ratio, NNReal.coe_pow, NNReal.coe_rpow, NNReal.coe_mul, NNReal.coe_div]
    simp only [NNReal.toReal, NNReal.coe_rpow, NNReal.coe_div, NNReal.coe_mul, NNReal.coe_pow] <;> norm_num
  constructor
  · apply WithDim.ext
    unfold tensionQuantity
    rw [converted_value, source.tension_value]
    norm_num [LTMCTUnitChoices.dimScale_apply, CGS, SI, forceDim,
      M𝓭, LengthUnit.centimeters, MassUnit.grams,
      PositiveRealUnitCore.ratio, NNReal.coe_pow, NNReal.coe_rpow, NNReal.coe_mul, NNReal.coe_div]
    simp only [NNReal.toReal, NNReal.coe_rpow, NNReal.coe_div, NNReal.coe_mul, NNReal.coe_pow] <;> norm_num
  · apply WithDim.ext
    unfold densityQuantity
    rw [converted_value, source.density_value]
    norm_num [LTMCTUnitChoices.dimScale_apply, CGS, SI, densityDim,
      M𝓭, LengthUnit.centimeters, MassUnit.grams,
      PositiveRealUnitCore.ratio, NNReal.coe_pow, NNReal.coe_rpow, NNReal.coe_mul, NNReal.coe_div]
    simp only [NNReal.toReal, NNReal.coe_rpow, NNReal.coe_div, NNReal.coe_mul, NNReal.coe_pow] <;> norm_num


lemma dyne_definition :
    dyne CGS = ((toDimensionful CGS (⟨1⟩ : Mass) CGS *
      toDimensionful CGS (⟨1⟩ : Length) CGS) /
      (toDimensionful CGS (⟨1⟩ : Duration) CGS *
       toDimensionful CGS (⟨1⟩ : Duration) CGS)).cast
       (show (M𝓭 * L𝓭) / (T𝓭 * T𝓭) = forceDim by
         simp [forceDim, pow_two]) := by
  simp only [dyne, coordinate_at]
  apply WithDim.ext
  norm_num [WithDim.cast, WithDim.withDim_hMul_val, ← WithDim.val_div_val]

/-- Reuse the named upstream nonnegative Frequency alongside the real-valued
quantity arithmetic; both carry inverse-time dimension. -/
noncomputable def physicalFrequency (data : StringData) (n : ℕ+) : Frequency :=
  ⟨⟨naturalFrequency data n, (FixedString.frequency_pos (fixedString data) n).le⟩⟩

/-- The dimension-tagged mode law uses the same real formula as the model. -/
lemma typed_fundamental (data : StringData) :
    frequencyQuantity (⟨data.lengthCm⟩ : Length) (⟨data.tensionDyn⟩ : Force)
      (⟨linearDensity data⟩ : LinearDensity) = (⟨fundamental data⟩ : RealFrequency) := by
  rfl

lemma typed_source_formula (data : StringData) :
    sourceFormulaQuantity (⟨data.lengthCm⟩ : Length) (⟨diameterCm data⟩ : Length)
      (⟨data.tensionDyn⟩ : Force) (⟨data.densityGcm3⟩ : Density) =
        (⟨fundamental data⟩ : RealFrequency) := by
  apply WithDim.ext
  change Real.sqrt (data.tensionDyn / (Real.pi * data.densityGcm3)) /
    (data.lengthCm * diameterCm data) = fundamental data
  rw [Candidate.fundamental_formula]
  ring

lemma typed_source_CGS (data : StringData) :
    sourceFormulaQuantity (lengthQuantity data CGS) (diameterQuantity data CGS)
      (tensionQuantity data CGS) (densityQuantity data CGS) =
        (⟨fundamental data⟩ : RealFrequency) := by
  rw [show lengthQuantity data CGS = (⟨data.lengthCm⟩ : Length) from coordinate_at _ _,
    diameter_in_CGS,
    show tensionQuantity data CGS = (⟨data.tensionDyn⟩ : Force) from coordinate_at _ _,
    show densityQuantity data CGS = (⟨data.densityGcm3⟩ : Density) from coordinate_at _ _]
  exact typed_source_formula data

/-- Independent SI evaluation of the converted source quantities agrees with
the primary coherent-CGS result; no frequency conversion factor is omitted. -/
lemma typed_source_SI (data : StringData) (source : SourceData data) :
    sourceFormulaQuantity (lengthQuantity data SI) (diameterQuantity data SI)
      (tensionQuantity data SI) (densityQuantity data SI) =
        (⟨fundamental data⟩ : RealFrequency) := by
  have h := source_in_SI data source
  rw [h.1, h.2.1, h.2.2.1, h.2.2.2]
  apply WithDim.ext
  change Real.sqrt ((49 / 2000 : ℝ) / (Real.pi * 7800)) /
    ((1 / 2) * (1 / 1000)) = fundamental data
  have hp : 0 ≤ fundamental data := (FixedString.fundamental_pos (fixedString data)).le
  apply (sq_eq_sq₀ (by positivity) hp).mp
  rw [div_pow, Real.sq_sqrt (by positivity), Candidate.fundamental_squared_source data source]
  field_simp [Real.pi_ne_zero]
  <;> ring

lemma CGS_frequency_scale : (CGS.dimScale SI frequencyDim : ℝ) = 1 := by
  simp [LTMCTUnitChoices.dimScale_apply, CGS, frequencyDim]

end LeanVerificationDemo.PhysicsDemo.P13.Units
