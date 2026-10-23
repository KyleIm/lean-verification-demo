import LeanVerificationDemo.PhysicsDemo.P05.Candidate

namespace LeanVerificationDemo.PhysicsDemo.P05
#check Candidate.solution
#check Candidate.reactions_required
#check Candidate.required_strictMono
#check Candidate.admissible_iff
#check Candidate.required_at_critical
#check Candidate.reachable_threshold
#check Candidate.unreachable_threshold
#print axioms Candidate.solution
example (data : LadderData) : TrustedPhysicsProblem data := Candidate.solution data
end LeanVerificationDemo.PhysicsDemo.P05
