import * as React from 'react';
import { DataGrid } from '@mui/x-data-grid';
import Paper from '@mui/material/Paper';
import { useGlobalState } from '../../state';

const columns = [
  { field: 'id', headerName: 'ID', width: 70 },
  { field: 'lines', headerName: 'Lines', width: 130 , sortable: true, description: 'Number of lines after normalization' },
  { field: 'members', headerName: 'Members', width: 130 , sortable: true, description: 'Number of clone class members' },
];

const paginationModel = { page: 0, pageSize: 10 };

export default function DataTable() {
  // Access the global state to get the cloneListData
  const { cloneListData } = useGlobalState();
  console.log(cloneListData);

  // Build rows based on cloneListData
  const buildRows = () => {
    let idx = 1;
    const rows = [];
    cloneListData.forEach(clone => {
      rows.push({ id: idx, lines: clone.window, members: clone.cloneLocs.length });
      idx += 1;
    });
    return rows;
  };

  return (
    <Paper sx={{ height: "100%", width: 350 }}>
      <DataGrid
        rows={buildRows()}  // Build the rows from global state data
        columns={columns}
        initialState={{ pagination: { paginationModel } }}
        sx={{ border: 1 }}
      />
    </Paper>
  );
}
