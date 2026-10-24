import LeanVerificationDemo.PhysicsDemo.P08.Candidate
import LeanVerificationDemo.PhyslibTemp.ClassicalMechanics.ConstantAccelerationExamples

open LeanVerificationDemo.PhyslibTemp.ClassicalMechanics

namespace LeanVerificationDemo.PhysicsDemo.P08.Verifier

example (data : ExplosionData) (source : SourceData data) :
    TrustedPhysicsProblem data := Candidate.solution data source

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

lemma balancingSource (u w : Vector3) : SourceData (balancingData u w) := by
  constructor
  · exact Examples.quadratic_constant _ _ _ _
  · simp [balancingData, Examples.quadratic_velocity]
  · have hv : (balancingData u w).rocket.velocity (apexTime (balancingData u w)) = 0 := by
      change (Examples.quadraticParticle ⟨3, by norm_num⟩ (0 : labFrame.Vector)
        (1 • up) ((-1 : ℝ) • up)).velocity (1 / 1) = 0
      rw [Examples.quadratic_velocity]
      norm_num
    have ha : apexVelocity (balancingData u w) = 0 := by
      unfold apexVelocity
      rw [hv]
      rfl
    rw [preMomentum, ha, smul_zero]
    simp [totalMomentum, momentum, balancingData]

-- The parabola is only a consistency witness, not the source trajectory model.
example (u w : Vector3) (t : ℝ) :
    height (balancingData u w) t ≤ height (balancingData u w) (apexTime (balancingData u w)) :=
  Candidate.apex_height_maximal _ (balancingSource u w) t

example (u w : Vector3) : apexVelocity (balancingData u w) = 0 :=
  Candidate.apex_velocity_zero _ (balancingSource u w)

-- The source assumptions are satisfiable, including degenerate zero velocities.
example : Nonempty ExplosionData := ⟨balancingData 0 0⟩
example : SourceData (balancingData 0 0) := balancingSource 0 0

-- A nonzero coordinate example also satisfies the same conservation premise.
example : SourceData
    (balancingData (EuclideanSpace.single 0 1) (EuclideanSpace.single 1 1)) :=
  balancingSource _ _

example : (balancingData (EuclideanSpace.single 0 1)
    (EuclideanSpace.single 1 1)).velocity 1 ≠ 0 := by
  intro h
  have h0 := congrArg (fun v : Vector3 => v 0) h
  norm_num [balancingData] at h0

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
