import LeanVerificationDemo.PhysicsDemo.P12.Units

namespace LeanVerificationDemo.PhysicsDemo.P12
#check BrakingModel
#check TableSolution
#check Candidate.constant_deceleration
#check Candidate.stopping_relation
#check Candidate.friction_estimator
#check Candidate.coefficient_from_row
#check Candidate.rounded_numerators
#check Candidate.coefficient_values
#check Candidate.all_estimates_inside_bands
#check Candidate.physical_table_compatibility
#check Candidate.table_solution_unique
#check Candidate.rounded_speed_independent
#check Candidate.solution
#check Units.kilometre_per_hour_in_SI
#check Units.typed_table_estimate
#print axioms Candidate.solution
example : TrustedPhysicsProblem := Candidate.solution
end LeanVerificationDemo.PhysicsDemo.P12
