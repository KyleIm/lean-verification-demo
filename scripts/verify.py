#!/usr/bin/env python3
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path
from typing import NamedTuple


ROOT = Path(__file__).resolve().parents[1]
LAKE = os.environ.get("LAKE", "lake")


class MutationCase(NamedTuple):
    number: int
    name: str
    original: str
    mutated: str
    command: list[str]
    expected_fragments: tuple[str, ...]


UNRELATED_FAILURE_MARKERS = (
    "unknown module prefix",
    "No such file",
    "unexpected token",
    "invalid import",
    "failed to load",
    "file does not exist",
    "error during download",
    "failed to fetch cache",
)


def run_command(label: str, command: list[str]) -> subprocess.CompletedProcess[str]:
    resolved = [LAKE if part == "lake" else part for part in command]
    display = ["lake" if part == LAKE else part for part in resolved]
    print(f"$ {' '.join(display)}")
    result = subprocess.run(
        resolved,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    if result.stdout.strip():
        print(result.stdout.rstrip())
    return result


def print_stage_result(result: subprocess.CompletedProcess[str]) -> bool:
    if result.returncode == 0:
        print("PASS")
        return True
    print("FAIL")
    return False


def mutation_test(case: MutationCase) -> bool:
    print(f"\nMutation {case.number}: {case.name}")
    print("\nOriginal:")
    print(case.original)
    print("\nMutated:")
    print(case.mutated)
    print("\nExpected result:")
    print("REJECTED")
    print("\nActual Lean failure:")
    result = run_command(case.name, case.command)
    output = result.stdout

    has_expected_failure = (
        result.returncode != 0
        and all(fragment in output for fragment in case.expected_fragments)
        and not any(marker in output for marker in UNRELATED_FAILURE_MARKERS)
    )

    if has_expected_failure:
        print("EXPECTED FAILURE - PASS")
        return True

    print("UNEXPECTED SUCCESS - FAIL")
    if result.returncode == 0:
        print("Reason: the corrupted pair was accepted by Lean.")
    else:
        print("Reason: Lean failed, but not with the expected proof/type mismatch.")
    return False


def main() -> int:
    print("LEAN 4-STAGE VERIFICATION DEMO\n")
    print("Original sqrt(2) problem and physics plate problem\n")

    print("[Stage 1] Structural / Compilation Verification")
    stage1 = run_command("lake build", ["lake", "build"])
    ok_stage1 = print_stage_result(stage1)

    print("\n[Stage 2] Problem-Solution Consistency Verification")
    print("\nSqrt(2) problem")
    stage2_math = run_command(
        "lake env lean LeanVerificationDemo/Verify.lean",
        ["lake", "env", "lean", "LeanVerificationDemo/Verify.lean"],
    )
    ok_stage2_math = print_stage_result(stage2_math)

    print("\nPhysics plate problem")
    stage2_physics = run_command(
        "lake env lean LeanVerificationDemo/Physics/Verify.lean",
        ["lake", "env", "lean", "LeanVerificationDemo/Physics/Verify.lean"],
    )
    ok_stage2_physics = print_stage_result(stage2_physics)

    print("\n[Stage 3] Human-Guided Mutation Verification")
    print("\nSqrt(2) mutations")
    math_mutation_cases = [
        MutationCase(
            number=1,
            name="assumption mutation",
            original="Assume sqrt(2) is rational.",
            mutated="Assume sqrt(2) is irrational instead.",
            command=["lake", "env", "lean", "mutations/AssumptionMutation.lean"],
            expected_fragments=(
                "Application type mismatch",
                "hAssumption",
                "has type\n  Irrational √2",
                "is expected to have type\n  √2 ∈ Set.range Rat.cast",
            ),
        ),
        MutationCase(
            number=2,
            name="contradiction mutation",
            original="From the rationality assumption, derive False.",
            mutated="Derive only True, which is not a contradiction.",
            command=["lake", "env", "lean", "mutations/ContradictionMutation.lean"],
            expected_fragments=(
                "Type mismatch",
                "hContradiction",
                "has type\n  True",
                "is expected to have type\n  False",
            ),
        ),
        MutationCase(
            number=3,
            name="conclusion mutation",
            original="Conclude that sqrt(2) is irrational.",
            mutated="Conclude that sqrt(2) is rational.",
            command=["lake", "env", "lean", "mutations/ConclusionMutation.lean"],
            expected_fragments=(
                "Type mismatch",
                "hContradictionFromRational",
                "has type\n  (∃ q, ↑q = √2) → False",
                "is expected to have type\n  MutatedProblem",
            ),
        ),
    ]
    math_mutation_results = [mutation_test(case) for case in math_mutation_cases]

    print("\nPhysics mutations")
    physics_mutation_cases = [
        MutationCase(
            number=1,
            name="entrance Snell-law corruption",
            original="At the upper interface, n₀ sin α = n₁ sin θ₁.",
            mutated="Use an incompatible relation starting from the lower-index expression instead.",
            command=["lake", "env", "lean", "mutations/physics/EntranceSnellMutation.lean"],
            expected_fragments=(
                "Type mismatch",
                "hEntranceCorrupt",
                "snellExpression data.n₂ (ray.stack.angle ray.stack.layerCount) = snellExpression data.n₀ ray.β",
                "snellExpression data.n₀ data.α = snellExpression data.n₀ ray.β",
            ),
        ),
        MutationCase(
            number=2,
            name="internal stratified-medium corruption",
            original="Each adjacent parallel interface satisfies Snell's law in the forward layer direction.",
            mutated="Pair the transmitted refractive index with the incident angle instead of the transmitted angle.",
            command=["lake", "env", "lean", "mutations/physics/InternalStratifiedMutation.lean"],
            expected_fragments=(
                "Type mismatch",
                "hCorrect",
                "SnellLaw (ray.stack.index i) (ray.stack.index (i + 1))",
                "snellExpression (ray.stack.index (i + 1)) (ray.stack.angle i)",
            ),
        ),
        MutationCase(
            number=3,
            name="physics conclusion mutation",
            original="Conclude that the outgoing angle equals the incident angle: β = α.",
            mutated="Claim the incompatible conclusion β ≠ α.",
            command=["lake", "env", "lean", "mutations/physics/PhysicsConclusionMutation.lean"],
            expected_fragments=(
                "Type mismatch",
                "Candidate.solution data ray",
                "has type\n  TrustedPhysicsProblem data ray",
                "is expected to have type\n  MutatedPhysicsProblem data ray",
            ),
        ),
    ]
    physics_mutation_results = [mutation_test(case) for case in physics_mutation_cases]

    print("\n[Stage 4] Natural-Language Proof Audit")
    print("\nSqrt(2) annotated proof")
    annotated = ROOT / "LeanVerificationDemo" / "CandidateAnnotated.lean"
    if annotated.exists():
        print("Annotated proof exists")
        stage4 = run_command(
            "lake env lean LeanVerificationDemo/CandidateAnnotated.lean",
            ["lake", "env", "lean", "LeanVerificationDemo/CandidateAnnotated.lean"],
        )
        ok_stage4_math = print_stage_result(stage4)
    else:
        print("Annotated proof is missing")
        print("FAIL")
        ok_stage4_math = False

    print("\nPhysics annotated proof")
    physics_annotated = ROOT / "LeanVerificationDemo" / "Physics" / "CandidateAnnotated.lean"
    if physics_annotated.exists():
        print("Annotated proof exists")
        stage4_physics = run_command(
            "lake env lean LeanVerificationDemo/Physics/CandidateAnnotated.lean",
            ["lake", "env", "lean", "LeanVerificationDemo/Physics/CandidateAnnotated.lean"],
        )
        ok_stage4_physics = print_stage_result(stage4_physics)
    else:
        print("Annotated proof is missing")
        print("FAIL")
        ok_stage4_physics = False

    all_ok = (
        ok_stage1
        and ok_stage2_math
        and ok_stage2_physics
        and all(math_mutation_results)
        and all(physics_mutation_results)
        and ok_stage4_math
        and ok_stage4_physics
    )
    print()
    if all_ok:
        print("FINAL RESULT: ALL VERIFICATION TESTS PASSED")
        return 0

    print("FINAL RESULT: VERIFICATION TESTS FAILED")
    return 1


if __name__ == "__main__":
    sys.exit(main())
