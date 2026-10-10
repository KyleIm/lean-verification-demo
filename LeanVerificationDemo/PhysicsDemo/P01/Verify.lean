import LeanVerificationDemo.PhysicsDemo.P01.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P01.Verifier

/-- Stage 2 check: the candidate must prove the trusted physics target. -/
example (data : PlateData) (ray : RayThroughPlate data) :
    TrustedPhysicsProblem data ray :=
  Candidate.solution data ray

end LeanVerificationDemo.PhysicsDemo.P01.Verifier
