# Installation, execution, evaluation and versioning

## Codex

Review this directory independently before installation. From a checkout, copy or
link the complete physics-lean-formalizer folder into the skill discovery directory
supported by the installed Codex runtime (commonly project `.agents/skills/` or
user `~/.agents/skills/`; some packaged environments use `~/.codex/skills/`).
Consult the installed runtime's skill list instead of assuming all hosts use one
path. This draft is intentionally kept in repository `skills/` for review and has
not been installed automatically. Invoke explicitly by path during review:

```text
Use the physics-lean-formalizer skill at /path/to/skills/physics-lean-formalizer/SKILL.md.
Read request.json and handle exactly that one problem. Preserve existing demos.
Write run-report.json and return its JSON object.
```

Validate the input before work:

```bash
python3 SKILL/scripts/validate_contract.py input request.json
```

After formalization, from the pinned repository environment:

```bash
python3 SKILL/scripts/check_run.py --repo REPO --code P14 --out RUN/evidence \
  --axiom LeanVerificationDemo.PhysicsDemo.P14.Candidate.solution \
  --axiom LeanVerificationDemo.PhysicsDemo.P14.CandidateAnnotated.solution
python3 SKILL/scripts/validate_contract.py report RUN/run-report.json
```

Use a fresh output directory for every attempt. Add `--extra-lean` for each new
shared example and `--regression` when shared/infrastructure changes require all
gold checks. --timeout bounds each command, not the entire session. The host must
enforce total budget. The checker reads repository code that can execute commands;
run it in the caller's reviewed sandbox, not against arbitrary downloaded code.

`check_run.py` emits evidence.json and logs, **not** run-report.json or semantic
acceptance. The agent fills the report after reviewing those results and source
semantics. It screens admissions in local/shared Lean and uses actual axiom
probes for named final declarations. Leakage token warnings cannot block or
certify semantic correctness by themselves. For host-side schema checks provision
Python 3.10+ and jsonschema>=4; no extra Lean project dependency is introduced.

## Mohsen's LLM API integration

A text-only completion cannot compile Lean. Provide an execution harness with
filesystem read/write, search and shell access to an isolated checkout containing
the pinned toolchain, resolved library source and compiled caches. Keep one
problem per agent session, unique PXX/run directory and a bounded resource budget.
The checkout must contain the locked corpus and PhyslibTemp APIs this draft targets.
The skill is not a replacement for the repository/library environment.

Portable option: expose this entire folder to the agent, load SKILL.md as workflow
instructions, supply one schema-valid request, and let it read routed references
and execute tools. If a provider lacks native skill discovery, the harness can
advertise name/description/path and provide the same read-file tools. Do not send
only SKILL.md while omitting referenced files, scripts or schemas.

Current OpenAI integration options are described in the official Skills guide:
https://developers.openai.com/api/docs/guides/tools-skills
It supports skills with shell execution environments; choose the host's documented
local/hosted mechanism and pin the uploaded skill version. These transport details
can change, so this draft deliberately avoids hardcoded model/endpoint payloads.
No new API-backed program or credentials are needed to review/test these files.

Host prompt example:

```text
Use physics-lean-formalizer version 0.1.0 at <mounted skill path>.
Input is the one request in <request path>. Read the relevant references.
You have a pinned Lean workspace and tool access. Follow the request budget.
Do not modify other problems or dependency pins. Preserve all logs.
Return only a run-report object validated against the bundled v1 schema.
If materially blocked, return a structured deferral with evidence.
```

Enforce the output schema using the API's structured-output capability when
available, and validate the saved artifact independently. Check evidence/hashes
and review disposition before accepting. Retries preserve earlier logs and input
hash; change the strategy or environment rather than simply re-prompting forever.
The orchestrator owns scheduling, concurrency, idempotency, queueing and commits.
Future component: physics-lean-batch-orchestrator. It reads one input, invokes this
skill, validates the report, accepts/retries/queues review, then continues. It is
not included here. Gold regression loops test existing proofs and do not formalize
many new source problems in a single skill invocation.

## Evaluation protocol

See evals/evals.json. Each case has a realistic prompt, source fixture, expected
observable outcomes and qualitative review. Run in a fresh isolated checkout per
case, mounting only source inputs and the existing shared library; remove the
target gold PXX implementation from the evaluation workspace or use a separate
reference-only snapshot inaccessible to the model. Otherwise copying the gold
Candidate would confound the evaluation. Keep the evaluator's expected answers
and policy notes out of the generating agent context.

Gold tests: mechanics (P09), figures (P11), table/rounding (P12), open find and
printed approximation (P13); P08 is an additional singular-event regression.
Use held-out parameter changes and missing-input/failure cases to test transfer.
When comparing skill versus baseline, use identical raw input, pins, tool budget
and evaluator; retain outputs from both and assess source fidelity as well as
build success. Use objective checks plus a blinded domain review where feasible.
No external model-driven eval has been run merely by creating these fixtures.

Automatic evidence checks: build/selected verifier, no admissions, final axioms,
explicit output files and hash inventory. Compile evaluator-supplied Lean probes
for wrong answers, conversions, exact-versus-rounded relations and witnesses.
Names may differ legitimately: adapt the probe to the returned API without changing
its proposition, or request a documented map of output declarations. Do not use
regex as proof of a mathematical property or demand a particular proof spelling.
A reviewer checks transitive answer separation, physical adequacy and real shared
API use; a clean lexical scan is insufficient.

Grades: each objective/qualitative item is pass/fail/not_run with evidence;
critical source-fidelity, leakage, false equality, axiom or build failures fail the
case. Structured deferral is the correct pass for deliberately ambiguous/missing
infrastructure cases. Do not average catastrophic methodology failures away.
Record latency/cost/attempts separately, not as correctness. Inspect regressions
before revising the skill and rerun only affected tests plus the critical suite.

## Versioning

Draft release: 0.1.0. Contract schemas: 1.0.0. Gold corpus baseline is an immutable
commit with per-file hashes, distinct from skill version. Record skill Git commit
or bundle digest alongside skill_version in deployment metadata; tag reviewed
releases (e.g. physics-lean-formalizer-v0.1.0) outside the core invocation.

Use patch versions for clarifications preserving behavior/schema; minor for new
policies/evals/APIs with compatible contracts; major for incompatible contract or
acceptance/model-boundary changes. Never silently rewrite report semantics.
For a new gold problem: record the source and corrections, decide whether each
lesson is stable or experimental, add a regression case, update corpus lock and
review policy diffs. Revalidate M00/P01–P13 plus affected additions. Keep a release
review outside SKILL.md rather than accumulating prompts in its entrypoint.
