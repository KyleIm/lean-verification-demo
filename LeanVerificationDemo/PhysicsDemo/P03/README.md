# P03 — Series capacitors and dielectric breakdown

Problem ID `433`; Electromagnetism. Source data and reasoning are preserved in
[source.jsonl](source.jsonl). See the [Physlib audit](PHYSLIB_AUDIT.md) for exact
pinned declarations/search evidence and [classification](CLASSIFICATION.md) for
what is reused, assumed or derived.

## Model and units

Four ideal identical parallel-plane capacitors initially contain air; the second
configuration replaces one with an equal-geometry glass capacitor. Assume linear
materials, uniform gap fields, negligible leakage/fringe effects and initially
uncharged isolated intermediate conductors. Q is the common **magnitude** of series
charge, not the signed net charge of each entire capacitor. Series voltage drops
have one orientation and add; no opposing/precharged sources are modeled.

Quantity aliases specialize existing Physlib `WithDim` over LTMCT to C, V, F,
V/m and m. Unlike P02, this problem needs no substance-amount dimension. Equations
and totals compare numerical coordinates in fixed coherent SI units. This is not
a general unit-covariance theorem or a microscopic/Maxwell circuit derivation.

| Source | Coherent SI input |
| --- | --- |
| Ea = 3 × 10⁴ V/cm | 3,000,000 V/m |
| Eg = 9 × 10⁴ V/cm | 9,000,000 V/m |
| d = 0.7 cm | 7/1000 m |
| εr = 7 | dimensionless 7 |

These exact SI constants are stored in `SourceData`; conversion from centimetres
is documented preprocessing, not a claimed Physlib unit-conversion theorem.
Reference air capacitance remains arbitrary and positive and cancels out.

## Physical primitives and source route

Stable Physlib supplies units and general electric field/potential relations,
but the audit found no capacitor, dielectric-scaling or breakdown API.
The minimal temporary module is
`LeanVerificationDemo/PhyslibTemp/Electromagnetism/PlaneCapacitor.lean`.
It defines `U = Q/C`, the uniform-gap relation and fixed-geometry dielectric
scaling independently of any failure model. `DielectricBreakdown.lean` imports
that basic module and adds an optional `BreakdownSpec (c : PlaneCapacitor)` with
threshold/admissibility and threshold-charge results. Neither module contains
P03 numerical constants or air/glass/four-component configuration.

The basic capacitor stores only C, gap and their positivity proofs. P03's
`BatteryData` separately supplies `airBreakdown : BreakdownSpec air` and
`glassBreakdown : BreakdownSpec glass`. Other capacitor problems need not import
the breakdown module or supply a breakdown field. `SourceData` continues to
supply only the two material field values, gap and relative permittivity.

`DielectricScaling` represents equal gaps explicitly. Equal plate area and the
remaining fixed-geometry assumptions are supplied externally; plate area is not
a capacitor field. This relation is a constitutive premise, not a derivation
from C = ε A/d or Maxwell equations.

The source route is retained:

```text
Q = Cair Uair; same Q in series
Cglass = εr Cair
Uglass = Q/Cglass = Uair/εr
```

The Lean implementation uses the algebraically equivalent primitive `U = Q/C`
instead of first solving `Q=CU`. Common Q and dielectric scaling are supplied
physical premises. The common q is a supplied ideal-series model, not a theorem
derived from a formal circuit graph. It does not derive equal charge from a formal circuit graph
or capacitance scaling from plate area or a Gaussian-units formula.

## Symbolic derivation and actual maxima

Let L = Ea d and G = Eg d. The candidate proves, before numerical evaluation:

```text
four air: Utotal = 4 Uair ≤ 4 L
mixed:    Utotal = 3 Uair + Uair/εr ≤ 3 L + L/εr
```

Positive εr makes the second expression increasing with Uair. At
`Q* = Cair L`, `Uair = L` exactly. Q* is admissible in air; glass is also admissible
when `L/εr ≤ G`, a condition proved from the source values, not assumed in the
final theorem. Thus both upper bounds have explicit attaining states.

`MaximumVoltage allowed total U` requires both:

```lean
(∀ q, allowed q → total q ≤ U) ∧ ∃ q, allowed q ∧ total q = U
```

The breakdown threshold is inclusive (`≤`), so these are attained maxima in an
idealized threshold model. A strict safety bound would yield a supremum instead.

## Numerical results and glass comparison

```text
L = 3,000,000 × 0.007 = 21,000 V
four air maximum = 4 L = 84,000 V
Uglass(Q*) = L/7 = 3,000 V
mixed maximum = 3 L + L/7 = 66,000 V
G = 9,000,000 × 0.007 = 63,000 V
3,000 V < 63,000 V
```

The named P03 helper `Candidate.glass_voltage_at_air_limit data source` explicitly
proves `(data.glass.voltage data.airBreakdown.chargeAtLimit).val = 3000` from the
air field, gap and εr in `SourceData`. The final solution uses this helper to
establish the strict comparison with the computed glass threshold. This helper
is P03-specific derived data; 3000 is not exported into PhyslibTemp.
The glass safety comparison is an explicit conclusion, not an input assumption.

Historical wording corresponds to “punctured” / “puncturing field intensity”.
This repository normalizes those terms to modern “dielectric breakdown” /
“breakdown field”; it does not claim those modern phrases are literal source
wording. `source.jsonl` is the normalized English working transcription.

## Trusted proposition and candidate pairing

```lean
def TrustedPhysicsProblem (data : BatteryData) : Prop :=
  MaximumVoltage data.airBreakdown.Admissible (airTotal data) 84000 ∧
  MaximumVoltage (mixedAdmissible data) (mixedTotal data) 66000 ∧
  (data.glass.voltage data.airBreakdown.chargeAtLimit).val < data.glassBreakdown.breakdownVoltage.val

Candidate.solution data source : TrustedPhysicsProblem data
```

`source : SourceData data` supplies only material fields, gap and εr. No final
voltage or upper-bound conclusion is an input field. `Verify.lean` checks this
judgment and includes a concrete consistent input example, ensuring the source
assumptions are satisfiable. `CandidateAnnotated.lean` repeats the proof with
explanatory comments; Lean checks the code, not the English commentary.

## Run

```bash
lake build
python3 scripts/verify.py --list
python3 scripts/verify.py P03
python3 scripts/verify.py P02
python3 scripts/verify.py P01
python3 scripts/verify.py M00
```

No mutations are configured yet. The verifier now handles an empty mutation
manifest with an explicit `SKIPPED` result; existing demos keep their mutation
behavior. A successful P03 result means compilation, pairing and annotated proof
passed, with mutation coverage deferred.

## Verified results

- `lake build`: PASS (3180 jobs); existing module-system interoperability warnings remain.
- `scripts/verify.py --list`: includes P03 / 433.
- `scripts/verify.py P03`: compilation, trusted pairing and annotated proof PASS;
  mutation stage explicitly SKIPPED.
- P02, P01 and M00: PASS, including their existing six mutation cases each.
- `#print axioms Candidate.solution`: only `propext`, `Classical.choice`, `Quot.sound`.
- `git diff --check`: PASS.

Validation reused installed toolchains and local dependency caches. A separate
empty-cache installation was not tested. Dependency pins remain unchanged.

## API migration

The basic `PlaneCapacitor.voltage`, `field`, `voltage_eq_field_mul_gap`,
`DielectricScaling` and `voltage_of_dielectric_scaling` remain independent of
breakdown and retain their names. The six breakdown declarations moved from
namespace `PlaneCapacitor` to `BreakdownSpec` in `DielectricBreakdown.lean`:
`breakdownVoltage`, `Admissible`, `field_le_iff`, `chargeAtLimit`,
`voltage_at_limit`, `admissible_at_limit`. Their receiver is now the optional
specification, whose type indexes the capacitor.

The final candidate still has judgment
`Candidate.solution data source : TrustedPhysicsProblem data`. The trusted
proposition's meaning is unchanged: two attained maxima and the strict glass
margin. Its syntax now refers to explicit breakdown specifications.
`MaximumVoltage` is unchanged. No dependency pins, P01/P02 APIs or mutation cases
were changed by this refactor.
