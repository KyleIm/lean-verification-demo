# Exact values, resolution and measurements

Separate exact mathematical equality, numerical approximation/error bounds,
decimal-place resolution, significant figures and empirical uncertainty. A
terminating decimal can be an exact rational coordinate of recorded data without
claiming the physical measurement is exact. Preserve its spelling independently.
Never invent uncertainty bands because a table looks experimental.

P12 has seven surfaces and ten speeds in km/h: preserve all 70 metre entries.
Derive the friction estimator from mechanics, convert speeds, compute an answer,
then check every cell against requested first-decimal resolution. Its precise
convention is a tenth-grid value c and band c-1/20 ≤ x < c+1/20, ties toward the
larger grid value. All actual entries are strictly inside their bands. Raw ice
estimates at different speeds are provably unequal. No single exact μ is asserted
to generate all ten distances; consistent per-row models and a common rounded
assignment are the justified claim. Do not smooth or synthesize the source table.
The specific g=49/5 is a documented choice, not a table fact.

P13's exact source model yields f1 = sqrt(490/(39*pi)) with
1.9998 < f1 < 1.9999, hence f1 ≠ 2. The printed equality to 2 is audited as an
approximation. Nearest-whole-Hz is a formal interpretation consistent with the
printed integer, not a source-specified tie rule. The tighter interval is a
proved strengthening, not precision claimed by the author. Do not invent a π
convention: neither 3.14 nor 22/7 makes the square exactly 4. The exact family is
n*f1; its error against 2n is < n/5000. This does not imply uniform whole-Hz
rounding to 2n for arbitrarily high modes.

Prefer exact rationals, Real.pi and certified inequalities; exploratory floating
point is not a Lean proof. Do not force a printed approximate equality into an
exact target. Requested significant figures require magnitude-dependent bounds,
not automatically a fixed decimal-place interval. State tie/domain conventions
only where needed. If a convention affects the answer and the source does not
resolve it, defer `numerical_approximation_ambiguity`; if all values lie away from
ties, explain why the choice is immaterial. Keep audit-only rounding out of the
trusted target unless precision is itself part of the source request (P12).
