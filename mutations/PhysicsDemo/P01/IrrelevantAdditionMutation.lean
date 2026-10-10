import LeanVerificationDemo.PhysicsDemo.P01.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P01.Mutations.IrrelevantAdditionMutation

/-- Mutation 5: add a true but unused intermediate fact. -/
theorem solution (data : PlateData) (ray : RayThroughPlate data) :
    TrustedPhysicsProblem data ray := by
  have hIrrelevant : (1 : Nat) + 1 = 2 := by
    norm_num

  exact Candidate.solution data ray

end LeanVerificationDemo.PhysicsDemo.P01.Mutations.IrrelevantAdditionMutation
