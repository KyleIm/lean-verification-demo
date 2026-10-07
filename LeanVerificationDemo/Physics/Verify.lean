import LeanVerificationDemo.Physics.Candidate

namespace LeanVerificationDemo
namespace Physics
namespace Verifier

/-- Stage 2 check: the candidate must prove the trusted physics target. -/
example (data : PlateData) (ray : RayThroughPlate data) :
    TrustedPhysicsProblem data ray :=
  Candidate.solution data ray

end Verifier
end Physics
end LeanVerificationDemo
