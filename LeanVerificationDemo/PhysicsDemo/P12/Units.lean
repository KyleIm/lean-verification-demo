import LeanVerificationDemo.PhysicsDemo.P12.Candidate
import Physlib.Units.WithDim.Speed

/-! Additive dimension/SI checks; the 70 table estimates remain exact scalar
calculations. These definitions specialize upstream quantities, not a new unit
framework. Dimensional validity does not supply a braking/friction law. -/
namespace LeanVerificationDemo.PhysicsDemo.P12.Units
open Dimension LTMCTUnitChoices UnitDependent CarriesDimension NNReal

abbrev velocityDim : Dimension LTMCTDimensionBase := L𝓭 / T𝓭
abbrev accelerationDim : Dimension LTMCTDimensionBase := L𝓭 / T𝓭 ^ (2 : ℕ)
abbrev Velocity := WithDim velocityDim ℝ
abbrev Acceleration := WithDim accelerationDim ℝ
abbrev Length := WithDim L𝓭 ℝ
abbrev Coefficient := WithDim (1 : Dimension LTMCTDimensionBase) ℝ

lemma stopping_dimensions : velocityDim * velocityDim = accelerationDim * L𝓭 := by
  ext b
  cases b <;> norm_num [velocityDim, accelerationDim, Dimension.div_exponent,
    Dimension.mul_exponent, Dimension.npow_exponent]

lemma coefficient_dimensions :
    (velocityDim * velocityDim) / (accelerationDim * L𝓭) = 1 := by
  rw [div_eq_mul_inv, stopping_dimensions]
  exact mul_inv_cancel _

/-- Real 2 acts dimensionlessly on the denominator; the result has dimension 1. -/
noncomputable def coefficientRhs (v : Velocity) (g : Acceleration) (s : Length) : Coefficient :=
  ((v * v) / ((2 : ℝ) • (g * s))).cast coefficient_dimensions

/-- Actual upstream quantity conversion, not a scalar conversion assumption. -/
lemma kilometre_per_hour_in_SI :
    DimSpeed.oneKilometerPerHour SI = (⟨5 / 18⟩ : WithDim (L𝓭 * T𝓭⁻¹) ℝ≥0) :=
  DimSpeed.oneKilometerPerHour_in_SI

def sourceSpeedMagnitude (i : Fin 10) : ℝ≥0 :=
  ⟨speedKmh i, by fin_cases i <;> norm_num [speedKmh]⟩

noncomputable def sourceSpeed (i : Fin 10) : DimSpeed :=
  sourceSpeedMagnitude i • DimSpeed.oneKilometerPerHour

/-- Every source speed is converted through the named upstream km/h quantity. -/
lemma source_speed_in_SI (i : Fin 10) :
    (((sourceSpeed i) SI).val : ℝ) = speedSI i := by
  unfold sourceSpeed
  rw [Dimensionful.smul_apply, DimSpeed.oneKilometerPerHour_in_SI]
  change speedKmh i * (5 / 18) = (5 / 18) * speedKmh i
  ring

/-- Lift the upstream converted magnitude into the real-coordinate WithDim
quantity needed for heterogeneous multiplication/division. -/
noncomputable def velocitySI (i : Fin 10) : Velocity :=
  ⟨(((sourceSpeed i) SI).val : ℝ)⟩

noncomputable def distanceQuantity (p : Pavement) (i : Fin 10) : Dimensionful Length :=
  toDimensionful SI ⟨brakingDistance p i⟩

/-- g=9.8 is explicitly a numerical model choice, initialized in coherent SI. -/
noncomputable def gravityQuantity : Dimensionful Acceleration := toDimensionful SI ⟨gravity⟩

lemma coordinate_at_SI {d : Dimension LTMCTDimensionBase} (q : WithDim d ℝ) :
    (toDimensionful SI q) SI = q := (toDimensionful SI).symm_apply_apply q

/-- Dimensionless typed expression and the scalar estimator agree. This bridge
does not repeat the 70 calculations or assert any rounded answer as input. -/
lemma typed_table_estimate (p : Pavement) (i : Fin 10) :
    coefficientRhs (velocitySI i) (gravityQuantity SI) (distanceQuantity p i SI) =
      (⟨tableEstimate p i⟩ : Coefficient) := by
  rw [show gravityQuantity SI = (⟨gravity⟩ : Acceleration) from coordinate_at_SI _,
    show distanceQuantity p i SI = (⟨brakingDistance p i⟩ : Length) from coordinate_at_SI _]
  apply WithDim.ext
  change (((sourceSpeed i) SI).val : ℝ) * (((sourceSpeed i) SI).val : ℝ) /
    (2 * (gravity * brakingDistance p i)) = tableEstimate p i
  rw [source_speed_in_SI]
  unfold tableEstimate frictionEstimate
  ring

/-- Dimensionless coefficients retain their magnitude when units change. -/
lemma coefficient_unit_invariant (c : Coefficient) (u₁ u₂ : LTMCTUnitChoices) :
    scaleUnit u₁ u₂ c = c := WithDim.scaleUnit_dim_eq_zero c u₁ u₂ rfl

end LeanVerificationDemo.PhysicsDemo.P12.Units
