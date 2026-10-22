import Physlib.ClassicalMechanics.Force
import Mathlib.LinearAlgebra.CrossProduct
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

/-!
# Minimal planar statics using Physlib forces

Reuse `ReferenceFrame.Vector` and `ReferenceFrame.Force`, with a single target Unit.
Positions are displacements from a chosen moment origin, not absolute affine points.
For Cartesian orthonormal axes and coherent SI coordinates, force components are
newtons, displacements metres, and signed moments newton-metres. Physlib's frame
vector carrier does not itself encode these physical dimensions.

Vanishing total force and moment is a supplied static balance model. This module
does not derive Newton-Euler contact mechanics or rigid-body motion.
-/
namespace LeanVerificationDemo.PhyslibTemp.ClassicalMechanics

open _root_.ClassicalMechanics

/-- Out-of-plane moment of a planar force, using Mathlib's 3D cross product
with zero third components. No moment-arm formula is assumed separately. -/
noncomputable def planarMoment {frame : ReferenceFrame 2}
    (r F : frame.Vector) : ℝ :=
  crossProduct ![r.components 0, r.components 1, 0]
    ![F.components 0, F.components 1, 0] 2

lemma planarMoment_eq {frame : ReferenceFrame 2} (r F : frame.Vector) :
    planarMoment r F = r.components 0 * F.components 1 -
      r.components 1 * F.components 0 := rfl

/-- Inertial Cartesian frame, zero net force and zero moment about the supplied origin.
Each force acts on the same body; this finite snapshot is not a dynamics theorem. -/
def PlanarStaticEquilibrium {ι : Type} [Fintype ι] (frame : ReferenceFrame 2)
    (r : ι → frame.Vector) (forces : ι → frame.Force Unit) (t : ℝ) : Prop :=
  frame.IsInertial ∧ frame.Orthonormal ∧
  (∀ k : Fin 2, ∑ i, (forces i t).components k = 0) ∧
  (∑ i, planarMoment (r i) (forces i t)) = 0

end LeanVerificationDemo.PhyslibTemp.ClassicalMechanics
