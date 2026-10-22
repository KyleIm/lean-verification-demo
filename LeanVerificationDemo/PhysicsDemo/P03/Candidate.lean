import LeanVerificationDemo.PhysicsDemo.P03.Problem

namespace LeanVerificationDemo.PhysicsDemo.P03.Candidate

open PhyslibTemp.Electromagnetism

/-- Symbolic inverse voltage scaling, using one common series charge. -/
lemma glass_voltage (data : BatteryData) (q : Charge) :
    (data.glass.voltage q).val = (data.air.voltage q).val / data.εr :=
  voltage_of_dielectric_scaling data.air data.glass data.εr data.scaling q

/-- Symbolic maximum for four identical air capacitors. -/
lemma air_maximum (data : BatteryData) :
    MaximumVoltage data.airBreakdown.Admissible (airTotal data)
      (4 * data.airBreakdown.breakdownVoltage.val) := by
  constructor
  · intro q hq
    exact mul_le_mul_of_nonneg_left hq.2 (by norm_num)
  · refine ⟨data.airBreakdown.chargeAtLimit, data.airBreakdown.admissible_at_limit, ?_⟩
    dsimp [airTotal]
    rw [data.airBreakdown.voltage_at_limit]

/-- Symbolic mixed maximum, provided the glass threshold admits the air-limited
operating point. This condition is proved from source data below, not assumed
in the final problem. -/
lemma mixed_maximum (data : BatteryData)
    (hGlass : data.airBreakdown.breakdownVoltage.val / data.εr ≤
      data.glassBreakdown.breakdownVoltage.val) :
    MaximumVoltage (mixedAdmissible data) (mixedTotal data)
      (3 * data.airBreakdown.breakdownVoltage.val + data.airBreakdown.breakdownVoltage.val / data.εr) := by
  constructor
  · intro q hq
    dsimp [mixedTotal]
    rw [glass_voltage]
    have hRatio := div_le_div_of_nonneg_right hq.1.2 data.εr_pos.le
    linarith [hq.1.2]
  · refine ⟨data.airBreakdown.chargeAtLimit, ?_, ?_⟩
    · refine ⟨data.airBreakdown.admissible_at_limit, ?_⟩
      constructor
      · exact data.airBreakdown.admissible_at_limit.1
      · rw [glass_voltage, data.airBreakdown.voltage_at_limit]
        exact hGlass
    · dsimp [mixedTotal]
      rw [glass_voltage, data.airBreakdown.voltage_at_limit]

/-- Evaluate the material thresholds in volts after exact SI conversion. -/
lemma threshold_values (data : BatteryData) (source : SourceData data) :
    data.airBreakdown.breakdownVoltage.val = 21000 ∧
      data.glassBreakdown.breakdownVoltage.val = 63000 := by
  have hGap : data.glass.gap = data.air.gap := data.scaling.1
  constructor
  · dsimp [BreakdownSpec.breakdownVoltage]
    rw [source.air_field, source.gap]
    norm_num
  · dsimp [BreakdownSpec.breakdownVoltage]
    rw [source.glass_field, hGap, source.gap]
    norm_num

/-- P03-specific numerical consequence of the supplied source data.
At the charge where air reaches Ea d = 21000 V, dielectric scaling gives glass
voltage 21000 / 7 = 3000 V. This is not a general capacitor law and intentionally
remains in P03, outside PhyslibTemp. -/
lemma glass_voltage_at_air_limit (data : BatteryData) (source : SourceData data) :
    (data.glass.voltage data.airBreakdown.chargeAtLimit).val = 3000 := by
  rw [glass_voltage, data.airBreakdown.voltage_at_limit]
  change (data.airBreakdown.breakdownField.val * data.air.gap.val) / data.εr = 3000
  rw [source.air_field, source.gap, source.permittivity]
  norm_num

/-- Derive both attained maxima and show that glass is strictly below breakdown. -/
theorem solution (data : BatteryData) (source : SourceData data) :
    TrustedPhysicsProblem data := by
  obtain ⟨hAir, hGlass⟩ := threshold_values data source
  have hSafe : data.airBreakdown.breakdownVoltage.val / data.εr <
      data.glassBreakdown.breakdownVoltage.val := by
    have hVoltage := glass_voltage_at_air_limit data source
    rw [glass_voltage, data.airBreakdown.voltage_at_limit] at hVoltage
    rw [hVoltage, hGlass]
    norm_num
  refine ⟨?_, ?_, ?_⟩
  · have h := air_maximum data
    norm_num [hAir] at h
    exact h
  · have h := mixed_maximum data hSafe.le
    norm_num [hAir, source.permittivity] at h
    exact h
  · rw [glass_voltage, data.airBreakdown.voltage_at_limit]
    exact hSafe

end LeanVerificationDemo.PhysicsDemo.P03.Candidate
