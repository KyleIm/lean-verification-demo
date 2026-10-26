# P10 pinned-library audit

Inspected the repository-selected versions, with no dependency changes:

- Physlib `96a6bc5e3c50a2856c64a6c9951c0a1c23790b58`;
- Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`;
- Lean 4.35.0.

## Search and representation decision

```bash
rg -n -i '(mean|average).?(speed|velocity|acceleration)|(speed|velocity|acceleration).?(mean|average)' Physlib PhyslibAlpha
rg -n 'integral_add_adjacent_intervals|integral_congr|IntervalIntegrable.congr|integral_piecewise' Mathlib/MeasureTheory/Integral/IntervalIntegral
rg -n 'integral_id|integral_const_mul|integral_eq_sub_of_hasDerivAt' Mathlib/Analysis/SpecialFunctions/Integrals/Basic.lean Mathlib/MeasureTheory/Integral/IntervalIntegral
rg -n 'average|piecewise' Mathlib/MeasureTheory/Integral/Average.lean Mathlib/Data/Set/Piecewise.lean Mathlib/Topology/Piecewise.lean
rg -n 'centimeters|seconds' Physlib/SpaceAndTime
```

No directly applicable formal mean-velocity/mean-acceleration API was found by
the whole stable/Alpha searches. The one mean-pattern hit is the FreeParticle
module's sentence “zero acceleration means velocity is constant”, not a definition
of an average. Physlib does have derivative-based velocity and
acceleration for particles and Time/Space derivative APIs, but the source gives
v(t) directly. Constructing a particle or a force law would add irrelevant input.
Related spatial integral hits in gradient/curl modules do not supply this graph
reasoning. No Alpha module is imported.

Mathlib already supplies all required integration. P10 uses real coefficients
and local standard mean definitions, plus a small upstream-unit layer. No new
PhyslibTemp graph, motion, average or unit API is needed.

## Mathlib declarations reused

Paths are relative to Mathlib. Types below specialize generic normed-valued
statements to the real-valued function used here.

| File / declaration | Used type or role |
| --- | --- |
| `MeasureTheory/Integral/IntervalIntegral/Basic.lean`, `intervalIntegral` | Real velocity function, volume measure and oriented endpoints produce a real interval integral |
| Same file:513, `Continuous.intervalIntegrable` | `Continuous f → ∀ a b, IntervalIntegrable f volume a b` |
| Same file:117, `IntervalIntegrable.congr` | Transfers interval integrability through equality on `Set.uIoc a b`; P10 restricts its proved closed-segment equality |
| Same file:209, `IntervalIntegrable.trans` | Integrability on a..b and b..c gives integrability on a..c |
| Same file:1077, `intervalIntegral.integral_congr` | `Set.EqOn f g (Set.uIcc a b) → (∫ t in a..b, f t) = ∫ t in a..b, g t` |
| Same file:1095, `intervalIntegral.integral_add_adjacent_intervals` | Given integrability on both intervals, `(∫ a..b, f) + (∫ b..c, f) = ∫ a..c, f` |
| `MeasureTheory/Integral/IntervalIntegral/FundThmCalculus.lean:1148`, `intervalIntegral.integral_eq_sub_of_hasDerivAt` | Given `∀ t ∈ Set.uIcc a b, HasDerivAt F (f t) t` and `IntervalIntegrable f volume a b`, proves `∫ t in a..b, f t = F b - F a` |
| `Analysis/Calculus/Deriv/Mul.lean`, `HasDerivAt.const_mul` | Differentiation of constant-scaled terms in the affine antiderivative |
| `Analysis/Calculus/Deriv/Pow.lean`, `hasDerivAt_pow` | Exact derivative of the quadratic antiderivative term |
| Algebra/order API, `abs_of_nonneg` | `0 ≤ v → |v| = v`, used with the graph's proved nonnegativity |

Also inspected `Analysis/SpecialFunctions/Integrals/Basic.lean:201`
(`intervalIntegral.integral_id`), constant/affine integral arithmetic and
`Set.piecewise`/continuous-piecewise APIs. FTC with an explicit quadratic
antiderivative gives the trapezoid formula directly, while adjacent-interval
addition makes all eight source pieces visible. Ordinary conditional selection
is sufficient; no general piecewise-motion object is introduced.

`MeasureTheory/Integral/Average.lean:279` has actual formal
`MeasureTheory.average`, defined via a normalized measure. It is not missing.
Using that broader API would require a restricted-measure/interval-length bridge
without simplifying this fixed zero-start-time problem. P10's local
`meanVelocity T := displacement T / T` is the requested standard time average;
it is not exported as a duplicate general library concept. Mean acceleration
is the local endpoint difference divided by T, so differentiability at the
polyline corners is unnecessary.

## Physlib quantity and unit declarations reused

Paths below are relative to Physlib.

| File / declaration | Type / use |
| --- | --- |
| `Units/Dimension.lean`, `Dimension B` and its commutative-group instance | Existing multiplicative physical dimensions, including products and quotients |
| `Units/LTMCTDimensionBase.lean`, `Dimension.L𝓭`, `T𝓭` | Length/time generators of `Dimension LTMCTDimensionBase` |
| `Units/WithDim/Basic.lean:33`, `WithDim` | `{B} [DimensionBasis B] (d : Dimension B) (M : Type) : Type`; local aliases use M = ℝ |
| Same file, heterogeneous `HDiv` instance | `HDiv (WithDim d1 ℝ) (WithDim d2 ℝ) (WithDim (d1*d2⁻¹) ℝ)` |
| Same file:356, `WithDim.cast` | Retags a quantity only with proof of equal dimension indices |
| Same file:40, `WithDim.ext` | Equality of real coordinates proves equality at a fixed dimension |
| `Units/Basic.lean:254`, `LTMCTUnitChoices.SI` | Existing typed coherent unit choice; P10 changes only its length slot |
| `SpaceAndTime/Space/LengthUnit.lean:104`, `LengthUnit.centimeters` | Actual length unit `scale ((1/10)^2) meters` |
| `SpaceAndTime/Time/TimeUnit.lean:66`, `TimeUnit.seconds` | Actual second unit; retained by graphUnits |
| `Units/Basic.lean:382/435`, `Dimensionful`, `CarriesDimension.toDimensionful` | Existing unit-dependent quantity representation and unit-choice equivalence |

`Units/WithDim/Velocity.lean` contains documentation but no actual named velocity
declaration at this pin. `DimSpeed` in `WithDim/Speed.lean` is a genuine named
unit-dependent nonnegative-speed type, but direct real arithmetic here is simpler
with the existing real-valued WithDim specialization. No new structures are
needed. The unit layer is source-native cm, s, cm/s and cm/s²; it need not convert
to SI metres to prove the source values.

P10 checks velocity·time = length, length/time = velocity and velocity/time =
acceleration, then lifts the same four scalar results to typed quantities and
initializes reported quantities at the caption's cm-second unit choice. No
mass/force/energy or full dimensionful integration framework is introduced.

## Trust and source-solution audit

Trusted geometric data is limited to the axes/units, the nine vertices,
straight connections and two marked times. `figure_caption.txt` contains no
solution areas or average values. The source image was not available; the user
explicitly authorized caption-only reconstruction, and no original-image
verification or independent source lookup is claimed.

The actual function interpolates the caption points on every closed segment.
Candidate derives integrability, segment areas, interval sums, nonnegativity,
path/displacement equality and all averages. No area, stopping law, unknown
trajectory or final numerical result is an external assumption. The local
kinematic interpretation defines displacement as ∫v and path as ∫|v|; the
equality is proved only on this nonnegative graph. The source solution's 10.5,
25 and four means are checked targets, not trusted geometric inputs.

The SVG generator has only the geometry JSON as input and uses no Lean/source
solution files or source images. Rendering choices are distinguished from
trusted plotted coordinates. This is a small graph/integral formalization, not
a new mechanics or graph ontology. PhyslibTemp is unchanged.
