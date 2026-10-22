import LeanVerificationDemo.PhysicsDemo.P03.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P03.Verifier

/-- Explicit trusted proposition/candidate pairing for the same physical data. -/
example (data : BatteryData) (source : SourceData data) :
    TrustedPhysicsProblem data := Candidate.solution data source

/-- Check the named source-specific glass-voltage result explicitly. -/
example (data : BatteryData) (source : SourceData data) :
    (data.glass.voltage data.airBreakdown.chargeAtLimit).val = 3000 :=
  Candidate.glass_voltage_at_air_limit data source

-- A concrete consistent instance checks that the trusted input assumptions are
-- satisfiable. The arbitrary positive reference capacitance here is 1 F;
-- neither the theorem nor the source problem fixes its value.
example : ∃ data : BatteryData, SourceData data := by
  let air : PhyslibTemp.Electromagnetism.PlaneCapacitor :=
    { C := ⟨1⟩, gap := ⟨7 / 1000⟩,
      C_pos := by norm_num, gap_pos := by norm_num }
  let glass : PhyslibTemp.Electromagnetism.PlaneCapacitor :=
    { C := ⟨7⟩, gap := ⟨7 / 1000⟩,
      C_pos := by norm_num, gap_pos := by norm_num }
  let data : BatteryData :=
    { air := air, glass := glass,
      airBreakdown := { breakdownField := ⟨3000000⟩, breakdown_pos := by norm_num },
      glassBreakdown := { breakdownField := ⟨9000000⟩, breakdown_pos := by norm_num },
      εr := 7, εr_pos := by norm_num,
      scaling := ⟨rfl, by norm_num [air, glass]⟩ }
  refine ⟨data, ?_⟩
  constructor <;> norm_num [data, air, glass]

end LeanVerificationDemo.PhysicsDemo.P03.Verifier
