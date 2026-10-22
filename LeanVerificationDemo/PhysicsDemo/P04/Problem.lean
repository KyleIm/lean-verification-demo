import LeanVerificationDemo.PhyslibTemp.Electromagnetism.CapacitorNetwork

namespace LeanVerificationDemo.PhysicsDemo.P04
open PhyslibTemp.Electromagnetism

/-- Labels are taken directly from the diagram caption, not inferred from an image. -/
inductive Vertex where
  | A | B | v1 | v2 | v3 | v4 | v5 | v6
  deriving DecidableEq

open Vertex

instance : Fintype Vertex where
  elems := {A, B, v1, v2, v3, v4, v5, v6}
  complete x := by cases x <;> simp

/-- The twelve undirected capacitor edges, listed once in the caption's orientation. -/
def diagramEdges : Finset (Vertex × Vertex) :=
  {(A,v1), (A,v2), (A,v3), (v1,v4), (v1,v6), (v2,v5),
   (v2,v6), (v3,v4), (v3,v5), (v4,B), (v5,B), (v6,B)}

/-- Adjacency is derived from the caption, including the reverse of each listed edge. -/
def Adj (i j : Vertex) : Prop := (i,j) ∈ diagramEdges ∨ (j,i) ∈ diagramEdges

instance : DecidableRel Adj := fun i j => inferInstanceAs
  (Decidable ((i,j) ∈ diagramEdges ∨ (j,i) ∈ diagramEdges))

/-- All edge capacitors have the same strictly positive capacitance. -/
structure CubeData where
  C : Capacitance
  C_pos : 0 < C.val

/-- The diagram caption is the sole source of connectivity for this network. -/
noncomputable def network (data : CubeData) : CapacitorNetwork Vertex where
  capacitance i j := if Adj i j then data.C else ⟨0⟩
  symmetric i j := by
    simp only [Adj, or_comm]
    rfl
  nonneg i j := by
    split
    · exact data.C_pos.le
    · exact le_refl 0
  diagonal i := by
    have hi : ¬ Adj i i := by cases i <;> decide
    simp [hi]

/-- Claimed equivalent capacitance, dimension-tagged in farads. -/
noncomputable def answer (data : CubeData) : Capacitance := ⟨(6 / 5 : ℝ) * data.C.val⟩

/-- The cube's terminal charge law and solvability at arbitrary boundary potentials.
Equipotential layers and the final coefficient are not supplied as premises. -/
def TrustedPhysicsProblem (data : CubeData) : Prop :=
  (network data).HasEquivalentCapacitance A B (answer data)

end LeanVerificationDemo.PhysicsDemo.P04
