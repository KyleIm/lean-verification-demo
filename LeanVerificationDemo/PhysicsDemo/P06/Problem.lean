import Physlib.Optics.Wavelength

namespace LeanVerificationDemo.PhysicsDemo.P06

/-- P06-local qualitative model for one transmitter–receiver link. These propositions
refer to retained paths, not to exact electromagnetic amplitudes. `lineOfSight`
means an unobstructed direct segment, supplied by the application; this model does
not compute visibility from geometry. Other mechanisms are outside this model. -/
structure PropagationModel where
  lineOfSight : Prop
  directPath : Prop
  reflectedReturn : Prop
  diffractedPath : Prop
  negligibleDiffraction : Prop
  straightLine : Prop
  /-- Adopt geometric propagation when diffraction is neglected. A modeling
  assumption, not a theorem that small diffraction is physically zero. -/
  geometricApproximation : negligibleDiffraction → straightLine
  /-- Negligible diffracted paths are omitted from the retained path model. -/
  omitDiffraction : negligibleDiffraction → ¬ diffractedPath
  /-- A retained direct geometric path requires an unobstructed segment. -/
  directRequiresVisibility : straightLine → directPath → lineOfSight

/-- Exhaustive only by definition of this restricted model: direct, reflected
return, or diffracted path. No assertion about all real propagation mechanisms. -/
def PropagationModel.HasPath (m : PropagationModel) : Prop :=
  m.directPath ∨ m.reflectedReturn ∨ m.diffractedPath

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
