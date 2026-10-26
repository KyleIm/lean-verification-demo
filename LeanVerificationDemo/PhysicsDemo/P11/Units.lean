import LeanVerificationDemo.PhysicsDemo.P11.Candidate
import Physlib.Units.WithDim.Basic

namespace LeanVerificationDemo.PhysicsDemo.P11.Units
open Dimension

abbrev Length := WithDim L𝓭 ℝ
abbrev Dimensionless := WithDim (1 : Dimension LTMCTDimensionBase) ℝ

/-- tan of the incidence angle is a dimensionless real ratio. -/
noncomputable def thresholdLength (height : Length) (α : ℝ) : Length :=
  (height * (⟨Real.tan α⟩ : Dimensionless)).cast (mul_one L𝓭)

lemma threshold_dimension : L𝓭 * (1 : Dimension LTMCTDimensionBase) = L𝓭 := mul_one _

/-- l and h tan α are lengths in one common coordinate-unit choice.
This dimension check does not assert that the far-screen inequality holds. -/
lemma typed_far_regime (g : Geometry) :
    FarScreen g ↔ thresholdLength (⟨g.h⟩ : Length) g.α ≤ (⟨g.l⟩ : Length) := by
  rfl

end LeanVerificationDemo.PhysicsDemo.P11.Units
