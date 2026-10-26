# Lean Verification Demo

Problem-centric Lean verification prototype for one mathematics problem and eleven
physics problems.

## Purpose

This repository verifies formalized problems one problem at a time.  For each
problem, Lean checks that a candidate proof term has the trusted proposition as
its type, and a small mutation suite checks that controlled perturbations behave
as expected.

## Auditing source problem–solution pairs

Both the textbook problem and its supplied solution are inputs to audit, rather
than authorities whose implicit reasoning is automatically trusted. A printed
solution may omit derivable steps or introduce approximations absent from the
question. Review each important step by asking:

1. Is it explicitly given in the original problem?
2. Is it an unstated consequence that can and should be derived?
3. Is it an empirical law or existing physical principle to reuse from Physlib or PhyslibTemp?
4. Is it a required approximation or idealization of the textbook model?
5. If it is an approximation, must it remain a primitive modeling premise, or can it be refined into an exact limiting/idealized statement?
6. Is it mathematical reasoning supported by Mathlib?
7. Does the actual Lean proof follow the documented dependency chain, and are deviations from the source route explained?

The aim is to reconstruct the explanation's logical and physical dependencies,
not mechanically translate each sentence. An omitted derivation should not
become a trusted premise merely because the solution considers it obvious.
A genuine physical approximation should remain explicit, rather than be presented
as an unconditional exact theorem. It need not remain an axiom when precise
limiting semantics can instead support a derivation. Conversely, do not turn a
finite-duration approximation into an exact finite-time statement. Any force,
regularity and event-limit assumptions needed for that refinement must remain
visible. This is a source-review standard; the verifier
checks proof terms against the chosen formal premises, not the physical validity
of those premises or the English documentation.

[P08](LeanVerificationDemo/PhysicsDemo/P08/README.md#the-source-solution-is-also-part-of-the-formalization-audit)
illustrates the distinction: apex rest is now derived under an explicit ideal
coasting model. For finite event duration ε, gravitational impulse is generally
nonzero; it tends to zero exactly as ε → 0⁺. Summed Newton II/III and convergence
of finite-duration endpoint momenta then derive across-event momentum equality.
Constant downward acceleration, initial upward velocity and the existence and
matching of the regularized event states are explicit model assumptions. Lean
does not prove that a physical explosion literally has zero duration.

## Reusable constant-acceleration layer

P08's refinement produced a reusable mechanics layer built on upstream Physlib's
`ReferenceFrame.Particle`, not a rocket-specific particle model:

| File | Role |
| --- | --- |
| [ConstantAcceleration.lean](LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/ConstantAcceleration.lean) | `HasConstantAcceleration` and derived velocity/position laws for any spatial dimension |
| [ConstantAcceleration.md](LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/ConstantAcceleration.md) | Reusability rationale, API limits and possible upstream integration |
| [ConstantAccelerationExamples.lean](LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/ConstantAccelerationExamples.lean) | Independent library consistency checks, including zero acceleration and dimensions 4 and 0 |

The dependency is upstream Particle → PhyslibTemp ConstantAcceleration → P08's
vertical coasting specialization → derived apex rest → explosion momentum and
linear coplanarity. No `UniformGravity` module exists yet: a future layer should
add physical content such as a gravitational force/Newton-II bridge, rather than
merely rename a constant vector. The design notes describe a possible future
upstream contribution; they are not P08 source assumptions or additional axioms.

P09 reuses the same layer for two separate sliding segments. Newton/friction
premises give their accelerations, and elastic speed matching joins the derived
distance relations. Its additive [unit layer](LeanVerificationDemo/PhysicsDemo/P09/Units.lean)
uses upstream Physlib dimensions and SI quantities to check the same equations
and exact numerical result. No new PhyslibTemp friction, collision or unit API is added.

## Reusable impulse–momentum layer

[ImpulseMomentum.lean](LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/ImpulseMomentum.lean)
adds coordinate finite-system Newton II/III, derived internal cancellation,
the finite impulse–momentum theorem, continuous-force shrinking-interval limits
and an event-limit consequence. It also includes adapters proving momentum
derivatives and internal cancellation for upstream Newtonian-system data.
[Design notes](LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/ImpulseMomentum.md)
explain the indexed interface and the limits of the upstream integration;
[independent examples](LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/ImpulseMomentumExamples.lean)
check interacting bodies, finite nonzero impulses, vanishing limits and arbitrary
vector dimension. No rocket or explosion ontology is introduced.

The possible future branch is PointParticle / Force / NewtonianSystem →
ImpulseMomentum → interaction/event applications. In P08 it joins the
constant-acceleration branch: kinematics supplies pre-event rest, while force
balance and a duration limit supply event momentum transfer.

## Verification Pipeline

For each problem:

1. Compile the trusted problem source and candidate source.
2. Check the explicit proposition/proof pairing.
3. Run six controlled mutation tests.
4. Compile an annotated proof for human audit.

P03–P11 currently defer mutation cases; Stage 3 explicitly reports `SKIPPED` for
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
| Physics | `574` | `P07` | [problem README](LeanVerificationDemo/PhysicsDemo/P07/README.md), [reconstructed illustration](LeanVerificationDemo/PhysicsDemo/P07/problem_diagram.svg), [induction audit](LeanVerificationDemo/PhysicsDemo/P07/PHYSLIB_AUDIT.md) |
| Physics | `77` | `P08` | [problem README](LeanVerificationDemo/PhysicsDemo/P08/README.md), [mechanics and linear-algebra audit](LeanVerificationDemo/PhysicsDemo/P08/PHYSLIB_AUDIT.md) |
| Physics | `47` | `P09` | [problem README](LeanVerificationDemo/PhysicsDemo/P09/README.md), [friction/impact audit](LeanVerificationDemo/PhysicsDemo/P09/PHYSLIB_AUDIT.md) |
| Physics | `23` | `P10` | [problem README](LeanVerificationDemo/PhysicsDemo/P10/README.md), [caption-only graph](LeanVerificationDemo/PhysicsDemo/P10/problem_diagram.svg), [audit](LeanVerificationDemo/PhysicsDemo/P10/PHYSLIB_AUDIT.md) |
| Physics | `677` | `P11` | [problem README](LeanVerificationDemo/PhysicsDemo/P11/README.md), [trusted Fig. 237 caption](LeanVerificationDemo/PhysicsDemo/P11/figure_caption.txt), [mirror/shadow audit](LeanVerificationDemo/PhysicsDemo/P11/PHYSLIB_AUDIT.md) |

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
python3 scripts/verify.py P07
python3 scripts/verify.py P08
python3 scripts/verify.py P09
python3 scripts/verify.py P10
python3 scripts/verify.py P11
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
| `574` (P07) | PASS | PASS | SKIPPED | PASS | PASS |
| `77` (P08) | PASS | PASS | SKIPPED | PASS | PASS |
| `47` (P09) | PASS | PASS | SKIPPED | PASS | PASS |
| `23` (P10) | PASS | PASS | SKIPPED | PASS | PASS |
| `677` (P11) | PASS | PASS | SKIPPED | PASS | PASS |

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
