import LeanVerificationDemo.MathDemo.M00.Problem

namespace LeanVerificationDemo.MathDemo.M00.Mutations.AssumptionMutation

/-
Mutation 1: corrupt the assumption step.

Correct step:
  Assume `sqrt(2)` is rational.

Mutated step:
  Assume `sqrt(2)` is irrational instead.

The remaining contradiction block is left in the same shape: it expects a
rationality assumption and therefore rejects the mutated assumption.
-/
theorem solution : LeanVerificationDemo.MathDemo.M00.SqrtTwoIrrationalProblem := by
  rw [LeanVerificationDemo.MathDemo.M00.SqrtTwoIrrationalProblem, Irrational]

  have hAssumption : Irrational (Real.sqrt 2) := by
    rw [Irrational]
    intro hRat
    have hNotSquare : ¬ IsSquare (2 : ℕ) := Nat.prime_two.not_isSquare
    have hIrr : Irrational (Real.sqrt 2) := irrational_sqrt_natCast_iff.mpr hNotSquare
    exact hIrr hRat

  intro hRat

  have hContradiction : False := by
    have hNotSquare : ¬ IsSquare (2 : ℕ) := Nat.prime_two.not_isSquare
    have hIrr : Irrational (Real.sqrt 2) := irrational_sqrt_natCast_iff.mpr hNotSquare
    exact hIrr hAssumption

  exact hContradiction

end LeanVerificationDemo.MathDemo.M00.Mutations.AssumptionMutation
