import Physlib.ClassicalMechanics.PointParticle.Basic
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Tactic

/-!
# Constant acceleration for upstream Physlib particles

Kinematics in an inertial frame, in any spatial dimension and its real time
coordinate. No force law, gravity, vertical axis or choice of units is built in.
-/
namespace LeanVerificationDemo.PhyslibTemp.ClassicalMechanics
open _root_.ClassicalMechanics

variable {d : ℕ} {frame : ReferenceFrame d} [Fact frame.IsInertial]

/-- An upstream particle has a prescribed constant coordinate acceleration. -/
def HasConstantAcceleration (particle : frame.Particle) (a : frame.Vector) : Prop :=
  ∀ t, particle.acceleration t = a

namespace HasConstantAcceleration
variable {particle : frame.Particle} {a : frame.Vector}

lemma hasDerivAt_velocity (h : HasConstantAcceleration particle a) (t : ℝ) :
    HasDerivAt particle.velocity a t := by
  have hv : HasDerivAt particle.velocity (particle.acceleration t) t :=
    (particle.pos_twice_differentiable (Fact.out : frame.IsInertial)).2 t |>.hasDerivAt
  rwa [h t] at hv

/-- Exact velocity evolution from the derivative-based acceleration premise. -/
lemma velocity_eq (h : HasConstantAcceleration particle a) (t₀ t : ℝ) :
    particle.velocity t = particle.velocity t₀ + (t - t₀) • a := by
  have hd (s : ℝ) : HasDerivAt (fun u => particle.velocity u - u • a) 0 s := by
    convert! (h.hasDerivAt_velocity s).sub ((hasDerivAt_id s).smul_const a) using 1
    simp
  have heq := is_const_of_deriv_eq_zero (fun s => (hd s).differentiableAt)
    (fun s => (hd s).deriv) t t₀
  linear_combination (norm := module) heq

/-- Exact quadratic position evolution; no stronger smoothness than upstream
Particle's two differentiability assumptions is required. -/
lemma position_eq (h : HasConstantAcceleration particle a) (t₀ t : ℝ) :
    particle.pos t = particle.pos t₀ + (t - t₀) • particle.velocity t₀ +
      ((t - t₀) ^ 2 / 2) • a := by
  have hd (s : ℝ) : HasDerivAt
      (fun u => particle.pos u - (u - t₀) • particle.velocity t₀ -
        ((u - t₀) ^ 2 / 2) • a) 0 s := by
    have hp : HasDerivAt particle.pos (particle.velocity s) s :=
      (particle.pos_twice_differentiable (Fact.out : frame.IsInertial)).1 s |>.hasDerivAt
    have hlin := ((hasDerivAt_id s).sub_const t₀).smul_const (particle.velocity t₀)
    have hquad := (((hasDerivAt_id s).sub_const t₀).pow 2).div_const 2 |>.smul_const a
    simp only [id_eq, Pi.pow_apply, Nat.cast_ofNat, Nat.reduceSub, pow_one, mul_one] at hquad
    convert! (hp.sub hlin).sub hquad using 1
    rw [h.velocity_eq t₀ s]
    module
  have heq := is_const_of_deriv_eq_zero (fun s => (hd s).differentiableAt)
    (fun s => (hd s).deriv) t t₀
  simp only [sub_self, zero_smul, sub_zero, ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true,
    zero_pow, zero_div] at heq
  linear_combination (norm := module) heq

lemma velocity_sub (h : HasConstantAcceleration particle a) (t₀ t : ℝ) :
    particle.velocity t - particle.velocity t₀ = (t - t₀) • a := by
  rw [h.velocity_eq t₀ t]
  module

lemma velocity_eq_of_zero (h : HasConstantAcceleration particle 0) (t₀ t : ℝ) :
    particle.velocity t = particle.velocity t₀ := by
  simpa using h.velocity_eq t₀ t

end HasConstantAcceleration
end LeanVerificationDemo.PhyslibTemp.ClassicalMechanics
