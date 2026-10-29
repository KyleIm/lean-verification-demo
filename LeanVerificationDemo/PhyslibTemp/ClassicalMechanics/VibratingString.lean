import Mathlib.Analysis.Real.Sqrt
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Data.PNat.Basic
import Mathlib.Tactic

/-!
# Ideal uniform string fixed at both ends

Positive, constant length, tension and linear mass density specify the standard
small-transverse-oscillation, perfectly flexible, nondispersive string model.
The wave-speed and fixed-end mode laws are adopted physical-model definitions;
this module does not derive them from a PDE or prove spectral completeness.
All real magnitudes use one coherent unit system; frequency means cycles/time,
not angular frequency. No material, cross-section or source numerical data are
built into this reusable layer.
-/
namespace LeanVerificationDemo.PhyslibTemp.ClassicalMechanics

structure FixedString where
  length : ℝ
  length_pos : 0 < length
  tension : ℝ
  tension_pos : 0 < tension
  linearDensity : ℝ
  linearDensity_pos : 0 < linearDensity

namespace FixedString

noncomputable def waveSpeed (s : FixedString) : ℝ := Real.sqrt (s.tension / s.linearDensity)
noncomputable def fundamental (s : FixedString) : ℝ := s.waveSpeed / (2 * s.length)

/-- The physical modes have strictly positive integer index. -/
noncomputable def frequency (s : FixedString) (n : ℕ+) : ℝ :=
  (n : ℝ) / (2 * s.length) * s.waveSpeed

lemma waveSpeed_pos (s : FixedString) : 0 < s.waveSpeed :=
  Real.sqrt_pos.mpr (div_pos s.tension_pos s.linearDensity_pos)

lemma waveSpeed_squared (s : FixedString) : s.waveSpeed ^ 2 = s.tension / s.linearDensity :=
  Real.sq_sqrt (div_pos s.tension_pos s.linearDensity_pos).le

lemma fundamental_pos (s : FixedString) : 0 < s.fundamental :=
  div_pos s.waveSpeed_pos (mul_pos (by norm_num) s.length_pos)

lemma frequency_pos (s : FixedString) (n : ℕ+) : 0 < s.frequency n := by
  have hn : (0 : ℝ) < n := by exact_mod_cast n.pos
  exact mul_pos (div_pos hn (mul_pos (by norm_num) s.length_pos)) s.waveSpeed_pos

lemma fundamental_eq (s : FixedString) :
    s.fundamental = (1 / (2 * s.length)) * Real.sqrt (s.tension / s.linearDensity) := by
  unfold fundamental waveSpeed
  ring

lemma harmonic_scaling (s : FixedString) (n : ℕ+) :
    s.frequency n = (n : ℝ) * s.fundamental := by
  unfold frequency fundamental
  ring

lemma first_frequency (s : FixedString) : s.frequency 1 = s.fundamental := by
  rw [harmonic_scaling]
  norm_num

noncomputable def wavelength (s : FixedString) (n : ℕ+) : ℝ := 2 * s.length / (n : ℝ)

lemma wavelength_pos (s : FixedString) (n : ℕ+) : 0 < s.wavelength n := by
  have hn : (0 : ℝ) < n := by exact_mod_cast n.pos
  exact div_pos (mul_pos (by norm_num) s.length_pos) hn

lemma frequency_eq_speed_div_wavelength (s : FixedString) (n : ℕ+) :
    s.frequency n = s.waveSpeed / s.wavelength n := by
  unfold frequency wavelength
  field_simp

/-- Spatial sine profile compatible with the two fixed ends. This boundary
check is not a derivation/completeness theorem for the wave equation. -/
noncomputable def modeShape (s : FixedString) (n : ℕ+) (x : ℝ) : ℝ :=
  Real.sin ((n : ℝ) * Real.pi * x / s.length)

lemma modeShape_left (s : FixedString) (n : ℕ+) : s.modeShape n 0 = 0 := by
  simp [modeShape]

lemma modeShape_right (s : FixedString) (n : ℕ+) : s.modeShape n s.length = 0 := by
  have harg : (n : ℝ) * Real.pi * s.length / s.length = (n : ℝ) * Real.pi := by
    field_simp [s.length_pos.ne']
  unfold modeShape
  rw [harg]
  exact Real.sin_nat_mul_pi (n : ℕ)

end FixedString
end LeanVerificationDemo.PhyslibTemp.ClassicalMechanics
