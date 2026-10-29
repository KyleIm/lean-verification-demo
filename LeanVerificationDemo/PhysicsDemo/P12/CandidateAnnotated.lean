import LeanVerificationDemo.PhysicsDemo.P12.Problem

namespace LeanVerificationDemo.PhysicsDemo.P12.CandidateAnnotated
open _root_.ClassicalMechanics
open LeanVerificationDemo.PhyslibTemp.ClassicalMechanics

-- [source table / pure mathematics] Exact positivity over all 70 source cells.
lemma table_distances_positive (p : Pavement) (i : Fin 10) :
    0 < brakingDistance p i := by
  cases p <;> fin_cases i <;> norm_num [brakingDistance]

-- [formalization choice] speedSI uses the essential 5/18 km/h conversion.
lemma table_speeds_positive (i : Fin 10) : 0 < speedSI i := by
  fin_cases i <;> norm_num [speedSI, speedKmh]

/-- Horizontal normal balance and maximum braking friction imply a = μg. -/
-- [source-solution model assumption → derived physics] N=mg, F=μN.
lemma friction_acceleration (run : BrakingRun) (model : BrakingModel run) :
    deceleration run = run.μ * run.g := by
  unfold deceleration
  rw [model.braking_friction, model.normal_balance]
  field_simp [run.particle.mass.property.ne']

/-- The source's constant-deceleration idealization is realized by fixed forces
and Newton II, rather than assuming the stopping-distance formula. -/
-- [source-solution model assumption / derived physics] Newton II with fixed forces
-- supplies the reusable constant-acceleration premise; v²=2as is not assumed.
lemma constant_deceleration (run : BrakingRun) (model : BrakingModel run) :
    HasConstantAcceleration run.particle ((-deceleration run) • tangent) := by
  intro t
  apply ReferenceFrame.Vector.componentEquiv.injective
  funext i
  fin_cases i
  change (run.particle.acceleration t).components 0 = -deceleration run * 1
  rw [mul_one]
  apply mul_left_cancel₀ run.particle.mass.property.ne'
  rw [model.newton]
  dsimp [deceleration]
  field_simp [run.particle.mass.property.ne']

-- [reusable physics] Project ConstantAcceleration.velocity_eq into the path coordinate.
lemma braking_velocity (run : BrakingRun) (model : BrakingModel run) (t : ℝ) :
    speed run.particle t = run.initialSpeed - deceleration run * t := by
  have h := congrArg (fun v : trackFrame.Vector => v.components 0)
    ((constant_deceleration run model).velocity_eq 0 t)
  change speed run.particle t = speed run.particle 0 + (t - 0) * (-deceleration run * 1) at h
  rw [model.initial_speed] at h
  linarith

-- [reusable physics] Project ConstantAcceleration.position_eq into the path coordinate.
lemma braking_travel (run : BrakingRun) (model : BrakingModel run) (t : ℝ) :
    travel run.particle t = t * run.initialSpeed - deceleration run * t ^ 2 / 2 := by
  have h := congrArg (fun v : trackFrame.Vector => v.components 0)
    ((constant_deceleration run model).position_eq 0 t)
  change (run.particle.pos t).components 0 = (run.particle.pos 0).components 0 +
    (t - 0) * speed run.particle 0 + ((t - 0) ^ 2 / 2) * (-deceleration run * 1) at h
  rw [model.initial_speed] at h
  unfold travel
  nlinarith

/-- No reversal on the braking interval: oriented displacement is the path
coordinate used for the source's braking distance. -/
lemma braking_speed_nonnegative (run : BrakingRun) (model : BrakingModel run)
    (t : ℝ) (ht : t ∈ Set.Icc 0 run.duration) : 0 ≤ speed run.particle t := by
  have ha : 0 ≤ deceleration run := by
    rw [friction_acceleration run model]
    exact mul_nonneg run.μ_nonneg run.g_pos.le
  have hv := braking_velocity run model t
  have hend := braking_velocity run model run.duration
  rw [model.final_at_rest] at hend
  nlinarith [mul_nonneg ha (sub_nonneg.mpr ht.2)]

/-- Eliminate time between the reusable velocity and position laws. -/
-- [derived physics / pure mathematics] Eliminate duration using final rest.
lemma stopping_relation (run : BrakingRun) (model : BrakingModel run) :
    run.initialSpeed ^ 2 = 2 * deceleration run * run.distance := by
  have hv := braking_velocity run model run.duration
  rw [model.final_at_rest] at hv
  have hs := braking_travel run model run.duration
  rw [model.distance_travelled] at hs
  have hid : (run.initialSpeed - deceleration run * run.duration) ^ 2 =
      run.initialSpeed ^ 2 - 2 * deceleration run *
        (run.duration * run.initialSpeed - deceleration run * run.duration ^ 2 / 2) := by ring
  rw [← hv, ← hs] at hid
  nlinarith

/-- Source formula, derived rather than a trusted final-equation premise. -/
-- [derived physics] Cancel positive mass/g/distance to obtain μ=v²/(2gs).
lemma friction_estimator (run : BrakingRun) (model : BrakingModel run) :
    run.μ = frictionEstimate run.initialSpeed run.g run.distance := by
  unfold frictionEstimate
  have hg := run.g_pos
  have hdist := run.distance_pos
  apply (eq_div_iff (by positivity : 2 * run.g * run.distance ≠ 0)).2
  have hs := stopping_relation run model
  rw [friction_acceleration run model] at hs
  nlinarith

lemma coefficient_from_row (p : Pavement) (i : Fin 10) (run : BrakingRun)
    (model : BrakingModel run) (row : ObservesRow run p i) :
    run.μ = tableEstimate p i := by
  rw [friction_estimator run model, row.1, row.2.1, row.2.2]
  rfl

/-- Candidate extraction rule: round the first measured estimate, then validate
ALL ten columns. This definition contains no supplied numerical answer list. -/
-- [formalization choice] Nearest tenth: floor(10x+1/2)/10, ties toward +∞.
-- gravity=49/5 is a numerical model specialization, not source table data.
noncomputable def coefficient (p : Pavement) : ℝ :=
  (⌊10 * tableEstimate p 0 + 1 / 2⌋ : ℝ) / 10

/-- These integer results are computed from source data by exact floor bounds. -/
-- [source table / pure mathematics] First numerical answer claims occur here
-- as kernel-checked consequences of data; none was supplied in Problem.lean.
lemma rounded_numerators (p : Pavement) :
    ⌊10 * tableEstimate p 0 + 1 / 2⌋ =
      (match p with
       | .ice => 1 | .drySnow => 2 | .wetWoodBlock => 3 | .dryWoodBlock => 5
       | .wetAsphalt => 4 | .dryAsphalt => 6 | .dryConcrete => 7 : ℤ) := by
  cases p <;> apply Int.floor_eq_iff.mpr <;>
    norm_num [tableEstimate, frictionEstimate, speedSI, speedKmh, gravity, brakingDistance]

/-- Explicit source-facing coefficients, now derived equations about the
computed witness, not trusted fields. -/
-- [derived data] Expose all seven final values for human review.
lemma coefficient_values (p : Pavement) : coefficient p =
    match p with
    | .ice => 1 / 10 | .drySnow => 2 / 10 | .wetWoodBlock => 3 / 10
    | .dryWoodBlock => 5 / 10 | .wetAsphalt => 4 / 10
    | .dryAsphalt => 6 / 10 | .dryConcrete => 7 / 10 := by
  unfold coefficient
  rw [rounded_numerators]
  cases p <;> norm_num

lemma coefficient_is_tenth (p : Pavement) : IsTenth (coefficient p) :=
  ⟨⌊10 * tableEstimate p 0 + 1 / 2⌋, rfl⟩

/-- All ten ice measurements lie strictly inside their common tenth band. -/
lemma ice_row (i : Fin 10) :
    coefficient .ice - 1 / 20 < tableEstimate .ice i ∧
    tableEstimate .ice i < coefficient .ice + 1 / 20 := by
  rw [coefficient_values]
  fin_cases i <;>
    norm_num [tableEstimate, frictionEstimate, speedSI, speedKmh, gravity, brakingDistance]

/-- All ten drySnow measurements lie strictly inside their common tenth band. -/
lemma drySnow_row (i : Fin 10) :
    coefficient .drySnow - 1 / 20 < tableEstimate .drySnow i ∧
    tableEstimate .drySnow i < coefficient .drySnow + 1 / 20 := by
  rw [coefficient_values]
  fin_cases i <;>
    norm_num [tableEstimate, frictionEstimate, speedSI, speedKmh, gravity, brakingDistance]

/-- All ten wetWoodBlock measurements lie strictly inside their common tenth band. -/
lemma wetWoodBlock_row (i : Fin 10) :
    coefficient .wetWoodBlock - 1 / 20 < tableEstimate .wetWoodBlock i ∧
    tableEstimate .wetWoodBlock i < coefficient .wetWoodBlock + 1 / 20 := by
  rw [coefficient_values]
  fin_cases i <;>
    norm_num [tableEstimate, frictionEstimate, speedSI, speedKmh, gravity, brakingDistance]

/-- All ten dryWoodBlock measurements lie strictly inside their common tenth band. -/
lemma dryWoodBlock_row (i : Fin 10) :
    coefficient .dryWoodBlock - 1 / 20 < tableEstimate .dryWoodBlock i ∧
    tableEstimate .dryWoodBlock i < coefficient .dryWoodBlock + 1 / 20 := by
  rw [coefficient_values]
  fin_cases i <;>
    norm_num [tableEstimate, frictionEstimate, speedSI, speedKmh, gravity, brakingDistance]

/-- All ten wetAsphalt measurements lie strictly inside their common tenth band. -/
lemma wetAsphalt_row (i : Fin 10) :
    coefficient .wetAsphalt - 1 / 20 < tableEstimate .wetAsphalt i ∧
    tableEstimate .wetAsphalt i < coefficient .wetAsphalt + 1 / 20 := by
  rw [coefficient_values]
  fin_cases i <;>
    norm_num [tableEstimate, frictionEstimate, speedSI, speedKmh, gravity, brakingDistance]

/-- All ten dryAsphalt measurements lie strictly inside their common tenth band. -/
lemma dryAsphalt_row (i : Fin 10) :
    coefficient .dryAsphalt - 1 / 20 < tableEstimate .dryAsphalt i ∧
    tableEstimate .dryAsphalt i < coefficient .dryAsphalt + 1 / 20 := by
  rw [coefficient_values]
  fin_cases i <;>
    norm_num [tableEstimate, frictionEstimate, speedSI, speedKmh, gravity, brakingDistance]

/-- All ten dryConcrete measurements lie strictly inside their common tenth band. -/
lemma dryConcrete_row (i : Fin 10) :
    coefficient .dryConcrete - 1 / 20 < tableEstimate .dryConcrete i ∧
    tableEstimate .dryConcrete i < coefficient .dryConcrete + 1 / 20 := by
  rw [coefficient_values]
  fin_cases i <;>
    norm_num [tableEstimate, frictionEstimate, speedSI, speedKmh, gravity, brakingDistance]

/-- Fin 10 and all seven constructors are covered: 70 exact, strict checks.
No estimate is on a half-tenth tie. -/
-- [source table / pure mathematics] Every speed column is checked exactly.
lemma all_estimates_inside_bands (p : Pavement) (i : Fin 10) :
    coefficient p - 1 / 20 < tableEstimate p i ∧
    tableEstimate p i < coefficient p + 1 / 20 := by
  cases p
  · exact ice_row i
  · exact drySnow_row i
  · exact wetWoodBlock_row i
  · exact dryWoodBlock_row i
  · exact wetAsphalt_row i
  · exact dryAsphalt_row i
  · exact dryConcrete_row i

lemma table_rounded : RoundedTable coefficient := by
  intro p
  refine ⟨coefficient_is_tenth p, ?_⟩
  intro i
  have h := all_estimates_inside_bands p i
  exact ⟨h.1.le, h.2⟩

/-- This final-certificate clause really uses Newton/friction and the reusable
kinematics: every modeled braking run matching a row has the rounded value. -/
-- [derived physics] Use the mechanics bridge, not just the rounding arithmetic.
lemma physical_table_compatibility : PhysicalTableCompatibility coefficient := by
  intro p i run model row
  rw [coefficient_from_row p i run model row]
  exact (table_rounded p).2 i

-- [pure mathematics] Distinct integer tenth-grid values have disjoint half-open bands.
lemma rounding_unique {x c d : ℝ} (hc : IsTenth c) (hd : IsTenth d)
    (hx : RoundsToTenth x c) (hy : RoundsToTenth x d) : c = d := by
  obtain ⟨n, rfl⟩ := hc
  obtain ⟨m, rfl⟩ := hd
  have hnm : (n : ℝ) < (m : ℝ) + 1 := by
    dsimp [RoundsToTenth] at hx hy
    linarith
  have hmn : (m : ℝ) < (n : ℝ) + 1 := by
    dsimp [RoundsToTenth] at hx hy
    linarith
  have hnm' : n < m + 1 := by exact_mod_cast hnm
  have hmn' : m < n + 1 := by exact_mod_cast hmn
  have heq : n = m := by omega
  rw [heq]

lemma table_solution_unique (other : Pavement → ℝ) (h : TableSolution other) :
    other = coefficient := by
  funext p
  -- One common sample separates grid values; existence/acceptance used all 70.
  exact rounding_unique (h.1 p).1 (table_rounded p).1
    ((h.1 p).2 0) ((table_rounded p).2 0)

/-- Speed independence at the requested resolution, not exact equality of raw
estimates or a claim that real friction never depends on speed. -/
lemma rounded_speed_independent (p : Pavement) (i j : Fin 10) :
    RoundsToTenth (tableEstimate p i) (coefficient p) ∧
    RoundsToTenth (tableEstimate p j) (coefficient p) :=
  ⟨(table_rounded p).2 i, (table_rounded p).2 j⟩

/-- Find from Table 1: ice 0.1; dry snow 0.2; wet wood 0.3; dry wood 0.5;
wet asphalt 0.4; dry asphalt 0.6; dry concrete 0.7.
The witness is computed from data; all columns and physical compatibility are
proved, and no competing tenth-grid assignment satisfies the specification. -/
-- [final witness assignment] The witness is computed; full-table validity,
-- physical compatibility and uniqueness are separately named before assembly.
theorem solution : TrustedPhysicsProblem := by
  have fitsAllSeventy : RoundedTable coefficient := table_rounded
  have agreesWithBrakingPhysics : PhysicalTableCompatibility coefficient :=
    physical_table_compatibility
  have uniqueAssignment : ∀ other, TableSolution other → other = coefficient :=
    table_solution_unique
  exact ⟨coefficient, ⟨fitsAllSeventy, agreesWithBrakingPhysics⟩, uniqueAssignment⟩

end LeanVerificationDemo.PhysicsDemo.P12.CandidateAnnotated
