import LeanVerificationDemo.PhysicsDemo.P02.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P02.Verifier

/-- The same candidate must prove the trusted target for arbitrary gas data. -/
example (data : GasData) (evidence : GasEvidence data) :
    TrustedPhysicsProblem data :=
  Candidate.solution data evidence

end LeanVerificationDemo.PhysicsDemo.P02.Verifier
