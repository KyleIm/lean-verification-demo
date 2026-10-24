import LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.ConstantAcceleration

/-! Library-level consistency examples, independent of any source problem. -/
namespace LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.Examples
open _root_.ClassicalMechanics

variable {d : ℕ} {frame : ReferenceFrame d} [Fact frame.IsInertial]

lemma quadratic_hasDerivAt (q v a : frame.Vector) (t : ℝ) :
    HasDerivAt (fun s : ℝ => q + s • v + (s ^ 2 / 2) • a) (v + t • a) t := by
  convert! ((hasDerivAt_const t q).add ((hasDerivAt_id t).smul_const v)).add
    (((hasDerivAt_pow 2 t).div_const 2).smul_const a) using 1
  module

/-- A test witness built from upstream Particle, not a parallel particle type. -/
noncomputable def quadraticParticle (m : {m : ℝ // 0 < m}) (q v a : frame.Vector) :
    frame.Particle where
  mass := m
  pos s := q + s • v + (s ^ 2 / 2) • a
  pos_twice_differentiable _ := by
    refine ⟨fun s => (quadratic_hasDerivAt q v a s).differentiableAt, ?_⟩
    have hd : deriv (fun s : ℝ => q + s • v + (s ^ 2 / 2) • a) =
        fun s => v + s • a := funext fun s => (quadratic_hasDerivAt q v a s).deriv
    rw [hd]
    fun_prop

lemma quadratic_velocity (m : {m : ℝ // 0 < m}) (q v a : frame.Vector) (t : ℝ) :
    (quadraticParticle m q v a).velocity t = v + t • a :=
  (quadratic_hasDerivAt q v a t).deriv

lemma quadratic_constant (m : {m : ℝ // 0 < m}) (q v a : frame.Vector) :
    HasConstantAcceleration (quadraticParticle m q v a) a := by
  intro t
  change deriv (quadraticParticle m q v a).velocity t = a
  have hv : (quadraticParticle m q v a).velocity = fun s => v + s • a :=
    funext fun s => quadratic_velocity m q v a s
  rw [hv]
  simpa using ((hasDerivAt_const t v).add ((hasDerivAt_id t).smul_const a)).deriv

-- Arbitrary spatial dimension, arbitrary reference time, and arbitrary vectors.
example (m : {m : ℝ // 0 < m}) (q v a : frame.Vector) (t₀ t : ℝ) :
    (quadraticParticle m q v a).velocity t - (quadraticParticle m q v a).velocity t₀ =
      (t - t₀) • a := (quadratic_constant m q v a).velocity_sub t₀ t

example (m : {m : ℝ // 0 < m}) (q v a : frame.Vector) (t₀ Δt : ℝ) :
    (quadraticParticle m q v a).pos (t₀ + Δt) =
      (quadraticParticle m q v a).pos t₀ + Δt • (quadraticParticle m q v a).velocity t₀ +
        (Δt ^ 2 / 2) • a := by
  simpa using (quadratic_constant m q v a).position_eq t₀ (t₀ + Δt)

example (m : {m : ℝ // 0 < m}) (q v : frame.Vector) (t₀ t : ℝ) :
    (quadraticParticle m q v 0).velocity t = (quadraticParticle m q v 0).velocity t₀ :=
  (quadratic_constant m q v 0).velocity_eq_of_zero t₀ t

example (m : {m : ℝ // 0 < m}) (q a : frame.Vector) (t : ℝ) :
    (quadraticParticle m q 0 a).velocity t = t • a := by
  simpa using quadratic_velocity m q 0 a t

example (m : {m : ℝ // 0 < m}) (q : frame.Vector) (t : ℝ) :
    (quadraticParticle m q 0 0).pos t = q := by
  calc
    (quadraticParticle m q 0 0).pos t = (quadraticParticle m q 0 0).pos 0 +
        (t - 0) • (quadraticParticle m q 0 0).velocity 0 + ((t - 0) ^ 2 / 2) • (0 : frame.Vector) :=
      (quadratic_constant m q 0 0).position_eq 0 t
    _ = q := by
      rw [quadratic_velocity]
      simp [quadraticParticle]

-- Explicit non-three-dimensional checks; these construct actual upstream particles.
example (frame4 : ReferenceFrame 4) [Fact frame4.IsInertial] (q v a : frame4.Vector) :
    (quadraticParticle ⟨1, by norm_num⟩ q v a).velocity 3 -
      (quadraticParticle ⟨1, by norm_num⟩ q v a).velocity 1 = (2 : ℝ) • a := by
  have h := (quadratic_constant ⟨1, by norm_num⟩ q v a).velocity_sub 1 3
  norm_num at h ⊢
  exact h

example (frame4 : ReferenceFrame 4) [Fact frame4.IsInertial] (q v a : frame4.Vector) :
    (quadraticParticle ⟨1, by norm_num⟩ q v a).pos 3 =
      (quadraticParticle ⟨1, by norm_num⟩ q v a).pos 1 +
      (2 : ℝ) • (quadraticParticle ⟨1, by norm_num⟩ q v a).velocity 1 + (2 : ℝ) • a := by
  have h := (quadratic_constant ⟨1, by norm_num⟩ q v a).position_eq 1 3
  norm_num at h ⊢
  exact h

example (frame0 : ReferenceFrame 0) [Fact frame0.IsInertial] (q : frame0.Vector) (t : ℝ) :
    (quadraticParticle ⟨1, by norm_num⟩ q 0 0).velocity t =
      (quadraticParticle ⟨1, by norm_num⟩ q 0 0).velocity 0 :=
  (quadratic_constant ⟨1, by norm_num⟩ q 0 0).velocity_eq_of_zero 0 t

end LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.Examples
