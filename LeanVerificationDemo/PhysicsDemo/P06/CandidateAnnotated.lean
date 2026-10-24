import LeanVerificationDemo.PhysicsDemo.P06.Problem

namespace LeanVerificationDemo.PhysicsDemo.P06.CandidateAnnotated

/-- Combine the supplied short-wave approximation assumptions, then eliminate
all retained path classes. No Maxwell/ionosphere/diffraction limit is proved. -/
theorem solution (data : ReceptionData) (source : SourceData data) :
    TrustedPhysicsProblem data := by
  -- Apply the source regime to each independent propagation premise.
  have noReturn : ¬ data.model.reflectedReturn := source.transparent source.shortWave
  have negligible : data.model.negligibleDiffraction := source.negligible source.shortWave
  -- Straight propagation and omitted diffraction follow from adopted rules,
  -- not a formal Maxwell/diffraction derivation. Case elimination is below.
  have straight : data.model.straightLine := data.model.geometricApproximation negligible
  have noDiffraction : ¬ data.model.diffractedPath := data.model.omitDiffraction negligible
  have visible : data.model.HasPath → data.model.lineOfSight := by
    intro path
    -- The three cases exhaust only the paths retained by this model.
    rcases path with direct | reflected | diffracted
    · exact data.model.directRequiresVisibility straight direct
    · exact (noReturn reflected).elim
    · exact (noDiffraction diffracted).elim
  -- Source-facing conclusion, only within this restricted propagation model:
  -- no line of sight → no retained propagation path.
  have noPathWithoutLineOfSight :
      ¬ data.model.lineOfSight → ¬ data.model.HasPath := by
    intro blocked path
    exact blocked (visible path)
  exact ⟨noReturn, negligible, straight, visible, noPathWithoutLineOfSight⟩

end LeanVerificationDemo.PhysicsDemo.P06.CandidateAnnotated
