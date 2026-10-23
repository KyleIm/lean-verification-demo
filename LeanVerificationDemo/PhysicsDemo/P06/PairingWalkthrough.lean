import LeanVerificationDemo.PhysicsDemo.P06.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P06
#check TrustedPhysicsProblem
#check Candidate.solution
#print axioms Candidate.solution
example (data : ReceptionData) (source : SourceData data) :
    TrustedPhysicsProblem data := Candidate.solution data source
end LeanVerificationDemo.PhysicsDemo.P06
