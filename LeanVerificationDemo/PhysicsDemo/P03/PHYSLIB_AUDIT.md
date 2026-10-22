# P03 Physlib audit

## Exact dependency

Physlib commit `96a6bc5e3c50a2856c64a6c9951c0a1c23790b58`, pinned in the
repository's `lakefile.lean` and `lake-manifest.json`; Lean/Mathlib 4.35.0.
No upstream revision or dependency was changed for P03. All paths below refer
to this revision, not GitHub HEAD.

## Search evidence and scope

The following searches were run over the installed pinned source, with stable
`Physlib/` and secondary `PhyslibAlpha/` results distinguished:

```bash
rg -n -i 'capacitor|capacitance|dielectric|permittivity|breakdown|parallel.plate' Physlib PhyslibAlpha
rg -n -i 'voltage|potential.difference|uniform.*field|series|charge.*potential|potential.*charge' Physlib/Electromagnetism
rg -n -i 'capacitor|capacitance|dielectric|breakdown|relative.permittivity|voltage|potential.difference|parallel.plate' Physlib/{Units,CondensedMatter,ClassicalMechanics,StatisticalMechanics} PhyslibAlpha
rg -n -i 'parallel.?plate|condenser|electric.?capacity|dielectric|capacitan|break.?down|relative.*permitt|permitt.*relative' Physlib PhyslibAlpha
```

The whole-tree capacitor/permittivity search returned only vacuum-permittivity
hits in `Electromagnetism/Basic.lean` and `Electromagnetism/Dynamics/Basic.lean`.
The broader synonym search returned no hits. The directory-specific search also
found a voltage reference in `CondensedMatter/Thermoelectric/Basic.lean:103`
(Seebeck coefficient, not capacitor voltage). No relevant Alpha declaration was
found. General potential/field/density hits were inspected, rather than treating
absence of a capacitor identifier as conclusive by itself.

Read relevant context in `Electromagnetism/Basic.lean`,
`Dynamics/Basic.lean`, `Kinematics/{ScalarPotential,ElectricField}.lean`,
`ThreeDimension/Basic.lean`, `Units/{LTMCTDimensionBase,Basic}.lean` and
`Units/WithDim/Basic.lean`. Generic units and field/potential foundations do
exist; there is no component-level capacitor model among the search results.

## Existing stable declarations

All qualified names below are Lean names; module paths are not extra namespaces.

| File / line | Declaration | Exact type / interpretation | Direct reuse |
| --- | --- | --- | --- |
| `Physlib/Units/WithDim/Basic.lean:33` | root `WithDim` | `{B : Type} → [DimensionBasis B] → Dimension B → Type → Type`; existing dimension-tagged coordinate wrapper | Yes, all quantity aliases |
| `Physlib/Units/LTMCTDimensionBase.lean:273,291,309,312` | `Dimension.L𝓭`, `T𝓭`, `M𝓭`, `C𝓭` | Each has type `Dimension LTMCTDimensionBase`; length, time, mass, charge generators | Yes; LTMCT suffices because P03 needs no amount dimension |
| `Physlib/Electromagnetism/Basic.lean:44` | `Electromagnetism.ElectricField` | `(d : ℕ := 3) → Type`; expands to `Time → Space d → EuclideanSpace ℝ (Fin d)` | Related field-valued API; not a scalar capacitor-voltage relation |
| `Physlib/Electromagnetism/Basic.lean:55` | `Electromagnetism.EMSystem` | `Type`, fields `ε₀ : ℝ`, `μ₀ : ℝ` | Vacuum constants, not relative dielectric scaling |
| `Physlib/Electromagnetism/Dynamics/Basic.lean:52` | `Electromagnetism.FreeSpace` | `Type`, fields `ε₀ μ₀ : ℝ` with positivity | Same distinction; no capacitor geometry or dielectric model |
| `Physlib/Electromagnetism/Kinematics/ScalarPotential.lean:64` | `Electromagnetism.ElectromagneticPotential.scalarPotential` | `{d : ℕ} → (c : SpeedOfLight := 1) → Electromagnetism.ElectromagneticPotential d → Time → Space d → ℝ` | General potential, not voltage of a lumped capacitor |
| `Physlib/Electromagnetism/Kinematics/ElectricField.lean:67,71,83` | `Electromagnetism.ElectromagneticPotential.electricField`, `electricField_eq`, `ofScalarPotential_electricField` | Exact checked signatures below; `E = −∇φ − ∂t A`, static scalar specialization `E = −∇φ` | Related foundations; no ready scalar `U = E d` plate API |

`Electromagnetism.ThreeDimension.electricField_eq_3D` at
`Physlib/Electromagnetism/ThreeDimension/Basic.lean:49` restates the same
field/potential identity for d = 3. It is not a breakdown or charge/capacitance law.

Exact signatures obtained by importing the pinned modules and running `#check`:

```text
Electromagnetism.ElectricField (d : ℕ := 3) : Type
Electromagnetism.EMSystem : Type
Electromagnetism.EMSystem.ε₀ (self : Electromagnetism.EMSystem) : ℝ
Electromagnetism.FreeSpace : Type
Electromagnetism.FreeSpace.ε₀ (self : Electromagnetism.FreeSpace) : ℝ
Electromagnetism.ElectromagneticPotential.scalarPotential {d : ℕ} (c : SpeedOfLight := 1)
  (A : Electromagnetism.ElectromagneticPotential d) : Time → Space d → ℝ
Electromagnetism.ElectromagneticPotential.electricField {d : ℕ} (c : SpeedOfLight := 1)
  (A : Electromagnetism.ElectromagneticPotential d) : Electromagnetism.ElectricField d
Electromagnetism.ElectromagneticPotential.electricField_eq {d : ℕ} {c : SpeedOfLight}
  (A : Electromagnetism.ElectromagneticPotential d) :
  Electromagnetism.ElectromagneticPotential.electricField c A = fun t x =>
    -Space.grad (Electromagnetism.ElectromagneticPotential.scalarPotential c A t) x -
      Time.deriv (fun t => Electromagnetism.ElectromagneticPotential.vectorPotential c A t x) t
Electromagnetism.ElectromagneticPotential.ofScalarPotential_electricField {d : ℕ} (c : SpeedOfLight)
  (φ : Time → Space d → ℝ) :
  Electromagnetism.ElectromagneticPotential.electricField c
      (Electromagnetism.ElectromagneticPotential.ofScalarPotential c φ) =
    fun t x => -Space.grad (φ t) x
@WithDim : {B : Type} → [inst : DimensionBasis B] → Dimension B → Type → Type
Dimension.L𝓭 : Dimension LTMCTDimensionBase
Dimension.C𝓭 : Dimension LTMCTDimensionBase
```

## Physical relations A–E

| Relation | Audit result | Minimal choice |
| --- | --- | --- |
| A: `U = Q/C` or `Q = CU` | No capacitor constitutive API found in stable or secondary Alpha search | Temporary `PlaneCapacitor.voltage`, definition `q.val / C.val` |
| B: common charge in series | No lumped series-capacitor circuit/charge API found | One common charge argument in the problem model; no redundant equality predicate or claimed circuit derivation |
| C: dielectric capacitance scaling | Vacuum ε₀ exists but neither relative εr nor a parallel-plate capacitance theorem was found | Reusable `DielectricScaling` relation for fixed geometry, no Gaussian formula |
| D: `U = E d` | Related general field/potential identity exists; scalar plate specialization is not supplied | Temporary uniform-gap model `field := voltage/gap` and derived `voltage_eq_field_mul_gap` |
| E: breakdown criterion | No breakdown model found | Reusable optional `BreakdownSpec` with positive threshold and `Admissible`; prove equivalence to the field bound |

D could be connected to a linear scalar potential by additional geometry and
calculus. This implementation does not claim the general field relation is
missing, and does not replace or duplicate the vector-field API. It uses a small
lumped uniform-gap specialization and states its modeling assumptions explicitly.

## Implementation split and boundaries

- From Physlib: generic quantity and dimension algebra, imported rather than copied.
- PhyslibTemp: ideal plane-capacitor coordinates, linear voltage law and uniform-gap
  field independent of failure data; optional `BreakdownSpec` in a separate module
  with threshold, admissibility and charge attaining it; dielectric
  scaling, and a derived inverse-voltage-scaling lemma. No declaration contains
  four components, the air/glass materials or the source numerical constants.
- P03: four identical air components or three air plus glass, additive series
  total voltage, common magnitude Q, supplied source data and the maximum target.
- Pure mathematics: real division, positive multiplication, order inequalities,
  exact rational arithmetic and the definition of attained maximum.

All values are coordinates in a fixed coherent SI system. WithDim tags the
input/output dimensions; coordinate relations are not a proof of general unit
covariance. Intermediate conductors are assumed initially neutral, capacitors
ideal and linear, leakage/fringe effects ignored. Equal charge and dielectric
scaling are physical premises, not conclusions from a formal circuit/Maxwell model.

Sources at the immutable revision:
[quantity wrapper](https://github.com/leanprover-community/physlib/blob/96a6bc5e3c50a2856c64a6c9951c0a1c23790b58/Physlib/Units/WithDim/Basic.lean#L33),
[electric-field relation](https://github.com/leanprover-community/physlib/blob/96a6bc5e3c50a2856c64a6c9951c0a1c23790b58/Physlib/Electromagnetism/Kinematics/ElectricField.lean#L67),
[vacuum permittivity](https://github.com/leanprover-community/physlib/blob/96a6bc5e3c50a2856c64a6c9951c0a1c23790b58/Physlib/Electromagnetism/Dynamics/Basic.lean#L52).

## Modularity follow-up (no upstream audit change)

`PlaneCapacitor.lean` now contains only the basic positive C/gap model, voltage,
field and `U = Ed` result, plus dielectric scaling/inverse voltage scaling.
`DielectricBreakdown.lean` imports it and introduces `BreakdownSpec c`, an optional
additional specification; the basic module does not import the failure module.

The six former `PlaneCapacitor` declarations `breakdownVoltage`, `Admissible`,
`field_le_iff`, `chargeAtLimit`, `voltage_at_limit`, `admissible_at_limit` now live
in namespace `BreakdownSpec`. Positive breakdown field and its proof likewise
belong to the specification rather than the capacitor. This is a local module
boundary refactor, not a new claim about absent or present upstream APIs.

Equal gap is explicit in `DielectricScaling`; plate area is not represented.
Equal area/other fixed-geometry conditions remain external physical assumptions.
Common q remains a problem-level premise, not a derived circuit-graph law.
The threshold remains inclusive by modeling convention. “Dielectric breakdown”
is normalized terminology for historical puncturing, not literal source wording.

The new `P03.Candidate.glass_voltage_at_air_limit` is numerical derived data:
source Ea = 3×10^6 V/m, d = 7/1000 m and εr = 7 imply 3000 V. It remains in P03
(and its annotated proof), and no numerical capacitor result is in PhyslibTemp.
The source conditions, existing maximum definition and final physical conclusions
are unchanged. Dependency pins and other demos are unchanged.
