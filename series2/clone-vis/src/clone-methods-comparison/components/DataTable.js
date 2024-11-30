import * as React from 'react';
import { DataGrid } from '@mui/x-data-grid';
import Paper from '@mui/material/Paper';
import { useGlobalState } from '../../state';

const columns = [
  { field: 'id', headerName: 'ID', width: 70 },
  { field: 'lines', headerName: 'Lines', width: 130, sortable: true, description: 'Number of lines after normalization' },
  { field: 'members', headerName: 'Members', width: 130, sortable: true, description: 'Number of clone class members' },
];

const initialPaginationModel = { page: 0, pageSize: 10 };

export default function DataTable() {
  // Access the global state to get the cloneListData and setSelectedRowIndex
  const { cloneListData, setSelectedRowIndex, cleanSelection } = useGlobalState();

  // Build rows based on cloneListData, ensure cloneListData is defined and an array
  const buildRows = () => {
    if (!Array.isArray(cloneListData)) {
      console.error('Expected cloneListData to be an array, but it is:', cloneListData);
      return []; // Return an empty array if cloneListData is not an array
    }

    let idx = 0;
    const rows = [];
    cloneListData.forEach(clone => {
      if (clone && clone.window && clone.methods) {
        rows.push({
          id: idx,
          lines: clone.window, // You may need to extract the right field here
          members: clone.methods.length,
        });
        idx += 1;
      }
    });
    return rows;
  };

  const handleRowClick = (params) => {
    cleanSelection();
    setSelectedRowIndex(params.id); // Record the clicked row index
    console.log(`Row clicked: ${params.id}`);
  };

  return (
    <Paper sx={{ height: "100%", width: "100%" }}>
      <DataGrid
        rows={buildRows()} // Build the rows from global state data
        columns={columns}
        paginationModel={initialPaginationModel} // Set initial pagination model
        sx={{ border: 1 }}
        onRowClick={handleRowClick} // Add row click handler
      />
    </Paper>
  );
}
