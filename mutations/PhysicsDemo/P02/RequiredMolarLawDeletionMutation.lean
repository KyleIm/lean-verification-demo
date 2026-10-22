import LeanVerificationDemo.PhysicsDemo.P02.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P02

open PhyslibTemp.Thermodynamics

-- Keep the mass/amount relation but omit the equation of state.
example (data : GasData) (n : Amount)
    (hAmount : MassAmountRelation data.m data.μ n) :
    TrustedPhysicsProblem data := by
  exact hAmount.2

end LeanVerificationDemo.PhysicsDemo.P02
