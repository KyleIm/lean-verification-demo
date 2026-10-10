import LeanVerificationDemo.Problem

namespace LeanVerificationDemo.Mutations.RequiredStepDeletionMutation

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
theorem solution : LeanVerificationDemo.SqrtTwoIrrationalProblem := by
  rw [LeanVerificationDemo.SqrtTwoIrrationalProblem, Irrational]
  intro hRat
  have hNotSquare : ¬ IsSquare (2 : Nat) := Nat.prime_two.not_isSquare
  exact hNotSquare

end LeanVerificationDemo.Mutations.RequiredStepDeletionMutation
