# Ideal specular plane-mirror semantics

`Reflection.lean` supplies reusable geometric-optics semantics on top of Mathlib
orthogonal reflection. P11 motivated the extraction, but the API has no object,
screen, ray obstruction, illumination channel, shadow, source angle or regime.

## Physical and mathematical boundary

A `PlaneMirror E` has a unit normal in a real inner-product space. The nonzero
normal defines a genuine tangent hyperplane `(ℝ ∙ normal)ᗮ`; an arbitrary
reflecting subspace is not silently labeled a physical plane mirror. No
finite-dimensional or complete-space hypothesis is needed. The normal's sign
only chooses an orientation. The law acts on directions; a mirror position and
the corresponding affine plane/ray intersections belong to the application.

`PlaneMirror.reflect` **models** an ideal stationary specular plane mirror by
applying Mathlib's `Submodule.reflection` in that tangent. This identification is
the physical law adopted by the module. The following consequences are proved:

| Declaration | Meaning |
| --- | --- |
| `normal_ne_zero` | Unit normal is nonzero |
| `reflect_eq` | `reflect v = v - (2 * inner ℝ normal v) • normal` |
| `tangent_component` | Tangential orthogonal projection is preserved |
| `normal_component` | Signed normal component reverses |
| `norm_reflect` | Direction magnitude is preserved (speed too if v is a velocity) |
| `reflect_reflect` | Reversing the reflection returns the input |
| `reflect_tangent` | A tangential/grazing direction is unchanged |
| `reflect_normal` | A normally incident direction reverses |
| `incidence_reflection_cosine` | Equal absolute normal-component/norm ratios |
| `PlaneMirror2D.horizontal_reflect` | `(vx,vy)` maps to `(vx,-vy)` |

For nonzero directions and a unit normal, the ratio in
`incidence_reflection_cosine` is the cosine of the unsigned angle to the normal
line. Equal ratios, normal reversal and unchanged tangential projection give
the usual incidence-angle-equals-reflection-angle law. The API uses this vector
form rather than introducing additional angle conventions. The identity also
holds algebraically at zero, where no physical ray angle is asserted.

The module does not derive mirror behavior from Maxwell equations or model
Fresnel coefficients, polarization, diffraction, finite apertures, moving
mirrors or radiometry. It has no numerical constants or unit framework.

## Reuse and upstream path

The pinned Physlib optics tree has no applicable formal specular-mirror API;
its placeholder and unrelated harmonic-wave material do not supply this law.
Mathlib provides the established mathematical operation, not its optical
interpretation. The new layer adds that interpretation and a physics-facing
theorem surface without reimplementing the linear algebra.

Potential independent uses include a single reflected-ray direction problem,
normal or grazing incidence, mirrors with other orientations, two-mirror
direction changes, and planar reflected-path constructions. `ReflectionExamples.lean`
checks downward/upward horizontal reflection, a vertical mirror, grazing/zero
directions and arbitrary-space invariants without importing P11.

Possible future dependency structure:

```text
Mathlib inner-product orthogonal reflection
        ↓
Physlib.Optics.Reflection (possible future contribution)
        ↓
mirror/ray systems and problem-specific geometry
```

This PhyslibTemp implementation is an upstream-oriented prototype. Naming,
affine-plane integration and namespace conventions should be discussed with
Physlib maintainers before upstreaming. It is not a claim that the pinned
Physlib already contains this physical semantics.
