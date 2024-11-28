import React, { useState } from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import { Tab, Tabs, Box } from '@mui/material';
import { CloneMethodComparison } from './clone-methods-comparison/CloneMethodsComparison';
import { Home } from './home/Home';
import { TreeView } from './tree-view/TreeView';
import { GlobalStateProvider } from './state';

const root = ReactDOM.createRoot(document.getElementById('root'));

function App() {
  const [selectedTab, setSelectedTab] = useState(1); // Manage which tab is selected

  const handleTabChange = (event, newValue) => {
    setSelectedTab(newValue); // Update selected tab value
  };

  return (
    <React.StrictMode>
      <GlobalStateProvider>
      <Box sx={{ width: '100%' }}>
        {/* Tabs for navigation */}
        <Tabs
          value={selectedTab}
          onChange={handleTabChange}
          indicatorColor="primary"
          textColor="primary"
          variant="scrollable"
          scrollButtons="auto"
          aria-label="scrollable tabs example"
        >
          <Tab label="Home" />
          <Tab label="Clone class investigator" />
          <Tab label="Tree View" />
        </Tabs>

        {/* Conditional rendering based on selected tab */}
        
        {selectedTab === 0 && (
          <Box sx={{ p: 3 }}>
            <Home />
          </Box>
        )}
        {selectedTab === 1 && (
          <Box sx={{ p: 3 }}>
            <CloneMethodComparison />
          </Box>
        )}
        {selectedTab === 2 && (
          <Box sx={{ p: 3 }}>
            <TreeView />
          </Box>
        )}
      </Box>
      </GlobalStateProvider>
    </React.StrictMode>
  );
}

root.render(<App />);
