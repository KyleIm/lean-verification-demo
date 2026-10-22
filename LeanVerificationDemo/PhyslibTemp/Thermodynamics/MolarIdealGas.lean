import Physlib.Units.SIUnitChoices
import Physlib.Units.WithDim.Basic

/-!
# Molar ideal-gas relations in coherent SI coordinates

Reuse Physlib's ISQ basis and `WithDim`; the abbreviations below only name
specializations of that existing quantity type. Values use kg, m, s, K and mol.
The molar equation of state is a phenomenological relation, not a derivation
from Physlib's normalized finite-particle Hamiltonian.
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
This relation retains an explicit molar gas constant; it introduces no axioms.
The parameter `R` denotes the universal gas constant, whose numerical value
is unnecessary for the substitution theorem. Physical-domain restrictions
belong to the state model rather than this algebraic equation. -/
def MolarIdealGasLaw (p : Pressure) (V : Volume) (n : Amount)
    (R : MolarGasConstant) (T : AbsoluteTemperature) : Prop :=
  p.val * V.val = n.val * R.val * T.val

end LeanVerificationDemo.PhyslibTemp.Thermodynamics
