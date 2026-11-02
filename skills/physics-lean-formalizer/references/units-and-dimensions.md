# Units and dimensions

Keep native values/units in source provenance, choose coherent coordinates for
computation, and prove each nontrivial conversion. Prefer upstream WithDim,
Dimension, unit choices and Dimensionful before local aliases/adapters.

A relevant check has three parts: well-typed products/divisions with proved
dimension equalities; actual source-unit conversion; a theorem linking the typed
expression to Candidate's scalar result. Assigning a unit tag to a final number
without those bridges does not establish dimensional consistency of the derivation.
Dimensions do not prove a friction law, collision law, or physical premise.

P09 checks Newton/friction/stopping dimensions, scalar-to-typed equations and a
wrong v/(gs) expression's non-dimensionlessness. P12 converts upstream
DimSpeed.oneKilometerPerHour to 5/18 m/s, connects each source speed, and proves
the typed estimator equals tableEstimate. The 70 arithmetic checks need not be
repeated inside dimension-indexed expressions.

P13 keeps cm, mm, dyn and g/cm³, converts mm to cm before CGS arithmetic, and
separately proves SI values: 0.5 m, 0.001 m, 0.0245 N, 7800 kg/m³.
A local dyne wrapper uses upstream dimensions and proves g·cm/s² and 10^-5 N.
Mechanical CGS does not specify electromagnetic Gaussian-CGS conventions.
Frequency is cycles/time, not angular frequency. Mixed scales cannot be treated
as interchangeable bare reals.

At the baseline pin, WithDim has no generic quantity square-root operation.
P13 proves half-power dimension identities and uses local sqrt wrappers tied
to scalar formulas. This proves the displayed dimensions/values, not a generic
sqrt unit-covariance theorem. ISQ's substance amount must not be silently erased
through LTMCT conversions (P02).

Set units_checked to passed only with compiled relevant evidence. Use
not_applicable with a reason if no dimensional claim exists; use deferred/failed
and `unit_infrastructure_gap` when needed bridges cannot be justified. Historical
P07 limited source-unit modeling is not evidence of a complete SI conversion.
