# Constant acceleration on upstream Physlib particles

`ConstantAcceleration.lean` imports
`Physlib.ClassicalMechanics.PointParticle.Basic`. Its objects are upstream
`ReferenceFrame.Particle` values, with upstream derivative-based `pos`, `velocity`
and `acceleration`. There is no parallel particle structure.

For any spatial dimension d, inertial frame, particle p and frame vector a:

```lean
HasConstantAcceleration p a := ∀ t, p.acceleration t = a
```

The API proves:

- `HasConstantAcceleration.hasDerivAt_velocity`: velocity has derivative a;
- `velocity_eq`: `v(t) = v(t₀) + (t-t₀) • a`;
- `position_eq`: `x(t) = x(t₀) + (t-t₀) • v(t₀) + ((t-t₀)^2/2) • a`;
- `velocity_sub`: the corresponding velocity difference;
- `velocity_eq_of_zero`: zero acceleration implies constant velocity.

The proofs subtract the proposed linear/quadratic terms and apply Mathlib's
`is_const_of_deriv_eq_zero`. The second derivative need not be continuous:
upstream Particle's differentiability of position and velocity suffices. The
current API assumes the acceleration relation on all real frame-time coordinates;
an interval-local version would require explicit interval hypotheses and is
future work. Positions here are frame-relative vector coordinates, not sums of
affine world-space points. No units, dimension three, vertical direction, force
law or gravity value is hard-coded.

These design and integration notes are not part of any problem's trusted source
assumptions. P08 supplies `HasConstantAcceleration` explicitly as a model premise;
the generic kinematics laws are proved from that premise. The library examples
are consistency witnesses, not source data for the rocket problem.

## Potential upstream Physlib layering

```text
Physlib.ClassicalMechanics.PointParticle.Basic
                    ↓
Physlib.ClassicalMechanics.ConstantAcceleration       (proposed)
                    ↓
Physlib.ClassicalMechanics.UniformGravity              (optional future layer)
                    ↓
problem/system-specific applications
```

Constant acceleration is generic kinematics, independent of a force's origin.
A future UniformGravity layer should supply real physical content such as
uniform force `m • g` plus Newton II implying acceleration g; simply renaming
`HasConstantAcceleration p g` would not justify another module. No UniformGravity
module is added now. Vertical projectiles, highest points and rockets belong
above these layers, never in the generic module.

This implementation is an **upstream-oriented prototype**, not a claim of an
accepted upstream API. Namespaces, inertial-frame typeclass conventions,
frame-time coordinate versus affine Time interfaces, and interval-local scopes
would need maintainer review. The current use of upstream frame-vector topology
and derivative instances also warrants API review. Further applications should
validate the interface before contribution.

Future textbook uses include free fall, vertical launch, general projectile
motion, constant-force motion, uniform-electric-field motion, turning points,
time to apex and maximum height. Only the kinematics is implemented: additional
force/field laws in those applications would still need premises or proofs.

## Focused library checks

`ConstantAccelerationExamples.lean` builds actual upstream positive-mass
particles with quadratic trajectories and verifies their derivative-based
constant acceleration. Its helper constructors are consistency witnesses, not a
new mechanics ontology or production particle API. Examples check arbitrary
initial time, velocity difference, quadratic displacement, zero acceleration,
zero initial velocity, stationary motion, and explicit dimensions 4 and 0.
P08's verification reuses these witnesses; its source model does not assume a
quadratic position formula.

```bash
lake env lean LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/ConstantAcceleration.lean
lake env lean LeanVerificationDemo/PhyslibTemp/ClassicalMechanics/ConstantAccelerationExamples.lean
```
