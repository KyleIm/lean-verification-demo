import LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.VibratingString
import Mathlib.Analysis.Real.Pi.Bounds

namespace LeanVerificationDemo.PhysicsDemo.P13
open LeanVerificationDemo.PhyslibTemp.ClassicalMechanics

/-- Source-native coordinates: cm, mm, dyn, g/cm³. These form a local
parameter bundle, not a material/steel ontology. -/
structure StringData where
  lengthCm : ℝ
  length_pos : 0 < lengthCm
  diameterMm : ℝ
  diameter_pos : 0 < diameterMm
  tensionDyn : ℝ
  tension_pos : 0 < tensionDyn
  densityGcm3 : ℝ
  density_pos : 0 < densityGcm3

/-- Explicit millimetre-to-centimetre conversion before coherent CGS arithmetic. -/
noncomputable def diameterCm (data : StringData) : ℝ := data.diameterMm / 10
noncomputable def radiusCm (data : StringData) : ℝ := diameterCm data / 2
/-- Elementary circular cross-sectional area, not a final frequency premise. -/
noncomputable def areaCm2 (data : StringData) : ℝ := Real.pi * radiusCm data ^ 2
noncomputable def linearDensity (data : StringData) : ℝ := data.densityGcm3 * areaCm2 data

lemma diameterCm_pos (data : StringData) : 0 < diameterCm data :=
  div_pos data.diameter_pos (by norm_num)
lemma areaCm2_pos (data : StringData) : 0 < areaCm2 data :=
  mul_pos Real.pi_pos (sq_pos_of_pos (div_pos (diameterCm_pos data) (by norm_num)))
lemma linearDensity_pos (data : StringData) : 0 < linearDensity data :=
  mul_pos data.density_pos (areaCm2_pos data)

/-- P13 uses the reusable ideal uniform string, with both ends fixed. Its
coherent CGS coordinates give cm/s for wave speed and s⁻¹ for frequency. -/
noncomputable def fixedString (data : StringData) : FixedString where
  length := data.lengthCm
  length_pos := data.length_pos
  tension := data.tensionDyn
  tension_pos := data.tension_pos
  linearDensity := linearDensity data
  linearDensity_pos := linearDensity_pos data

noncomputable def naturalFrequency (data : StringData) (n : ℕ+) : ℝ :=
  (fixedString data).frequency n
noncomputable def fundamental (data : StringData) : ℝ := (fixedString data).fundamental

/-- Only original numerical inputs: no frequency or combined source formula. -/
structure SourceData (data : StringData) : Prop where
  length_value : data.lengthCm = 50
  diameter_value : data.diameterMm = 1
  tension_value : data.tensionDyn = 2450
  density_value : data.densityGcm3 = 39 / 5

/-- A precise interpretation of the source's integer-Hz numerical answer:
nearest integer, with half-integer ties toward +∞. -/
def RoundsToWholeHz (x : ℝ) (k : ℤ) : Prop := (k : ℝ) - 1 / 2 ≤ x ∧ x < k + 1 / 2

def ExactSpectrum (data : StringData) : Prop :=
  ∀ n : ℕ+, naturalFrequency data n = (n : ℝ) / (data.lengthCm * diameterCm data) *
    Real.sqrt (data.tensionDyn / (Real.pi * data.densityGcm3))

def HarmonicSpectrum (data : StringData) : Prop :=
  ∀ n : ℕ+, naturalFrequency data n = (n : ℝ) * fundamental data

/-- The combined formula and harmonics must be derived. The printed 2 Hz is
checked as rounding, and a strict inequality records that it is not exact. -/
def TrustedPhysicsProblem (data : StringData) : Prop :=
  ExactSpectrum data ∧ HarmonicSpectrum data ∧
    RoundsToWholeHz (fundamental data) 2 ∧ fundamental data < 2

end LeanVerificationDemo.PhysicsDemo.P13
