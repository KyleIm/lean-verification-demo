import Physlib.ClassicalMechanics.PointParticle.NewtonianSystem.Basic
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic

/-!
# Finite-system impulse and momentum

Newton II in momentum form and pairwise Newton III imply that only external
forces change total momentum. This coordinate-level interface allows families
of interactions without imposing globally smooth position trajectories across
a singular event. No application, force law, or spatial dimension is fixed.
-/
namespace LeanVerificationDemo.PhyslibTemp.ClassicalMechanics

open scoped BigOperators Topology
open Filter MeasureTheory

/-- Upstream particle trajectories and Newton II give the momentum-form law.
This adapter does not assume the advertised derivative equation as an axiom. -/
lemma newtonian_particle_momentum_hasDerivAt {d : ℕ}
    (system : _root_.ClassicalMechanics.PointParticle.NewtonianSystem d)
    (particle : system.Particle) (t : ℝ) :
    HasDerivAt (fun s => particle.momentum s)
      (_root_.ClassicalMechanics.ReferenceFrame.netForce particle
        system.internalForces system.externalForces t) t := by
  have hv : HasDerivAt particle.1.velocity (particle.1.acceleration t) t :=
    (particle.1.pos_twice_differentiable system.isInertial.out).2 t |>.hasDerivAt
  have hforce := congrFun (system.newton_second_law particle) t
  rw [hforce]
  exact hv.const_smul particle.1.mass.val

/-- Upstream Newton III really cancels the internal force multiset, including
multiplicities. This lemma uses the upstream reversal operation and system law. -/
lemma newtonian_internal_force_sum_zero {d : ℕ}
    (system : _root_.ClassicalMechanics.PointParticle.NewtonianSystem d) (t : ℝ) :
    (system.internalForces.map (fun f => f.value t)).sum = 0 := by
  have h := congrArg (fun fs => (fs.map (fun f => f.value t)).sum)
    system.newton_third_law
  simp only [Multiset.map_map] at h
  change (system.internalForces.map (fun f => -f.value t)).sum =
    (system.internalForces.map (fun f => f.value t)).sum at h
  have hneg : (system.internalForces.map (fun f => -f.value t)).sum =
      -(system.internalForces.map (fun f => f.value t)).sum := by
    simp
  rw [hneg] at h
  let total : system.Vector := (system.internalForces.map (fun f => f.value t)).sum
  change -total = total at h
  apply _root_.ClassicalMechanics.ReferenceFrame.Vector.componentEquiv.injective
  funext i
  have hi := congrArg (fun v : system.Vector => v.components i) h
  change -total.components i = total.components i at hi
  change total.components i = 0
  linarith

variable {ι E : Type*} [Fintype ι] [NormedAddCommGroup E]
  [NormedSpace ℝ E] [CompleteSpace E]

/-- Indexed coordinate Newton II/III. `internal i j t` is the force on i from j;
diagonal entries vanish by antisymmetry. Momenta need not be position derivatives.
This is a force-balance interface, not a replacement for upstream particles. -/
structure MomentumBalance (p : ι → ℝ → E) (internal : ι → ι → ℝ → E)
    (external : ι → ℝ → E) : Prop where
  newton_second : ∀ i t, HasDerivAt (p i) (external i t + ∑ j, internal i j t) t
  newton_third : ∀ i j t, internal i j t = -internal j i t

namespace MomentumBalance
variable {p : ι → ℝ → E} {internal : ι → ι → ℝ → E} {external : ι → ℝ → E}

omit [CompleteSpace E] in
lemma internal_sum_zero (h : MomentumBalance p internal external) (t : ℝ) :
    ∑ i, ∑ j, internal i j t = 0 := by
  have hneg : (∑ i, ∑ j, internal i j t) = -(∑ i, ∑ j, internal i j t) := by
    calc
      (∑ i, ∑ j, internal i j t) = ∑ i, ∑ j, -internal j i t := by
        exact Finset.sum_congr rfl (fun i _ => Finset.sum_congr rfl
          (fun j _ => h.newton_third i j t))
      _ = -(∑ i, ∑ j, internal i j t) := by
        simp only [Finset.sum_neg_distrib]
        rw [Finset.sum_comm]
  have htwice : (2 : ℝ) • (∑ i, ∑ j, internal i j t) = 0 := by
    linear_combination (norm := module) hneg
  exact (smul_eq_zero.mp htwice).resolve_left (by norm_num)

omit [CompleteSpace E] in
/-- Summing particle momentum equations eliminates all internal forces. -/
lemma total_hasDerivAt (h : MomentumBalance p internal external) (t : ℝ) :
    HasDerivAt (fun s => ∑ i, p i s) (∑ i, external i t) t := by
  have hd := HasDerivAt.sum (u := Finset.univ) (fun i _ => h.newton_second i t)
  simp only [Finset.sum_add_distrib, h.internal_sum_zero t, add_zero] at hd
  convert hd using 1
  ext s
  simp

/-- Finite-duration impulse–momentum theorem. Integrability is an explicit
analytic hypothesis; continuity of the total external force suffices. -/
lemma total_change_eq_integral (h : MomentumBalance p internal external) (a b : ℝ)
    (hint : IntervalIntegrable (fun t => ∑ i, external i t) volume a b) :
    (∑ i, p i b) - (∑ i, p i a) = ∫ t in a..b, ∑ i, external i t := by
  exact (intervalIntegral.integral_eq_sub_of_hasDerivAt
    (fun t _ => h.total_hasDerivAt t) hint).symm

end MomentumBalance

/-- Constant-force impulse for any (oriented) duration, not zero at finite
positive duration when the force is nonzero. -/
lemma constant_impulse (force : E) (t₀ ε : ℝ) :
    (∫ _t in t₀..t₀ + ε, force) = ε • force := by
  simp [intervalIntegral.integral_const]

omit [CompleteSpace E] in
/-- A continuous external force has vanishing impulse on a shrinking interval.
This reuses Mathlib's continuity of the integral primitive. -/
lemma continuous_impulse_tendsto_zero (force : ℝ → E) (h : Continuous force) (t₀ : ℝ) :
    Tendsto (fun ε => ∫ t in t₀..t₀ + ε, force t) (𝓝[>] (0 : ℝ)) (𝓝 0) := by
  have hp := intervalIntegral.continuous_primitive (μ := volume)
    (fun a b => h.intervalIntegrable a b) t₀
  have hid : Tendsto (fun ε : ℝ => ε) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) :=
    nhdsWithin_le_nhds
  have hε : Tendsto (fun ε : ℝ => t₀ + ε) (𝓝[>] (0 : ℝ)) (𝓝 t₀) := by
    simpa only [add_zero] using tendsto_const_nhds.add hid
  convert hp.continuousAt.tendsto.comp hε using 1
  · rfl
  · simp

omit [CompleteSpace E] in
/-- Exact constant-force shrinking-interval limit for positive durations. -/
lemma constant_impulse_tendsto_zero (force : E) (t₀ : ℝ) :
    Tendsto (fun ε => ∫ _t in t₀..t₀ + ε, force) (𝓝[>] (0 : ℝ)) (𝓝 0) := by
  exact continuous_impulse_tendsto_zero (fun _ => force) continuous_const t₀

omit [NormedSpace ℝ E] [CompleteSpace E] in
/-- Explicit event semantics: finite-duration momentum changes equal external
impulses, endpoint states converge from positive durations, and those impulses
vanish. Uniqueness of limits derives equality of event states. It is not an
extra conservation axiom. -/
lemma event_momentum_eq_of_impulse_limit {endpoint impulse : ℝ → E} {before after : E}
    (balance : ∀ ε > 0, endpoint ε - before = impulse ε)
    (endpoint_limit : Tendsto endpoint (𝓝[>] (0 : ℝ)) (𝓝 after))
    (impulse_limit : Tendsto impulse (𝓝[>] (0 : ℝ)) (𝓝 0)) :
    after = before := by
  have heq : (fun ε => endpoint ε - before) =ᶠ[𝓝[>] (0 : ℝ)] impulse := by
    filter_upwards [self_mem_nhdsWithin] with ε hε
    exact balance ε hε
  have hzero : after - before = 0 :=
    tendsto_nhds_unique (endpoint_limit.sub_const before) (impulse_limit.congr' heq.symm)
  exact sub_eq_zero.mp hzero

end LeanVerificationDemo.PhyslibTemp.ClassicalMechanics
