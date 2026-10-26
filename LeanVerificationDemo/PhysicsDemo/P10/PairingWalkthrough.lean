import LeanVerificationDemo.PhysicsDemo.P10.Units

namespace LeanVerificationDemo.PhysicsDemo.P10
#check Candidate.velocity_at_vertices
#check Candidate.velocity_on_segment
#check Candidate.velocity_nonnegative_on_zero_ten
#check Candidate.integral_linear_segment
#check Candidate.segment_areas
#check Candidate.distance_first_five
#check Candidate.distance_first_ten
#check Candidate.path_eq_displacement
#check Candidate.solution
#check Units.typed_answers
#print axioms Candidate.solution
#print axioms Candidate.path_eq_displacement
#print axioms Units.typed_answers
example : TrustedPhysicsProblem := Candidate.solution
end LeanVerificationDemo.PhysicsDemo.P10
