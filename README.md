# Lean Verification Demo

Minimal working prototype of a four-stage verification pipeline for one
mathematical proof and one physics proof.

Demonstration problem:

> Prove that `sqrt(2)` is irrational.

The proof method demonstrated here is proof by contradiction:

1. Assume `sqrt(2)` is rational.
2. Derive a contradiction from that assumption.
3. Conclude that `sqrt(2)` is irrational.

Physics demonstration problem:

> A thick transparent plate has refractive index changing from `n₁` at the
> upper face to `n₂` at the lower face. A beam enters at angle `α`. What is the
> outgoing angle `β`?

Under the explicit model assumptions in `LeanVerificationDemo/Physics/Problem.lean`,
the trusted conclusion is:

```lean
ray.β = data.α
```

The trusted Lean proposition is defined in `LeanVerificationDemo/Problem.lean`:

```lean
def SqrtTwoIrrationalProblem : Prop :=
  Irrational (Real.sqrt 2)
```

## Structure

- `LeanVerificationDemo/Problem.lean`: trusted formal problem statement.
- `LeanVerificationDemo/Candidate.lean`: candidate proof.
- `LeanVerificationDemo/Verify.lean`: Stage 2 type check that the candidate proves the trusted statement.
- `LeanVerificationDemo/PairingWalkthrough.lean`: explicit Stage 2 problem/solution pairing walkthrough.
- `LeanVerificationDemo/CandidateAnnotated.lean`: compiling proof with natural-language comments.
- `mutations/`: intentionally broken variants for mutation testing.
- `mutations/manifest.json`: human-readable mutation metadata and expected outcomes.
- `scripts/verify.py`: orchestration script for all four stages.
- `docs/math/README.md`: detailed guide to the math demo.
- `docs/physics/README.md`: detailed guide to the physics demo.

Physics-specific files:

- `LeanVerificationDemo/Physics/Problem.lean`: trusted physics model and target.
- `LeanVerificationDemo/Physics/Candidate.lean`: candidate physics proof.
- `LeanVerificationDemo/Physics/Verify.lean`: Stage 2 check for the physics target.
- `LeanVerificationDemo/Physics/CandidateAnnotated.lean`: annotated physics proof.
- `mutations/physics/`: physics mutation tests.

## Stage 1: Structural / Compilation Verification

Stage 1 runs `lake build`.

This checks that the valid Lake project compiles: imports resolve, syntax is
accepted, elaboration succeeds, tactics close their goals, and Lean produces
compiled artifacts.

If this stage fails, the compiler output is the reason for failure.

## Stage 2: Problem-Solution Consistency Verification

Stage 2 runs:

```bash
lake env lean LeanVerificationDemo/Verify.lean
```

`Verify.lean` contains:

```lean
example : LeanVerificationDemo.SqrtTwoIrrationalProblem :=
  LeanVerificationDemo.Candidate.solution
```

The visible pairing is:

```text
Problem A  = LeanVerificationDemo.SqrtTwoIrrationalProblem
Candidate B = LeanVerificationDemo.Candidate.solution
Check       = Lean elaborates and validates B : A
```

This prevents the candidate from changing the target theorem. The explicit
typed declaration in `Verify.lean` connects the candidate proof to the trusted
target. Lake runs the build or Lean command, Lean elaborates the source, and the
kernel validates the resulting declaration/type judgment.

## Stage 3: Human-Guided Mutation Verification

Stage 3 is mutation testing around Stages 1 and 2, not another Lean proof layer.

It deliberately perturbs the problem/proof pair and compares the expected Lean
outcome with the actual Lean outcome.

Some mutations should be rejected. Some mutations should be accepted. A mutation
test passes when the expected outcome matches the actual outcome.

Stage 3 uses the same three-part decomposition as the annotated proof:

- Assumption mutation: changes the contradiction assumption from rationality of
  `sqrt(2)` to irrationality of `sqrt(2)`.
- Contradiction mutation: keeps the rationality assumption but derives only
  `True` instead of `False`.
- Conclusion mutation: keeps the contradiction argument but changes the final
  claimed result to rationality of `sqrt(2)`.
- Target substitution: changes the trusted target from irrationality of
  `sqrt(2)` to irrationality of `sqrt(3)` while keeping the original candidate
  proof.
- Irrelevant addition: inserts an unused proof of `(1 : Nat) + 1 = 2` and then
  proves the original target normally.
- Required-step deletion: removes the conversion from the non-square fact to
  irrationality, so the proof no longer reaches the trusted target.

| ID | Category | Expected | Why |
| --- | --- | --- | --- |
| `MATH-M001` | Assumption replacement | `REJECT` | The contradiction block expects a rationality assumption. |
| `MATH-M002` | Contradiction corruption | `REJECT` | `True` does not close a goal of `False`. |
| `MATH-M003` | Conclusion replacement | `REJECT` | A proof of irrationality does not directly prove rationality. |
| `MATH-M004` | Target substitution | `REJECT` | The unchanged proof of `sqrt(2)` irrationality has the wrong type for the `sqrt(3)` target. |
| `MATH-M005` | Irrelevant addition | `ACCEPT` | Lean checks validity, not relevance or minimality. |
| `MATH-M006` | Required-step deletion | `REJECT` | The deleted step is required to derive contradiction from the rationality assumption. |

For target substitution, `sqrt(2)` irrationality is true and `sqrt(3)`
irrationality is also true. The mutation is rejected because the unchanged
candidate proof proves the `sqrt(2)` target, not the `sqrt(3)` target.

For irrelevant addition, the inserted fact `(1 : Nat) + 1 = 2` may be accepted.
This is expected: Lean verifies that the final term has the requested type; it
does not require every intermediate fact to be relevant or necessary.

Expected Lean failures count as successful mutation tests only when the runner
finds the intended proof/type mismatch in the compiler output. Missing files,
bad imports, syntax errors, environment failures, or unrelated Lean failures
make the mutation test fail. Expected Lean acceptances also count as successful
mutation tests when Lean accepts the file.

## Stage 4: Natural-Language Proof Audit

Stage 4 checks that `LeanVerificationDemo/CandidateAnnotated.lean` exists and
compiles.

The comments explain the mathematical meaning of the proof for a human reader.
Lean verifies the Lean code, but it does not verify that the English comments
are correct. This stage is a human-audit and interpretability layer.

Stage 4 does not machine-verify the correctness of the natural-language
comments. It exposes the structure of the Lean proof in natural language so
that a human can audit whether the formal proof corresponds to the intended
mathematical reasoning.

Stage 3 and Stage 4 deliberately use the same decomposition:

1. Assumption.
2. Contradiction.
3. Conclusion.

Stage 3 perturbs these components one at a time. Stage 4 explains these
components one at a time.

For the physics demo, Stage 3 perturbs:

1. The entrance Snell-law relation.
2. The internal stratified/parallel-layer relation.
3. The final conclusion `β = α`.

Stage 4 explains the same physics proof blocks:

1. Problem modeling.
2. Primitive physics at the entrance.
3. Derived physics through the stratified finite-layer model.
4. Primitive physics at the exit.
5. Pure mathematical cancellation and sine injectivity.

## What Lean Guarantees

Lean verifies that a proof term proves a Lean proposition.

For this demo, Lean verifies that `Candidate.solution` proves:

```lean
Irrational (Real.sqrt 2)
```

The proof uses Mathlib's local arithmetic facts that connect irrationality of
`sqrt(n)` to `n` not being a square, and it explicitly presents the
contradiction structure. It does not use `irrational_sqrt_two` as a one-line
shortcut, and it does not use `sorry`, `admit`, or custom axioms.

## What Lean Does Not Guarantee

Lean alone does not automatically verify that the Lean proposition is a
semantically perfect translation of the original natural-language mathematical
problem.

This prototype assumes the trusted Lean specification in `Problem.lean` is the
formal target selected by a human.

## Physics Layering

The physics demo uses the minimal PhyslibTemp Snell-law API vendored in this
repository:

```lean
def SnellLaw
    (nIncident nTransmitted : RefractiveIndex)
    (θIncident : IncidentAngle) (θTransmitted : TransmittedAngle) : Prop :=
  snellExpression nIncident θIncident = snellExpression nTransmitted θTransmitted
```

This lives in:

```text
LeanVerificationDemo/PhyslibTemp/Optics/Refraction.lean
```

No sibling Math2Physics checkout is required. The vendored file keeps the
original `Math2Physics.PhyslibTemp.Optics` namespace so the demo math and
physics proofs use the same API shape as before.

The new theorem:

```lean
theorem stratified_parallel_layer_invariant
    (data : PlateData) (ray : RayThroughPlate data) :
    snellExpression data.n₁ (ray.stack.angle 0) =
      snellExpression data.n₂ (ray.stack.angle ray.stack.layerCount) := by
  have hchain := ray.stack.snellExpression_chain
  simpa [ray.stack_upper_index, ray.stack_lower_index] using hchain
```

is a derived-physics theorem in the demo problem file. It depends on local
adjacent-interface evidence stored in:

```lean
adjacent_snell :
  ∀ i, i < layerCount →
    SnellLaw (index i) (index (i + 1)) (angle i) (angle (i + 1))
```

The global endpoint relation is not stored as a field. It is proved by
`FiniteStratifiedStack.snellExpression_chain`, which uses induction and equality
transitivity to chain the adjacent Snell-law equalities. It is not added to
PhyslibTemp because it is tied to this prototype's simplified finite
parallel-layer model.

Important limitation: this prototype does not prove the full continuous
stratified-medium invariant by a limiting argument from infinitely many layers.
The current PhyslibTemp API does not yet contain ray-path geometry, layered
approximations, or the required limiting theorem. The continuous profile
`n : ℝ → RefractiveIndex` is modeled as problem data, but the proof uses a
finite parallel-layer Snell-law consequence as the derived physics evidence.

## Physics / Math Classification

| Component | Classification |
| --- | --- |
| `SnellLaw` from PhyslibTemp | Primitive physics |
| Entrance relation `n₀ sin α = n₁ sin θ₁` | Primitive physics, applied at the upper interface |
| Exit relation `n₂ sin θ₂ = n₀ sin β` | Primitive physics, applied at the lower interface |
| Local `adjacent_snell` links | Primitive physics, applied at each adjacent parallel interface |
| `stratified_parallel_layer_invariant` | Derived physics for the finite parallel-layer model |
| `FiniteStratifiedStack.snellExpression_chain` | Pure mathematics: induction and equality transitivity |
| `n : ℝ → RefractiveIndex` | Problem-specific modeling |
| `ContinuousOn (fun z => (n z : ℝ)) (Set.Icc 0 L)` | Problem-specific modeling / pure topology |
| Endpoint conditions `n 0 = n₁`, `n L = n₂` | Problem-specific modeling |
| Same external medium `n₀` above and below | Problem-specific modeling |
| Finite sampled stack of layers | Problem-specific modeling |
| Physical angle range assumptions | Problem-specific modeling |
| Chaining equalities | Pure mathematics / Lean equality reasoning |
| Cancelling positive `n₀` | Pure mathematics / Mathlib reasoning |
| Sine injectivity on the physical interval | Pure mathematics / Mathlib reasoning |

## Commands

This repository vendors only the small PhyslibTemp optics module needed by the
physics demo. Lake fetches Mathlib directly from GitHub at the Lean 4.33.0
compatible tag:

```lean
require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.33.0"
```

### Reproduce From A Fresh Clone

Prerequisite: install Elan/Lean so the `lake` command is available on `PATH`.
The repository pins the Lean toolchain in `lean-toolchain`.

```bash
git clone https://github.com/KyleIm/lean-verification-demo.git
cd lean-verification-demo
lake update
lake build
python3 scripts/verify.py
```

If `lake exe cache get` cannot fetch precompiled Mathlib artifacts, `lake build`
may compile more from source and take substantially longer.

Optional cache step after `lake update`:

```bash
lake exe cache get
```

Build the valid project:

```bash
lake build
```

Run the full verification demo:

```bash
python3 scripts/verify.py
```

The script also works directly:

```bash
./scripts/verify.py
```

## What Was Implemented Today

1. A Lake-based four-stage verifier demo.
2. A math proof demo for `sqrt(2)` irrationality by contradiction.
3. Math mutation tests for assumption, contradiction, and conclusion corruption.
4. A physics proof demo for a stratified transparent plate.
5. A finite-layer model that stores only local adjacent-interface Snell-law evidence.
6. A Lean-derived finite-layer Snell invariant proved by induction/equality chaining.
7. Physics mutation tests for entrance Snell corruption, internal local-link corruption, and conclusion corruption.
8. Human-audit annotated proofs for both demos.

More detail:

- Math demo: `docs/math/README.md`
- Physics demo: `docs/physics/README.md`

## Actual `lake build` Output

```text
✔ [3010/3016] Built LeanVerificationDemo.PhyslibTemp.Optics.Refraction (2.4s)
✔ [3011/3016] Built LeanVerificationDemo.Physics.Problem (2.3s)
✔ [3012/3016] Built LeanVerificationDemo.Physics.Candidate (2.3s)
✔ [3013/3016] Built LeanVerificationDemo.Physics.CandidateAnnotated (2.3s)
✔ [3014/3016] Built LeanVerificationDemo.Physics.Verify (2.1s)
✔ [3015/3016] Built LeanVerificationDemo (2.1s)
Build completed successfully (3016 jobs).
```

## Actual Verification Output

```text
LEAN 4-STAGE VERIFICATION DEMO

Original sqrt(2) problem and physics plate problem

[Stage 1] Structural / Compilation Verification
$ lake build
Build completed successfully (3016 jobs).
PASS

[Stage 2] Problem-Solution Consistency Verification

Sqrt(2) problem
$ lake env lean LeanVerificationDemo/Verify.lean
PASS

Physics plate problem
$ lake env lean LeanVerificationDemo/Physics/Verify.lean
PASS

[Stage 3] Human-Guided Mutation Verification

Sqrt(2) mutations

Mutation 1: assumption mutation

Original:
Assume sqrt(2) is rational.

Mutated:
Assume sqrt(2) is irrational instead.

Expected result:
REJECTED

Actual Lean failure:
$ lake env lean mutations/AssumptionMutation.lean
mutations/AssumptionMutation.lean:32:15: error: Application type mismatch: The argument
  hAssumption
has type
  Irrational √2
but is expected to have type
  √2 ∈ Set.range Rat.cast
in the application
  hIrr hAssumption
EXPECTED FAILURE - PASS

Mutation 2: contradiction mutation

Original:
From the rationality assumption, derive False.

Mutated:
Derive only True, which is not a contradiction.

Expected result:
REJECTED

Actual Lean failure:
$ lake env lean mutations/ContradictionMutation.lean
mutations/ContradictionMutation.lean:22:2: error: Type mismatch
  hContradiction
has type
  True
but is expected to have type
  False
EXPECTED FAILURE - PASS

Mutation 3: conclusion mutation

Original:
Conclude that sqrt(2) is irrational.

Mutated:
Conclude that sqrt(2) is rational.

Expected result:
REJECTED

Actual Lean failure:
$ lake env lean mutations/ConclusionMutation.lean
mutations/ConclusionMutation.lean:25:2: error: Type mismatch
  hContradictionFromRational
has type
  (∃ q, ↑q = √2) → False
but is expected to have type
  MutatedProblem
EXPECTED FAILURE - PASS

Physics mutations

Mutation 1: entrance Snell-law corruption

Original:
At the upper interface, n₀ sin α = n₁ sin θ₁.

Mutated:
Use an incompatible relation starting from the lower-index expression instead.

Expected result:
REJECTED

Actual Lean failure:
$ lake env lean mutations/physics/EntranceSnellMutation.lean
mutations/physics/EntranceSnellMutation.lean:30:4: error: Type mismatch
  Eq.trans hEntranceCorrupt (Eq.trans hInternal hExit)
has type
  snellExpression data.n₂ (ray.stack.angle ray.stack.layerCount) = snellExpression data.n₀ ray.β
but is expected to have type
  snellExpression data.n₀ data.α = snellExpression data.n₀ ray.β
EXPECTED FAILURE - PASS

Mutation 2: internal stratified-medium corruption

Original:
Each adjacent parallel interface satisfies Snell's law in the forward layer direction.

Mutated:
Pair the transmitted refractive index with the incident angle instead of the transmitted angle.

Expected result:
REJECTED

Actual Lean failure:
$ lake env lean mutations/physics/InternalStratifiedMutation.lean
mutations/physics/InternalStratifiedMutation.lean:26:10: error: Type mismatch
  hCorrect
has type
  SnellLaw (ray.stack.index i) (ray.stack.index (i + 1)) (ray.stack.angle i) (ray.stack.angle (i + 1))
but is expected to have type
  snellExpression (ray.stack.index i) (ray.stack.angle i) =
    snellExpression (ray.stack.index (i + 1)) (ray.stack.angle i)
mutations/physics/InternalStratifiedMutation.lean:27:8: error: Type mismatch
  hWrongAngle
has type
  snellExpression (ray.stack.index i) (ray.stack.angle i) =
    snellExpression (ray.stack.index (i + 1)) (ray.stack.angle i)
but is expected to have type
  SnellLaw (ray.stack.index i) (ray.stack.index (i + 1)) (ray.stack.angle i) (ray.stack.angle (i + 1))
EXPECTED FAILURE - PASS

Mutation 3: physics conclusion mutation

Original:
Conclude that the outgoing angle equals the incident angle: β = α.

Mutated:
Claim the incompatible conclusion β ≠ α.

Expected result:
REJECTED

Actual Lean failure:
$ lake env lean mutations/physics/PhysicsConclusionMutation.lean
mutations/physics/PhysicsConclusionMutation.lean:15:2: error: Type mismatch
  Candidate.solution data ray
has type
  TrustedPhysicsProblem data ray
but is expected to have type
  MutatedPhysicsProblem data ray
EXPECTED FAILURE - PASS

[Stage 4] Natural-Language Proof Audit

Sqrt(2) annotated proof
Annotated proof exists
$ lake env lean LeanVerificationDemo/CandidateAnnotated.lean
PASS

Physics annotated proof
Annotated proof exists
$ lake env lean LeanVerificationDemo/Physics/CandidateAnnotated.lean
PASS

FINAL RESULT: ALL VERIFICATION TESTS PASSED
```
