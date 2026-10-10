#!/usr/bin/env python3
from __future__ import annotations

import os
import json
import subprocess
import sys
from pathlib import Path
from typing import Any, NamedTuple


ROOT = Path(__file__).resolve().parents[1]
LAKE = os.environ.get("LAKE", "lake")
MUTATION_MANIFEST = ROOT / "mutations" / "manifest.json"


class ManifestMutationCase(NamedTuple):
    id: str
    domain: str
    category: str
    name: str
    mutated_object: str
    original: str
    mutated: str
    expected: str
    command: list[str]
    rationale: str
    expected_error_fragments: tuple[str, ...]


class MutationResult(NamedTuple):
    id: str
    category: str
    expected: str
    actual: str
    passed: bool


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


def print_pairing_check(
    label: str,
    trusted_problem: str,
    candidate_proof: str,
    command: list[str],
    proof_application: str | None = None,
) -> bool:
    print(f"\n[PAIRING CHECK - {label}]")
    print("\nTrusted problem/type:")
    print(f"  {trusted_problem}")
    print("\nCandidate proof term:")
    print(f"  {candidate_proof}")
    print("\nRequired judgment:")
    judgment_term = proof_application or candidate_proof
    print(f"  {judgment_term}")
    print(f"    : {trusted_problem}")
    print("\nRunning Lean type check...")
    result = run_command(label, command)
    print("\nResult:")
    if result.returncode == 0:
        print("  ACCEPTED")
        return True
    print("  REJECTED")
    return False


def load_manifest_cases(domain: str) -> list[ManifestMutationCase]:
    with MUTATION_MANIFEST.open(encoding="utf-8") as manifest_file:
        raw_cases: list[dict[str, Any]] = json.load(manifest_file)

    cases: list[ManifestMutationCase] = []
    for raw in raw_cases:
        if raw["domain"] != domain:
            continue
        cases.append(
            ManifestMutationCase(
                id=raw["id"],
                domain=raw["domain"],
                category=raw["category"],
                name=raw["name"],
                mutated_object=raw["mutated_object"],
                original=raw["original"],
                mutated=raw["mutated"],
                expected=raw["expected"],
                command=list(raw["command"]),
                rationale=raw["rationale"],
                expected_error_fragments=tuple(raw.get("expected_error_fragments", ())),
            )
        )
    return cases


def manifest_mutation_test(case: ManifestMutationCase) -> MutationResult:
    print(f"\n[{case.id}]")
    print("\nDomain:")
    print(f"  {case.domain}")
    print("\nCategory:")
    print(f"  {case.category}")
    print("\nMutated object:")
    print(f"  {case.mutated_object}")
    print("\nOriginal:")
    print(f"  {case.original}")
    print("\nMutated:")
    print(f"  {case.mutated}")
    print("\nExpected outcome:")
    print(f"  {case.expected}")
    print("\nRunning Lean...")

    result = run_command(case.name, case.command)
    actual = "ACCEPT" if result.returncode == 0 else "REJECT"
    output = result.stdout

    if case.expected == "REJECT":
        fragments_ok = all(
            fragment in output for fragment in case.expected_error_fragments
        )
        unrelated_failure = any(marker in output for marker in UNRELATED_FAILURE_MARKERS)
        passed = actual == case.expected and fragments_ok and not unrelated_failure
    else:
        passed = actual == case.expected

    print("\nActual outcome:")
    print(f"  {actual}")
    if actual == "ACCEPT":
        print("\nLean accepted this mutation.")

    print("\nRationale:")
    print(f"  {case.rationale}")
    print("\nTEST RESULT:")
    print(f"  {'PASS' if passed else 'FAIL'}")

    if actual == "REJECT" and case.expected == "REJECT" and not passed:
        print("\nReason:")
        print("  Lean rejected the file, but the error did not match the expected mutation signature.")
    elif actual != case.expected:
        print("\nReason:")
        print(f"  Expected {case.expected}, got {actual}.")

    return MutationResult(
        id=case.id,
        category=case.category,
        expected=case.expected,
        actual=actual,
        passed=passed,
    )


def print_mutation_summary(results: list[MutationResult]) -> None:
    if not results:
        return
    category_width = max(28, *(len(result.category) + 2 for result in results))
    print("\nMutation summary")
    print(f"{'ID':<12}{'Category':<{category_width}}{'Expected':<11}{'Actual':<9}Test")
    for result in results:
        test = "PASS" if result.passed else "FAIL"
        print(
            f"{result.id:<12}{result.category:<{category_width}}"
            f"{result.expected:<11}{result.actual:<9}{test}"
        )


def main() -> int:
    print("LEAN 4-STAGE VERIFICATION DEMO\n")
    print("Original sqrt(2) problem and physics plate problem\n")

    print("[Stage 1] Structural / Compilation Verification")
    stage1 = run_command("lake build", ["lake", "build"])
    ok_stage1 = print_stage_result(stage1)

    print("\n[Stage 2] Problem-Solution Consistency Verification")
    ok_stage2_math = print_pairing_check(
        "MATH",
        "LeanVerificationDemo.SqrtTwoIrrationalProblem",
        "LeanVerificationDemo.Candidate.solution",
        ["lake", "env", "lean", "LeanVerificationDemo/Verify.lean"],
    )

    ok_stage2_physics = print_pairing_check(
        "PHYSICS",
        "TrustedPhysicsProblem data ray",
        "Candidate.solution data ray",
        ["lake", "env", "lean", "LeanVerificationDemo/Physics/Verify.lean"],
        proof_application="Candidate.solution data ray",
    )

    print("\n[Stage 3] Human-Guided Mutation Verification")
    print("\nSqrt(2) mutations")
    math_mutation_results = [
        manifest_mutation_test(case) for case in load_manifest_cases("math")
    ]
    print_mutation_summary(math_mutation_results)

    print("\nPhysics mutations")
    physics_mutation_results = [
        manifest_mutation_test(case) for case in load_manifest_cases("physics")
    ]
    print_mutation_summary(physics_mutation_results)

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
        and all(result.passed for result in math_mutation_results)
        and all(result.passed for result in physics_mutation_results)
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
