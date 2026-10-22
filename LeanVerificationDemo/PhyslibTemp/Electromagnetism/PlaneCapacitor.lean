import Physlib.Units.WithDim.Basic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

/-!
# Ideal plane capacitors in fixed coherent SI coordinates

Reuse Physlib's LTMCT dimension basis and `WithDim`. These type abbreviations
name existing generic coordinate quantities, not a new unit framework.
The model assumes a uniform field, linear dielectric, negligible fringe effects
and leakage. Voltages/charges are magnitudes. The breakdown threshold is inclusive.
-/
namespace LeanVerificationDemo.PhyslibTemp.Electromagnetism

open Dimension

/-- Charge coordinate in coulombs. -/
abbrev Charge := WithDim C𝓭 ℝ
/-- Voltage coordinate in volts (energy per charge). -/
abbrev Voltage := WithDim (M𝓭 * L𝓭 ^ 2 / T𝓭 ^ 2 / C𝓭) ℝ
/-- Capacitance coordinate in farads (charge per voltage). -/
abbrev Capacitance := WithDim (C𝓭 / (M𝓭 * L𝓭 ^ 2 / T𝓭 ^ 2 / C𝓭)) ℝ
/-- Uniform electric-field magnitude in volts per metre. -/
abbrev FieldMagnitude := WithDim (M𝓭 * L𝓭 / T𝓭 ^ 2 / C𝓭) ℝ
/-- Separation coordinate in metres. -/
abbrev Separation := WithDim L𝓭 ℝ

/-- Ideal linear plane capacitor with a positive gap and breakdown field. -/
structure PlaneCapacitor where
  C : Capacitance
  gap : Separation
  breakdownField : FieldMagnitude
  C_pos : 0 < C.val
  gap_pos : 0 < gap.val
  breakdown_pos : 0 < breakdownField.val

namespace PlaneCapacitor

/-- Constitutive capacitor law U = Q/C, in fixed coherent SI coordinates. -/
noncomputable def voltage (c : PlaneCapacitor) (q : Charge) : Voltage :=
  ⟨q.val / c.C.val⟩

/-- Uniform plane-gap field E = U/d; no general field reconstruction is claimed. -/
noncomputable def field (c : PlaneCapacitor) (q : Charge) : FieldMagnitude :=
  ⟨(c.voltage q).val / c.gap.val⟩

/-- Threshold voltage E_break d for this uniform-gap model. -/
noncomputable def breakdownVoltage (c : PlaneCapacitor) : Voltage :=
  ⟨c.breakdownField.val * c.gap.val⟩

/-- Inclusive idealized breakdown admissibility for nonnegative charge magnitude. -/
def Admissible (c : PlaneCapacitor) (q : Charge) : Prop :=
  0 ≤ q.val ∧ (c.voltage q).val ≤ c.breakdownVoltage.val

/-- The voltage bound is exactly the field breakdown bound for positive gap. -/
lemma field_le_iff (c : PlaneCapacitor) (q : Charge) :
    (c.field q).val ≤ c.breakdownField.val ↔
      (c.voltage q).val ≤ c.breakdownVoltage.val := by
  exact div_le_iff₀ c.gap_pos

/-- Uniform-field voltage relation U = E d. -/
lemma voltage_eq_field_mul_gap (c : PlaneCapacitor) (q : Charge) :
    (c.voltage q).val = (c.field q).val * c.gap.val := by
  dsimp [field]
  exact (div_mul_cancel₀ _ c.gap_pos.ne').symm

/-- Charge that reaches this capacitor's idealized breakdown threshold. -/
noncomputable def chargeAtLimit (c : PlaneCapacitor) : Charge :=
  ⟨c.C.val * c.breakdownVoltage.val⟩

lemma voltage_at_limit (c : PlaneCapacitor) :
    (c.voltage c.chargeAtLimit).val = c.breakdownVoltage.val := by
  dsimp [voltage, chargeAtLimit]
  exact mul_div_cancel_left₀ _ c.C_pos.ne'

lemma admissible_at_limit (c : PlaneCapacitor) : c.Admissible c.chargeAtLimit := by
  constructor
  · exact mul_nonneg c.C_pos.le (mul_nonneg c.breakdown_pos.le c.gap_pos.le)
  · exact (c.voltage_at_limit).le

end PlaneCapacitor

/-- At fixed plate area and separation, a relative-permittivity factor multiplies
capacitance. This is a supplied constitutive premise for equal-area plates;
area is not independently modeled. It does not solve Maxwell equations. -/
def DielectricScaling (reference filled : PlaneCapacitor) (εr : ℝ) : Prop :=
  filled.gap = reference.gap ∧ filled.C.val = εr * reference.C.val

/-- Equal-magnitude series charge and dielectric scaling imply inverse voltage scaling.
The common argument q expresses the series-charge premise, not a circuit theorem. -/
lemma voltage_of_dielectric_scaling (a b : PlaneCapacitor) (εr : ℝ)
    (h : DielectricScaling a b εr) (q : Charge) :
    (b.voltage q).val = (a.voltage q).val / εr := by
  change q.val / b.C.val = (q.val / a.C.val) / εr
  rw [h.2]
  have arithmetic (x y z : ℝ) : x / (z * y) = (x / y) / z := by
    rw [div_div]
    congr 1
    ring
  exact arithmetic q.val a.C.val εr

end LeanVerificationDemo.PhyslibTemp.Electromagnetism
