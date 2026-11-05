import LeanVerificationDemo.PhyslibTemp.Optics.TwoBeamInterference

namespace LeanVerificationDemo.PhysicsDemo.P15P16
open LeanVerificationDemo.PhyslibTemp.Optics

/-- Positive coordinates in one coherent length unit. Wavelength is the
existing Physlib quantity. D >> l and near-axis observation select the
paraxial model below, not a fabricated exact finite-distance inequality. -/
structure ScreenData where
  separation : ℝ
  distance : ℝ
  wavelength : Wavelength
  separation_pos : 0 < separation
  distance_pos : 0 < distance
  wavelength_pos : 0 < (wavelength.val : ℝ)

/-- Source coordinates (-D,l/2), (-D,-l/2); screen coordinate (0,h).
The center is the midpoint of the perpendicular source/screen geometry. -/
noncomputable def upperPath (data : ScreenData) (h : ℝ) : ℝ :=
  Real.sqrt (data.distance ^ 2 + (h - data.separation / 2) ^ 2)
noncomputable def lowerPath (data : ScreenData) (h : ℝ) : ℝ :=
  Real.sqrt (data.distance ^ 2 + (h + data.separation / 2) ^ 2)
noncomputable def exactDifference (data : ScreenData) (h : ℝ) : ℝ :=
  lowerPath data h - upperPath data h

/-- Explicit far-screen closure: in the difference-of-squares identity,
replace the sum-of-ranges denominator by 2D. This defines an approximation
model; it does not assert that the actual sum equals 2D. -/
noncomputable def paraxialDifference (data : ScreenData) (h : ℝ) : ℝ :=
  (lowerPath data h ^ 2 - upperPath data h ^ 2) / (2 * data.distance)

/-- Equal initial phase is the reference adopted by the supplied solution.
Coherence alone would only imply a fixed, possibly nonzero phase offset. -/
noncomputable def ordinaryPhase (data : ScreenData) (h : ℝ) : ℝ :=
  TwoBeamInterference.phase data.wavelength (paraxialDifference data h) 0

end LeanVerificationDemo.PhysicsDemo.P15P16
