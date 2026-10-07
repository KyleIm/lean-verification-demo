import LeanVerificationDemo.Physics.Candidate

namespace LeanVerificationDemo
namespace Physics
namespace Mutations
namespace PhysicsConclusionMutation

/-- Mutated target: claim the outgoing angle is not the incident angle. -/
def MutatedPhysicsProblem (data : PlateData) (ray : RayThroughPlate data) : Prop :=
  ray.β ≠ data.α

/-- Mutation 3: check the valid proof against the incompatible conclusion. -/
theorem solution (data : PlateData) (ray : RayThroughPlate data) :
    MutatedPhysicsProblem data ray :=
  Candidate.solution data ray

end PhysicsConclusionMutation
end Mutations
end Physics
end LeanVerificationDemo
