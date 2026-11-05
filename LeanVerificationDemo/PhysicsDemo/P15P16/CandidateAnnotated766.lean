import LeanVerificationDemo.PhysicsDemo.P15P16.Problem766
import LeanVerificationDemo.PhysicsDemo.P15P16.GeometryDerivation

namespace LeanVerificationDemo.PhysicsDemo.P15P16.P766.CandidateAnnotated
open LeanVerificationDemo.PhyslibTemp.Optics.TwoBeamInterference
open GeometryDerivation

-- [reflection phase shift / supplied solution] Pi reversal is the optical model premise, not a consequence of geometric ray reflection.
lemma reflection_adds_pi (data : ScreenData) (h : ℝ) :
    lloydPhase data h = ordinaryPhase data h + Real.pi := by
  unfold lloydPhase ordinaryPhase phase
  ring

-- [shared reusable optics / derived physics] Use the cosine phase-reversal theorem; extrema swap for arbitrary positive beam amplitudes.
lemma maxima_minima_interchange (data : ScreenData) (h : ℝ) :
    (IsMaximum (lloydPhase data h) ↔ IsMinimum (ordinaryPhase data h)) ∧
    (IsMinimum (lloydPhase data h) ↔ IsMaximum (ordinaryPhase data h)) := by
  rw [reflection_adds_pi]
  exact ⟨maximum_pi_iff _, minimum_pi_iff _⟩

-- [self-contained Lean replacement] Equal-phase ordinary reference is explicitly represented here.
lemma ordinary_center_maximum (data : ScreenData) : IsMaximum (ordinaryPhase data 0) := by
  simp [ordinaryPhase, paraxial_difference_eq, phase, IsMaximum]

-- [derived physics] The center minimum follows from pi reversal, rather than being a source-evidence field.
lemma lloyd_center_minimum (data : ScreenData) : IsMinimum (lloydPhase data 0) :=
  (maxima_minima_interchange data 0).2.mpr (ordinary_center_maximum data)

/-- Computed independently here: no Candidate764 import or theorem. -/
-- [textbook cross-problem dependency / self-contained Lean replacement] Derive the ordinary comparison period locally; do not import Candidate764.
noncomputable def ordinaryPeriod (data : ScreenData) : ℝ :=
  (data.wavelength.val : ℝ) * data.distance / data.separation
-- [constructed answer] The spatial phase-translation witness is supplied by Candidate.
noncomputable def solutionShift (data : ScreenData) : ℝ :=
  (data.wavelength.val : ℝ) * data.distance / (2 * data.separation)

-- [far-field approximation / interference condition] Solve this problem's own phase model using shared geometry and optics.
lemma ordinary_order_location (data : ScreenData) (q h : ℝ) :
    ordinaryPhase data h = q * (2 * Real.pi) ↔ h = q * ordinaryPeriod data := by
  rw [ordinaryPhase, phase_order_iff data.wavelength data.wavelength_pos,
    paraxial_difference_eq]
  unfold ordinaryPeriod
  constructor <;> intro he
  all_goals
    field_simp [data.distance_pos.ne', data.separation_pos.ne'] at he ⊢
    nlinarith [he]

-- [derived physics] Lloyd bright centers occupy the ordinary half-integer positions.
lemma lloyd_bright_positions (data : ScreenData) (h : ℝ) :
    IsMaximum (lloydPhase data h) ↔
      ∃ n : ℤ, h = ((n : ℝ) + 1 / 2) * ordinaryPeriod data := by
  rw [(maxima_minima_interchange data h).1, minimum_iff]
  exact exists_congr fun n => ordinary_order_location data (n + 1 / 2) h

-- [derived physics] Lloyd minima occupy the ordinary integer positions, including zero.
lemma lloyd_dark_positions (data : ScreenData) (h : ℝ) :
    IsMinimum (lloydPhase data h) ↔
      ∃ n : ℤ, h = (n : ℝ) * ordinaryPeriod data := by
  rw [(maxima_minima_interchange data h).2, maximum_iff]
  exact exists_congr fun n => ordinary_order_location data n h

-- [terminology audit / pure mathematics] The displacement is half the bright-to-bright period, not a full period.
lemma half_period_shift (data : ScreenData) : solutionShift data = ordinaryPeriod data / 2 := by
  unfold solutionShift ordinaryPeriod
  ring

-- [shared reusable optics / reflection phase shift] Derive the equivalent half-wavelength path offset.
lemma reflection_path_offset (data : ScreenData) (h : ℝ) :
    lloydPhase data h = phase data.wavelength
      (paraxialDifference data h + (data.wavelength.val : ℝ) / 2) 0 := by
  rw [half_wavelength_adds_pi data.wavelength data.wavelength_pos]
  exact reflection_adds_pi data h

-- [derived geometry / far-field approximation] The computed spatial shift produces that path offset.
lemma shifted_path_difference (data : ScreenData) (h : ℝ) :
    paraxialDifference data (h + solutionShift data) =
      paraxialDifference data h + (data.wavelength.val : ℝ) / 2 := by
  rw [paraxial_difference_eq, paraxial_difference_eq]
  unfold solutionShift
  field_simp [data.distance_pos.ne', data.separation_pos.ne']
  <;> ring

-- [derived physics] The computed shift aligns the two explicit phase functions.
lemma phase_translation (data : ScreenData) (h : ℝ) :
    lloydPhase data h = ordinaryPhase data (h + solutionShift data) := by
  rw [reflection_path_offset, ordinaryPhase, shifted_path_difference]

-- [derived physics] The phase translation also translates the actual two-beam intensity function.
lemma intensity_translation (data : ScreenData) (a b h : ℝ) :
    intensity a b (lloydPhase data h) =
      intensity a b (ordinaryPhase data (h + solutionShift data)) := by
  rw [phase_translation]

-- [derived physics] Verify the constructed spatial witness; extrema swap remains a separately derived theorem.
lemma shift_valid (data : ScreenData) : IsRelativeShift data (solutionShift data) := by
  exact ⟨div_pos (mul_pos data.wavelength_pos data.distance_pos)
    (mul_pos (by norm_num) data.separation_pos), phase_translation data⟩

-- [pure mathematics / formalization choice] The fixed unwrapped pi branch gives a unique positive phase-translation representative.
lemma relative_shift_unique (data : ScreenData) (other : ℝ) (valid : IsRelativeShift data other) :
    other = solutionShift data := by
  have hc : ordinaryPhase data other = (1 / 2 : ℝ) * (2 * Real.pi) := by
    have h := valid.2 0
    rw [reflection_adds_pi] at h
    have hz : ordinaryPhase data 0 = 0 := by
      simp [ordinaryPhase, paraxial_difference_eq, phase]
    rw [hz] at h
    simpa using h.symm
  have heq := (ordinary_order_location data (1 / 2) other).mp hc
  rw [half_period_shift]
  linarith [heq]

/-- Return the half-bright-period displacement, not a full bright-fringe
period. Center maximum becomes a minimum; all extrema interchange. -/
-- [final judgment] Return wavelength*D/(2l); no theorem from Candidate764 participates.
theorem solution (data : ScreenData) : TrustedPhysicsProblem data := by
  have computed : IsRelativeShift data
      ((data.wavelength.val : ℝ) * data.distance / (2 * data.separation)) := shift_valid data
  exact ⟨solutionShift data, computed, fun other h => relative_shift_unique data other h⟩

end LeanVerificationDemo.PhysicsDemo.P15P16.P766.CandidateAnnotated
