import LeanVerificationDemo.PhysicsDemo.P02.Problem

namespace LeanVerificationDemo.PhysicsDemo.P02.Candidate

open PhyslibTemp.Thermodynamics

/-- Combine the mass/amount relation with the molar equation of state. -/
theorem solution (data : GasData) (evidence : GasEvidence data) :
    TrustedPhysicsProblem data := by
  -- Source answer: pV = (m/μ)RT, with μ the dimensional molar mass.
  change data.p.val * data.V.val =
    (data.m.val / data.μ.val) * data.R.val * data.T.val
  have hn : evidence.n = amountOfSubstanceFromMass data.m data.μ :=
    evidence.mass_amount.2
  have hEOS := evidence.equation_of_state
  change data.p.val * data.V.val = evidence.n.val * data.R.val * data.T.val at hEOS
  rw [hn] at hEOS
  exact hEOS

end LeanVerificationDemo.PhysicsDemo.P02.Candidate
