import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic

/-!
# Vendored temporary geometrical-optics refraction semantics

This is the minimal PhyslibTemp optics surface used by this demo. It is vendored
locally so the repository builds without a sibling Math2Physics checkout.
-/

namespace Math2Physics
namespace PhyslibTemp
namespace Optics

/-- A refractive index, represented as a positive real scalar. -/
structure RefractiveIndex where
  /-- The numerical value of the refractive index. -/
  val : ℝ
  /-- Physical refractive indices are positive. -/
  positive : 0 < val

namespace RefractiveIndex

instance : Coe RefractiveIndex ℝ where
  coe n := n.val

@[simp]
lemma coe_mk (n : ℝ) (hn : 0 < n) : ((⟨n, hn⟩ : RefractiveIndex) : ℝ) = n := rfl

@[simp]
lemma coe_pos (n : RefractiveIndex) : 0 < (n : ℝ) := n.positive

@[simp]
lemma coe_ne_zero (n : RefractiveIndex) : (n : ℝ) ≠ 0 := ne_of_gt n.positive

end RefractiveIndex

/-- An angle measured from the normal to a planar interface or slab face. -/
abbrev NormalAngle := ℝ

/-- An incident angle, measured from the interface normal on the incident side. -/
abbrev IncidentAngle := NormalAngle

/-- A transmitted, or refracted, angle measured from the interface normal on the transmitted side. -/
abbrev TransmittedAngle := NormalAngle

/-- The physical range of elementary normal-measured optical angles. -/
def IsPhysicalNormalAngle (θ : NormalAngle) : Prop :=
  θ ∈ Set.Icc 0 (Real.pi / 2)

namespace IsPhysicalNormalAngle

/-- A physical unsigned normal angle also lies in Mathlib's sine-injectivity interval. -/
lemma mem_sin_inj_interval {θ : NormalAngle} (hθ : IsPhysicalNormalAngle θ) :
    θ ∈ Set.Icc (-(Real.pi / 2)) (Real.pi / 2) := by
  constructor
  · linarith [hθ.1, Real.pi_pos]
  · exact hθ.2

end IsPhysicalNormalAngle

/-- The scalar expression `n * sin θ` appearing in Snell's law. -/
noncomputable def snellExpression (n : RefractiveIndex) (θ : NormalAngle) : ℝ :=
  (n : ℝ) * Real.sin θ

/-- Snell's law at a planar interface. -/
def SnellLaw
    (nIncident nTransmitted : RefractiveIndex)
    (θIncident : IncidentAngle) (θTransmitted : TransmittedAngle) : Prop :=
  snellExpression nIncident θIncident = snellExpression nTransmitted θTransmitted

/-- A valid single-interface refraction configuration. -/
structure RefractionAtInterface where
  /-- Refractive index on the incident side of the interface. -/
  incidentIndex : RefractiveIndex
  /-- Refractive index on the transmitted side of the interface. -/
  transmittedIndex : RefractiveIndex
  /-- Incident angle, measured from the interface normal. -/
  incidentAngle : IncidentAngle
  /-- Transmitted/refracted angle, measured from the interface normal. -/
  transmittedAngle : TransmittedAngle
  /-- Incident angle is an unsigned physical normal angle. -/
  incidentAngle_physical : IsPhysicalNormalAngle incidentAngle
  /-- Transmitted angle is an unsigned physical normal angle. -/
  transmittedAngle_physical : IsPhysicalNormalAngle transmittedAngle
  /-- The concrete configuration satisfies Snell's law. -/
  snell_law : SnellLaw incidentIndex transmittedIndex incidentAngle transmittedAngle

namespace RefractionAtInterface

/-- If a Snell-law interface has the same refractive index on both sides, then its transmitted
angle equals its incident angle. -/
theorem transmittedAngle_eq_incidentAngle_of_same_index
    (cfg : RefractionAtInterface)
    (hsame : cfg.incidentIndex = cfg.transmittedIndex) :
    cfg.transmittedAngle = cfg.incidentAngle := by
  have hsin : Real.sin cfg.incidentAngle = Real.sin cfg.transmittedAngle := by
    have h := cfg.snell_law
    rw [hsame] at h
    exact mul_left_cancel₀ cfg.transmittedIndex.coe_ne_zero
      (by simpa [SnellLaw, snellExpression] using h)
  exact (Real.injOn_sin
    cfg.incidentAngle_physical.mem_sin_inj_interval
    cfg.transmittedAngle_physical.mem_sin_inj_interval hsin).symm

end RefractionAtInterface

end Optics
end PhyslibTemp
end Math2Physics
