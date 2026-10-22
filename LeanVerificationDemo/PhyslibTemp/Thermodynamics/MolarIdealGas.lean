import Physlib.Units.SIUnitChoices
import Physlib.Units.WithDim.Basic

/-!
# Molar ideal-gas relations in coherent SI coordinates

Reuse Physlib's ISQ basis and `WithDim`; the abbreviations below only name
specializations of that existing quantity type. Values use kg, m, s, K and mol.
The molar equation of state is a phenomenological relation, not a derivation
from Physlib's normalized finite-particle Hamiltonian.

The ISQ aliases are intentional. At the pinned Physlib revision,
`Units/WithDim/Mass.lean` contains no mass declaration; `DimPressure` uses
`Dimensionful` over LTMCT; and `Temperature` wraps `ℝ≥0`, not ISQ `WithDim`.
No named volume quantity was found. Replacing these aliases would require
coordinate/basis conversions rather than direct type reuse. See P02's audit.

Whether the mass/amount API should become an upstream Physlib named API is an
open design question to discuss with Physlib maintainers.

Deferred APIs (not implemented or required by P02):
* `universalGasConstant : MolarGasConstant` with a specified numerical value;
* an Avogadro constant `N_A` and particle-count/amount conversion `N = n N_A`;
* a possible bridge `R = N_A k_B` with consistent dimensions and units.
-/
namespace LeanVerificationDemo.PhyslibTemp.Thermodynamics

open Dimension

/-- Mass coordinates over the existing ISQ basis, in kilograms. -/
abbrev Mass := WithDim (single (.mass : ISQDimensionBase)) ℝ
/-- Amount coordinates over the existing ISQ basis, in moles. -/
abbrev Amount := WithDim (single (.amount : ISQDimensionBase)) ℝ
/-- Mass per amount of substance (kg/mol), not relative molecular mass. -/
abbrev MolarMass := WithDim
  (single (.mass : ISQDimensionBase) / single (.amount : ISQDimensionBase)) ℝ
/-- Pressure coordinates in pascals over the ISQ basis. -/
abbrev Pressure := WithDim
  (single (.mass : ISQDimensionBase) /
    (single (.length : ISQDimensionBase) * single (.time : ISQDimensionBase) ^ 2)) ℝ
/-- Volume coordinates in cubic metres. -/
abbrev Volume := WithDim (single (.length : ISQDimensionBase) ^ 3) ℝ
/-- Absolute-temperature coordinates in kelvin. -/
abbrev AbsoluteTemperature := WithDim (single (.temperature : ISQDimensionBase)) ℝ
/-- Molar gas-constant coordinates in J/(mol K). -/
abbrev MolarGasConstant := WithDim
  ((single (.mass : ISQDimensionBase) * single (.length : ISQDimensionBase) ^ 2) /
    (single (.time : ISQDimensionBase) ^ 2 * single (.amount : ISQDimensionBase) *
      single (.temperature : ISQDimensionBase))) ℝ

/-- Amount of substance obtained from mass and molar mass, in coherent SI coordinates.
The real quotient is total; physical applications must require positive molar mass. -/
noncomputable def amountOfSubstanceFromMass (m : Mass) (μ : MolarMass) : Amount :=
  ⟨m.val / μ.val⟩

/-- A sample's amount is its mass divided by its positive molar mass.
Positivity is part of this physical relation, not a field-simplification trick. -/
def MassAmountRelation (m : Mass) (μ : MolarMass) (n : Amount) : Prop :=
  0 < μ.val ∧ n = amountOfSubstanceFromMass m μ

/-- Molar ideal-gas equation in one fixed coherent SI coordinate system.
`R` is an explicit molar-gas-constant parameter. This module does not fix
its value to the numerical universal gas constant; it introduces no axioms.
Here `n : Amount`, unlike the particle count `n : ℕ` and normalized `R := 1`
in Physlib's `IdealGas.ideal_gas_law`. The two laws are not directly interchangeable.
Physical-domain restrictions belong to the state model rather than this equation. -/
def MolarIdealGasLaw (p : Pressure) (V : Volume) (n : Amount)
    (R : MolarGasConstant) (T : AbsoluteTemperature) : Prop :=
  p.val * V.val = n.val * R.val * T.val

end LeanVerificationDemo.PhyslibTemp.Thermodynamics
