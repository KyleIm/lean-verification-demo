# P11 pinned-library and source-solution audit

## Revisions and search evidence

The repository pins Physlib **96a6bc5e3c50a2856c64a6c9951c0a1c23790b58**
and Mathlib **56a005855ea17e0b0958f73ec801ae140b0a1679** (Lean 4.35.0).
The installed checkout was inspected at these revisions; no pins were changed.
Paths below are relative to their respective library roots.

Searches included:

```bash
rg --files Physlib/Optics PhyslibAlpha
rg -ni 'specular|reflection|reflecting|mirror|angle.of.incidence' Physlib PhyslibAlpha
rg -ni 'ray|shadow|screen|geometric.optics' Physlib/Optics Physlib/Electromagnetism
rg -n 'reflection_singleton_apply|reflection_apply' Mathlib/Analysis/InnerProductSpace
rg -n 'tan_pos_of_pos_of_lt_pi_div_two|volume_Icc' Mathlib/Analysis Mathlib/MeasureTheory
```

The whole-tree reflection search was also examined for semantically equivalent
APIs. Stable hits concern crystal/quantum symmetries, time reflection or prose
such as “mirrors”; none supplies the optical mirror/ray-intersection model used
here. In particular:

- `Physlib/Optics/Basic.lean` is a **documentation-only placeholder**, with no
  formal optical law.
- `Physlib/Optics/Polarization/Basic.lean` is documentation directing the reader
  to `Physlib/Electromagnetism/Vacuum/HarmonicWave`. That field/polarization
  material does not provide this planar ray, opaque-segment or shadow API.
- `Physlib/Optics/Frequency.lean` and `Wavelength.lean` concern wave quantities,
  not a specular ray law or the required screen geometry.
- There is no `PhyslibAlpha/Optics` directory. Alpha reflection hits are
  specialized symmetry material, not an applicable optics API. No Alpha import
  or `InformalLemma` is used as a theorem.
- The local `PhyslibTemp/Optics/Refraction.lean` supports refraction/Snell
  relations; it does not supply the mirror geometry needed here.

This is evidence for the absence of an **applicable formal geometric-optics
API in this pinned revision**, not a claim that every use of the word
reflection in Physlib is absent.

## Mathematical primitive versus reusable physical semantics

`Mathlib/Analysis/InnerProductSpace/Projection/Reflection.lean` provides actual
formal declarations in namespace `Submodule`. With `K : Submodule ℝ E`, a real
inner-product space E and `[K.HasOrthogonalProjection]`, their types specialize to:

```lean
Submodule.reflection : E ≃ₗᵢ[ℝ] E
-- K is the implicit receiver/parameter of this declaration.

Submodule.reflection_apply (p : E) :
  K.reflection p = 2 • K.starProjection p - p

Submodule.reflection_singleton_apply (u v : E) :
  (ℝ ∙ u).reflection v =
    2 • (inner ℝ u v / (‖u‖ ^ 2)) • u - v
```

Locations: `reflection` line 49, `reflection_apply` line 64,
`reflection_singleton_apply` line 106. The original APIs are more general over
the scalar field; the real specialization above is what P11 uses.

Mathlib supplies the mathematical operation, not an ideal plane-mirror law.
The re-audit also searched `specular|plane.mirror|law.of.reflection|angle.of.incidence`
through the whole pinned stable/Alpha trees and found no applicable formal
physics API. The source paths/revision and distinctions above remain valid.

The earlier P11 implementation assigned the optical interpretation locally.
That decision is revised: **a reusable physical interpretation deserves its own
physics layer even when its mathematical primitive already exists**. The new
`PhyslibTemp/Optics/Reflection.lean` models an ideal stationary specular mirror
with a unit normal and applies Mathlib reflection in the normal's orthogonal
complement. The unit normal ensures a genuine tangent hyperplane, rather than
silently calling an arbitrary reflecting subspace a physical plane mirror.

The new API is under `LeanVerificationDemo.PhyslibTemp.Optics`:

```lean
-- E is any real inner-product space; no CompleteSpace/dimension restriction.
PlaneMirror E                         -- unit normal, with normal_unit proof
PlaneMirror.tangent (mirror)          -- (ℝ ∙ mirror.normal)ᗮ
PlaneMirror.reflect (mirror) (v : E) : E

PlaneMirror.reflect_eq (mirror) (v) :
  mirror.reflect v = v - (2 * inner ℝ mirror.normal v) • mirror.normal
PlaneMirror.tangent_component (mirror) (v) :
  mirror.tangent.starProjection (mirror.reflect v) = mirror.tangent.starProjection v
PlaneMirror.normal_component (mirror) (v) :
  inner ℝ mirror.normal (mirror.reflect v) = -inner ℝ mirror.normal v
PlaneMirror.norm_reflect (mirror) (v) : ‖mirror.reflect v‖ = ‖v‖
PlaneMirror.reflect_reflect (mirror) (v) : mirror.reflect (mirror.reflect v) = v
PlaneMirror.incidence_reflection_cosine (mirror) (v) :
  |inner ℝ mirror.normal (mirror.reflect v)| / ‖mirror.reflect v‖ =
    |inner ℝ mirror.normal v| / ‖v‖
PlaneMirror2D.horizontal_reflect (vx vy : ℝ) :
  horizontal.reflect (direction vx vy) = direction vx (-vy)
```

The physical interpretation is adopted; component/norm/involution and the
unsigned normal-angle cosine identity are proved from Mathlib. No claim is
made to derive specular optics from Maxwell equations. The cosine has an angle
meaning for nonzero directions; zero remains an algebraic degenerate case.
`normal_ne_zero`, `reflect_tangent` and `reflect_normal` cover additional useful
cases. Independent horizontal, vertical, grazing, zero and arbitrary-space
checks are in `ReflectionExamples.lean`; `Reflection.md` explains potential
upstream integration and further uses.

P11 now imports this module, chooses the horizontal mirror with vertical unit
normal, and derives `(1,-q) ↦ (1,q)` by specializing `horizontal_reflect`. Its
object/screen placement and every obstruction or shadow calculation stay local.

Other formal Mathlib dependencies are:

| File | Declaration/type used | Role |
| --- | --- | --- |
| `Analysis/InnerProductSpace/PiL2.lean` | `EuclideanSpace ℝ (Fin 2)`; `EuclideanSpace.norm_sq_eq` and `inner_eq_star_dotProduct` | Concrete planar coordinates and evaluation of reflection |
| `Analysis/SpecialFunctions/Trigonometric/Basic.lean` | `Real.tan_pos_of_pos_of_lt_pi_div_two : 0 < x → x < Real.pi / 2 → 0 < Real.tan x` | Positive slope and valid divisions for acute incidence |
| `MeasureTheory/Measure/Lebesgue/Basic.lean:87` | `Real.volume_Icc {a b : ℝ} : volume (Set.Icc a b) = ENNReal.ofReal (b-a)` | Length of the actual shadow sets |
| `Basic/ENNReal/Basic.lean:253` | `ENNReal.toReal_ofReal` (nonnegative real input) | Convert finite interval measure to real length |

No new mathematical reflection or general visibility solver is needed.

## Upstream dimension infrastructure reused

`Physlib/Units/WithDim/Basic.lean` supplies the formal quantity system:

```lean
WithDim {B : Type} [DimensionBasis B] (d : Dimension B) (M : Type) : Type
WithDim.val : WithDim d M → M

-- Heterogeneous multiplication instance, line 248:
HMul (WithDim d₁ ℝ) (WithDim d₂ ℝ) (WithDim (d₁ * d₂) ℝ)

-- Namespace WithDim, line 356:
WithDim.cast (m : WithDim d M) (h : d = d₂) : WithDim d₂ M
```

`Physlib/Units/Dimension.lean` defines `Dimension` and its commutative-group
algebra; `Physlib/Units/LTMCTDimensionBase.lean` provides `Dimension.L𝓭`.
Dimension `1` is dimensionless. P11's `Units.lean` uses these directly:
`Length := WithDim L𝓭 ℝ`, `Dimensionless := WithDim 1 ℝ`, and
`thresholdLength h α := (h * ⟨tan α⟩).cast (mul_one L𝓭)`.
Thus h tan α and l have the same length dimension, and `typed_far_regime`
checks the equivalence of the dimension-tagged and scalar inequalities.
This does not prove that a far-screen condition holds. The primary geometry
remains in scalar coordinates with one common length unit.

## Source-solution audit and geometric correction

The only trusted figure input is the qualitative Fig. 237 caption in
`figure_caption.txt`. It has no h, l, α, inequalities, boundary constructions or
shadow lengths. Fig. 494 is reference-only solution material, never a trusted
construction. No independently located source book/image is used.

Positive h, positive l and acute α measured **from the vertical normal to the
horizontal mirror** quantify the
qualitative source geometry. They are formalization parameters, not labels
claimed to occur in the source problem. No `SourceData` field assumes a regime.

With q=cot α and H=lq, solving actual ray equations gives screen heights H+u
and H−u for obstruction at object height u. The top inverted boundary has mirror
coordinate h/q=h tan α, and reaches the screen forward precisely when
`l ≥ h tan α`. This is the derived solution-introduced regime boundary.

The **supplied solution** calls the two far-screen portions a “direct”
(upright) and an inverted shadow. Solving the actual ray geometry reveals that
both lose reflected light, through obstruction before or after reflection.
For a strictly far screen, direct/unreflected sunlight is unblocked. Thus
`uprightShadow` must not be identified with `directBlocked`, which denotes the
actual unreflected-channel loss. This is an audit result, not a new meaning
silently assigned to the source's wording. **Source terminology ≠ formal
physical-channel terminology**; predicate names must respect the physical
concepts rather than mechanically copy natural-language designations.

The approved Fig. 237 prose caption is unchanged. Its machine-readable
`figure_caption.json` geometry drives the deterministic SVG generator. Pixel
coordinates, visual inclinations and ray count are explicitly rendering choices,
not source measurements or case assumptions. The generator reads no source
solution, Candidate, Fig. 494 or derived boundary information. The SVG is a
caption-derived reconstruction, not a source scan or solution reconstruction.

The resulting ray-derived sets are:

```text
upright reflected shadow:    [H,H+h]
inverted reflected shadow:   [max(0,H-h),H]
loss of either channel:     [max(0,H-h),H+h]
loss of both channels:      [0,h-H]
```

Far: two adjoining lengths h and total 2h. Near: total H+h<2h and positive
fully dark length h−H. The explicit near endpoints/lengths are derived
strengthenings, not additional text attributed to the supplied solution.
Boundary-ray contact is inclusive; a singleton at the exact threshold has zero
length. Closed-interval and extended-mirror conventions are documented locally.

## Minimum-extension decision

```text
From stable Physlib:
  WithDim / Dimension / LTMCT length and dimensionless multiplication

From Mathlib:
  Euclidean coordinates, orthogonal reflection, trigonometry,
  interval sets and Lebesgue measure

New in PhyslibTemp:
  ideal specular plane-mirror semantics and reusable direction laws

P11-specific modeling:
  h/l/α and coordinates; horizontal mirror specialization and ray families;
  opaque-object intersections and illumination-channel predicates;
  solution regime predicates and source-facing shadow interpretation

Derived geometry and pure mathematics:
  reflection components, unique screen hits, boundary intersections,
  threshold equivalence, shadow intervals, ordering and lengths
```

This addition satisfies the reusable-physics criterion: the optical API is
absent upstream, source-independent, useful in other geometric-optics problems,
and built on existing mathematical reflection instead of duplicating it.
It adds a physical model and a theorem surface, not a one-line alias.
P11's shadow geometry and channel meanings remain local. No new unit framework,
visibility engine or solution-specific threshold is exported to PhyslibTemp.
