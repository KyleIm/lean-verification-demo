import LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.ConstantAcceleration

namespace LeanVerificationDemo.PhysicsDemo.P12
open _root_.ClassicalMechanics

/-- P12-local surface categories from Table 1. -/
inductive Pavement
  | ice | drySnow | wetWoodBlock | dryWoodBlock | wetAsphalt | dryAsphalt | dryConcrete
  deriving DecidableEq, Repr

instance : Fintype Pavement where
  elems := {.ice, .drySnow, .wetWoodBlock, .dryWoodBlock, .wetAsphalt, .dryAsphalt, .dryConcrete}
  complete := by intro p; cases p <;> simp

/-- Source speeds, in km/h; every terminating decimal below is an exact real. -/
def speedKmh : Fin 10 → ℝ :=
  ![10, 20, 30, 40, 50, 60, 70, 80, 90, 100]

/-- Source Table 1, in metres, without smoothing or synthetic replacement. -/
def brakingDistance : Pavement → Fin 10 → ℝ
  | .ice => ![3.9, 15.6, 35.3, 62.9, 98.1, 141.4, 192.6, 251.6, 318.2, 393.0]
  | .drySnow => ![1.9, 7.8, 17.6, 31.4, 49.0, 70.7, 96.3, 125.8, 159.1, 196.6]
  | .wetWoodBlock => ![1.3, 5.2, 11.7, 20.9, 32.7, 47.1, 64.2, 83.8, 106.0, 131.0]
  | .dryWoodBlock => ![0.78, 3.1, 7.0, 12.5, 19.6, 28.2, 38.5, 50.3, 63.6, 78.6]
  | .wetAsphalt => ![0.97, 3.9, 8.8, 15.7, 24.5, 35.3, 48.1, 62.9, 79.5, 98.2]
  | .dryAsphalt => ![0.65, 2.6, 5.8, 10.4, 16.3, 23.5, 32.1, 41.9, 53.0, 65.5]
  | .dryConcrete => ![0.56, 2.2, 5.0, 9.0, 14.0, 20.2, 27.5, 35.9, 45.4, 56.1]

/-- Exact coordinate conversion; Units.lean connects this to upstream SI units. -/
noncomputable def speedSI (i : Fin 10) : ℝ := (5 / 18 : ℝ) * speedKmh i

/-- Numerical modeling choice, not a value printed in the source table. -/
noncomputable def gravity : ℝ := 49 / 5

/-- Physical estimator to be justified from braking mechanics in Candidate. -/
noncomputable def frictionEstimate (v g s : ℝ) : ℝ := v ^ 2 / (2 * g * s)
noncomputable def tableEstimate (p : Pavement) (i : Fin 10) : ℝ :=
  frictionEstimate (speedSI i) gravity (brakingDistance p i)

/-- Exact tenth grid, with no prescribed numerical answer. -/
def IsTenth (c : ℝ) : Prop := ∃ n : ℤ, c = (n : ℝ) / 10

/-- Nearest-tenth band, with half-tenth ties assigned to the larger grid value.
The grid condition is supplied separately by RoundedTable. -/
def RoundsToTenth (x c : ℝ) : Prop := c - 1 / 20 ≤ x ∧ x < c + 1 / 20

def RoundedTable (coeff : Pavement → ℝ) : Prop :=
  ∀ p, IsTenth (coeff p) ∧ ∀ i, RoundsToTenth (tableEstimate p i) (coeff p)

/-- One oriented braking coordinate; SI real magnitudes. -/
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
noncomputable def speed (particle : trackFrame.Particle) (t : ℝ) : ℝ :=
  (particle.velocity t).components 0
noncomputable def travel (particle : trackFrame.Particle) (t : ℝ) : ℝ :=
  (particle.pos t).components 0 - (particle.pos 0).components 0

/-- Local parameters of one braking observation, not an ontology of vehicles. -/
structure BrakingRun where
  particle : trackFrame.Particle
  duration : ℝ
  duration_pos : 0 < duration
  initialSpeed : ℝ
  initialSpeed_pos : 0 < initialSpeed
  distance : ℝ
  distance_pos : 0 < distance
  g : ℝ
  g_pos : 0 < g
  μ : ℝ
  μ_nonneg : 0 ≤ μ
  normalReaction : ℝ
  frictionMagnitude : ℝ

noncomputable def deceleration (run : BrakingRun) : ℝ :=
  run.frictionMagnitude / run.particle.mass.val

/-- Source-solution idealization: fixed horizontal support, saturated braking
friction and Newton II. These imply constant deceleration. The globally smooth
particle is a reference continuation; physical braking uses [0,duration] only.
No constant acceleration is asserted for a vehicle after it has stopped. -/
structure BrakingModel (run : BrakingRun) : Prop where
  normal_balance : run.normalReaction = run.particle.mass.val * run.g
  braking_friction : run.frictionMagnitude = run.μ * run.normalReaction
  newton : ∀ t, run.particle.mass.val * (run.particle.acceleration t).components 0 =
    -run.frictionMagnitude
  initial_speed : speed run.particle 0 = run.initialSpeed
  distance_travelled : travel run.particle run.duration = run.distance
  final_at_rest : speed run.particle run.duration = 0

/-- Source row matching plus the explicitly chosen g specialization. -/
def ObservesRow (run : BrakingRun) (p : Pavement) (i : Fin 10) : Prop :=
  run.initialSpeed = speedSI i ∧ run.distance = brakingDistance p i ∧ run.g = gravity

/-- Every physical run satisfying the row and adopted model must yield the same
rounded answer. This clause makes the final proof use the mechanics derivation. -/
def PhysicalTableCompatibility (coeff : Pavement → ℝ) : Prop :=
  ∀ p i run, BrakingModel run → ObservesRow run p i → RoundsToTenth run.μ (coeff p)

def TableSolution (coeff : Pavement → ℝ) : Prop :=
  RoundedTable coeff ∧ PhysicalTableCompatibility coeff

/-- Find the unique rounded assignment, rather than putting the seven answers
into trusted fields. The table specifies bands, not exact speed-independent μ. -/
def TrustedPhysicsProblem : Prop := ∃! coeff : Pavement → ℝ, TableSolution coeff

end LeanVerificationDemo.PhysicsDemo.P12
