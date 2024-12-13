import NodeGraph.Graph.Basic
import NodeGraph.Utils.CollectDeps

open Lean

namespace NodeGraph

abbrev DeclName := Name
abbrev DeclGraph := Graph DeclName
abbrev DeclGraph.Data := Graph.Data DeclName

namespace DeclGraph

initialize ext :
    PersistentEnvExtension Data Data DeclGraph ←
    registerPersistentEnvExtension {
  mkInitial := return .empty
  addImportedFn := fun as => do
    let mut bs := #[]
    for a in as do
      bs := bs ++ a
    return Graph.deserialize bs
  addEntryFn := Graph.addData
  exportEntriesFn := Graph.serialize
}

def addNode (declName : Name) : CoreM Unit := do
  let usedCs ← collectDeps declName
  let env ← getEnv
  let G := ext.getState env
  let mut out := G
  out := Graph.addNode out declName
  for c in usedCs do
    if G.nodes.contains c then
      out := out.addEdge c declName
  setEnv <| ext.setState env out.tred

end DeclGraph

end NodeGraph
