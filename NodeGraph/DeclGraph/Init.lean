import NodeGraph.Graph.Basic
import NodeGraph.Utils.CollectDeps
import NodeGraph.WeightedSorry.Basic

open Lean

namespace NodeGraph

abbrev DeclName := Name
structure DeclGraph where 
  graph : Graph DeclName
  weights : Std.HashMap DeclName Nat
deriving Inhabited

inductive DeclGraph.Data where 
  | ofData (data : Graph.Data DeclName)
  | ofWeight (declName : DeclName) (weight : Nat)
deriving Inhabited

namespace DeclGraph

def empty : DeclGraph := ⟨Graph.empty, Std.HashMap.empty⟩

def addData (G : DeclGraph) (d : Data) : DeclGraph := 
  match d with
  | .ofData d => ⟨G.graph.addData d, G.weights⟩
  | .ofWeight d w => ⟨G.graph, G.weights.insert d w⟩

def serialize (G : DeclGraph) : Array Data := Id.run do
  let mut out := #[]
  for d in G.graph.serialize do
    out := out.push <| .ofData d
  for (n, w) in G.weights do 
    out := out.push <| .ofWeight n w
  return out

def deserialize (ds : Array Data) : DeclGraph := Id.run do
  let mut G := empty
  for d in ds do
    G := G.addData d
  return G

initialize ext :
    PersistentEnvExtension Data Data DeclGraph ←
    registerPersistentEnvExtension {
  mkInitial := return ⟨.empty, .empty⟩
  addImportedFn := fun as => do
    let mut bs : Array Data := #[]
    for a in as do
      bs := bs ++ a
    return deserialize bs
  addEntryFn := DeclGraph.addData
  exportEntriesFn := serialize
}

unsafe
def addNode (G : DeclGraph) (declName : Name) : CoreM DeclGraph := do
  let ⟨w,b⟩ ← collectConstWeight (← getConstInfo declName)
  let mut ⟨G, W⟩ := G
  G := Graph.addNode G declName
  if !b then W := W.insert declName w
  return ⟨G, W⟩

def addEdge (G : DeclGraph) (src tgt : Name) : DeclGraph := 
  ⟨G.graph.addEdge src tgt, G.weights⟩

unsafe
def addNodeAndEdges (G : DeclGraph) (declName : Name) : CoreM DeclGraph := do
  let usedCs ← collectDeps declName
  let ⟨w,b⟩ ← collectConstWeight (← getConstInfo declName)
  let mut ⟨G, W⟩ := G
  G := Graph.addNode G declName
  for c in usedCs do
    if G.nodes.contains c then
      G := G.addEdge c declName
  if !b then W := W.insert declName w
  return ⟨G, W⟩

def tred (G : DeclGraph) : DeclGraph := 
  ⟨G.graph.tred, G.weights⟩

def componentTo (G : DeclGraph) (c : DeclName) : Except String DeclGraph := do
  let c ← G.graph.componentTo c
  return ⟨c, G.weights⟩

def componentFrom (G : DeclGraph) (c : DeclName) : Except String DeclGraph := do
  let c ← G.graph.componentFrom c
  return ⟨c, G.weights⟩

end DeclGraph

end NodeGraph
