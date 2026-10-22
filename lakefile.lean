import Lake
open Lake DSL

package «lean-verification-demo» where

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.35.0"

require Physlib from git
  "https://github.com/leanprover-community/physlib.git" @
  "96a6bc5e3c50a2856c64a6c9951c0a1c23790b58"

@[default_target]
lean_lib LeanVerificationDemo
