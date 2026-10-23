# P06 — Why is television reception limited by direct visibility?

Source problem **656** asks: “Why can TV programmes be seen only within the
range of direct visibility?” The supplied solution says that TV wavelengths
are below 10 metres, that the ionosphere is “transparent” to them and does not
reflect them, and that they undergo almost no diffraction around obstacles
such as houses, so they propagate practically in straight lines.

## How TV reception is represented in Lean

There is no reusable `TV`, `TVStation` or `TVProgramme` object. `ReceptionData`
collects one positive wavelength and a qualitative transmitter–receiver link.
The wave uses stable Physlib's dimension-tagged `Wavelength`; its numerical
coordinate is in **metres**, so the source cutoff is 10. The link records direct
visibility and direct, ionospheric reflected-return and diffracted path
propositions. Transmitter and receiver positions and obstacle geometry are
abstracted away: visibility means an unobstructed direct segment supplied by the
application, not a computed geometric intersection test. Reception here means
availability of a retained propagation path, not decoding a programme or meeting
a signal-strength threshold.

## Printed explanation and adopted approximation

The source chain is preserved:

```text
λ < 10 m → ionosphere treated as transparent → no reflected return
λ < 10 m → diffraction around relevant obstacles treated as negligible
negligible diffraction → adopt straight-line propagation
straight-line direct path → unobstructed line of sight
blocked line of sight + excluded return/diffraction → no retained path
```

`SourceData` supplies the two regime implications and the actual wavelength
bound. Neither is proved from wavelength algebra. “Transparent” excludes the
modeled **ionospheric** return, not all reflection. “Almost no diffraction” is a
predicate selecting an approximation: the generic model explicitly assumes that
its diffracted channel is omitted in that approximation. “Practically straight”
is a straight-line approximation predicate whose direct paths require visibility.
These are exact rules **inside an approximate model**, not exact laws of nature.

`HasPath` includes only direct, reflected-return and diffracted channels. Other
reflection, scattering, refraction, ducting and engineering reception effects
are outside its scope. The proof does not establish that real television signals
can never be received beyond line of sight. Nor does visibility alone guarantee
real reception. The conclusion is a necessary condition in this restricted model.

## Methodological significance of this formalization

Compared with P05, where force and moment balance yield a position-dependent
friction requirement and its threshold, P06 places much of its substantive
physics in the adopted model. The absence of ionospheric reflected return in
the relevant wavelength regime, negligible diffraction around the relevant
obstacles, and the adoption of geometric propagation when diffraction is
neglected are explicit source assumptions or propagation-model rules. Lean does
not derive them from Maxwell equations, plasma physics or diffraction theory.

The candidate mainly checks the deductive step within that model:

```text
exclude ionospheric reflected path
+ exclude diffracted path
+ direct geometric path requires line of sight
→ no line of sight implies no retained propagation path
```

This separation is intentional. Textbook explanations often compress empirical
knowledge, regime-dependent approximations, idealizations and deductive
reasoning into a few sentences. Formalization makes their different roles
explicit: Lean rigorously verifies the consequences of the adopted model,
while the choice and validity of its approximations remain physical modeling
assumptions unless a deeper theory is formalized. P06's physical content lies
heavily in those assumptions; the visibility conclusion follows logically
inside the model. This distinction clarifies the physical explanation and the
scope of the proof.

The theorem therefore does not claim that real TV signals can never be received
beyond line of sight: other propagation mechanisms remain outside the restricted
model. The reusable module stays in `PhyslibTemp/Optics`, which suits its
wavelength, reflection/diffraction, geometric-propagation and visibility
abstraction; it does not provide a field-level Maxwell/plasma model.

## Trusted proposition and candidate

For `data : ReceptionData`, the trusted proposition is exactly:

```lean
(¬ data.model.reflectedReturn) ∧
data.model.negligibleDiffraction ∧
data.model.straightLine ∧
(data.model.HasPath → data.model.lineOfSight) ∧
(¬ data.model.lineOfSight → ¬ data.model.HasPath)
```

The checked judgment is
`Candidate.solution data source : TrustedPhysicsProblem data`, where
`source : SourceData data`. The candidate applies both regime assumptions,
selects the geometric approximation, eliminates the reflected and diffracted
cases, and uses visibility for the direct case. The final no-path conclusion is
not a field of the source evidence. Verify includes consistent visible and
blocked models; the visible model retains an actual direct path.

## Boundaries and verification

Stable Physlib supplies the wavelength quantity. PhyslibTemp supplies only the
reusable qualitative propagation/approximation interface. The cutoff and
ionospheric interpretation belong to P06; the final path restriction is derived;
case elimination is pure logic. See [classification](CLASSIFICATION.md) and
[pinned-source audit](PHYSLIB_AUDIT.md).

`source.jsonl` separates the supplied source wording from the corrected formal
interpretation. No original scan or additional diagram is reconstructed here.

Run `lake build` and `python3 scripts/verify.py P06`. Mutation tests are explicitly
deferred (`mutations.json` is empty). `PairingWalkthrough.lean` prints final
axioms; the candidate uses no additional physical axioms beyond its explicit
model/source arguments.

Validation for this addition: `lake build` passed (3383 jobs); P06, P05, P04,
P03, P02, P01 and M00 verification all passed. P03–P06 explicitly skipped
mutations; M00/P01/P02 each passed all six existing cases.
`#print axioms Candidate.solution` reports exactly
`[propext, Classical.choice, Quot.sound]`; no `sorry` or new axioms were added.
