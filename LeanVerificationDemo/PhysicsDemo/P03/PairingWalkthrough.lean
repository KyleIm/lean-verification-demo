import LeanVerificationDemo.PhysicsDemo.P03.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P03

#check TrustedPhysicsProblem
#check Candidate.solution
#check Candidate.glass_voltage_at_air_limit
#print axioms Candidate.solution

example (data : BatteryData) (source : SourceData data) :
    TrustedPhysicsProblem data := Candidate.solution data source

end LeanVerificationDemo.PhysicsDemo.P03
