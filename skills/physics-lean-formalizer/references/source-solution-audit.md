# Source and solution audit

Preserve the original request and supplied solution independently. The solution
is evidence for intended modeling, not a theorem oracle. If absent, derive an
answer using the audited model and say no supplied-solution comparison was possible.

For every premise and consequential step, record source location or declaration,
classification, whether assumed/defined/proved, and where the final proof uses it:
source fact; source-solution-only assumption; formalization choice; reusable
physics; derived physics; pure mathematics. Mixed classifications may be split
into several rows. Record unused source/model assumptions rather than claiming
they participated in the proof.

Check physical domain/signs, existence, boundary conditions, coordinate/angle
conventions, exact versus approximate laws, source unit meanings and arithmetic.
Do not assume an intermediate relation because the supplied explanation skips it.
Classify idealizations as such, and document whether the source actually states them.
A missing conventional numerical constant such as g=9.8 is a formalization
choice (P09/P12), never a newly attributed source fact.

P08 supersedes treating apex rest and across-event conservation as given facts:
constant-acceleration coasting implies the height maximum and zero apex velocity;
Newton II/III gives finite-duration momentum balance; external impulse tends to
zero; endpoint convergence yields event equality. Existence/matching of those
regularizations remains an explicit assumption. Zero impulse at finite duration
would be false. Do not require every future mechanics problem to rederive all
laws: use the appropriate already-proved reusable theorem and expose its premises.

P05 corrects universal slipping claims: if the critical position exceeds the
ladder length, the entire physical ladder can remain statically admissible.
P06 formalizes only retained approximate propagation channels, not an absolute
ban on real beyond-line-of-sight reception. P07 preserves a historical field/unit
coefficient and explicitly does not identify H with SI B. Such unresolved unit
interpretations constrain the theorem's scope and are not templates for claiming
full unit verification on unseen problems.

P11 corrects terminology by solving ray geometry: upright/inverted reflected-light
loss differs from blockage of the unreflected channel. Predicate names must track
physical meaning. P12/P13 audit printed numbers without forcing false equalities.

When a discrepancy can be resolved with a justified exact/approximate distinction,
retain the source, prove the corrected result, and report it. When resolution
requires guessing a materially different experiment/model, defer with
`source_solution_inconsistency` or `source_ambiguity`, listing alternatives and
what clarification would resolve them. Do not fabricate a proof by contradictory
premises or silently weaken the requested task.
