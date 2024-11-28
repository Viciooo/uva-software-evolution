import React from 'react';
import { Light as SyntaxHighlighter } from 'react-syntax-highlighter';
import { java } from 'react-syntax-highlighter/dist/esm/languages/hljs';
import { atomOneDark } from 'react-syntax-highlighter/dist/esm/styles/hljs';

// Register Java syntax
SyntaxHighlighter.registerLanguage('java', java);

const CodeVisualizer = ({ code, highlightedLines }) => {
  const getLineProps = (lineNumber) => {
    if (highlightedLines.includes(lineNumber)) {
      return { style: { backgroundColor: 'rgba(255, 255, 0, 0.4)' } };
    }
    return {};
  };

  return (
    <div style={{ width: '100%', height: '100%', overflow: 'auto', borderRadius: '8px', backgroundColor: '#2d2d2d' }}>
      <SyntaxHighlighter
        language="java"
        style={atomOneDark}
        showLineNumbers
        wrapLines
        lineProps={(lineNumber) => getLineProps(lineNumber)}
        customStyle={{
          padding: '1rem',
          fontSize: '1rem',
          height: '100%',
          margin: 0,
          borderRadius: '8px',
        }}
      >
        {code}
      </SyntaxHighlighter>
    </div>
  );
};

export default CodeVisualizer;
