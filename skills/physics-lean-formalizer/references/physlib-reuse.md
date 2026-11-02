# Pinned-library reuse audit

Read lean-toolchain, lakefile and lake-manifest; check package git HEADs before
searching `.lake/packages/Physlib/Physlib` and `.lake/packages/mathlib/Mathlib`.
Use `rg --files` for orientation, then semantic/synonym `rg -ni` searches across
stable Physlib. Read relevant definitions/theorems and their assumptions in
context; inspect neighboring modules. Search Mathlib for mathematical operations
and existing PhyslibTemp for previously added physics. Absence is scoped to this
revision and search, never inferred from a filename alone.

PHYSLIB_AUDIT records commands, roots, useful hits, qualified declaration names,
actual types, formal versus informal status, and reasons for reuse/non-reuse.
Distinguish: formal stable API; generic infrastructure usable via adapters;
related but mismatched model; informal_lemma/TODO/documentation; Alpha-only API;
no suitable result found. Inspect Alpha as secondary evidence if useful, but
avoid treating it as stable or importing it without explicit compatibility review.

Examples of important mismatches:
- P02: microscopic normalized IdealGas law uses natural particle count and a
  normalized constant; it is not a real molar-amount equation with symbolic R.
  AmountUnit denotes a scale; WithDim represents a sample quantity.
- P05: rigid-body informal lemmas are not formal torque/equilibrium results.
- P09/P12: static friction bounds do not supply saturated moving/braking friction;
  a sliding-pendulum name does not imply a kinetic friction API.
- P11: Mathlib reflection supplies mathematics; reusable ideal optical semantics
  still need a physical interpretation. Do not use a decorative unused PDE import.
- P13: traveling wave solutions take wave speed as input; they do not establish
  tension/density speed, fixed-end quantization or spectral completeness.

Reuse applicable upstream semantics, not just imports. Minimal local projections
of an existing model are often sufficient (P12 reuses ConstantAcceleration but
not P09's two-leg assumptions). A small missing named quantity can be an alias
of upstream units; it does not justify reinventing dimension algebra.
