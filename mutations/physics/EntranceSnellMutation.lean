import LeanVerificationDemo.Physics.Problem

namespace LeanVerificationDemo
namespace Physics
namespace Mutations
namespace EntranceSnellMutation

open Math2Physics.PhyslibTemp.Optics

/-- Mutation 1: corrupt the entrance Snell-law component. -/
theorem solution (data : PlateData) (ray : RayThroughPlate data) :
    TrustedPhysicsProblem data ray := by
  have hEntranceCorrupt :
      snellExpression data.n₂ (ray.stack.angle ray.stack.layerCount) =
        snellExpression data.n₁ (ray.stack.angle 0) :=
    (stratified_parallel_layer_invariant data ray).symm

  have hInternal :
      snellExpression data.n₁ (ray.stack.angle 0) =
        snellExpression data.n₂ (ray.stack.angle ray.stack.layerCount) :=
    stratified_parallel_layer_invariant data ray

  have hExit :
      snellExpression data.n₂ (ray.stack.angle ray.stack.layerCount) =
        snellExpression data.n₀ ray.β :=
    ray.exit_snell

  have hExterior :
      snellExpression data.n₀ data.α = snellExpression data.n₀ ray.β :=
    hEntranceCorrupt.trans (hInternal.trans hExit)

  have hSin : Real.sin data.α = Real.sin ray.β := by
    exact mul_left_cancel₀ data.n₀.coe_ne_zero
      (by simpa [snellExpression] using hExterior)

  exact (Real.injOn_sin
    data.α_physical.mem_sin_inj_interval
    ray.β_physical.mem_sin_inj_interval hSin).symm

end EntranceSnellMutation
end Mutations
end Physics
end LeanVerificationDemo
