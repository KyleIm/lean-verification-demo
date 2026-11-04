import LeanVerificationDemo.PhysicsDemo.P14.Units

namespace LeanVerificationDemo.PhysicsDemo.P14.Verifier

/-- An independent consistency example, not numerical data from problem 638.
Only physical parameters are stored; no answer fields are supplied. -/
def exampleSystem : CoupledPendulumData where
  length := 2
  mass := 2
  springConstant := 5
  gravity := 8
  separation := 3
  length_pos := by norm_num
  mass_pos := by norm_num
  spring_pos := by norm_num
  gravity_pos := by norm_num
  separation_pos := by norm_num

example : TrustedPhysicsProblem exampleSystem := Candidate.solution exampleSystem
lemma example_in_frequency : (Candidate.solutionFrequencies exampleSystem).inPhase = 2 := by
  change Real.sqrt ((8 : ℝ) / 2) = 2
  rw [show (8 : ℝ) / 2 = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
lemma example_anti_frequency : (Candidate.solutionFrequencies exampleSystem).antiPhase = 3 := by
  change Real.sqrt ((8 : ℝ) / 2 + 2 * 5 / 2) = 3
  rw [show (8 : ℝ) / 2 + 2 * 5 / 2 = 3 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
example : IsModeFrequency exampleSystem .inPhase 2 := by
  simpa only [example_in_frequency] using
    (Candidate.solutionFrequencies_valid exampleSystem).1
example : IsModeFrequency exampleSystem .antiPhase 3 := by
  simpa only [example_anti_frequency] using
    (Candidate.solutionFrequencies_valid exampleSystem).2

example (data : CoupledPendulumData) : data.length ≠ 0 ∧ data.mass ≠ 0 :=
  ⟨data.length_pos.ne', data.mass_pos.ne'⟩
example (data : CoupledPendulumData) (mode : Mode) : ¬ IsModeFrequency data mode 0 := by
  intro h
  exact (lt_irrefl 0) h.1
example : ¬ IsModeFrequency exampleSystem .antiPhase 2 := by
  intro h
  have h3 : IsModeFrequency exampleSystem .antiPhase 3 := by
    simpa only [example_anti_frequency] using
      (Candidate.solutionFrequencies_valid exampleSystem).2
  have := Candidate.mode_frequency_unique exampleSystem .antiPhase h h3
  norm_num at this

example (data : CoupledPendulumData) (φ : ℝ) : springExtension data .inPhase φ = 0 :=
  Candidate.in_phase_extension data φ
example (data : CoupledPendulumData) : springExtension data .antiPhase 0 = 0 := by
  rw [Candidate.anti_phase_extension]
  simp
example (data : CoupledPendulumData) (mode : Mode) (φ : ℝ) :
    (firstBob data φ).2 = (secondBob data mode φ).2 :=
  Candidate.equal_bob_heights data mode φ

-- Both symmetric modes retain actual ordered, horizontal spring geometry locally.
example (data : CoupledPendulumData) (mode : Mode) :
    ∀ᶠ φ in nhds (0 : ℝ), (firstBob data φ).1 < (secondBob data mode φ).1 :=
  Candidate.bobs_ordered_near_equilibrium data mode

-- The mode answers are checked against both bob torque equations, not just a
-- stored square-root answer. Candidate reuses upstream oscillator frequencies.
example (data : CoupledPendulumData) :
    (pendulum data).toHarmonicOscillator.ω =
      (Candidate.solutionFrequencies data).inPhase :=
  Candidate.in_phase_angular_frequency data
example (data : CoupledPendulumData) :
    (Candidate.antiPhaseOscillator data).ω =
      (Candidate.solutionFrequencies data).antiPhase :=
  Candidate.anti_phase_angular_frequency data

example : Units.springDim / Dimension.M𝓭 = Units.squaredAngularFrequencyDim :=
  Units.spring_over_mass_dimension
example (data : CoupledPendulumData) :
    Units.angularRoot (Units.squaredAntiPhase ⟨data.gravity⟩ ⟨data.length⟩
      ⟨data.springConstant⟩ ⟨data.mass⟩) =
      (⟨(Candidate.solutionFrequencies data).antiPhase⟩ : Units.AngularFrequency) :=
  Units.typed_anti_phase data

end LeanVerificationDemo.PhysicsDemo.P14.Verifier
