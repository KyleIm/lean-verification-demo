import LeanVerificationDemo.PhysicsDemo.P14.Problem

namespace LeanVerificationDemo.PhysicsDemo.P14.Candidate
open ClassicalMechanics

lemma hooke_force (data : CoupledPendulumData) (mode : Mode) (φ : ℝ) :
    springForce data mode φ = data.springConstant * springExtension data mode φ := by
  rw [springForce, HarmonicOscillator.force_eq_linear]
  simp [springModel]

/-- The two prescribed modes keep the spring horizontal exactly. -/
lemma equal_bob_heights (data : CoupledPendulumData) (mode : Mode) (φ : ℝ) :
    (firstBob data φ).2 = (secondBob data mode φ).2 := by
  cases mode <;> simp [firstBob, secondBob, partnerAngle]

lemma in_phase_extension (data : CoupledPendulumData) (φ : ℝ) :
    springExtension data .inPhase φ = 0 := by
  simp [springExtension, firstBob, secondBob, partnerAngle]

/-- Positive φ moves the left bob left and the right bob right. Signed
extension also covers the opposite half-cycle, where the spring compresses. -/
lemma anti_phase_extension (data : CoupledPendulumData) (φ : ℝ) :
    springExtension data .antiPhase φ = 2 * data.length * Real.sin φ := by
  simp [springExtension, firstBob, secondBob, partnerAngle]
  ring

/-- Bob order is preserved on a neighbourhood of equilibrium; thus the
signed horizontal separation really is the spring length there. -/
lemma bobs_ordered_near_equilibrium (data : CoupledPendulumData) (mode : Mode) :
    ∀ᶠ φ in nhds (0 : ℝ), (firstBob data φ).1 < (secondBob data mode φ).1 := by
  have hc : Continuous (fun φ => (secondBob data mode φ).1 - (firstBob data φ).1) := by
    cases mode <;> unfold firstBob secondBob partnerAngle <;> fun_prop
  have h0 : 0 < (secondBob data mode 0).1 - (firstBob data 0).1 := by
    cases mode <;> simpa [firstBob, secondBob, partnerAngle] using data.separation_pos
  have he : ∀ᶠ φ in nhds (0 : ℝ),
      0 < (secondBob data mode φ).1 - (firstBob data φ).1 :=
    (hc.tendsto 0) (Ioi_mem_nhds h0)
  filter_upwards [he] with φ hφ
  linarith

lemma spring_length_from_geometry (data : CoupledPendulumData) (mode : Mode) (φ : ℝ)
    (ordered : (firstBob data φ).1 < (secondBob data mode φ).1) :
    springLength data mode φ - data.separation = springExtension data mode φ := by
  unfold springLength
  rw [← equal_bob_heights, sub_self]
  simp only [zero_pow (by decide : (2 : ℕ) ≠ 0), add_zero, Real.sqrt_sq_eq_abs]
  rw [abs_of_pos (sub_pos.mpr ordered)]
  rfl

lemma physical_extension_near_equilibrium (data : CoupledPendulumData) (mode : Mode) :
    ∀ᶠ φ in nhds (0 : ℝ),
      springLength data mode φ - data.separation = springExtension data mode φ := by
  filter_upwards [bobs_ordered_near_equilibrium data mode] with φ ordered
  exact spring_length_from_geometry data mode φ ordered

lemma first_horizontal_tangent (data : CoupledPendulumData) (φ : ℝ) :
    deriv (fun θ => (firstBob data θ).1) φ = -data.length * Real.cos φ :=
  ((Real.hasDerivAt_sin φ).const_mul (-data.length)).deriv

lemma spring_torque_projection (data : CoupledPendulumData) (mode : Mode) (φ : ℝ) :
    firstTorque data mode φ = (pendulum data).torque (EuclideanSpace.single 0 φ) 0 +
      springForce data mode φ * deriv (fun θ => (firstBob data θ).1) φ := by
  rw [first_horizontal_tangent, firstTorque]
  ring

lemma gravity_torque (data : CoupledPendulumData) (φ : ℝ) :
    (pendulum data).torque (EuclideanSpace.single 0 φ) 0 =
      -(data.mass * data.gravity * data.length * Real.sin φ) := by
  rw [SimplePendulum.torque_apply]
  simp [pendulum]

lemma in_phase_torque (data : CoupledPendulumData) (φ : ℝ) :
    firstTorque data .inPhase φ =
      -(data.mass * data.gravity * data.length) * Real.sin φ := by
  rw [spring_torque_projection, gravity_torque, hooke_force, in_phase_extension]
  ring

/-- Source restoring force times -l gives the signed torque. The cosine is
the projection onto the bob's tangent, not an approximation at this stage. -/
lemma anti_phase_torque (data : CoupledPendulumData) (φ : ℝ) :
    firstTorque data .antiPhase φ =
      -(data.mass * data.gravity * data.length) * Real.sin φ -
        (2 * data.springConstant * data.length ^ 2) * (Real.sin φ * Real.cos φ) := by
  rw [spring_torque_projection, gravity_torque, hooke_force, anti_phase_extension,
    first_horizontal_tangent]
  ring

lemma source_restoring_force (data : CoupledPendulumData) (φ : ℝ) :
    -firstTorque data .antiPhase φ / data.length =
      data.mass * data.gravity * Real.sin φ +
        2 * data.springConstant * data.length * Real.sin φ * Real.cos φ := by
  rw [anti_phase_torque]
  field_simp [data.length_pos.ne']
  <;> ring

lemma second_in_phase_torque (data : CoupledPendulumData) (φ : ℝ) :
    secondTorque data .inPhase φ = firstTorque data .inPhase φ := by
  simp [secondTorque, firstTorque, hooke_force, in_phase_extension, partnerAngle]

lemma second_anti_phase_torque (data : CoupledPendulumData) (φ : ℝ) :
    secondTorque data .antiPhase φ = -firstTorque data .antiPhase φ := by
  simp only [secondTorque, partnerAngle, gravity_torque, Real.sin_neg, Real.cos_neg]
  rw [anti_phase_torque, hooke_force, anti_phase_extension]
  ring

/-- Exact differentiation at φ=0 supplies the first-order model. -/
lemma in_phase_torque_derivative (data : CoupledPendulumData) :
    deriv (firstTorque data .inPhase) 0 = -(data.mass * data.gravity * data.length) := by
  have h := (Real.hasDerivAt_sin 0).const_mul (-(data.mass * data.gravity * data.length))
  have hf : firstTorque data .inPhase =
      fun φ => -(data.mass * data.gravity * data.length) * Real.sin φ :=
    funext (in_phase_torque data)
  rw [hf]
  simpa only [Real.cos_zero, mul_one] using h.deriv

lemma anti_phase_torque_derivative (data : CoupledPendulumData) :
    deriv (firstTorque data .antiPhase) 0 =
      -(data.mass * data.gravity * data.length + 2 * data.springConstant * data.length ^ 2) := by
  have h := ((Real.hasDerivAt_sin 0).const_mul
    (-(data.mass * data.gravity * data.length))).sub
    (((Real.hasDerivAt_sin 0).mul (Real.hasDerivAt_cos 0)).const_mul
      (2 * data.springConstant * data.length ^ 2))
  have hf : firstTorque data .antiPhase = fun φ =>
      -(data.mass * data.gravity * data.length) * Real.sin φ -
        (2 * data.springConstant * data.length ^ 2) * (Real.sin φ * Real.cos φ) :=
    funext (anti_phase_torque data)
  rw [hf]
  convert h.deriv using 1 <;> simp <;> ring

lemma linearized_in_phase (data : CoupledPendulumData) (φ : ℝ) :
    linearizedFirstTorque data .inPhase φ = -(data.mass * data.gravity * data.length) * φ ∧
    linearizedSecondTorque data .inPhase φ = linearizedFirstTorque data .inPhase φ := by
  constructor
  · rw [linearizedFirstTorque, in_phase_torque_derivative]
  · unfold linearizedSecondTorque linearizedFirstTorque
    rw [show secondTorque data .inPhase = firstTorque data .inPhase from
      funext (second_in_phase_torque data)]

lemma linearized_anti_phase (data : CoupledPendulumData) (φ : ℝ) :
    linearizedFirstTorque data .antiPhase φ =
      -(data.mass * data.gravity * data.length + 2 * data.springConstant * data.length ^ 2) * φ ∧
    linearizedSecondTorque data .antiPhase φ = -linearizedFirstTorque data .antiPhase φ := by
  constructor
  · rw [linearizedFirstTorque, anti_phase_torque_derivative]
  · unfold linearizedSecondTorque linearizedFirstTorque
    rw [show secondTorque data .antiPhase = (fun φ => -firstTorque data .antiPhase φ) from
      funext (second_anti_phase_torque data)]
    have hn := deriv.neg (f := firstTorque data .antiPhase) (x := (0 : ℝ))
    have hn' : deriv (fun φ => -firstTorque data .antiPhase φ) 0 =
        -deriv (firstTorque data .antiPhase) 0 := hn
    rw [hn']
    ring

/-- The existing upstream small-angle pendulum API supplies the in-phase
oscillator. The additional spring stiffness comes from the derivative above. -/
noncomputable def antiPhaseOscillator (data : CoupledPendulumData) : HarmonicOscillator where
  m := (pendulum data).inertia
  k := data.mass * data.gravity * data.length + 2 * data.springConstant * data.length ^ 2
  m_pos := (pendulum data).inertia_pos
  k_pos := by have := data.mass_pos; have := data.gravity_pos
              have := data.length_pos; have := data.spring_pos; positivity

lemma in_phase_angular_frequency (data : CoupledPendulumData) :
    (pendulum data).toHarmonicOscillator.ω = Real.sqrt (data.gravity / data.length) := by
  rw [SimplePendulum.toHarmonicOscillator_ω]
  rfl

lemma anti_phase_angular_frequency (data : CoupledPendulumData) :
    (antiPhaseOscillator data).ω =
      Real.sqrt (data.gravity / data.length + 2 * data.springConstant / data.mass) := by
  unfold HarmonicOscillator.ω antiPhaseOscillator SimplePendulum.inertia pendulum
  congr 1
  field_simp [data.length_pos.ne', data.mass_pos.ne']

lemma in_phase_valid (data : CoupledPendulumData) :
    IsModeFrequency data .inPhase (pendulum data).toHarmonicOscillator.ω := by
  refine ⟨HarmonicOscillator.ω_pos _, ?_⟩
  intro φ
  have hs := SimplePendulum.ω_sq_mul_inertia (pendulum data)
  change (pendulum data).ω ^ 2 * (pendulum data).inertia =
    data.mass * data.gravity * data.length at hs
  rw [SimplePendulum.toHarmonicOscillator_ω]
  constructor
  · rw [(linearized_in_phase data φ).1]
    rw [← hs]
    ring
  · rw [(linearized_in_phase data φ).2, (linearized_in_phase data φ).1]
    rw [← hs]
    simp only [partnerAngle]
    ring

lemma anti_phase_valid (data : CoupledPendulumData) :
    IsModeFrequency data .antiPhase (antiPhaseOscillator data).ω := by
  refine ⟨HarmonicOscillator.ω_pos _, ?_⟩
  intro φ
  have hs := HarmonicOscillator.ω_sq (antiPhaseOscillator data)
  have hi := (pendulum data).inertia_pos
  have hk : (pendulum data).inertia * (antiPhaseOscillator data).ω ^ 2 =
      data.mass * data.gravity * data.length + 2 * data.springConstant * data.length ^ 2 := by
    rw [hs]
    change (pendulum data).inertia *
      ((data.mass * data.gravity * data.length + 2 * data.springConstant * data.length ^ 2) /
        (pendulum data).inertia) = _
    field_simp
  constructor
  · rw [(linearized_anti_phase data φ).1]
    rw [← hk]
    ring
  · rw [(linearized_anti_phase data φ).2, (linearized_anti_phase data φ).1]
    simp only [partnerAngle]
    rw [← hk]
    ring

/-- Positive frequency selects one square root; both bob equations were checked. -/
lemma mode_frequency_unique (data : CoupledPendulumData) (mode : Mode) {ω ν : ℝ}
    (hω : IsModeFrequency data mode ω) (hν : IsModeFrequency data mode ν) : ω = ν := by
  have h1 := (hω.2 1).1
  have h2 := (hν.2 1).1
  have hi := (pendulum data).inertia_pos
  apply (sq_eq_sq₀ hω.1.le hν.1.le).mp
  nlinarith

/-- Computed answer, first supplied here on the Candidate side, in radians/time. -/
noncomputable def solutionFrequencies (data : CoupledPendulumData) : ModeFrequencies where
  inPhase := Real.sqrt (data.gravity / data.length)
  antiPhase := Real.sqrt (data.gravity / data.length + 2 * data.springConstant / data.mass)

lemma solutionFrequencies_valid (data : CoupledPendulumData) :
    IsModeFrequencySolution data (solutionFrequencies data) := by
  have hIn := in_phase_valid data
  have hAnti := anti_phase_valid data
  rw [in_phase_angular_frequency] at hIn
  rw [anti_phase_angular_frequency] at hAnti
  exact ⟨hIn, hAnti⟩

/-- Find ω_in=√(g/l) and ω_anti=√(g/l+2k/m) in the linearized model.
The trusted target asks for witnesses; the formulas are computed in Candidate. -/
theorem solution (data : CoupledPendulumData) : TrustedPhysicsProblem data := by
  have valid : IsModeFrequencySolution data
      ⟨Real.sqrt (data.gravity / data.length),
        Real.sqrt (data.gravity / data.length + 2 * data.springConstant / data.mass)⟩ :=
    solutionFrequencies_valid data
  refine ⟨solutionFrequencies data, valid, ?_⟩
  intro other hOther
  apply ModeFrequencies.ext
  · exact mode_frequency_unique data .inPhase hOther.1 valid.1
  · exact mode_frequency_unique data .antiPhase hOther.2 valid.2

end LeanVerificationDemo.PhysicsDemo.P14.Candidate
