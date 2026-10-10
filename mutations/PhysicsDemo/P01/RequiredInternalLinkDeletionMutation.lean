import LeanVerificationDemo.PhysicsDemo.P01.Problem

namespace LeanVerificationDemo.PhysicsDemo.P01.Mutations.RequiredInternalLinkDeletionMutation

open Math2Physics.PhyslibTemp.Optics

/-
Mutation 6: remove the required internal stratified-medium link.

Original chain:
  Entrance -> Internal stratified relation -> Exit

After mutation:
  Entrance -> [missing] -> Exit
-/
theorem solution (data : PlateData) (ray : RayThroughPlate data) :
    TrustedPhysicsProblem data ray := by
  have hEntrance :
      snellExpression data.n₀ data.α = snellExpression data.n₁ (ray.stack.angle 0) :=
    ray.entrance_snell

  have hExit :
      snellExpression data.n₂ (ray.stack.angle ray.stack.layerCount) =
        snellExpression data.n₀ ray.β :=
    ray.exit_snell

  have hExterior :
      snellExpression data.n₀ data.α = snellExpression data.n₀ ray.β :=
    hEntrance.trans hExit

  have hSin : Real.sin data.α = Real.sin ray.β := by
    exact mul_left_cancel₀ data.n₀.coe_ne_zero
      (by simpa [snellExpression] using hExterior)

  exact (Real.injOn_sin
    data.α_physical.mem_sin_inj_interval
    ray.β_physical.mem_sin_inj_interval hSin).symm

end LeanVerificationDemo.PhysicsDemo.P01.Mutations.RequiredInternalLinkDeletionMutation
