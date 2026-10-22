# P05 — Why does a climbing man's ladder reach a slipping threshold?

Source problem **108**, Classical Mechanics. Source problem, supplied printed-solution
explanation and qualitative answer: [source.jsonl](source.jsonl).
[Physlib audit](PHYSLIB_AUDIT.md) · [Classification](CLASSIFICATION.md).

## Source and figure provenance

> A man climbs up a ladder leaning against a smooth vertical wall.
> The ladder begins to slip only when the man reaches a certain height. Why?

Fig. 311 is a **solution-side explanatory diagram** used to disambiguate the force
directions, geometric labels and moment arms appearing in the printed solution.
It is not part of the trusted problem statement. Unlike P04, there is no trusted
`diagram_caption` or image-derived topology input. No new figure is reconstructed.
The chosen coordinates implement the physical idealizations and interpretation
of the source solution; the image is not machine-readable evidence for Lean.

The source neglects ladder weight for simplicity. We retain that approximation.
The source friction coefficient k is written μ internally. G is the man's
**weight in newtons**, not gravitational acceleration.

## Physical data and abstraction level

`LadderData` supplies only L > 0, G > 0, μ ≥ 0 and 0 < α < π/2. There is no numerical
SourceData record because the source is qualitative; no reaction, monotonicity or
threshold conclusion is supplied as data. Geometry stays fixed when comparing
quasistatic positions, and the man stands at AO = s with 0 ≤ s ≤ L.

Working in a fixed inertial Cartesian frame, put O = (0,0), x away from the wall
and y upward. The wall is to the left. The acute inclination α is measured above
the horizontal direction toward the wall:

```text
C = (−L cos α, 0)
B = (−L cos α, L sin α),       CB = H = L sin α > 0
A = (−s cos α, s sin α),       AO = s.
```

The straight-line coordinate parametrization supplies the elementary projection
geometry: the man's horizontal moment arm has magnitude s cos α. We do not build
a Euclidean-angle object and prove the projection from a separate diagram.

The four forces on the modeled body, using actual stable Physlib
`ReferenceFrame.Force` values, are:

| Force | Components (N) | Application point relative to O (m) |
| --- | --- | --- |
| Smooth-wall normal | (N1,0) | B |
| Floor normal | (0,N2) | O |
| Floor friction | (−Ffr,0) | O |
| Man's weight | (0,−G) | A |

There is no wall tangential force and no ladder-weight contribution. Both support
reactions must be nonnegative in admissible equilibrium. Unknown Ffr is a signed
coordinate before equilibrium is solved; for s ≥ 0 the proof shows Ffr ≥ 0.

Physlib's frame vector carries frame information but **does not carry physical
dimension tags**. The surrounding model fixes SI coordinates: m for positions,
N for forces, N m for moments, radians for α, and dimensionless μ. This follows
the upstream mechanics convention, not a new dimensionful force implementation.

## Reused versus added mechanics

Stable Physlib provides real Force/frame/vector infrastructure. Its general
rigid-body force/torque equations in the pinned `RigidBody/Basic.lean` are
`InformalLemma` metadata, not formal proofs. Pendulum torque is formal but is
specific to the pendulum; static contact/friction relations were not found.

Two small reusable modules were added:

- `PhyslibTemp/ClassicalMechanics/PlanarStatics.lean`: signed planar moment using
  Mathlib's cross product, its coordinate formula, and an inertial Cartesian
  finite-force static-balance predicate.
- `PhyslibTemp/ClassicalMechanics/StaticFriction.lean`: admissible and saturated
  Coulomb static-friction relations, independent of ladders.

No `Ladder` type or source label is exported into PhyslibTemp. There is no change
to capacitor APIs, existing demos, dependency pins or the verification runner.

The formalization **adopts zero net force and zero moment as a static model**.
It applies that model to the explicit four forces and derives the source scalar
relations. It does not construct a full rigid-body contact-mechanics system and
derive its equilibrium from formal Newton-Euler differential equations.

## Textbook route and derived source equations

```text
force equilibrium → N2 = G, Ffr = N1
moment balance about O → N1 H = G cos α s
→ N1 = Ffr = G cos α s / H
→ required friction increases with s
→ maximum available static friction is reached.
```

`Candidate.equilibrium_iff` establishes the first two lines by evaluating force
sums and moments, not by storing the source equations as assumptions. The reusable
moment is `(r × F)z = rx Fy − ry Fx`: the wall contributes −H N1, the man's weight
contributes +G s cos α, and both floor forces have zero moment about O.
Thus the source's equation `N1 * CB = G * cos(alpha) * AO` is a derived specialization
of the minimal moment model plus the supplied coordinate geometry.

`Candidate.reactions_required` proves the reactions are forced by equilibrium.
`balancingReactions` and `balancing_equilibrium` construct balancing forces; a
separate check determines whether their friction is physically available.

## Static friction and “begins to slip”

The reusable relation is precisely:

```text
StaticFriction μ N Ft := 0 ≤ μ ∧ 0 ≤ N ∧ |Ft| ≤ μ N
LimitingStaticFriction μ N Ft := 0 ≤ μ ∧ 0 ≤ N ∧ |Ft| = μ N.
```

Static friction is **not always μN**. It adjusts below the threshold; equality
means limiting friction. The inequality includes its boundary, so limiting
static equilibrium is admitted. This models a marginal threshold, not a proof
that motion must already occur at equality. This makes the threshold convention
more precise than the printed source's onset wording.

“Begins to slip” is interpreted as **loss of an admissible static equilibrium
satisfying the static-friction bound above the threshold**. We do not prove an
acceleration, solve an initial-value problem, or assert any post-slip trajectory.

## Lean result and strengthening

Define

```text
requiredFriction(s) = G cos α s / H
criticalPosition = μ H / cos α.
```

The final candidate proves:

1. Required friction is strictly increasing (so also nondecreasing).
2. For every position on the ladder, an admissible static equilibrium exists
   **iff** s ≤ criticalPosition. Both directions are proved, including explicit
   construction of support forces below the threshold.
3. Required friction at criticalPosition is exactly μG, hence limiting friction.
4. If the critical position lies on the ladder, that threshold is admissible.
5. At any on-ladder position above it, no admissible static equilibrium exists.

The explicit formula for criticalPosition is a **derived strengthening**, not part
of the printed qualitative answer. Its nonnegativity is proved. A finite ladder
need not reach the threshold: for sufficiently large μ it lies beyond the top.
The formalization therefore does not claim that every ladder/μ combination slips
before the man reaches the top. Saturation at the formula is algebraic; physical
attainability is conditional on `OnLadder data (criticalPosition data)`.

The strict-monotonicity theorem extends the formula to all real s; physical uses
are restricted by `OnLadder`. No output conclusion is an input field.

```lean
Candidate.solution data : TrustedPhysicsProblem data
```

`Verify.lean` provides positive-L/G, acute-angle, nonnegative-μ example parameters
and proves that every admissible parameter choice has a static state at s = 0.
Thus the physical domain and its equilibria are nonempty. `PairingWalkthrough.lean`
prints the checked declarations and the final theorem's axioms. Annotated comments
explain the same checked proof but are not themselves machine-verified.

## Run

```bash
lake build
python3 scripts/verify.py P05
# Or select source number:
python3 scripts/verify.py 108
```

Mutations are explicitly SKIPPED initially, following the existing runner behavior.
The audit records exact upstream declaration signatures and search evidence.

## Validation results

- `lake build`: PASS (3375 jobs); module-system interoperability warnings remain.
- P05: source compilation, explicit proposition/proof pairing and annotated proof PASS;
  mutations explicitly SKIPPED.
- P04 and P03: PASS with their existing mutation stages SKIPPED.
- P02, P01 and M00: PASS including all six existing mutation cases each.
- Both new PhyslibTemp mechanics modules also compiled directly with `lake env lean`.
- Final P05 theorem axioms: only `propext`, `Classical.choice`, `Quot.sound`.
- Satisfiable parameter example and admissible bottom-contact state: checked in `Verify.lean`.
- `git diff --check`: PASS. Dependency pins, capacitor APIs and previous demo files unchanged.

Validation reused the installed toolchain and local dependency caches; a separate
empty-cache setup was not tested.
