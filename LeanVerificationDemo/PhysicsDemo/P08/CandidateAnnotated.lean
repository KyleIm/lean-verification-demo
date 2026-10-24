import LeanVerificationDemo.PhysicsDemo.P08.Problem

open _root_.ClassicalMechanics

namespace LeanVerificationDemo.PhysicsDemo.P08.CandidateAnnotated

/-- Reusable mechanics specialized to P08's initial vertical velocity and
constant downward acceleration: v(t) = (u - gt) e_z. -/
lemma vertical_velocity_evolution (data : ExplosionData) (source : SourceData data) (t : ℝ) :
    data.rocket.velocity t = (data.initialSpeed - data.g * t) • up := by
  -- [Upstream/reusable mechanics] Integrate the actual particle acceleration.
  have hVelocity := source.constant_acceleration.velocity_eq 0 t
  rw [source.initial_velocity] at hVelocity
  simp only [sub_zero] at hVelocity
  calc
    data.rocket.velocity t = data.initialSpeed • up + t • ((-data.g) • up) := hVelocity
    _ = (data.initialSpeed - data.g * t) • up := by module

/-- The reusable quadratic position law gives the scalar height law. -/
lemma height_evolution (data : ExplosionData) (source : SourceData data) (t : ℝ) :
    height data t = height data 0 + t * data.initialSpeed - data.g * t ^ 2 / 2 := by
  -- [Upstream/reusable mechanics] Project the generic quadratic law onto height.
  have hPosition := source.constant_acceleration.position_eq 0 t
  rw [source.initial_velocity] at hPosition
  have hz := congrArg (fun v : labFrame.Vector => v.components 2) hPosition
  change height data t = height data 0 + (t - 0) * (data.initialSpeed * 1) +
    ((t - 0) ^ 2 / 2) * ((-data.g) * 1) at hz
  convert hz using 1
  ring

lemma apex_time_pos (data : ExplosionData) : 0 < apexTime data :=
  div_pos data.initialSpeed_pos data.g_pos

/-- The computed time really is a highest point of the ideal reference trajectory. -/
lemma apex_height_maximal (data : ExplosionData) (source : SourceData data) (t : ℝ) :
    height data t ≤ height data (apexTime data) := by
  -- [P08 specialization] The height difference is a nonnegative square.
  have hDifference : height data (apexTime data) - height data t =
      (data.g / 2) * (t - apexTime data) ^ 2 := by
    rw [height_evolution data source (apexTime data), height_evolution data source t]
    dsimp [apexTime]
    field_simp [data.g_pos.ne']
    ring
  apply sub_nonneg.mp
  rw [hDifference]
  exact mul_nonneg (div_pos data.g_pos (by norm_num)).le (sq_nonneg _)

lemma apex_isLocalMax (data : ExplosionData) (source : SourceData data) :
    IsLocalMax (height data) (apexTime data) :=
  Filter.Eventually.of_forall (apex_height_maximal data source)

lemma height_hasDerivAt (data : ExplosionData) (source : SourceData data) (t : ℝ) :
    HasDerivAt (height data) (data.initialSpeed - data.g * t) t := by
  have heq : height data = fun s => height data 0 + s * data.initialSpeed - data.g * s ^ 2 / 2 :=
    funext (height_evolution data source)
  rw [heq]
  convert! ((hasDerivAt_const t (height data 0)).add
    ((hasDerivAt_id t).mul_const data.initialSpeed)).sub
      (((hasDerivAt_pow 2 t).const_mul data.g).div_const 2) using 1
  ring

/-- Fermat's theorem is applied to the proved highest point, not assumed rest. -/
lemma apex_vertical_velocity_zero (data : ExplosionData) (source : SourceData data) :
    data.initialSpeed - data.g * apexTime data = 0 :=
  -- [Mathlib calculus] The proved maximum, not assumed rest, gives zero slope.
  (apex_isLocalMax data source).hasDerivAt_eq_zero
    (height_hasDerivAt data source (apexTime data))

lemma apex_frame_velocity_zero (data : ExplosionData) (source : SourceData data) :
    data.rocket.velocity (apexTime data) = 0 := by
  rw [vertical_velocity_evolution data source, apex_vertical_velocity_zero data source,
    zero_smul]

lemma apex_velocity_zero (data : ExplosionData) (source : SourceData data) :
    apexVelocity data = 0 := by
  unfold apexVelocity
  rw [apex_frame_velocity_zero data source]
  rfl

/-- The pre-explosion momentum now depends on proved apex rest. -/
lemma pre_momentum_zero (data : ExplosionData) (source : SourceData data) :
    preMomentum data = 0 := by
  simp [preMomentum, apex_velocity_zero data source]

/-- Source/model physics: the adopted conserved momentum is therefore zero. -/
lemma total_momentum_zero (data : ExplosionData) (source : SourceData data) :
    momentum data 0 + momentum data 1 + momentum data 2 = 0 := by
  change totalMomentum data = 0
  -- [Approximate explosion physics] Across-event conservation remains a premise.
  exact source.momentum_conserved.trans (pre_momentum_zero data source)

/-- Pure linear algebra: the first momentum is minus the sum of the other two. -/
lemma first_momentum_eq_neg_sum (data : ExplosionData) (source : SourceData data) :
    momentum data 0 = -(momentum data 1 + momentum data 2) := by
  exact eq_neg_of_add_eq_zero_left (by
    simpa [add_assoc] using total_momentum_zero data source)

/-- An explicit candidate plane, possibly a line or {0}; independence is not assumed. -/
noncomputable def momentumPlane (data : ExplosionData) : Submodule ℝ Vector3 :=
  Submodule.span ℝ {momentum data 1, momentum data 2}

lemma first_momentum_in_span (data : ExplosionData) (source : SourceData data) :
    momentum data 0 ∈ momentumPlane data := by
  -- [Pure linear algebra] Span closure contains the negative generator sum.
  have h1 : momentum data 1 ∈ momentumPlane data :=
    Submodule.subset_span (by simp)
  have h2 : momentum data 2 ∈ momentumPlane data :=
    Submodule.subset_span (by simp)
  rw [first_momentum_eq_neg_sum data source]
  exact (momentumPlane data).neg_mem ((momentumPlane data).add_mem h1 h2)

lemma momenta_in_plane (data : ExplosionData) (source : SourceData data) :
    ∀ i, momentum data i ∈ momentumPlane data := by
  intro i
  fin_cases i
  · exact first_momentum_in_span data source
  · exact Submodule.subset_span (by simp)
  · exact Submodule.subset_span (by simp)

/-- Two generators give dimension at most two, even if equal or zero. -/
lemma momentum_plane_finrank (data : ExplosionData) :
    Module.finrank ℝ (momentumPlane data) ≤ 2 := by
  classical
  have hSet : (({momentum data 1, momentum data 2} : Finset Vector3) : Set Vector3) =
      {momentum data 1, momentum data 2} := by
    ext v
    simp
  have h := finrank_span_finset_le_card (R := ℝ)
    ({momentum data 1, momentum data 2} : Finset Vector3)
  change Module.finrank ℝ (Submodule.span ℝ
    (({momentum data 1, momentum data 2} : Finset Vector3) : Set Vector3)) ≤
      ({momentum data 1, momentum data 2} : Finset Vector3).card at h
  rw [hSet] at h
  exact h.trans Finset.card_le_two

lemma momenta_coplanar (data : ExplosionData) (source : SourceData data) :
    LinearCoplanar (momentum data) := by
  exact ⟨momentumPlane data, momentum_plane_finrank data, momenta_in_plane data source⟩

/-- Nonzero masses recover velocities by inverse scalar multiplication, so the
same linear plane contains velocities as well as momenta. -/
lemma velocity_mem_of_momentum_mem (data : ExplosionData) (i : Fin 3)
    {plane : Submodule ℝ Vector3} (hp : momentum data i ∈ plane) :
    data.velocity i ∈ plane := by
  -- [Pure linear algebra] Invert positive mass within the same linear subspace.
  have hScaled := plane.smul_mem (data.mass i)⁻¹ hp
  simpa [momentum, smul_smul, (data.mass_pos i).ne'] using hScaled

/-- Source answer: the three immediate post-explosion velocity vectors lie in
one plane through the origin (dimension ≤ 2). No later fragment dynamics is claimed. -/
theorem solution (data : ExplosionData) (source : SourceData data) :
    TrustedPhysicsProblem data := by
  -- Constant-acceleration mechanics → height maximum → Fermat → zero apex velocity
  -- → zero pre-momentum → conserved zero post-momentum → momentum coplanarity.
  -- Then transfer membership by positive masses.
  obtain ⟨plane, hDimension, hMomenta⟩ := momenta_coplanar data source
  have hVelocities : ∀ i, data.velocity i ∈ plane := by
    intro i
    exact velocity_mem_of_momentum_mem data i (hMomenta i)
  -- Explicit linear conclusion; this is not affine coplanarity of three endpoints.
  change ∃ plane : Submodule ℝ Vector3,
    Module.finrank ℝ plane ≤ 2 ∧ ∀ i, data.velocity i ∈ plane
  exact ⟨plane, hDimension, hVelocities⟩

end LeanVerificationDemo.PhysicsDemo.P08.CandidateAnnotated
