# Pinned Physlib audit — problem 574

Physlib package HEAD and repository manifest use
`96a6bc5e3c50a2856c64a6c9951c0a1c23790b58`. Lean/Mathlib remain 4.35.0.
No pins changed. Paths below are relative to that pinned checkout.

## Search evidence and scope

Searched the entire stable `Physlib/` and secondary `PhyslibAlpha/` trees:

```bash
rg -n -i 'resistivity|\bresistance\b|ohm.s|faraday|induced emf|magnetic flux|electromagnetic induction|\bannulus\b' Physlib PhyslibAlpha
rg --files Physlib PhyslibAlpha | rg -i 'current|magnetic|flux|annul|ohm|resist|induct'
rg -n -i 'resistiv|\bresistan|\bohm|electromotive|\bemf\b|\bflux\b|\bconductiv' Physlib/Electromagnetism Physlib/Units Physlib/CondensedMatter PhyslibAlpha/Electromagnetism
```

An initial broad search for `induction` also found many mathematical induction
proofs; those are not evidence of electromagnetic induction support. Refined
searches and source inspection distinguish the following actual APIs.

## Relevant formal stable declarations

| File / namespace / declaration | Type or defining relation | Assessment |
| --- | --- | --- |
| `Physlib/Units/WithDim/Basic.lean`, root `WithDim` | `{B : Type} → [DimensionBasis B] → Dimension B → Type → Type` | Reused for local length, resistivity and current aliases; no new unit foundation |
| `Physlib/Electromagnetism/Kinematics/MagneticField.lean:79`, `Electromagnetism.ElectromagneticPotential.magneticField` | `(c : SpeedOfLight := 1) → ElectromagneticPotential → MagneticField` | Formal curl of vector potential; relates to a B-type field, not a supplied source H-to-SI conversion |
| `Physlib/Electromagnetism/ThreeDimension/MaxwellEquations.lean:86`, `Electromagnetism.ThreeDimension.faradayLaw` | `{𝓕 : FreeSpace} (V : ElectromagneticPotential 3) (t : Time) (x : Space) (hV : ContDiff ℝ ∞ V) : (∇ ⨯ V.electricField 𝓕.c t) x = - ∂ₜ (fun t => V.magneticField 𝓕.c t x) t` | Actual formal differential Faraday theorem, not an InformalLemma. Does not supply loop emf, material resistance or source-unit factor |
| `Physlib/Electromagnetism/Dynamics/CurrentDensity.lean:68`, `Electromagnetism.LorentzCurrentDensity` | `(d : ℕ := 3) → Type`, defined as `SpaceTime d → Lorentz.Vector d` | Formal spacetime current density, not a loop-current integral |
| Same file:144, `Electromagnetism.LorentzCurrentDensity.currentDensity` | `{d : ℕ} (c : SpeedOfLight := 1) (J : LorentzCurrentDensity d) : Time → Space d → EuclideanSpace ℝ (Fin d)` | Formal spatial vector current density; distinct from P07's scalar contribution per radial width |
| `Physlib/CondensedMatter/Thermoelectric/Basic.lean:103`, `CondensedMatter.ThermoelectricMaterial` | Structure with `S σ κl κe : ℝ`, `0 < σ`, `0 < κl`, `0 ≤ κe` | Formal positive conductivity parameter in a thermoelectric model; no annular Ohm/resistance/Faraday composition |

The Maxwell module explicitly limits itself to pointwise differential equations;
integral formulations, boundary conditions and material constitutive laws are
outside its scope. P07 therefore does not claim to apply `faradayLaw` to a loop
via a formal Stokes theorem, and does not import it merely for attribution.

## Stubs, Alpha and specialized geometry

`Physlib/Electromagnetism/Current/CircularCoil.lean` is a stub with a TODO about
the field of a steady circular current; it does not prove induced loop current.
`Current/InfiniteWire.lean` and tempered-distributional current/field APIs concern
other geometries. `PhyslibAlpha/Particles/QED/Evaluation.lean` discusses the
formal Bianchi identity in a QED formal-polynomial setting; it supplies neither
this source-unit constitutive law nor this conducting-ring model. Alpha
`CondensedMatter/TightBindingChain/Current/` describes quantum chain currents,
not the resistive annulus. No Alpha import is added. Documentation, TODOs and
InformalLemma records are not used as proofs.

The whole-tree annulus/flux/resistance searches did not reveal a stable
conducting annulus, `R = ρ l/A`, loop-emf or resistive current-integration API
suitable for this problem. Other circle geometry (e.g. pendulum configuration
spaces) and string-theory fluxes are unrelated. This is a bounded claim about
the inspected revision, not a claim that Physlib lacks magnetic fields or
Faraday's law altogether.

## Extension decision

* Stable Physlib reused: `WithDim` and its LTMCT dimension algebra, directly.
* Mathlib reused: `HasDerivAt`, `deriv`, interval integration, continuity-based
  interval integrability, integrability transfer by `IntervalIntegrable.congr`,
  and `intervalIntegral.integral_eq_sub_of_hasDerivAt` (fundamental theorem of calculus).
* PhyslibTemp: **no additions**. Lack of an upstream API alone does not justify
  exporting a new library abstraction.
* P07-local: annular parameters, source H coordinate and historical coefficient,
  flux proxy, thin-ring resistance coefficient, scalar Faraday/Ohm evidence and
  integration of the current-per-width profile over radius. These encode this
  source's geometry and adopted continuum argument; no generic ring ontology is created.

The integral is the continuum counterpart of the printed thin-ring sum. Its
integrability and value are proved; convergence of a specific discrete δ-family
and the validity of the continuum material idealization are not proved.
