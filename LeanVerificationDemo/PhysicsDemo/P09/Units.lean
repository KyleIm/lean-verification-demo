import LeanVerificationDemo.PhysicsDemo.P09.Candidate
import Physlib.Units.WithDim.Basic
import Physlib.Units.WithDim.Speed
import Physlib.Units.WithDim.Energy

/-!
# P09: dimensional verification beside the unchanged mechanics proof

All quantity aliases below specialize upstream `WithDim`; no quantity structure,
dimension algebra or conversion framework is introduced. The LTMCT basis is
sufficient for this mechanics problem, and `LTMCTUnitChoices.SI` fixes coherent
metres, seconds and kilograms. Products/divisions are upstream heterogeneous
operations. `WithDim.cast` is used only with a proved dimension equality.

Dimensional homogeneity does not supply the friction or collision physics.
The typed mechanics statements below explicitly use Candidate's scalar proofs.
-/
namespace LeanVerificationDemo.PhysicsDemo.P09.Units

open Dimension CarriesDimension LTMCTUnitChoices UnitDependent

abbrev velocityDim : Dimension LTMCTDimensionBase := L𝓭 / T𝓭
abbrev accelerationDim : Dimension LTMCTDimensionBase := L𝓭 / T𝓭 ^ (2 : ℕ)
abbrev forceDim : Dimension LTMCTDimensionBase := M𝓭 * L𝓭 / T𝓭 ^ (2 : ℕ)
abbrev energyDim : Dimension LTMCTDimensionBase := forceDim * L𝓭

abbrev Length := WithDim L𝓭 ℝ
abbrev Duration := WithDim T𝓭 ℝ
abbrev Mass := WithDim M𝓭 ℝ
abbrev Velocity := WithDim velocityDim ℝ
abbrev Acceleration := WithDim accelerationDim ℝ
abbrev Force := WithDim forceDim ℝ
abbrev Energy := WithDim energyDim ℝ
abbrev Coefficient := WithDim (1 : Dimension LTMCTDimensionBase) ℝ

lemma coefficient_has_dimension_one : dim Coefficient = 1 := rfl

/-- Necessity and sufficiency of dimensionless μ is a homogeneity condition,
not an inference from a numerical force equality (which could involve zero). -/
lemma friction_dimensions_iff (d : Dimension LTMCTDimensionBase) :
    d * forceDim = forceDim ↔ d = 1 := by
  constructor
  · intro h
    exact mul_right_cancel (h.trans (one_mul _).symm)
  · intro h
    simp [h]

lemma newton_dimensions : M𝓭 * accelerationDim = forceDim := by
  simp [accelerationDim, forceDim, div_eq_mul_inv, mul_assoc]

lemma stopping_dimensions : velocityDim * velocityDim = accelerationDim * L𝓭 := by
  ext b
  cases b <;> norm_num [velocityDim, accelerationDim, Dimension.div_exponent,
    Dimension.mul_exponent, Dimension.npow_exponent]

lemma speed_squared_dimensions : velocityDim ^ (2 : ℕ) = accelerationDim * L𝓭 := by
  simpa only [pow_two] using stopping_dimensions

/-- [v²/(gs)] = 1. The real multiplier 2 acts dimensionlessly on the denominator. -/
lemma coefficient_dimensions :
    (velocityDim * velocityDim) * (accelerationDim * L𝓭)⁻¹ = 1 := by
  rw [stopping_dimensions]
  exact mul_inv_cancel _

lemma energy_dimensions : M𝓭 * (velocityDim * velocityDim) = energyDim := by
  ext b
  cases b <;> norm_num [velocityDim, energyDim, forceDim, Dimension.div_exponent,
    Dimension.mul_exponent, Dimension.npow_exponent] <;> ring

/-- The deliberately wrong v/(gs) has dimension T/L, not dimensionless. -/
lemma incorrect_formula_dimension : velocityDim / (accelerationDim * L𝓭) = T𝓭 / L𝓭 := by
  ext b
  cases b <;> norm_num [velocityDim, accelerationDim, Dimension.div_exponent,
    Dimension.mul_exponent, Dimension.npow_exponent]

lemma incorrect_formula_not_dimensionless : velocityDim / (accelerationDim * L𝓭) ≠ 1 := by
  intro h
  have hx := congrArg (fun d : Dimension LTMCTDimensionBase => d.exponent .length) h
  norm_num [velocityDim, accelerationDim, Dimension.div_exponent,
    Dimension.mul_exponent, Dimension.npow_exponent] at hx

/-- Typed μN: upstream multiplication, followed by the identity-dimension law. -/
def frictionForce (μ : Coefficient) (N : Force) : Force :=
  (μ * N).cast (one_mul forceDim)

def newtonForce (m : Mass) (a : Acceleration) : Force :=
  (m * a).cast newton_dimensions

/-- WithDim uses heterogeneous multiplication for squaring a quantity. -/
def speedSquared (v : Velocity) : WithDim (accelerationDim * L𝓭) ℝ :=
  (v * v).cast stopping_dimensions

noncomputable def coefficientRhs (v : Velocity) (g : Acceleration) (s : Length) : Coefficient :=
  ((v * v) / ((2 : ℝ) • (g * s))).cast coefficient_dimensions

/-- Optional dimension check only: mv²/2 is an energy, whose dimension is N·m.
This is not a replacement energy proof of P09. -/
noncomputable def kineticEnergyExpression (m : Mass) (v : Velocity) : Energy :=
  ((1 / 2 : ℝ) • (m * (v * v))).cast energy_dimensions

/-- Lift the existing friction-model equality into two Force-typed quantities.
The dimensional product alone does not establish this physical equality. -/
lemma typed_friction (data : PuckData) (model : SlidingModel data) :
    (⟨data.frictionMagnitude⟩ : Force) =
      frictionForce (⟨data.μ⟩ : Coefficient) (⟨data.normalReaction⟩ : Force) := by
  apply WithDim.ext
  exact model.sliding_friction

/-- Algebraic F = ma for the defined deceleration magnitude F/m. Candidate's
Newton-II lemmas establish its physical connection to the trajectory acceleration. -/
lemma typed_newton (data : PuckData) :
    (⟨data.frictionMagnitude⟩ : Force) =
      newtonForce (⟨data.before.mass.val⟩ : Mass) (⟨deceleration data⟩ : Acceleration) := by
  apply WithDim.ext
  change data.frictionMagnitude = data.before.mass.val *
    (data.frictionMagnitude / data.before.mass.val)
  field_simp [data.before.mass.property.ne']

lemma typed_friction_acceleration (data : PuckData) (model : SlidingModel data) :
    (⟨deceleration data⟩ : Acceleration) =
      ((⟨data.μ⟩ : Coefficient) * (⟨data.g⟩ : Acceleration)).cast
        (one_mul accelerationDim) := by
  apply WithDim.ext
  exact Candidate.friction_acceleration data model

lemma typed_stopping_relation (data : PuckData) (model : SlidingModel data) :
    speedSquared (⟨data.initialSpeed⟩ : Velocity) =
      (2 : ℝ) • ((⟨deceleration data⟩ : Acceleration) *
        ((⟨data.firstPath⟩ : Length) + (⟨data.secondPath⟩ : Length))) := by
  apply WithDim.ext
  change data.initialSpeed * data.initialSpeed =
    2 * (deceleration data * (data.firstPath + data.secondPath))
  simpa only [pow_two, mul_assoc] using Candidate.stopping_relation data model

/-- An equality between dimensionless quantities, justified by the existing
mechanics derivation and an explicit SI-coordinate lift. -/
lemma typed_coefficient_equation (data : PuckData) (model : SlidingModel data) :
    (⟨data.μ⟩ : Coefficient) = coefficientRhs
      (⟨data.initialSpeed⟩ : Velocity) (⟨data.g⟩ : Acceleration)
      ((⟨data.firstPath⟩ : Length) + (⟨data.secondPath⟩ : Length)) := by
  apply WithDim.ext
  change data.μ = (data.initialSpeed * data.initialSpeed) /
    (2 * (data.g * (data.firstPath + data.secondPath)))
  simpa only [pow_two, mul_assoc] using Candidate.coefficient_symbolic data model

lemma typed_source_answer (data : PuckData) (source : SourceData data) :
    (⟨data.μ⟩ : Coefficient) = (⟨5 / 49⟩ : Coefficient) := by
  apply WithDim.ext
  exact Candidate.coefficient_exact data source

/-- A genuinely dimensionless coefficient does not change numerical magnitude
when units change. This is upstream unit covariance, not a P09 assumption. -/
lemma coefficient_unit_invariant (μ : Coefficient) (u₁ u₂ : LTMCTUnitChoices) :
    scaleUnit u₁ u₂ μ = μ :=
  WithDim.scaleUnit_dim_eq_zero μ u₁ u₂ rfl

/-! Source values are unit-dependent quantities initialized in upstream SI.
Thus their SI numerical coefficients are explicit, not unlabelled reals. -/
noncomputable def metre : Dimensionful Length := toDimensionful SI ⟨1⟩
noncomputable def second : Dimensionful Duration := toDimensionful SI ⟨1⟩
noncomputable def kilogram : Dimensionful Mass := toDimensionful SI ⟨1⟩
noncomputable def newton : Dimensionful Force := toDimensionful SI ⟨1⟩
noncomputable def initialVelocity : Dimensionful Velocity := toDimensionful SI ⟨5⟩
noncomputable def firstDistance : Dimensionful Length := toDimensionful SI ⟨10⟩
noncomputable def secondDistance : Dimensionful Length := toDimensionful SI ⟨5 / 2⟩
noncomputable def gravity : Dimensionful Acceleration := toDimensionful SI ⟨49 / 5⟩

/-- Upstream's unit-choice equivalence recovers the starting SI coordinates. -/
lemma coordinate_at_SI {d : Dimension LTMCTDimensionBase} (q : WithDim d ℝ) :
    (toDimensionful SI q) SI = q :=
  (toDimensionful SI).symm_apply_apply q

lemma base_units_in_SI :
    metre SI = (⟨1⟩ : Length) ∧ second SI = (⟨1⟩ : Duration) ∧
    kilogram SI = (⟨1⟩ : Mass) ∧ newton SI = (⟨1⟩ : Force) := by
  exact ⟨coordinate_at_SI _, coordinate_at_SI _, coordinate_at_SI _, coordinate_at_SI _⟩

lemma source_values_in_SI :
    initialVelocity SI = (⟨5⟩ : Velocity) ∧
    firstDistance SI = (⟨10⟩ : Length) ∧
    secondDistance SI = (⟨5 / 2⟩ : Length) ∧
    gravity SI = (⟨49 / 5⟩ : Acceleration) := by
  exact ⟨coordinate_at_SI _, coordinate_at_SI _, coordinate_at_SI _, coordinate_at_SI _⟩

lemma total_distance_in_SI :
    firstDistance SI + secondDistance SI = (⟨25 / 2⟩ : Length) := by
  rw [source_values_in_SI.2.1, source_values_in_SI.2.2.1]
  apply WithDim.ext
  norm_num

/-- Actual heterogeneous quantity arithmetic evaluates the source expression
to a dimensionless rational; no floating-point arithmetic or mechanics premise. -/
lemma source_coefficient_in_SI :
    coefficientRhs (initialVelocity SI) (gravity SI)
      (firstDistance SI + secondDistance SI) = (⟨5 / 49⟩ : Coefficient) := by
  rw [source_values_in_SI.1, source_values_in_SI.2.2.2, total_distance_in_SI]
  apply WithDim.ext
  norm_num [coefficientRhs, WithDim.cast, WithDim.withDim_hMul_val,
    ← WithDim.val_div_val, WithDim.real_smul_val]

/-- Existing named speed API agrees with the real-valued quantity used in the
heterogeneous arithmetic (the named API itself uses nonnegative coordinates). -/
lemma named_speed_in_SI :
    (((5 : NNReal) • DimSpeed.oneMeterPerSecond) SI).val = 5 := by
  simp

lemma joule_is_newton_metre :
    (DimEnergy.joule SI).cast
      (show M𝓭 * L𝓭 * L𝓭 * T𝓭⁻¹ * T𝓭⁻¹ = energyDim by
        ext b
        cases b <;> norm_num [energyDim, forceDim, Dimension.mul_exponent,
          Dimension.div_exponent, Dimension.npow_exponent, Dimension.inv_exponent]
        all_goals ring) =
      ((newton SI) * (metre SI) : Energy) := by
  rw [show DimEnergy.joule SI =
    (⟨1⟩ : WithDim (M𝓭 * L𝓭 * L𝓭 * T𝓭⁻¹ * T𝓭⁻¹) ℝ) from coordinate_at_SI _]
  rw [base_units_in_SI.2.2.2, base_units_in_SI.1]
  apply WithDim.ext
  change (1 : ℝ) = 1 * 1
  norm_num

end LeanVerificationDemo.PhysicsDemo.P09.Units
