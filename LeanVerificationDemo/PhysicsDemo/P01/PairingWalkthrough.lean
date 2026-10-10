import LeanVerificationDemo.PhysicsDemo.P01.Candidate

/-!
Stage 2 pairing walkthrough for P01.

Problem = proposition/type A.
Solution = proof term B.
Verification = Lean elaborates the declaration and validates that B : A.
-/

namespace LeanVerificationDemo.PhysicsDemo.P01

#check TrustedPhysicsProblem
#check Candidate.solution

example (data : PlateData) (ray : RayThroughPlate data) :
    TrustedPhysicsProblem data ray :=
  Candidate.solution data ray

end LeanVerificationDemo.PhysicsDemo.P01
