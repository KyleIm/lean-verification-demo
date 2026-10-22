import LeanVerificationDemo.PhyslibTemp.Electromagnetism.PlaneCapacitor

namespace LeanVerificationDemo.PhysicsDemo.P03

open PhyslibTemp.Electromagnetism

/-- Two materials with identical geometry; all three/four air components are
copies of air. A single nonnegative charge magnitude models an ideal series
string with initially uncharged isolated intermediate conductors. -/
structure BatteryData where
  air : PlaneCapacitor
  glass : PlaneCapacitor
  εr : ℝ
  εr_pos : 0 < εr
  scaling : DielectricScaling air glass εr

/-- Supplied physical data converted exactly from V/cm and cm to SI. -/
structure SourceData (data : BatteryData) : Prop where
  air_field : data.air.breakdownField.val = 3000000
  glass_field : data.glass.breakdownField.val = 9000000
  gap : data.air.gap.val = 7 / 1000
  permittivity : data.εr = 7

/-- Four identical air capacitors: series voltages add. -/
noncomputable def airTotal (data : BatteryData) (q : Charge) : ℝ :=
  4 * (data.air.voltage q).val

/-- Three identical air capacitors and one glass capacitor, sharing charge q. -/
noncomputable def mixedTotal (data : BatteryData) (q : Charge) : ℝ :=
  3 * (data.air.voltage q).val + (data.glass.voltage q).val

/-- All components satisfy their own inclusive breakdown condition. -/
def mixedAdmissible (data : BatteryData) (q : Charge) : Prop :=
  data.air.Admissible q ∧ data.glass.Admissible q

/-- A maximum means both an upper bound and an admissible state attaining it. -/
def MaximumVoltage (allowed : Charge → Prop) (total : Charge → ℝ) (U : ℝ) : Prop :=
  (∀ q, allowed q → total q ≤ U) ∧ ∃ q, allowed q ∧ total q = U

/-- Problem 433: both attained maximum voltages and a strict glass safety margin
at the operating point where air reaches its breakdown threshold. -/
def TrustedPhysicsProblem (data : BatteryData) : Prop :=
  MaximumVoltage data.air.Admissible (airTotal data) 84000 ∧
  MaximumVoltage (mixedAdmissible data) (mixedTotal data) 66000 ∧
  (data.glass.voltage data.air.chargeAtLimit).val < data.glass.breakdownVoltage.val

end LeanVerificationDemo.PhysicsDemo.P03
