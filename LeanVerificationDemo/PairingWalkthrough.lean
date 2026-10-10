import LeanVerificationDemo.Candidate
import LeanVerificationDemo.Physics.Candidate

/-!
Stage 2 pairing walkthrough.

Problem = proposition/type A.
Solution = proof term B.
Verification = Lean elaborates the declaration and validates that B : A.
-/

namespace LeanVerificationDemo

/- Math pairing. -/

#check LeanVerificationDemo.SqrtTwoIrrationalProblem
#check LeanVerificationDemo.Candidate.solution

example : LeanVerificationDemo.SqrtTwoIrrationalProblem :=
  LeanVerificationDemo.Candidate.solution

namespace Physics

/- Physics pairing. -/

#check LeanVerificationDemo.Physics.TrustedPhysicsProblem
#check LeanVerificationDemo.Physics.Candidate.solution

example (data : PlateData) (ray : RayThroughPlate data) :
    TrustedPhysicsProblem data ray :=
  Candidate.solution data ray

end Physics
end LeanVerificationDemo
