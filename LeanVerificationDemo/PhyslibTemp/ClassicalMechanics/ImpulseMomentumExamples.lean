import LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.ImpulseMomentum

namespace LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.ImpulseExamples
open scoped BigOperators Topology
open Filter MeasureTheory

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]

omit [CompleteSpace E] in
/-- A genuine two-body interaction with arbitrary equal-and-opposite internal
force f and independent constant external forces a and b. -/
lemma two_body_balance (a b f : E) :
    MomentumBalance
      (![fun t => t • (a + f), fun t => t • (b - f)] : Fin 2 → ℝ → E)
      (fun i j _ => (![![0, f], ![-f, 0]] : Fin 2 → Fin 2 → E) i j)
      ![fun _ => a, fun _ => b] := by
  constructor
  · intro i t
    fin_cases i
    · simpa [Fin.sum_univ_two] using (hasDerivAt_id t).smul_const (a + f)
    · simpa [Fin.sum_univ_two, sub_eq_add_neg] using (hasDerivAt_id t).smul_const (b - f)
  · intro i j t
    fin_cases i <;> fin_cases j <;> simp

-- Internal forces alter individual momenta, but their total contribution cancels.
example (f : E) (t : ℝ) :
    ∑ i, ∑ j, (fun i j _ => (![![0, f], ![-f, 0]] : Fin 2 → Fin 2 → E) i j) i j t = 0 :=
  (two_body_balance (0 : E) 0 f).internal_sum_zero t

-- FTC computes a real finite-duration change, without assuming conservation.
example (a b f : E) (ε : ℝ) :
    (∑ i : Fin 2, (![fun t => t • (a + f), fun t => t • (b - f)] :
      Fin 2 → ℝ → E) i ε) = ε • (a + b) := by
  have h := (two_body_balance a b f).total_change_eq_integral 0 ε
    (by simp [Fin.sum_univ_two])
  simpa [Fin.sum_univ_two, intervalIntegral.integral_const] using h

example : (∫ _t in (0 : ℝ)..2, (3 : ℝ)) ≠ 0 := by norm_num

-- The force is fixed while duration shrinks: a genuine right-hand limit.
example (force : E) (t₀ : ℝ) :
    Tendsto (fun ε => ∫ _t in t₀..t₀ + ε, force) (𝓝[>] (0 : ℝ)) (𝓝 0) :=
  constant_impulse_tendsto_zero force t₀

-- Nonconstant external force also has zero short-interval impulse limit.
example (f : E) :
    Tendsto (fun ε => ∫ t in (0 : ℝ)..ε, t • f) (𝓝[>] (0 : ℝ)) (𝓝 0) := by
  simpa only [zero_add] using continuous_impulse_tendsto_zero
    (fun t : ℝ => t • f) (continuous_id.smul continuous_const) 0

-- Dimension is not fixed by the mechanics layer.
example (f : EuclideanSpace ℝ (Fin 4)) :
    (∫ _t in (5 : ℝ)..5 + 2, f) = (2 : ℝ) • f :=
  constant_impulse f 5 2

example (ε : ℝ) : (∫ _t in (0 : ℝ)..ε, (0 : E)) = 0 := by simp

#print axioms MomentumBalance.total_change_eq_integral
#print axioms constant_impulse_tendsto_zero
#print axioms event_momentum_eq_of_impulse_limit

end LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.ImpulseExamples
