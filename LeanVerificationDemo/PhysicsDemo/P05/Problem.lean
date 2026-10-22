import LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.PlanarStatics
import LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.StaticFriction
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

namespace LeanVerificationDemo.PhysicsDemo.P05

open _root_.ClassicalMechanics PhyslibTemp.ClassicalMechanics

/-- A fixed Cartesian lab frame: x points away from the wall, y points upward. -/
noncomputable def labFrame : ReferenceFrame 2 where
  timeOrigin := ⟨0⟩
  origin := fun _ => ⟨fun _ => 0⟩
  basis := fun _ => (EuclideanSpace.basisFun (Fin 2) ℝ).toBasis

lemma labFrame_inertial : labFrame.IsInertial where
  origin_moves_uniformly := by
    refine ⟨0, ?_⟩
    intro t₁ t₂
    simp [labFrame]
  basis_conserved := fun _ _ => rfl

lemma labFrame_orthonormal : labFrame.Orthonormal := by
  intro t
  exact (EuclideanSpace.basisFun (Fin 2) ℝ).orthonormal

/-- P05 model parameters, not threshold conclusions. The ideal ladder is weightless,
against a smooth vertical wall on a horizontal rough floor. Units: m, N, radians.
The angle is acute; μ is nonnegative. The geometry stays fixed during the static
comparison. Force directions/positions below encode the stated contact idealization. -/
structure LadderData where
  length : ℝ
  length_pos : 0 < length
  alpha : ℝ
  alpha_pos : 0 < alpha
  alpha_lt : alpha < Real.pi / 2
  G : ℝ
  G_pos : 0 < G
  μ : ℝ
  μ_nonneg : 0 ≤ μ

/-- CB, the vertical height of the upper wall contact. -/
noncomputable def height (data : LadderData) : ℝ := data.length * Real.sin data.alpha

/-- AO is a distance along the ladder, not the vertical height. -/
def OnLadder (data : LadderData) (s : ℝ) : Prop := 0 ≤ s ∧ s ≤ data.length

/-- Unknown support-force coordinates. Signed floor friction is bounded by an absolute value. -/
structure Reactions where
  N1 : ℝ
  N2 : ℝ
  Ffr : ℝ

/-- One constant Physlib force acting on the modeled ladder/man body. -/
noncomputable def constantForce (x y : ℝ) : labFrame.Force Unit where
  value := fun _ => ⟨![x, y]⟩
  target := ()

/-- Forces indexed as wall normal, floor normal, floor friction, man's weight.
A smooth wall contributes no tangential force; no ladder-weight force is added. -/
noncomputable def forces (data : LadderData) (r : Reactions) : Fin 4 → labFrame.Force Unit :=
  ![constantForce r.N1 0, constantForce 0 r.N2,
    constantForce (-r.Ffr) 0, constantForce 0 (-data.G)]

/-- Displacements from O for the four forces. B=(-L cos α, L sin α),
A=(-s cos α,s sin α), both floor forces act at O. This coordinate
parameterization supplies the elementary projection geometry interpreted from
the printed solution/Fig. 311; it is not trusted problem-image topology. -/
noncomputable def positions (data : LadderData) (s : ℝ) : Fin 4 → labFrame.Vector :=
  ![⟨![-data.length * Real.cos data.alpha, height data]⟩, ⟨![0, 0]⟩, ⟨![0, 0]⟩,
    ⟨![-s * Real.cos data.alpha, s * Real.sin data.alpha]⟩]

/-- Static force and moment balance at an arbitrary snapshot (all forces are constant). -/
def EquilibriumAt (data : LadderData) (s : ℝ) (r : Reactions) : Prop :=
  PlanarStaticEquilibrium labFrame (positions data s) (forces data r) 0

/-- Existence of support forces respecting static balance, a compressive wall normal
and the Coulomb static-friction bound. Physical positions are separately OnLadder. -/
def AdmissibleAt (data : LadderData) (s : ℝ) : Prop :=
  ∃ r, EquilibriumAt data s r ∧ 0 ≤ r.N1 ∧ StaticFriction data.μ r.N2 r.Ffr

/-- Required friction predicted by force/moment balance; it must be proved below. -/
noncomputable def requiredFriction (data : LadderData) (s : ℝ) : ℝ :=
  data.G * Real.cos data.alpha * s / height data

/-- Derived-strengthening candidate for the critical AO, not a number given by the source. -/
noncomputable def criticalPosition (data : LadderData) : ℝ :=
  data.μ * height data / Real.cos data.alpha

/-- The qualitative answer: increasing required friction; exact admissibility
threshold on the ladder; saturation; admissibility at a reachable threshold;
and no admissible static equilibrium above it. No post-slip trajectory is asserted. -/
def TrustedPhysicsProblem (data : LadderData) : Prop :=
  StrictMono (requiredFriction data) ∧
  (∀ s, OnLadder data s → (AdmissibleAt data s ↔ s ≤ criticalPosition data)) ∧
  LimitingStaticFriction data.μ data.G (requiredFriction data (criticalPosition data)) ∧
  (OnLadder data (criticalPosition data) → AdmissibleAt data (criticalPosition data)) ∧
  (∀ s, OnLadder data s → criticalPosition data < s → ¬ AdmissibleAt data s)

end LeanVerificationDemo.PhysicsDemo.P05
