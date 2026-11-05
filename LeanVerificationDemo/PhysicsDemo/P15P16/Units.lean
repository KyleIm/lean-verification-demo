import LeanVerificationDemo.PhysicsDemo.P15P16.Candidate764
import LeanVerificationDemo.PhysicsDemo.P15P16.Candidate766

namespace LeanVerificationDemo.PhysicsDemo.P15P16.Units
open Dimension
open LeanVerificationDemo.PhyslibTemp.Optics

abbrev Length := WithDim L𝓭 ℝ
abbrev Dimensionless := WithDim (1 : Dimension LTMCTDimensionBase) ℝ

lemma spacing_dimension : L𝓭 * L𝓭 / L𝓭 = (L𝓭 : Dimension LTMCTDimensionBase) := by decide
lemma path_ratio_dimension : L𝓭 / L𝓭 = (1 : Dimension LTMCTDimensionBase) := by decide

noncomputable def wavelengthQuantity (data : ScreenData) : Length :=
  ⟨(data.wavelength.val : ℝ)⟩

noncomputable def spacingQuantity (wavelength distance separation : Length) : Length :=
  ((wavelength * distance) / separation).cast spacing_dimension

noncomputable def shiftQuantity (wavelength distance separation : Length) : Length :=
  ((wavelength * distance) / ((2 : ℝ) • separation)).cast spacing_dimension

noncomputable def pathDifferenceQuantity (lower upper distance : Length) : Length :=
  ((lower * lower - upper * upper) / ((2 : ℝ) • distance)).cast spacing_dimension

noncomputable def phaseQuantity (wavelength pathDifference : Length)
    (offset : Dimensionless) : Dimensionless :=
  (2 * Real.pi) • (pathDifference / wavelength).cast path_ratio_dimension + offset

lemma typed_spacing (data : ScreenData) :
    spacingQuantity (wavelengthQuantity data) ⟨data.distance⟩ ⟨data.separation⟩ =
      (⟨P764.Candidate.solutionSpacing data⟩ : Length) := rfl

lemma typed_shift (data : ScreenData) :
    shiftQuantity (wavelengthQuantity data) ⟨data.distance⟩ ⟨data.separation⟩ =
      (⟨P766.Candidate.solutionShift data⟩ : Length) := rfl

lemma typed_path_difference (data : ScreenData) (h : ℝ) :
    pathDifferenceQuantity ⟨lowerPath data h⟩ ⟨upperPath data h⟩ ⟨data.distance⟩ =
      (⟨paraxialDifference data h⟩ : Length) := by
  apply WithDim.ext
  change (lowerPath data h * lowerPath data h - upperPath data h * upperPath data h) /
    (2 * data.distance) = paraxialDifference data h
  simp only [paraxialDifference, pow_two]

lemma typed_phase (data : ScreenData) (δ offset : ℝ) :
    phaseQuantity (wavelengthQuantity data) ⟨δ⟩ ⟨offset⟩ =
      (⟨TwoBeamInterference.phase data.wavelength δ offset⟩ : Dimensionless) := rfl

example : (⟨Real.pi⟩ : Dimensionless).val = Real.pi := rfl

end LeanVerificationDemo.PhysicsDemo.P15P16.Units
