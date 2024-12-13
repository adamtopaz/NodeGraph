import NodeGraph.Widget.Utils
import Lean
import ProofWidgets

open Lean Elab

namespace NodeGraph

inductive SubnodeKind where
  | tactic | term
deriving Hashable, BEq

structure Subnode where
  markdown? : Option String
  pretty : String
  kind : SubnodeKind
deriving Hashable, BEq

namespace Subnode

open ProofWidgets Jsx in
def mkHtml (nd : Subnode) : Html := Id.run do
  let mdHtml : Html := match nd.markdown? with
    | some md => <MarkdownDisplay contents = {md} />
    | none => <div/>
  let prettyString := s!"```lean\n{nd.pretty}\n```"
  return (
    <div>
      {mdHtml}
      <MarkdownDisplay contents = {prettyString} />
    </div>
  )

initialize ext :
    PersistentEnvExtension (Name × Subnode) (Name × Subnode) (Std.HashMap Name (Std.HashSet Subnode)) ←
  registerPersistentEnvExtension {
    mkInitial := return {}
    addImportedFn := fun as => do
      let mut out := {}
      for bs in as do
        for (nm, node) in bs do
          out := out.insert nm <| out.getD nm {} |>.insert node
      return out
    addEntryFn := fun m (a,b) =>
      m.insert a <| m.getD a {} |>.insert b
    exportEntriesFn := fun m => Id.run do
      let mut out := #[]
      for (a,bs) in m do
        for b in bs do
          out := out.push (a,b)
      return out
  }

syntax:max (name := subnodeTermStx) "subnode" (term)? "in" term:max : term
syntax:max (name := subnodeTacStx) "subnode" (term)? ("in" tactic)? : tactic

open Term in
@[term_elab subnodeTermStx]
def elabTermSubnode : TermElab := fun stx type? => match stx with
  | `(subnode%$tk $[$t:term]? in $s:term) => do
    let md ← t.mapM fun t => do
      let t ← elabTerm t (some <| .const ``String [])
      unsafe Meta.evalExpr String (.const ``String []) t
    let s ← elabTerm s type?
    let tp ← Meta.inferType s
    synthesizeSyntheticMVarsNoPostponing
    let pretty : String := s!"{← Meta.ppExpr s} : {← Meta.ppExpr tp}"
    let node : Subnode := ⟨md, pretty, .term⟩
    Widget.displayHtml node.mkHtml tk
    if let some declName ← getDeclName? then
      modifyEnv fun env => ext.addEntry env ⟨declName, node⟩
    return s
  | _ => throwUnsupportedSyntax

open Tactic in
@[tactic subnodeTacStx]
def elabTacSubnode : Tactic := fun stx => match stx with
  | `(tactic|subnode%$tk $[$t:term]? $[in $tac:tactic]?) => do
    let md : Option String ← t.mapM fun t => do
      let t ← elabTerm t (some <| .const ``String [])
      unsafe Meta.evalExpr String (.const ``String []) t
    let goals ← getGoals
    let pretty : String ← show TacticM String from do
      if goals.isEmpty then
        return "no goals"
      else
        return toString <|
          Std.Format.joinSep (← goals.mapM fun mvar => Meta.ppGoal mvar) "\n\n"
    let node : Subnode := ⟨md, pretty, .tactic⟩
    Widget.displayHtml node.mkHtml tk
    if let some declName ← Term.getDeclName? then
      modifyEnv fun env => ext.addEntry env ⟨declName, node⟩
    if let some tac := tac then evalTactic tac
  | _ => throwUnsupportedSyntax

end Subnode
end NodeGraph
