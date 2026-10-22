import LeanVerificationDemo.PhysicsDemo.P02.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P02

#check TrustedPhysicsProblem
#check Candidate.solution
#print axioms Candidate.solution

example (data : GasData) (evidence : GasEvidence data) :
    TrustedPhysicsProblem data :=
  Candidate.solution data evidence

end LeanVerificationDemo.PhysicsDemo.P02
