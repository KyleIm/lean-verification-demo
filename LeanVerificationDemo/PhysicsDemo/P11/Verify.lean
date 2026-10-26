import LeanVerificationDemo.PhysicsDemo.P11.Units

namespace LeanVerificationDemo.PhysicsDemo.P11.Verifier

example (g : Geometry) : TrustedPhysicsProblem g := Candidate.solution g

/-- Numerical test geometries, not source-figure data. Both regimes exist. -/
noncomputable def testGeometry (h l : ℝ) (hh : 0 < h) (hl : 0 < l) : Geometry where
  h := h
  h_pos := hh
  l := l
  l_pos := hl
  α := Real.pi / 4
  angle_pos := by linarith [Real.pi_pos]
  angle_lt := by linarith [Real.pi_pos]

lemma test_base (h l : ℝ) (hh : 0 < h) (hl : 0 < l) :
    baseHeight (testGeometry h l hh hl) = l := by
  simp [testGeometry, baseHeight, slope, Real.tan_pi_div_four]

noncomputable def farExample : Geometry := testGeometry 1 2 (by norm_num) (by norm_num)
noncomputable def nearExample : Geometry := testGeometry 2 1 (by norm_num) (by norm_num)
noncomputable def criticalExample : Geometry := testGeometry 1 1 (by norm_num) (by norm_num)

lemma far_example : FarScreen farExample := by
  norm_num [FarScreen, farExample, testGeometry, Real.tan_pi_div_four]
lemma near_example : NearScreen nearExample := by
  norm_num [NearScreen, nearExample, testGeometry, Real.tan_pi_div_four]

example : verticalLength (shadow farExample) = 2 := by
  have h := (Candidate.far_screen_shadow_structure farExample far_example).total_length
  norm_num [farExample, testGeometry] at h
  exact h

example : verticalLength (shadow nearExample) = 3 := by
  have h := (Candidate.near_screen_shadow_structure nearExample near_example).total_length
  norm_num [nearExample, baseHeight, slope, testGeometry, Real.tan_pi_div_four] at h
  exact h

example : fullyDark nearExample = Set.Icc (0 : ℝ) 1 := by
  have h := Candidate.fully_dark_interval nearExample
  norm_num [nearExample, baseHeight, slope, testGeometry, Real.tan_pi_div_four] at h
  exact h

-- Strict far screens have no direct-sunlight shadow at positive screen heights.
example : directIlluminated farExample 2 := by
  constructor
  · norm_num
  · rw [Candidate.direct_blocked_iff]
    norm_num [farExample, baseHeight, slope, testGeometry, Real.tan_pi_div_four]

-- Yet reflected light is blocked at that same screen height.
example : ¬ reflectedIlluminated farExample 2 := by
  intro h
  apply h.2
  rw [Candidate.reflected_shadow_interval]
  norm_num [farExample, baseHeight, slope, testGeometry, Real.tan_pi_div_four]

-- Inclusive geometric contact blocks a single base point at the threshold;
-- its length is zero. No positive-length far-screen dark interval is claimed.
example : fullyDark criticalExample = {(0 : ℝ)} := by
  rw [Candidate.fully_dark_interval]
  norm_num [criticalExample, baseHeight, slope, testGeometry, Real.tan_pi_div_four]

example (g : Geometry) : FarScreen g ∨ NearScreen g := le_or_gt _ _
example (g : Geometry) :
    FarScreen g ↔ Units.thresholdLength (⟨g.h⟩ : Units.Length) g.α ≤ (⟨g.l⟩ : Units.Length) :=
  Units.typed_far_regime g

end LeanVerificationDemo.PhysicsDemo.P11.Verifier
