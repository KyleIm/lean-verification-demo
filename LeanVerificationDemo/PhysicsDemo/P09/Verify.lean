import LeanVerificationDemo.PhysicsDemo.P09.Candidate
import LeanVerificationDemo.PhysicsDemo.P09.Units
import LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.ConstantAccelerationExamples

namespace LeanVerificationDemo.PhysicsDemo.P09.Verifier
open LeanVerificationDemo.PhyslibTemp.ClassicalMechanics

example (data : PuckData) (source : SourceData data) :
    TrustedPhysicsProblem data := Candidate.solution data source

/-- Independent consistency witnesses, not source-prescribed trajectories.
Unit mass, unit friction force and unit deceleration determine the model;
the coefficient is chosen as F/N, not supplied as a final-answer premise. -/
noncomputable def pathParticle (u : ℝ) : trackFrame.Particle :=
  Examples.quadraticParticle ⟨1, by norm_num⟩ 0 (u • tangent) ((-1 : ℝ) • tangent)

lemma path_speed (u t : ℝ) : speed (pathParticle u) t = u - t := by
  unfold speed pathParticle
  rw [Examples.quadratic_velocity]
  change u * 1 + t * (-1 * 1) = u - t
  ring

lemma path_travel (u t : ℝ) : travel (pathParticle u) t = u * t - t ^ 2 / 2 := by
  unfold travel pathParticle Examples.quadraticParticle
  change (0 + t * (u * 1) + (t ^ 2 / 2) * (-1 * 1)) -
    (0 + 0 * (u * 1) + ((0 : ℝ) ^ 2 / 2) * (-1 * 1)) = u * t - t ^ 2 / 2
  ring

lemma path_acceleration (u t : ℝ) :
    (pathParticle u).acceleration t = (-1 : ℝ) • tangent :=
  Examples.quadratic_constant ⟨1, by norm_num⟩ 0 (u • tangent) ((-1 : ℝ) • tangent) t

noncomputable def witness : PuckData where
  before := pathParticle 5
  after := pathParticle (Real.sqrt 5)
  firstDuration := 5 - Real.sqrt 5
  firstDuration_pos := by
    have hs := Real.sq_sqrt (show (0 : ℝ) ≤ 5 by norm_num)
    have hp := Real.sqrt_nonneg (5 : ℝ)
    nlinarith
  secondDuration := Real.sqrt 5
  secondDuration_pos := Real.sqrt_pos.mpr (by norm_num)
  initialSpeed := 5
  initialSpeed_pos := by norm_num
  firstPath := 10
  firstPath_pos := by norm_num
  secondPath := 5 / 2
  secondPath_pos := by norm_num
  g := 49 / 5
  g_pos := by norm_num
  μ := 1 / (49 / 5)
  μ_nonneg := by norm_num
  normalReaction := 49 / 5
  frictionMagnitude := 1

lemma witness_model : SlidingModel witness := by
  have hs := Real.sq_sqrt (show (0 : ℝ) ≤ 5 by norm_num)
  constructor
  · rfl
  · norm_num [witness, pathParticle, Examples.quadraticParticle]
  · norm_num [witness]
  · intro t
    change (pathParticle 5).mass.val * ((pathParticle 5).acceleration t).components 0 = -1
    rw [path_acceleration]
    change (1 : ℝ) * (-1 * 1) = -1
    norm_num
  · intro t
    change (pathParticle (Real.sqrt 5)).mass.val *
      ((pathParticle (Real.sqrt 5)).acceleration t).components 0 = -1
    rw [path_acceleration]
    change (1 : ℝ) * (-1 * 1) = -1
    norm_num
  · change speed (pathParticle 5) 0 = 5
    rw [path_speed]
    ring
  · change travel (pathParticle 5) (5 - Real.sqrt 5) = 10
    rw [path_travel]
    nlinarith
  · change travel (pathParticle (Real.sqrt 5)) (Real.sqrt 5) = 5 / 2
    rw [path_travel]
    nlinarith
  · change 0 ≤ speed (pathParticle 5) (5 - Real.sqrt 5)
    rw [path_speed]
    linarith [Real.sqrt_nonneg (5 : ℝ)]
  · change ElasticFixedBoardImpact
      (speed (pathParticle 5) (5 - Real.sqrt 5)) (speed (pathParticle (Real.sqrt 5)) 0)
    unfold ElasticFixedBoardImpact
    rw [path_speed, path_speed]
    ring
  · change speed (pathParticle (Real.sqrt 5)) (Real.sqrt 5) = 0
    rw [path_speed]
    ring

lemma witness_source : SourceData witness where
  model := witness_model
  initial_value := rfl
  first_path_value := rfl
  second_path_value := rfl
  gravity_value := rfl

-- Explicit source-data consistency, nonzero launch, positive paths and final rest.
example : SourceData witness := witness_source
example : witness.initialSpeed ≠ 0 := witness.initialSpeed_pos.ne'
example : 0 < witness.firstPath ∧ 0 < witness.secondPath :=
  ⟨witness.firstPath_pos, witness.secondPath_pos⟩
example : speed witness.after witness.secondDuration = 0 := witness_model.final_at_rest

-- Impact speed and both physical interval velocities are genuinely nonnegative.
example : speed witness.before witness.firstDuration = Real.sqrt 5 := by
  change speed (pathParticle 5) (5 - Real.sqrt 5) = Real.sqrt 5
  rw [path_speed]
  ring

example : |speed witness.before witness.firstDuration| = |speed witness.after 0| :=
  Candidate.impact_preserves_speed witness witness_model

example : witness.μ = (5 : ℝ) / 49 := Candidate.coefficient_exact witness witness_source
example : |witness.μ - (102 : ℝ) / 1000| < 1 / 2000 :=
  Candidate.coefficient_source_value witness witness_source
example : (1020408 : ℝ) / 10000000 < witness.μ ∧ witness.μ < (1020409 : ℝ) / 10000000 :=
  Candidate.coefficient_decimal_interval witness witness_source

-- Guard against confusing the printed rounded answer with an exact identity.
example : witness.μ ≠ (102 : ℝ) / 1000 := by
  rw [Candidate.coefficient_exact witness witness_source]
  norm_num

-- Additive unit layer: the original mechanics/source witnesses are unchanged.
example (data : PuckData) (source : SourceData data) :
    (⟨data.μ⟩ : Units.Coefficient) = Units.coefficientRhs
      (⟨data.initialSpeed⟩ : Units.Velocity) (⟨data.g⟩ : Units.Acceleration)
      ((⟨data.firstPath⟩ : Units.Length) + (⟨data.secondPath⟩ : Units.Length)) :=
  Units.typed_coefficient_equation data source.model

example : (⟨witness.μ⟩ : Units.Coefficient) = (⟨5 / 49⟩ : Units.Coefficient) :=
  Units.typed_source_answer witness witness_source

example : Units.coefficientRhs (Units.initialVelocity LTMCTUnitChoices.SI)
    (Units.gravity LTMCTUnitChoices.SI)
    (Units.firstDistance LTMCTUnitChoices.SI + Units.secondDistance LTMCTUnitChoices.SI) =
      (⟨5 / 49⟩ : Units.Coefficient) := Units.source_coefficient_in_SI

-- This negative dimensional check is an ordinary proved inequality of dimensions,
-- rather than a deliberately broken equality left in a compiling source file.
example : Units.velocityDim / (Units.accelerationDim * Dimension.L𝓭) ≠ 1 :=
  Units.incorrect_formula_not_dimensionless

end LeanVerificationDemo.PhysicsDemo.P09.Verifier
