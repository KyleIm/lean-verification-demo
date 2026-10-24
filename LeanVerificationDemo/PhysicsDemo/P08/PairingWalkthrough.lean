import LeanVerificationDemo.PhysicsDemo.P08.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P08
#check Candidate.vertical_velocity_evolution
#check Candidate.height_evolution
#check Candidate.apex_time_pos
#check Candidate.apex_height_maximal
#check Candidate.apex_vertical_velocity_zero
#check Candidate.apex_velocity_zero
#check Candidate.pre_momentum_zero
#check Candidate.internal_forces_cancel
#check Candidate.finite_duration_momentum_balance
#check Candidate.gravitational_impulse_eq
#check Candidate.gravitational_impulse_tendsto_zero
#check Candidate.total_momentum_endpoint_limit
#check Candidate.event_momentum_eq
#check Candidate.total_momentum_zero
#check Candidate.first_momentum_eq_neg_sum
#check Candidate.momenta_coplanar
#check Candidate.velocity_mem_of_momentum_mem
#check Candidate.solution
#print axioms Candidate.solution
#print axioms Candidate.event_momentum_eq
#print axioms Candidate.gravitational_impulse_tendsto_zero
example (data : ExplosionData) (source : SourceData data) :
    TrustedPhysicsProblem data := Candidate.solution data source
end LeanVerificationDemo.PhysicsDemo.P08
