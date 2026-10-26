import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.Tactic

namespace LeanVerificationDemo.PhysicsDemo.P10

/-- Caption-only time coordinates, in seconds. -/
def time : Fin 9 → ℝ := ![0, 1, 2, 3, 5, 6, 7, 9, 10]

/-- Caption-only velocity ordinates, in cm/s; these are not positions. -/
def ordinate : Fin 9 → ℝ := ![0, 1, 1, 3, 4, 4, 3, 2, 2]

/-- Straight interpolation of two consecutive caption vertices. -/
noncomputable def linearSegment (a b u w t : ℝ) : ℝ :=
  u + ((w - u) / (b - a)) * (t - a)

noncomputable def segment (i : Fin 8) (t : ℝ) : ℝ :=
  linearSegment (time i.castSucc) (time i.succ)
    (ordinate i.castSucc) (ordinate i.succ) t

/-- The caption's polyline. Boundary values of adjacent segments agree, as
checked in Candidate. Only [0,10] is physical input; extensions are immaterial. -/
noncomputable def velocity (t : ℝ) : ℝ :=
  if t ≤ 1 then segment 0 t else
  if t ≤ 2 then segment 1 t else
  if t ≤ 3 then segment 2 t else
  if t ≤ 5 then segment 3 t else
  if t ≤ 6 then segment 4 t else
  if t ≤ 7 then segment 5 t else
  if t ≤ 9 then segment 6 t else segment 7 t

/-- Kinematic interpretation of an input velocity graph, in cm. No underlying
position trajectory or Newtonian dynamics is needed for this source problem. -/
noncomputable def displacement (T : ℝ) : ℝ := ∫ t in (0 : ℝ)..T, velocity t

/-- Local path-language interpretation; equality to displacement must be proved
using nonnegativity, not assumed for arbitrary signed velocity graphs. -/
noncomputable def pathTravelled (T : ℝ) : ℝ := ∫ t in (0 : ℝ)..T, |velocity t|

noncomputable def meanVelocity (T : ℝ) : ℝ := displacement T / T
noncomputable def meanAcceleration (T : ℝ) : ℝ := (velocity T - velocity 0) / T

/-- Source problem 23: velocity means in cm/s and acceleration means in cm/s².
These four source-solution values are targets, not graph/model premises. -/
def TrustedPhysicsProblem : Prop :=
  meanVelocity 5 = 21 / 10 ∧ meanAcceleration 5 = 4 / 5 ∧
  meanVelocity 10 = 5 / 2 ∧ meanAcceleration 10 = 1 / 5

end LeanVerificationDemo.PhysicsDemo.P10
