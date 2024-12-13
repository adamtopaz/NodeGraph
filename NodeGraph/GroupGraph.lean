import NodeGraph.DeclGraph
import NodeGraph.Widget.GroupGraph
import NodeGraph.Widget.Utils

open Lean Elab ProofWidgets Jsx

namespace NodeGraph

def GroupName.mkNode (groupName : GroupName) : CoreM Widget.GroupGraph.Node := do
  let some graph := GroupGraph.ext.getState (← getEnv) |>.graphs |>.get? groupName
    | throwError "{groupName} not found in group registry"
  let graph : DeclGraph := graph.tred
  return ⟨s!"{hash groupName}", ← graph.mkDot⟩

namespace GroupGraph

def mkDot (graph : GroupGraph) : CoreM String := do
  let mut out : String := "digraph {\n"
  for (group, _) in graph.graphs do
    out := out ++ s!"  \"{group}\" [id=\"{hash group}\", shape=\"diamond\"];"
  for (src,tgt) in graph.deps do
    out := out ++ s!"  \"{src}\" -> \"{tgt}\";"
  return out ++ "}"

def mkGraphs (graph : GroupGraph) : CoreM (Array Widget.GroupGraph.Node) :=
  graph.graphs.toArray.mapM fun (g, _) => g.mkNode

def mkNodes (graph : GroupGraph) : CoreM (Array Widget.InfoGraph.Node) := do
  let mut out := #[]
  for (_, g) in graph.graphs do
    let nodes ← g.mkNodes
    out := out ++ nodes
  return out

def mkHtml (graph : GroupGraph) : CoreM Html :=
  return <Widget.GroupGraph
    graphs = {← graph.mkGraphs}
    nodes = {← graph.mkNodes}
    dot = {← graph.mkDot}
    defaultHtml = {<p>Click a node</p>}
  />

def displayHtml (graph : GroupGraph) (stx : Syntax) : CoreM Unit := do
  Widget.displayHtml (← mkHtml graph) stx

end GroupGraph
end NodeGraph
