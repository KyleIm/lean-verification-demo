import Physlib.Optics.Wavelength

namespace LeanVerificationDemo.PhyslibTemp.Optics

/-- A qualitative model for one transmitter–receiver link. These propositions
refer to retained paths, not to exact electromagnetic amplitudes. `lineOfSight`
means an unobstructed direct segment, supplied by the application; this API does
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

end LeanVerificationDemo.PhyslibTemp.Optics
