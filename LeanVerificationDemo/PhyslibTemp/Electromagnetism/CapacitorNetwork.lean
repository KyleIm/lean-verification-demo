import LeanVerificationDemo.PhyslibTemp.Electromagnetism.PlaneCapacitor
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

/-!
# Finite ideal capacitor networks in fixed coherent SI coordinates

No gap or breakdown data are required. Capacitance weights are symmetric,
nonnegative and zero on the diagonal; zero represents no connecting capacitor.
Node charge is the signed sum Cij (Vi - Vj). Neutral interior nodes model
initially uncharged isolated internal conductors. This is a lumped electrostatic
constitutive model, not a circuit theorem derived from Maxwell equations.
-/
namespace LeanVerificationDemo.PhyslibTemp.Electromagnetism

/-- Finite ideal linear capacitive couplings; all values use coherent SI units. -/
structure CapacitorNetwork (ι : Type) [Fintype ι] where
  capacitance : ι → ι → Capacitance
  symmetric : ∀ i j, capacitance i j = capacitance j i
  nonneg : ∀ i j, 0 ≤ (capacitance i j).val
  diagonal : ∀ i, (capacitance i i).val = 0

namespace CapacitorNetwork

variable {ι : Type} [Fintype ι]

/-- Signed free charge on a conductor, obtained by summing incident plate charges. -/
noncomputable def nodeCharge (net : CapacitorNetwork ι) (φ : ι → Voltage) (i : ι) : Charge :=
  ⟨∑ j, (net.capacitance i j).val * ((φ i).val - (φ j).val)⟩

/-- Internal conductors carry zero net charge; terminal charges are unconstrained. -/
def NeutralInterior (net : CapacitorNetwork ι) (A B : ι) (φ : ι → Voltage) : Prop :=
  ∀ i, i ≠ A → i ≠ B → (net.nodeCharge φ i).val = 0

/-- Fixed terminal potentials and neutral internal conductors. -/
def DirichletState (net : CapacitorNetwork ι) (A B : ι) (a b : Voltage)
    (φ : ι → Voltage) : Prop :=
  φ A = a ∧ φ B = b ∧ net.NeutralInterior A B φ

/-- An equivalent capacitance requires a state for every pair of boundary potentials
and the terminal charge law for every neutral-interior state. This is stronger
than evaluating one selected state. Voltages may be equal; no division by ΔV occurs. -/
def HasEquivalentCapacitance (net : CapacitorNetwork ι) (A B : ι)
    (Ceq : Capacitance) : Prop :=
  (∀ a b, ∃ φ, net.DirichletState A B a b φ) ∧
  ∀ φ, net.NeutralInterior A B φ →
    (net.nodeCharge φ A).val = Ceq.val * ((φ A).val - (φ B).val)

end CapacitorNetwork
end LeanVerificationDemo.PhyslibTemp.Electromagnetism
