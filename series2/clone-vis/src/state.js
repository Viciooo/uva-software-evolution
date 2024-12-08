import React, { createContext, useContext, useState } from 'react';

// Create a Context
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
      cleanSelection, // Add the cleanSelection function to the context
      selectedFile,  // Add selectedFile to the context
      setSelectedFile, // Add setter for selectedFile to the context
    }}>
      {children}
    </GlobalStateContext.Provider>
  );
};

// Create a Custom Hook to Access the Global State
export const useGlobalState = () => {
  const context = useContext(GlobalStateContext);
  if (!context) {
    throw new Error('useGlobalState must be used within a GlobalStateProvider');
  }
  return context;
};
