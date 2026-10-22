# P04 classification

| Component | Classification | Boundary |
| --- | --- | --- |
| Physlib dimension basis and `WithDim` | Existing Physlib primitive | Imported by existing capacitor module |
| Existing Charge / Voltage / Capacitance aliases | PhyslibTemp reusable physical relation (existing coordinate aliases) | Reused; no gap or breakdown data needed |
| Mathlib finite sets, Fintype, sums and real arithmetic | Pure mathematics | General finite representation and algebra |
| `CapacitorNetwork` | PhyslibTemp reusable physical relation | Any finite vertex type, symmetric nonnegative coupling matrix, zero diagonal |
| `CapacitorNetwork.nodeCharge` | PhyslibTemp reusable physical relation | Signed Q = C ΔV contributions summed at a conductor; no circuit graph theorem claimed |
| `NeutralInterior`, `DirichletState` | PhyslibTemp reusable physical relation | Neutral isolated interior conductors, specified terminal potentials |
| `HasEquivalentCapacitance` | PhyslibTemp reusable physical relation | Solvability for all boundary potentials and universal terminal charge coefficient |
| `Vertex`, `diagramEdges`, `Adj`, `network` | Problem-specific modeling | Caption's eight names and twelve undirected couplings, all identical C |
| `CubeData` | Problem-specific modeling | C > 0 is the only supplied material condition |
| `answer`, `TrustedPhysicsProblem` | Problem-specific modeling | Claimed 6C/5 and required proof obligation, not assumed physical evidence |
| `all_vertices`, diagram cardinality and layer-count checks | Pure mathematics | Finite data validation |
| `residual`, `charge_formula` | Derived physics | Explicit nodal expressions checked against caption-derived sums |
| `internal_potentials` | Derived physics | Six charge-balance equations force equal potentials within each layer |
| `equilibrium`, `equilibrium_is_state` | Derived physics | Explicit realization for arbitrary boundary values |
| `terminal_charge`, `Candidate.solution` | Derived physics | Establish the charge law and equivalent capacitance |
| Positivity cancellation, linear elimination, rewriting, rational arithmetic | Pure mathematics | No symmetry or series-capacitance assumption |

The source symmetry argument and 3C–6C–3C reduction are documented, but the formal
route uses nodal equations instead. Diagram caption transcription is trusted input;
no claim is made that Lean interpreted a bitmap diagram. No existing P01/P02/P03
API, dependency pin or mutation behavior was changed.
