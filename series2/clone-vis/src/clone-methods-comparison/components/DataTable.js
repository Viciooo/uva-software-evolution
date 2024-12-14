import React, { useCallback } from 'react';
import { AgGridReact } from 'ag-grid-react';
import { useGlobalState } from '../../state';
import 'ag-grid-community/styles/ag-grid.css';
import 'ag-grid-community/styles/ag-theme-alpine.css';

const columns = [
  { headerName: 'ID', field: 'id', flex: 1, minWidth: 80, maxWidth: 120 },
  { 
    headerName: 'Lines', 
    field: 'lines', 
    flex: 2,  
    minWidth: 100, 
    sortable: true, 
    description: 'Number of lines after normalization' 
  },
  { 
    headerName: 'Members', 
    field: 'members', 
    flex: 2,  
    minWidth: 100, 
    sortable: true, 
    description: 'Number of clone class members' 
  },
];

export default function DataTable() {
  const { cloneListData, setSelectedRowIndex, cleanSelection } = useGlobalState();

  const buildRows = useCallback(() => {
    if (!Array.isArray(cloneListData)) {
      console.error('Expected cloneListData to be an array, but it is:', cloneListData);
      return [];
    }

    let idx = 0;
    const rows = [];
    cloneListData.forEach(clone => {
      if (clone && clone.size && clone.methods) {
        rows.push({
          id: idx,
          lines: clone.size,
          members: clone.methods.length,
        });
        idx += 1;
      }
    });
    return rows;
  }, [cloneListData]);

  const handleRowClick = useCallback((event) => {
    cleanSelection();
    setSelectedRowIndex(event.data.id); // Record the clicked row index
    console.log(`Row clicked: ${event.data.id}`);
  }, [setSelectedRowIndex, cleanSelection]);

  return (
    <div className="ag-theme-alpine custom-grid" style={{ height: '100%', width: '100%' }}>
      <AgGridReact
        rowData={buildRows()}
        columnDefs={columns} 
        pagination={true}
        paginationPageSize={10}
        domLayout='autoHeight' 
        onRowClicked={handleRowClick}
      />
    </div>
  );
}
