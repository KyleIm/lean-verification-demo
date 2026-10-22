# P04 pinned Physlib audit

## Revision and search evidence

Physlib `96a6bc5e3c50a2856c64a6c9951c0a1c23790b58`, Lean/Mathlib 4.35.0,
as pinned by this repository. No dependency revision was changed.

Searches over the installed pinned source:

```bash
rg -n -i 'capacitor|capacitance|kirchhoff|circuit|network|laplacian' Physlib/Electromagnetism Physlib/Units Physlib/CondensedMatter
rg --files Physlib | rg -i 'circuit|network|graph|capac|laplacian'
rg -n -i 'capacitor|capacitance|kirchhoff|circuit|electric.*network|network.*electric' Physlib PhyslibAlpha
```

The first search had no relevant capacitor-network hits. The file search located
stable `CondensedMatter/Crystal/PeriodicGraph.lean` and spatial Laplacian modules.
The whole-tree semantic search found only secondary Alpha Kirchhoff-related
box/junction charge-conservation material, separated below. Together with the
previous [P03 capacitor audit](../P03/PHYSLIB_AUDIT.md), these searches found no
stable finite capacitor-network API, neutral-node electrostatic solve, or equivalent
capacitance/series/parallel theorem suitable for the cube. This is a source search
result, not a claim that general graph/algebra infrastructure is absent.

## Stable Physlib: reused and inspected

| Source | Declaration / type | Interpretation and suitability |
| --- | --- | --- |
| `Physlib/Units/WithDim/Basic.lean:33` | `WithDim : {B : Type} → [DimensionBasis B] → Dimension B → Type → Type` | Existing dimension-tagged coordinate wrapper, reused |
| `Physlib/Units/LTMCTDimensionBase.lean:273,291,309,312` | `Dimension.L𝓭`, `T𝓭`, `M𝓭`, `C𝓭 : Dimension LTMCTDimensionBase` | Basis for charge, voltage and capacitance; reused through existing aliases |
| `Physlib/CondensedMatter/Crystal/PeriodicGraph.lean:61` | `Physlib.CondensedMatter.Crystal.PeriodicGraph (C : Crystal G)` with ambient `{G : Type*} [AddCommGroup G] [AddGroup.FG G]` | Translation-invariant crystal graph, not finite capacitor electrostatics; not imported |
| same file:63 | `PeriodicGraph.toSimpleGraph : PeriodicGraph C → SimpleGraph C.Site` | Existing Mathlib graph underneath a periodic crystal; no capacitance weights or nodal-charge law |
| same file:82 | `PeriodicGraph.translateIso (g : PeriodicGraph C) (a : G) : g.toSimpleGraph ≃g g.toSimpleGraph` | Translation symmetry, not cube diagonal symmetry plus uniqueness of electrostatic equilibrium |
| `Physlib/SpaceAndTime/Space/Derivatives/Laplacian.lean` | Spatial differential Laplacian (continuum calculus) | Different object from a finite weighted capacitor matrix; not used |

P03 already provides `PhyslibTemp.Electromagnetism.Charge`, `Voltage` and
`Capacitance`, all aliases of existing Physlib `WithDim` types. These are reused.
The existing `PlaneCapacitor.voltage` implements U = Q/C but requires a capacitor
gap, which is irrelevant to the cube once C is supplied. The new signed node-charge
sum uses the same constitutive law in Q = C ΔV form, not an independent competing
capacitor material law. No new unit or basic voltage framework was introduced.

## PhyslibAlpha: related, not used

`PhyslibAlpha/Electromagnetism/BoxChargeConservation.lean` explicitly distinguishes
its continuum box-current theorem from branch currents of a lumped circuit
(lines 28–30). At line 277, namespace `Electromagnetism.ThreeDimension`,
`boxOutwardCurrent_eq_zero_of_steady` proves a zero current flux under Maxwell
and steady-charge assumptions. It is not the capacitor relation Σ Cij(Vi−Vj)=0.

`PhyslibAlpha/Electromagnetism/TemperedDistributional/WireJunction.lean` similarly
models one steady junction of idealized distributional wires. Exact declaration
at line 264, namespace `Electromagnetism.TempDistLorentzCurrentDensity`:

```lean
lemma IsWireJunction.sum_currents_eq_zero {d} {𝓕 : FreeSpace}
    {J : TempDistLorentzCurrentDensity d} {ι : Type} [Fintype ι]
    {u : ι → EuclideanSpace ℝ (Fin d)} {I : ι → ℝ}
    (hJ : J.IsWireJunction 𝓕.c u I) (hu : ∀ k, u k ≠ 0)
    (A : TempDistElectromagneticPotential d)
    (h : TempDistElectromagneticPotential.IsExtrema 𝓕 A J)
    (hρ : distTimeDeriv (J.chargeDensity 𝓕.c) = 0) : ∑ k, I k = 0
```

This is not a finite capacitor circuit, static conductor neutrality or a
capacitance-reduction theorem. No Alpha module is imported by P04.

## Minimum extension and split

- **From Physlib / existing temporary module:** typed charge, voltage, capacitance
  coordinates and dimension algebra.
- **New PhyslibTemp:** a finite symmetric nonnegative capacitance matrix with
  zero diagonal; signed node-charge sum; neutral-interior and boundary-state
  predicates; equivalent capacitance defined through existence and the terminal
  charge law. These definitions mention no cube, caption labels, C/5 or source answer.
- **P04-specific:** exact caption transcription, identical C > 0, finite residuals,
  solution of the six interior equations and the 6C/5 coefficient.
- **Pure Mathlib:** finite sets/sums, cancellation, linear arithmetic and field/ring
  identities. No general graph-automorphism/quotient or series/parallel machinery
  was invented just to reproduce the printed reduction.

Source links at the pinned revision:
[units](https://github.com/leanprover-community/physlib/blob/96a6bc5e3c50a2856c64a6c9951c0a1c23790b58/Physlib/Units/WithDim/Basic.lean#L33),
[periodic crystal graph](https://github.com/leanprover-community/physlib/blob/96a6bc5e3c50a2856c64a6c9951c0a1c23790b58/Physlib/CondensedMatter/Crystal/PeriodicGraph.lean#L61),
[Alpha wire-junction result](https://github.com/leanprover-community/physlib/blob/96a6bc5e3c50a2856c64a6c9951c0a1c23790b58/PhyslibAlpha/Electromagnetism/TemperedDistributional/WireJunction.lean#L264).
