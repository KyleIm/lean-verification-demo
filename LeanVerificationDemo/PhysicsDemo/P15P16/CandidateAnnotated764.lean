import LeanVerificationDemo.PhysicsDemo.P15P16.Problem764
import LeanVerificationDemo.PhysicsDemo.P15P16.GeometryDerivation

namespace LeanVerificationDemo.PhysicsDemo.P15P16.P764.CandidateAnnotated
open LeanVerificationDemo.PhyslibTemp.Optics.TwoBeamInterference
open GeometryDerivation

-- [exact Euclidean geometry / source image] Factor the range-square difference from the Fig. 253 source/screen coordinates.
lemma path_square_identity (data : ScreenData) (h : ℝ) :
    (lowerPath data h + upperPath data h) * exactDifference data h =
      2 * h * data.separation := factored_path_difference data h

/-- This coefficient is derived from the explicit 2D closure of the exact
path-square geometry; it is not an exact finite-range replacement. -/
-- [far-field approximation] Simplify the explicitly adopted 2D-denominator closure; do not assert finite ranges sum to 2D.
lemma linearized_path_difference (data : ScreenData) (h : ℝ) :
    paraxialDifference data h = data.separation * h / data.distance :=
  paraxial_difference_eq data h

-- [constructed answer] This formula first occurs on the solution side, not in the trusted target.
noncomputable def solutionSpacing (data : ScreenData) : ℝ :=
  (data.wavelength.val : ℝ) * data.distance / data.separation

-- [shared reusable optics / interference condition / derived physics] Convert constructive phase order to path difference, then solve for screen height.
lemma phase_order_location (data : ScreenData) (q h : ℝ) :
    ordinaryPhase data h = q * (2 * Real.pi) ↔ h = q * solutionSpacing data := by
  rw [ordinaryPhase, phase_order_iff data.wavelength data.wavelength_pos,
    linearized_path_difference]
  unfold solutionSpacing
  constructor <;> intro he
  all_goals
    field_simp [data.distance_pos.ne', data.separation_pos.ne'] at he ⊢
    nlinarith [he]

-- [shared reusable optics] Cosine maxima characterize every integer bright order.
lemma bright_fringe_positions (data : ScreenData) (h : ℝ) :
    IsMaximum (ordinaryPhase data h) ↔ ∃ n : ℤ, h = (n : ℝ) * solutionSpacing data := by
  rw [maximum_iff]
  exact exists_congr fun n => phase_order_location data n h

-- [shared reusable optics] Cosine minima give half-integer dark positions.
lemma dark_fringe_positions (data : ScreenData) (h : ℝ) :
    IsMinimum (ordinaryPhase data h) ↔
      ∃ n : ℤ, h = ((n : ℝ) + 1 / 2) * solutionSpacing data := by
  rw [minimum_iff]
  exact exists_congr fun n => phase_order_location data (n + 1 / 2) h

-- [pure mathematics] Consecutive bright orders differ by the computed spacing.
lemma adjacent_bright_spacing (data : ScreenData) (n : ℤ) :
    ((n + 1 : ℤ) : ℝ) * solutionSpacing data - (n : ℝ) * solutionSpacing data =
      solutionSpacing data := by
  push_cast
  ring

-- [terminology audit / derived physics] Dark-to-dark spacing is the same full period.
lemma adjacent_dark_spacing (data : ScreenData) (n : ℤ) :
    (((n + 1 : ℤ) : ℝ) + 1 / 2) * solutionSpacing data -
      ((n : ℝ) + 1 / 2) * solutionSpacing data = solutionSpacing data := by
  push_cast
  ring

-- [terminology audit / pure mathematics] Neighboring bright and dark centers differ by half a period.
lemma bright_to_neighboring_dark (data : ScreenData) (n : ℤ) :
    ((n : ℝ) + 1 / 2) * solutionSpacing data - (n : ℝ) * solutionSpacing data =
      solutionSpacing data / 2 := by ring

-- [derived physics] The returned spacing satisfies the semantic phase-order and full bright-lattice specification.
lemma spacing_valid (data : ScreenData) : IsFringeSpacing data (solutionSpacing data) := by
  refine ⟨div_pos (mul_pos data.wavelength_pos data.distance_pos) data.separation_pos,
    ?_, bright_fringe_positions data⟩
  intro n h
  exact phase_order_location data n h

/-- Return the computed bright-to-bright spacing Δh = wavelength D/l. -/
-- [final judgment] Return wavelength*D/l and prove uniqueness without storing the answer in Problem.
theorem solution (data : ScreenData) : TrustedPhysicsProblem data := by
  have computed : IsFringeSpacing data
      ((data.wavelength.val : ℝ) * data.distance / data.separation) := spacing_valid data
  refine ⟨solutionSpacing data, computed, ?_⟩
  intro other hOther
  have horder := (hOther.2.1 1 other).mpr (by simp)
  have heq := (computed.2.1 1 other).mp horder
  simpa [solutionSpacing] using heq

end LeanVerificationDemo.PhysicsDemo.P15P16.P764.CandidateAnnotated
