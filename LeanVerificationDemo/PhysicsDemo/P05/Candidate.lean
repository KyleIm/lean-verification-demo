import LeanVerificationDemo.PhysicsDemo.P05.Problem
import Mathlib.Tactic

namespace LeanVerificationDemo.PhysicsDemo.P05.Candidate
open PhyslibTemp.ClassicalMechanics

lemma cos_pos (data : LadderData) : 0 < Real.cos data.alpha :=
  Real.cos_pos_of_mem_Ioo ⟨by linarith [Real.pi_pos, data.alpha_pos], data.alpha_lt⟩

lemma height_pos (data : LadderData) : 0 < height data :=
  mul_pos data.length_pos (Real.sin_pos_of_pos_of_lt_pi data.alpha_pos
    (by linarith [data.alpha_lt, Real.pi_pos]))

/-- Compute Cartesian force balance and moments from actual Physlib force values.
This derives the source's scalar equations within the minimal supplied statics model. -/
lemma equilibrium_iff (data : LadderData) (s : ℝ) (r : Reactions) :
    EquilibriumAt data s r ↔
      r.N2 = data.G ∧ r.Ffr = r.N1 ∧
        r.N1 * height data = data.G * Real.cos data.alpha * s := by
  have hx : (∑ i : Fin 4, (forces data r i 0).components 0) = r.N1 - r.Ffr := by
    simp [forces, constantForce, Fin.sum_univ_succ, sub_eq_add_neg]
  have hy : (∑ i : Fin 4, (forces data r i 0).components 1) = r.N2 - data.G := by
    simp [forces, constantForce, Fin.sum_univ_succ, sub_eq_add_neg]
  have hm : (∑ i : Fin 4, planarMoment (positions data s i) (forces data r i 0)) =
      data.G * Real.cos data.alpha * s - r.N1 * height data := by
    simp [positions, forces, constantForce, planarMoment_eq, Fin.sum_univ_succ]
    ring
  change (labFrame.IsInertial ∧ labFrame.Orthonormal ∧ _ ∧ _) ↔ _
  simp only [labFrame_inertial, labFrame_orthonormal, true_and]
  constructor
  · rintro ⟨hf, ht⟩
    have h0 := hf 0
    have h1 := hf 1
    rw [hx] at h0
    rw [hy] at h1
    rw [hm] at ht
    exact ⟨by linarith, by linarith, by linarith⟩
  · rintro ⟨hN2, hF, hT⟩
    constructor
    · intro k
      fin_cases k <;> norm_num [forces, constantForce, Fin.sum_univ_succ, hF, hN2]
    · rw [hm, hT]; ring

/-- The required support forces are consequences of equilibrium, not input assumptions. -/
lemma reactions_required (data : LadderData) (s : ℝ) (r : Reactions)
    (h : EquilibriumAt data s r) :
    r.N2 = data.G ∧ r.N1 = requiredFriction data s ∧ r.Ffr = requiredFriction data s := by
  obtain ⟨hN2, hF, hT⟩ := (equilibrium_iff data s r).mp h
  have hN1 : r.N1 = requiredFriction data s :=
    (eq_div_iff (height_pos data).ne').2 hT
  exact ⟨hN2, hN1, hF.trans hN1⟩

/-- Explicit balancing support forces, before the friction bound is imposed. -/
noncomputable def balancingReactions (data : LadderData) (s : ℝ) : Reactions :=
  ⟨requiredFriction data s, data.G, requiredFriction data s⟩

lemma balancing_equilibrium (data : LadderData) (s : ℝ) :
    EquilibriumAt data s (balancingReactions data s) := by
  apply (equilibrium_iff data s _).mpr
  refine ⟨rfl, rfl, ?_⟩
  exact div_mul_cancel₀ _ (height_pos data).ne'

lemma required_nonneg (data : LadderData) {s : ℝ} (hs : 0 ≤ s) :
    0 ≤ requiredFriction data s :=
  div_nonneg (mul_nonneg (mul_pos data.G_pos (cos_pos data)).le hs) (height_pos data).le

/-- Required friction is strictly increasing for fixed geometry and weight. -/
lemma required_strictMono (data : LadderData) : StrictMono (requiredFriction data) := by
  intro a b hab
  exact div_lt_div_of_pos_right
    (mul_lt_mul_of_pos_left hab (mul_pos data.G_pos (cos_pos data))) (height_pos data)

/-- The force-bound inequality is equivalent to the critical-position inequality. -/
lemma required_le_iff (data : LadderData) (s : ℝ) :
    requiredFriction data s ≤ data.μ * data.G ↔ s ≤ criticalPosition data := by
  rw [requiredFriction, criticalPosition, div_le_iff₀ (height_pos data),
    le_div_iff₀ (cos_pos data)]
  have hLeft : data.G * Real.cos data.alpha * s = data.G * (s * Real.cos data.alpha) := by ring
  have hRight : data.μ * data.G * height data = data.G * (data.μ * height data) := by ring
  rw [hLeft, hRight]
  exact mul_le_mul_iff_right₀ data.G_pos

lemma critical_nonneg (data : LadderData) : 0 ≤ criticalPosition data :=
  div_nonneg (mul_nonneg data.μ_nonneg (height_pos data).le) (cos_pos data).le

/-- The explicit critical-position formula saturates the force bound.
This formula is a derived strengthening of the qualitative source explanation. -/
lemma required_at_critical (data : LadderData) :
    requiredFriction data (criticalPosition data) = data.μ * data.G := by
  dsimp [requiredFriction, criticalPosition]
  field_simp [(height_pos data).ne', (cos_pos data).ne']

/-- Static admissibility is exactly the position threshold for nonnegative AO. -/
lemma admissible_iff (data : LadderData) {s : ℝ} (hs : 0 ≤ s) :
    AdmissibleAt data s ↔ s ≤ criticalPosition data := by
  constructor
  · rintro ⟨r, he, _, _, _, hBound⟩
    obtain ⟨hN2, _, hF⟩ := reactions_required data s r he
    rw [hN2, hF, abs_of_nonneg (required_nonneg data hs)] at hBound
    exact (required_le_iff data s).mp hBound
  · intro hPosition
    refine ⟨balancingReactions data s, balancing_equilibrium data s,
      required_nonneg data hs, data.μ_nonneg, data.G_pos.le, ?_⟩
    change |requiredFriction data s| ≤ data.μ * data.G
    rw [abs_of_nonneg (required_nonneg data hs)]
    exact (required_le_iff data s).mpr hPosition

/-- Prove the qualitative source answer as loss of admissible static equilibrium,
not as a theorem about acceleration or a slipping trajectory. -/
theorem solution (data : LadderData) : TrustedPhysicsProblem data := by
  refine ⟨required_strictMono data, ?_, ?_, ?_, ?_⟩
  · intro s hs
    exact admissible_iff data hs.1
  · refine ⟨data.μ_nonneg, data.G_pos.le, ?_⟩
    rw [required_at_critical, abs_of_nonneg (mul_nonneg data.μ_nonneg data.G_pos.le)]
  · intro hs
    exact (admissible_iff data hs.1).mpr le_rfl
  · intro s hs hAbove hAdmissible
    exact (not_le_of_gt hAbove) ((admissible_iff data hs.1).mp hAdmissible)

end LeanVerificationDemo.PhysicsDemo.P05.Candidate
