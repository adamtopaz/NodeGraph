import AutoBlueprint.DeclGraph.Init
import AutoBlueprint.Utils.CollectDeps

open Lean

namespace AutoBlueprint

abbrev GroupName := Name

inductive GroupGraph.Data where
  | data (group : GroupName) (data : DeclGraph.Data)
  | group (decl : DeclName) (group : GroupName)
  | dep (src tgt : GroupName)

structure GroupGraph where
  graphs : Std.HashMap GroupName DeclGraph
  groups : Std.HashMap DeclName (Std.HashSet GroupName)
  deps : Std.HashSet (GroupName × GroupName)
deriving Inhabited

namespace GroupGraph

def addData (G : GroupGraph) (d : Data) : GroupGraph := Id.run do
  let mut graphs := G.graphs
  let mut groups := G.groups
  let mut deps := G.deps
  match d with
  | .data g d =>
    graphs := graphs.insert g <| graphs.getD g .empty |>.addData d
  | .group d g =>
    groups := groups.insert d <| groups.getD d .empty |>.insert g
  | .dep a b =>
    deps := deps.insert (a,b)
  return ⟨graphs, groups, deps⟩

def serialize (G : GroupGraph) : Array Data := Id.run do
  let mut out := #[]
  for (g,graph) in G.graphs do
    for item in graph.serialize do out := out.push <| .data g item
  for (d,gs) in G.groups do for g in gs do
    out := out.push <| .group d g
  return out

def deserialize (data : Array Data) : GroupGraph := Id.run do
  let mut out := ⟨{},{},{}⟩
  for item in data do out := out.addData item
  return out

initialize ext :
    PersistentEnvExtension Data Data GroupGraph ←
    registerPersistentEnvExtension {
  mkInitial := return ⟨{}, {}, {}⟩
  addImportedFn := fun as => do
    let mut bs := #[]
    for a in as do
      bs := bs ++ a
    return deserialize bs
  addEntryFn := addData
  exportEntriesFn := serialize
}

def addNodeToGroups
    (declName : DeclName) (groups : Std.HashSet GroupName) : CoreM Unit := do
  let usedCs ← collectDeps declName
  let env ← getEnv
  let G := ext.getState env
  let mut ⟨outGraphs, outGroups, outDeps⟩ := G
  let mut graphsToReduce : Std.HashSet GroupName := {}
  for group in groups do
    outGroups :=
      outGroups.insert declName <| outGroups.getD declName .empty |>.insert group
    outGraphs :=
      outGraphs.insert group <| Graph.addNode (outGraphs.getD group .empty) declName
    for c in usedCs do
      unless outGroups.contains c do continue
      let cGroups := outGroups.getD c .empty
      if cGroups.contains group then
        graphsToReduce := graphsToReduce.insert group
        outGraphs := outGraphs.insert group <|
          Graph.addEdge (outGraphs.getD group .empty) c declName
      for cgroup in cGroups do
        if cgroup != group then outDeps := outDeps.insert (cgroup, group)
  for group in graphsToReduce do
    outGraphs := outGraphs.insert group (outGraphs.getD group .empty).tred
  setEnv <| ext.setState env ⟨outGraphs, outGroups, outDeps⟩

end GroupGraph

end AutoBlueprint
