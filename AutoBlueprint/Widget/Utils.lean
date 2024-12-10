import ProofWidgets

namespace AutoBlueprint
namespace Widget

open Lean ProofWidgets in
def displayHtml (html : Html) (stx : Syntax) : CoreM Unit :=
  Widget.savePanelWidgetInfo
    (hash HtmlDisplayPanel.javascript)
    (return json% { html: $(← Server.RpcEncodable.rpcEncode html) })
    stx
