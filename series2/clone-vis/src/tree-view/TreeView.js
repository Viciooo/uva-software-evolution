import React, { useState, useRef } from 'react';
import { Graph } from 'react-d3-graph';
import './TreeView.css';
import { useGlobalState } from '../state';
import { toNodesAndLinks } from '../transformations';

const config = {
  nodeHighlightBehavior: true,
  node: {
    color: 'lightblue',
    highlightStrokeColor: 'red',
    fontSize: 0,  // This makes the font invisible
    labelProperty: 'id',  // Keep the ID as the label but make it invisible
  },
  link: {
    highlightColor: 'orange',
    linkLength: 150, // Controls the default length of the link
  },
  directed: true,
  height: window.innerHeight,
  width: window.innerWidth,
};

export const TreeView = () => {
  const [tooltip, setTooltip] = useState({ visible: false, content: '', x: 0, y: 0 });
  const [depth, setDepth] = useState(3);  // Depth state to track the current depth value
  const graphRef = useRef(null);
  const graphInstanceRef = useRef(null); // Ref to store the graph instance

  const { cloneListData } = useGlobalState(); // Access global state using the custom hook

  const data = toNodesAndLinks(cloneListData, depth);  // Update the graph data based on the current depth

  // Handle node hover for tooltip
  const handleNodeHover = (nodeId, node) => {
    // Set the tooltip to be in the center of the screen
    setTooltip({
      visible: true,
      content: node.tooltip || nodeId,
      x: window.innerWidth / 2,  // Position at the horizontal center of the screen
      y: window.innerHeight / 2, // Position at the vertical center of the screen
    });
  };

  const handleNodeOut = () => {
    setTooltip({ visible: false, content: '', x: 0, y: 0 });
  };

  // Custom node configuration based on size
  const customConfig = {
    ...config,
    node: {
      ...config.node,
      size: (node) => node.size || 600, // Use node size from data or default to 600
    },
  };

  // Function to handle depth change from the dropdown
  const handleDepthChange = (event) => {
    setDepth(Number(event.target.value));  // Update the depth state and refresh graph
  };

  return (
    <div
      style={{
        width: '90vw', // Full viewport width
        height: '80vh', // Full viewport height
        display: 'flex',
        alignItems: 'center',      // Center the content vertically
        padding: '10px',           // Padding inside the div
        boxSizing: 'border-box',   // Ensure padding doesn't affect width/height
        boxShadow: '0px 0px 10px rgba(0, 0, 0, 0.5)', // Black shadow for 3D effect
        flexDirection: 'column',   // Align children (dropdown and graph) vertically
      }}
    >
      {/* Depth Selection Dropdown */}
      <div
        style={{
          marginBottom: '10px',
          display: 'flex',
          justifyContent: 'center',
          width: '100%',
        }}
      >
        <select
          value={depth}
          onChange={handleDepthChange}
          style={{
            padding: '5px 10px',
            fontSize: '14px',
            borderRadius: '4px',
            border: '1px solid #ccc',
            boxShadow: '0 0 5px rgba(0, 0, 0, 0.2)',
            cursor: 'pointer',
          }}
        >
          {Array.from({ length: 10 }, (_, i) => i + 1).map((d) => (
            <option key={d} value={d}>
              Depth {d}
            </option>
          ))}
        </select>
      </div>

      {/* Graph Container */}
      <div
        ref={graphRef}
        style={{
          position: 'relative',
          width: '100%',
          height: '100%',
        }}
      >
        {/* Tooltip */}
        <div
          className="tooltip"
          style={{
            position: 'absolute',
            visibility: tooltip.visible ? 'visible' : 'hidden',
            left: `${tooltip.x}px`,
            top: `${tooltip.y}px`,
            background: 'rgba(0, 0, 0, 0.75)',
            color: '#fff',
            padding: '8px',
            borderRadius: '4px',
            fontSize: '12px',
            pointerEvents: 'none',
            transform: 'translate(-50%, -100%)', // Center the tooltip based on the x and y positions
            whiteSpace: 'pre-line', // Important to handle \n as line breaks
          }}
        >
          {tooltip.content}
        </div>

        {/* Graph */}
        <Graph
          id="graph"
          data={data}
          config={customConfig} // Use custom config with dynamic node sizes
          onMouseOverNode={(nodeId, node) => handleNodeHover(nodeId, node)}
          onMouseOutNode={handleNodeOut}
          ref={graphInstanceRef} // Store the graph instance to trigger onClickNode
        />
      </div>
    </div>
  );
};
