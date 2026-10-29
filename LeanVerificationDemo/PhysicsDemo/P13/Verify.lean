import LeanVerificationDemo.PhysicsDemo.P13.Units

namespace LeanVerificationDemo.PhysicsDemo.P13.Verifier
open LeanVerificationDemo.PhyslibTemp.ClassicalMechanics

/-- Original source data only: no frequency or approximation answer field. -/
noncomputable def sourceString : StringData where
  lengthCm := 50
  length_pos := by norm_num
  diameterMm := 1
  diameter_pos := by norm_num
  tensionDyn := 2450
  tension_pos := by norm_num
  densityGcm3 := 39 / 5
  density_pos := by norm_num

lemma source_inputs : SourceData sourceString := ⟨rfl, rfl, rfl, rfl⟩
example : TrustedPhysicsProblem sourceString := Candidate.solution sourceString source_inputs
example : fundamental sourceString = Real.sqrt (490 / (39 * Real.pi)) :=
  Candidate.fundamental_exact_source sourceString source_inputs
example : (19998 : ℝ) / 10000 < fundamental sourceString ∧
    fundamental sourceString < (19999 : ℝ) / 10000 :=
  Candidate.fundamental_bounds sourceString source_inputs
example : RoundsToWholeHz (fundamental sourceString) 2 :=
  Candidate.printed_fundamental_rounds sourceString source_inputs

-- Explicit negative check against replacing rounded textbook arithmetic by =2.
example : fundamental sourceString ≠ 2 :=
  Candidate.printed_fundamental_not_exact sourceString source_inputs
example (n : ℕ+) : |naturalFrequency sourceString n - 2 * (n : ℝ)| < (n : ℝ) / 5000 :=
  Candidate.mode_approximation_error sourceString source_inputs n
example (n : ℕ+) : naturalFrequency sourceString n = (n : ℝ) * fundamental sourceString :=
  Candidate.natural_harmonics sourceString n
example (n : ℕ+) : naturalFrequency sourceString n =
    (n : ℝ) * Real.sqrt (490 / (39 * Real.pi)) :=
  Candidate.source_mode_exact sourceString source_inputs n

-- Common rational substitutes for π do not give an exact square of 4 either.
-- These checks are not substitutions for Real.pi in the physical theorem.
example : (490 : ℝ) / (39 * (22 / 7)) ≠ 4 := by norm_num
example : (490 : ℝ) / (39 * (314 / 100)) ≠ 4 := by norm_num
example : (245 : ℝ) / 78 ≠ 22 / 7 ∧ (245 : ℝ) / 78 ≠ 314 / 100 := by norm_num

example : ¬ ∃ n : ℕ+, (n : ℕ) = 0 := by
  rintro ⟨n, hn⟩
  exact Nat.ne_of_gt n.pos hn
example (n : ℕ+) : 0 < naturalFrequency sourceString n :=
  (fixedString sourceString).frequency_pos n
example (n : ℕ+) : (fixedString sourceString).modeShape n 0 = 0 ∧
    (fixedString sourceString).modeShape n sourceString.lengthCm = 0 :=
  ⟨FixedString.modeShape_left _ n, FixedString.modeShape_right _ n⟩

-- Actual upstream unit conversions, including the dyne's coherent CGS meaning.
example : Units.diameterQuantity sourceString Units.CGS = (⟨1 / 10⟩ : Units.Length) := by
  rw [Units.diameter_in_CGS, Candidate.source_converted_diameter sourceString source_inputs]
example : Units.dyne LTMCTUnitChoices.SI = (⟨1 / 100000⟩ : Units.Force) := Units.dyne_in_SI
example : Units.densityQuantity sourceString LTMCTUnitChoices.SI = (⟨7800⟩ : Units.Density) :=
  (Units.source_in_SI sourceString source_inputs).2.2.2
example : Units.sourceFormulaQuantity
    (Units.lengthQuantity sourceString LTMCTUnitChoices.SI)
    (Units.diameterQuantity sourceString LTMCTUnitChoices.SI)
    (Units.tensionQuantity sourceString LTMCTUnitChoices.SI)
    (Units.densityQuantity sourceString LTMCTUnitChoices.SI) =
      (⟨fundamental sourceString⟩ : Units.RealFrequency) :=
  Units.typed_source_SI sourceString source_inputs

end LeanVerificationDemo.PhysicsDemo.P13.Verifier
