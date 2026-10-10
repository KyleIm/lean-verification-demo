import LeanVerificationDemo.MathDemo.M00.Problem

namespace LeanVerificationDemo.MathDemo.M00.CandidateAnnotated

/-
The human-facing mathematical problem is:

  Prove that sqrt(2) is irrational by contradiction.

The machine-facing statement is `SqrtTwoIrrationalProblem`,
defined in `Problem.lean` as `Irrational (Real.sqrt 2)`.
-/
theorem solution : SqrtTwoIrrationalProblem := by
  -- Step 1 - Assumption:
  -- To prove irrationality by contradiction, rewrite the trusted problem as:
  -- every claimed rational representation of `sqrt(2)` leads to impossibility.
  rw [SqrtTwoIrrationalProblem, Irrational]

  -- Assume that `sqrt(2)` can be represented by a rational number.
  -- This is the rationality assumption that the contradiction argument will refute.
  intro hRat

  -- Step 2 - Contradiction:
  -- A prime natural number cannot be a perfect square. Since `2` is prime,
  -- the natural number `2` is not a square.
  have hNotSquare : ¬ IsSquare (2 : ℕ) := Nat.prime_two.not_isSquare

  -- Mathlib proves the local arithmetic bridge: for a natural number `n`,
  -- `sqrt(n)` is irrational exactly when `n` is not a square.
  -- Applying that bridge to `2` turns the arithmetic fact above into
  -- irrationality of `sqrt(2)`.
  have hIrr : Irrational (Real.sqrt 2) := irrational_sqrt_natCast_iff.mpr hNotSquare

  -- The assumed rational representation contradicts the derived irrationality.
  -- This is the explicit `False` required by the proof by contradiction.
  have hContradiction : False := hIrr hRat

  -- Step 3 - Conclusion:
  -- Since the rationality assumption leads to contradiction, no rational
  -- representation of `sqrt(2)` exists.
  exact hContradiction

end LeanVerificationDemo.MathDemo.M00.CandidateAnnotated
