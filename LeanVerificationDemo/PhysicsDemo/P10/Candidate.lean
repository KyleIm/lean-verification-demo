import LeanVerificationDemo.PhysicsDemo.P10.Problem
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Pow

namespace LeanVerificationDemo.PhysicsDemo.P10.Candidate
open MeasureTheory

lemma velocity_at_vertices (i : Fin 9) : velocity (time i) = ordinate i := by
  fin_cases i <;> norm_num [velocity, segment, linearSegment, time, ordinate]

lemma velocity_at_zero : velocity 0 = 0 := velocity_at_vertices 0
lemma velocity_at_five : velocity 5 = 4 := velocity_at_vertices 4
lemma velocity_at_ten : velocity 10 = 2 := velocity_at_vertices 8

lemma segment_times_increasing (i : Fin 8) : time i.castSucc < time i.succ := by
  fin_cases i <;> norm_num [time]

/-- The actual velocity function agrees with the straight interpolation on
every closed caption segment, including the shared endpoints. -/
lemma velocity_on_segment (i : Fin 8) :
    Set.EqOn velocity (segment i) (Set.Icc (time i.castSucc) (time i.succ)) := by
  intro t ht
  fin_cases i <;> norm_num [time] at ht <;>
    simp only [velocity] <;> split_ifs <;>
    norm_num [segment, linearSegment, time, ordinate] <;> linarith

lemma velocity_nonnegative_on_zero_ten :
    ∀ t ∈ Set.Icc (0 : ℝ) 10, 0 ≤ velocity t := by
  intro t ht
  rcases ht with ⟨hzero, hten⟩
  unfold velocity
  split_ifs <;> norm_num [segment, linearSegment, time, ordinate] <;> linarith

/-- Integrate a straight interpolation using a proved antiderivative and actual
interval integrability. The trapezoid area is a theorem, never a caption input. -/
lemma integral_linear_segment (a b u w : ℝ) (hab : a < b) :
    (∫ t in a..b, linearSegment a b u w t) = (b - a) * (u + w) / 2 := by
  let c := (w - u) / (b - a)
  have hd (t : ℝ) : HasDerivAt (fun x => u * x + c * (x ^ 2 / 2 - a * x))
      (linearSegment a b u w t) t := by
    convert! ((hasDerivAt_id t).const_mul u).add
      ((((hasDerivAt_pow 2 t).div_const 2).sub
        ((hasDerivAt_id t).const_mul a)).const_mul c) using 1
    dsimp [linearSegment, c]
    ring
  have hint : IntervalIntegrable (linearSegment a b u w) volume a b :=
    (show Continuous (linearSegment a b u w) by unfold linearSegment; fun_prop).intervalIntegrable a b
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun t _ => hd t) hint]
  dsimp [c]
  field_simp [ne_of_gt (sub_pos.mpr hab)]
  ring

lemma segment_integrable (i : Fin 8) :
    IntervalIntegrable velocity volume (time i.castSucc) (time i.succ) := by
  have hc : Continuous (segment i) := by unfold segment linearSegment; fun_prop
  apply (hc.intervalIntegrable _ _).congr
  intro t ht
  rw [Set.uIoc_of_le (segment_times_increasing i).le] at ht
  exact (velocity_on_segment i ⟨ht.1.le, ht.2⟩).symm

lemma segment_integral (i : Fin 8) :
    (∫ t in time i.castSucc..time i.succ, velocity t) =
      (time i.succ - time i.castSucc) * (ordinate i.castSucc + ordinate i.succ) / 2 := by
  calc
    _ = ∫ t in time i.castSucc..time i.succ, segment i t := by
      apply intervalIntegral.integral_congr
      simpa only [Set.uIcc_of_le (segment_times_increasing i).le] using velocity_on_segment i
    _ = _ := integral_linear_segment _ _ _ _ (segment_times_increasing i)

/-- Numerical segment areas are derived from the caption endpoints. -/
lemma segment_areas (i : Fin 8) :
    (∫ t in time i.castSucc..time i.succ, velocity t) =
      (![1 / 2, 1, 2, 7, 4, 7 / 2, 5, 2] : Fin 8 → ℝ) i := by
  rw [segment_integral]
  fin_cases i <;> norm_num [time, ordinate]

lemma integrable_first_five : IntervalIntegrable velocity volume 0 5 :=
  (((segment_integrable 0).trans (segment_integrable 1)).trans
    (segment_integrable 2)).trans (segment_integrable 3)

/-- The first four derived trapezoids give 1/2 + 1 + 2 + 7 = 21/2 cm. -/
lemma distance_first_five : displacement 5 = 21 / 2 := by
  have h02 := intervalIntegral.integral_add_adjacent_intervals (segment_integrable 0)
    (segment_integrable 1)
  have h03 := intervalIntegral.integral_add_adjacent_intervals
    ((segment_integrable 0).trans (segment_integrable 1)) (segment_integrable 2)
  have h05 := intervalIntegral.integral_add_adjacent_intervals
    (((segment_integrable 0).trans (segment_integrable 1)).trans (segment_integrable 2))
    (segment_integrable 3)
  have ha0 := segment_areas 0
  have ha1 := segment_areas 1
  have ha2 := segment_areas 2
  have ha3 := segment_areas 3
  norm_num [time] at h02 h03 h05 ha0 ha1 ha2 ha3
  unfold displacement
  linarith

lemma integrable_first_ten : IntervalIntegrable velocity volume 0 10 :=
  (((integrable_first_five.trans (segment_integrable 4)).trans
    (segment_integrable 5)).trans (segment_integrable 6)).trans (segment_integrable 7)

/-- Add the remaining areas 4 + 7/2 + 5 + 2 to obtain 25 cm. -/
lemma distance_first_ten : displacement 10 = 25 := by
  have h06 := intervalIntegral.integral_add_adjacent_intervals integrable_first_five
    (segment_integrable 4)
  have h07 := intervalIntegral.integral_add_adjacent_intervals
    (integrable_first_five.trans (segment_integrable 4)) (segment_integrable 5)
  have h09 := intervalIntegral.integral_add_adjacent_intervals
    ((integrable_first_five.trans (segment_integrable 4)).trans (segment_integrable 5))
    (segment_integrable 6)
  have h010 := intervalIntegral.integral_add_adjacent_intervals
    (((integrable_first_five.trans (segment_integrable 4)).trans (segment_integrable 5)).trans
      (segment_integrable 6)) (segment_integrable 7)
  have ha4 := segment_areas 4
  have ha5 := segment_areas 5
  have ha6 := segment_areas 6
  have ha7 := segment_areas 7
  norm_num [time] at h06 h07 h09 h010 ha4 ha5 ha6 ha7
  have hFirst := distance_first_five
  unfold displacement at *
  linarith

/-- Only this nonnegative source graph identifies path with displacement. -/
lemma path_eq_displacement {T : ℝ} (hT : 0 ≤ T) (hTen : T ≤ 10) :
    pathTravelled T = displacement T := by
  apply intervalIntegral.integral_congr
  intro t ht
  rw [Set.uIcc_of_le hT] at ht
  exact abs_of_nonneg (velocity_nonnegative_on_zero_ten t ⟨ht.1, ht.2.trans hTen⟩)

lemma mean_velocity_five : meanVelocity 5 = 21 / 10 := by
  rw [meanVelocity, distance_first_five]
  norm_num

lemma mean_velocity_ten : meanVelocity 10 = 5 / 2 := by
  rw [meanVelocity, distance_first_ten]
  norm_num

lemma mean_acceleration_five : meanAcceleration 5 = 4 / 5 := by
  rw [meanAcceleration, velocity_at_five, velocity_at_zero]
  norm_num

lemma mean_acceleration_ten : meanAcceleration 10 = 1 / 5 := by
  rw [meanAcceleration, velocity_at_ten, velocity_at_zero]
  norm_num

/-- Source-facing four answers, derived from the input graph, not solution evidence. -/
theorem solution : TrustedPhysicsProblem := by
  change meanVelocity 5 = 21 / 10 ∧ meanAcceleration 5 = 4 / 5 ∧
    meanVelocity 10 = 5 / 2 ∧ meanAcceleration 10 = 1 / 5
  have meanVelocity5 : meanVelocity 5 = 21 / 10 := mean_velocity_five
  have meanAcceleration5 : meanAcceleration 5 = 4 / 5 := mean_acceleration_five
  have meanVelocity10 : meanVelocity 10 = 5 / 2 := mean_velocity_ten
  have meanAcceleration10 : meanAcceleration 10 = 1 / 5 := mean_acceleration_ten
  exact ⟨meanVelocity5, meanAcceleration5, meanVelocity10, meanAcceleration10⟩

end LeanVerificationDemo.PhysicsDemo.P10.Candidate
