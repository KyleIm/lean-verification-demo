import LeanVerificationDemo.Physics.Problem

namespace LeanVerificationDemo
namespace Physics
namespace CandidateAnnotated

open Math2Physics.PhyslibTemp.Optics

/-- Annotated physics proof for the stratified-plate demonstration. -/
theorem solution (data : PlateData) (ray : RayThroughPlate data) :
    TrustedPhysicsProblem data ray := by
  -- [Problem modeling]
  -- The plate is represented by the one-dimensional profile `data.n`,
  -- with boundary values `data.n₁` and `data.n₂`.  This encodes a
  -- stratified medium whose iso-index layers are parallel to the faces.

  -- [Primitive physics]
  -- At the upper interface, Snell's law relates the external incident ray
  -- to the ray just inside the top of the plate:
  -- `n₀ sin α = n₁ sin θ₁`.
  have hEntrance :
      snellExpression data.n₀ data.α = snellExpression data.n₁ (ray.stack.angle 0) :=
    ray.entrance_snell

  -- [Primitive physics]
  -- Inside the finite stratified approximation, Snell's law is supplied only
  -- locally at each adjacent parallel interface in `ray.stack.adjacent_snell`.

  -- [Pure mathematics]
  -- Lean chains those adjacent equalities by finite induction over the layer
  -- index.  This is ordinary equality transitivity, not a new optical law.

  -- [Derived physics]
  -- The result of that finite chain is the internal Snell invariant between
  -- the upper and lower sampled layers:
  -- `n₁ sin θ_upper = n₂ sin θ_lower`.
  have hInternal :
      snellExpression data.n₁ (ray.stack.angle 0) =
        snellExpression data.n₂ (ray.stack.angle ray.stack.layerCount) :=
    stratified_parallel_layer_invariant data ray

  -- [Primitive physics]
  -- At the lower interface, Snell's law relates the ray just before exiting
  -- the plate to the outgoing ray in the same external medium:
  -- `n₂ sin θ₂ = n₀ sin β`.
  have hExit :
      snellExpression data.n₂ (ray.stack.angle ray.stack.layerCount) =
        snellExpression data.n₀ ray.β :=
    ray.exit_snell

  -- [Pure mathematics]
  -- Chaining the entrance, internal, and exit equalities eliminates the
  -- internal angles and leaves equality of the external Snell expressions.
  have hExterior :
      snellExpression data.n₀ data.α = snellExpression data.n₀ ray.β :=
    hEntrance.trans (hInternal.trans hExit)

  -- [Pure mathematics]
  -- The external refractive index is positive, hence nonzero, so the common
  -- factor `n₀` can be cancelled from `n₀ sin α = n₀ sin β`.
  have hSin : Real.sin data.α = Real.sin ray.β := by
    exact mul_left_cancel₀ data.n₀.coe_ne_zero
      (by simpa [snellExpression] using hExterior)

  -- [Pure mathematics]
  -- Both external angles lie in the physical interval `[0, π/2]`, which is
  -- inside Mathlib's interval where sine is injective.  Equal sines therefore
  -- imply equal angles, so `β = α`.
  exact (Real.injOn_sin
    data.α_physical.mem_sin_inj_interval
    ray.β_physical.mem_sin_inj_interval hSin).symm

end CandidateAnnotated
end Physics
end LeanVerificationDemo
