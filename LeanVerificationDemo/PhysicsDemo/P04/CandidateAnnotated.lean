import LeanVerificationDemo.PhysicsDemo.P04.Problem

namespace LeanVerificationDemo.PhysicsDemo.P04.CandidateAnnotated
open PhyslibTemp.Electromagnetism Vertex

/-- Concrete vertex enumeration for checking sums against the diagram. -/
lemma all_vertices : (Finset.univ : Finset Vertex) = {A,B,v1,v2,v3,v4,v5,v6} := by decide

/-- Unit-capacitance charge residuals computed from the twelve caption edges. -/
def residual (φ : Vertex → Voltage) : Vertex → ℝ
  | A => 3 * (φ A).val - (φ v1).val - (φ v2).val - (φ v3).val
  | B => 3 * (φ B).val - (φ v4).val - (φ v5).val - (φ v6).val
  | v1 => 3 * (φ v1).val - (φ A).val - (φ v4).val - (φ v6).val
  | v2 => 3 * (φ v2).val - (φ A).val - (φ v5).val - (φ v6).val
  | v3 => 3 * (φ v3).val - (φ A).val - (φ v4).val - (φ v5).val
  | v4 => 3 * (φ v4).val - (φ v1).val - (φ v3).val - (φ B).val
  | v5 => 3 * (φ v5).val - (φ v2).val - (φ v3).val - (φ B).val
  | v6 => 3 * (φ v6).val - (φ v1).val - (φ v2).val - (φ B).val

/-- Check the actual network sums, rather than assuming the desired layer topology. -/
lemma charge_formula (data : CubeData) (φ : Vertex → Voltage) (i : Vertex) :
    ((network data).nodeCharge φ i).val = data.C.val * residual φ i := by
  -- Expand the generic signed node-charge sum using precisely the caption edges.
  cases i <;>
    simp [CapacitorNetwork.nodeCharge, network, all_vertices, Adj, diagramEdges, residual] <;> ring

/-- Solve the six neutral-conductor equations. Equal potentials within each layer
are derived from the caption's network, not taken as symmetry assumptions. -/
lemma internal_potentials (data : CubeData) (φ : Vertex → Voltage)
    (h : (network data).NeutralInterior A B φ) :
    (φ v1).val = (3 * (φ A).val + 2 * (φ B).val) / 5 ∧
    (φ v2).val = (φ v1).val ∧ (φ v3).val = (φ v1).val ∧
    (φ v4).val = (2 * (φ A).val + 3 * (φ B).val) / 5 ∧
    (φ v5).val = (φ v4).val ∧ (φ v6).val = (φ v4).val := by
  have balance (i : Vertex) (hiA : i ≠ A) (hiB : i ≠ B) : residual φ i = 0 := by
    have hz := h i hiA hiB
    rw [charge_formula] at hz
    exact (mul_eq_zero.mp hz).resolve_left data.C_pos.ne'
  -- These are six neutral-node equations; no equipotential evidence is supplied.
  have h1 := balance v1 (by decide) (by decide)
  have h2 := balance v2 (by decide) (by decide)
  have h3 := balance v3 (by decide) (by decide)
  have h4 := balance v4 (by decide) (by decide)
  have h5 := balance v5 (by decide) (by decide)
  have h6 := balance v6 (by decide) (by decide)
  simp only [residual] at h1 h2 h3 h4 h5 h6
  -- Linear elimination establishes equal potentials and their boundary dependence.
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> linarith

/-- Explicit equilibrium for arbitrary terminal potentials; no nonzero voltage
assumption is necessary. The interior values also prove existence of a state. -/
noncomputable def equilibrium (a b : Voltage) : Vertex → Voltage
  | A => a
  | B => b
  | v1 | v2 | v3 => ⟨(3 * a.val + 2 * b.val) / 5⟩
  | v4 | v5 | v6 => ⟨(2 * a.val + 3 * b.val) / 5⟩

lemma equilibrium_is_state (data : CubeData) (a b : Voltage) :
    (network data).DirichletState A B a b (equilibrium a b) := by
  refine ⟨rfl, rfl, ?_⟩
  intro i hiA hiB
  rw [charge_formula]
  have hr : residual (equilibrium a b) i = 0 := by
    cases i <;> simp_all [residual, equilibrium] <;> ring
  rw [hr, mul_zero]

/-- The terminal charge coefficient is 6C/5 for every admissible equilibrium. -/
lemma terminal_charge (data : CubeData) (φ : Vertex → Voltage)
    (h : (network data).NeutralInterior A B φ) :
    ((network data).nodeCharge φ A).val =
      (answer data).val * ((φ A).val - (φ B).val) := by
  obtain ⟨h1, h2, h3, _, _, _⟩ := internal_potentials data φ h
  rw [charge_formula]
  change data.C.val * (3 * (φ A).val - (φ v1).val - (φ v2).val - (φ v3).val) =
    ((6 / 5 : ℝ) * data.C.val) * ((φ A).val - (φ B).val)
  rw [h2, h3, h1]
  ring

/-- The original caption network, with neutral internal conductors, realizes 6C/5. -/
theorem solution (data : CubeData) : TrustedPhysicsProblem data := by
  -- Establish existence for all boundary potentials before proving the charge law.
  constructor
  · intro a b
    exact ⟨equilibrium a b, equilibrium_is_state data a b⟩
  · exact terminal_charge data

end LeanVerificationDemo.PhysicsDemo.P04.CandidateAnnotated
