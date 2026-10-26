import Mathlib.Analysis.InnerProductSpace.Projection.Reflection
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Tactic

/-!
# Ideal specular plane-mirror reflection

A unit normal specifies a genuine mirror hyperplane, rather than an arbitrary
reflecting subspace. Directions reflect in its tangent space using Mathlib's
orthogonal reflection. This is an ideal geometric-optics law, not a derivation
from electromagnetic boundary conditions. The mirror's position is irrelevant
to this direction law and is supplied by applications when constructing rays.
-/
namespace LeanVerificationDemo.PhyslibTemp.Optics

variable (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- Orientation of an ideal specular plane mirror. Either sign of the unit
normal describes the same tangent hyperplane. -/
structure PlaneMirror where
  normal : E
  normal_unit : ‖normal‖ = 1

namespace PlaneMirror
variable {E}

lemma normal_ne_zero (mirror : PlaneMirror E) : mirror.normal ≠ 0 := by
  intro h
  have hu := mirror.normal_unit
  simp [h] at hu

/-- The tangent hyperplane orthogonal to the unit mirror normal. -/
noncomputable def tangent (mirror : PlaneMirror E) : Submodule ℝ E :=
  (ℝ ∙ mirror.normal)ᗮ

noncomputable instance (mirror : PlaneMirror E) : mirror.tangent.HasOrthogonalProjection := by
  unfold tangent
  infer_instance

/-- Ideal specular reflection of a direction in the mirror tangent. -/
noncomputable def reflect (mirror : PlaneMirror E) (incident : E) : E :=
  mirror.tangent.reflection incident

lemma reflect_eq (mirror : PlaneMirror E) (incident : E) :
    mirror.reflect incident =
      incident - (2 * inner ℝ mirror.normal incident) • mirror.normal := by
  unfold reflect tangent
  rw [Submodule.reflection_orthogonal_apply, Submodule.reflection_singleton_apply]
  simp [mirror.normal_unit]
  module

/-- Tangential projection is unchanged by specular reflection. -/
lemma tangent_component (mirror : PlaneMirror E) (incident : E) :
    mirror.tangent.starProjection (mirror.reflect incident) =
      mirror.tangent.starProjection incident := by
  unfold reflect
  rw [Submodule.reflection_apply]
  have hfixed := mirror.tangent.starProjection_eq_self_iff.mpr
    (mirror.tangent.starProjection_apply_mem incident)
  simp [map_sub, two_smul, hfixed]

/-- The signed component along the mirror normal changes sign. -/
lemma normal_component (mirror : PlaneMirror E) (incident : E) :
    inner ℝ mirror.normal (mirror.reflect incident) =
      -inner ℝ mirror.normal incident := by
  rw [reflect_eq, inner_sub_right, inner_smul_right, real_inner_self_eq_norm_sq,
    mirror.normal_unit]
  ring

/-- An ideal stationary mirror preserves the direction-vector magnitude. -/
lemma norm_reflect (mirror : PlaneMirror E) (incident : E) :
    ‖mirror.reflect incident‖ = ‖incident‖ := mirror.tangent.reflection.norm_map incident

lemma reflect_reflect (mirror : PlaneMirror E) (incident : E) :
    mirror.reflect (mirror.reflect incident) = incident :=
  mirror.tangent.reflection_reflection incident

/-- A direction along the mirror remains unchanged, including grazing rays. -/
lemma reflect_tangent (mirror : PlaneMirror E) {incident : E}
    (h : incident ∈ mirror.tangent) : mirror.reflect incident = incident :=
  Submodule.reflection_mem_subspace_eq_self h

/-- A normally incident direction reverses exactly. -/
lemma reflect_normal (mirror : PlaneMirror E) : mirror.reflect mirror.normal = -mirror.normal :=
  Submodule.reflection_orthogonalComplement_singleton_eq_neg mirror.normal

/-- Vector form of equal unsigned incidence/reflection angles to the normal.
For a nonzero direction these ratios are the normal-angle cosines. At zero the
identity still holds algebraically, without assigning a physical ray angle. -/
lemma incidence_reflection_cosine (mirror : PlaneMirror E) (incident : E) :
    |inner ℝ mirror.normal (mirror.reflect incident)| / ‖mirror.reflect incident‖ =
      |inner ℝ mirror.normal incident| / ‖incident‖ := by
  rw [normal_component, norm_reflect, abs_neg]

end PlaneMirror

namespace PlaneMirror2D
abbrev Space := EuclideanSpace ℝ (Fin 2)
def direction (vx vy : ℝ) : Space := WithLp.toLp 2 ![vx, vy]

/-- A horizontal plane mirror in a two-dimensional vertical cross-section. -/
noncomputable def horizontal : PlaneMirror Space where
  normal := direction 0 1
  normal_unit := by
    rw [EuclideanSpace.norm_eq]
    norm_num [direction, Fin.sum_univ_two]

/-- Horizontal-mirror law: preserve the tangent coordinate and reverse the
normal coordinate. No object, screen, shadow or incidence regime is involved. -/
lemma horizontal_reflect (vx vy : ℝ) :
    horizontal.reflect (direction vx vy) = direction vx (-vy) := by
  rw [PlaneMirror.reflect_eq]
  ext i
  fin_cases i <;> simp [horizontal, direction,
    EuclideanSpace.inner_eq_star_dotProduct, dotProduct, Fin.sum_univ_two] <;> ring

end PlaneMirror2D
end LeanVerificationDemo.PhyslibTemp.Optics
