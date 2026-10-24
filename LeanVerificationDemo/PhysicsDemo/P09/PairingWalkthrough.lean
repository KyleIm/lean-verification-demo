import LeanVerificationDemo.PhysicsDemo.P09.Candidate
import LeanVerificationDemo.PhysicsDemo.P09.Units

namespace LeanVerificationDemo.PhysicsDemo.P09

#check Candidate.friction_acceleration
#check Candidate.segment_deceleration_before
#check Candidate.segment_deceleration_after
#check Candidate.segment_velocity
#check Candidate.segment_travel
#check Candidate.segment_speed_squared
#check Candidate.sliding_speeds_nonnegative
#check Candidate.impact_preserves_speed
#check Candidate.impact_speed_eq
#check Candidate.stopping_relation
#check Candidate.deceleration_from_stopping
#check Candidate.coefficient_from_deceleration
#check Candidate.total_path
#check Candidate.coefficient_symbolic
#check Candidate.coefficient_exact
#check Candidate.coefficient_source_value
#check Candidate.coefficient_decimal_interval
#check Candidate.solution
#print axioms Candidate.solution
#check Units.friction_dimensions_iff
#check Units.newton_dimensions
#check Units.speed_squared_dimensions
#check Units.coefficient_dimensions
#check Units.typed_coefficient_equation
#check Units.source_coefficient_in_SI
#check Units.incorrect_formula_not_dimensionless
#check Units.joule_is_newton_metre
#print axioms Units.typed_coefficient_equation
#print axioms Units.source_coefficient_in_SI

example (data : PuckData) (source : SourceData data) :
    TrustedPhysicsProblem data := Candidate.solution data source

-- Explicit source-facing answer in the proposition/proof pairing.
example (data : PuckData) (source : SourceData data) :
    data.μ = (5 : ℝ) / 49 ∧ |data.μ - (102 : ℝ) / 1000| < 1 / 2000 :=
  Candidate.solution data source

end LeanVerificationDemo.PhysicsDemo.P09
