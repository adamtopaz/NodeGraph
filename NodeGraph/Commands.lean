import NodeGraph.NodeAttr
import NodeGraph.GroupGraph

open Lean Elab
namespace NodeGraph

syntax (name := graphCmdStx) "#decl_graph" ("in" ident)? ("from" <|> "to" ident)? : command

open Command in
@[command_elab graphCmdStx]
def elabGraphCmd : CommandElab := fun stx => match stx with
  | `(command|#decl_graph) => do
    let env ← getEnv
    let graph := DeclGraph.ext.getState env
    liftCoreM <| DeclGraph.displayHtml graph.tred stx
  | `(command|#decl_graph to $id:ident) => do
    let env ← getEnv
    let graph := DeclGraph.ext.getState env
    let .ok graph := graph.componentTo id.getId | throwError "{id.getId} not found in node registry"
    liftCoreM <| DeclGraph.displayHtml graph.tred stx
  | `(command|#decl_graph from $id:ident) => do
    let env ← getEnv
    let graph := DeclGraph.ext.getState env
    let .ok graph := graph.componentFrom id.getId | throwError "{id.getId} not found in node registry"
    liftCoreM <| DeclGraph.displayHtml graph.tred stx
  | `(command|#decl_graph in $group:ident) => do
    let env ← getEnv
    let some graph := GroupGraph.ext.getState env |>.graphs.get? group.getId
      | throwError "{group} not found in group registry."
    liftCoreM <| DeclGraph.displayHtml graph.tred stx
  | `(command|#decl_graph in $group:ident to $id:ident) => do
    let env ← getEnv
    let some graph := GroupGraph.ext.getState env |>.graphs.get? group.getId
      | throwError "{group} not found in registry."
    let .ok graph := graph.componentTo id.getId
      | throwError "{id.getId} not found in the graph from group {group.getId}"
    liftCoreM <| DeclGraph.displayHtml graph.tred stx
  | `(command|#decl_graph in $group:ident from $id:ident) => do
    let env ← getEnv
    let some graph := GroupGraph.ext.getState env |>.graphs.get? group.getId
      | throwError "{group} not found in registry."
    let .ok graph := graph.componentFrom id.getId
      | throwError "{id.getId} not found in the graph from group {group.getId}"
    liftCoreM <| DeclGraph.displayHtml graph.tred stx
  | _ => throwUnsupportedSyntax

syntax (name := grouGraphCmdStx) "#group_graph" : command

open Command in
@[command_elab grouGraphCmdStx]
def elabGroupGraphCmd : CommandElab := fun stx => match stx with
  | `(command|#group_graph) => do
    let env ← getEnv
    let groupGraph := GroupGraph.ext.getState env
    liftCoreM <| groupGraph.displayHtml stx
  | _ => throwUnsupportedSyntax

end NodeGraph
