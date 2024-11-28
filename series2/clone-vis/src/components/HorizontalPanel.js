import React, { useState } from 'react';
import './HorizontalPanel.css';

const HorizontalPanel = ({ items }) => {
  const [selected, setSelected] = useState([]);

  const toggleSelect = (index) => {
    if (selected.includes(index)) {
      // Remove the box from the selected list
      setSelected(selected.filter((i) => i !== index));
    } else if (selected.length < 2) {
      // Add the box to the selected list if fewer than 2 are selected
      setSelected([...selected, index]);
    }
  };

  return (
    <div className="horizontal-panel">
      {items.map((item, index) => (
        <div
          key={index}
          className={`box ${selected.includes(index) ? 'selected' : ''}`}
          onClick={() => toggleSelect(index)}
        >
          {item}
        </div>
      ))}
    </div>
  );
};

export default HorizontalPanel;
