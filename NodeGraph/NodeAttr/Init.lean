import NodeGraph.GroupGraph.Init
import NodeGraph.Subnode.Init
import NodeGraph.Widget.Utils
import ProofWidgets

open Lean Elab
open ProofWidgets Jsx

namespace NodeGraph

def DeclName.mkHtml (declName : DeclName) (markdown? : Option String) (weight? : Option Nat) :
    CoreM Html := Meta.MetaM.run' do
  let env ← getEnv
  let some const := env.find? declName | return <div/>
  let us ← Meta.mkFreshLevelMVarsFor const
  let constFmt ← Widget.ppExprTagged (.const declName us)
  let typeFmt ← Widget.ppExprTagged const.type
  let subnodes := Subnode.ext.getState env |>.get? declName
  let subnodesHtml : Html :=
    match subnodes with
    | some subnodes =>
      let termSubnodes := subnodes.filter fun nd => nd.kind == .term
      let tacSubnodes := subnodes.filter fun nd => nd.kind == .tactic
      let termHeader : Html :=
        if termSubnodes.isEmpty then <div/> else <p><b><u>Term Subnodes</u></b></p>
      let tacHeader : Html :=
        if tacSubnodes.isEmpty then <div/> else <p><b><u>Tactic Subnodes</u></b></p>
      let termhtmls : Array Html := termSubnodes.toArray.map fun sn =>
        <li>{sn.mkHtml}</li>
      let tachtmls : Array Html := tacSubnodes.toArray.map fun sn =>
        <li>{sn.mkHtml}</li>
      (<div>
        {termHeader}
        {.element "ul" #[] termhtmls}
        {tacHeader}
        {.element "ul" #[] tachtmls}
      </div>)
    | none => <div/>
  let mdHtml : Html :=
    match markdown? with
    | some md => <MarkdownDisplay contents = {md} />
    | none => <div/>
  let docHtml : Html :=
    match ← findDocString? env declName with
    | some doc => <MarkdownDisplay contents = {doc} />
    | none => <div/>
  let weightHtml : Html :=
    match weight? with
    | some w =>
      <div>
      <p><b><u>Weight</u></b></p>
      <p>{.text s!"{w}"}</p>
      </div>
    | none => <div/>
  return (
    <div>
      {mdHtml}
      {docHtml}
      {weightHtml}
      <p><b><u>Constant Name</u></b></p>
      <InteractiveCode fmt={constFmt} />
      <p><b><u>Constant Type</u></b></p>
      <InteractiveCode fmt={typeFmt} />
      {subnodesHtml}
    </div>
  )

namespace NodeAttr

syntax (name := nodeAttrStx) "node" (term)? ("in" (ident)*)? : attr

unsafe
initialize attr : ParametricAttribute (Option String) ← registerParametricAttribute {
  name := `nodeAttrStx
  descr := "A parametric node attribute that stores some necessary information about declarations"
  getParam := fun nm stx => match stx with
  | `(attr| node%$tk $[$t:term]? $[in $[$ids:ident]*]?) => do
    let markdown? : Option String ← t.mapM fun t => Meta.MetaM.run' <| Term.TermElabM.run' <| unsafe do
      Meta.evalExpr String (.const ``String []) (← Term.elabTerm t (some <| .const ``String []))
    let ⟨w,b⟩ ← collectConstWeight (← getConstInfo nm)
    let w : Option Nat := if !b then some w else none
    let html ← DeclName.mkHtml nm markdown? w
    Widget.displayHtml html tk
    let env ← getEnv
    let mut G := DeclGraph.ext.getState env
    G ← G.addNodeAndEdges nm
    setEnv <| DeclGraph.ext.setState env G
    if let some ids := ids then
      GroupGraph.addNodeToGroups nm <| .ofArray (ids.map fun a => a.getId)
    return markdown?
  | _ => throwUnsupportedSyntax
}

end NodeAttr

end NodeGraph
