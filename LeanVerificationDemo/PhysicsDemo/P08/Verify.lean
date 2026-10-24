import LeanVerificationDemo.PhysicsDemo.P08.Candidate
import LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.ConstantAccelerationExamples
import LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.ImpulseMomentumExamples

open LeanVerificationDemo.PhyslibTemp.ClassicalMechanics
open scoped BigOperators Topology
open Filter

namespace LeanVerificationDemo.PhysicsDemo.P08.Verifier

example (data : ExplosionData) (source : SourceData data) :
    TrustedPhysicsProblem data := Candidate.solution data source

/-- Explicit regularizations: internal forces grow like 1/ε, while the fixed
gravitational force stays bounded. No conservation equality is supplied. -/
noncomputable def down : Vector3 := WithLp.toLp 2 ((-1 : ℝ) • up).components

noncomputable def regularizedMomentum (u w : Vector3) (ε : ℝ) (i : Fin 3) (t : ℝ) :
    Vector3 :=
  (t / ε) • (![-(u + w), u, w] : Fin 3 → Vector3) i + t • down

noncomputable def regularizedInternal (u w : Vector3) (ε : ℝ) (i j : Fin 3)
    (_t : ℝ) : Vector3 :=
  ε⁻¹ • (![![0, -u, -w], ![u, 0, 0], ![w, 0, 0]] : Fin 3 → Fin 3 → Vector3) i j

lemma regularized_hasDerivAt (u w : Vector3) (ε : ℝ) (i : Fin 3) (t : ℝ) :
    HasDerivAt (regularizedMomentum u w ε i)
      (ε⁻¹ • (![-(u + w), u, w] : Fin 3 → Vector3) i + down) t := by
  convert! (((hasDerivAt_id t).div_const ε).smul_const
    ((![-(u + w), u, w] : Fin 3 → Vector3) i)).add
      ((hasDerivAt_id t).smul_const down) using 1
  simp [one_div]

/-- Consistent source inputs with arbitrary balancing fragment momenta.
No plane or coplanarity conclusion is part of this evidence. -/
noncomputable def balancingData (u w : Vector3) : ExplosionData where
  mass _ := 1
  mass_pos _ := by norm_num
  velocity := ![-(u + w), u, w]
  rocket := Examples.quadraticParticle ⟨3, by norm_num⟩ (0 : labFrame.Vector)
    (1 • up) ((-1 : ℝ) • up)
  initialSpeed := 1
  initialSpeed_pos := by norm_num
  g := 1
  g_pos := by norm_num
  eventMomentum := regularizedMomentum u w
  internalForce := regularizedInternal u w

lemma balancingSource (u w : Vector3) : SourceData (balancingData u w) := by
  constructor
  · exact Examples.quadratic_constant _ _ _ _
  · simp [balancingData, Examples.quadratic_velocity]
  · norm_num [balancingData, Fin.sum_univ_succ, Examples.quadraticParticle]
  · intro ε _hε
    constructor
    · intro i t
      convert regularized_hasDerivAt u w ε i t using 1
      · rfl
      · fin_cases i <;>
          simp [balancingData, regularizedInternal,
            gravityAcceleration, down, Fin.sum_univ_succ] <;> module
    · intro i j t
      fin_cases i <;> fin_cases j <;>
        simp [balancingData, regularizedInternal]
  · intro ε _hε i
    have hv : (balancingData u w).rocket.velocity (apexTime (balancingData u w)) = 0 := by
      change (Examples.quadraticParticle ⟨3, by norm_num⟩ (0 : labFrame.Vector)
        (1 • up) ((-1 : ℝ) • up)).velocity (1 / 1) = 0
      rw [Examples.quadratic_velocity]
      norm_num
    have ha : apexVelocity (balancingData u w) = 0 := by
      unfold apexVelocity
      rw [hv]
      rfl
    rw [ha]
    simp [balancingData, regularizedMomentum]
  · intro i
    have hε : Tendsto (fun ε : ℝ => ε) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) :=
      nhdsWithin_le_nhds
    have hconst : Tendsto
        (fun _ : ℝ => (![-(u + w), u, w] : Fin 3 → Vector3) i)
        (𝓝[>] (0 : ℝ)) (𝓝 ((![-(u + w), u, w] : Fin 3 → Vector3) i)) :=
      tendsto_const_nhds
    have hlim := hconst.add (hε.smul_const down)
    have heq : (fun ε => (balancingData u w).eventMomentum ε i ε) =ᶠ[𝓝[>] (0 : ℝ)]
        (fun ε => (![-(u + w), u, w] : Fin 3 → Vector3) i + ε • down) := by
      filter_upwards [self_mem_nhdsWithin] with ε hpos
      simp [balancingData, regularizedMomentum, (show 0 < ε from hpos).ne']
    have hlim' : Tendsto
        (fun ε => (![-(u + w), u, w] : Fin 3 → Vector3) i + ε • down)
        (𝓝[>] (0 : ℝ)) (𝓝 (momentum (balancingData u w) i)) := by
      simpa [momentum, balancingData] using hlim
    exact hlim'.congr' heq.symm

-- The parabola is only a consistency witness, not the source trajectory model.
example (u w : Vector3) (t : ℝ) :
    height (balancingData u w) t ≤ height (balancingData u w) (apexTime (balancingData u w)) :=
  Candidate.apex_height_maximal _ (balancingSource u w) t

example (u w : Vector3) : apexVelocity (balancingData u w) = 0 :=
  Candidate.apex_velocity_zero _ (balancingSource u w)

-- The source assumptions are satisfiable, including degenerate zero velocities.
example : Nonempty ExplosionData := ⟨balancingData 0 0⟩
example : SourceData (balancingData 0 0) := balancingSource 0 0

-- A nonzero coordinate example has actual regularized internal forces and limits.
example : SourceData
    (balancingData (EuclideanSpace.single 0 1) (EuclideanSpace.single 1 1)) :=
  balancingSource _ _

example : (balancingData (EuclideanSpace.single 0 1)
    (EuclideanSpace.single 1 1)).velocity 1 ≠ 0 := by
  intro h
  have h0 := congrArg (fun v : Vector3 => v 0) h
  norm_num [balancingData] at h0

-- Finite positive durations retain a nonzero gravitational impulse.
example (data : ExplosionData) (ε : ℝ) (hε : 0 < ε) :
    gravitationalImpulse data ε ≠ 0 := by
  have hm : 0 < ∑ i, data.mass i := Finset.sum_pos (fun i _ => data.mass_pos i)
    (by simp)
  have hg : gravityAcceleration data ≠ 0 := by
    intro hz
    have hc := congrArg (fun v : Vector3 => v 2) hz
    change -data.g * 1 = 0 at hc
    linarith [data.g_pos]
  rw [Candidate.gravitational_impulse_eq, gravitationalForce]
  exact smul_ne_zero hε.ne' (smul_ne_zero hm.ne' hg)

example (data : ExplosionData) :
    Tendsto (gravitationalImpulse data) (𝓝[>] (0 : ℝ)) (𝓝 0) :=
  Candidate.gravitational_impulse_tendsto_zero data

-- The across-event equality is a theorem, not a SourceData field.
example (data : ExplosionData) (source : SourceData data) :
    totalMomentum data = preMomentum data := Candidate.event_momentum_eq data source

-- Every candidate plane is genuinely finite-dimensional in this ambient space.
example (plane : Submodule ℝ Vector3) : FiniteDimensional ℝ plane := inferInstance

-- Unlike affine coplanarity of three points, this predicate is not automatic:
-- the three independent standard basis vectors cannot fit in a linear plane.
example : ¬ LinearCoplanar (fun i : Fin 3 => EuclideanSpace.single i (1 : ℝ)) := by
  rintro ⟨plane, hDimension, hMembers⟩
  have hSpan : Submodule.span ℝ
      (Set.range (fun i : Fin 3 => EuclideanSpace.single i (1 : ℝ))) = ⊤ := by
    have hBasis : (fun i : Fin 3 => EuclideanSpace.single i (1 : ℝ)) =
        (EuclideanSpace.basisFun (Fin 3) ℝ).toBasis := by
      funext i
      change EuclideanSpace.single i (1 : ℝ) = (EuclideanSpace.basisFun (Fin 3) ℝ) i
      simp
    rw [hBasis]
    exact (EuclideanSpace.basisFun (Fin 3) ℝ).toBasis.span_eq
  have hTop : (⊤ : Submodule ℝ Vector3) ≤ plane := by
    rw [← hSpan]
    apply Submodule.span_le.mpr
    rintro v ⟨i, rfl⟩
    exact hMembers i
  have hPlane : plane = ⊤ := top_unique hTop
  rw [hPlane] at hDimension
  norm_num at hDimension

end LeanVerificationDemo.PhysicsDemo.P08.Verifier
