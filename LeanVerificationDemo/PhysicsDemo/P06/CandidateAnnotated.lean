import LeanVerificationDemo.PhysicsDemo.P06.Problem

namespace LeanVerificationDemo.PhysicsDemo.P06.CandidateAnnotated

/-- Combine the supplied short-wave approximation assumptions, then eliminate
all retained path classes. No Maxwell/ionosphere/diffraction limit is proved. -/
theorem solution (data : ReceptionData) (source : SourceData data) :
    TrustedPhysicsProblem data := by
  -- Apply the source regime to each independent propagation premise.
  have noReturn := source.transparent source.shortWave
  have negligible := source.negligible source.shortWave
  have straight := data.model.geometricApproximation negligible
  have noDiffraction := data.model.omitDiffraction negligible
  have visible : data.model.HasPath → data.model.lineOfSight := by
    intro path
    -- The three cases exhaust only the paths retained by this model.
    rcases path with direct | reflected | diffracted
    · exact data.model.directRequiresVisibility straight direct
    · exact (noReturn reflected).elim
    · exact (noDiffraction diffracted).elim
  exact ⟨noReturn, negligible, straight, visible, fun blocked path => blocked (visible path)⟩

end LeanVerificationDemo.PhysicsDemo.P06.CandidateAnnotated
