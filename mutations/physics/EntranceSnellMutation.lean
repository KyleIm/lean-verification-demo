import LeanVerificationDemo.Physics.Candidate

namespace LeanVerificationDemo
namespace Physics
namespace Mutations
namespace EntranceSnellMutation

open Math2Physics.PhyslibTemp.Optics

/-- Mutation 1: directly corrupt the entrance Snell-law index/angle pairing. -/
theorem solution (data : PlateData) (ray : RayThroughPlate data) :
    TrustedPhysicsProblem data ray := by
  have hEntranceCorrupt :
      snellExpression data.n₀ (ray.stack.angle 0) =
        snellExpression data.n₁ data.α :=
    ray.entrance_snell

  exact Candidate.solution data ray

end EntranceSnellMutation
end Mutations
end Physics
end LeanVerificationDemo
