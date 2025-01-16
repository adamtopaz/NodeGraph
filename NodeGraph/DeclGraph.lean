import NodeGraph.NodeAttr.Init
import NodeGraph.Widget.InfoGraph
import NodeGraph.Widget.Utils

open Lean Elab ProofWidgets Jsx

namespace NodeGraph

def DeclName.mkNode (declName : DeclName) (weight? : Option Nat) : CoreM Widget.InfoGraph.Node := do
  let md? := NodeAttr.attr.getParam? (← getEnv) declName |>.join
  return ⟨s!"{hash declName}", ← declName.mkHtml md? weight?⟩ -- TODO: Fix `none`.

namespace DeclGraph

def mkDot (graph : DeclGraph) : CoreM String := do
  let env ← getEnv
  let mut out := "digraph {\n"
  for node in graph.graph.nodes do
    let some const := env.find? node | continue
    let shape : String ← Meta.MetaM.run' do
      if ← Meta.isProp const.type then return "oval"
      else return "box"
    let color : String ← show CoreM _ from do
      let isAxiom : Bool := const matches .axiomInfo ..
      if isAxiom || const.getUsedConstantsAsSet.contains ``sorryAx then return "red"
      else return "black"
    let style : String := if const matches .axiomInfo .. then "dashed" else "solid"
    let id : String := s!"{hash node}"
    let label : String := s!"{node}"
    out := out ++ s!"  \"{label}\" [id=\"{id}\", label=\"{label}\", color=\"{color}\", shape=\"{shape}\", style=\"{style}\"];\n"
  for (src,tgt) in graph.graph.edges do
    out := out ++ s!"  \"{src}\" -> \"{tgt}\";\n"
  return out ++ "}"

def mkNodes (graph : DeclGraph) : CoreM (Array Widget.InfoGraph.Node) := do
  graph.graph.nodes.toArray.mapM fun n => n.mkNode <| graph.weights.get? n

def mkHtml (graph : DeclGraph) : CoreM Html :=
  return <Widget.InfoGraph
    nodes = {← mkNodes graph}
    dot = {← mkDot graph}
    defaultHtml = {<p>Click a node</p>}
  />

def displayHtml (graph : DeclGraph) (stx : Syntax) : CoreM Unit := do
  Widget.displayHtml (← mkHtml graph) stx

end DeclGraph
end NodeGraph
