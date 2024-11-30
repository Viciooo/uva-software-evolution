import React, { useState } from 'react';
import { useGlobalState } from '../../state'; // Import global state hook
import './HorizontalPanel.css';

const HorizontalPanel = ({ items }) => {
  const { leftWindowLocIdx, rightWindowLocIdx, setLeftWindowLocIdx, setRightWindowLocIdx } = useGlobalState();
  const [tooltip, setTooltip] = useState({ visible: false, content: '', x: 0, y: 0 });

  const toggleSelect = (index) => {
    if (leftWindowLocIdx === null) {
      setLeftWindowLocIdx(index); // Set left index if not already selected
      console.log('leftWindowLocIdx:', index);
    } else if (rightWindowLocIdx === null && index !== leftWindowLocIdx) {
      setRightWindowLocIdx(index); // Set right index if not already selected
      console.log('rightWindowLocIdx:', index);
    } else if (leftWindowLocIdx === index) {
      setLeftWindowLocIdx(null); // Deselect left index
      console.log('leftWindowLocIdx:', null);
    } else if (rightWindowLocIdx === index) {
      setRightWindowLocIdx(null); // Deselect right index
      console.log('leftWindowLocIdx:', null);
    }
  };

  const truncateName = (name) => {
    const visibleLength = 20;
    if (name.length > visibleLength) {
      return `...${name.slice(-visibleLength)}`;
    }
    return name;
  };

  const showTooltip = (e, content) => {
    setTooltip({
      visible: true,
      content,
      x: e.clientX + 10,
      y: e.clientY + 10,
    });
  };

  const hideTooltip = () => {
    setTooltip({ visible: false, content: '', x: 0, y: 0 });
  };

  return (
    <div className="horizontal-panel">
      {items.map((item, index) => (
        <div
          key={index}
          className={`box ${
            index === leftWindowLocIdx || index === rightWindowLocIdx ? 'selected' : ''
          }`}
          onClick={() => toggleSelect(index)}
          onMouseEnter={(e) => showTooltip(e, item.name)} // Show custom tooltip
          onMouseLeave={hideTooltip} // Hide tooltip
        >
          {truncateName(item.name)}
        </div>
      ))}
      {tooltip.visible && (
        <div
          className="custom-tooltip"
          style={{ top: tooltip.y, left: tooltip.x }}
        >
          {tooltip.content}
        </div>
      )}
    </div>
  );
};

export default HorizontalPanel;
