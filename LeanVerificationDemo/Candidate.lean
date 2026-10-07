import LeanVerificationDemo.Problem

namespace LeanVerificationDemo.Candidate

/-- Candidate solution submitted to the verifier. -/
theorem solution : LeanVerificationDemo.SqrtTwoIrrationalProblem := by
  rw [LeanVerificationDemo.SqrtTwoIrrationalProblem, Irrational]
  intro hRat
  have hNotSquare : ¬ IsSquare (2 : ℕ) := Nat.prime_two.not_isSquare
  have hIrr : Irrational (Real.sqrt 2) := irrational_sqrt_natCast_iff.mpr hNotSquare
  exact hIrr hRat

end LeanVerificationDemo.Candidate
