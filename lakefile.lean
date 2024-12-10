import Lake
open Lake DSL

package «AutoBlueprint» where
  -- Settings applied to both builds and interactive editing
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩, -- pretty-prints `fun a ↦ b`
    ⟨`pp.proofs.withType, false⟩
  ]
  -- add any additional package configuration options here

require "leanprover-community" / "proofwidgets" @ git "v0.0.48"

@[default_target]
lean_lib «AutoBlueprint» where
  -- add any library configuration options here
