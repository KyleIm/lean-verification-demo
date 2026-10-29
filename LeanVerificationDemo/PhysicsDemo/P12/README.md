# P12 — Find friction coefficients from braking Table 1

Source problem **48**. [Source pair and Table 1](source.jsonl) ·
[Classification](CLASSIFICATION.md) · [Pinned-library audit](PHYSLIB_AUDIT.md).

## Source question vs formalized question

### BEFORE — original source problem

> The path travelled by a motor vehicle from the moment the brakes are applied until it stops is known as the braking distance. For the types of tyres in common use in the USSR and a normal air pressure in the tubes, the dependence of the braking distance on the speed of the vehicle at the beginning of braking and on the state and type of the pavement can be tabulated.

Find the coefficient of friction for the various kinds of pavement surface to an accuracy of the first digit after the decimal point, using the data in this table.

### AFTER — Lean-facing formalized problem

Find the **unique** assignment `coeff : Pavement → ℝ` on the tenth grid such
that every converted Table 1 estimate rounds to its surface's coefficient.
Also prove that every braking run satisfying the adopted mechanics and matching
a source row has a coefficient in that same band.

The exact trusted target is:

```lean
∃! coeff : Pavement → ℝ, TableSolution coeff
-- TableSolution coeff = RoundedTable coeff ∧ PhysicalTableCompatibility coeff
```

`RoundedTable` quantifies over all seven pavement constructors and `Fin 10`.
It requires `IsTenth (coeff p)` and the rounding relation for every estimate.
`PhysicalTableCompatibility` quantifies over every `BrakingRun` satisfying
`BrakingModel` and `ObservesRow`; its μ must round to `coeff p`. This second
clause makes the final theorem depend on the mechanics derivation, not only on
rational table arithmetic. `Verify.lean` constructs a physical witness for every
row, so that compatibility is not merely vacuous.

### What changed

The table's prose/categories become finite indexed data. Constant acceleration
is a **source-solution** idealization, rather than a source-stated premise.
Horizontal normal balance, saturated braking friction and scalar Newton II
form an explicit local model. A positive, fixed g is specialized to **49/5 m/s²**
for table evaluation; the supplied excerpt does not print that value. The
km/h→m/s conversion and a precise nearest-tenth convention become explicit.
The request is strengthened to uniqueness and all-ten-speed agreement, with no
claim of exact speed independence in the raw estimates.

No vehicle ontology, tyre material model or detailed braking hardware is built.
The physical representation consists of a one-dimensional upstream Particle,
positive mass, initial speed, distance, stopping duration, forces, g and μ.
The force law and idealization are not derived from tyre/contact mechanics.

## Source Table 1 — distances in metres

These are the supplied source data, reproduced without smoothing. The column
headers are initial speeds in **km/h**, not m/s. Exact terminating decimal Lean
literals represent rational real values; trailing zeros are preserved here and
in the source record as provenance, without changing numerical meaning.

| Surface / speed (km/h) | 10 | 20 | 30 | 40 | 50 | 60 | 70 | 80 | 90 | 100 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Ice | 3.9 | 15.6 | 35.3 | 62.9 | 98.1 | 141.4 | 192.6 | 251.6 | 318.2 | 393.0 |
| Dry snow | 1.9 | 7.8 | 17.6 | 31.4 | 49.0 | 70.7 | 96.3 | 125.8 | 159.1 | 196.6 |
| Wet wood block | 1.3 | 5.2 | 11.7 | 20.9 | 32.7 | 47.1 | 64.2 | 83.8 | 106.0 | 131.0 |
| Dry wood block | 0.78 | 3.1 | 7.0 | 12.5 | 19.6 | 28.2 | 38.5 | 50.3 | 63.6 | 78.6 |
| Wet asphalt | 0.97 | 3.9 | 8.8 | 15.7 | 24.5 | 35.3 | 48.1 | 62.9 | 79.5 | 98.2 |
| Dry asphalt | 0.65 | 2.6 | 5.8 | 10.4 | 16.3 | 23.5 | 32.1 | 41.9 | 53.0 | 65.5 |
| Dry concrete | 0.56 | 2.2 | 5.0 | 9.0 | 14.0 | 20.2 | 27.5 | 35.9 | 45.4 | 56.1 |

`Problem.lean` contains the same seven explicitly written vectors in
`brakingDistance : Pavement → Fin 10 → ℝ`, plus `speedKmh : Fin 10 → ℝ`.
No values are generated from the answer list or a synthetic quadratic table.

## Mechanics and the source-solution audit

The adopted horizontal-road braking model supplies:

```text
N = mg
F = μN                         (maximum braking-friction magnitude)
m a_coordinate = -F            (Newton II along the direction of travel)
initial speed v > 0
final speed = 0
travelled coordinate distance = source s > 0.
```

The source's coefficient k is written μ in the Lean model. This is saturated
braking friction, not a claim of static equilibrium while the vehicle moves. It neglects other tangential forces and keeps μ, g and mass
fixed during each observation. The source's constant-acceleration assumption is
realized through these constant forces; `constant_deceleration` derives the
existing `HasConstantAcceleration` premise from Newton II. It is not an extra
`a=v²/(2s)` input.

P12 directly reuses upstream `ReferenceFrame.Particle` and existing
PhyslibTemp `ConstantAcceleration`. Projecting its **proved** velocity and
position laws gives

```text
v(t) = v_initial - a t
s(t) = t v_initial - a t²/2
final rest → v_initial² = 2 a s
N=mg, F=μN → a=μg
→ μ = v_initial²/(2gs).
```

`braking_speed_nonnegative` proves no reversal on [0,duration], justifying the
oriented displacement as the braking path coordinate. As in P09, the smooth
particle is a mathematical reference continuation; only the braking interval
is physical. The model does not predict backward acceleration after stopping.

P09 was audited but is not imported: its local two-leg collision/source
assumptions are not reusable braking infrastructure. StaticFriction supplies a
sticking bound, not the present motion law; PlanarStatics and ImpulseMomentum
are not needed. **No new PhyslibTemp declaration is added.** A short local
projection/algebra argument is sufficient after the existing kinematics layer.

The original statement's tyre/pressure/context limitations remain source
provenance. Lean does not establish that all actual pavements/vehicles obey the
adopted idealization or that real friction is generally speed independent.

## Exact estimation, conversion and rounding

The source solution's physical rule is justified by `friction_estimator`:

```text
speedSI i = (5/18) speedKmh i
k_est(p,i) = (speedSI i)² / [2 (49/5) brakingDistance(p,i)].
```

Using the km/h numbers directly in the SI formula would multiply estimates by
(18/5)²; the conversion is explicit before squaring. All arithmetic in the Lean
proofs is exact, with `norm_num`, real/rational algebra and integer floor bounds;
there are no Float calculations, numerical tolerances or native-evaluation axioms.

`IsTenth c` means `∃ n : ℤ, c = n/10`. The exact rounding band is

```text
RoundsToTenth x c := c - 1/20 ≤ x ∧ x < c + 1/20.
```

With c on the grid this is nearest-tenth rounding, ties to the larger grid value
(toward +∞). Every one of the 70 table estimates is proved **strictly** inside
its selected band, so tie choices do not affect the answers. A generic integer-
grid argument proves different tenth values cannot share a rounded observation.

## Candidate construction and derived answer

`Problem.lean` has **no seven-value answer mapping**. The first numerical
answer claims occur in Candidate's `rounded_numerators` lemma and are proved
from data. The witness itself is an extraction algorithm:

```text
coefficient p = floor(10 * tableEstimate p 0 + 1/2) / 10.
```

It proposes a value from the first column, then accepts it only after checking
**all ten columns**. Seven named row lemmas establish 70 strict inequalities;
no speed is omitted. `coefficient_values` exposes the computed assignment:

| Pavement | Derived nearest-tenth coefficient |
| --- | --- |
| Ice | 0.1 |
| Dry snow | 0.2 |
| Wet wood block | 0.3 |
| Dry wood block | 0.5 |
| Wet asphalt | 0.4 |
| Dry asphalt | 0.6 |
| Dry concrete | 0.7 |

Uniqueness uses one shared sample to distinguish grid values; validity and
existence use all 70 entries. Thus selecting the first sample for the extraction
algorithm does not replace the full-table check. Any assignment satisfying the
specification must be this one.

The printed answers are retained in `source.jsonl` as **solution conclusions**,
not trusted Lean inputs. The computed answer equations in Candidate can be
inspected directly. This makes the distinction between an answer-bearing target
and a data/specification target explicit without claiming that the numerical
results were unknown to the formalizer.

Exact source decimals need not yield identical raw estimates at different
speeds: Verify proves that the first and last ice estimates differ. No common
exact μ is asserted to generate all ten distance values. Each row admits its
own physical run, while its estimate is classified at the requested resolution.
No measurement-error/uncertainty interval is added to the supplied table.

## Dimensional verification

`Units.lean` reuses upstream WithDim and the **existing** quantity theorem
`DimSpeed.oneKilometerPerHour_in_SI`. It converts every named km/h source-speed
quantity to the scalar SI coordinate used in `speedSI`. Distance and gravity
quantities are initialized in upstream coherent SI.

Executable checks prove:

```text
velocity² = acceleration × length                  (dimension equality)
velocity² / (acceleration × length) = 1             (dimensionless)
1 km/h = (5/18) m/s                                (upstream quantity equality)
typed coefficient expression = dimension-tagged tableEstimate.
```

The factor 2 is dimensionless. The quantity layer certifies dimension and unit
conversion, not physical truth. The mechanics proof establishes the modeled
formula, scalar arithmetic establishes the estimates and rounding, and typed
checks validate the units. Integration/table fitting is not performed inside
an invented dimension framework or repeated as 70 typed computations.

## Reviewer-facing dependency

```text
source table + SI conversion + explicit g choice
                              ↓
normal balance + saturated braking friction + scalar Newton II
→ constant deceleration → reusable velocity/position laws
→ final rest → stopping relation → friction estimator
                              ↓
first-row floor extraction → all 70 exact band checks
→ physical compatibility → unique rounded assignment
→ speed independence at the requested one-decimal resolution.
```

`CandidateAnnotated.lean` labels source table, source-solution assumptions,
reusable physics, derived physics, formalization choices and pure mathematics.
`Verify.lean` checks all-row physical satisfiability, nonzero speeds/paths,
exact decimals, tie behavior, a wrong assignment, nonconstant raw estimates,
uniqueness and the quantity/scalar bridge. Mutations are initially deferred
with an explicit empty manifest, consistent with recent demos.

```bash
lake build
python3 scripts/verify.py P12
lake env lean LeanVerificationDemo/PhysicsDemo/P12/Units.lean
git diff --check
```

Validation: `lake build` passed (3676 jobs). M00 and P01–P12 all passed;
M00/P01/P02 passed their six mutation checks each, while P03–P12 explicitly
skipped deferred empty mutation manifests. Direct `Units.lean` compilation,
source-table/Lean/README consistency, annotated-proof parity, new-file whitespace
and `git diff --check` passed. Candidate and CandidateAnnotated final axioms are
`[propext, Classical.choice, Quot.sound]`; no `sorry`, new axiom, Float or
native-evaluation proof was introduced. Dependency pins, previous demos and
PhyslibTemp modules are unchanged.
