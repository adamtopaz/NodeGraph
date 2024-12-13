import Lean

open Lean

namespace NodeGraph

namespace CollectDeps

private structure State where
  visited : Std.HashSet Name := {}
  usedConsts : Std.HashSet Name := {}

private partial def collectDepsAux (c : Name) :
    StateRefT State CoreM Unit := do
  let state ← get
  unless state.visited.contains c do
    let env ← getEnv
    let some const := env.find? c
      | throwError "Failed to find {c} in environment"
    let usedConsts ← const.getUsedConstantsAsSet.toArray.filterM fun t => Bool.not <$> do
      if t matches .str _ "inj" then return true
      if t matches .str _ "noConfusionType" then return true
      let env ← getEnv
      pure <| t.isInternalDetail
        || isAuxRecursor env t
        || isNoConfusion env t
       <||> isRec t <||> Meta.isMatcher t
    modify fun s => {
      visited := s.visited.insert c
      usedConsts := s.usedConsts.union <| .ofArray usedConsts
    }
    for d in usedConsts do collectDepsAux d

private def collect (c : Name) : CoreM (Std.HashSet Name) := do
  let go := collectDepsAux c |>.run {}
  let (_, out) ← go
  return out.usedConsts

end CollectDeps

def collectDeps (c : Name) : CoreM (Std.HashSet Name) :=
  CollectDeps.collect c
