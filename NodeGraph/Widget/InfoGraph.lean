import ProofWidgets.Component.Basic
import ProofWidgets.Component.HtmlDisplay
import Lean

open ProofWidgets Jsx Lean

namespace NodeGraph
namespace Widget
namespace InfoGraph

structure Node where
  id : String
  html : Html
deriving Inhabited, Server.RpcEncodable

structure Props where
  nodes : Array Node
  dot : String
  defaultHtml : Html
deriving Inhabited, Server.RpcEncodable

end InfoGraph

@[widget_module]
def InfoGraph : Component InfoGraph.Props where
  javascript := include_str ".." / ".." / "widget" / "build" / "infoGraph.js"
