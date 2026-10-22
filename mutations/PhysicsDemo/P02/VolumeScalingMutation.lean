import LeanVerificationDemo.PhysicsDemo.P02.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P02

open PhyslibTemp.Thermodynamics

example (data : GasData) (evidence : GasEvidence data) :
    evidence.n.val = data.μ.val / data.m.val := by
  have hAmount : evidence.n.val = data.m.val / data.μ.val :=
    congrArg WithDim.val evidence.mass_amount.2
  exact hAmount

end LeanVerificationDemo.PhysicsDemo.P02
