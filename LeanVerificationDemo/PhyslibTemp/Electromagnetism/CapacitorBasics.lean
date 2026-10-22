import Physlib.Units.WithDim.Basic

/-!
# Shared capacitor quantities in coherent SI coordinates

These aliases specialize Physlib's existing `WithDim` over the LTMCT basis.
They impose no plane geometry, network topology or dielectric-breakdown model.
Charge is signed; sign restrictions belong to the physical model using it.
-/
namespace LeanVerificationDemo.PhyslibTemp.Electromagnetism

open Dimension

/-- Charge coordinate in coulombs. -/
abbrev Charge := WithDim C𝓭 ℝ
/-- Voltage coordinate in volts (energy per charge). -/
abbrev Voltage := WithDim (M𝓭 * L𝓭 ^ 2 / T𝓭 ^ 2 / C𝓭) ℝ
/-- Capacitance coordinate in farads (charge per voltage). -/
abbrev Capacitance := WithDim (C𝓭 / (M𝓭 * L𝓭 ^ 2 / T𝓭 ^ 2 / C𝓭)) ℝ
end LeanVerificationDemo.PhyslibTemp.Electromagnetism
