import LeanVerificationDemo.PhysicsDemo.P11.Units

namespace LeanVerificationDemo.PhysicsDemo.P11
#check Candidate.reflection_geometry
#check Candidate.incidence_ratio
#check Candidate.screen_hit_unique_iff
#check Candidate.boundary_ray_intersections
#check Candidate.upright_shadow_interval
#check Candidate.inverted_shadow_interval
#check Candidate.threshold_characterization
#check Candidate.top_boundary_screen_iff
#check Candidate.direct_subset_reflected
#check Candidate.reflected_availability
#check Candidate.far_screen_shadow_structure
#check Candidate.near_screen_shadow_structure
#check Candidate.solution
#check Units.typed_far_regime
#print axioms Candidate.solution
example (g : Geometry) : TrustedPhysicsProblem g := Candidate.solution g
end LeanVerificationDemo.PhysicsDemo.P11
