import * as React from 'react';
import { DataGrid } from '@mui/x-data-grid';
import Paper from '@mui/material/Paper';

const columns = [
  { field: 'id', headerName: 'ID', width: 70 },
  { field: 'lines', headerName: 'Lines', width: 130 , sortable: true, description: 'Number of lines after normalization'},
  { field: 'members', headerName: 'Members', width: 130 , sortable: true, description: 'Number of clone class members'},
];

const rows = [
  { id: 1, lines: 10, members: 5 },
  { id: 2, lines: 20, members: 10 },
  { id: 3, lines: 30, members: 15 },
  { id: 4, lines: 40, members: 20 },
  { id: 5, lines: 50, members: 25 },
  { id: 6, lines: 60, members: 30 },
  { id: 7, lines: 70, members: 35 },
  { id: 8, lines: 80, members: 40 },
  { id: 9, lines: 90, members: 45 },
  { id: 10, lines: 100, members: 50 },
  { id: 11, lines: 110, members: 55 },
  { id: 12, lines: 120, members: 60 },
  { id: 13, lines: 130, members: 65 },
  { id: 14, lines: 140, members: 70 },
  { id: 15, lines: 150, members: 75 },
  { id: 16, lines: 160, members: 80 },
  { id: 17, lines: 170, members: 85 },
  { id: 18, lines: 180, members: 90 },
  { id: 19, lines: 190, members: 95 },
  { id: 20, lines: 200, members: 100 },
  { id: 21, lines: 210, members: 105 },
  { id: 22, lines: 220, members: 110 },
  { id: 23, lines: 230, members: 115 },
  { id: 24, lines: 240, members: 120 },
  { id: 25, lines: 250, members: 125 },
];

const paginationModel = { page: 0, pageSize: 10 };

export default function DataTable() {
  return (
    <Paper sx={{ height: "100%", width: 350 }}>
      <DataGrid
        rows={rows}
        columns={columns}
        initialState={{ pagination: { paginationModel } }}
        sx={{ border: 1 }}
      />
    </Paper>
  );
}
