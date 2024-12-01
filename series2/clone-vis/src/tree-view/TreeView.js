import React from 'react';
import { Graph } from 'react-d3-graph';

const data = {
  nodes: [{ id: 'Node 1' }, { id: 'Node 2' }, { id: 'Node 3' }],
  links: [
    { source: 'Node 1', target: 'Node 2' },
    { source: 'Node 1', target: 'Node 3' },
  ],
};

const config = {
  nodeHighlightBehavior: true,
  node: { color: 'lightblue', size: 300 },
  link: { highlightColor: 'orange' },
  collapsible: true,
};

export const TreeView = () => {
  return <Graph id="graph" data={data} config={config} />;
};
