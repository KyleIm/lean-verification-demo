# Math Demo: `sqrt(2)` Is Irrational

This demo verifies the theorem:

> Prove that `sqrt(2)` is irrational, by contradiction.

## Files

- `LeanVerificationDemo/Problem.lean`: trusted Lean statement.
- `LeanVerificationDemo/Candidate.lean`: candidate proof.
- `LeanVerificationDemo/Verify.lean`: Stage 2 type check.
- `LeanVerificationDemo/CandidateAnnotated.lean`: commented proof for human audit.
- `mutations/AssumptionMutation.lean`: corrupts the contradiction assumption.
- `mutations/ContradictionMutation.lean`: corrupts the contradiction step.
- `mutations/ConclusionMutation.lean`: corrupts the final conclusion.

## Trusted Statement

```lean
def SqrtTwoIrrationalProblem : Prop :=
  Irrational (Real.sqrt 2)
```

Stage 2 checks:

```lean
example : LeanVerificationDemo.SqrtTwoIrrationalProblem :=
  LeanVerificationDemo.Candidate.solution
```

This prevents the candidate from proving a different theorem.

## Proof Structure

The successful proof is explicitly organized as:

1. Assume `sqrt(2)` is rational.
2. Use Mathlib's arithmetic fact that `sqrt(n)` is irrational when `n` is not a square.
3. Since `2` is prime, `2` is not a square.
4. The rationality assumption contradicts irrationality.
5. Therefore `sqrt(2)` is irrational.

The proof does not use `irrational_sqrt_two` as a one-line shortcut.

## Mutation Tests

The math mutations are controlled proof corruptions:

| Mutation | Corruption | Expected result |
| --- | --- | --- |
| Assumption | assumes irrationality instead of rationality | Lean type mismatch |
| Contradiction | derives `True` instead of `False` | Lean type mismatch |
| Conclusion | concludes rationality instead of irrationality | Lean type mismatch |

The Python runner checks that the Lean failure contains the expected proof/type
mismatch, not just any nonzero exit code.

## Commands

From the repository root:

```bash
python3 scripts/verify.py
```

To run only the math Stage 2 check:

```bash
lake env lean LeanVerificationDemo/Verify.lean
```

## Limitations

Lean verifies that the Lean proof proves the Lean statement. It does not
automatically verify that the Lean proposition is the perfect semantic
translation of the English sentence.
