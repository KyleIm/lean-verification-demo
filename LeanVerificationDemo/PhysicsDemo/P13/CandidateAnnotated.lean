import LeanVerificationDemo.PhysicsDemo.P13.Problem

namespace LeanVerificationDemo.PhysicsDemo.P13.CandidateAnnotated
open LeanVerificationDemo.PhyslibTemp.ClassicalMechanics

-- [derived geometry] Convert radius=d/2 into the diameter-area expression.
lemma circular_area (data : StringData) :
    areaCm2 data = Real.pi * diameterCm data ^ 2 / 4 := by
  unfold areaCm2 radiusCm
  ring

/-- Volume density × circular area becomes mass per unit length. -/
-- [derived physics/geometry] Uniform volume density times area gives μ.
lemma linear_density_formula (data : StringData) :
    linearDensity data = Real.pi * data.densityGcm3 * diameterCm data ^ 2 / 4 := by
  rw [linearDensity, circular_area]
  ring

-- [reusable physics + pure mathematics] Use c=√(T/μ), then the cylinder relation.
lemma wave_speed_from_volume_density (data : StringData) :
    (fixedString data).waveSpeed = (2 / diameterCm data) *
      Real.sqrt (data.tensionDyn / (Real.pi * data.densityGcm3)) := by
  have hd := diameterCm_pos data
  have hs : 0 ≤ data.tensionDyn / (Real.pi * data.densityGcm3) :=
    (div_pos data.tension_pos (mul_pos Real.pi_pos data.density_pos)).le
  apply (sq_eq_sq₀ (FixedString.waveSpeed_pos _).le
    (mul_nonneg (div_nonneg (by norm_num) hd.le) (Real.sqrt_nonneg _))).mp
  rw [FixedString.waveSpeed_squared, mul_pow, Real.sq_sqrt hs]
  change data.tensionDyn / linearDensity data = _
  rw [linear_density_formula]
  field_simp [Real.pi_ne_zero, data.density_pos.ne', hd.ne']
  <;> ring

/-- Reusable n c/(2L) plus cylindrical geometry gives the source formula.
It is a conclusion, never a SourceData equality premise. -/
-- [source-solution physical model / reusable physics] Apply the adopted fixed-end
-- mode law; this implementation does not derive that law from the PDE.
lemma cylindrical_frequency (data : StringData) (n : ℕ+) :
    naturalFrequency data n = (n : ℝ) / (data.lengthCm * diameterCm data) *
      Real.sqrt (data.tensionDyn / (Real.pi * data.densityGcm3)) := by
  unfold naturalFrequency
  rw [FixedString.frequency, wave_speed_from_volume_density]
  change (n : ℝ) / (2 * data.lengthCm) * ((2 / diameterCm data) *
    Real.sqrt (data.tensionDyn / (Real.pi * data.densityGcm3))) = _
  field_simp [data.length_pos.ne', (diameterCm_pos data).ne']
  <;> ring

lemma fundamental_formula (data : StringData) :
    fundamental data = (1 / (data.lengthCm * diameterCm data)) *
      Real.sqrt (data.tensionDyn / (Real.pi * data.densityGcm3)) := by
  have h := cylindrical_frequency data 1
  change (fixedString data).frequency 1 = _ at h
  rw [FixedString.first_frequency] at h
  change (fixedString data).fundamental = _
  simpa only [PNat.val_ofNat, Nat.cast_one] using h

-- [source problem data / unit conversion] 1 mm becomes 0.1 cm explicitly.
lemma source_converted_diameter (data : StringData) (source : SourceData data) :
    diameterCm data = 1 / 10 := by
  rw [diameterCm, source.diameter_value]

/-- Exact arithmetic leaves π in the result; it does not give the square 4. -/
-- [source problem data / pure mathematics] Keep Real.pi exact in the arithmetic.
lemma fundamental_squared_source (data : StringData) (source : SourceData data) :
    fundamental data ^ 2 = 490 / (39 * Real.pi) := by
  rw [fundamental_formula, source.length_value, source_converted_diameter data source,
    source.tension_value, source.density_value, mul_pow,
    Real.sq_sqrt (by positivity)]
  field_simp [Real.pi_ne_zero]
  <;> ring

lemma fundamental_exact_source (data : StringData) (source : SourceData data) :
    fundamental data = Real.sqrt (490 / (39 * Real.pi)) := by
  have hp : 0 ≤ fundamental data := (FixedString.fundamental_pos (fixedString data)).le
  apply (sq_eq_sq₀ hp (Real.sqrt_nonneg _)).mp
  rw [fundamental_squared_source data source, Real.sq_sqrt (by positivity)]

/-- Certified numerical interval: 1.9998 < f₁ < 1.9999 Hz. These tighter
bounds are a derived strengthening, not precision claimed by the source. -/
-- [approximation/rounding] Mathlib proven π bounds certify the interval.
lemma fundamental_bounds (data : StringData) (source : SourceData data) :
    (19998 : ℝ) / 10000 < fundamental data ∧
    fundamental data < (19999 : ℝ) / 10000 := by
  have hden : 0 < 39 * Real.pi := by positivity
  have hlo : ((19998 : ℝ) / 10000) ^ 2 < 490 / (39 * Real.pi) := by
    apply (lt_div_iff₀ hden).2
    nlinarith [Real.pi_lt_d6]
  have hhi : 490 / (39 * Real.pi) < ((19999 : ℝ) / 10000) ^ 2 := by
    apply (div_lt_iff₀ hden).2
    nlinarith [Real.pi_gt_d6]
  have hs := fundamental_squared_source data source
  have hp := FixedString.fundamental_pos (fixedString data)
  change 0 < fundamental data at hp
  constructor <;> nlinarith

-- [formalization choice] Interpret the printed integer 2 as nearest-whole Hz.
lemma printed_fundamental_rounds (data : StringData) (source : SourceData data) :
    RoundsToWholeHz (fundamental data) 2 := by
  have h := fundamental_bounds data source
  norm_num [RoundsToWholeHz]
  constructor <;> linarith [h.1, h.2]

lemma fundamental_lt_two (data : StringData) (source : SourceData data) :
    fundamental data < 2 := by
  linarith [(fundamental_bounds data source).2]

-- [source-solution audit] The textbook equality is not exact with Real.pi.
lemma printed_fundamental_not_exact (data : StringData) (source : SourceData data) :
    fundamental data ≠ 2 := (fundamental_lt_two data source).ne

lemma natural_harmonics (data : StringData) (n : ℕ+) :
    naturalFrequency data n = (n : ℝ) * fundamental data :=
  FixedString.harmonic_scaling (fixedString data) n

-- [derived physics] Explicit exact source-specific frequency sequence.
lemma source_mode_exact (data : StringData) (source : SourceData data) (n : ℕ+) :
    naturalFrequency data n = (n : ℝ) * Real.sqrt (490 / (39 * Real.pi)) := by
  rw [natural_harmonics, fundamental_exact_source data source]

/-- The source's 2n is an approximation of the family, with error growing
with n; it does not mean every high mode rounds to 2n at unit-Hz resolution. -/
-- [pure mathematics / approximation] Scale the coefficient error with positive n.
lemma mode_approximation_error (data : StringData) (source : SourceData data) (n : ℕ+) :
    |naturalFrequency data n - 2 * (n : ℝ)| < (n : ℝ) / 5000 := by
  have hn : (0 : ℝ) < n := by exact_mod_cast n.pos
  have hf := fundamental_bounds data source
  have herror : |fundamental data - 2| < (1 : ℝ) / 5000 := by
    rw [abs_of_neg (by linarith [hf.2])]
    linarith [hf.1]
  rw [natural_harmonics]
  have heq : (n : ℝ) * fundamental data - 2 * n = (n : ℝ) * (fundamental data - 2) := by ring
  rw [heq, abs_mul, abs_of_pos hn]
  simpa only [mul_div, mul_one] using mul_lt_mul_of_pos_left herror hn

/-- Exact family: fₙ = n/(Ld) √(T/(πρ)) = n f₁, with n strictly positive.
Source arithmetic: f₁ rounds to 2 Hz but is strictly smaller than 2, so 2n is
not installed as an exact real-valued frequency family. -/
-- [final judgment] Prove the combined formula, exact harmonics and audited rounding.
theorem solution (data : StringData) (source : SourceData data) :
    TrustedPhysicsProblem data := by
  have exactModes : ExactSpectrum data := cylindrical_frequency data
  have harmonics : HarmonicSpectrum data := natural_harmonics data
  have roundedFundamental : RoundsToWholeHz (fundamental data) 2 :=
    printed_fundamental_rounds data source
  have strictlyBelowTwo : fundamental data < 2 := fundamental_lt_two data source
  exact ⟨exactModes, harmonics, roundedFundamental, strictlyBelowTwo⟩

end LeanVerificationDemo.PhysicsDemo.P13.CandidateAnnotated
