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

The theorem in `Physlib/StatisticalMechanics/MicroCanonicalEnsemble/IdealGas.lean`
has Lean declaration name `IdealGas.ideal_gas_law` (the module path is not its
Lean namespace). It is a normalized microscopic result with `n : ℕ` as particle
count and local `R := 1`. It cannot be instantiated with arbitrary real
m/μ, and no existing molar conversion was found. The temporary API consequently
adds a phenomenological molar relation with explicit R and a mass/amount relation.
It does not claim a microscopic derivation of that relation. P02's law instead
uses `n : Amount` and `R : MolarGasConstant`; the declarations are not directly
interchangeable. R is an explicit symbolic molar-gas-constant parameter; this
module does not fix the numerical value of the universal gas constant.

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

## Why retain the ISQ aliases?

At the pinned revision, the named-quantity audit gives:

| P02 alias | Existing Physlib candidate | Direct reuse assessment |
| --- | --- | --- |
| `Mass` | `Physlib/Units/WithDim/Mass.lean` | File contains documentation but no `Mass` declaration. `MassUnit` in `ClassicalMechanics/Mass/MassUnit.lean:38` represents a unit scale, not sample mass. |
| `Pressure` | `DimPressure`, `Units/WithDim/Pressure.lean:24` | `Dimensionful (WithDim (M𝓭 * L𝓭⁻¹ * T𝓭⁻¹ * T𝓭⁻¹) ℝ)` uses LTMCT and a unit-independent wrapper, unlike P02's fixed-SI ISQ coordinates. |
| `Volume` | Whole stable-tree declaration search | No named `Volume` / `DimVolume` declaration found; P02 specializes existing `WithDim` to ISQ length cubed. |
| `AbsoluteTemperature` | `Temperature`, `Thermodynamics/Temperature/Basic.lean:32` | Structure with `val : ℝ≥0`, not an ISQ dimension-tagged quantity. Reusing it would require coordinate conversion and changes to the state API. |

These are aliases of existing generic Physlib quantities, not a new unit system.
ISQ keeps amount as an independent base dimension; LTMCT does not. Physlib's
basis embedding does not by itself turn a LTMCT `Dimensionful` value into an ISQ
coordinate quantity. Such conversions are possible future work but unnecessary
for this proof, so all four aliases remain unchanged.

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

## Natural-language reformulation

Historical source route:

```text
fixed p,T
→ V proportional to m
→ introduce one-mole volume Vμ
→ Vμ = V μ / m
→ pVμ = RT
→ pV = (m/μ)RT
```

The one-mole scaling can also be written `Vμ/μ = V/m`. This route assumes
positive mass to divide by m.

Formalized modern route:

```text
n = m/μ
pV = nRT
→ pV = (m/μ)RT
```

For the source's positive-mass ideal-gas regime, this is a physically equivalent
modern reformulation, **not a literal step-by-step formalization of the historical
derivation**. The formal statement additionally permits zero mass. It relies on
the independently supplied molar state equation and mass/amount relation; it does
not derive the equivalence of microscopic and phenomenological models.

## Deferred design questions

`amountOfSubstanceFromMass` and `MassAmountRelation` remain reusable temporary
APIs. Whether `n = m/μ` should become an upstream Physlib named API is an open
design question to discuss with Physlib maintainers.

Possible future Physlib/PhyslibTemp APIs, not implemented or needed for P02:

- `universalGasConstant : MolarGasConstant`, with a specified numerical value;
- Avogadro constant `N_A`;
- particle count ↔ amount-of-substance conversion, `N = n N_A`;
- a dimensionally consistent bridge `R = N_A k_B`.

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
