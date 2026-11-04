# P14 pinned-library and source-solution audit

## Revisions and search scope

Physlib `96a6bc5e3c50a2856c64a6c9951c0a1c23790b58`, Mathlib
`56a005855ea17e0b0958f73ec801ae140b0a1679`, Lean 4.35.0. The actual dependency
checkout HEAD was checked against the manifest. No pin changed.

Searches covered the whole stable Physlib tree, relevant mechanics in context,
Alpha separately, Mathlib calculus and dimensions, and existing PhyslibTemp:

```bash
rg -ni 'pendulum|small.oscillat|small.angle|harmonic.oscillat|coupled.oscillat|normal.mode|spring|hooke|angular.frequency|linearization' Physlib/ClassicalMechanics Physlib/SpaceAndTime
rg -ni 'coupled.oscillat|coupled.pendul|normal.mode|small.angle|small.oscillat|hooke' Physlib --glob '*.lean'
rg -ni 'coupled.oscillat|coupled.pendul|normal.mode|small.angle|small.oscillat|hooke' PhyslibAlpha --glob '*.lean'
rg --files Physlib/ClassicalMechanics | rg -i 'pendul|oscillat|spring|coupl'
rg -ni 'spring|hooke|pendulum|normal.mode' LeanVerificationDemo/PhyslibTemp
rg -n 'hasDerivAt_sin|hasDerivAt_cos' Mathlib/Analysis/SpecialFunctions/Trigonometric/Deriv.lean
```

Read `Pendulum/SimplePendulum/Basic.lean`, `SmallAngle.lean`,
`HarmonicOscillator/Basic.lean`, `WithDim.lean`, and relevant solution/geometry
APIs. Also inspected `Pendulum/CoplanarDoublePendulum.lean`, the other pivot
problems, rigid-body small oscillations, and Alpha's coupled spring potential.
The existing local constant-acceleration/statics/string modules do not supply
this small-oscillation model and are not imported merely for related names.

## Stable formal physics actually reused

Paths are relative to Physlib. All declarations below are in namespace
`ClassicalMechanics` (with the nested namespaces shown). They are formal Lean
declarations, not informal lemmas.

| File / line | Declaration and exact relevant type | P14 use |
| --- | --- | --- |
| `Pendulum/SimplePendulum/Basic.lean:137` | `SimplePendulum` with `m ℓ g : ℝ`, each positive | Construct the source's ideal point-bob pendulum |
| Same:226,229 | `SimplePendulum.inertia (S) : ℝ := S.m * S.ℓ^2`; `inertia_pos (S) : 0 < S.inertia` | Rotational Newton II; positive inertia for uniqueness |
| Same:238 | `SimplePendulum.ω_sq_mul_inertia (S) : S.ω^2 * S.inertia = S.m*S.g*S.ℓ` | Validate in-phase frequency against derived torque |
| Same:599 | `SimplePendulum.torque_apply (S) (x : EuclideanSpace ℝ (Fin 1)) : S.torque x 0 = -(S.m*S.g*S.ℓ*Real.sin (x 0))` | Gravity torque is derived from existing API |
| `Pendulum/SimplePendulum/SmallAngle.lean:150` | `SimplePendulum.toHarmonicOscillator (S) : HarmonicOscillator` | Existing oscillator with mass/inertia ml² and stiffness mgl |
| Same:178 | `SimplePendulum.toHarmonicOscillator_ω (S) : S.toHarmonicOscillator.ω = S.ω` | In-phase oscillator-to-pendulum frequency bridge |
| `HarmonicOscillator/Basic.lean:122` | `HarmonicOscillator` with positive `m k : ℝ` | Reuse Hooke force; instantiate derived antiphase oscillator |
| Same:156,160,163 | `HarmonicOscillator.ω (S) : ℝ := Real.sqrt (S.k/S.m)`; `ω_pos (S) : 0 < S.ω`; `ω_sq (S) : S.ω^2 = S.k/S.m` | Construct positive angular frequencies; validate torque equations |
| Same:464 | `HarmonicOscillator.force_eq_linear (S) (x : EuclideanSpace ℝ (Fin 1)) : S.force x = -S.k • x` | Actual Hooke-force dependency in `hooke_force`, with opposite sign for the left bob |
| `HarmonicOscillator/WithDim.lean:41` | `HarmonicOscillatorWithDim`, `m : WithDim M𝓭 ℝ`, `k : WithDim (M𝓭*T𝓭⁻¹*T𝓭⁻¹) ℝ`, positive | Use existing typed mass/spring stiffness, not a new unit model |

The scalar `SimplePendulum.ω` is defined at Basic:199 as `sqrt(S.g/S.ℓ)`.
The actual upstream small-angle support is substantially more than this name:

```lean
-- SmallAngle.lean:208
SimplePendulum.LinearizedEquationOfMotion (S)
    (θ : Time → EuclideanSpace ℝ (Fin 1)) : Prop :=
  ∀ t, ∂ₜ (∂ₜ θ) t + (S.ω ^ 2) • θ t = 0

-- SmallAngle.lean:262
SimplePendulum.fderiv_torque_zero_apply (S) (v : EuclideanSpace ℝ (Fin 1)) :
  fderiv ℝ S.torque 0 v = S.toHarmonicOscillator.force v
```

That module also formally proves equivalence to the oscillator equation, smooth
linearized trajectories, uniqueness, periodicity and a cubic torque residual
bound (`norm_torque_sub_toHarmonicOscillator_force_le`, line 488). These are
available related APIs; P14 directly calls the smaller force/inertia/frequency
surface listed above, and uses scalar derivatives for the added spring term.
The module's final TODO (line 588) concerns convergence of rescaled nonlinear
trajectories to linearized trajectories. It is not a proved convergence theorem.

## Related hits that do not supply this coupled problem

- `RigidBody/Basic.lean:336`, `small_oscillations_about_equilibrium`, is an
  **informal_lemma**, not a usable normal-mode solver.
- `Pendulum/CoplanarDoublePendulum.lean:74` concerns a serial double pendulum
  and has `@[sorryful] def ConfigurationSpace : Type := sorry`. Its surrounding
  Lagrangian discussion is not a formal spring-linked-pendulum theorem. Not imported.
- Other stable pivot-motion pendulum files concern different apparatus; they do
  not replace the geometry here.
- `PhyslibAlpha/ClassicalMechanics/CoupledSpringPotential.lean` formally studies
  `couplingPotential (x : EuclideanSpace ℝ (Fin 2)) := x 0^2 + x 0*x 1 + x 1^2`
  and a local-minimum/positive-definite Hessian result (`coupled_spring_potential`).
  This is **Alpha-only**, not a mode-frequency API for the present physical system.
  No Alpha import is used.
- Quantum harmonic oscillators are not used for this classical system.

No applicable ready-made two-pendulum symmetric-mode theorem was found in those
stable sources or the whole-tree semantic search. This does **not** mean that
Physlib lacks pendulums, Hooke forces or rigorous small-angle infrastructure.

## Mathlib and dimensional APIs

`Mathlib/Analysis/SpecialFunctions/Trigonometric/Deriv.lean:331,372`:

```lean
Real.hasDerivAt_sin (x : ℝ) : HasDerivAt Real.sin (Real.cos x) x
Real.hasDerivAt_cos (x : ℝ) : HasDerivAt Real.cos (-Real.sin x) x
```

`HasDerivAt.const_mul`, `.mul`, `.sub`, and `.deriv` compute the mode torque
derivatives. `deriv.neg` in `Analysis/Calculus/Deriv/Add.lean:278` gives
`deriv (-f) x = -deriv f x`. Continuity and `Ioi_mem_nhds` prove the uncrossed
spring branch exists near equilibrium. `Real.sqrt_sq_eq_abs`, positive-square
cancellation `sq_eq_sq₀`, and exact real algebra finish geometry/frequency checks.

Upstream `Units/WithDim/Basic.lean` supplies indexed quantities, products,
division, addition at equal dimension and `WithDim.cast`. `Units/Dimension.lean`
supplies `Dimension.mul_exponent`, `inv_exponent` and `qpow_exponent`; rational
half-powers certify the root has T⁻¹ dimension. No quantity sqrt operator is
provided in the inspected WithDim API, so a small P14-local expression wrapper
tags `Real.sqrt` using that proved dimension equality, following P13's precedent.
It is a dimensional/value bridge, not a general unit-covariance framework.

## Reuse decision and actual proof dependency

**PhyslibTemp addition: none.** Existing upstream SimplePendulum, small-angle
oscillator and Hooke APIs cover the reusable semantic layer. The remaining
mode-slice coordinate and torque calculation is narrow enough to stay P14-local.
No new coupled-oscillator or general eigenvalue framework is justified here.

Candidate's returned pair depends on `solutionFrequencies_valid`, then
`in_phase_valid`/`anti_phase_valid`, the derived torque derivatives, and upstream
`ω_sq_mul_inertia`/`HarmonicOscillator.ω_sq`. The explicit formula lemmas invoke
`toHarmonicOscillator_ω` and `HarmonicOscillator.ω`. Torque calculations use
`gravity_torque` → `SimplePendulum.torque_apply` and `hooke_force` →
`HarmonicOscillator.force_eq_linear`. These are actual proof dependencies.

The linearized dynamics is an adopted small-oscillation model; the derivatives
and mode coefficients are proved, not assumed. The interpretation does not claim
full coupled finite-amplitude dynamics or a convergence theorem. No final
frequency or solution-figure force expression is stored in the trusted target.

## Image and source-solution audit

The original Fig. 228 was directly viewed from the user-identified screenshot.
Both mass labels m are visible, and therefore equal mass is image-source data.
The supplied prose contributes the undeformed-spring condition; it cannot be
inferred from pixels alone. The reconstruction was written from direct visual
analysis, with no trusted-caption intermediary. SHA-256 and source path are
recorded in source.jsonl; the original pixels are not copied into the repository.

No separate Fig. 479 file was identified or viewed. It is solution-side reference
material only; supplied solution text guides the audit. Its Fr, force arrows and
frequency expressions are not original-problem image facts. Candidate derives
the stated Fr with signs, then differentiates the exact mode-slice torque rather
than assuming finite-angle trigonometric equalities.
