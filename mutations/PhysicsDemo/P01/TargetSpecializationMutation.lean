import LeanVerificationDemo.PhysicsDemo.P01.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P01.Mutations.TargetSpecializationMutation

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

end LeanVerificationDemo.PhysicsDemo.P01.Mutations.TargetSpecializationMutation
