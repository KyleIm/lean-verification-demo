# P02 component classification

| Component | Classification | Meaning / boundary |
| --- | --- | --- |
| `ISQDimensionBase.amount`, `Dimension.single`, dimension algebra | Existing Physlib primitive | Amount is an independent SI/ISQ base dimension |
| `AmountUnit.moles`, `SIUnitChoices.SI` | Existing Physlib primitive | Existing mole unit and coherent SI unit choices |
| `WithDim` and its generic arithmetic | Existing Physlib primitive | Reused dimension-tagged coordinate quantities |
| `IdealGas.ideal_gas_law` | Derived physics (existing Physlib; not used in P02) | Proves normalized `PV = NT`, with `N : ℕ`, pressure derived from its Hamiltonian, `R := 1`; not a physical molar theorem |
| `Mass`, `Amount`, `Pressure`, `Volume`, `AbsoluteTemperature` aliases | PhyslibTemp primitive/reusable definition | Only abbreviations of existing ISQ `WithDim` specializations; no replacement unit framework |
| `MolarMass`, `MolarGasConstant` aliases | PhyslibTemp primitive/reusable definition | Missing named derived-quantity specializations, kg/mol and J/(mol K) |
| `amountOfSubstanceFromMass` | PhyslibTemp primitive/reusable definition | Coordinate quotient `m/μ` with amount dimension |
| `MassAmountRelation` | PhyslibTemp primitive/reusable definition | Positive μ and sample amount equal to the quotient |
| `MolarIdealGasLaw` | PhyslibTemp primitive/reusable definition | Phenomenological molar relation `pV = nRT` with symbolic parameter R, no fixed universal numerical value; definition of a relation, no axiom |
| `GasData`, `GasEvidence` | Problem-specific modeling | One sample, physical-domain signs, independent evidence of both relations |
| `TrustedPhysicsProblem` | Problem-specific modeling | Statement of the arbitrary-mass target |
| `Candidate.solution`, `CandidateAnnotated.solution` | Derived physics | Combine two reusable physical relations to establish the target |
| `congrArg` / `rw`, projection of equality evidence, unfolding | Pure mathematics | Substitute the amount equality into the molar state equation |
| `Verifier` example and pairing walkthrough | Pure mathematics | Type-check candidate against trusted proposition for the same data |

The normalization issue and search evidence are documented in
[PHYSLIB_AUDIT.md](PHYSLIB_AUDIT.md). In particular, an ISQ→LTMCT projection
forgets amount; it does not supply an Avogadro or thermal-scale conversion.

Signs: μ > 0 is part of the reusable mass relation; m ≥ 0, T > 0 and R > 0
select the physical state domain. Rewriting itself needs no positivity.
No extra p or V signs are assumed for algebraic convenience. The gas law is
assumed for a separately supplied amount, and the mass relation connects that
amount to m and μ; the final arbitrary-mass equation is never an input field.

All equations compare coordinates in fixed coherent SI units. The present API
checks quantity dimensions but does not establish covariance under arbitrary
unit changes, nor derive the phenomenological law from a microscopic model.

The four coordinate aliases are retained after the named-quantity review; see
[the README](README.md#why-retain-the-isq-aliases) for the Mass, Pressure, Volume
and Temperature comparison. No new conversion infrastructure was added.
The mass/amount API's upstream placement remains a design question. A numerical
`universalGasConstant`, Avogadro constant, `N = n N_A` conversion and `R = N_A k_B`
bridge are deferred; none is a premise or implementation dependency of P02.
