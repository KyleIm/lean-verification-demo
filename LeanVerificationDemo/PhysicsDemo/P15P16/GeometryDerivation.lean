import LeanVerificationDemo.PhysicsDemo.P15P16.Geometry

namespace LeanVerificationDemo.PhysicsDemo.P15P16.GeometryDerivation

lemma upper_path_squared (data : ScreenData) (h : ℝ) :
    upperPath data h ^ 2 = data.distance ^ 2 + (h - data.separation / 2) ^ 2 :=
  Real.sq_sqrt (by positivity)

lemma lower_path_squared (data : ScreenData) (h : ℝ) :
    lowerPath data h ^ 2 = data.distance ^ 2 + (h + data.separation / 2) ^ 2 :=
  Real.sq_sqrt (by positivity)

lemma squared_path_difference (data : ScreenData) (h : ℝ) :
    lowerPath data h ^ 2 - upperPath data h ^ 2 = 2 * h * data.separation := by
  rw [lower_path_squared, upper_path_squared]
  ring

lemma factored_path_difference (data : ScreenData) (h : ℝ) :
    (lowerPath data h + upperPath data h) * exactDifference data h =
      2 * h * data.separation := by
  unfold exactDifference
  nlinarith [squared_path_difference data h]

lemma paraxial_difference_eq (data : ScreenData) (h : ℝ) :
    paraxialDifference data h = data.separation * h / data.distance := by
  rw [paraxialDifference, squared_path_difference]
  field_simp [data.distance_pos.ne']
  <;> ring

/-- Even at the center, the finite Euclidean sum is strictly greater than
2D. The far-field denominator replacement is not an exact geometry theorem. -/
lemma center_sum_strict (data : ScreenData) :
    2 * data.distance < lowerPath data 0 + upperPath data 0 := by
  have hs := Real.sq_sqrt (show 0 ≤ data.distance ^ 2 + (data.separation / 2) ^ 2 by positivity)
  have hn := Real.sqrt_nonneg (data.distance ^ 2 + (data.separation / 2) ^ 2)
  have hp : 0 < data.separation / 2 := by linarith [data.separation_pos]
  have hd := data.distance_pos
  have hlt : data.distance < Real.sqrt (data.distance ^ 2 + (data.separation / 2) ^ 2) := by
    nlinarith
  simp only [lowerPath, upperPath, zero_add, zero_sub, neg_sq]
  linarith

end LeanVerificationDemo.PhysicsDemo.P15P16.GeometryDerivation
