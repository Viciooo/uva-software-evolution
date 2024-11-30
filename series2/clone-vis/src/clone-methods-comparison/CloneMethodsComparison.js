import DataTable from './components/DataTable';
import HorizontalPanel from './components/HorizontalPanel';
import CodeVisualizer from './components/CodeVisualizer';
import { getCloneList } from './models';
import React, { useEffect, useState } from 'react';
import { useGlobalState } from '../state';

export const CloneMethodComparison = () => {
  const {
    setCloneListData,
    cloneListData,
    selectedRowIndex,
    leftWindowLocIdx,
    rightWindowLocIdx,
  } = useGlobalState(); // Access global state using the custom hook

  const [leftWindowJavaCode, setLeftWindowJavaCode] = useState('');
  const [rightWindowJavaCode, setRightWindowJavaCode] = useState('');
  const [leftWindowHighlightedLines, setLeftWindowHighlightedLines] = useState([]);
  const [rightWindowHighlightedLines, setRightWindowHighlightedLines] = useState([]);
  const [isLoadingLeftCode, setIsLoadingLeftCode] = useState(false);
  const [isLoadingRightCode, setIsLoadingRightCode] = useState(false);

  // Load clone list data on component mount
  useEffect(() => {
    getCloneList()
      .then(clones => {
        setCloneListData(clones); // Populate global state with fetched clones
      })
      .catch(error => {
        console.error('Failed to fetch clone list:', error);
      });
  }, [setCloneListData]);

  // Effect to load left window Java code
  useEffect(() => {
    if (selectedRowIndex !== null && cloneListData[selectedRowIndex] && leftWindowLocIdx !== null) {
      const clone = cloneListData[selectedRowIndex];
      const methods = clone.methods;
      const m = methods[leftWindowLocIdx];

      // Use rawLines directly from the method object
      setIsLoadingLeftCode(false); // Set loading to false immediately
      setLeftWindowJavaCode(m.rawLines || ''); // Set Java code from rawLines

      setLeftWindowHighlightedLines(
        Array.from({ length: m.lastLine - m.startLine + 1 }, (_, i) => m.startLine + i)
      );
      console.log('Left window Java code:', m.rawLines);
    } else {
      setLeftWindowJavaCode('');
      setLeftWindowHighlightedLines([]);
      setIsLoadingLeftCode(false); // Reset loading state
    }
  }, [selectedRowIndex, cloneListData, leftWindowLocIdx]);

  // Effect to load right window Java code
  useEffect(() => {
    if (selectedRowIndex !== null && cloneListData[selectedRowIndex] && rightWindowLocIdx !== null) {
      const clone = cloneListData[selectedRowIndex];
      const methods = clone.methods;
      const m = methods[rightWindowLocIdx];

      // Use rawLines directly from the method object
      setIsLoadingRightCode(false); // Set loading to false immediately
      setRightWindowJavaCode(m.rawLines || ''); // Set Java code from rawLines

      setRightWindowHighlightedLines(
        Array.from({ length: m.lastLine - m.startLine + 1 }, (_, i) => m.startLine + i)
      );
      console.log('Right window Java code:', m.rawLines);
    } else {
      setRightWindowJavaCode('');
      setRightWindowHighlightedLines([]);
      setIsLoadingRightCode(false); // Reset loading state
    }
  }, [selectedRowIndex, cloneListData, rightWindowLocIdx]);

  return (
    <div
      style={{
        display: 'grid',
        gridTemplateColumns: '2fr 2fr 4fr',
        gridTemplateRows: 'auto 1fr',
        height: '85vh',
        gap: '10px',
        padding: '10px',
        boxSizing: 'border-box',
      }}
    >
      {/* DataTable on the top-left */}
      <div style={{ gridColumn: '1 / 2', gridRow: '1 / 3', overflow: 'auto' }}>
        <DataTable />
      </div>

      {/* HorizontalPanel next to DataTable */}
      <div style={{ gridColumn: '2 / 5', gridRow: '1 / 2', overflowX: 'auto' }}>
        {selectedRowIndex !== null && cloneListData[selectedRowIndex]?.methods?.length > 0 ? (
          <HorizontalPanel items={cloneListData[selectedRowIndex].methods} />
        ) : (
          <p style={{ textAlign: 'center' }}>No methods selected or available.</p>
        )}
      </div>

      {/* Two CodeVisualizer windows side-by-side */}
      <div style={{ gridColumn: '2 / 4', gridRow: '2 / 3', display: 'flex', gap: '10px' }}>
        {isLoadingLeftCode ? (
          <p>Loading left code...</p>
        ) : (
          <CodeVisualizer
            code={leftWindowJavaCode}
            highlightedLines={leftWindowHighlightedLines}
            style={{ flex: 1 }}
          />
        )}
        {isLoadingRightCode ? (
          <p>Loading right code...</p>
        ) : (
          <CodeVisualizer
            code={rightWindowJavaCode}
            highlightedLines={rightWindowHighlightedLines}
            style={{ flex: 1 }}
          />
        )}
      </div>
    </div>
  );
};
