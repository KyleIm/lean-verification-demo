import LeanVerificationDemo.PhyslibTemp.Optics.Refraction
import Mathlib.Topology.Basic

namespace LeanVerificationDemo
namespace Physics

open Math2Physics.PhyslibTemp.Optics

/-- Problem-specific mathematical model of a thick stratified plate.

The normal coordinate `z : ℝ` runs through the thickness of the plate.  The use of
`n : ℝ → RefractiveIndex` is the simplified one-dimensional representation of a
stratified medium with plane parallel iso-index layers. -/
structure PlateData where
  /-- Plate thickness.  The upper face is modeled at `z = 0`, the lower face at `z = L`. -/
  L : ℝ
  /-- The plate has positive thickness. -/
  L_pos : 0 < L
  /-- Refractive-index profile through the thickness direction. -/
  n : ℝ → RefractiveIndex
  /-- External refractive index, the same above and below the plate. -/
  n₀ : RefractiveIndex
  /-- Refractive index at the upper face. -/
  n₁ : RefractiveIndex
  /-- Refractive index at the lower face. -/
  n₂ : RefractiveIndex
  /-- Upper boundary condition for the refractive-index profile. -/
  n_upper : n 0 = n₁
  /-- Lower boundary condition for the refractive-index profile. -/
  n_lower : n L = n₂
  /-- The profile varies continuously inside the plate. -/
  n_continuousOn : ContinuousOn (fun z => (n z : ℝ)) (Set.Icc 0 L)
  /-- Incident angle `α`, measured from the common normal. -/
  α : IncidentAngle
  /-- The incident angle lies in the physical interval where sine is injective. -/
  α_physical : IsPhysicalNormalAngle α

/-- A finite stack of parallel stratified layers.

`layerCount = N` means that the stack has interfaces between layers
`0 → 1 → ... → N`.  The functions are total on `Nat` to keep the prototype
lightweight; only values from `0` through `N` are physically used. -/
structure FiniteStratifiedStack where
  /-- Number of adjacent internal Snell-law links. -/
  layerCount : Nat
  /-- Refractive index assigned to each sampled layer. -/
  index : Nat → RefractiveIndex
  /-- Ray angle assigned to each sampled layer. -/
  angle : Nat → NormalAngle
  /-- Primitive physics at every adjacent parallel interface in the finite stack. -/
  adjacent_snell :
    ∀ i, i < layerCount → SnellLaw (index i) (index (i + 1)) (angle i) (angle (i + 1))

namespace FiniteStratifiedStack

/-- Pure mathematical chaining of adjacent Snell-law equalities through a finite stack. -/
theorem snellExpression_chain
    (stack : FiniteStratifiedStack) :
    snellExpression (stack.index 0) (stack.angle 0) =
      snellExpression (stack.index stack.layerCount) (stack.angle stack.layerCount) := by
  let expr : Nat → ℝ := fun i => snellExpression (stack.index i) (stack.angle i)
  have hstep : ∀ i, i < stack.layerCount → expr i = expr (i + 1) := by
    intro i hi
    simpa [expr, SnellLaw] using stack.adjacent_snell i hi
  have hchain :
      ∀ N, (∀ i, i < N → expr i = expr (i + 1)) → expr 0 = expr N := by
    intro N h
    induction N with
    | zero =>
        rfl
    | succ N ih =>
        have hprefix : expr 0 = expr N := by
          apply ih
          intro i hi
          exact h i (Nat.lt_trans hi (Nat.lt_succ_self N))
        exact hprefix.trans (h N (Nat.lt_succ_self N))
  exact hchain stack.layerCount hstep

end FiniteStratifiedStack

/-- Ray data and primitive Snell-law evidence for the passage through the plate.

The internal medium is represented by a finite stack of parallel sampled layers.
Only local adjacent-interface Snell-law evidence is stored; the global endpoint
invariant is proved from those local links. -/
structure RayThroughPlate (data : PlateData) where
  /-- Finite sampled stratification of the plate. -/
  stack : FiniteStratifiedStack
  /-- The first sampled internal layer has the upper-face refractive index. -/
  stack_upper_index : stack.index 0 = data.n₁
  /-- The last sampled internal layer has the lower-face refractive index. -/
  stack_lower_index : stack.index stack.layerCount = data.n₂
  /-- Outgoing angle `β`, measured from the same normal in the external medium. -/
  β : TransmittedAngle
  /-- The outgoing angle lies in the physical interval where sine is injective. -/
  β_physical : IsPhysicalNormalAngle β
  /-- Primitive physics: Snell's law at the upper boundary. -/
  entrance_snell : SnellLaw data.n₀ data.n₁ data.α (stack.angle 0)
  /-- Primitive physics: Snell's law at the lower boundary. -/
  exit_snell : SnellLaw data.n₂ data.n₀ (stack.angle stack.layerCount) β

/-- Trusted formal target for the physics demonstration:
the outgoing angle equals the incident angle. -/
def TrustedPhysicsProblem (data : PlateData) (ray : RayThroughPlate data) : Prop :=
  ray.β = data.α

/-- Derived physics theorem for the finite-layer stratified model.

This is not an additional primitive physical law and it does not project a
global endpoint relation from the ray data.  It first chains the local adjacent
Snell-law equalities by finite induction, then rewrites the endpoint indices to
the upper and lower boundary indices of the plate. -/
theorem stratified_parallel_layer_invariant
    (data : PlateData) (ray : RayThroughPlate data) :
    snellExpression data.n₁ (ray.stack.angle 0) =
      snellExpression data.n₂ (ray.stack.angle ray.stack.layerCount) := by
  have hchain := ray.stack.snellExpression_chain
  simpa [ray.stack_upper_index, ray.stack_lower_index] using hchain

end Physics
end LeanVerificationDemo
