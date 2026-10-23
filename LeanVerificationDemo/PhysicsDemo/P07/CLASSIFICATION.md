# P07 classification

| Component | Classification | Boundary |
| --- | --- | --- |
| Physlib `WithDim`, LTMCT dimension algebra | Existing Physlib primitive | Length, resistivity and current dimension tags |
| Upstream differential `faradayLaw` | Existing Physlib formal theorem, inspected but not used | No formal loop/source-unit bridge is claimed |
| Mathlib derivatives, interval integral and integrability | Pure mathematics | Actual analytic API reused |
| `Length`, `Resistivity`, `Current` | P07-specific modeling | Local aliases of Physlib quantities in fixed source coordinates |
| Fig. 203 caption, `a`, `b`, `h`, positive radii/order/height | P07-specific geometric input | Caption contains only visible geometry |
| `RingData.ρ`, `k`, their positivity | P07-specific source/model parameters | Material/field information from text, not caption |
| `field` (`H = kt`) | P07-specific source modeling | Homogeneous axial historical scalar, not automatically SI B |
| `sourceFactor` | P07-specific unit convention | Exact `1/100000000`; conversion dimension carried implicitly by the coordinate law |
| `flux`, `resistanceCoefficient` | P07-specific physical modeling | πx²H proxy and leading-order thin-ring resistance per inverse width |
| `Response.faraday`, `Response.ohm` | P07-specific physical assumptions | Integral Faraday magnitude and strip Ohm relations, no new axioms |
| `totalCurrent` | P07-specific continuum modeling | Radial integral of independent concentric current contributions |
| `Candidate.flux_derivative` | Derived equation / pure mathematics | Differentiate the prescribed linear field law |
| `Candidate.current_per_width` | Derived physics | Combine Faraday, Ohm, geometry and source convention |
| `Candidate.current_integrable` | Pure mathematics | Derived linear density really is integrable |
| `Candidate.solution` | Derived physics | Integrate the local density to obtain the source formula |
| Cancellation, rational/ring algebra, interval integration | Pure mathematics | No physical relation is proved by algebra alone |
| `Verifier.exampleResponse`, inhabited parameter example | Pure mathematics | Consistency witnesses, not final-formula premises |

P07 introduces **no PhyslibTemp declarations**. Neither the thin-ring geometry
nor the historical source-unit convention is exported as a reusable API.
