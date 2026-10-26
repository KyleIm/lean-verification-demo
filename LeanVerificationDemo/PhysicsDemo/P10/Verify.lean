import LeanVerificationDemo.PhysicsDemo.P10.Units

namespace LeanVerificationDemo.PhysicsDemo.P10.Verifier

example : TrustedPhysicsProblem := Candidate.solution
example (i : Fin 9) : velocity (time i) = ordinate i := Candidate.velocity_at_vertices i
example (i : Fin 8) :
    Set.EqOn velocity (segment i) (Set.Icc (time i.castSucc) (time i.succ)) :=
  Candidate.velocity_on_segment i

-- Nonvertex samples guard against mistaking the graph for position or steps.
example : velocity (5 / 2) = 2 := by
  norm_num [velocity, segment, linearSegment, time, ordinate]
example : velocity 4 = 7 / 2 := by
  norm_num [velocity, segment, linearSegment, time, ordinate]
example : velocity 8 = 5 / 2 := by
  norm_num [velocity, segment, linearSegment, time, ordinate]

example : pathTravelled 5 = 21 / 2 := by
  rw [Candidate.path_eq_displacement (by norm_num) (by norm_num), Candidate.distance_first_five]
example : pathTravelled 10 = 25 := by
  rw [Candidate.path_eq_displacement (by norm_num) (by norm_num), Candidate.distance_first_ten]

-- This is specifically not a general path = signed displacement principle.
example : (∫ _t in (0 : ℝ)..1, |(-1 : ℝ)|) ≠ (∫ _t in (0 : ℝ)..1, (-1 : ℝ)) := by
  norm_num

example : Units.typedMeanVelocity 5 = (⟨21 / 10⟩ : Units.Velocity) := Units.typed_answers.1
example : Units.typedMeanAcceleration 5 = (⟨4 / 5⟩ : Units.Acceleration) := Units.typed_answers.2.1
example : Units.typedMeanVelocity 10 = (⟨5 / 2⟩ : Units.Velocity) := Units.typed_answers.2.2.1
example : Units.typedMeanAcceleration 10 = (⟨1 / 5⟩ : Units.Acceleration) := Units.typed_answers.2.2.2
example : Units.graphUnits.length = LengthUnit.centimeters := rfl
example : Units.graphUnits.time = TimeUnit.seconds := rfl

end LeanVerificationDemo.PhysicsDemo.P10.Verifier
