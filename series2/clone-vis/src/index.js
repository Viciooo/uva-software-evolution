import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import DataTable from './components/DataTable';
import HorizontalPanel from './components/HorizontalPanel';
import CodeVisualizer from './components/CodeVisualizer';
import { GlobalStateProvider } from './state';

const root = ReactDOM.createRoot(document.getElementById('root'));

const names = [
  'Alice', 'Bob', 'Charlie', 'Diana', 'Eve', 'Frank',
  'Alice', 'Bob', 'Charlie', 'Diana', 'Eve', 'Frank',
  'Alice', 'Bob', 'Charlie', 'Diana', 'Eve', 'Frank',
  'Alice', 'Bob', 'Charlie', 'Diana', 'Eve', 'Frank'
];

const javaCode = `
    public class Main {
        public static void main(String[] args) {
            System.out.println("Hello, World!");
            for (int i = 0; i < 5; i++) {
                System.out.println("Count: " + i);
            }
        }
    }
  `;

const highlightedLines = [3, 5]; // Highlight line numbers 3 and 5

root.render(
  <React.StrictMode>
    <GlobalStateProvider>
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '2fr 2fr 4fr',
          gridTemplateRows: 'auto 1fr',
          height: '100vh',
          gap: '10px',
          padding: '10px',
          boxSizing: 'border-box'
        }}
      >
        {/* DataTable on the top-left */}
        <div style={{ gridColumn: '1 / 2', gridRow: '1 / 3', overflow: 'auto' }}>
          <DataTable />
        </div>

        {/* HorizontalPanel next to DataTable */}
        <div style={{ gridColumn: '2 / 5', gridRow: '1 / 2', overflowX: 'auto' }}>
          <HorizontalPanel items={names} />
        </div>

        {/* Two CodeVisualizer windows side-by-side */}
        <div style={{ gridColumn: '2 / 4', gridRow: '2 / 3', display: 'flex', gap: '10px' }}>
          <CodeVisualizer
            code={javaCode}
            highlightedLines={highlightedLines}
            style={{ flex: 1 }}
          />
          <CodeVisualizer
            code={javaCode}
            highlightedLines={highlightedLines}
            style={{ flex: 1 }}
          />
        </div>
      </div>
    </GlobalStateProvider>
  </React.StrictMode>
);
