import LeanVerificationDemo.PhysicsDemo.P08.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P08
#check Candidate.total_momentum_zero
#check Candidate.first_momentum_eq_neg_sum
#check Candidate.momenta_coplanar
#check Candidate.velocity_mem_of_momentum_mem
#check Candidate.solution
#print axioms Candidate.solution
example (data : ExplosionData) (source : SourceData data) :
    TrustedPhysicsProblem data := Candidate.solution data source
end LeanVerificationDemo.PhysicsDemo.P08
