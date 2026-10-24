import LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.ConstantAcceleration

namespace LeanVerificationDemo.PhysicsDemo.P09
open _root_.ClassicalMechanics

/-- An oriented path coordinate for each separate straight sliding segment.
The two coordinates are not one global spatial axis through the collision. -/
noncomputable def trackFrame : ReferenceFrame 1 where
  timeOrigin := ⟨0⟩
  origin := fun _ => ⟨fun _ => 0⟩
  basis := fun _ => (EuclideanSpace.basisFun (Fin 1) ℝ).toBasis

lemma trackFrame_inertial : trackFrame.IsInertial where
  origin_moves_uniformly := by
    refine ⟨0, ?_⟩
    intro t₁ t₂
    simp [trackFrame]
  basis_conserved := fun _ _ => rfl

instance : Fact trackFrame.IsInertial := ⟨trackFrame_inertial⟩

def tangent : trackFrame.Vector := ⟨fun _ => 1⟩

/-- Signed path-coordinate velocity; nonnegativity on each physical interval
is derived before interpreting it as the speed. Coordinates use coherent SI. -/
noncomputable def speed (p : trackFrame.Particle) (t : ℝ) : ℝ :=
  (p.velocity t).components 0

noncomputable def travel (p : trackFrame.Particle) (t : ℝ) : ℝ :=
  (p.pos t).components 0 - (p.pos 0).components 0

/-- P09-local fixed-board elasticity interpretation: unchanged kinetic energy
per unit mass. It is not a general collision theorem or a reflection map. -/
def ElasticFixedBoardImpact (incoming outgoing : ℝ) : Prop :=
  incoming ^ 2 = outgoing ^ 2

structure PuckData where
  before : trackFrame.Particle
  after : trackFrame.Particle
  firstDuration : ℝ
  firstDuration_pos : 0 < firstDuration
  secondDuration : ℝ
  secondDuration_pos : 0 < secondDuration
  initialSpeed : ℝ
  initialSpeed_pos : 0 < initialSpeed
  firstPath : ℝ
  firstPath_pos : 0 < firstPath
  secondPath : ℝ
  secondPath_pos : 0 < secondPath
  g : ℝ
  g_pos : 0 < g
  μ : ℝ
  μ_nonneg : 0 ≤ μ
  normalReaction : ℝ
  frictionMagnitude : ℝ

/-- Deceleration magnitude derived from tangential force divided by mass;
the Candidate proves this equals μg. -/
noncomputable def deceleration (data : PuckData) : ℝ :=
  data.frictionMagnitude / data.before.mass.val

/-- Problem-local model: horizontal support balance, the source's sliding
friction convention, Newton II along each oriented segment, and elastic impact.
The globally differentiable segment particles are reference continuations;
only [0, duration] describes physical sliding. No single constant acceleration
vector is asserted across the direction-changing collision or after stopping. -/
structure SlidingModel (data : PuckData) : Prop where
  same_mass : data.after.mass = data.before.mass
  normal_balance : data.normalReaction = data.before.mass.val * data.g
  sliding_friction : data.frictionMagnitude = data.μ * data.normalReaction
  newton_before : ∀ t, data.before.mass.val * (data.before.acceleration t).components 0 =
    -data.frictionMagnitude
  newton_after : ∀ t, data.after.mass.val * (data.after.acceleration t).components 0 =
    -data.frictionMagnitude
  initial_speed : speed data.before 0 = data.initialSpeed
  first_path : travel data.before data.firstDuration = data.firstPath
  second_path : travel data.after data.secondDuration = data.secondPath
  incoming_nonneg : 0 ≤ speed data.before data.firstDuration
  elastic_impact : ElasticFixedBoardImpact
    (speed data.before data.firstDuration) (speed data.after 0)
  final_at_rest : speed data.after data.secondDuration = 0

/-- Source numbers and explicit g = 9.8 m/s² specialization. The original
question does not supply g; this standard numerical choice yields its answer. -/
structure SourceData (data : PuckData) : Prop where
  model : SlidingModel data
  initial_value : data.initialSpeed = 5
  first_path_value : data.firstPath = 10
  second_path_value : data.secondPath = 5 / 2
  gravity_value : data.g = 49 / 5

/-- Determine the coefficient exactly and justify rounding to the source's
three-decimal answer. Neither conclusion is trusted source evidence. -/
def TrustedPhysicsProblem (data : PuckData) : Prop :=
  data.μ = (5 : ℝ) / 49 ∧ |data.μ - (102 : ℝ) / 1000| < 1 / 2000

end LeanVerificationDemo.PhysicsDemo.P09
