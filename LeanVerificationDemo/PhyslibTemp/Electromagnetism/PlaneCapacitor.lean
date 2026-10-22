import LeanVerificationDemo.PhyslibTemp.Electromagnetism.CapacitorBasics
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

/-!
# Ideal plane capacitors in fixed coherent SI coordinates

Shared charge, voltage and capacitance coordinates come from `CapacitorBasics`.
The plane-specific field and separation aliases specialize Physlib `WithDim`;
no new unit framework is introduced.
The model assumes a uniform field, linear dielectric, negligible fringe effects
and leakage. Voltages/charges are magnitudes. Breakdown is an optional additional
specification provided by `DielectricBreakdown.lean`; it is not intrinsic capacitor data.
-/
namespace LeanVerificationDemo.PhyslibTemp.Electromagnetism

open Dimension

/-- Uniform electric-field magnitude in volts per metre. -/
abbrev FieldMagnitude := WithDim (M𝓭 * L𝓭 / T𝓭 ^ 2 / C𝓭) ℝ
/-- Separation coordinate in metres. -/
abbrev Separation := WithDim L𝓭 ℝ

/-- Ideal linear plane capacitor with positive capacitance and gap.
No dielectric-failure specification is required to use this basic model. -/
structure PlaneCapacitor where
  C : Capacitance
  gap : Separation
  C_pos : 0 < C.val
  gap_pos : 0 < gap.val

namespace PlaneCapacitor

/-- Constitutive capacitor law U = Q/C, in fixed coherent SI coordinates. -/
noncomputable def voltage (c : PlaneCapacitor) (q : Charge) : Voltage :=
  ⟨q.val / c.C.val⟩

/-- Uniform plane-gap field E = U/d; no general field reconstruction is claimed. -/
noncomputable def field (c : PlaneCapacitor) (q : Charge) : FieldMagnitude :=
  ⟨(c.voltage q).val / c.gap.val⟩

/-- Uniform-field voltage relation U = E d. -/
lemma voltage_eq_field_mul_gap (c : PlaneCapacitor) (q : Charge) :
    (c.voltage q).val = (c.field q).val * c.gap.val := by
  dsimp [field]
  exact (div_mul_cancel₀ _ c.gap_pos.ne').symm

end PlaneCapacitor

/-- At fixed plate area and separation, a relative-permittivity factor multiplies
capacitance. Equal gap is represented explicitly. Equal plate area and the
remaining fixed-geometry assumptions are supplied externally: plate area is not
a field of `PlaneCapacitor`. This is a constitutive premise, not a derivation
from C = ε A/d or Maxwell equations. -/
def DielectricScaling (reference filled : PlaneCapacitor) (εr : ℝ) : Prop :=
  filled.gap = reference.gap ∧ filled.C.val = εr * reference.C.val

/-- Equal-magnitude series charge and dielectric scaling imply inverse voltage scaling.
The common argument q expresses the series-charge premise, not a circuit theorem. -/
lemma voltage_of_dielectric_scaling (a b : PlaneCapacitor) (εr : ℝ)
    (h : DielectricScaling a b εr) (q : Charge) :
    (b.voltage q).val = (a.voltage q).val / εr := by
  change q.val / b.C.val = (q.val / a.C.val) / εr
  rw [h.2]
  have arithmetic (x y z : ℝ) : x / (z * y) = (x / y) / z := by
    rw [div_div]
    congr 1
    ring
  exact arithmetic q.val a.C.val εr

end LeanVerificationDemo.PhyslibTemp.Electromagnetism
