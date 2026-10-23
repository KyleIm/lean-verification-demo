import LeanVerificationDemo.PhysicsDemo.P07.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P07
#check TrustedPhysicsProblem
#check Candidate.current_per_width
#check Candidate.solution
#print axioms Candidate.solution
example (data : RingData) (response : Response data) :
    TrustedPhysicsProblem data response := Candidate.solution data response
end LeanVerificationDemo.PhysicsDemo.P07
