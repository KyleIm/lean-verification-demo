import LeanVerificationDemo.Problem

namespace LeanVerificationDemo.Mutations.ContradictionMutation

/-
Mutation 2: corrupt the contradiction step.

Correct step:
  From the rationality assumption, derive `False`.

Mutated step:
  Derive only the irrelevant proposition `True`.
-/
theorem solution : LeanVerificationDemo.SqrtTwoIrrationalProblem := by
  rw [LeanVerificationDemo.SqrtTwoIrrationalProblem, Irrational]

  intro hRat

  have hContradiction : True := by
    exact True.intro

  exact hContradiction

end LeanVerificationDemo.Mutations.ContradictionMutation
