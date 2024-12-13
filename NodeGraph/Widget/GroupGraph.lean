import ProofWidgets.Component.Basic
import ProofWidgets.Component.HtmlDisplay
import NodeGraph.Widget.InfoGraph
import Lean

open ProofWidgets Jsx Lean

namespace NodeGraph
namespace Widget
namespace GroupGraph

structure Node where
  id : String
  dot : String
deriving Inhabited, Server.RpcEncodable

structure Props where
  graphs : Array Node
  nodes : Array InfoGraph.Node
  dot : String
  defaultHtml : Html
deriving Inhabited, Server.RpcEncodable

end GroupGraph

@[widget_module]
def GroupGraph : Component GroupGraph.Props where
  javascript := include_str ".." / ".." / "widget" / "build" / "groupGraph.js"
