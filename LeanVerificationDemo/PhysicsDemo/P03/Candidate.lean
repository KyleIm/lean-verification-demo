import LeanVerificationDemo.PhysicsDemo.P03.Problem

namespace LeanVerificationDemo.PhysicsDemo.P03.Candidate

open PhyslibTemp.Electromagnetism

/-- Symbolic inverse voltage scaling, using one common series charge. -/
lemma glass_voltage (data : BatteryData) (q : Charge) :
    (data.glass.voltage q).val = (data.air.voltage q).val / data.εr :=
  voltage_of_dielectric_scaling data.air data.glass data.εr data.scaling q

/-- Symbolic maximum for four identical air capacitors. -/
lemma air_maximum (data : BatteryData) :
    MaximumVoltage data.air.Admissible (airTotal data)
      (4 * data.air.breakdownVoltage.val) := by
  constructor
  · intro q hq
    exact mul_le_mul_of_nonneg_left hq.2 (by norm_num)
  · refine ⟨data.air.chargeAtLimit, data.air.admissible_at_limit, ?_⟩
    dsimp [airTotal]
    rw [data.air.voltage_at_limit]

/-- Symbolic mixed maximum, provided the glass threshold admits the air-limited
operating point. This condition is proved from source data below, not assumed
in the final problem. -/
lemma mixed_maximum (data : BatteryData)
    (hGlass : data.air.breakdownVoltage.val / data.εr ≤
      data.glass.breakdownVoltage.val) :
    MaximumVoltage (mixedAdmissible data) (mixedTotal data)
      (3 * data.air.breakdownVoltage.val + data.air.breakdownVoltage.val / data.εr) := by
  constructor
  · intro q hq
    dsimp [mixedTotal]
    rw [glass_voltage]
    have hRatio := div_le_div_of_nonneg_right hq.1.2 data.εr_pos.le
    linarith [hq.1.2]
  · refine ⟨data.air.chargeAtLimit, ?_, ?_⟩
    · refine ⟨data.air.admissible_at_limit, ?_⟩
      constructor
      · exact data.air.admissible_at_limit.1
      · rw [glass_voltage, data.air.voltage_at_limit]
        exact hGlass
    · dsimp [mixedTotal]
      rw [glass_voltage, data.air.voltage_at_limit]

/-- Evaluate the material thresholds in volts after exact SI conversion. -/
lemma threshold_values (data : BatteryData) (source : SourceData data) :
    data.air.breakdownVoltage.val = 21000 ∧
      data.glass.breakdownVoltage.val = 63000 := by
  have hGap : data.glass.gap = data.air.gap := data.scaling.1
  constructor
  · dsimp [PlaneCapacitor.breakdownVoltage]
    rw [source.air_field, source.gap]
    norm_num
  · dsimp [PlaneCapacitor.breakdownVoltage]
    rw [source.glass_field, hGap, source.gap]
    norm_num

/-- Derive both attained maxima and show that glass is strictly below breakdown. -/
theorem solution (data : BatteryData) (source : SourceData data) :
    TrustedPhysicsProblem data := by
  obtain ⟨hAir, hGlass⟩ := threshold_values data source
  have hSafe : data.air.breakdownVoltage.val / data.εr <
      data.glass.breakdownVoltage.val := by
    rw [hAir, source.permittivity, hGlass]
    norm_num
  refine ⟨?_, ?_, ?_⟩
  · have h := air_maximum data
    norm_num [hAir] at h
    exact h
  · have h := mixed_maximum data hSafe.le
    norm_num [hAir, source.permittivity] at h
    exact h
  · rw [glass_voltage, data.air.voltage_at_limit]
    exact hSafe

end LeanVerificationDemo.PhysicsDemo.P03.Candidate
