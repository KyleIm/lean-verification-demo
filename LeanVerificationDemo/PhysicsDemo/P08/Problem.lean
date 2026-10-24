import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.LinearAlgebra.FiniteDimensional.Basic
import Mathlib.LinearAlgebra.Dimension.Constructions
import Mathlib.Tactic

namespace LeanVerificationDemo.PhysicsDemo.P08

/-- Cartesian vector coordinates in one fixed inertial frame and coherent units.
Velocity and momentum share a coordinate space; physical dimensions are not
encoded in its type. These are vectors, not affine endpoints. -/
abbrev Vector3 := EuclideanSpace ℝ (Fin 3)

/-- P08-local event snapshot. Velocities are immediately after the explosion.
The pre-explosion rocket is represented only by its translational apex velocity;
no trajectory, rotation or finite-duration explosion dynamics is constructed. -/
structure ExplosionData where
  mass : Fin 3 → ℝ
  mass_pos : ∀ i, 0 < mass i
  velocity : Fin 3 → Vector3
  apexVelocity : Vector3

/-- Classical snapshot momentum p_i = m_i v_i. This local scalar action matches
Physlib's particle momentum definition without requiring a Newtonian trajectory. -/
noncomputable def momentum (data : ExplosionData) (i : Fin 3) : Vector3 :=
  data.mass i • data.velocity i

/-- Co-moving constituents before breakup: total mass times rocket velocity. -/
noncomputable def preMomentum (data : ExplosionData) : Vector3 :=
  (data.mass 0 + data.mass 1 + data.mass 2) • data.apexVelocity

noncomputable def totalMomentum (data : ExplosionData) : Vector3 :=
  momentum data 0 + momentum data 1 + momentum data 2

/-- Independent source/model premises. Conservation is an adopted event-level
approximation justified by neglecting the short gravitational impulse; neither
zero gravity impulse nor literally zero event duration is derived here. -/
structure SourceData (data : ExplosionData) : Prop where
  apex_at_rest : data.apexVelocity = 0
  momentum_conserved : totalMomentum data = preMomentum data

/-- Genuine linear coplanarity: all vectors lie in a real linear subspace through
zero of dimension at most two. Subspaces of Vector3 are finite-dimensional, so
finrank cannot hide an infinite-dimensional case. Degeneracies are allowed. -/
def LinearCoplanar (vectors : Fin 3 → Vector3) : Prop :=
  ∃ plane : Submodule ℝ Vector3,
    Module.finrank ℝ plane ≤ 2 ∧ ∀ i, vectors i ∈ plane

/-- Source problem 77: immediate post-explosion velocity vectors are linearly
coplanar. No plane, dimension bound or zero post-momentum is an input premise. -/
def TrustedPhysicsProblem (data : ExplosionData) : Prop :=
  LinearCoplanar data.velocity

end LeanVerificationDemo.PhysicsDemo.P08
