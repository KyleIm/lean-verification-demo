import LeanVerificationDemo.Physics.Candidate

namespace LeanVerificationDemo
namespace Physics
namespace Mutations
namespace TargetSpecializationMutation

/-
Mutation 4: specialize the target without transforming the candidate proof.

The specialized target is derivable from `Candidate.solution data ray` and
`hAlpha`, but the unchanged candidate proof term alone still has target
`ray.β = data.α`.
-/
theorem solution
    (data : PlateData)
    (ray : RayThroughPlate data)
    (hAlpha : data.α = Real.pi / 6) :
    ray.β = Real.pi / 6 :=
  Candidate.solution data ray

end TargetSpecializationMutation
end Mutations
end Physics
end LeanVerificationDemo
