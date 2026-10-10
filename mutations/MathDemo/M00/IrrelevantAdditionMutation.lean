import LeanVerificationDemo.MathDemo.M00.Problem

namespace LeanVerificationDemo.MathDemo.M00.Mutations.IrrelevantAdditionMutation

/-
Mutation: add a true but unused intermediate fact.

Lean verifies logical and type correctness. It does not require every
intermediate fact to be relevant or necessary.
-/
theorem solution : LeanVerificationDemo.MathDemo.M00.SqrtTwoIrrationalProblem := by
  rw [LeanVerificationDemo.MathDemo.M00.SqrtTwoIrrationalProblem, Irrational]
  intro hRat
  have hIrrelevant : (1 : Nat) + 1 = 2 := by
    norm_num
  have hNotSquare : ¬ IsSquare (2 : Nat) := Nat.prime_two.not_isSquare
  have hIrr : Irrational (Real.sqrt 2) := irrational_sqrt_natCast_iff.mpr hNotSquare
  exact hIrr hRat

end LeanVerificationDemo.MathDemo.M00.Mutations.IrrelevantAdditionMutation
