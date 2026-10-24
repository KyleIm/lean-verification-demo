import LeanVerificationDemo.PhysicsDemo.P08.Problem

open _root_.ClassicalMechanics
open LeanVerificationDemo.PhyslibTemp.ClassicalMechanics
open scoped BigOperators Topology
open Filter MeasureTheory

namespace LeanVerificationDemo.PhysicsDemo.P08.Candidate

/-- Reusable mechanics specialized to P08's initial vertical velocity and
constant downward acceleration: v(t) = (u - gt) e_z. -/
lemma vertical_velocity_evolution (data : ExplosionData) (source : SourceData data) (t : ℝ) :
    data.rocket.velocity t = (data.initialSpeed - data.g * t) • up := by
  have hVelocity := source.constant_acceleration.velocity_eq 0 t
  rw [source.initial_velocity] at hVelocity
  simp only [sub_zero] at hVelocity
  calc
    data.rocket.velocity t = data.initialSpeed • up + t • ((-data.g) • up) := hVelocity
    _ = (data.initialSpeed - data.g * t) • up := by module

/-- The reusable quadratic position law gives the scalar height law. -/
lemma height_evolution (data : ExplosionData) (source : SourceData data) (t : ℝ) :
    height data t = height data 0 + t * data.initialSpeed - data.g * t ^ 2 / 2 := by
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

/-- Newton III eliminates even large duration-dependent internal forces. -/
lemma internal_forces_cancel (data : ExplosionData) (source : SourceData data)
    (ε : ℝ) (hε : 0 < ε) (t : ℝ) :
    ∑ i, ∑ j, data.internalForce ε i j t = 0 :=
  (source.event_balance ε hε).internal_sum_zero t

/-- Co-moving constituents at the start have the pre-event rocket momentum. -/
lemma initial_total_momentum (data : ExplosionData) (source : SourceData data)
    (ε : ℝ) (hε : 0 < ε) :
    (∑ i, data.eventMomentum ε i 0) = preMomentum data := by
  simp_rw [source.event_initial ε hε]
  rw [← Finset.sum_smul, source.mass_balance]
  rfl

/-- Constant gravity has a finite-duration impulse ε F_g; it is not discarded. -/
lemma gravitational_impulse_eq (data : ExplosionData) (ε : ℝ) :
    gravitationalImpulse data ε = ε • gravitationalForce data := by
  simp [gravitationalImpulse, intervalIntegral.integral_const]

lemma gravitational_impulse_tendsto_zero (data : ExplosionData) :
    Tendsto (gravitationalImpulse data) (𝓝[>] (0 : ℝ)) (𝓝 0) := by
  have h := constant_impulse_tendsto_zero (gravitationalForce data) 0
  simp_rw [constant_impulse] at h
  change Tendsto (fun ε => gravitationalImpulse data ε) _ _
  simp_rw [gravitational_impulse_eq]
  exact h

/-- Summed Newton II, internal cancellation and FTC give the finite-time balance. -/
lemma finite_duration_momentum_balance (data : ExplosionData) (source : SourceData data)
    (ε : ℝ) (hε : 0 < ε) :
    (∑ i, data.eventMomentum ε i ε) - preMomentum data = gravitationalImpulse data ε := by
  have h := (source.event_balance ε hε).total_change_eq_integral 0 ε
    (by simpa only [gravitationalForce, ← Finset.sum_smul] using
      (intervalIntegrable_const : IntervalIntegrable
        (fun _ : ℝ => gravitationalForce data) volume 0 ε))
  rw [initial_total_momentum data source ε hε] at h
  simpa only [gravitationalImpulse, gravitationalForce, Finset.sum_smul] using h

/-- Event-state semantics: endpoints of positive-duration regularizations
converge to the immediate post-event fragment momenta. This is a duration limit,
not a claim about a fixed finite time after an actual explosion. -/
lemma total_momentum_endpoint_limit (data : ExplosionData) (source : SourceData data) :
    Tendsto (fun ε => ∑ i, data.eventMomentum ε i ε)
      (𝓝[>] (0 : ℝ)) (𝓝 (totalMomentum data)) := by
  have h := tendsto_finsetSum Finset.univ (fun i _ => source.post_event_limit i)
  simpa [totalMomentum, Fin.sum_univ_succ, add_assoc] using h

/-- Across-event equality is derived by uniqueness of the right-duration limit,
after finite-time Newton balance and vanishing external impulse are proved. -/
lemma event_momentum_eq (data : ExplosionData) (source : SourceData data) :
    totalMomentum data = preMomentum data := by
  exact event_momentum_eq_of_impulse_limit
    (finite_duration_momentum_balance data source)
    (total_momentum_endpoint_limit data source)
    (gravitational_impulse_tendsto_zero data)

/-- Derived event mechanics plus proved apex rest gives zero post-event momentum. -/
lemma total_momentum_zero (data : ExplosionData) (source : SourceData data) :
    momentum data 0 + momentum data 1 + momentum data 2 = 0 := by
  change totalMomentum data = 0
  exact (event_momentum_eq data source).trans (pre_momentum_zero data source)

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
  have hScaled := plane.smul_mem (data.mass i)⁻¹ hp
  simpa [momentum, smul_smul, (data.mass_pos i).ne'] using hScaled

/-- Source answer: the three immediate post-explosion velocity vectors lie in
one plane through the origin (dimension ≤ 2). No later fragment dynamics is claimed. -/
theorem solution (data : ExplosionData) (source : SourceData data) :
    TrustedPhysicsProblem data := by
  -- Constant-acceleration mechanics → height maximum → Fermat → zero apex velocity
  -- → zero pre-momentum; Newton II/III → finite gravitational impulse → zero-duration
  -- event limit → zero post-momentum → momentum coplanarity.
  -- Then transfer membership by positive masses.
  obtain ⟨plane, hDimension, hMomenta⟩ := momenta_coplanar data source
  have hVelocities : ∀ i, data.velocity i ∈ plane := by
    intro i
    exact velocity_mem_of_momentum_mem data i (hMomenta i)
  -- Explicit linear conclusion; this is not affine coplanarity of three endpoints.
  change ∃ plane : Submodule ℝ Vector3,
    Module.finrank ℝ plane ≤ 2 ∧ ∀ i, data.velocity i ∈ plane
  exact ⟨plane, hDimension, hVelocities⟩

end LeanVerificationDemo.PhysicsDemo.P08.Candidate
