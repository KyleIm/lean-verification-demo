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

-- Both reachability branches are checked as explicit candidate consequences.
example (data : LadderData) (h : ReachableThreshold data) :
    OnLadder data (criticalPosition data) ∧ AdmissibleAt data (criticalPosition data) :=
  ⟨(Candidate.reachable_threshold data h).1, (Candidate.reachable_threshold data h).2.1⟩

example (data : LadderData) (h : ¬ ReachableThreshold data)
    (s : ℝ) (hs : OnLadder data s) :
    AdmissibleAt data s ∧ requiredFriction data s < data.μ * data.G :=
  (Candidate.unreachable_threshold data h s hs).2

-- The two cases really occur in the admitted parameter domain, rather than
-- being merely conditional branches whose hypotheses might be impossible.
example (data : LadderData) : ∃ other : LadderData, ReachableThreshold other := by
  refine ⟨{ data with μ := 0, μ_nonneg := le_rfl }, ?_⟩
  change 0 * height data / Real.cos data.alpha ≤ data.length
  simpa using data.length_pos.le

example (data : LadderData) : ∃ other : LadderData, ¬ ReachableThreshold other := by
  let other : LadderData :=
    { data with
      μ := 2 * data.length * Real.cos data.alpha / height data
      μ_nonneg := (div_pos
        (mul_pos (mul_pos (by norm_num) data.length_pos) (Candidate.cos_pos data))
        (Candidate.height_pos data)).le }
  have hCritical : criticalPosition other = 2 * data.length := by
    change (2 * data.length * Real.cos data.alpha / height data) * height data /
      Real.cos data.alpha = 2 * data.length
    rw [div_mul_cancel₀ _ (Candidate.height_pos data).ne',
      mul_div_cancel_right₀ _ (Candidate.cos_pos data).ne']
  refine ⟨other, ?_⟩
  change ¬ criticalPosition other ≤ data.length
  rw [hCritical]
  linarith [data.length_pos]

end LeanVerificationDemo.PhysicsDemo.P05.Verifier
