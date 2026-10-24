# Finite-system impulse–momentum prototype

[ImpulseMomentum.lean](ImpulseMomentum.lean) supplies an arbitrary finite-index,
complete real normed-vector-space interface. It fixes neither dimension nor
force law. It complements upstream trajectories rather than defining another
particle ontology.

## Upstream reuse and the current interface boundary

The pinned `Physlib.ClassicalMechanics.PointParticle.NewtonianSystem.Basic`
contains actual formal particle/system momentum definitions, Newton II and
Newton III as system fields. It has no summed momentum-derivative, impulse or
event-limit theorem. Two adapters use those definitions directly:

- `newtonian_particle_momentum_hasDerivAt` derives each upstream particle's
  momentum derivative from derivative-based velocity and system Newton II;
- `newtonian_internal_force_sum_zero` derives cancellation from the upstream
  internal-force multiset's reversal invariance, preserving multiplicities.

`MomentumBalance p internal external` is a smaller coordinate interface:

```text
HasDerivAt (p i) (external i t + Σ j, internal i j t) t
internal i j t = -internal j i t
```

It states Newton II in momentum form and pairwise Newton III, not total momentum
conservation. The internal self-force entries are zero by antisymmetry. Missing
pairs can be represented by zero. It is appropriate for duration-indexed
regularizations whose forces may grow without bound as duration shrinks.

P08 uses this indexed interface directly. The two upstream adapters are checked
integration points, **not** a complete adapter constructing `MomentumBalance`
from a `NewtonianSystem`. That target/source aggregation adapter remains future
work. P08 does not claim to construct upstream fragment position trajectories,
derive every Newton-II input from a force potential, or model breakup topology.

## Proven API

For `h : MomentumBalance p internal external`:

- `h.internal_sum_zero t`: `Σ i, Σ j, internal i j t = 0`;
- `h.total_hasDerivAt t`: derivative of `Σ i, p i t` is `Σ i, external i t`;
- `h.total_change_eq_integral a b hint`: total momentum difference equals the
  interval integral of net external force, given its interval integrability.

The proofs use finite sums and Mathlib's fundamental theorem of calculus.
Individual internal forces need not have a uniform bound across a family, nor
need their impulses vanish. Only their **sum** cancels.

`constant_impulse force t₀ ε` proves the integral equals `ε • force`.
`constant_impulse_tendsto_zero force t₀` proves its limit is zero along
`𝓝[>] (0 : ℝ)`. Finite positive duration with nonzero force gives a nonzero
impulse. `continuous_impulse_tendsto_zero` handles continuous time-dependent
forces by reusing Mathlib's `intervalIntegral.continuous_primitive`, specialized
to a fixed lower endpoint and a shrinking upper endpoint. Constant force is
its corollary. Local bounded/integrable variants remain future interface work.

`event_momentum_eq_of_impulse_limit` proves `after = before` from:

1. `endpoint ε - before = impulse ε` for positive ε;
2. `endpoint ε → after` as ε → 0⁺;
3. `impulse ε → 0` as ε → 0⁺.

It uses uniqueness of limits. Endpoint convergence and the finite-duration
force model are explicit hypotheses; the theorem does not establish the
existence of a regularization for every real physical interaction. In
applications, derive the finite balance with `total_change_eq_integral`, rather
than supplying the desired event equality as an input.

The differential interface currently holds on all real elapsed-time coordinates,
which simplifies FTC. An interval-local interface would weaken this regularity
requirement and is future API work.

## Reusability and possible upstream hierarchy

This is an **upstream-oriented prototype**, requiring maintainer/API review and
further use cases before contribution. It can support interacting-body impulses,
short-contact collisions, recoil, and constant-force momentum-transfer problems.
It contains no application-specific object or conservation axiom.

```text
Physlib PointParticle / Force / NewtonianSystem
                        ↓
Physlib ClassicalMechanics.ImpulseMomentum (possible future layer)
  summed Newton II/III → finite impulse balance → event limits
                        ↓
interaction / collision / breakup applications
```

The separate `PointParticle → ConstantAcceleration → optional UniformGravity`
branch supplies kinematic states. Applications can combine the two branches.
No UniformGravity or general event ontology is introduced here.

## Independent checks

[ImpulseMomentumExamples.lean](ImpulseMomentumExamples.lean) constructs a
two-body force/momentum model with nonzero internal forces, checks their
cancellation and the finite-duration external impulse, checks a nonzero finite
impulse versus the zero-duration right limit, a nonconstant continuous force,
dimension four and zero force. These checks do not depend on source-problem data.

These design notes are not extra trusted assumptions. The physical inputs live
in the explicit force-balance and application model hypotheses.
