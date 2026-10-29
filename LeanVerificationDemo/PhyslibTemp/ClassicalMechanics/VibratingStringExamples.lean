import LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.VibratingString

namespace LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.VibratingStringExamples

/-- An independent ideal string, with no material or P13 source constants. -/
def exampleString : FixedString where
  length := 2
  length_pos := by norm_num
  tension := 12
  tension_pos := by norm_num
  linearDensity := 3
  linearDensity_pos := by norm_num

example : exampleString.waveSpeed = 2 := by
  norm_num [FixedString.waveSpeed, exampleString]
example : exampleString.fundamental = 1 / 2 := by
  norm_num [FixedString.fundamental, FixedString.waveSpeed, exampleString]
example : exampleString.frequency 3 = 3 / 2 := by
  rw [FixedString.harmonic_scaling]
  norm_num [FixedString.fundamental, FixedString.waveSpeed, exampleString]

example (s : FixedString) (n : ℕ+) :
    0 < s.frequency n ∧ s.frequency n = s.waveSpeed / s.wavelength n :=
  ⟨s.frequency_pos n, s.frequency_eq_speed_div_wavelength n⟩
example (s : FixedString) (n : ℕ+) : s.modeShape n 0 = 0 ∧ s.modeShape n s.length = 0 :=
  ⟨s.modeShape_left n, s.modeShape_right n⟩
example : ¬ ∃ n : ℕ+, (n : ℕ) = 0 := by
  rintro ⟨n, hn⟩
  exact Nat.ne_of_gt n.pos hn

#print axioms FixedString.harmonic_scaling
end LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.VibratingStringExamples
