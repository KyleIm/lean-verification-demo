import LeanVerificationDemo.MathDemo.M00.Problem

namespace LeanVerificationDemo.MathDemo.M00.Mutations.ConclusionMutation

/-
Mutation 3: corrupt the conclusion step.

Correct step:
  Conclude that `sqrt(2)` is irrational.

Mutated step:
  Conclude that `sqrt(2)` is rational.
-/
def MutatedProblem : Prop :=
  ∃ q : ℚ, (q : ℝ) = Real.sqrt 2

theorem solution : MutatedProblem := by
  have hContradictionFromRational :
      (∃ q : ℚ, (q : ℝ) = Real.sqrt 2) → False := by
    intro hRat
    have hNotSquare : ¬ IsSquare (2 : ℕ) := Nat.prime_two.not_isSquare
    have hIrr : Irrational (Real.sqrt 2) := irrational_sqrt_natCast_iff.mpr hNotSquare
    exact hIrr hRat

  exact hContradictionFromRational

end LeanVerificationDemo.MathDemo.M00.Mutations.ConclusionMutation
