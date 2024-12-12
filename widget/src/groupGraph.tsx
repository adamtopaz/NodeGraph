import { useState } from "react";
import HtmlDisplay, { Html } from './htmlDisplay';
import ClickableGraph from './clickableGraph';
import { InfoGraphNode } from './infoGraph';
import { styles } from './styles';
import ResizableContainer from "./container";

interface GroupGraphNode {
    id : string;
    dot : string;
}

interface GroupGraphProps {
    graphs : Array<GroupGraphNode>
    nodes : Array<InfoGraphNode>
    dot : string
    defaultHtml : Html
}

export default function GroupGraph ({graphs, nodes, dot, defaultHtml} : GroupGraphProps) {

  const graphMap = new Map(graphs.map(graph => [graph.id, graph.dot]))
  const nodeMap = new Map(nodes.map(node => [node.id, node.html]))
  const [infoState, setInfoState] = useState<Html>(defaultHtml);
  const [childState, setChildState] = useState<JSX.Element>(<div></div>);

  const childClickHandler = (id: string) : void => {
    const html = nodeMap.get(id);
    if (html) {
      setInfoState(html);
    }
  }

  const childDefaultHandler = () : void => {
      setInfoState(defaultHtml);
  }

  const clickHandler = (id: string) : void => {
    setInfoState(defaultHtml);
    console.log(id);
    const graph = graphMap.get(id);
    if (graph) {
      setChildState(
        <ResizableContainer title={"Declaration Graph"}>
          <div style={{padding : "16px", width : "100%", height : "100%"}} >
            <ClickableGraph 
              dot={graph} 
              clickHandler={childClickHandler} 
              defaultHandler={childDefaultHandler} 
            />
          </div>
        </ResizableContainer>);
    }
  }
  const defaultHandler = () : void => {
    setInfoState(defaultHtml);
    setChildState(<div/>);
  }

  return (
    <div style={styles.container}> 
      <ResizableContainer title={"Group Graph"}>
        <div style={{padding : "16px", width : "100%", height : "100%"}}> 
          <ClickableGraph 
            dot={dot} 
            clickHandler={clickHandler} 
            defaultHandler={defaultHandler} />
        </div>
      </ResizableContainer>
      {childState}
      <ResizableContainer title={"Declaration Information"}>
        <div style={{padding : "16px", width : "100%", height : "100%"}}> 
          <HtmlDisplay html={infoState} />
        </div>
      </ResizableContainer>
    </div>
  )

}