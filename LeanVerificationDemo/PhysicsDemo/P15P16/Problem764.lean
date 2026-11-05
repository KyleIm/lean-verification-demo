import LeanVerificationDemo.PhysicsDemo.P15P16.Geometry

namespace LeanVerificationDemo.PhysicsDemo.P15P16.P764
open LeanVerificationDemo.PhyslibTemp.Optics.TwoBeamInterference

/-- Find a positive spacing whose consecutive integer orders are exactly
the constructive orders, and whose lattice contains all bright fringes.
No computed spacing is supplied by this success criterion. -/
def IsFringeSpacing (data : ScreenData) (spacing : ℝ) : Prop :=
  0 < spacing ∧
  (∀ (n : ℤ) (h : ℝ), ordinaryPhase data h = (n : ℝ) * (2 * Real.pi) ↔
    h = (n : ℝ) * spacing) ∧
  (∀ h, IsMaximum (ordinaryPhase data h) ↔ ∃ n : ℤ, h = (n : ℝ) * spacing)

def TrustedPhysicsProblem (data : ScreenData) : Prop :=
  ∃! spacing : ℝ, IsFringeSpacing data spacing

end LeanVerificationDemo.PhysicsDemo.P15P16.P764
