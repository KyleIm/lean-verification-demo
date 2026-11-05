import LeanVerificationDemo.PhysicsDemo.P15P16.Problem764
import LeanVerificationDemo.PhysicsDemo.P15P16.GeometryDerivation

namespace LeanVerificationDemo.PhysicsDemo.P15P16.P764.Candidate
open LeanVerificationDemo.PhyslibTemp.Optics.TwoBeamInterference
open GeometryDerivation

lemma path_square_identity (data : ScreenData) (h : ℝ) :
    (lowerPath data h + upperPath data h) * exactDifference data h =
      2 * h * data.separation := factored_path_difference data h

/-- This coefficient is derived from the explicit 2D closure of the exact
path-square geometry; it is not an exact finite-range replacement. -/
lemma linearized_path_difference (data : ScreenData) (h : ℝ) :
    paraxialDifference data h = data.separation * h / data.distance :=
  paraxial_difference_eq data h

noncomputable def solutionSpacing (data : ScreenData) : ℝ :=
  (data.wavelength.val : ℝ) * data.distance / data.separation

lemma phase_order_location (data : ScreenData) (q h : ℝ) :
    ordinaryPhase data h = q * (2 * Real.pi) ↔ h = q * solutionSpacing data := by
  rw [ordinaryPhase, phase_order_iff data.wavelength data.wavelength_pos,
    linearized_path_difference]
  unfold solutionSpacing
  constructor <;> intro he
  all_goals
    field_simp [data.distance_pos.ne', data.separation_pos.ne'] at he ⊢
    nlinarith [he]

lemma bright_fringe_positions (data : ScreenData) (h : ℝ) :
    IsMaximum (ordinaryPhase data h) ↔ ∃ n : ℤ, h = (n : ℝ) * solutionSpacing data := by
  rw [maximum_iff]
  exact exists_congr fun n => phase_order_location data n h

lemma dark_fringe_positions (data : ScreenData) (h : ℝ) :
    IsMinimum (ordinaryPhase data h) ↔
      ∃ n : ℤ, h = ((n : ℝ) + 1 / 2) * solutionSpacing data := by
  rw [minimum_iff]
  exact exists_congr fun n => phase_order_location data (n + 1 / 2) h

lemma adjacent_bright_spacing (data : ScreenData) (n : ℤ) :
    ((n + 1 : ℤ) : ℝ) * solutionSpacing data - (n : ℝ) * solutionSpacing data =
      solutionSpacing data := by
  push_cast
  ring

lemma adjacent_dark_spacing (data : ScreenData) (n : ℤ) :
    (((n + 1 : ℤ) : ℝ) + 1 / 2) * solutionSpacing data -
      ((n : ℝ) + 1 / 2) * solutionSpacing data = solutionSpacing data := by
  push_cast
  ring

lemma bright_to_neighboring_dark (data : ScreenData) (n : ℤ) :
    ((n : ℝ) + 1 / 2) * solutionSpacing data - (n : ℝ) * solutionSpacing data =
      solutionSpacing data / 2 := by ring

lemma spacing_valid (data : ScreenData) : IsFringeSpacing data (solutionSpacing data) := by
  refine ⟨div_pos (mul_pos data.wavelength_pos data.distance_pos) data.separation_pos,
    ?_, bright_fringe_positions data⟩
  intro n h
  exact phase_order_location data n h

/-- Return the computed bright-to-bright spacing Δh = wavelength D/l. -/
theorem solution (data : ScreenData) : TrustedPhysicsProblem data := by
  have computed : IsFringeSpacing data
      ((data.wavelength.val : ℝ) * data.distance / data.separation) := spacing_valid data
  refine ⟨solutionSpacing data, computed, ?_⟩
  intro other hOther
  have horder := (hOther.2.1 1 other).mpr (by simp)
  have heq := (computed.2.1 1 other).mp horder
  simpa [solutionSpacing] using heq

end LeanVerificationDemo.PhysicsDemo.P15P16.P764.Candidate
