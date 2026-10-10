import LeanVerificationDemo.PhysicsDemo.P01.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P01.Mutations.ExitSnellMutation

open Math2Physics.PhyslibTemp.Optics

/-- Mutation 3: directly corrupt the exit Snell-law index/angle pairing. -/
theorem solution (data : PlateData) (ray : RayThroughPlate data) :
    TrustedPhysicsProblem data ray := by
  have hExitCorrupt :
      snellExpression data.n₂ ray.β =
        snellExpression data.n₀ (ray.stack.angle ray.stack.layerCount) :=
    ray.exit_snell

  exact Candidate.solution data ray

end LeanVerificationDemo.PhysicsDemo.P01.Mutations.ExitSnellMutation
