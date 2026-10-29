import LeanVerificationDemo.PhysicsDemo.P12.Units
import LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.ConstantAccelerationExamples

namespace LeanVerificationDemo.PhysicsDemo.P12.Verifier
open LeanVerificationDemo.PhyslibTemp.ClassicalMechanics

example : TrustedPhysicsProblem := Candidate.solution

/-- Test-only constructive model for each source row: choose the deceleration
from speed/distance, then obtain μ as force/normal reaction. No rounded answer
is inserted in this witness. Every one of the 70 physical observations exists. -/
noncomputable def rate (p : Pavement) (i : Fin 10) : ℝ :=
  speedSI i ^ 2 / (2 * brakingDistance p i)
noncomputable def duration (p : Pavement) (i : Fin 10) : ℝ :=
  2 * brakingDistance p i / speedSI i

lemma rate_pos (p : Pavement) (i : Fin 10) : 0 < rate p i := by
  have hv := Candidate.table_speeds_positive i
  have hs := Candidate.table_distances_positive p i
  unfold rate
  positivity

lemma duration_pos (p : Pavement) (i : Fin 10) : 0 < duration p i := by
  have hv := Candidate.table_speeds_positive i
  have hs := Candidate.table_distances_positive p i
  unfold duration
  positivity

noncomputable def rowParticle (p : Pavement) (i : Fin 10) : trackFrame.Particle :=
  Examples.quadraticParticle ⟨1, by norm_num⟩ 0 ((speedSI i) • tangent)
    ((-rate p i) • tangent)

lemma row_speed (p : Pavement) (i : Fin 10) (t : ℝ) :
    speed (rowParticle p i) t = speedSI i - rate p i * t := by
  unfold speed rowParticle
  rw [Examples.quadratic_velocity]
  change speedSI i * 1 + t * (-rate p i * 1) = speedSI i - rate p i * t
  ring

lemma row_travel (p : Pavement) (i : Fin 10) (t : ℝ) :
    travel (rowParticle p i) t = t * speedSI i - rate p i * t ^ 2 / 2 := by
  unfold travel rowParticle Examples.quadraticParticle
  change (0 + t * (speedSI i * 1) + (t ^ 2 / 2) * (-rate p i * 1)) -
    (0 + 0 * (speedSI i * 1) + ((0 : ℝ) ^ 2 / 2) * (-rate p i * 1)) =
      t * speedSI i - rate p i * t ^ 2 / 2
  ring

noncomputable def witness (p : Pavement) (i : Fin 10) : BrakingRun where
  particle := rowParticle p i
  duration := duration p i
  duration_pos := duration_pos p i
  initialSpeed := speedSI i
  initialSpeed_pos := Candidate.table_speeds_positive i
  distance := brakingDistance p i
  distance_pos := Candidate.table_distances_positive p i
  g := gravity
  g_pos := by norm_num [gravity]
  μ := rate p i / gravity
  μ_nonneg := div_nonneg (rate_pos p i).le (by norm_num [gravity])
  normalReaction := gravity
  frictionMagnitude := rate p i

lemma witness_model (p : Pavement) (i : Fin 10) : BrakingModel (witness p i) := by
  have hv := (Candidate.table_speeds_positive i).ne'
  have hs := (Candidate.table_distances_positive p i).ne'
  constructor
  · change gravity = 1 * gravity
    ring
  · change rate p i = (rate p i / gravity) * gravity
    field_simp [gravity]
  · intro t
    have ha := Examples.quadratic_constant (frame := trackFrame) ⟨1, by norm_num⟩ 0
      ((speedSI i) • tangent) ((-rate p i) • tangent) t
    change (1 : ℝ) * ((rowParticle p i).acceleration t).components 0 = -rate p i
    change (rowParticle p i).acceleration t = (-rate p i) • tangent at ha
    rw [ha]
    change 1 * (-rate p i * 1) = -rate p i
    ring
  · change speed (rowParticle p i) 0 = speedSI i
    rw [row_speed]
    ring
  · change travel (rowParticle p i) (duration p i) = brakingDistance p i
    rw [row_travel]
    unfold duration rate
    field_simp [hv, hs] <;> ring
  · change speed (rowParticle p i) (duration p i) = 0
    rw [row_speed]
    unfold duration rate
    field_simp [hv, hs] <;> ring

lemma witness_observes (p : Pavement) (i : Fin 10) : ObservesRow (witness p i) p i :=
  ⟨rfl, rfl, rfl⟩

example (p : Pavement) (i : Fin 10) :
    ∃ run, BrakingModel run ∧ ObservesRow run p i :=
  ⟨witness p i, witness_model p i, witness_observes p i⟩

example (p : Pavement) (i : Fin 10) :
    RoundsToTenth (witness p i).μ (Candidate.coefficient p) :=
  Candidate.physical_table_compatibility p i _ (witness_model p i) (witness_observes p i)

-- Exact decimals, essential conversion, no zero-speed/path rows.
example : (3.9 : ℝ) = 39 / 10 ∧ (0.78 : ℝ) = 39 / 50 ∧ (0.97 : ℝ) = 97 / 100 := by
  norm_num
example : speedSI 0 = (25 : ℝ) / 9 := by norm_num [speedSI, speedKmh]
example : Fintype.card Pavement * Fintype.card (Fin 10) = 70 := by decide

-- Tie convention is executable; every real table estimate avoids these ties.
example : RoundsToTenth (15 / 100 : ℝ) (2 / 10) := by norm_num [RoundsToTenth]
example : ¬ RoundsToTenth (15 / 100 : ℝ) (1 / 10) := by norm_num [RoundsToTenth]
example (p : Pavement) (i : Fin 10) :
    Candidate.coefficient p - 1 / 20 < tableEstimate p i ∧
    tableEstimate p i < Candidate.coefficient p + 1 / 20 :=
  Candidate.all_estimates_inside_bands p i

-- Rounded speed independence does not assert exact equality of raw estimates.
example : tableEstimate .ice 0 ≠ tableEstimate .ice 9 := by
  norm_num [tableEstimate, frictionEstimate, speedSI, speedKmh, gravity, brakingDistance]

-- A deliberately wrong all-zero assignment fails the full-table criterion.
example : ¬ RoundedTable (fun _ => 0) := by
  intro h
  have hx := (h .ice).2 0
  norm_num [RoundsToTenth, tableEstimate, frictionEstimate, speedSI, speedKmh,
    gravity, brakingDistance] at hx

example (other : Pavement → ℝ) (h : TableSolution other) : other = Candidate.coefficient :=
  Candidate.table_solution_unique other h
example (p : Pavement) (i : Fin 10) :
    Units.coefficientRhs (Units.velocitySI i) (Units.gravityQuantity LTMCTUnitChoices.SI)
      (Units.distanceQuantity p i LTMCTUnitChoices.SI) =
        (⟨tableEstimate p i⟩ : Units.Coefficient) := Units.typed_table_estimate p i

end LeanVerificationDemo.PhysicsDemo.P12.Verifier
