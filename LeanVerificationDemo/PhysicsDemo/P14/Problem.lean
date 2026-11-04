import Physlib.ClassicalMechanics.Pendulum.SimplePendulum.SmallAngle

namespace LeanVerificationDemo.PhysicsDemo.P14
open ClassicalMechanics

/-- Length and spring data come from the text; equal mass and direct bob
attachments come from the inspected Fig. 228. Separation is a coordinate
parameter for the distinct fixed pivots, not an extra source label. -/
structure CoupledPendulumData where
  length : ℝ
  mass : ℝ
  springConstant : ℝ
  gravity : ℝ
  separation : ℝ
  length_pos : 0 < length
  mass_pos : 0 < mass
  spring_pos : 0 < springConstant
  gravity_pos : 0 < gravity
  separation_pos : 0 < separation

def pendulum (data : CoupledPendulumData) : SimplePendulum where
  m := data.mass
  ℓ := data.length
  g := data.gravity
  m_pos := data.mass_pos
  ℓ_pos := data.length_pos
  g_pos := data.gravity_pos

inductive Mode | inPhase | antiPhase deriving DecidableEq

def partnerAngle : Mode → ℝ → ℝ
  | .inPhase, φ => φ
  | .antiPhase, φ => -φ

/-- Coordinates: pivots (0,0), (separation,0), y upward; positive first
angle points left. These are local coordinates for the inspected setup. -/
noncomputable def firstBob (data : CoupledPendulumData) (φ : ℝ) : ℝ × ℝ :=
  (-data.length * Real.sin φ, -data.length * Real.cos φ)

noncomputable def secondBob (data : CoupledPendulumData) (mode : Mode) (φ : ℝ) : ℝ × ℝ :=
  (data.separation - data.length * Real.sin (partnerAngle mode φ),
    -data.length * Real.cos (partnerAngle mode φ))

/-- Signed horizontal extension. For the two symmetric modes the bob heights
agree. Near equilibrium their order is unchanged, so this is the actual
spring extension. No arbitrary-angle horizontal-spring model is asserted. -/
noncomputable def springExtension (data : CoupledPendulumData) (mode : Mode) (φ : ℝ) : ℝ :=
  (secondBob data mode φ).1 - (firstBob data φ).1 - data.separation

/-- Ordinary Euclidean distance, used to verify the signed extension locally. -/
noncomputable def springLength (data : CoupledPendulumData) (mode : Mode) (φ : ℝ) : ℝ :=
  Real.sqrt (((secondBob data mode φ).1 - (firstBob data φ).1) ^ 2 +
    ((secondBob data mode φ).2 - (firstBob data φ).2) ^ 2)

/-- Borrow the upstream oscillator's Hooke-force API. Its mass is the bob
mass, not a mass assigned to the weightless spring; only its force is used. -/
def springModel (data : CoupledPendulumData) : HarmonicOscillator where
  m := data.mass
  k := data.springConstant
  m_pos := data.mass_pos
  k_pos := data.spring_pos

/-- The upstream restoring force opposes positive extension. The force on
the left bob is its opposite, directed right for a stretched spring. -/
noncomputable def springForce (data : CoupledPendulumData) (mode : Mode) (φ : ℝ) : ℝ :=
  -(springModel data).force (EuclideanSpace.single 0 (springExtension data mode φ)) 0

/-- Exact mode-slice torque: upstream gravitational torque plus the spring
force dotted with the angular tangent (-l cos φ, l sin φ).
This is the local physical model, not a solved frequency equation. -/
noncomputable def firstTorque (data : CoupledPendulumData) (mode : Mode) (φ : ℝ) : ℝ :=
  (pendulum data).torque (EuclideanSpace.single 0 φ) 0 -
    data.length * springForce data mode φ * Real.cos φ

noncomputable def secondTorque (data : CoupledPendulumData) (mode : Mode) (φ : ℝ) : ℝ :=
  (pendulum data).torque (EuclideanSpace.single 0 (partnerAngle mode φ)) 0 +
    data.length * springForce data mode φ * Real.cos (partnerAngle mode φ)

/-- The adopted small-oscillation dynamics uses the derivative of each exact
mode-slice torque at equilibrium. No finite-angle sin φ = φ or cos φ = 1. -/
noncomputable def linearizedFirstTorque (data : CoupledPendulumData) (mode : Mode)
    (φ : ℝ) : ℝ := deriv (firstTorque data mode) 0 * φ
noncomputable def linearizedSecondTorque (data : CoupledPendulumData) (mode : Mode)
    (φ : ℝ) : ℝ := deriv (secondTorque data mode) 0 * φ

/-- A positive angular frequency must satisfy rotational Newton II for both
bobs in the chosen mode: angular acceleration is -ω² times angular position.
This semantic criterion contains no expected frequency formula. -/
def IsModeFrequency (data : CoupledPendulumData) (mode : Mode) (ω : ℝ) : Prop :=
  0 < ω ∧ ∀ φ,
    linearizedFirstTorque data mode φ = -(pendulum data).inertia * ω ^ 2 * φ ∧
    linearizedSecondTorque data mode φ =
      -(pendulum data).inertia * ω ^ 2 * partnerAngle mode φ

@[ext] structure ModeFrequencies where
  inPhase : ℝ
  antiPhase : ℝ

def IsModeFrequencySolution (data : CoupledPendulumData) (answer : ModeFrequencies) : Prop :=
  IsModeFrequency data .inPhase answer.inPhase ∧
  IsModeFrequency data .antiPhase answer.antiPhase

/-- Determine the two natural angular frequencies of this linearized system. -/
def TrustedPhysicsProblem (data : CoupledPendulumData) : Prop :=
  ∃! answer, IsModeFrequencySolution data answer

end LeanVerificationDemo.PhysicsDemo.P14
