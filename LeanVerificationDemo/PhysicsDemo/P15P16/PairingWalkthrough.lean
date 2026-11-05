import LeanVerificationDemo.PhysicsDemo.P15P16.Units
import LeanVerificationDemo.PhysicsDemo.P15P16.CandidateAnnotated764
import LeanVerificationDemo.PhysicsDemo.P15P16.CandidateAnnotated766

namespace LeanVerificationDemo.PhysicsDemo.P15P16
#print P764.TrustedPhysicsProblem
#print P766.TrustedPhysicsProblem
#check P764.Candidate.path_square_identity
#check P764.Candidate.solutionSpacing
#check P764.Candidate.bright_fringe_positions
#check P766.Candidate.maxima_minima_interchange
#check P766.Candidate.lloyd_center_minimum
#check P766.Candidate.half_period_shift
#print axioms P764.Candidate.solution
#print axioms P766.Candidate.solution
#print axioms P764.CandidateAnnotated.solution
#print axioms P766.CandidateAnnotated.solution
example (data : ScreenData) : P764.TrustedPhysicsProblem data := P764.Candidate.solution data
example (data : ScreenData) : P766.TrustedPhysicsProblem data := P766.Candidate.solution data
end LeanVerificationDemo.PhysicsDemo.P15P16
