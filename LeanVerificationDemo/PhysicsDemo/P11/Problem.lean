import LeanVerificationDemo.PhyslibTemp.Optics.Reflection
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.MeasureTheory.Measure.Lebesgue.Basic
import Mathlib.Tactic

namespace LeanVerificationDemo.PhysicsDemo.P11
open MeasureTheory

abbrev Plane := EuclideanSpace ℝ (Fin 2)
def point (x y : ℝ) : Plane := WithLp.toLp 2 ![x, y]

/-- Quantitative model parameters, NOT symbols supplied by problem 677's text
or Fig. 237. α is measured from the vertical normal to the horizontal mirror. -/
structure Geometry where
  h : ℝ
  h_pos : 0 < h
  l : ℝ
  l_pos : 0 < l
  α : ℝ
  angle_pos : 0 < α
  angle_lt : α < Real.pi / 2

/-- Vertical rise per horizontal distance: cot α for incidence from the normal. -/
noncomputable def slope (g : Geometry) : ℝ := 1 / Real.tan g.α
noncomputable def baseHeight (g : Geometry) : ℝ := g.l * slope g

/-- P11's horizontal mirror specializes the reusable ideal-specular law. -/
noncomputable def mirror : PhyslibTemp.Optics.PlaneMirror Plane :=
  PhyslibTemp.Optics.PlaneMirror2D.horizontal
noncomputable def mirrorDirection : Submodule ℝ Plane := mirror.tangent
noncomputable def incomingDirection (g : Geometry) : Plane := point 1 (-slope g)
/-- The reusable plane-mirror law supplies the reflected direction.
P11 supplies the placement y=0; the generic law has no screen/shadow geometry. -/
noncomputable def reflectedDirection (g : Geometry) : Plane :=
  mirror.reflect (incomingDirection g)

noncomputable def incidentRay (g : Geometry) (r t : ℝ) : Plane :=
  point r 0 + t • incomingDirection g
noncomputable def reflectedRay (g : Geometry) (r t : ℝ) : Plane :=
  point r 0 + t • reflectedDirection g
noncomputable def directRay (g : Geometry) (z t : ℝ) : Plane :=
  point g.l z + t • incomingDirection g

/-- r is the mirror coordinate. t≥0 selects the actual reflected half-ray. -/
def ScreenHit (g : Geometry) (r z : ℝ) : Prop :=
  ∃ t ≥ 0, reflectedRay g r t = point g.l z
def IncidentBlocked (g : Geometry) (r : ℝ) : Prop :=
  ∃ u ∈ Set.Icc (0 : ℝ) g.h, ∃ t ≤ 0, incidentRay g r t = point 0 u
def OutgoingBlocked (g : Geometry) (r : ℝ) : Prop :=
  ∃ u ∈ Set.Icc (0 : ℝ) g.h, ∃ t, 0 ≤ t ∧ t ≤ g.l - r ∧
    reflectedRay g r t = point 0 u

def directBlocked (g : Geometry) : Set ℝ :=
  {z | 0 ≤ z ∧ ∃ u ∈ Set.Icc (0 : ℝ) g.h, ∃ t ≤ 0, directRay g z t = point 0 u}
def uprightShadow (g : Geometry) : Set ℝ :=
  {z | 0 ≤ z ∧ ∃ r, ScreenHit g r z ∧ OutgoingBlocked g r}
def invertedShadow (g : Geometry) : Set ℝ :=
  {z | 0 ≤ z ∧ ∃ r, ScreenHit g r z ∧ IncidentBlocked g r}
def reflectedBlocked (g : Geometry) : Set ℝ := uprightShadow g ∪ invertedShadow g
def directIlluminated (g : Geometry) (z : ℝ) : Prop := 0 ≤ z ∧ z ∉ directBlocked g
def reflectedIlluminated (g : Geometry) (z : ℝ) : Prop := 0 ≤ z ∧ z ∉ reflectedBlocked g
/-- Source shadow means loss of at least one channel relative to the doubly
illuminated screen. Fully dark means loss of both; these are different sets. -/
def shadow (g : Geometry) : Set ℝ := directBlocked g ∪ reflectedBlocked g
def fullyDark (g : Geometry) : Set ℝ := directBlocked g ∩ reflectedBlocked g
noncomputable def verticalLength (s : Set ℝ) : ℝ := (volume s).toReal

/-- Solution-introduced regimes; neither inequality is source evidence. -/
noncomputable def FarScreen (g : Geometry) : Prop := g.h * Real.tan g.α ≤ g.l
noncomputable def NearScreen (g : Geometry) : Prop := g.l < g.h * Real.tan g.α

structure FarConclusion (g : Geometry) : Prop where
  upright : uprightShadow g = Set.Icc (baseHeight g) (baseHeight g + g.h)
  inverted : invertedShadow g = Set.Icc (baseHeight g - g.h) (baseHeight g)
  meeting_bases : uprightShadow g ∩ invertedShadow g = {baseHeight g}
  upright_length : verticalLength (uprightShadow g) = g.h
  inverted_length : verticalLength (invertedShadow g) = g.h
  total_interval : shadow g = Set.Icc (baseHeight g - g.h) (baseHeight g + g.h)
  total_length : verticalLength (shadow g) = 2 * g.h

structure NearConclusion (g : Geometry) : Prop where
  total_interval : shadow g = Set.Icc 0 (baseHeight g + g.h)
  total_length : verticalLength (shadow g) = baseHeight g + g.h
  shorter : verticalLength (shadow g) < 2 * g.h
  dark_interval : fullyDark g = Set.Icc 0 (g.h - baseHeight g)
  positive_dark_length : 0 < verticalLength (fullyDark g)

def TrustedPhysicsProblem (g : Geometry) : Prop :=
  (FarScreen g → FarConclusion g) ∧ (NearScreen g → NearConclusion g)

end LeanVerificationDemo.PhysicsDemo.P11
