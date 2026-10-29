import LeanVerificationDemo.PhysicsDemo.P13.Units

namespace LeanVerificationDemo.PhysicsDemo.P13
#check SourceData
#check Candidate.circular_area
#check Candidate.linear_density_formula
#check Candidate.cylindrical_frequency
#check Candidate.fundamental_exact_source
#check Candidate.fundamental_bounds
#check Candidate.printed_fundamental_rounds
#check Candidate.printed_fundamental_not_exact
#check Candidate.source_mode_exact
#check Candidate.mode_approximation_error
#check Units.dyne_definition
#check Units.source_in_SI
#check Units.typed_source_SI
#check Candidate.solution
#print axioms Candidate.solution
example (data : StringData) (source : SourceData data) : TrustedPhysicsProblem data :=
  Candidate.solution data source
end LeanVerificationDemo.PhysicsDemo.P13
