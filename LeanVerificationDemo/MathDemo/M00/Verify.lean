import LeanVerificationDemo.MathDemo.M00.Candidate

namespace LeanVerificationDemo.MathDemo.M00.Verifier

/-- Stage 2 check: the candidate must inhabit the trusted problem statement. -/
example : SqrtTwoIrrationalProblem :=
  Candidate.solution

end LeanVerificationDemo.MathDemo.M00.Verifier
