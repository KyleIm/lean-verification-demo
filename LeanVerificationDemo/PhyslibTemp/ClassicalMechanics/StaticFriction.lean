import Mathlib.Basic.Real.Basic
import Mathlib.Algebra.Order.Ring.Abs

/-!
# Coulomb static-friction relations

Real force coordinates use a consistent unit (newtons in P05). A signed tangential
force may adjust within the bound; equality is imposed only at limiting friction.
No kinetic-friction or post-slip dynamics is specified.
-/
namespace LeanVerificationDemo.PhyslibTemp.ClassicalMechanics

/-- Coulomb static-friction admissibility, including the physical sign domain. -/
def StaticFriction (μ N Ft : ℝ) : Prop :=
  0 ≤ μ ∧ 0 ≤ N ∧ |Ft| ≤ μ * N

/-- Saturated static friction; this is not the law for every sticking contact. -/
def LimitingStaticFriction (μ N Ft : ℝ) : Prop :=
  0 ≤ μ ∧ 0 ≤ N ∧ |Ft| = μ * N

end LeanVerificationDemo.PhyslibTemp.ClassicalMechanics
