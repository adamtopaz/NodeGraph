import { useEffect, useState, useRef } from "react";
import * as d3 from 'd3';
import { graphviz } from 'd3-graphviz';
import { styles } from './styles';

export interface ClickableGraphProps {
  dot : string
  clickHandler : (id : string) => void
  defaultHandler : () => void
}

export default function ClickableGraph({dot, clickHandler, defaultHandler} : ClickableGraphProps) {
  const graphRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!graphRef.current) { return }
    //resizeObserver.disconnect();
    graphviz(graphRef.current)
      //.width(width)
      //.height(height)
      .fit(true)
      .scale(1)
      .renderDot(dot)
      .onerror((e) => {
        d3.select(graphRef.current).text(e);
      })
      .on('end', () => {

        const svg = d3.select(graphRef.current).select('svg');

        svg
          .attr('width', "100%")
          .attr('height', "100%")
          .attr('viewBox', `0 0 ${window.screen.width} ${window.screen.height}`)
          .attr('preserveAspectRatio', 'xMidYMid meet');

        d3.select(graphRef.current).select('polygon').style("fill", "transparent");

        d3.select(graphRef.current).selectAll('text').each(function () {
          const tNode = d3.select(this);
          tNode.style("fill", "var(--vscode-editor-foreground)");
        });

        d3.select(graphRef.current).selectAll<SVGAElement, unknown>(".edge").each(function () {
          const eNode = d3.select(this)
          eNode.select("path").style("stroke","var(--vscode-editor-foreground)");
          eNode.select("polygon")
            .style("stroke","var(--vscode-editor-foreground)")
            .style("fill","var(--vscode-editor-foreground)");
        });

        d3.select(graphRef.current).selectAll<SVGAElement, unknown>(".node").each(function () {
          const gNode = d3.select(this);

          gNode.attr("pointer-events", "fill");
          gNode.style('cursor', 'pointer');
          gNode.on("click", function(event) {
            event.stopPropagation();
            const nodeId = d3.select(this).attr("id");
            if (nodeId) {
              clickHandler(nodeId);
            }
          });
        });

        d3.select(graphRef.current).on("click", function () { defaultHandler() });
      });
  }, [dot, clickHandler, defaultHandler]);

  return (
    <div 
      ref={graphRef}
      style={{ width: '100%', height: '100%' }}
    />
  );
}
