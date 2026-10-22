import LeanVerificationDemo.PhysicsDemo.P04.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P04.Verifier

example (data : CubeData) : TrustedPhysicsProblem data := Candidate.solution data

example (data : CubeData) : 0 < (answer data).val := Candidate.answer_pos data

-- Consistency of source assumptions: the common capacitance can be any positive value.
example : Nonempty CubeData := ⟨{ C := ⟨1⟩, C_pos := by norm_num }⟩

-- The caption has exactly twelve edges and no extra or missing named links.
example : diagramEdges.card = 12 := by decide

-- Check the caption's 3–6–3 edge counts; this is data validation, not an
-- assumption that the endpoints of a layer already have equal potential.
open Vertex in
example :
    (diagramEdges.filter (fun e => e.1 = A)).card = 3 ∧
    (diagramEdges.filter (fun e => e.1 ∈ ({v1,v2,v3} : Finset Vertex) ∧
      e.2 ∈ ({v4,v5,v6} : Finset Vertex))).card = 6 ∧
    (diagramEdges.filter (fun e => e.2 = B)).card = 3 := by decide

end LeanVerificationDemo.PhysicsDemo.P04.Verifier
