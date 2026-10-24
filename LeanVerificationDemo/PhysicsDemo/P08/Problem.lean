import LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.ConstantAcceleration
import LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.ImpulseMomentum
import Mathlib.Analysis.Calculus.LocalExtr.Basic
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.LinearAlgebra.FiniteDimensional.Basic
import Mathlib.LinearAlgebra.Dimension.Constructions
import Mathlib.Tactic

namespace LeanVerificationDemo.PhysicsDemo.P08
open _root_.ClassicalMechanics
open LeanVerificationDemo.PhyslibTemp.ClassicalMechanics
open scoped BigOperators Topology
open Filter

/-- Fixed nonrotating Cartesian frame; the third coordinate is vertical. -/
noncomputable def labFrame : ReferenceFrame 3 where
  timeOrigin := ⟨0⟩
  origin := fun _ => ⟨fun _ => 0⟩
  basis := fun _ => (EuclideanSpace.basisFun (Fin 3) ℝ).toBasis

lemma labFrame_inertial : labFrame.IsInertial where
  origin_moves_uniformly := by
    refine ⟨0, ?_⟩
    intro t₁ t₂
    simp [labFrame]
  basis_conserved := fun _ _ => rfl

instance : Fact labFrame.IsInertial := ⟨labFrame_inertial⟩

/-- P08's upward unit coordinate direction. -/
def up : labFrame.Vector := ⟨![0, 0, 1]⟩

/-- Cartesian vector coordinates in one fixed inertial frame and coherent units.
Velocity and momentum share a coordinate space; physical dimensions are not
encoded in its type. These are vectors, not affine endpoints. -/
abbrev Vector3 := EuclideanSpace ℝ (Fin 3)

/-- Fragments are event snapshots. The rocket is an upstream particle describing
an ideal coasting reference trajectory under constant downward acceleration.
It is not a model of propulsion or the post-explosion fragment trajectories. -/
structure ExplosionData where
  mass : Fin 3 → ℝ
  mass_pos : ∀ i, 0 < mass i
  velocity : Fin 3 → Vector3
  rocket : labFrame.Particle
  initialSpeed : ℝ
  initialSpeed_pos : 0 < initialSpeed
  g : ℝ
  g_pos : 0 < g
  /-- Duration-indexed momentum histories; the second time is elapsed time
  since the event starts, so its absolute time is apexTime + t. -/
  eventMomentum : ℝ → Fin 3 → ℝ → Vector3
  /-- Force on i from j, for each positive-duration regularization. -/
  internalForce : ℝ → Fin 3 → Fin 3 → ℝ → Vector3

/-- Candidate turning time of the vertical coasting reference trajectory. Its
maximum-height property and zero velocity are proved, not supplied as evidence. -/
noncomputable def apexTime (data : ExplosionData) : ℝ := data.initialSpeed / data.g

noncomputable def height (data : ExplosionData) (t : ℝ) : ℝ :=
  (data.rocket.pos t).components 2

/-- Convert the upstream velocity components at the derived apex time into the
same fixed Cartesian coordinate space used by the fragment velocities. -/
noncomputable def apexVelocity (data : ExplosionData) : Vector3 :=
  WithLp.toLp 2 (data.rocket.velocity (apexTime data)).components

/-- Classical snapshot momentum p_i = m_i v_i. This local scalar action matches
Physlib's particle momentum definition without requiring a Newtonian trajectory. -/
noncomputable def momentum (data : ExplosionData) (i : Fin 3) : Vector3 :=
  data.mass i • data.velocity i

/-- Pre-breakup momentum of the actual upstream rocket particle. -/
noncomputable def preMomentum (data : ExplosionData) : Vector3 :=
  data.rocket.mass.val • apexVelocity data

noncomputable def totalMomentum (data : ExplosionData) : Vector3 :=
  momentum data 0 + momentum data 1 + momentum data 2

/-- Constant external acceleration in the fragment coordinate space. -/
noncomputable def gravityAcceleration (data : ExplosionData) : Vector3 :=
  WithLp.toLp 2 ((-data.g) • up).components

noncomputable def gravitationalForce (data : ExplosionData) : Vector3 :=
  (∑ i, data.mass i) • gravityAcceleration data

/-- Elapsed-time impulse over the finite event, equivalent to integrating the
constant force over [apexTime, apexTime + ε]. -/
noncomputable def gravitationalImpulse (data : ExplosionData) (ε : ℝ) : Vector3 :=
  ∫ _t in (0 : ℝ)..ε, gravitationalForce data

/-- Source/model inputs, not conservation of the final event states. Each
positive-duration interaction obeys coordinate Newton II/III and starts with
co-moving constituents. The post-event snapshot is the limit of its endpoint
momenta as duration tends to zero from above. Existence of this regularization
and its limits is an idealization, not a theorem about an actual explosion. -/
structure SourceData (data : ExplosionData) : Prop where
  constant_acceleration : HasConstantAcceleration data.rocket ((-data.g) • up)
  initial_velocity : data.rocket.velocity 0 = data.initialSpeed • up
  mass_balance : ∑ i, data.mass i = data.rocket.mass.val
  event_balance : ∀ ε > 0, MomentumBalance (data.eventMomentum ε) (data.internalForce ε)
    (fun i _ => data.mass i • gravityAcceleration data)
  event_initial : ∀ ε > 0, ∀ i,
    data.eventMomentum ε i 0 = data.mass i • apexVelocity data
  post_event_limit : ∀ i, Tendsto (fun ε => data.eventMomentum ε i ε)
    (𝓝[>] (0 : ℝ)) (𝓝 (momentum data i))

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
