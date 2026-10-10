import LeanVerificationDemo.MathDemo.M00.Problem

namespace LeanVerificationDemo.MathDemo.M00.Mutations.RequiredStepDeletionMutation

/-
Mutation: delete the required conversion from `¬ IsSquare 2` to
`Irrational (Real.sqrt 2)`.

The original proof uses:

  have hIrr : Irrational (Real.sqrt 2) :=
    irrational_sqrt_natCast_iff.mpr hNotSquare
  exact hIrr hRat

That required step is omitted below, so the proof no longer inhabits the trusted
target.
-/
theorem solution : LeanVerificationDemo.MathDemo.M00.SqrtTwoIrrationalProblem := by
  rw [LeanVerificationDemo.MathDemo.M00.SqrtTwoIrrationalProblem, Irrational]
  intro hRat
  have hNotSquare : ¬ IsSquare (2 : Nat) := Nat.prime_two.not_isSquare
  exact hNotSquare

end LeanVerificationDemo.MathDemo.M00.Mutations.RequiredStepDeletionMutation
