import LeanVerificationDemo.PhysicsDemo.P14.Units

namespace LeanVerificationDemo.PhysicsDemo.P14
#check CoupledPendulumData
#print IsModeFrequency
#print TrustedPhysicsProblem
#check Candidate.equal_bob_heights
#check Candidate.in_phase_extension
#check Candidate.anti_phase_extension
#check Candidate.source_restoring_force
#check Candidate.anti_phase_torque_derivative
#check Candidate.in_phase_angular_frequency
#check Candidate.anti_phase_angular_frequency
#check Candidate.solutionFrequencies
#check Candidate.solutionFrequencies_valid
#check Candidate.solution
#print axioms Candidate.solution
example (data : CoupledPendulumData) : TrustedPhysicsProblem data := Candidate.solution data
end LeanVerificationDemo.PhysicsDemo.P14
