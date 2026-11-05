import LeanVerificationDemo.PhyslibTemp.Optics.TwoBeamInterference

namespace LeanVerificationDemo.PhyslibTemp.Optics.TwoBeamInterferenceExamples
open TwoBeamInterference

noncomputable def exampleWavelength : Wavelength := ⟨⟨4, by norm_num⟩⟩

example : IsMaximum 0 := by simp [IsMaximum]
example : IsMinimum Real.pi := by simp [IsMinimum]
example (θ : ℝ) : IsMaximum (θ + Real.pi) ↔ IsMinimum θ := maximum_pi_iff θ
example (θ : ℝ) : IsMinimum (θ + Real.pi) ↔ IsMaximum θ := minimum_pi_iff θ
example : intensity 2 1 Real.pi = 1 := by norm_num [intensity]
example : intensity 2 1 0 = 9 := by norm_num [intensity]
example : ¬ IsMaximum Real.pi := by norm_num [IsMaximum]
example : IsMaximum (phase exampleWavelength 4 0) := by
  apply (maximum_path_iff exampleWavelength (by change (0 : ℝ) < 4; norm_num) 4).mpr
  refine ⟨1, ?_⟩
  norm_num only [Int.cast_one]
  change (4 : ℝ) = 1 * 4
  norm_num
example : IsMinimum (phase exampleWavelength 2 0) := by
  apply (minimum_path_iff exampleWavelength (by change (0 : ℝ) < 4; norm_num) 2).mpr
  refine ⟨0, ?_⟩
  norm_num only [Int.cast_zero]
  change (2 : ℝ) = (1 / 2) * 4
  norm_num

end LeanVerificationDemo.PhyslibTemp.Optics.TwoBeamInterferenceExamples
