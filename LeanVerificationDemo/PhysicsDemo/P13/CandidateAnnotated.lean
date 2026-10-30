import LeanVerificationDemo.PhysicsDemo.P13.Problem
import Mathlib.Analysis.Real.Pi.Bounds

namespace LeanVerificationDemo.PhysicsDemo.P13.CandidateAnnotated
open LeanVerificationDemo.PhyslibTemp.ClassicalMechanics

/-- Solution-side interpretation of the printed integer-Hz answer: nearest
integer with half-integer ties toward +∞. This is not a trusted target. -/
-- [formalization choice] Rounding is solution-side; the trusted request has no numerical answer.
def RoundsToWholeHz (x : ℝ) (k : ℤ) : Prop := (k : ℝ) - 1 / 2 ≤ x ∧ x < k + 1 / 2

-- [derived geometry] Radius d/2 gives the cylindrical cross-sectional area.
lemma circular_area (data : StringData) :
    areaCm2 data = Real.pi * diameterCm data ^ 2 / 4 := by
  unfold areaCm2 radiusCm
  ring

/-- Volume density × circular area becomes mass per unit length. -/
-- [derived physics] Uniform volume density times area gives linear density.
lemma linear_density_formula (data : StringData) :
    linearDensity data = Real.pi * data.densityGcm3 * diameterCm data ^ 2 / 4 := by
  rw [linearDensity, circular_area]
  ring

-- [reusable physics / pure mathematics] Use FixedString.waveSpeed_squared, then simplify the local density.
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
-- [reusable physics / derived geometry] Apply FixedString.frequency; do not duplicate its mode law.
lemma cylindrical_frequency (data : StringData) (n : ℕ+) :
    naturalFrequency data n = (n : ℝ) / (data.lengthCm * diameterCm data) *
      Real.sqrt (data.tensionDyn / (Real.pi * data.densityGcm3)) := by
  unfold naturalFrequency
  rw [FixedString.frequency, wave_speed_from_volume_density]
  change (n : ℝ) / (2 * data.lengthCm) * ((2 / diameterCm data) *
    Real.sqrt (data.tensionDyn / (Real.pi * data.densityGcm3))) = _
  field_simp [data.length_pos.ne', (diameterCm_pos data).ne']
  <;> ring

-- [reusable physics] FixedString.first_frequency identifies the first mode.
lemma fundamental_formula (data : StringData) :
    fundamental data = (1 / (data.lengthCm * diameterCm data)) *
      Real.sqrt (data.tensionDyn / (Real.pi * data.densityGcm3)) := by
  have h := cylindrical_frequency data 1
  change (fixedString data).frequency 1 = _ at h
  rw [FixedString.first_frequency] at h
  change (fixedString data).fundamental = _
  simpa only [PNat.val_ofNat, Nat.cast_one] using h

-- [source problem data / unit conversion] Convert 1 mm to 0.1 cm before substitution.
lemma source_converted_diameter (data : StringData) (source : SourceData data) :
    diameterCm data = 1 / 10 := by
  rw [diameterCm, source.diameter_value]

/-- Exact arithmetic leaves π in the result; it does not give the square 4. -/
-- [source problem data / pure mathematics] Exact rational substitution retains Real.pi.
lemma fundamental_squared_source (data : StringData) (source : SourceData data) :
    fundamental data ^ 2 = 490 / (39 * Real.pi) := by
  rw [fundamental_formula, source.length_value, source_converted_diameter data source,
    source.tension_value, source.density_value, mul_pow,
    Real.sq_sqrt (by positivity)]
  field_simp [Real.pi_ne_zero]
  <;> ring

-- [derived numerical specialization] Positivity selects the physical square root.
lemma fundamental_exact_source (data : StringData) (source : SourceData data) :
    fundamental data = Real.sqrt (490 / (39 * Real.pi)) := by
  have hp : 0 ≤ fundamental data := (FixedString.fundamental_pos (fixedString data)).le
  apply (sq_eq_sq₀ hp (Real.sqrt_nonneg _)).mp
  rw [fundamental_squared_source data source, Real.sq_sqrt (by positivity)]

/-- Certified numerical interval: 1.9998 < f₁ < 1.9999 Hz. These tighter
bounds are a derived strengthening, not precision claimed by the source. -/
-- [approximation/rounding] Proved pi bounds give a certified interval, not source measurement precision.
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

-- [formalization choice / derived audit] Whole-Hz rounding is checked separately from the find-the-family target.
lemma printed_fundamental_rounds (data : StringData) (source : SourceData data) :
    RoundsToWholeHz (fundamental data) 2 := by
  have h := fundamental_bounds data source
  norm_num [RoundsToWholeHz]
  constructor <;> linarith [h.1, h.2]

lemma fundamental_lt_two (data : StringData) (source : SourceData data) :
    fundamental data < 2 := by
  linarith [(fundamental_bounds data source).2]

-- [source-solution audit] Reject an exact 2-Hz replacement.
lemma printed_fundamental_not_exact (data : StringData) (source : SourceData data) :
    fundamental data ≠ 2 := (fundamental_lt_two data source).ne

-- [reusable physics] Invoke FixedString.harmonic_scaling directly.
lemma natural_harmonics (data : StringData) (n : ℕ+) :
    naturalFrequency data n = (n : ℝ) * fundamental data :=
  FixedString.harmonic_scaling (fixedString data) n

-- [derived physics / source specialization] This exact source family first appears on the Candidate side.
lemma source_mode_exact (data : StringData) (source : SourceData data) (n : ℕ+) :
    naturalFrequency data n = (n : ℝ) * Real.sqrt (490 / (39 * Real.pi)) := by
  rw [natural_harmonics, fundamental_exact_source data source]

/-- The source's 2n is an approximation of the family, with error growing
with n; it does not mean every high mode rounds to 2n at unit-Hz resolution. -/
-- [pure mathematics / approximation] Harmonic scaling makes the error grow with positive mode number.
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

/-- The computed answer for the four source values, in s⁻¹. Its agreement
with the physical model is proved below, not built into the trusted target. -/
-- [constructed answer] Return the computed source-specific family, not a trusted answer field.
noncomputable def solutionFrequency : ℕ+ → ℝ :=
  fun n => (n : ℝ) * Real.sqrt (490 / (39 * Real.pi))

/-- Geometry → reusable FixedString law → exact source specialization proves
that the computed family satisfies the semantic success criterion. -/
-- [semantic validation] The answer matches FixedString through the preceding derivation.
lemma solutionFrequency_valid (data : StringData) (source : SourceData data) :
    IsNaturalFrequencySolution data solutionFrequency := by
  intro n
  exact (source_mode_exact data source n).symm

/-- The model determines a single family; no independence or nondegeneracy
claim about PDE eigenfunctions is needed for this function equality. -/
-- [pure mathematics] Pointwise semantic agreement gives uniqueness of the returned function.
lemma solutionFrequency_unique (data : StringData) (source : SourceData data)
    (freq : ℕ+ → ℝ) (valid : IsNaturalFrequencySolution data freq) :
    freq = solutionFrequency := by
  funext n
  exact (valid n).trans (solutionFrequency_valid data source n).symm

/-- Return the explicitly computed family fₙ = n √(490/(39π)), n > 0,
and prove it is the unique family of the ideal source string. The separate
audit lemmas above compare this exact answer with the textbook's 2n Hz. -/
-- [final judgment] Construct the explicit frequency-family witness and prove validity and uniqueness.
theorem solution (data : StringData) (source : SourceData data) :
    TrustedPhysicsProblem data := by
  have returnedFamily : IsNaturalFrequencySolution data
      (fun n : ℕ+ => (n : ℝ) * Real.sqrt (490 / (39 * Real.pi))) :=
    solutionFrequency_valid data source
  have uniqueFamily : ∀ freq, IsNaturalFrequencySolution data freq →
      freq = solutionFrequency := solutionFrequency_unique data source
  exact ⟨solutionFrequency, returnedFamily, uniqueFamily⟩

end LeanVerificationDemo.PhysicsDemo.P13.CandidateAnnotated
