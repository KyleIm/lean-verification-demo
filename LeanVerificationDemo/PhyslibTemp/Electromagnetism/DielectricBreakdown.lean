import LeanVerificationDemo.PhyslibTemp.Electromagnetism.PlaneCapacitor

/-!
# Optional dielectric-breakdown specification for a plane capacitor

A generic `PlaneCapacitor` does not require dielectric-failure data. This separate
specification adds a positive breakdown field when needed. The threshold is
inclusive (U ≤ U_break), an idealized modeling convention permitting an attained
maximum. A strict safety criterion would instead require a supremum formulation.
-/
namespace LeanVerificationDemo.PhyslibTemp.Electromagnetism

/-- Optional positive dielectric-breakdown field attached to a specific capacitor.
The index ties this specification to the capacitor whose gap it uses. -/
structure BreakdownSpec (c : PlaneCapacitor) where
  breakdownField : FieldMagnitude
  breakdown_pos : 0 < breakdownField.val

namespace BreakdownSpec

variable {c : PlaneCapacitor}

/-- Threshold voltage E_break d for the specified uniform-gap capacitor. -/
noncomputable def breakdownVoltage (spec : BreakdownSpec c) : Voltage :=
  ⟨spec.breakdownField.val * c.gap.val⟩

/-- Inclusive idealized breakdown admissibility for nonnegative charge magnitude. -/
def Admissible (spec : BreakdownSpec c) (q : Charge) : Prop :=
  0 ≤ q.val ∧ (c.voltage q).val ≤ spec.breakdownVoltage.val

/-- The voltage bound is exactly the field breakdown bound for positive gap. -/
lemma field_le_iff (spec : BreakdownSpec c) (q : Charge) :
    (c.field q).val ≤ spec.breakdownField.val ↔
      (c.voltage q).val ≤ spec.breakdownVoltage.val := by
  exact div_le_iff₀ c.gap_pos

/-- Charge reaching the threshold of this optional breakdown specification. -/
noncomputable def chargeAtLimit (spec : BreakdownSpec c) : Charge :=
  ⟨c.C.val * spec.breakdownVoltage.val⟩

lemma voltage_at_limit (spec : BreakdownSpec c) :
    (c.voltage spec.chargeAtLimit).val = spec.breakdownVoltage.val := by
  dsimp [PlaneCapacitor.voltage, chargeAtLimit]
  exact mul_div_cancel_left₀ _ c.C_pos.ne'

lemma admissible_at_limit (spec : BreakdownSpec c) : spec.Admissible spec.chargeAtLimit := by
  constructor
  · exact mul_nonneg c.C_pos.le (mul_nonneg spec.breakdown_pos.le c.gap_pos.le)
  · exact spec.voltage_at_limit.le

end BreakdownSpec

end LeanVerificationDemo.PhyslibTemp.Electromagnetism
