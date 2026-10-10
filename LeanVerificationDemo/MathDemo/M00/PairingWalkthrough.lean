import LeanVerificationDemo.MathDemo.M00.Candidate

/-!
Stage 2 pairing walkthrough for M00.

Problem = proposition/type A.
Solution = proof term B.
Verification = Lean elaborates the declaration and validates that B : A.
-/

namespace LeanVerificationDemo.MathDemo.M00

#check SqrtTwoIrrationalProblem
#check Candidate.solution

example : SqrtTwoIrrationalProblem :=
  Candidate.solution

end LeanVerificationDemo.MathDemo.M00
