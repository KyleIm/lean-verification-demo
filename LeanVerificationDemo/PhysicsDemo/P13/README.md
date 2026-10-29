# P13 — Fixed-string natural frequencies and the printed “2 Hz”

Source problem **650**. [Source pair](source.jsonl) ·
[Classification](CLASSIFICATION.md) · [Pinned-library audit](PHYSLIB_AUDIT.md).

## Source question vs formalized question

### BEFORE — original source problem

> Find the frequencies of natural oscillations of a steel string with a length
> of l=50 cm and a diameter of d=1 mm if the tension of the string is T=2450
> dynes. The density of steel is ρ=7.8 g/cm³.

The supplied solution states νₙ=nν₀ for n=1,2,3,... and
`ν₀ = (1/(ld)) sqrt(T/(πρ)) = 2 s⁻¹`, hence νₙ=2n s⁻¹.
The printed numerical equality is audited below rather than trusted.

### AFTER — Lean-facing formalized problem

Given positive source-native parameters and the original four numerical values,
specialize an ideal uniform string with both ends fixed. Derive the cylindrical
string formula, exact harmonics and a justified whole-Hz interpretation of the
printed fundamental. Explicitly prove that the fundamental is **not exactly 2**.

The trusted target is:

```lean
ExactSpectrum data ∧ HarmonicSpectrum data ∧
  RoundsToWholeHz (fundamental data) 2 ∧ fundamental data < 2
```

`ExactSpectrum` asks for the combined formula to be proved, and
`HarmonicSpectrum` asks for fₙ=n f₁. `SourceData` contains only the four original
number equalities. No final frequency, circular linear-density formula or
combined source formula is a trusted input field.

### What changed

The steel string is represented locally by native length, diameter, tension and
volume-density parameters, circular cross-section, linear density and a reusable
`FixedString` model. Steel contributes its given density; no steel/material
ontology or constitutive elasticity theory is constructed.

The both-fixed-end, uniform-tension/density, perfectly flexible, small-amplitude
model is the source-solution interpretation specified for this task. It is not
a claim that the original question literally describes endpoint constraints or
that bending stiffness/damping of real steel has been analyzed. Positive modes
are `n : ℕ+`; mode zero is not a physical oscillation in this API.

The symbolic physics is preserved. The printed numerical equality is corrected
to an approximation conditional on exact source values and `Real.pi`. No input
uncertainty intervals or hidden rational replacement for π are introduced.

## Reusable physics and the PDE boundary

[VibratingString.lean](../../PhyslibTemp/ClassicalMechanics/VibratingString.lean)
introduces a source-independent ideal model:

```text
length L > 0; tension T > 0; linear density μ > 0
c = sqrt(T/μ)
fₙ = n c/(2L), n=1,2,...
```

It proves speed/frequency positivity, c²=T/μ, the fundamental formula,
harmonic scaling and fₙ=c/λₙ with λₙ=2L/n. A sine profile sin(nπx/L) is shown to
vanish at both endpoints. Independent examples check a different string and
arbitrary positive modes.

These are **adopted ideal physical-model laws and their proved consequences**.
The implementation does not derive c²=T/μ from distributed force balance,
derive all eigenfrequencies from the PDE, or prove completeness of the sine
spectrum. Fixed-end sine boundary checks are not a spectral derivation.

Pinned Physlib has a formal wave equation and travelling plane-wave theorem,
plus harmonic-wave definitions. It has no applicable fixed-string quantization
or tension/linear-density API. The generic model therefore adds the missing
physical semantics without introducing a separation-of-variables framework.
[Design notes](../../PhyslibTemp/ClassicalMechanics/VibratingString.md) explain
this boundary and a possible upstream integration path.

## Cylinder geometry and density conversion

P13 keeps this material/geometry specialization local:

```text
d_cm = d_mm / 10
r = d_cm / 2
A = πr² = πd_cm²/4
μ = ρA = πρd_cm²/4.
```

The area starts from elementary circular geometry. Candidate proves its
diameter form, the linear-density formula and the square-root simplification

```text
c = (2/d_cm) sqrt(T/(πρ))
fₙ = n/(2L) c = n/(L d_cm) sqrt(T/(πρ)).
```

These are derived relations, not the source solution copied into an assumption.
The reusable module knows nothing about cylinders, steel or source constants.

## Native units and independent SI verification

The data are preserved in their original units:

| Quantity | Source-native value | Proven SI conversion |
| --- | --- | --- |
| L | 50 cm | 1/2 m |
| d | 1 mm = 1/10 cm | 1/1000 m |
| T | 2450 dyn | 49/2000 N = 0.0245 N |
| ρ | 7.8 g/cm³ = 39/5 g/cm³ | 7800 kg/m³ |

The primary scalar evaluation is coherent **mechanical CGS**: cm, g and s.
The diameter is explicitly converted before substitution. `Units.lean` uses
upstream `LTMCTUnitChoices`, named centimetres/millimetres/grams, `Dimensionful`
and WithDim. Its mechanical CGS choice leaves irrelevant charge/temperature
slots unchanged; it is not an electromagnetic Gaussian-CGS model.

No named upstream dyne was found. P13 locally defines one dyne as one coherent
CGS force and proves `1 dyn = 1 g·cm/s² = 10⁻⁵ N`. This uses upstream dimensions
and unit conversion, not a new unit framework. The same quantity infrastructure
proves all four source-to-SI conversions. Typed source-formula evaluation in SI
agrees with the primary CGS result; both systems use seconds for frequency.

The executable dimensional checks are:

```text
(M/L³) × L² = M/L                         (linear density)
[(M L/T²)/(M/L)]^(1/2) = L/T             (wave speed)
(L/T)/L = T⁻¹                            (frequency)
[(M L/T²)/(M/L³)]^(1/2) = L²/T
(L²/T)/(L×L) = T⁻¹                       (source-solution form).
```

The pinned WithDim supports product/division and rational dimension powers but
has no quantity square-root operator. Two local expression wrappers tag
`Real.sqrt` using the upstream half-power dimension and proved dimension
identities. They are dimension/value checks, not a new general square-root or
unit-covariance API. Typed bridges use the Candidate's actual physical formula.
The named upstream nonnegative `Frequency` is also reused for physical outputs.

## Exact versus approximate “2”

Exact arithmetic with the source numbers yields:

```text
f₁² = 490/(39π)
f₁  = sqrt(490/(39π))
1.9998 < f₁ < 1.9999 Hz.
```

The bounds use Mathlib's proved `Real.pi_gt_d6` and `Real.pi_lt_d6` and exact
rational inequalities, not floating-point computation. In particular `f₁ < 2`
and `f₁ ≠ 2` are proved. Exact equality to 2 would require π=245/78, which is
neither 3.14 nor 22/7. Verification also checks that those two usual rational
substitutes do not make the squared result exactly 4. The supplied material
does not establish which arithmetic approximation the author used.

The formal interpretation of the printed integer answer is **nearest whole
Hz**, with a half-open band `[k−1/2,k+1/2)` and ties toward +∞. This is an
explicit formalization choice consistent with the displayed 2, not a rounding
rule stated verbatim by the source. The tighter interval above is a derived
strengthening, not precision attributed to the textbook.

The exact natural-frequency family is therefore:

```text
fₙ = n sqrt(490/(39π)) Hz, n=1,2,3,...
```

The source's `2n Hz` is an approximation obtained from the rounded fundamental.
Candidate proves the useful error bound

```text
|fₙ − 2n| < n/5000 Hz.
```

The error grows with n. We do **not** claim that every arbitrarily high mode
rounds to 2n at unit-Hz resolution. Exact harmonic scaling and an approximate
fundamental must not be turned into an exact `fₙ=2n` theorem.

## Source-solution audit and proof dependency

- **Source facts:** the four native-unit values and the request for frequencies.
- **Source-solution physical interpretation:** ideal fixed-string harmonics;
  constant linear density/tension and negligible stiffness/damping.
- **Reusable physical model:** c=√(T/μ), fₙ=nc/(2L), positive mode indexing.
- **Derived local geometry:** circular area and volume-to-linear density.
- **Formalization choices:** coherent CGS computation, exact π, whole-Hz rounding.
- **Derived results:** combined cylinder formula, exact source spectrum,
  certified bounds, non-equality to 2 and scaled family approximation.
- **Pure mathematics:** square roots, positive cancellation, integer sine nodes,
  π bounds and rational/algebraic inequalities.

```text
native source inputs → mm-to-cm conversion → radius/area → linear density
→ reusable fixed-string law → combined source formula
→ exact π arithmetic → certified fundamental bounds → justified rounding
→ exact harmonic family and controlled 2n approximation.
```

CandidateAnnotated labels each stage. Verify constructs source inputs, checks
exact and approximate results, rejects exact 2, excludes mode zero, checks fixed
endpoints and exercises the CGS/SI and dimensional bridges. The new reusable
module has an independent examples file. Mutations are initially deferred with
an explicit empty manifest, consistent with recent demos.

```bash
lake build
python3 scripts/verify.py P13
lake env lean LeanVerificationDemo/PhysicsDemo/P13/Units.lean
lake env lean LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/VibratingStringExamples.lean
git diff --check
```

Validation: `lake build` passed (3685 jobs); M00 and P01–P13 all passed.
M00/P01/P02 passed all six mutation checks each; P03–P13 explicitly skipped
deferred empty manifests. Direct `Units.lean` and independent reusable-example
compilation, annotated-proof parity, source-only-input checks, new-file whitespace
and `git diff --check` passed. Both final Candidate theorems use only
`[propext, Classical.choice, Quot.sound]`; no `sorry`, new axiom, Float or
native-evaluation proof was added. Dependency pins and previous demos remain
unchanged. The only new reusable physics is the documented ideal string model.
