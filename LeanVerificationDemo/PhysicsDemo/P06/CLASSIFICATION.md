# Classification

| Component | Classification | Boundary |
| --- | --- | --- |
| `Wavelength`, `WithDim L𝓭 ℝ≥0` | Existing Physlib primitive | Length-tagged wavelength, reused unchanged |
| `PropagationModel` | PhyslibTemp reusable physical relation | Qualitative single-link model with explicit approximation rules |
| `negligibleDiffraction`, `straightLine` | PhyslibTemp reusable physical relation | Model predicates, not measured bounds or Maxwell limits |
| `geometricApproximation`, `omitDiffraction`, `directRequiresVisibility` | PhyslibTemp reusable physical relation | Explicit adopted rules, not unconditional physical theorems |
| `PropagationModel.HasPath` | PhyslibTemp reusable definition | Exhaustive enumeration only of retained channels |
| Wavelength positivity and metre convention, cutoff 10 m | P06-specific modeling | Source regime |
| `SourceData.transparent`, `SourceData.negligible` | P06-specific modeling assumptions | Source claims adopted as approximation assumptions |
| Ionospheric interpretation of reflected channel | P06-specific modeling | Not all reflection; other mechanisms excluded |
| Direct visibility | Problem-specific input to generic model | Geometric visibility is abstract, not computed |
| No reflected return, geometric propagation and visibility necessity | Derived physics | Conditional consequences of the adopted assumptions |
| Blockage implies no retained path | Derived physics | Restricted reception interpretation |
| Disjunction elimination and contradiction | Pure mathematics | Propositional logic |

No TV ontology, propagation solver, exact zero-diffraction law or general
impossibility of real beyond-line-of-sight television reception is introduced.

The propagation rules are approximation-level physical relations rather than
derived electromagnetic laws; their `Optics` placement reflects the model’s
wavelength, path-channel and geometric-visibility abstraction.
