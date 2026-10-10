import LeanVerificationDemo.PhysicsDemo.P01.Problem

namespace LeanVerificationDemo.PhysicsDemo.P01.Mutations.InternalStratifiedMutation

open Math2Physics.PhyslibTemp.Optics

/-- Mutation 2: corrupt one local adjacent-interface Snell relation in the finite stack. -/
theorem solution (data : PlateData) (ray : RayThroughPlate data) :
    TrustedPhysicsProblem data ray := by
  have hEntrance :
      snellExpression data.n₀ data.α = snellExpression data.n₁ (ray.stack.angle 0) :=
    ray.entrance_snell

  let corruptStack : FiniteStratifiedStack :=
    { layerCount := ray.stack.layerCount
      index := ray.stack.index
      angle := ray.stack.angle
      adjacent_snell := fun i hi => by
        have hCorrect := ray.stack.adjacent_snell i hi
        have hWrongAngle :
            snellExpression (ray.stack.index i) (ray.stack.angle i) =
              snellExpression (ray.stack.index (i + 1)) (ray.stack.angle i) :=
          hCorrect
        exact hWrongAngle }

  have hInternalCorrupt :
      snellExpression data.n₁ (ray.stack.angle 0) =
        snellExpression data.n₂ (ray.stack.angle ray.stack.layerCount) := by
    have hchain := corruptStack.snellExpression_chain
    simpa [corruptStack, ray.stack_upper_index, ray.stack_lower_index] using hchain

  have hExit :
      snellExpression data.n₂ (ray.stack.angle ray.stack.layerCount) =
        snellExpression data.n₀ ray.β :=
    ray.exit_snell

  have hExterior :
      snellExpression data.n₀ data.α = snellExpression data.n₀ ray.β :=
    hEntrance.trans (hInternalCorrupt.trans hExit)

  have hSin : Real.sin data.α = Real.sin ray.β := by
    exact mul_left_cancel₀ data.n₀.coe_ne_zero
      (by simpa [snellExpression] using hExterior)

  exact (Real.injOn_sin
    data.α_physical.mem_sin_inj_interval
    ray.β_physical.mem_sin_inj_interval hSin).symm

end LeanVerificationDemo.PhysicsDemo.P01.Mutations.InternalStratifiedMutation
