import { useState, useRef, useEffect } from "react";
import HtmlDisplay, { Html } from './htmlDisplay';
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
  const [graphHeight, setGraphHeight] = useState<number>(0);
  const [graphWidth, setGraphWidth] = useState<number>(0);

  const clickHandler = (id: string) : void => {
    const html = nodeMap.get(id);
    if (html) {
      setInfoState(html);
    }
  }

  const defaultHandler = () : void => {
    setInfoState(defaultHtml);
  }

  const graphRef = useRef<HTMLDivElement>(null);
  const resizeObserver = new ResizeObserver((entries) => {
    if (!graphRef.current) { return }
    const entry = entries[0];
    setGraphHeight(entry.contentRect.height);
    setGraphWidth(entry.contentRect.width);
    console.log(entry.contentRect.height, entry.contentRect.width);
  });

  useEffect(() => {
    if (!graphRef.current) { return }
    resizeObserver.observe(graphRef.current);
  }, []);

  return (
    <div style={styles.container}> 
      <ResizableContainer title={"Declaration Graph"} >
        <div style={{padding : "16px", width : "100%", height : "100%"}} ref={graphRef} > 
          <ClickableGraph 
            dot={dot} 
            height={graphHeight}
            width={graphWidth}
            clickHandler={clickHandler} 
            defaultHandler={defaultHandler} 
          />
        </div>
      </ResizableContainer>
      <ResizableContainer title={"Declaration Information"}>
        <div style={{padding : "16px"}}>
          <HtmlDisplay html={infoState} />
        </div>
      </ResizableContainer>
    </div>
  )

}