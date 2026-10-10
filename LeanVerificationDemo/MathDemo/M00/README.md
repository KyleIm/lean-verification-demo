# M00 — sqrt(2) Is Irrational

Problem ID: `math-sqrt2-irrational`

## Original Problem

Prove that `sqrt(2)` is irrational.

## Trusted Lean Proposition

```lean
def SqrtTwoIrrationalProblem : Prop :=
  Irrational (Real.sqrt 2)
```

## Candidate Proof

The candidate proof is:

```lean
LeanVerificationDemo.MathDemo.M00.Candidate.solution
```

It proves the trusted proposition by contradiction: assume a rational
representation of `sqrt(2)`, derive irrationality from the non-square fact for
`2`, and close the contradiction.

## Proof Structure

1. Rewrite the trusted proposition as an irrationality goal.
2. Introduce a rationality assumption.
3. Use Mathlib's square-root irrationality criterion for natural numbers.
4. Apply the derived irrationality proof to the rationality assumption.

## Stage 1 — Compilation Check

The problem verifier compiles:

- `Problem.lean`
- `Candidate.lean`

It runs the equivalent of:

```bash
lake env lean LeanVerificationDemo/MathDemo/M00/Problem.lean
lake env lean LeanVerificationDemo/MathDemo/M00/Candidate.lean
```

Lake supplies the pinned Lean/Mathlib environment.  Lean parses and elaborates
each source file, and Lean's trusted kernel validates the resulting
declarations.

## Stage 2 — Proposition / Proof Pairing

The explicit pairing is:

```lean
example : SqrtTwoIrrationalProblem :=
  Candidate.solution
```

The required judgment is:

```text
LeanVerificationDemo.MathDemo.M00.Candidate.solution
  : LeanVerificationDemo.MathDemo.M00.SqrtTwoIrrationalProblem
```

`Verify.lean` explicitly asks Lean to accept this judgment.  Python does not
compare strings or theorem names; it launches Lean through `lake env`.  Lean
elaborates the declaration, and Lean's trusted kernel checks that the candidate
proof inhabits the trusted proposition.

## Stage 3 — Six-Mutation Summary

| ID | Category | Expected | Details |
| --- | --- | --- | --- |
| `MATH-M001` | Assumption replacement | REJECT | [M001](../../../mutations/MathDemo/M00/M001.md) |
| `MATH-M002` | Contradiction corruption | REJECT | [M002](../../../mutations/MathDemo/M00/M002.md) |
| `MATH-M003` | Conclusion replacement | REJECT | [M003](../../../mutations/MathDemo/M00/M003.md) |
| `MATH-M004` | Target substitution | REJECT | [M004](../../../mutations/MathDemo/M00/M004.md) |
| `MATH-M005` | Irrelevant addition | ACCEPT | [M005](../../../mutations/MathDemo/M00/M005.md) |
| `MATH-M006` | Required-step deletion | REJECT | [M006](../../../mutations/MathDemo/M00/M006.md) |

## Stage 4 — Annotated Proof

`CandidateAnnotated.lean` contains the same proof with human-facing comments.
Lean checks the Lean code in the annotated file.  It does not machine-check the
truth of the English comments.

## Current Verification Result

Current direct checks:

```text
lake build                                      PASS
LeanVerificationDemo/MathDemo/M00/Verify.lean  PASS
MATH-M001                                      REJECT -> PASS
MATH-M002                                      REJECT -> PASS
MATH-M003                                      REJECT -> PASS
MATH-M004                                      REJECT -> PASS
MATH-M005                                      ACCEPT -> PASS
MATH-M006                                      REJECT -> PASS
CandidateAnnotated.lean                        PASS
```

## Limitations

Lean verifies the formal proposition.  It does not decide whether the trusted
Lean statement is the only possible formalization of the informal problem.

## How To Run This Problem

Use the problem-centric verifier:

```bash
python3 scripts/verify.py M00
```

For manual/direct Lean checks:

```bash
lake build
lake env lean LeanVerificationDemo/MathDemo/M00/Verify.lean
lake env lean LeanVerificationDemo/MathDemo/M00/CandidateAnnotated.lean
```
