import React, { createContext, useContext, useState } from 'react';

// Create a Context
const GlobalStateContext = createContext();

// Create a Provider Component
export const GlobalStateProvider = ({ children }) => {
  const [state, setState] = useState({});

  return (
    <GlobalStateContext.Provider value={{ state, setState }}>
      {children}
    </GlobalStateContext.Provider>
  );
};

// Custom Hook to use the Context
export const useGlobalState = () => useContext(GlobalStateContext);
