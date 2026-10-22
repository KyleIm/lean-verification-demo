import LeanVerificationDemo.PhysicsDemo.P02.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P02

open PhyslibTemp.Thermodynamics

example (data : GasData) (evidence : GasEvidence data) :
    data.p.val * data.V.val = (data.μ.val / data.m.val) * data.R.val * data.T.val := by
  exact Candidate.solution data evidence

end LeanVerificationDemo.PhysicsDemo.P02
