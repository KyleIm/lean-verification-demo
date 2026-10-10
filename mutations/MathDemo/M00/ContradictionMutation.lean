import LeanVerificationDemo.MathDemo.M00.Problem

namespace LeanVerificationDemo.MathDemo.M00.Mutations.ContradictionMutation

/-
Mutation 2: corrupt the contradiction step.

Correct step:
  From the rationality assumption, derive `False`.

Mutated step:
  Derive only the irrelevant proposition `True`.
-/
theorem solution : LeanVerificationDemo.MathDemo.M00.SqrtTwoIrrationalProblem := by
  rw [LeanVerificationDemo.MathDemo.M00.SqrtTwoIrrationalProblem, Irrational]

  intro hRat

  have hContradiction : True := by
    exact True.intro

  exact hContradiction

end LeanVerificationDemo.MathDemo.M00.Mutations.ContradictionMutation
