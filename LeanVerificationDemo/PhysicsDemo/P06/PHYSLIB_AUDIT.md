# Pinned Physlib audit for problem 656

Inspected package HEAD and lake-manifest.json: both select
`96a6bc5e3c50a2856c64a6c9951c0a1c23790b58`. No dependency pins changed.
Paths below are relative to that Physlib checkout.

## Search evidence

Ran whole-tree searches over stable `Physlib/` and secondary `PhyslibAlpha/`:

```bash
rg -n -i 'ionosph|diffract|line.of.sight|geometric optics|straight.line propagation|wavelength|reflection' Physlib PhyslibAlpha
rg --files Physlib PhyslibAlpha | rg -i 'wave|optic|ray|light'
rg -n -i '\b(ray|visibility|obstacle|reflection|diffraction|ionosphere)\b' Physlib/Optics Physlib/Electromagnetism PhyslibAlpha
```

Inspected `Optics/{Basic,Wavelength,Frequency,Polarization/Basic}.lean`,
`Electromagnetism/Vacuum/{IsPlaneWave,HarmonicWave}.lean`, and
`ClassicalMechanics/WaveEquation/{Basic,HarmonicWave}.lean`.
The searches found no ionospheric propagation or diffraction regime API,
no obstacle-blocking visibility semantics, and no theorem joining these to a
short-wavelength reception restriction. This absence claim concerns this pin,
not all possible future Physlib versions.

## Actual stable declarations

* `Physlib/Optics/Wavelength.lean:70`, root namespace:
  `abbrev Wavelength : Type := WithDim L𝓭 ℝ≥0`.
  Formal dimension-tagged nonnegative wavelength; **reused directly**.
* Same file, namespace `Wavelength`, lines 82–83:
  `noncomputable def ofFrequency (c : WithDim (L𝓭 * T𝓭⁻¹) ℝ≥0)
  (ν : Frequency) (_ν_pos : 0 < ν.val) : Wavelength`.
  Lines 96–98, `ofFrequency_mul` has exact type
  `(c : WithDim (L𝓭 * T𝓭⁻¹) ℝ≥0) (ν : Frequency) (hν : 0 < ν.val) →
  (ofFrequency c ν hν).val * ν.val = c.val`.
  Formal frequency relation, unnecessary here; not a visibility theorem.
* `Physlib/ClassicalMechanics/WaveEquation/Basic.lean:60`, namespace
  `ClassicalMechanics`:
  `WaveEquation {d} (f : Time → Space d → EuclideanSpace ℝ (Fin d))
  (t : Time) (x : Space d) (c : ℝ) : Prop`.
  Definition is `c^2 • Δᵥ (f t) x - ∂ₜ (fun t => (∂ₜ (fun t => f t x) t)) t = 0`.
  Formal wave equation; does not supply obstacle boundary conditions or a
  diffraction-to-ray approximation.
* `Physlib/Electromagnetism/Vacuum/IsPlaneWave.lean:75`, namespace
  `Electromagnetism.ElectromagneticPotential`:
  `IsPlaneWave {d : ℕ} (𝓕 : FreeSpace) (A : ElectromagneticPotential d)
  (s : Direction d) : Prop`.
  Defined by existence of plane-wave electric and magnetic profiles. This is a
  formal free-space field property, not ionospheric transmission or reception.
  `Vacuum/HarmonicWave.lean:486` formally constructs such plane waves, but no
  blocked-link theorem follows without additional medium/obstacle assumptions.
* `Physlib/Optics/Basic.lean` is a documentation placeholder. It is not evidence
  that the entire optics directory is empty: Wavelength is a real formal API.

## Secondary / unrelated hits

`PhyslibAlpha/Electromagnetism/TemperedDistributional/WireJunction.lean:85`
parametrizes wire rays as `s ↦ s • w`: electrical wire geometry, not optical
rays around obstacles. Alpha crystal point-group reflections are spatial
symmetries, not wave reflection. Neither is imported. Stable cosmological
`FLRW/Distances.lean:73` uses “line-of-sight” for comoving distance, not
visibility through obstacles. Quantum plane waves, reflectionless potentials,
Planck radiance and polarization do not establish the source propagation chain.
No InformalLemma or documentation-only assertion is treated as a proved
propagation result.

## Minimal extension decision (revised)

* Stable Physlib: `Wavelength` and its existing dimension infrastructure,
  imported directly from `Physlib.Optics.Wavelength`.
* PhyslibTemp: no addition. The earlier propagation module has been removed.
* P06-specific: the qualitative propagation-link model `PropagationModel`,
  retained direct/reflected/diffracted path decomposition (`HasPath`),
  ionospheric interpretation, diffraction/straight-line approximation rules,
  positive wavelength in metre coordinates and the 10 m source threshold.
  All declarations are local to P06's `Problem.lean`.
* Pure mathematics: implication composition, disjunction case analysis and
  contradiction.

The absence of an upstream API does not by itself justify a reusable extension.
The earlier propagation abstraction is intentionally kept problem-local because
there is not yet enough evidence of genuine reuse across problems. Its channel
decomposition and approximation rules encode this particular qualitative source
explanation, rather than a broadly justified optics API. No replacement generic
approximation framework is introduced.

This is intentionally a semantic assumption layer, not a rigorous derivation
of geometric optics from Maxwell's equations. Moving that layer does not change
the adopted assumptions or the candidate's deductive conclusion.
