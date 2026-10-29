# Ideal fixed-string normal modes

`VibratingString.lean` supplies a source-independent model of a uniform stretched
string with both ends fixed. `FixedString` contains positive length, tension and
linear mass density in a common coherent unit system. The assumptions are small
transverse oscillations, constant tension/density, perfect flexibility,
negligible stiffness and damping, and ideal fixed endpoints. Frequencies count
cycles per unit time, not radians per unit time.

## Physical-law boundary

The module adopts the standard model laws

```text
c = sqrt(T/μ)
fₙ = n c/(2L), n a positive integer.
```

These are definitions of the ideal physical model. The implementation does not
derive the string equation from force balance or derive its complete spectrum
from the PDE. It proves consequences of the adopted law rather than disguising
that modeling choice as a PDE theorem.

The pinned upstream `ClassicalMechanics.WaveEquation` and `harmonicWave` APIs
provide a general wave equation and travelling plane-wave solutions. They do
not supply this mechanical wave-speed law, fixed-end quantization or a ready
spectral-completeness theorem. Importing an unused PDE declaration would not
bridge that gap. The current module therefore uses Mathlib real square roots
and trigonometry directly; a future PDE bridge can build on upstream Physlib.

## API

All names below are in `LeanVerificationDemo.PhyslibTemp.ClassicalMechanics`:

| Declaration | Meaning |
| --- | --- |
| `FixedString` | Positive uniform length, tension, linear density |
| `FixedString.waveSpeed`, `waveSpeed_pos`, `waveSpeed_squared` | c=√(T/μ), positive, with c²=T/μ |
| `fundamental`, `fundamental_eq`, `fundamental_pos` | f₁=c/(2L), positive |
| `frequency`, `frequency_pos` | Positive-natural-indexed mode frequencies |
| `harmonic_scaling`, `first_frequency` | fₙ=n f₁ and mode 1 is the fundamental |
| `wavelength`, `wavelength_pos`, `frequency_eq_speed_div_wavelength` | λₙ=2L/n and fₙ=c/λₙ |
| `modeShape`, `modeShape_left`, `modeShape_right` | sin(nπx/L) is zero at both fixed ends |

The sine boundary checks provide a concrete fixed-end-compatible spatial
profile. They do not prove that all PDE solutions decompose into these modes.
`n : ℕ+` excludes the zero-frequency/non-oscillating case from the physical mode
API. No diameter, circular cross-section, material, numerical unit conversion
or particular source result appears in the reusable model.

`VibratingStringExamples.lean` independently checks a different string, positive
modes, harmonic scaling, wavelength relation and fixed boundary values. Future
applications include string-length/tension tuning, comparing harmonics,
recovering linear density, and strings with other cross-sectional shapes.

## Possible upstream integration

```text
Physlib.ClassicalMechanics.WaveEquation / harmonic waves
        ↓  (future mechanical and fixed-boundary bridge)
Physlib.ClassicalMechanics.VibratingString
        ↓
material/geometry-specific textbook problems
```

The present PhyslibTemp API is an upstream-oriented model prototype, not a claim
that the missing PDE bridge has already been implemented. Namespace, quantity
typing and the relationship between an adopted spectral law and a future PDE
derivation should be reviewed with Physlib maintainers. Cylinder geometry and
source arithmetic remain in consumers such as P13.
