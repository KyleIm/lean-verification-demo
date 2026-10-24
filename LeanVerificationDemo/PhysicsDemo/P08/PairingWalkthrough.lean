import LeanVerificationDemo.PhysicsDemo.P08.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P08
#check Candidate.vertical_velocity_evolution
#check Candidate.height_evolution
#check Candidate.apex_time_pos
#check Candidate.apex_height_maximal
#check Candidate.apex_vertical_velocity_zero
#check Candidate.apex_velocity_zero
#check Candidate.total_momentum_zero
#check Candidate.first_momentum_eq_neg_sum
#check Candidate.momenta_coplanar
#check Candidate.velocity_mem_of_momentum_mem
#check Candidate.solution
#print axioms Candidate.solution
example (data : ExplosionData) (source : SourceData data) :
    TrustedPhysicsProblem data := Candidate.solution data source
end LeanVerificationDemo.PhysicsDemo.P08
