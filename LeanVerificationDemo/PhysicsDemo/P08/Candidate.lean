import LeanVerificationDemo.PhysicsDemo.P08.Problem

namespace LeanVerificationDemo.PhysicsDemo.P08.Candidate

/-- Apex rest implies zero pre-explosion momentum, independently of conservation. -/
lemma pre_momentum_zero (data : ExplosionData) (source : SourceData data) :
    preMomentum data = 0 := by
  simp [preMomentum, source.apex_at_rest]

/-- Source/model physics: the adopted conserved momentum is therefore zero. -/
lemma total_momentum_zero (data : ExplosionData) (source : SourceData data) :
    momentum data 0 + momentum data 1 + momentum data 2 = 0 := by
  change totalMomentum data = 0
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
  -- First prove momentum coplanarity, then transfer membership by positive masses.
  obtain ⟨plane, hDimension, hMomenta⟩ := momenta_coplanar data source
  have hVelocities : ∀ i, data.velocity i ∈ plane := by
    intro i
    exact velocity_mem_of_momentum_mem data i (hMomenta i)
  -- Explicit linear conclusion; this is not affine coplanarity of three endpoints.
  change ∃ plane : Submodule ℝ Vector3,
    Module.finrank ℝ plane ≤ 2 ∧ ∀ i, data.velocity i ∈ plane
  exact ⟨plane, hDimension, hVelocities⟩

end LeanVerificationDemo.PhysicsDemo.P08.Candidate
