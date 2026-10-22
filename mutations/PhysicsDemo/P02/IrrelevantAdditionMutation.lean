import LeanVerificationDemo.PhysicsDemo.P02.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P02

open PhyslibTemp.Thermodynamics

example (data : GasData) (evidence : GasEvidence data) :
    TrustedPhysicsProblem data := by
  have _unused : (1 : ℕ) + 1 = 2 := rfl
  exact Candidate.solution data evidence

end LeanVerificationDemo.PhysicsDemo.P02
