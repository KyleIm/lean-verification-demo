import LeanVerificationDemo.PhysicsDemo.P04.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P04
#check Candidate.solution
#check Candidate.internal_potentials
#print axioms Candidate.solution
example (data : CubeData) : TrustedPhysicsProblem data := Candidate.solution data
end LeanVerificationDemo.PhysicsDemo.P04
