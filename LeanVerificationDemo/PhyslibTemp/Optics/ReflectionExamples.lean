import LeanVerificationDemo.PhyslibTemp.Optics.Reflection

namespace LeanVerificationDemo.PhyslibTemp.Optics.ReflectionExamples
open PlaneMirror2D

-- Independent of P11: any downward direction reflects upward and preserves vx.
example (vx vy : ℝ) (downward : vy < 0) :
    (horizontal.reflect (direction vx vy)) 0 = vx ∧
    0 < (horizontal.reflect (direction vx vy)) 1 := by
  rw [horizontal_reflect]
  exact ⟨rfl, neg_pos.mpr downward⟩

example : horizontal.reflect (direction 3 (-4)) = direction 3 4 := by
  simpa using horizontal_reflect 3 (-4)

-- Grazing and zero directions are algebraically well behaved.
example (vx : ℝ) : horizontal.reflect (direction vx 0) = direction vx 0 := by
  simpa using horizontal_reflect vx 0
example : horizontal.reflect (0 : Space) = 0 := by
  exact horizontal.tangent.reflection.map_zero

-- A different mirror orientation, not a special-purpose horizontal-only model.
noncomputable def vertical : PlaneMirror Space where
  normal := direction 1 0
  normal_unit := by
    rw [EuclideanSpace.norm_eq]
    norm_num [direction, Fin.sum_univ_two]

example (vx vy : ℝ) : vertical.reflect (direction vx vy) = direction (-vx) vy := by
  rw [PlaneMirror.reflect_eq]
  ext i
  fin_cases i <;> simp [vertical, direction,
    EuclideanSpace.inner_eq_star_dotProduct, dotProduct, Fin.sum_univ_two] <;> ring

-- Arbitrary-dimensional interface; no object, screen or shadow assumptions.
example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (mirror : PlaneMirror E) (v : E) :
    ‖mirror.reflect v‖ = ‖v‖ ∧ mirror.reflect (mirror.reflect v) = v :=
  ⟨mirror.norm_reflect v, mirror.reflect_reflect v⟩

example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (mirror : PlaneMirror E) (v : E) :
    mirror.tangent.starProjection (mirror.reflect v) = mirror.tangent.starProjection v ∧
    inner ℝ mirror.normal (mirror.reflect v) = -inner ℝ mirror.normal v :=
  ⟨mirror.tangent_component v, mirror.normal_component v⟩

#print axioms PlaneMirror.incidence_reflection_cosine
end LeanVerificationDemo.PhyslibTemp.Optics.ReflectionExamples
