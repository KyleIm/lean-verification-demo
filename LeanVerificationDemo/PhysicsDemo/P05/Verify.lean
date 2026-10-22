import LeanVerificationDemo.PhysicsDemo.P05.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P05.Verifier

example (data : LadderData) : TrustedPhysicsProblem data := Candidate.solution data

-- The physical parameter domain is satisfiable; no threshold result is assumed.
example : Nonempty LadderData := by
  refine ⟨{
    length := 1
    length_pos := by norm_num
    alpha := Real.pi / 4
    alpha_pos := by positivity
    alpha_lt := by linarith [Real.pi_pos]
    G := 1
    G_pos := by norm_num
    μ := 1 / 4
    μ_nonneg := by norm_num
  }⟩

-- Every parameter choice has an admissible state at the bottom, so the model's
-- nonexistence-above-threshold conclusion is not merely vacuous.
example (data : LadderData) : AdmissibleAt data 0 :=
  (Candidate.admissible_iff data (le_refl 0)).mpr (Candidate.critical_nonneg data)

end LeanVerificationDemo.PhysicsDemo.P05.Verifier
