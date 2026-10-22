# Existing P02 mutation checks

These six previously created checks were adapted to the revised molar model
because the repository verifier always runs its mutation stage. No new mutation
cases were added in this phase. The historical filename `VolumeScalingMutation`
now tests the corresponding modern mass/amount relation.

| ID | Change | Expected |
| --- | --- | --- |
| GAS-P001 | Replace `n = m/μ` with `n = μ/m` while reusing the original evidence | REJECT |
| GAS-P002 | Replace `pV = nRT` with `pV = nR/T` | REJECT |
| GAS-P003 | Reverse `m/μ` in the final equation | REJECT |
| GAS-P004 | Specialize the target to one mole but reuse the general proof without rewriting | REJECT |
| GAS-P005 | Insert an unused arithmetic fact | ACCEPT |
| GAS-P006 | Delete the equation of state, retaining only the mass/amount relation | REJECT |

The specialized equation is valid when `m = μ`; rejection here means that the
unchanged general proof term does not directly inhabit the specialized type.
A rewrite would adapt it. Deletion tests the particular broken proof, not a
general independence theorem. Diagnostic fragments exclude import/file failures.

Run `python3 scripts/verify.py P02` from the repository root.
