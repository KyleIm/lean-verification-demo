# Lean Verification Demo

Problem-centric Lean verification prototype for one mathematics problem and six
physics problems.

## Purpose

This repository verifies formalized problems one problem at a time.  For each
problem, Lean checks that a candidate proof term has the trusted proposition as
its type, and a small mutation suite checks that controlled perturbations behave
as expected.

## Verification Pipeline

For each problem:

1. Compile the trusted problem source and candidate source.
2. Check the explicit proposition/proof pairing.
3. Run six controlled mutation tests.
4. Compile an annotated proof for human audit.

P03, P04, P05 and P06 currently defer mutation cases; Stage 3 explicitly reports `SKIPPED` for
an empty manifest. Existing demos still run their six mutation checks.

The six mutation tests are part of Stage 3.  They are not six separate
verification stages.

## Execution Path

```text
scripts/verify.py
  ↓
lake env
  ↓
pinned Lean / Mathlib environment
  ↓
lean <selected file>
  ↓
parsing + elaboration + type checking
  ↓
Lean kernel validates the resulting declaration
```

`scripts/verify.py` orchestrates commands and interprets results.  `lake env`
supplies the repository's pinned Lean/Mathlib environment.  Lean parses and
elaborates the selected source file, and Lean's trusted kernel validates the
resulting declaration/type judgment.

Stage 1 uses `lake env lean <file>` to check that the selected problem's
`Problem.lean` and `Candidate.lean` are individually valid Lean source files.
Stage 2 runs `Verify.lean`, which explicitly requires the candidate proof to
inhabit the trusted proposition, such as:

```text
Candidate.solution : SqrtTwoIrrationalProblem
Candidate.solution data ray : TrustedPhysicsProblem data ray
```

`lake build` remains a repository-level validation command for the valid Lake
project.

## Current Problems

| Area | Problem ID | Code | Documentation |
| --- | --- | --- | --- |
| Mathematics | `math-sqrt2-irrational` | `M00` | [problem README](LeanVerificationDemo/MathDemo/M00/README.md) |
| Physics | `697` (local ID `physics-stratified-plate`) | `P01` | [problem README](LeanVerificationDemo/PhysicsDemo/P01/README.md), [classification](LeanVerificationDemo/PhysicsDemo/P01/CLASSIFICATION.md) |
| Physics | `321` | `P02` | [problem README](LeanVerificationDemo/PhysicsDemo/P02/README.md), [source JSONL](LeanVerificationDemo/PhysicsDemo/P02/source.jsonl) |
| Physics | `433` | `P03` | [problem README](LeanVerificationDemo/PhysicsDemo/P03/README.md), [audit](LeanVerificationDemo/PhysicsDemo/P03/PHYSLIB_AUDIT.md) |
| Physics | `436` (local ID `cube-capacitor-opposite-vertices`) | `P04` | [problem README](LeanVerificationDemo/PhysicsDemo/P04/README.md), [diagram caption and source](LeanVerificationDemo/PhysicsDemo/P04/source.jsonl) |
| Physics | `108` | `P05` | [problem README](LeanVerificationDemo/PhysicsDemo/P05/README.md), [mechanics audit](LeanVerificationDemo/PhysicsDemo/P05/PHYSLIB_AUDIT.md) |
| Physics | `656` | `P06` | [problem README](LeanVerificationDemo/PhysicsDemo/P06/README.md), [propagation audit](LeanVerificationDemo/PhysicsDemo/P06/PHYSLIB_AUDIT.md) |

## Run

List available problems:

```bash
python3 scripts/verify.py --list
```

Verify one problem by code:

```bash
python3 scripts/verify.py M00
python3 scripts/verify.py P01
python3 scripts/verify.py P02
python3 scripts/verify.py P03
python3 scripts/verify.py P04
python3 scripts/verify.py P05
python3 scripts/verify.py P06
```

Or by full problem ID:

```bash
python3 scripts/verify.py math-sqrt2-irrational
python3 scripts/verify.py physics-stratified-plate
python3 scripts/verify.py 321
```

Running without an argument shows the available problems and prompts for a code
or ID.  Add `--verbose` to show raw Lean diagnostics for each command.

## Current Status

| Problem | Compile | Pairing | Mutations | Audit | Result |
| --- | --- | --- | --- | --- | --- |
| `math-sqrt2-irrational` | PASS | PASS | 6 / 6 PASS | PASS | PASS |
| `physics-stratified-plate` | PASS | PASS | 6 / 6 PASS | PASS | PASS |
| `321` (P02) | PASS | PASS | 6 / 6 PASS | PASS | PASS |
| `433` (P03) | PASS | PASS | SKIPPED | PASS | PASS |
| `cube-capacitor-opposite-vertices` (P04) | PASS | PASS | SKIPPED | PASS | PASS |
| `108` (P05) | PASS | PASS | SKIPPED | PASS | PASS |
| `656` (P06) | PASS | PASS | SKIPPED | PASS | PASS |

## Environment

- Lean: `4.35.0`
- Mathlib: `v4.35.0`
- Physlib: `96a6bc5e3c50a2856c64a6c9951c0a1c23790b58` (P02 unit infrastructure).

The repository pins these versions in `lean-toolchain` and `lakefile.lean`.

## Repository Notes

The repository pins its upstream Physlib dependency and keeps missing reusable
physics under `LeanVerificationDemo/PhyslibTemp`. P02 imports Physlib unit
infrastructure; its molar API and audit are documented in the problem README.

The vendored file keeps the historical `Math2Physics.PhyslibTemp.Optics`
namespace for API compatibility, but no sibling Math2Physics checkout is
required.
