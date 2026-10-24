import Physlib.Units.WithDim.Basic
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.Tactic

namespace LeanVerificationDemo.PhysicsDemo.P07
open Dimension

/-- Length coordinates in the source's fixed, unspecified length convention. -/
abbrev Length := WithDim L𝓭 ℝ
/-- Resistivity coordinates (resistance times length), not asserted to be SI. -/
abbrev Resistivity := WithDim (M𝓭 * L𝓭 ^ 3 / (T𝓭 * C𝓭 ^ 2)) ℝ
/-- Current coordinates in the source convention. -/
abbrev Current := WithDim (C𝓭 / T𝓭) ℝ

/-- P07 parameter bundle, not an ontology-level ring. Figure geometry gives
`a,b,h`; resistivity and field rate come from the text. H is a historical scalar,
not identified with SI magnetic flux density B or magnetic field strength H. -/
structure RingData where
  a : Length
  b : Length
  h : Length
  ρ : Resistivity
  k : ℝ
  a_pos : 0 < a.val
  a_lt_b : a.val < b.val
  h_pos : 0 < h.val
  ρ_pos : 0 < ρ.val
  k_pos : 0 < k

/-- Exact retained source-unit coefficient. Its conversion to SI is not proved. -/
noncomputable def sourceFactor : ℝ := 1 / 100000000

/-- Homogeneous axial source-field coordinate, H(t) = kt. -/
noncomputable def field (data : RingData) (t : ℝ) : ℝ := data.k * t

/-- Flux proxy π x² H, in source coordinates. This is not a claim H = SI B. -/
noncomputable def flux (data : RingData) (x t : ℝ) : ℝ :=
  Real.pi * x ^ 2 * field data t

/-- Thin-ring resistance coefficient: for width δ, the leading-order resistance
is this coefficient / δ, from ρ (2πx)/(δ h). This is a continuum premise. -/
noncomputable def resistanceCoefficient (data : RingData) (x : ℝ) : ℝ :=
  data.ρ.val * (2 * Real.pi * x) / data.h.val

/-- Independent local physical relations. The scalar current-per-width profile is
dI/dx: the contribution to total azimuthal current per unit radial width. It is
neither Physlib's vector current density J nor a current flowing radially.
Positive orientation denotes the magnitude opposing the increasing source flux.
Self-inductance, transients and the induced field's feedback are neglected. -/
structure Response (data : RingData) where
  emf : ℝ → ℝ → ℝ
  currentPerWidth : ℝ → ℝ → ℝ
  /-- Adopted integral Faraday magnitude law in the historical unit convention. -/
  faraday : ∀ x ∈ Set.Icc data.a.val data.b.val, ∀ t,
    emf x t = sourceFactor * deriv (flux data x) t
  /-- Ohm relation after dividing the infinitesimal strip current by its width. -/
  ohm : ∀ x ∈ Set.Icc data.a.val data.b.val, ∀ t,
    currentPerWidth x t * resistanceCoefficient data x = emf x t

/-- The continuum sum of concentric-loop currents, not currents in a single
series path. This adopts the source's independent-loop approximation. -/
noncomputable def totalCurrent (data : RingData) (response : Response data) (t : ℝ) :
    Current := ⟨∫ x in data.a.val..data.b.val, response.currentPerWidth x t⟩

/-- Source problem 574, for every time coordinate in the prescribed-field model.
The final current formula is a target, not an evidence field. -/
def TrustedPhysicsProblem (data : RingData) (response : Response data) : Prop :=
  ∀ t, (totalCurrent data response t).val =
    sourceFactor * (data.k * data.h.val / (4 * data.ρ.val)) *
      (data.b.val ^ 2 - data.a.val ^ 2)

end LeanVerificationDemo.PhysicsDemo.P07
