import LeanVerificationDemo.PhysicsDemo.P07.Problem

namespace LeanVerificationDemo.PhysicsDemo.P07.Candidate

lemma flux_derivative (data : RingData) (x t : ℝ) :
    deriv (flux data x) t = Real.pi * x ^ 2 * data.k := by
  have heq : flux data x = fun u => (Real.pi * x ^ 2 * data.k) * u := by
    funext u
    dsimp [flux, field]
    ring
  rw [heq]
  simp

/-- Derived local current contribution, obtained from Faraday and Ohm relations. -/
lemma current_per_width (data : RingData) (response : Response data)
    (x : ℝ) (hx : x ∈ Set.Icc data.a.val data.b.val) (t : ℝ) :
    response.currentPerWidth x t =
      (sourceFactor * data.k * data.h.val / (2 * data.ρ.val)) * x := by
  have hx0 : x ≠ 0 := (lt_of_lt_of_le data.a_pos hx.1).ne'
  have hp := response.ohm x hx t
  rw [response.faraday x hx t, flux_derivative] at hp
  dsimp [resistanceCoefficient] at hp
  have hr : data.ρ.val ≠ 0 := data.ρ_pos.ne'
  have hh : data.h.val ≠ 0 := data.h_pos.ne'
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  field_simp at hp ⊢
  nlinarith [hp]

/-- The derived radial current is genuinely interval-integrable; the total is
not using the integral's default value for a nonintegrable function. -/
lemma current_integrable (data : RingData) (response : Response data) (t : ℝ) :
    IntervalIntegrable (fun x => response.currentPerWidth x t)
      MeasureTheory.volume data.a.val data.b.val := by
  have hi : IntervalIntegrable
      (fun x : ℝ => (sourceFactor * data.k * data.h.val / (2 * data.ρ.val)) * x)
      MeasureTheory.volume data.a.val data.b.val :=
    (continuous_const.mul continuous_id).intervalIntegrable _ _
  apply hi.congr
  intro x hx
  have hx' : data.a.val < x ∧ x ≤ data.b.val := by
    simpa [Set.uIoc_of_le data.a_lt_b.le] using hx
  exact (current_per_width data response x ⟨hx'.1.le, hx'.2⟩ t).symm

/-- Derive the source formula by evaluating the continuum integral. No discrete
partition-to-integral convergence theorem is claimed by this proof. -/
theorem solution (data : RingData) (response : Response data) :
    TrustedPhysicsProblem data response := by
  intro t
  change (∫ x in data.a.val..data.b.val, response.currentPerWidth x t) = _
  have heq := intervalIntegral.integral_congr (μ := MeasureTheory.volume) (a := data.a.val) (b := data.b.val)
    (fun x hx => current_per_width data response x
      (by simpa [Set.uIcc_of_le data.a_lt_b.le] using hx) t)
  rw [heq, intervalIntegral.integral_const_mul, integral_id]
  ring

end LeanVerificationDemo.PhysicsDemo.P07.Candidate
