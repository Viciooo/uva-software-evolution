import React, { createContext, useContext, useState } from 'react';

const GlobalStateContext = createContext();

export const GlobalStateProvider = ({ children }) => {
  const [cloneListData, setCloneListData] = useState([]);
  const [selectedRowIndex, setSelectedRowIndex] = useState(null);
  const [leftWindowLocIdx, setLeftWindowLocIdx] = useState(null); // Track left window selection
  const [rightWindowLocIdx, setRightWindowLocIdx] = useState(null); // Track right window selection
  const [selectedFile, setSelectedFile] = useState(null); // Store the selected file

  // Function to clean the selections
  const cleanSelection = () => {
    setLeftWindowLocIdx(null);
    setRightWindowLocIdx(null);
  };

  return (
    <GlobalStateContext.Provider value={{
      cloneListData,
      setCloneListData,
      selectedRowIndex,
      setSelectedRowIndex,
      leftWindowLocIdx,
      setLeftWindowLocIdx,
      rightWindowLocIdx,
      setRightWindowLocIdx,
      cleanSelection,
      selectedFile,
      setSelectedFile,
    }}>
      {children}
    </GlobalStateContext.Provider>
  );
};

export const useGlobalState = () => {
  const context = useContext(GlobalStateContext);
  if (!context) {
    throw new Error('useGlobalState must be used within a GlobalStateProvider');
  }
  return context;
};
