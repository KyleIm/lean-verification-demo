import LeanVerificationDemo.PhyslibTemp.Optics.PropagationApproximation

namespace LeanVerificationDemo.PhysicsDemo.P06
open LeanVerificationDemo.PhyslibTemp.Optics

/-- One emitted wavelength and one transmitter–receiver link. Wavelength.val
is evaluated in the fixed metre unit convention throughout P06. -/
structure ReceptionData where
  wavelength : Wavelength
  wavelength_pos : 0 < wavelength.val
  model : PropagationModel

/-- Source-specific regime assumptions. “Transparent” means no retained
ionospheric reflected return, not an exact material-transmission theorem.
The reflected channel of this P06 link refers specifically to the ionosphere. -/
structure SourceData (data : ReceptionData) : Prop where
  shortWave : data.wavelength.val < 10
  transparent : data.wavelength.val < 10 → ¬ data.model.reflectedReturn
  negligible : data.wavelength.val < 10 → data.model.negligibleDiffraction

/-- Corrected source claim, conditional on the restricted propagation
approximation: reception paths require visibility, and blockage eliminates
retained paths. This does not prohibit real beyond-line-of-sight reception. -/
def TrustedPhysicsProblem (data : ReceptionData) : Prop :=
  (¬ data.model.reflectedReturn) ∧
  data.model.negligibleDiffraction ∧
  data.model.straightLine ∧
  (data.model.HasPath → data.model.lineOfSight) ∧
  (¬ data.model.lineOfSight → ¬ data.model.HasPath)

end LeanVerificationDemo.PhysicsDemo.P06
