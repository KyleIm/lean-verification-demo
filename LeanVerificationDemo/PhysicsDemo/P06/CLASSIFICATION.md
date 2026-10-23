# Classification

| Component | Classification | Boundary |
| --- | --- | --- |
| `Wavelength`, `WithDim L𝓭 ℝ≥0` | Existing Physlib primitive | Length-tagged wavelength, reused unchanged |
| `PropagationModel` | P06-specific modeling | Qualitative single-link model with explicit approximation rules |
| `negligibleDiffraction`, `straightLine` | P06-specific modeling | Model predicates, not measured bounds or Maxwell limits |
| `geometricApproximation`, `omitDiffraction`, `directRequiresVisibility` | P06-specific modeling | Explicit adopted rules, not unconditional physical theorems |
| `PropagationModel.HasPath` | P06-specific modeling | Exhaustive enumeration only of retained channels |
| Wavelength positivity and metre convention, cutoff 10 m | P06-specific modeling | Source regime |
| `SourceData.transparent`, `SourceData.negligible` | P06-specific modeling assumptions | Source claims adopted as approximation assumptions |
| Ionospheric interpretation of reflected channel | P06-specific modeling | Not all reflection; other mechanisms excluded |
| Direct visibility | P06-specific modeling | Geometric visibility is abstract, not computed |
| No reflected return, geometric propagation and visibility necessity | Derived physics | Conditional consequences of the adopted assumptions |
| Blockage implies no retained path | Derived physics | Restricted reception interpretation |
| Disjunction elimination and contradiction | Pure mathematics | Propositional logic |

No TV ontology, propagation solver, exact zero-diffraction law or general
impossibility of real beyond-line-of-sight television reception is introduced.

P06 adds no reusable PhyslibTemp concept. `PropagationModel`, its fields and
`HasPath` live in P06's `Problem.lean`. The propagation rules are
approximation-level physical assumptions rather than derived electromagnetic
laws. The channel decomposition is tailored to this source explanation; broader
reuse has not been established.
