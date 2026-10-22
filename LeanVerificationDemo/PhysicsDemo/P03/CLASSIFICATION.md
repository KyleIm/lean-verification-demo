# P03 component classification

| Component | Classification | Boundary |
| --- | --- | --- |
| Physlib `WithDim`, dimension generators and arithmetic | Existing Physlib primitive | Imported, not reimplemented |
| Charge / voltage / capacitance / field / gap aliases | Existing Physlib primitive (specialized by local abbreviations) | Coordinates of existing dimensional wrapper in C, V, F, V/m, m |
| `PlaneCapacitor` and `voltage` (`U=Q/C`) | PhyslibTemp reusable physical relation | Generic ideal linear capacitor: C and gap only, plus positivity; no mandatory failure data |
| `BreakdownSpec c` | PhyslibTemp reusable physical relation | Optional positive dielectric-failure specification indexed by c, in a separate module |
| Common series charge Q | Problem-specific modeling | One shared argument; assumes ideal series string with neutral intermediate conductors |
| `DielectricScaling` (`Cfilled=εr Creference`) | PhyslibTemp reusable physical relation | Supplied fixed-geometry constitutive scaling; equal gap explicitly encoded; equal area/remaining geometry supplied externally; not derived from C = ε A/d |
| `field` (`E=U/d`) | PhyslibTemp reusable physical relation | Uniform-gap coordinate model |
| `voltage_eq_field_mul_gap` (`U=Ed`) | Derived physics | Algebraic consequence of uniform-gap definition |
| `BreakdownSpec.breakdownVoltage`, `BreakdownSpec.Admissible` | PhyslibTemp reusable physical relation | Inclusive threshold `U≤Ebreak d`, nonnegative Q |
| `BreakdownSpec.field_le_iff` | Derived physics | Equivalence to `E≤Ebreak` for a positive gap |
| `BreakdownSpec.chargeAtLimit`, `BreakdownSpec.voltage_at_limit`, `BreakdownSpec.admissible_at_limit` | Derived physics | Threshold operating charge and attainability |
| `voltage_of_dielectric_scaling` | Derived physics | Common Q plus dielectric scaling gives inverse voltage ratio |
| `BatteryData`, `SourceData`, `airTotal`, `mixedTotal`, `mixedAdmissible` | Problem-specific modeling | Capacitors plus separate failure specs; source field values/gap/εr, identical copies and voltage addition |
| `MaximumVoltage` | Pure mathematics | Upper bound plus an admissible witness attaining it |
| `TrustedPhysicsProblem` | Problem-specific modeling | Both numerical maxima and strict glass safety comparison |
| `Candidate.glass_voltage_at_air_limit` | Derived physics | P03-only source-data evaluation: Ea d / εr = 3000 V; never part of PhyslibTemp |
| Candidate symbolic maxima / final solution | Derived physics | Order bounds and explicit operating state, followed by evaluation |
| Rational normalization, cancellation, rewriting, inequality arithmetic | Pure mathematics | No new physical assumptions |

Audit evidence and existing general field APIs: [PHYSLIB_AUDIT.md](PHYSLIB_AUDIT.md).
No new mutations or physical constants were introduced. No existing dependency
pins were changed. The field relation is a uniform-gap specialization, not a
claim to have formally derived the capacitor from continuum electromagnetism.

The shared q is a supplied series-configuration premise, not a theorem from a
formal circuit graph. Inclusive failure thresholds remain a modeling convention
for attained maxima. “Breakdown” normalizes the historical “puncturing” wording;
it is not presented as a literal source quotation. The structural refactor does
not change the final trusted proposition semantically or alter `MaximumVoltage`.
