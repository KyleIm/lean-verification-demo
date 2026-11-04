import LeanVerificationDemo.PhysicsDemo.P14.Candidate
import Physlib.ClassicalMechanics.HarmonicOscillator.WithDim

namespace LeanVerificationDemo.PhysicsDemo.P14.Units
open Dimension

abbrev accelerationDim : Dimension LTMCTDimensionBase := L𝓭 / T𝓭 ^ (2 : ℕ)
abbrev forceDim : Dimension LTMCTDimensionBase := M𝓭 * accelerationDim
abbrev springDim : Dimension LTMCTDimensionBase := M𝓭 * T𝓭⁻¹ * T𝓭⁻¹
abbrev squaredAngularFrequencyDim : Dimension LTMCTDimensionBase := T𝓭⁻¹ * T𝓭⁻¹
abbrev angularFrequencyDim : Dimension LTMCTDimensionBase := T𝓭⁻¹
abbrev Length := WithDim L𝓭 ℝ
abbrev Mass := WithDim M𝓭 ℝ
abbrev Acceleration := WithDim accelerationDim ℝ
abbrev SpringConstant := WithDim springDim ℝ
abbrev SquaredAngularFrequency := WithDim squaredAngularFrequencyDim ℝ
abbrev AngularFrequency := WithDim angularFrequencyDim ℝ

lemma hooke_dimension : springDim * L𝓭 = forceDim := by decide
lemma gravity_over_length_dimension : accelerationDim / L𝓭 = squaredAngularFrequencyDim := by
  decide
lemma spring_over_mass_dimension : springDim / M𝓭 = squaredAngularFrequencyDim := by decide
lemma spring_length_over_mass_dimension : springDim * L𝓭 / M𝓭 = accelerationDim := by decide
lemma angular_frequency_root_dimension :
    squaredAngularFrequencyDim ^ (1 / 2 : ℚ) = angularFrequencyDim := by
  ext b
  cases b <;> norm_num [squaredAngularFrequencyDim, angularFrequencyDim,
    Dimension.mul_exponent, Dimension.inv_exponent, Dimension.qpow_exponent]
  all_goals
    apply Exponent.coe_inj.mp
    norm_num [Exponent.ofRat]

/-- Actual WithDim addition requires both radicand terms to have T⁻² dimension. -/
noncomputable def squaredInPhase (g : Acceleration) (l : Length) : SquaredAngularFrequency :=
  (g / l).cast gravity_over_length_dimension
noncomputable def squaredAntiPhase (g : Acceleration) (l : Length)
    (k : SpringConstant) (m : Mass) : SquaredAngularFrequency :=
  squaredInPhase g l + (((2 : ℝ) • k) / m).cast spring_over_mass_dimension

/-- Radians are dimensionless. This local wrapper uses upstream rational
dimension powers; the pinned WithDim has no quantity sqrt operation. -/
noncomputable def angularRoot (q : SquaredAngularFrequency) : AngularFrequency :=
  (⟨Real.sqrt q.val⟩ : WithDim (squaredAngularFrequencyDim ^ (1 / 2 : ℚ)) ℝ).cast
    angular_frequency_root_dimension

noncomputable def sourceForm (g : Acceleration) (l : Length)
    (k : SpringConstant) (m : Mass) : SquaredAngularFrequency :=
  ((g + ((((2 : ℝ) • k) * l) / m).cast spring_length_over_mass_dimension) / l).cast
    gravity_over_length_dimension

/-- The two source-solution radicands are equal as typed quantities. -/
lemma source_form_eq (data : CoupledPendulumData) :
    sourceForm ⟨data.gravity⟩ ⟨data.length⟩ ⟨data.springConstant⟩ ⟨data.mass⟩ =
      squaredAntiPhase ⟨data.gravity⟩ ⟨data.length⟩ ⟨data.springConstant⟩ ⟨data.mass⟩ := by
  apply WithDim.ext
  change (data.gravity + 2 * data.springConstant * data.length / data.mass) / data.length =
    data.gravity / data.length + 2 * data.springConstant / data.mass
  field_simp [data.mass_pos.ne', data.length_pos.ne']

lemma typed_in_phase (data : CoupledPendulumData) :
    angularRoot (squaredInPhase ⟨data.gravity⟩ ⟨data.length⟩) =
      (⟨(Candidate.solutionFrequencies data).inPhase⟩ : AngularFrequency) := rfl

lemma typed_anti_phase (data : CoupledPendulumData) :
    angularRoot (squaredAntiPhase ⟨data.gravity⟩ ⟨data.length⟩
      ⟨data.springConstant⟩ ⟨data.mass⟩) =
      (⟨(Candidate.solutionFrequencies data).antiPhase⟩ : AngularFrequency) := rfl

/-- Upstream already provides dimension-tagged mass and Hooke stiffness.
No P14 unit framework or PhyslibTemp extension is introduced. -/
def physicalSpring (data : CoupledPendulumData) : ClassicalMechanics.HarmonicOscillatorWithDim where
  m := ⟨data.mass⟩
  k := ⟨data.springConstant⟩
  m_pos := data.mass_pos
  k_pos := data.spring_pos

end LeanVerificationDemo.PhysicsDemo.P14.Units
