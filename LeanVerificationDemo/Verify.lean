import LeanVerificationDemo.Candidate

namespace LeanVerificationDemo.Verifier

/-- Stage 2 check: the candidate must inhabit the trusted problem statement. -/
example : LeanVerificationDemo.SqrtTwoIrrationalProblem :=
  LeanVerificationDemo.Candidate.solution

end LeanVerificationDemo.Verifier
