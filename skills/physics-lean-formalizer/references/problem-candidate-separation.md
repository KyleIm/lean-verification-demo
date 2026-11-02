# Semantic specification and solution construction

The trusted statement must describe what counts as a solution before a particular
answer is known. Model semantics and solution algebra have different roles.

For an open “find X” request, normally define `IsSolution data x` using the source
conditions and adopted physical model, then ask for `∃ x, IsSolution data x`.
Use `∃!` only if uniqueness is physically and mathematically justified. Multivalued,
gauge-dependent or symmetry-related answers may need a set, equivalence class,
parameterized family, or existence without uniqueness. Do not add uniqueness to
make every problem resemble P13. A source “prove relation R” may legitimately put R
in the target. An answer discovered for a “find” problem generally may not.

Candidate constructs an explicit answer, proves it satisfies the criterion, and
proves requested uniqueness/completeness at the justified model boundary. A
trivial witness copied from the model may certify existence but does not finish
a requested computation; additionally derive and return the explicit answer.

P13's final Problem uses `IsNaturalFrequencySolution data freq := ∀ n,
freq n = (fixedString data).frequency n`, then existential uniqueness. The
Candidate derives cylinder geometry, the source specialization and explicit
`n * sqrt(490/(39*pi))` family. General `FixedString.frequency` is permissible
reusable physics, though it encodes the ideal mode law. Putting the combined
cylindrical formula, numerical family, or printed `2n` into the trusted target
would circumvent the task. Positivity and elementary representation geometry can
remain in Problem; meaningful problem-specific derivations belong in Candidate.

P12's target finds the coefficient assignment satisfying a rounding grid and
physical compatibility. An estimator expression is permitted as an operational
criterion only with a real bridge to braking mechanics: final validity uses the
derived estimator and Verify constructs consistent runs. Copying a textbook
formula into a criterion with no physics bridge would merely verify arithmetic.

## Review the transitive boundary

Review Problem and everything it uses, including local helper imports and shared
modules. Renaming an answer `model`, hiding it in a data field, assuming an
intermediate result, or placing a circular IsSolution definition in PhyslibTemp
does not make it trustworthy. Problem must not import Candidate/Verify/Units
when those import Candidate. Test that source evidence contains only source
inputs and separately classified legitimate model assumptions.

Ask: could this specification have been written from the question and chosen
general model without consulting the answer? Does it still ask the source task?
Would a wrong answer be rejected? Is the selected evidence satisfiable? Does
Candidate actually use the claimed physical law in proving validity?

Earlier P03 numerical maxima, P04 `answer := 6C/5`, P09's exact/rounded numbers,
P10 means, and P11's explicit shadow conclusions are historical closed targets.
They provide useful derivation/test evidence but do not override the later
P12/P13 open-request policy. Preserve gold files; do not silently migrate them.
P11's conditional regimes are useful tests of source assumptions versus derived
cases, not a blanket license to put newly discovered results into any find target.

Lexical answer checks are warnings. Source constants such as a given 2 or π
are legitimate; equivalent algebra, aliases and transitive leakage defeat token
matching. Meaning-level review is required even after all lints pass.
