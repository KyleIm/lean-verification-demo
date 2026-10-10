import LeanVerificationDemo.PhysicsDemo.P01.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P01.Mutations.EntranceSnellMutation

open Math2Physics.PhyslibTemp.Optics

/-- Mutation 1: directly corrupt the entrance Snell-law index/angle pairing. -/
theorem solution (data : PlateData) (ray : RayThroughPlate data) :
    TrustedPhysicsProblem data ray := by
  have hEntranceCorrupt :
      snellExpression data.n₀ (ray.stack.angle 0) =
        snellExpression data.n₁ data.α :=
    ray.entrance_snell

  exact Candidate.solution data ray

end LeanVerificationDemo.PhysicsDemo.P01.Mutations.EntranceSnellMutation
