import Physlib.Optics.Wavelength
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic

/-! Ideal monochromatic coherent two-beam interference. The time-averaged
intensity law is adopted, not derived from Maxwell boundary conditions.
Positive beam amplitudes need not be equal; a minimum need not be dark.
Phase offsets are inputs: no universal mirror phase law is asserted here. -/
namespace LeanVerificationDemo.PhyslibTemp.Optics.TwoBeamInterference

noncomputable def phase (wavelength : Wavelength) (pathDifference offset : ℝ) : ℝ :=
  2 * Real.pi * (pathDifference / (wavelength.val : ℝ)) + offset

noncomputable def intensity (a b θ : ℝ) : ℝ :=
  a ^ 2 + b ^ 2 + 2 * a * b * Real.cos θ

def IsMaximum (θ : ℝ) : Prop := Real.cos θ = 1
def IsMinimum (θ : ℝ) : Prop := Real.cos θ = -1

lemma intensity_bounds {a b : ℝ} (ha : 0 < a) (hb : 0 < b) (θ : ℝ) :
    (a - b) ^ 2 ≤ intensity a b θ ∧ intensity a b θ ≤ (a + b) ^ 2 := by
  have hp : 0 ≤ 2 * a * b := by positivity
  have hlo := mul_le_mul_of_nonneg_left (Real.neg_one_le_cos θ) hp
  have hhi := mul_le_mul_of_nonneg_left (Real.cos_le_one θ) hp
  unfold intensity
  constructor <;> nlinarith

lemma intensity_maximum_iff {a b : ℝ} (ha : 0 < a) (hb : 0 < b) (θ : ℝ) :
    intensity a b θ = (a + b) ^ 2 ↔ IsMaximum θ := by
  unfold intensity IsMaximum
  constructor
  · intro h
    have hc : (2 * a * b) * (Real.cos θ - 1) = 0 := by nlinarith
    have hn : 2 * a * b ≠ 0 := by positivity
    have := (mul_eq_zero.mp hc).resolve_left hn
    linarith
  · intro h
    rw [h]
    ring

lemma intensity_minimum_iff {a b : ℝ} (ha : 0 < a) (hb : 0 < b) (θ : ℝ) :
    intensity a b θ = (a - b) ^ 2 ↔ IsMinimum θ := by
  unfold intensity IsMinimum
  constructor
  · intro h
    have hc : (2 * a * b) * (Real.cos θ + 1) = 0 := by nlinarith
    have hn : 2 * a * b ≠ 0 := by positivity
    have := (mul_eq_zero.mp hc).resolve_left hn
    linarith
  · intro h
    rw [h]
    ring

lemma maximum_pi_iff (θ : ℝ) : IsMaximum (θ + Real.pi) ↔ IsMinimum θ := by
  simp only [IsMaximum, IsMinimum, Real.cos_add_pi]
  constructor <;> intro h <;> linarith

lemma minimum_pi_iff (θ : ℝ) : IsMinimum (θ + Real.pi) ↔ IsMaximum θ := by
  simp only [IsMaximum, IsMinimum, Real.cos_add_pi]
  constructor <;> intro h <;> linarith

lemma maximum_iff (θ : ℝ) :
    IsMaximum θ ↔ ∃ n : ℤ, θ = (n : ℝ) * (2 * Real.pi) := by
  simpa only [IsMaximum, eq_comm] using Real.cos_eq_one_iff θ

lemma minimum_iff (θ : ℝ) :
    IsMinimum θ ↔ ∃ n : ℤ, θ = ((n : ℝ) + 1 / 2) * (2 * Real.pi) := by
  constructor
  · intro h
    obtain ⟨n, hn⟩ := (maximum_iff (θ + Real.pi)).mp ((maximum_pi_iff θ).mpr h)
    refine ⟨n - 1, ?_⟩
    push_cast
    nlinarith [hn]
  · rintro ⟨n, hn⟩
    apply (maximum_pi_iff θ).mp
    apply (maximum_iff _).mpr
    refine ⟨n + 1, ?_⟩
    push_cast
    nlinarith [hn]

/-- Constructive integer orders and half-integer destructive orders follow
from the coherent phase/intensity law, not from a screen-specific formula. -/
lemma phase_order_iff (wavelength : Wavelength) (hwavelength : 0 < (wavelength.val : ℝ)) (δ q : ℝ) :
    phase wavelength δ 0 = q * (2 * Real.pi) ↔ δ = q * (wavelength.val : ℝ) := by
  unfold phase
  constructor
  · intro h
    have hc : 2 * Real.pi ≠ 0 := by positivity
    have he : δ / (wavelength.val : ℝ) = q := by
      apply mul_left_cancel₀ hc
      nlinarith [h]
    exact (div_eq_iff hwavelength.ne').mp he
  · intro h
    rw [h]
    field_simp [hwavelength.ne']
    ring

lemma half_wavelength_adds_pi (wavelength : Wavelength)
    (hwavelength : 0 < (wavelength.val : ℝ)) (δ offset : ℝ) :
    phase wavelength (δ + (wavelength.val : ℝ) / 2) offset =
      phase wavelength δ offset + Real.pi := by
  unfold phase
  field_simp [hwavelength.ne']
  <;> ring

lemma maximum_path_iff (wavelength : Wavelength) (hwavelength : 0 < (wavelength.val : ℝ)) (δ : ℝ) :
    IsMaximum (phase wavelength δ 0) ↔ ∃ n : ℤ, δ = (n : ℝ) * (wavelength.val : ℝ) := by
  rw [maximum_iff]
  exact exists_congr fun n => phase_order_iff wavelength hwavelength δ n

lemma minimum_path_iff (wavelength : Wavelength) (hwavelength : 0 < (wavelength.val : ℝ)) (δ : ℝ) :
    IsMinimum (phase wavelength δ 0) ↔ ∃ n : ℤ, δ = ((n : ℝ) + 1 / 2) * (wavelength.val : ℝ) := by
  rw [minimum_iff]
  exact exists_congr fun n => phase_order_iff wavelength hwavelength δ (n + 1 / 2)

end LeanVerificationDemo.PhyslibTemp.Optics.TwoBeamInterference
