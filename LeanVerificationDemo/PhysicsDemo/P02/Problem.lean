import LeanVerificationDemo.PhyslibTemp.Thermodynamics.MolarIdealGas

namespace LeanVerificationDemo.PhysicsDemo.P02

open PhyslibTemp.Thermodynamics

/-- Problem-specific ideal-gas state in coherent SI coordinates.
Zero mass is permitted. No separate signs for pressure or volume are needed
for this substitution; positive temperature selects the physical gas regime. -/
structure GasData where
  p : Pressure
  V : Volume
  m : Mass
  μ : MolarMass
  R : MolarGasConstant
  T : AbsoluteTemperature
  m_nonneg : 0 ≤ m.val
  R_pos : 0 < R.val
  T_pos : 0 < T.val

/-- Independent physical premises: molar amount, its mass relation, and the
molar ideal-gas equation. The arbitrary-mass conclusion is not an input field. -/
structure GasEvidence (data : GasData) where
  n : Amount
  mass_amount : MassAmountRelation data.m data.μ n
  equation_of_state : MolarIdealGasLaw data.p data.V n data.R data.T

/-- Problem 321: arbitrary-mass equation of state, in coherent SI coordinates. -/
def TrustedPhysicsProblem (data : GasData) : Prop :=
  data.p.val * data.V.val = (data.m.val / data.μ.val) * data.R.val * data.T.val

end LeanVerificationDemo.PhysicsDemo.P02
