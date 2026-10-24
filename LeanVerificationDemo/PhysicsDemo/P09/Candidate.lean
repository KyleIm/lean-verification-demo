import LeanVerificationDemo.PhysicsDemo.P09.Problem

namespace LeanVerificationDemo.PhysicsDemo.P09.Candidate
open _root_.ClassicalMechanics
open LeanVerificationDemo.PhyslibTemp.ClassicalMechanics

/-- Horizontal support balance and the local sliding-friction law give a = μg.
This is not an assertion that a sliding puck is in static equilibrium. -/
lemma friction_acceleration (data : PuckData) (model : SlidingModel data) :
    deceleration data = data.μ * data.g := by
  unfold deceleration
  rw [model.sliding_friction, model.normal_balance]
  field_simp [data.before.mass.property.ne']

lemma deceleration_nonneg (data : PuckData) (model : SlidingModel data) :
    0 ≤ deceleration data := by
  rw [friction_acceleration data model]
  exact mul_nonneg data.μ_nonneg data.g_pos.le

/-- Newton II gives constant negative coordinate acceleration on the first leg. -/
lemma segment_deceleration_before (data : PuckData) (model : SlidingModel data) :
    HasConstantAcceleration data.before ((-deceleration data) • tangent) := by
  intro t
  apply ReferenceFrame.Vector.componentEquiv.injective
  funext i
  fin_cases i
  change (data.before.acceleration t).components 0 = -deceleration data * 1
  rw [mul_one]
  apply mul_left_cancel₀ data.before.mass.property.ne'
  rw [model.newton_before]
  dsimp [deceleration]
  field_simp [data.before.mass.property.ne']

lemma segment_deceleration_after (data : PuckData) (model : SlidingModel data) :
    HasConstantAcceleration data.after ((-deceleration data) • tangent) := by
  intro t
  apply ReferenceFrame.Vector.componentEquiv.injective
  funext i
  fin_cases i
  change (data.after.acceleration t).components 0 = -deceleration data * 1
  rw [mul_one]
  apply mul_left_cancel₀ data.after.mass.property.ne'
  rw [model.newton_after, model.same_mass]
  dsimp [deceleration]
  field_simp [data.before.mass.property.ne']

/-- Project the existing reusable velocity law onto one segment's path axis. -/
lemma segment_velocity (p : trackFrame.Particle) (a : ℝ)
    (ha : HasConstantAcceleration p ((-a) • tangent)) (t : ℝ) :
    speed p t = speed p 0 - a * t := by
  have h := congrArg (fun v : trackFrame.Vector => v.components 0) (ha.velocity_eq 0 t)
  change speed p t = speed p 0 + (t - 0) * (-a * 1) at h
  linarith

/-- Project the reusable quadratic position law; no v² = 2as premise is used. -/
lemma segment_travel (p : trackFrame.Particle) (a : ℝ)
    (ha : HasConstantAcceleration p ((-a) • tangent)) (t : ℝ) :
    travel p t = t * speed p 0 - a * t ^ 2 / 2 := by
  have h := congrArg (fun v : trackFrame.Vector => v.components 0) (ha.position_eq 0 t)
  change (p.pos t).components 0 = (p.pos 0).components 0 +
    (t - 0) * speed p 0 + ((t - 0) ^ 2 / 2) * (-a * 1) at h
  unfold travel
  nlinarith

/-- Eliminate time from the two derived kinematic laws. -/
lemma segment_speed_squared (p : trackFrame.Particle) (a : ℝ)
    (ha : HasConstantAcceleration p ((-a) • tangent)) (t : ℝ) :
    speed p t ^ 2 = speed p 0 ^ 2 - 2 * a * travel p t := by
  rw [segment_velocity p a ha t, segment_travel p a ha t]
  ring

/-- No reversal occurs on either modeled sliding interval. This justifies
using each oriented displacement as its travelled distance. -/
lemma sliding_speeds_nonnegative (data : PuckData) (model : SlidingModel data) :
    (∀ t ∈ Set.Icc 0 data.firstDuration, 0 ≤ speed data.before t) ∧
    (∀ t ∈ Set.Icc 0 data.secondDuration, 0 ≤ speed data.after t) := by
  have ha := deceleration_nonneg data model
  constructor
  · intro t ht
    have hv := segment_velocity data.before _ (segment_deceleration_before data model) t
    have hend := segment_velocity data.before _ (segment_deceleration_before data model)
      data.firstDuration
    have hprod := mul_nonneg ha (sub_nonneg.mpr ht.2)
    linarith [model.incoming_nonneg]
  · intro t ht
    have hv := segment_velocity data.after _ (segment_deceleration_after data model) t
    have hend := segment_velocity data.after _ (segment_deceleration_after data model)
      data.secondDuration
    have hprod := mul_nonneg ha (sub_nonneg.mpr ht.2)
    rw [model.final_at_rest] at hend
    linarith

/-- Local elastic energy interpretation → preservation of speed magnitude.
This does not derive a wall reflection map or collision angle. -/
lemma impact_preserves_speed (data : PuckData) (model : SlidingModel data) :
    |speed data.before data.firstDuration| = |speed data.after 0| := by
  exact (sq_eq_sq_iff_abs_eq_abs _ _).mp model.elastic_impact

lemma impact_speed_eq (data : PuckData) (model : SlidingModel data) :
    speed data.before data.firstDuration = speed data.after 0 := by
  have h := impact_preserves_speed data model
  rw [abs_of_nonneg model.incoming_nonneg,
    abs_of_nonneg ((sliding_speeds_nonnegative data model).2 0
      ⟨le_rfl, data.secondDuration_pos.le⟩)] at h
  exact h

/-- Same deceleration and elastic speed matching allow the two distance losses
to be added. Total path, not displacement across the reflection, appears here. -/
lemma stopping_relation (data : PuckData) (model : SlidingModel data) :
    data.initialSpeed ^ 2 = 2 * deceleration data * (data.firstPath + data.secondPath) := by
  have hBefore := segment_speed_squared data.before _
    (segment_deceleration_before data model) data.firstDuration
  have hAfter := segment_speed_squared data.after _
    (segment_deceleration_after data model) data.secondDuration
  rw [model.initial_speed, model.first_path, impact_speed_eq data model] at hBefore
  rw [model.final_at_rest, model.second_path] at hAfter
  nlinarith

/-- Explicit textbook deceleration formula, now a derived result. -/
lemma deceleration_from_stopping (data : PuckData) (model : SlidingModel data) :
    deceleration data = data.initialSpeed ^ 2 / (2 * (data.firstPath + data.secondPath)) := by
  have hs := stopping_relation data model
  have hden : 0 < 2 * (data.firstPath + data.secondPath) :=
    mul_pos (by norm_num) (add_pos data.firstPath_pos data.secondPath_pos)
  apply (eq_div_iff hden.ne').2
  nlinarith

lemma coefficient_from_deceleration (data : PuckData) (model : SlidingModel data) :
    data.μ = deceleration data / data.g := by
  exact (eq_div_iff data.g_pos.ne').2 (friction_acceleration data model).symm

lemma coefficient_symbolic (data : PuckData) (model : SlidingModel data) :
    data.μ = data.initialSpeed ^ 2 / (2 * data.g * (data.firstPath + data.secondPath)) := by
  rw [coefficient_from_deceleration data model, deceleration_from_stopping data model, div_div]
  congr 1
  ring

lemma total_path (data : PuckData) (source : SourceData data) :
    data.firstPath + data.secondPath = 25 / 2 := by
  rw [source.first_path_value, source.second_path_value]
  norm_num

/-- Exact source specialization: μ = 25 / (2 · 9.8 · 12.5) = 5/49. -/
lemma coefficient_exact (data : PuckData) (source : SourceData data) :
    data.μ = (5 : ℝ) / 49 := by
  rw [coefficient_symbolic data source.model, source.initial_value,
    source.gravity_value, total_path data source]
  norm_num

/-- The printed 0.102 is a three-decimal approximation, not an exact equality. -/
lemma coefficient_source_value (data : PuckData) (source : SourceData data) :
    |data.μ - (102 : ℝ) / 1000| < 1 / 2000 := by
  rw [coefficient_exact data source]
  norm_num

lemma coefficient_decimal_interval (data : PuckData) (source : SourceData data) :
    (1020408 : ℝ) / 10000000 < data.μ ∧ data.μ < (1020409 : ℝ) / 10000000 := by
  rw [coefficient_exact data source]
  norm_num

/-- Source answer: the coefficient is exactly 5/49, approximately 0.102.
Newton/friction → two constant-deceleration legs → elastic speed matching
→ total stopping relation → symbolic coefficient → source values. -/
theorem solution (data : PuckData) (source : SourceData data) :
    TrustedPhysicsProblem data := by
  change data.μ = (5 : ℝ) / 49 ∧ |data.μ - (102 : ℝ) / 1000| < 1 / 2000
  have exactCoefficient : data.μ = (5 : ℝ) / 49 := coefficient_exact data source
  have sourceRounded : |data.μ - (102 : ℝ) / 1000| < 1 / 2000 :=
    coefficient_source_value data source
  exact ⟨exactCoefficient, sourceRounded⟩

end LeanVerificationDemo.PhysicsDemo.P09.Candidate
