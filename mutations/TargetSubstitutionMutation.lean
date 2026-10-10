import LeanVerificationDemo.Candidate

namespace LeanVerificationDemo.Mutations.TargetSubstitutionMutation

/-
Mutation: substitute the trusted target.

Original target:
  Irrational (Real.sqrt 2)

Mutated target:
  Irrational (Real.sqrt 3)

Both statements are true, but the unchanged candidate proof has the type of the
original target. This file checks whether that proof can inhabit the substituted
target.
-/
def MutatedProblem : Prop :=
  Irrational (Real.sqrt 3)

theorem solution : MutatedProblem :=
  LeanVerificationDemo.Candidate.solution

end LeanVerificationDemo.Mutations.TargetSubstitutionMutation
