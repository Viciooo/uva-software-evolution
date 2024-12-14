import React, { useState, useRef } from 'react';
import { Graph } from 'react-d3-graph';
import './TreeView.css';
import { useGlobalState } from '../state';
import { toNodesAndLinks } from '../transformations';

const config = {
  nodeHighlightBehavior: true,
  node: {
    color: 'darkblue',
    highlightStrokeColor: 'red',
    fontSize: 0,
    labelProperty: 'id',
  },
  d3: {
    gravity: -7000,
    linkStrength: 0.001,
  },
  link: { strokeWidth: 10 },
  directed: true,
  height: window.innerHeight,
  width: window.innerWidth,
};

export const TreeView = () => {
  const [tooltip, setTooltip] = useState({ visible: false, content: '', x: 0, y: 0 });
  const [depth, setDepth] = useState(1);
  const [selectTooltip, setSelectTooltip] = useState(false);
  const [showHelpPopup, setShowHelpPopup] = useState(false); // State for help popup visibility
  const graphRef = useRef(null);
  const graphInstanceRef = useRef(null);

  const { cloneListData } = useGlobalState();
  
  const data = toNodesAndLinks(cloneListData, depth);

  const handleNodeHover = (nodeId, node) => {
    setTooltip({
      visible: true,
      content: node.tooltip || nodeId,
      x: window.innerWidth / 2,
      y: window.innerHeight / 2,
    });
  };

  const handleNodeOut = () => {
    setTooltip({ visible: false, content: '', x: 0, y: 0 });
  };

  const handleDepthChange = (event) => {
    setDepth(Number(event.target.value));
  };

  const customConfig = {
    ...config,
    node: {
      ...config.node,
      size: (node) => node.size,
    },
  };

  return (
    <div className="container">
      <div className="header">
        <div className="help-icon" onClick={() => setShowHelpPopup(true)}>
          ❓
        </div>

        {selectTooltip && (
          <div className="select-tooltip">
            Depth is a level of granularity you choose for analysing.
            <br></br>
            It literally means - how many packages down from the root of the project do you want to see.
            <br></br>
            Ex: depth=0 shows only root, depth=1 shows root and files/folders in its directory, and so on...
          </div>
        )}

        <select
          value={depth}
          onChange={handleDepthChange}
          className="select-dropdown"
          onMouseEnter={() => setSelectTooltip(true)}
          onMouseLeave={() => setSelectTooltip(false)}
        >
          {Array.from({ length: 10 }, (_, i) => i).map((d) => (
            <option key={d} value={d}>
              Depth {d}
            </option>
          ))}
        </select>
      </div>

      <div ref={graphRef} className="graph-container">
        <div
          className={`tooltip ${tooltip.visible ? 'visible' : ''}`}
          style={{
            left: `${tooltip.x}px`,
            top: `${tooltip.y}px`,
          }}
        >
          {tooltip.content}
        </div>

        <Graph
          id="graph"
          data={data}
          config={customConfig}
          onMouseOverNode={(nodeId, node) => handleNodeHover(nodeId, node)}
          onMouseOutNode={handleNodeOut}
          ref={graphInstanceRef}
        />
      </div>

      {showHelpPopup && (
        <div className="help-popup">
          <div className="popup-content">
            <h3>About this tool</h3>
            <p>
              This is the tool that shows the distribution of cloned lines across the files and packages.
              The sizes of nodes correspond to the amount of cloned lines they have.
            </p>
            <p>
              Place your mouse over a node to see the path in the analyzed project and the number of cloned lines.
            </p>
            <p>You can zoom in/out(using scroll) and drag the nodes.</p>
            <p>
              Arrow going from one node to the other signals that it is a parent package.
            </p>
            <button onClick={() => setShowHelpPopup(false)}>Close</button>
          </div>
        </div>
      )}
    </div>
  );
};
