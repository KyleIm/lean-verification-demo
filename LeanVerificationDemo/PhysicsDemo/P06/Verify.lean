import LeanVerificationDemo.PhysicsDemo.P06.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P06.Verifier

example (data : ReceptionData) (source : SourceData data) :
    TrustedPhysicsProblem data := Candidate.solution data source

/-- Both blocked and visible links satisfy the assumptions. A visible link can
retain a direct path; no-path is not baked into the source evidence. -/
def exampleData (visible : Prop) : ReceptionData where
  wavelength := ⟨1⟩
  wavelength_pos := by norm_num
  model := {
    lineOfSight := visible
    directPath := visible
    reflectedReturn := False
    diffractedPath := False
    negligibleDiffraction := True
    straightLine := True
    geometricApproximation := fun _ => True.intro
    omitDiffraction := fun _ => id
    directRequiresVisibility := fun _ => id }

example (visible : Prop) : SourceData (exampleData visible) := by
  exact ⟨by norm_num [exampleData], fun _ h => h, fun _ => True.intro⟩

example : (exampleData True).model.HasPath := Or.inl True.intro
example : ¬ (exampleData False).model.lineOfSight := id

end LeanVerificationDemo.PhysicsDemo.P06.Verifier
