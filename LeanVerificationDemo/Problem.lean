import Mathlib.NumberTheory.Real.Irrational

namespace LeanVerificationDemo

/-- Trusted formal statement for the demonstration problem:
`sqrt(2)` is irrational. -/
def SqrtTwoIrrationalProblem : Prop :=
  Irrational (Real.sqrt 2)

theorem trustedProblemStatement :
    SqrtTwoIrrationalProblem ↔ Irrational (Real.sqrt 2) :=
  Iff.rfl

end LeanVerificationDemo
