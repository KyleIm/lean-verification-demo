# P02 — Ideal gas equation for arbitrary mass

Problem ID: `321`; Thermodynamics / Ideal Gas Law.
Original problem/solution/answer: [source.jsonl](source.jsonl).
Physlib audit: [PHYSLIB_AUDIT.md](PHYSLIB_AUDIT.md).
Component classification: [CLASSIFICATION.md](CLASSIFICATION.md).

## Physical model and units

The answer is `pV = (m/μ)RT`. The historical “molecular weight” μ functions as
**molar mass**, not dimensionless relative molecular mass. The implementation
uses coherent SI coordinates: m in kg, μ in kg/mol, amount n in mol, p in Pa,
V in m³, absolute temperature T in K, and R in J/(mol K). The historical g and
g/mol convention gives the same numerical ratio n.

`PhyslibTemp.Thermodynamics.MolarIdealGas` imports Physlib's existing ISQ basis,
SI unit choices and `WithDim`; its aliases do not implement new quantity/unit
foundations. This repository pins Physlib commit
`96a6bc5e3c50a2856c64a6c9951c0a1c23790b58`, Lean/Mathlib `4.35.0`.

The known `IdealGas.ideal_gas_law` is a normalized finite-particle result with
natural particle count and R = 1. It cannot be instantiated with arbitrary real
m/μ, and no existing molar conversion was found. The temporary API consequently
adds a phenomenological molar relation with explicit R and a mass/amount relation.
It does not claim a microscopic derivation of that relation.

`GasData` stores dimension-tagged state coordinates. `GasEvidence` supplies:

```text
n : Amount
MassAmountRelation m μ n        -- μ > 0 and n = amountOfSubstanceFromMass m μ
MolarIdealGasLaw p V n R T      -- p.val * V.val = n.val * R.val * T.val
```

Nonnegative mass (including zero), positive absolute temperature and positive R
select the physical regime. Positive μ is carried by `MassAmountRelation`.
No positivity of p or V is needed for this substitution theorem. The equations
compare coordinates in one fixed SI system, not unit-independent `Dimensionful`
objects; arbitrary unit covariance is outside this demo.

## Candidate and explicit pairing

The candidate rewrites n using the mass/amount relation in the molar law:

```text
pV = nRT,     n = m/μ
         ⇒   pV = (m/μ)RT
```

Neither premise is the final target. The trusted proposition depends only on
the gas data, not on a reference molar volume or candidate proof.

```lean
Candidate.solution data evidence : TrustedPhysicsProblem data
```

`Verify.lean` checks this judgment; `PairingWalkthrough.lean` prints the type and
axioms. `CandidateAnnotated.lean` repeats the derivation with comments. Lean
checks the proof terms, not the truth of the English comments.

## Historical solution

At fixed p and T, volume is proportional to mass. For a one-mole sample,
`Vμ/μ = V/m`, hence `Vμ = V*μ/m`. Substituting this into `pVμ = RT`
yields `pV = (m/μ)RT`. This route assumes positive mass to divide by m.
The formal proof uses the modern mass/amount route instead and permits zero mass.

## Run

```bash
lake build
python3 scripts/verify.py --list
python3 scripts/verify.py P02
# Equivalent selection by source problem ID:
python3 scripts/verify.py 321
```

The earlier six mutation cases were adapted to the new model only to preserve
compatibility with the existing verifier. No new cases were created. See
[mutation notes](../../../mutations/PhysicsDemo/P02/README.md).

## Validation results

- `lake build`: PASS (3173 jobs).
- `scripts/verify.py --list`: M00, P01 and P02 listed.
- `scripts/verify.py P02`: all four stages PASS; existing mutations 6/6 PASS.
- After the toolchain upgrade: M00 and P01 verification also PASS, each 6/6 mutations.
- `#print axioms Candidate.solution`: only `propext`, `Classical.choice`, `Quot.sound`.
- `git diff --check`: PASS.

Checks used the installed toolchain and local cached upstream artifacts; an
independent empty-cache installation was not tested. No sibling source paths
are present in the committed dependency declarations. Local ignored cache links
reuse the installed Physlib artifacts; the prior 4.33 Lake cache is retained in
`.cache/lean433/lake` rather than deleted.
