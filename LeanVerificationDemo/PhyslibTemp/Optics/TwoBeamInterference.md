# Coherent two-beam interference

This module supplies a small optical physical-model layer over stable Physlib
`Wavelength` and Mathlib trigonometry. The audited Physlib revision has no
applicable classical two-beam phase/extrema API. Quantum coherent states and
flavour phase redefinitions are different models.

The adopted model is monochromatic, coherent, scalar/fixed-polarization light
with common wavelength and positive real amplitudes in the overlap region:

```text
phase = 2π (pathDifference / wavelength) + offset
intensity = a² + b² + 2ab cos(phase).
```

Intensity is in coherent amplitude-squared coordinates, with any common
proportionality factor suppressed. This standard time-averaged law is adopted,
not derived from Maxwell fields, a vector-polarization model or detector theory.
The extrema predicates are tied to actual bounds `(a−b)² ≤ I ≤ (a+b)²` and their
equality conditions. Equal amplitudes are not assumed: a destructive-phase
minimum may remain nonzero.

The API proves integer constructive orders, half-integer destructive orders,
path-to-phase order conversion and the exchange of extrema after an arbitrary
input phase gains π. It does not assert that every physical mirror causes π:
the offset is an application input. No screen, far-field assumption, Lloyd
apparatus, source distance or computed fringe spacing belongs to this layer.

P15/P16 actually use `phase_order_iff`, `maximum_iff`, `minimum_iff` and the
π-reversal theorems in witness validity and fringe derivations. The independent
examples test another wavelength, unequal-amplitude nonzero minima and a
rejected maximum at phase π. Likely other users include Young's slits,
interferometer path changes and ideal thin-film phase comparisons. Their
geometry, reflection coefficients and approximation regimes remain separate.

A possible future upstream home is `Physlib.Optics.Interference.TwoBeam`,
depending on `Optics.Wavelength` and Mathlib cosine. This is a small prototype
physical model, not a general electromagnetic superposition framework. The
existing PhyslibTemp plane-mirror direction API stays independent: geometric
reflection does not by itself determine optical reflection phase.
