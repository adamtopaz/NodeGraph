import { useState } from "react";
import { HtmlDisplay, Html } from '@leanprover-community/proofwidgets4';
import ClickableGraph from './clickableGraph';
import { styles } from './styles';
import ResizableContainer from "./container";

export interface InfoGraphNode {
  id : string;
  html : Html;
}

export interface InfoGraphProps {
  nodes : Array<InfoGraphNode>
  dot : string
  defaultHtml : Html
}

export default function DeclGraph ({nodes, dot, defaultHtml} : InfoGraphProps) {

  const nodeMap = new Map(nodes.map(node => [node.id, node.html]))
  const [infoState, setInfoState] = useState<Html>(defaultHtml);

  const clickHandler = (id: string) : void => {
    const html = nodeMap.get(id);
    if (html) {
      setInfoState(html);
    }
  }

  const defaultHandler = () : void => {
    setInfoState(defaultHtml);
  }

  return (
    <div style={styles.container}> 
      <ResizableContainer title={"Declaration Graph"} >
        <div style={{width : "100%", height : "100%"}} > 
          <ClickableGraph 
            dot={dot} 
            clickHandler={clickHandler} 
            defaultHandler={defaultHandler} 
          />
        </div>
      </ResizableContainer>
      <ResizableContainer title={"Declaration Information"}>
        <div style={{padding : "16px", width : "100%", height : "100%"}} >
          <HtmlDisplay html={infoState} />
        </div>
      </ResizableContainer>
    </div>
  )

}