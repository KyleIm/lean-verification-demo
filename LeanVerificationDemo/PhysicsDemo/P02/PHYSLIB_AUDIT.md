# Physlib audit for P02

## Revision and scope

Before this change, this repository required only Mathlib `v4.33.0`; there was
**no Physlib dependency or Physlib pin**. The earlier P02 did not import Physlib.
The separately installed Physlib was inspected at commit
`96a6bc5e3c50a2856c64a6c9951c0a1c23790b58` (Lean/Mathlib `v4.35.0`).
This change pins that exact commit in `lakefile.lean` and `lake-manifest.json`,
and upgrades the demo toolchain/Mathlib to `v4.35.0` to import its unit API.
All paths/line numbers below refer to that commit, not a floating GitHub HEAD.
Source links use the immutable upstream revision.

Searches covered all of stable `Physlib/` and, separately, `PhyslibAlpha/`:

```bash
rg -n -i 'amount.?of.?substance|molar|\bmole\b|\bmol\b|avogadro|gas.constant|ideal.gas.law|equation.of.state' Physlib PhyslibAlpha
rg -n -i 'ideal.?gas|molar|avogadro|amount|equation.of.state|pressure.*volume|volume.*pressure|\bpV\b' Physlib
rg --files Physlib | rg -i 'foundations|chemi|unit|dimension|therm|statistic'
```

There is no `Physlib/Foundations/` directory at this revision, and the path search
found no chemistry subtree. Relevant foundations live in `Physlib/Units/`.
Full context was read in `Dimension`, `ISQDimensionBase`, `SIUnitChoices`,
`ISQBridge`, `ParametricUnits`, `UnitSystem`, `WithDim/Basic`, `WithDim/Pressure`,
`WithDim/Energy`, `Thermodynamics/IdealGas/Basic`, `Temperature/Basic`,
`StatisticalMechanics/BoltzmannConstant`, `MicroCanonicalEnsemble/{Basic,
ThermoQuantities,IdealGas}` and `CanonicalEnsemble/Basic`; related canonical
ensemble modules were searched as well. Whole-tree hits for equation of state
also include cosmological barotropic pressure, not a molar ideal-gas API.

## 1. Amount of substance — EXISTS

These are stable Physlib declarations, not Alpha APIs. Names are fully qualified;
root-level declarations have no enclosing namespace.

| File and line | Namespace / declaration | Exact Lean type | Interpretation |
| --- | --- | --- | --- |
| `Physlib/Units/ISQDimensionBase.lean:56` | `ISQDimensionBase.amount` | `ISQDimensionBase` | Independent substance-amount base dimension |
| `Physlib/Units/Dimension.lean:173` | `Dimension.single` | `{B : Type} → [DimensionBasis B] → [DecidableEq B] → B → Dimension B` | Constructs the amount dimension using `single .amount` |
| `Physlib/Units/ISQDimensionBase.lean:89` | `ISQDimensionBase.single_amount_ne_one` | `Dimension.single ISQDimensionBase.amount ≠ 1` | Amount is not dimensionless |
| `Physlib/Units/SIUnitChoices.lean:78` | root `AmountUnit` | `Type` | Unit scale with fields `val : ℝ`, `property : 0 < val`; not the amount in a sample |
| `Physlib/Units/SIUnitChoices.lean:95` | `AmountUnit.moles` | `AmountUnit` | Coherent mole unit, value 1 |
| `Physlib/Units/SIUnitChoices.lean:178` | root `SIUnitChoices` | `Type` (abbreviation of `UnitSystem ISQDimensionBase`) | Seven typed unit choices |
| `Physlib/Units/SIUnitChoices.lean:183` | `SIUnitChoices.SI` | `SIUnitChoices` | Coherent SI system, amount slot is `AmountUnit.moles` |
| `Physlib/Units/WithDim/Basic.lean:33` | root `WithDim` | `{B : Type} → [DimensionBasis B] → Dimension B → Type → Type` | Existing quantity wrapper; sample amount can be `WithDim (Dimension.single ISQDimensionBase.amount) ℝ` |

A separately named sample-amount type is unnecessary: `WithDim` already represents
it. `AmountUnit.moles` denotes a unit, not a number of moles. Alpha search found
no additional relevant substance/molar API; unrelated English “amount” and `Pv`
variable hits were not treated as physics declarations.

## 2. Molar mass — B

**B: no named reusable molar-mass API found, but the existing dimensional/unit
infrastructure represents it.** This is not status C.

Using the existing declarations above, its type is:

```lean
WithDim
  (Dimension.single (.mass : ISQDimensionBase) /
   Dimension.single (.amount : ISQDimensionBase)) ℝ
```

`Dimension B` is a commutative group (multiplication adds exponents, inversion
negates them), so mass/amount is a natural derived dimension. At
`Physlib/Units/WithDim/Basic.lean:317`, the generic division instance has type:

```lean
{B : Type} → [DimensionBasis B] → (d1 d2 : Dimension B) →
  HDiv (WithDim d1 ℝ) (WithDim d2 ℝ) (WithDim (d1 * d2⁻¹) ℝ)
```

The coordinate identity `WithDim.val_div_val`, line 322, is:

```lean
∀ {B : Type} [DimensionBasis B] {d1 d2 : Dimension B}
  (m1 : WithDim d1 ℝ) (m2 : WithDim d2 ℝ),
  m1.val / m2.val = (m1 / m2).val
```

Thus `m / μ` has dimension mass/(mass/amount), equal to amount by commutative-group
algebra. A small named coordinate function/relation is the missing convenience,
not new unit foundations. `SIUnitChoices.dimScale` (line 194) has type
`SIUnitChoices → SIUnitChoices → Dimension ISQDimensionBase →* ℝ≥0`; it supplies
generic rescaling, not a particle-to-mole law.

The problem's μ is **molar mass**, in kg/mol in the implementation. The historical
mass in grams and molar mass in g/mol yield the same ratio in moles. Dimensionless
relative molecular mass would require an additional conversion and is not used.
No Avogadro constant or particle-count/amount bridge was found in either tree.

## 3. Ideal-gas equation — RELATED BUT NOT DIRECTLY REUSABLE

### Known normalized theorem: exact context

At `Physlib/StatisticalMechanics/MicroCanonicalEnsemble/Basic.lean:44`:

```lean
abbrev NVEHamiltonian := MicroHamiltonian (ℕ × ℝ)
def NVEHamiltonian.N : (ℕ × ℝ) → ℕ := Prod.fst
```

The source explicitly calls these parameters particle number and volume.
Root declaration `IdealGas : NVEHamiltonian` is at
`MicroCanonicalEnsemble/IdealGas.lean:25`. Its configuration index is
`Fin n × (Fin 3 ⊕ Fin 3)`: three positions and three momenta per distinguishable
particle. Its Hamiltonian sums `p²/2` with particle mass normalized to one,
excluding positions outside a cube of volume V. Hence **n is particle count
`ℕ`, not amount of substance and not a molar amount coerced into ℕ**.

Namespace `NVEHamiltonian`, `ThermoQuantities.lean:219`:

```lean
def pressure (H : NVEHamiltonian) (d : ℕ × ℝ) (T : ℝ) : ℝ :=
  let (n, V) := d
  -deriv (fun V' ↦ MicroHamiltonian.helmholtzA H (n, V') T) V
```

Namespace `MicroHamiltonian`, same file, lines 76 and 85:

```lean
def partitionZT {D : Type} (H : MicroHamiltonian D) (d : D) (T : ℝ) : ℝ :=
  partitionZ H d (1 / T)
def helmholtzA {D : Type} (H : MicroHamiltonian D) (d : D) (T : ℝ) : ℝ :=
  -T * (partitionZT H d T).log
```

Namespace `IdealGas`, `IdealGas.lean:196`, exact elaborated signature
(`have`/`let` print equivalently here):

```lean
theorem ideal_gas_law (n : ℕ) {V T : ℝ} (hV : 0 < V) (hT : 0 < T) :
    let P := IdealGas.pressure (n, V) T
    let R := 1
    P * V = (n : ℝ) * R * T
```

This is a **normalized/unitless `PV = NT` result**. T is the real temperature
parameter used through β = 1/T, not Physlib's `Temperature` type with physical
Boltzmann factor. R is a local abbreviation for 1, not a theorem parameter
representing the physical molar gas constant. The comment explicitly calls the
system unitless. The formulas normalize the thermal energy scale (physically
consistent with kB = 1); the source does not construct a unit conversion that
identifies this 1 with physical R.

### Related stable declarations and indirect routes

All `MicroCanonicalEnsemble` paths below have prefix
`Physlib/StatisticalMechanics/`.

```lean
-- MicroCanonicalEnsemble/IdealGas.lean:56, namespace IdealGas
lemma partitionZ_eq (n : ℕ) {V β : ℝ} (hV : 0 < V) (hβ : 0 < β) :
  MicroHamiltonian.partitionZ IdealGas (n, V) β =
    V ^ n * (2 * Real.pi / β) ^ (3 * (n : ℝ) / 2)

-- same file:178, namespace IdealGas
lemma helmholtzA_eq (n : ℕ) {V T : ℝ} (hV : 0 < V) (hT : 0 < T) :
  MicroHamiltonian.helmholtzA IdealGas (n, V) T =
    -(n : ℝ) * T * (Real.log V + (3/2) * Real.log (2 * Real.pi * T))

-- BoltzmannConstant.lean:29,33, namespace Constants
def kBAx : {p : ℝ | 0 < p}
noncomputable def kB : ℝ
-- kBAx's value is 1.380649e-23; kB := kBAx.1.

-- Physlib/Thermodynamics/Temperature/Basic.lean:59,62
-- namespace Temperature
noncomputable def β (T : Temperature) : ℝ≥0
lemma β_toReal (T : Temperature) :
  (T.β : ℝ) = 1 / (Constants.kB * T.toReal)

-- CanonicalEnsemble/Basic.lean:680, namespace CanonicalEnsemble
noncomputable def helmholtzFreeEnergy {ι : Type} [MeasurableSpace ι]
    (𝓒 : CanonicalEnsemble ι) (T : Temperature) : ℝ :=
  -Constants.kB * T.val * Real.log (𝓒.partitionFunction T)

-- Physlib/Thermodynamics/IdealGas/Basic.lean:34, root namespace
def entropy (c R s0 U0 V0 N0 : ℝ) (U V N : ℝ) : ℝ :=
  N * s0 + N * R *
    (c * Real.log (U / U0) + Real.log (V / V0) -
      (c + 1) * Real.log (N / N0))
```

The first two are indirect derivations of the same normalized pressure law;
they do not supply an independent molar formulation. The physical kB and
canonical free energy are related but insufficient: no particle/amount conversion,
Avogadro constant, R = NA kB bridge, or theorem connecting these canonical
quantities to this ideal-gas model was found. The entropy module also proves
`adiabatic_relation_log` (line 46) and `adiabatic_relation_UaUbVaVb` (line 75);
it gives entropy/adiabatic relations, not pressure/temperature derivative definitions
or a molar equation-of-state theorem. Its real parameter R alone does not fill
that gap.

`Dimension.isqToLTMCT : Dimension.Projection ISQDimensionBase LTMCTDimensionBase`
(`Physlib/Units/ISQBridge.lean:131`) **forgets** amount; it is not a conversion
between particle count and molar amount. `UnitScale.dimScale` likewise changes
unit magnitudes only. None of these is an existing conversion making the known
ideal-gas theorem directly applicable to arbitrary real `m/μ`.

Conclusion: **RELATED BUT NOT DIRECTLY REUSABLE** for the requested molar law.
A new physical bridge would require more assumptions/definitions than the minimal
phenomenological molar relation used here. Substituting a real `m/μ` for a natural
particle count or just replacing local `R := 1` would be unjustified.

## Implementation split

- **From Physlib:** `ISQDimensionBase`, `Dimension.single`, dimension algebra,
  `AmountUnit.moles` / `SIUnitChoices`, and `WithDim`. Quantity names in the temporary
  file are only abbreviations of these existing types. No amount/unit framework
  is reimplemented.
- **New PhyslibTemp:** derived molar-mass type alias, coherent-SI mass-to-amount
  function and positive-molar-mass relation, explicit molar ideal-gas relation.
  It is a `Prop` definition supplied as physical evidence, not a new axiom or
  a claim to derive the molar law from the normalized theorem.
- **Problem-specific:** a sample's data and independent evidence of the two
  reusable relations; nonnegative mass, positive absolute temperature and R.
  Positive μ is carried by the reusable mass relation. No arbitrary positivity
  assumptions on p or V are used to assist tactics.
- **Pure mathematics:** substitution of the amount equality and unfolding of
  the quotient's coordinate definition. No field tactic is needed.

The P02 quantities carry ISQ dimensions, but equations compare their numerical
coordinates in one documented coherent SI system. This is not a proof of general
unit covariance: `WithDim`'s full unit-scaling instances are restricted to the
five-base LTMCT system, even though its algebra works over ISQ.

## Signature verification

The following output was obtained by `lake env lean` importing the pinned Physlib
modules and running `#check` (and `#print axioms` for the known theorem):

```text
ISQDimensionBase.amount : ISQDimensionBase
@Dimension.single : {B : Type} → [inst : DimensionBasis B] → [DecidableEq B] → B → Dimension B
ISQDimensionBase.single_amount_ne_one : Dimension.single ISQDimensionBase.amount ≠ 1
AmountUnit : Type
AmountUnit.moles : AmountUnit
SIUnitChoices : Type
SIUnitChoices.SI : SIUnitChoices
@WithDim : {B : Type} → [inst : DimensionBasis B] → Dimension B → Type → Type
@WithDim.val_div_val : ∀ {B : Type} [inst : DimensionBasis B] {d1 d2 : Dimension B} (m1 : WithDim d1 ℝ)
  (m2 : WithDim d2 ℝ), m1.val / m2.val = (m1 / m2).val
Dimension.isqToLTMCT : Dimension.Projection ISQDimensionBase LTMCTDimensionBase
NVEHamiltonian : Type 1
NVEHamiltonian.N : ℕ × ℝ → ℕ
IdealGas : NVEHamiltonian
IdealGas.ideal_gas_law (n : ℕ) {V T : ℝ} (hV : 0 < V) (hT : 0 < T) :
  have P := IdealGas.pressure (n, V) T;
  have R := 1;
  P * V = ↑n * R * T
NVEHamiltonian.pressure (H : NVEHamiltonian) (d : ℕ × ℝ) (T : ℝ) : ℝ
@MicroHamiltonian.partitionZT : {D : Type} → MicroHamiltonian D → D → ℝ → ℝ
@MicroHamiltonian.helmholtzA : {D : Type} → MicroHamiltonian D → D → ℝ → ℝ
IdealGas.partitionZ_eq (n : ℕ) {V β : ℝ} (hV : 0 < V) (hβ : 0 < β) :
  MicroHamiltonian.partitionZ IdealGas (n, V) β = V ^ n * (2 * Real.pi / β) ^ (3 * ↑n / 2)
IdealGas.helmholtzA_eq (n : ℕ) {V T : ℝ} (hV : 0 < V) (hT : 0 < T) :
  MicroHamiltonian.helmholtzA IdealGas (n, V) T = -↑n * T * (Real.log V + 3 / 2 * Real.log (2 * Real.pi * T))
Constants.kB : ℝ
Temperature.β_toReal (T : Temperature) : ↑T.β = 1 / (Constants.kB * T.toReal)
@CanonicalEnsemble.helmholtzFreeEnergy : {ι : Type} → [inst : MeasurableSpace ι] → CanonicalEnsemble ι → Temperature → ℝ
'IdealGas.ideal_gas_law' depends on axioms: [propext, Classical.choice, Quot.sound]
```

Primary source links: [ISQ basis](https://github.com/leanprover-community/physlib/blob/96a6bc5e3c50a2856c64a6c9951c0a1c23790b58/Physlib/Units/ISQDimensionBase.lean#L44), [SI units](https://github.com/leanprover-community/physlib/blob/96a6bc5e3c50a2856c64a6c9951c0a1c23790b58/Physlib/Units/SIUnitChoices.lean#L76), [quantity algebra](https://github.com/leanprover-community/physlib/blob/96a6bc5e3c50a2856c64a6c9951c0a1c23790b58/Physlib/Units/WithDim/Basic.lean#L33), [normalized gas theorem](https://github.com/leanprover-community/physlib/blob/96a6bc5e3c50a2856c64a6c9951c0a1c23790b58/Physlib/StatisticalMechanics/MicroCanonicalEnsemble/IdealGas.lean#L196), [pressure](https://github.com/leanprover-community/physlib/blob/96a6bc5e3c50a2856c64a6c9951c0a1c23790b58/Physlib/StatisticalMechanics/MicroCanonicalEnsemble/ThermoQuantities.lean#L219).

The exact types of the related adiabatic results (root namespace) are:

```lean
theorem adiabatic_relation_log
    {s0 U0 V0 N0 c R : ℝ}
    {Ua Ub Va Vb N : ℝ}
    (hUa : 0 < Ua) (hUb : 0 < Ub)
    (hVa : 0 < Va) (hVb : 0 < Vb)
    (hN : 0 < N)
    (hU0 : 0 < U0) (hV0 : 0 < V0)
    (hR : 0 < R)
    (hS :
      entropy c R s0 U0 V0 N0 Ua Va N =
      entropy c R s0 U0 V0 N0 Ub Vb N) :
    c * log (Ua / Ub) + log (Va / Vb) = 0

theorem adiabatic_relation_UaUbVaVb
    {s0 U0 V0 N0 c R : ℝ}
    {Ua Ub Va Vb N : ℝ}
    (hUa : 0 < Ua) (hUb : 0 < Ub)
    (hVa : 0 < Va) (hVb : 0 < Vb)
    (hN : 0 < N)
    (hU0 : 0 < U0) (hV0 : 0 < V0)
    (hR : 0 < R)
    (hS :
      entropy c R s0 U0 V0 N0 Ua Va N =
      entropy c R s0 U0 V0 N0 Ub Vb N) :
    (Real.rpow (Ua / Ub) c) * (Va / Vb) = 1
```
