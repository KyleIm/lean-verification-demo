import LeanVerificationDemo.PhysicsDemo.P10.Candidate
import Physlib.Units.WithDim.Basic

/-! Small unit layer: the graph's real coefficients use cm, seconds, cm/s and
cm/s². All types and conversions are upstream Physlib, not a new unit framework. -/
namespace LeanVerificationDemo.PhysicsDemo.P10.Units
open Dimension LTMCTUnitChoices CarriesDimension

abbrev Length := WithDim L𝓭 ℝ
abbrev Duration := WithDim T𝓭 ℝ
abbrev Velocity := WithDim (L𝓭 / T𝓭) ℝ
abbrev Acceleration := WithDim (L𝓭 / T𝓭 ^ (2 : ℕ)) ℝ

/-- Time remains SI seconds; only the length slot is changed to centimetres. -/
noncomputable def graphUnits : LTMCTUnitChoices := { SI with length := LengthUnit.centimeters }

lemma velocity_times_time : (L𝓭 / T𝓭) * T𝓭 = L𝓭 := by simp
lemma distance_div_time : L𝓭 * T𝓭⁻¹ = L𝓭 / T𝓭 := by rfl
lemma velocity_div_time : (L𝓭 / T𝓭) * T𝓭⁻¹ = L𝓭 / T𝓭 ^ (2 : ℕ) := by
  simp [div_eq_mul_inv, pow_two, mul_assoc]

noncomputable def typedMeanVelocity (T : ℝ) : Velocity :=
  ((⟨displacement T⟩ : Length) / (⟨T⟩ : Duration)).cast distance_div_time

noncomputable def typedMeanAcceleration (T : ℝ) : Acceleration :=
  (((⟨velocity T⟩ : Velocity) - (⟨velocity 0⟩ : Velocity)) /
    (⟨T⟩ : Duration)).cast velocity_div_time

/-- Exact same four scalar answers lifted to their proper dimensions; the
mean definitions and Candidate proof supply the values, not dimension analysis. -/
lemma typed_answers :
    typedMeanVelocity 5 = (⟨21 / 10⟩ : Velocity) ∧
    typedMeanAcceleration 5 = (⟨4 / 5⟩ : Acceleration) ∧
    typedMeanVelocity 10 = (⟨5 / 2⟩ : Velocity) ∧
    typedMeanAcceleration 10 = (⟨1 / 5⟩ : Acceleration) := by
  obtain ⟨hv5, ha5, hv10, ha10⟩ := Candidate.solution
  constructor
  · exact WithDim.ext _ _ hv5
  constructor
  · exact WithDim.ext _ _ ha5
  constructor
  · exact WithDim.ext _ _ hv10
  · exact WithDim.ext _ _ ha10

/-- A physical reported quantity, initialized at the caption's cm/s units. -/
noncomputable def reportedMeanVelocity (T : ℝ) : Dimensionful Velocity :=
  toDimensionful graphUnits (typedMeanVelocity T)
noncomputable def reportedMeanAcceleration (T : ℝ) : Dimensionful Acceleration :=
  toDimensionful graphUnits (typedMeanAcceleration T)

lemma reported_velocity_five : reportedMeanVelocity 5 graphUnits = (⟨21 / 10⟩ : Velocity) := by
  exact ((toDimensionful graphUnits).symm_apply_apply _).trans typed_answers.1

lemma reported_acceleration_ten :
    reportedMeanAcceleration 10 graphUnits = (⟨1 / 5⟩ : Acceleration) := by
  exact ((toDimensionful graphUnits).symm_apply_apply _).trans typed_answers.2.2.2

end LeanVerificationDemo.PhysicsDemo.P10.Units
