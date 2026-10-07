import Lake
open Lake DSL

package «lean-verification-demo» where
  packagesDir := "../math2physics/Lean/physlib/.lake/packages"

require mathlib from "../math2physics/Lean/physlib/.lake/packages/mathlib"
require Math2Physics from "../math2physics/Lean"

@[default_target]
lean_lib LeanVerificationDemo
