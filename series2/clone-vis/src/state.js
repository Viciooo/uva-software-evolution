import React, { createContext, useContext, useState } from 'react';

// Create a Context
const GlobalStateContext = createContext();

// Create a Provider Component
export const GlobalStateProvider = ({ children }) => {
  const [cloneListData, setCloneListData] = useState([]);

  return (
    <GlobalStateContext.Provider value={{ cloneListData, setCloneListData }}>
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
