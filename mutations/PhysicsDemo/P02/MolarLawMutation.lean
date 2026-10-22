import LeanVerificationDemo.PhysicsDemo.P02.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P02

open PhyslibTemp.Thermodynamics

example (data : GasData) (evidence : GasEvidence data) :
    data.p.val * data.V.val = evidence.n.val * data.R.val / data.T.val := by
  have hLaw : data.p.val * data.V.val = evidence.n.val * data.R.val * data.T.val :=
    evidence.equation_of_state
  exact hLaw

end LeanVerificationDemo.PhysicsDemo.P02
