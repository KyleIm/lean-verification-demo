# P11 classification

| Component | Classification | Boundary |
| --- | --- | --- |
| Fig. 237 qualitative caption | Trusted source/figure facts | Source-visible relative geometry only; no symbols, inequalities or shadow results |
| figure_caption.json / generator / SVG | Caption-derived problem visualization | Geometry only; pixel coordinates and ray count are rendering choices, not source measurements or Lean premises |
| Fig. 494 | Reference-only solution material | No construction or additional premise is extracted |
| h, l, α and positive/acute parameter domains | Formalization/model parameters | Quantify upright object, screen placement and oblique incidence; not original labels/numbers |
| Object origin, mirror y=0, screen x=l | Problem-local coordinate choice | Not source-stated coordinates |
| Extended mirror/screen, opaque segment, binary rays | Explicit problem-local physical idealization | No finite edges, solar disk, penumbra or radiometry |
| Mathlib Submodule.reflection | Existing mathematical geometry | Orthogonal reflection; Mathlib does not assign optical semantics |
| PhyslibTemp PlaneMirror / reflect | Reusable physical model/law | Ideal stationary specular mirror with unit normal and tangent hyperplane |
| tangent_component / normal_component / norm_reflect / reflect_reflect | Reusable derived physics | Consequences of the ideal reflection law |
| incidence_reflection_cosine / horizontal_reflect | Reusable optical theorem surface | Equal unsigned normal-angle ratios and planar component formula |
| mirror / reflection_geometry | P11 specialization of reusable physics | Horizontal placement/direction specialization; no threshold in PhyslibTemp |
| incomingDirection / reflectedDirection / ray families | P11-local optical model | All incoming rays parallel; reflected rays use the reusable ideal-specular law |
| reflection_geometry / incidence_ratio | Derived geometry and angle-convention check | Horizontal component preserved, normal reversed; α measured from the vertical normal to the horizontal mirror |
| ScreenHit / IncidentBlocked / OutgoingBlocked | Local intersection predicates | Existential ray/segment equations with correct before/after parameter domains |
| screen_hit_unique_iff / boundary_ray_intersections | Derived ray geometry | Intersections and uniqueness are proved, not supplied endpoints |
| uprightShadow / invertedShadow | P11 orientation-specific reflected-channel losses | Neither is silently equated with directBlocked |
| directBlocked / reflectedBlocked / illumination predicates | P11 binary availability | Separate physical channels; no radiometric strength claims |
| shadow / fullyDark | Explicit local terminology | At least one channel absent versus both absent |
| threshold_characterization / top_boundary_screen_iff | Derived regime boundary | H−h reaches 0 iff l=h tan α; forward top-boundary hit iff far condition |
| FarScreen / NearScreen | Solution-introduced case predicates | Not source premises and not Geometry fields |
| far_screen_shadow_structure | Derived source geometry | Two lengths h, adjoining bases, total Lebesgue length 2h |
| near_screen_shadow_structure | Derived source conclusion and strengthening | Length H+h<2h; dark interval [0,h−H] has positive length |
| interval_length / verticalLength | Mathlib measure and pure arithmetic | Length of actual sets, not assumed answer fields |
| Units thresholdLength / typed_far_regime | Upstream-unit dimensional verification | WithDim length × dimensionless tan remains length; does not assert the regime |
| Far/near/critical examples | Verification data | Independent test parameters, never trusted source geometry |

The supplied solution calls the two portions a “direct” (upright) and an
inverted shadow. Solving the ray geometry establishes that both are reflected-
light deficits. `directBlocked` retains the distinct unreflected-light meaning;
`uprightShadow` is never identified with it. **Source terminology ≠ formal
physical-channel terminology**: source wording alone must not determine predicate
names when the physics separates different concepts.

The reusable reflection law belongs in PhyslibTemp; all shadow geometry remains
P11-local. No general visibility engine or unit framework is introduced.
