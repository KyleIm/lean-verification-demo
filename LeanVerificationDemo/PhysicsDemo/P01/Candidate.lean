import LeanVerificationDemo.PhysicsDemo.P01.Problem

namespace LeanVerificationDemo.PhysicsDemo.P01.Candidate

open Math2Physics.PhyslibTemp.Optics

/-- Candidate physics solution: combine Snell's law at the entrance, through the
parallel stratified layers, and at the exit, then cancel the common external
index and use sine injectivity on the physical angular interval. -/
theorem solution (data : PlateData) (ray : RayThroughPlate data) :
    TrustedPhysicsProblem data ray := by
  -- Source answer: β = α. The same external n₀ and the finite-layer Snell
  -- invariant eliminate the internal index variation; this is conditional on
  -- the supplied transmitted ray, not a continuous-medium limit theorem.
  change ray.β = data.α
  have hEntrance :
      snellExpression data.n₀ data.α = snellExpression data.n₁ (ray.stack.angle 0) :=
    ray.entrance_snell

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
    hEntrance.trans (hInternal.trans hExit)

  have hSin : Real.sin data.α = Real.sin ray.β := by
    exact mul_left_cancel₀ data.n₀.coe_ne_zero
      (by simpa [snellExpression] using hExterior)

  exact (Real.injOn_sin
    data.α_physical.mem_sin_inj_interval
    ray.β_physical.mem_sin_inj_interval hSin).symm

end LeanVerificationDemo.PhysicsDemo.P01.Candidate
