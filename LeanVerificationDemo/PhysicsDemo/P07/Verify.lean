import LeanVerificationDemo.PhysicsDemo.P07.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P07.Verifier

example (data : RingData) (response : Response data) :
    TrustedPhysicsProblem data response := Candidate.solution data response

/-- Consistency witness for the local physical relations, independent of the
final integrated answer. It supplies only an emf and current-per-width field. -/
noncomputable def exampleResponse (data : RingData) : Response data where
  emf x _ := sourceFactor * (Real.pi * x ^ 2 * data.k)
  currentPerWidth x _ := (sourceFactor * data.k * data.h.val / (2 * data.ρ.val)) * x
  faraday x _ t := by rw [Candidate.flux_derivative]
  ohm x _ t := by
    dsimp [resistanceCoefficient]
    field_simp [data.ρ_pos.ne', data.h_pos.ne']

example (data : RingData) : Nonempty (Response data) := ⟨exampleResponse data⟩

example : Nonempty RingData := by
  refine ⟨{
    a := ⟨1⟩
    b := ⟨2⟩
    h := ⟨1⟩
    ρ := ⟨1⟩
    k := 1
    a_pos := by norm_num
    a_lt_b := by norm_num
    h_pos := by norm_num
    ρ_pos := by norm_num
    k_pos := by norm_num
  }⟩

end LeanVerificationDemo.PhysicsDemo.P07.Verifier
