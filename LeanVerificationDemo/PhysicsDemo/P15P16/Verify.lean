import LeanVerificationDemo.PhysicsDemo.P15P16.Units

namespace LeanVerificationDemo.PhysicsDemo.P15P16.Verifier
open LeanVerificationDemo.PhyslibTemp.Optics.TwoBeamInterference

/-- Independent positive parameters in coherent units, not source numerical
data. Answers are computed from these parameters, not stored as evidence. -/
noncomputable def exampleScreen : ScreenData where
  separation := 2
  distance := 100
  wavelength := ⟨⟨1 / 10, by norm_num⟩⟩
  separation_pos := by norm_num
  distance_pos := by norm_num
  wavelength_pos := by change (0 : ℝ) < 1 / 10; norm_num

example : P764.TrustedPhysicsProblem exampleScreen := P764.Candidate.solution exampleScreen
example : P766.TrustedPhysicsProblem exampleScreen := P766.Candidate.solution exampleScreen

example : P764.Candidate.solutionSpacing exampleScreen = 5 := by
  change (1 / 10 : ℝ) * 100 / 2 = 5
  norm_num
example : P766.Candidate.solutionShift exampleScreen = 5 / 2 := by
  change (1 / 10 : ℝ) * 100 / (2 * 2) = 5 / 2
  norm_num

example (data : ScreenData) :
    0 < data.separation ∧ 0 < data.distance ∧ 0 < (data.wavelength.val : ℝ) :=
  ⟨data.separation_pos, data.distance_pos, data.wavelength_pos⟩
example (data : ScreenData) : 2 * data.distance < lowerPath data 0 + upperPath data 0 :=
  GeometryDerivation.center_sum_strict data
example (data : ScreenData) : ¬ (lowerPath data 0 + upperPath data 0 = 2 * data.distance) :=
  (GeometryDerivation.center_sum_strict data).ne'
example (data : ScreenData) : exactDifference data 0 = 0 := by
  simp [exactDifference, lowerPath, upperPath]

example (data : ScreenData) : P764.IsFringeSpacing data (P764.Candidate.solutionSpacing data) :=
  P764.Candidate.spacing_valid data
example (data : ScreenData) :
    ¬ P764.IsFringeSpacing data (P764.Candidate.solutionSpacing data / 2) := by
  intro h
  have hp := (h.2.1 1 (P764.Candidate.solutionSpacing data / 2)).mpr (by simp)
  have he := ((P764.Candidate.spacing_valid data).2.1 1 _).mp hp
  simp only [Int.cast_one, one_mul] at he
  linarith [(P764.Candidate.spacing_valid data).1]
example (data : ScreenData) : IsMaximum (ordinaryPhase data 0) :=
  P766.Candidate.ordinary_center_maximum data
example (data : ScreenData) : IsMinimum (P766.lloydPhase data 0) :=
  P766.Candidate.lloyd_center_minimum data
example (data : ScreenData) (h : ℝ) :
    (IsMaximum (P766.lloydPhase data h) ↔ IsMinimum (ordinaryPhase data h)) ∧
    (IsMinimum (P766.lloydPhase data h) ↔ IsMaximum (ordinaryPhase data h)) :=
  P766.Candidate.maxima_minima_interchange data h
example (data : ScreenData) : ¬ IsMaximum (P766.lloydPhase data 0) := by
  have h := P766.Candidate.lloyd_center_minimum data
  intro hwrong
  unfold IsMinimum at h
  unfold IsMaximum at hwrong
  linarith

example (data : ScreenData) :
    P766.IsRelativeShift data (P766.Candidate.solutionShift data) := P766.Candidate.shift_valid data
example (data : ScreenData) :
    ¬ P766.IsRelativeShift data (P766.Candidate.ordinaryPeriod data) := by
  intro h
  have heq := P766.Candidate.relative_shift_unique data _ h
  have hp : 0 < P766.Candidate.ordinaryPeriod data :=
    div_pos (mul_pos data.wavelength_pos data.distance_pos) data.separation_pos
  rw [P766.Candidate.half_period_shift] at heq
  linarith

-- Unequal amplitudes retain a nonzero minimum: phase reversal is not a
-- claim that all real reflected-light minima are perfectly black.
example : intensity 2 1 Real.pi = 1 := by norm_num [intensity]

end LeanVerificationDemo.PhysicsDemo.P15P16.Verifier
