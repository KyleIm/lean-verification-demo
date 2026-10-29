# P12 pinned-library and problem–solution audit

## Exact revisions and searches

Inspected repository-pinned Physlib
`96a6bc5e3c50a2856c64a6c9951c0a1c23790b58` and Mathlib
`56a005855ea17e0b0958f73ec801ae140b0a1679` (Lean 4.35.0).
No dependency pin changed. Searches/readings used the installed pinned sources:

```bash
rg -ni '\bfriction\b|braking|stopping.distance|constant.acceleration|uniformly.accelerat' Physlib PhyslibAlpha
rg -n 'Particle|velocity|acceleration|newton|kineticEnergy' Physlib/ClassicalMechanics/PointParticle/Basic.lean Physlib/ClassicalMechanics/PointParticle/NewtonianSystem/Basic.lean Physlib/ClassicalMechanics/FreeParticle/Basic.lean
rg -ni 'kilomet.*hour|km.?h' Physlib/Units
rg -n 'WithDim|HMul|HDiv|def cast' Physlib/Units/WithDim/Basic.lean
rg -n 'floor_eq_iff' Mathlib/Algebra/Order/Floor/Ring.lean
```

The first whole-tree search found no applicable stable braking, stopping-distance
or friction API. The Alpha friction hit is the documentation description of
`PhyslibAlpha/ClassicalMechanics/NortonDome/Basic.lean` as motion **without**
friction; it is not a braking-friction law. No Alpha declaration or informal
statement is used as a formal theorem. This is a claim about the applicable
API in this revision, not absence of all mechanics.

## Upstream mechanics inspected/reused

Paths are relative to Physlib. Namespace in the first entries is
`ClassicalMechanics.ReferenceFrame` (variable `frame : ReferenceFrame d`):

| Source location | Declaration and type/fields | P12 use |
| --- | --- | --- |
| `ClassicalMechanics/PointParticle/Basic.lean:47` | `Particle frame`; `mass : {m : ℝ // 0 < m}`, `pos : ℝ → frame.Vector`, twice-differentiability in inertial frames | One braking trajectory and positive mass |
| Same file:64 | `Particle.velocity : ℝ → frame.Vector := deriv particle.pos`, with differentiability Fact | Projected scalar velocity |
| Same file:72 | `Particle.acceleration : ℝ → frame.Vector := deriv particle.velocity`, with differentiability Facts | Scalar Newton II and constant deceleration |
| `ClassicalMechanics/Force.lean:45,74` | `Force (frame) (Object)` and `netForce` | Inspected generic force infrastructure; no specific braking law |
| `ClassicalMechanics/PointParticle/NewtonianSystem/Basic.lean:53–67` | `NewtonianSystem d`, inertial frame, particles/forces; `newton_second_law : ∀ particle, netForce ... = particle.1.mass • particle.1.acceleration` | Formal Newton II exists; a full force-multiset system adds no benefit for this scalar single-run proof |
| `ClassicalMechanics/FreeParticle/Basic.lean:130–184` | `NewtonsSecondLaw`, `accel_zero`, constant-velocity consequence | Formal zero-force results, insufficient for nonzero braking deceleration |

Scalar normal balance, saturated braking force and scalar Newton II are explicit
P12-local model inputs. P12 does not claim to derive road support/contact laws
from a complete Newtonian-system or tyre model.

## Existing PhyslibTemp/local code audited

`PhyslibTemp/ClassicalMechanics/ConstantAcceleration.lean`, namespace
`LeanVerificationDemo.PhyslibTemp.ClassicalMechanics`, supplies actual formal
declarations for an upstream inertial `frame.Particle`:

```lean
HasConstantAcceleration particle a : Prop := ∀ t, particle.acceleration t = a

HasConstantAcceleration.velocity_eq (h) (t₀ t : ℝ) :
  particle.velocity t = particle.velocity t₀ + (t-t₀) • a

HasConstantAcceleration.position_eq (h) (t₀ t : ℝ) :
  particle.pos t = particle.pos t₀ + (t-t₀) • particle.velocity t₀ +
    ((t-t₀)^2/2) • a
```

P12 reuses both laws. It projects them into a one-dimensional braking coordinate
and eliminates duration using final rest; `v²=2as` is **derived**, not a premise.
Fixed local friction and scalar Newton II derive the constant-acceleration
premise. The globally smooth particle is a reference continuation; only the
braking interval has physical meaning.

Also read:

- P09 `Problem.lean` and `Candidate.lean`: horizontal normal balance, sliding
  friction, Newton II, the one-dimensional projection/time-elimination argument
  and elastic-impact assumptions. P09's helpers have its fixed local frame and
  its problem module imports source/collision machinery. Rather than importing
  those assumptions or redesigning P09, P12 uses short local projections of the
  generic ConstantAcceleration laws. There is no new reusable-module gap here.
- `StaticFriction.lean`: `StaticFriction μ N Ft := 0≤μ ∧ 0≤N ∧ |Ft|≤μ*N`;
  `LimitingStaticFriction` replaces the bound by equality. These are static
  admissibility, not a moving vehicle's braking dynamics.
- `PlanarStatics.lean`: planar moment and equilibrium snapshots, not needed.
- `ImpulseMomentum.lean`: finite-system/event impulse semantics, not needed.

No new friction, table-analysis, vehicle or pavement library is added.

## Exact upstream unit/dimension APIs

P12 uses the default LTMCT basis, sufficient for these mechanical quantities.
The necessary APIs are in `Physlib/Units`, not the older suggested
`Physlib/Foundations/SI.lean` / `SIDeriv.lean` paths, which do not exist in this
pinned tree. P09 Units was inspected as a precedent without importing PuckData.

| Source location | Exact relevant type | Use |
| --- | --- | --- |
| `Units/WithDim/Basic.lean:33` | `WithDim {B} [DimensionBasis B] (d : Dimension B) (M : Type)` with `val : M` | Tagged real length, velocity, acceleration and dimensionless coefficient |
| Same file:248 | `HMul (WithDim d₁ ℝ) (WithDim d₂ ℝ) (WithDim (d₁*d₂) ℝ)` | v×v and g×s |
| Same file:318 | `HDiv (WithDim d₁ ℝ) (WithDim d₂ ℝ) (WithDim (d₁*d₂⁻¹) ℝ)` | Dimensionful division |
| Same file:356 | `WithDim.cast (m : WithDim d M) (h : d=d₂) : WithDim d₂ M` | Cast only with proved coefficient dimension equality |
| `Units/LTMCTDimensionBase.lean:273` | `Dimension.L𝓭 : Dimension LTMCTDimensionBase` (also T𝓭 for time) | L/T and L/T² |
| `Units/Basic.lean:254,382` | `LTMCTUnitChoices.SI`; `Dimensionful (M) := Subtype (HasDimension (M:=M))` | SI initialization and unit-dependent quantities |
| `Units/Basic.lean`, namespace `CarriesDimension` | `toDimensionful SI : M ≃ Dimensionful M` | Distance/gravity initialized in SI; inverse equivalence recovers coordinates |
| Same file:424 | `Dimensionful.smul_apply (a : ℝ≥0) (f : Dimensionful M) (u) : (a • f).1 u = a • f.1 u` | Scale named speed quantity by every table speed |
| `Units/WithDim/Speed.lean:24` | `DimSpeed := Dimensionful (WithDim (L𝓭*T𝓭⁻¹) ℝ≥0)` | Existing named speed quantity |
| Same file:45 | `DimSpeed.oneKilometerPerHour : DimSpeed` | Actual km/h unit |
| Same file:72 | `DimSpeed.oneKilometerPerHour_in_SI : oneKilometerPerHour SI = ⟨5/18⟩` | Essential conversion reused directly |
| `SpaceAndTime/Space/LengthUnit.lean:128` | `LengthUnit.kilometers := scale (10^3) meters` | Inspected underlying kilometre convention |
| `SpaceAndTime/Time/TimeUnit.lean:93,110` | `TimeUnit.hours := scale (60*60) seconds`; `hours_div_seconds : hours/seconds = 3600` | Inspected underlying hour convention |

`Units.lean` proves `(L/T)² = (L/T²)*L`, hence
`velocity²/(acceleration*length)=1`. It converts every source speed through the
named km/h quantity, then proves the real-coordinate typed coefficient expression
equals the dimension-tagged scalar `tableEstimate`. It does not rerun 70 table
checks in dimension-indexed quantities. Dimensional correctness remains separate
from the physical-law assumptions.

## Rounding/data audit and open specification

The source table is represented explicitly as seven vectors of ten exact real
decimal literals, plus the ten speed headers. No data are smoothed or generated
from the supplied coefficients. g=49/5 is a numerical modeling specialization,
not a number printed in the supplied table/solution excerpt.

Mathlib `Algebra/Order/Floor/Ring.lean:139` supplies the formal theorem:

```lean
Int.floor_eq_iff : ⌊a⌋ = z ↔ (z : ℝ) ≤ a ∧ a < z + 1
```

Candidate computes `floor(10*tableEstimate p 0+1/2)/10`, verifies the integer
floor bounds, then checks **all ten** estimates for every pavement. The exact
criterion is the tenth grid and `[c−1/20,c+1/20)`. All 70 estimates actually
lie strictly inside, so no tie convention affects these data. Uniqueness uses
integer order, exact real casts and disjoint bands. `norm_num`, `ring`,
`linarith`/`nlinarith` and `omega` produce kernel-checked proofs; no Float,
`native_decide` or new axiom is used.

The final trusted type is `∃! coeff, RoundedTable coeff ∧
PhysicalTableCompatibility coeff`. It contains no seven-value answer mapping.
The first numerical answer claims are derived in Candidate's `rounded_numerators`
and `coefficient_values`. The printed answer list stays in source.jsonl as
solution conclusions, not trusted Lean input. The physical compatibility clause
makes the final proof actually depend on the derived friction estimator.
Verification constructs a positive-mass quadratic run for **every** source cell,
without inserting a rounded answer, to check model consistency.

Raw estimates are not asserted equal across speeds. The table's printed decimal
coordinates are exact inputs to the estimate, not an assertion of a perfect
single-μ quadratic dataset. Speed independence is proved only at the requested
one-decimal resolution; no measurement-error model is invented.

## Minimum-extension decision

```text
Stable Physlib:
  ReferenceFrame.Particle and derivative-based velocity/acceleration
  WithDim / Dimensionful / SI / named km/h conversion

Existing PhyslibTemp:
  ConstantAcceleration velocity and position laws

New PhyslibTemp:
  nothing

P12-local:
  pavement categories, all table data, braking-force model/coordinate projection
  observation matching, estimator, rounding criterion and computed assignment

Derived physics / pure mathematics:
  constant deceleration, stopping relation, estimator correctness
  exact 70-cell classification, physical compatibility and unique assignment
```
