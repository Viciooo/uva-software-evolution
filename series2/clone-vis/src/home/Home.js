import React, { useState } from 'react';
import { useGlobalState } from '../state';
import {Clone} from '../models';
function Home() {
  const { setCloneListData, setSelectedFile, selectedFile } = useGlobalState(); // Access global state using the custom hook
  const [error, setError] = useState(null); // Error state
  const [isLoading, setIsLoading] = useState(false);
  const [popupMessage, setPopupMessage] = useState(null); // For success/error message
  const [popupType, setPopupType] = useState(''); // Success (green) or error (red)

  const handleFileChange = (event) => {
    setIsLoading(true);
    setError(null); // Clear any previous error messages
    const file = event.target.files[0];

    if (file) {
      setSelectedFile(file); // Save the selected file to global state

      const reader = new FileReader();

      // Read the file as text
      reader.readAsText(file);

      reader.onload = () => {
        try {
          const parsedData = JSON.parse(reader.result); // Parse the JSON file content
          setCloneListData(Clone.createFromJSON(parsedData)); // Set the global clone list data directly

          setPopupMessage("File loaded successfully!");
          setPopupType("success");
        } catch (err) {
          setError("Invalid JSON format");
          setPopupMessage("Error: Invalid JSON format");
          setPopupType("error");
        } finally {
          setIsLoading(false);
        }
      };

      reader.onerror = () => {
        setError("Error reading the file");
        setPopupMessage("Error: Unable to read the file");
        setPopupType("error");
        setIsLoading(false);
      };
    } else {
      setIsLoading(false);
      setError("No file selected");
      setPopupMessage("Error: No file selected");
      setPopupType("error");
    }
  };

  return (
    <div style={styles.container}>
      <h1>Select json with detected clones</h1>

      {/* Use the selectedFile to display the name in the input */}
      <input
        type="file"
        accept=".json"
        onChange={handleFileChange}
        style={{ marginBottom: '20px', padding: '10px' }}
      />
      <div>
        {/* Display the selected file name */}
        {selectedFile && selectedFile.name ? (
          <p>Selected file: {selectedFile.name}</p>
        ) : (
          <p>No file selected</p>
        )}
      </div>

      {isLoading && <p>Loading...</p>}

      {/* Popup message */}
      {popupMessage && (
        <div style={popupType === "success" ? styles.successPopup : styles.errorPopup}>
          {popupMessage}
        </div>
      )}
    </div>
  );
}

const styles = {
  container: {
    padding: '20px',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: '100vh', // To make sure the content is centered vertically
  },
  successPopup: {
    backgroundColor: 'green',
    color: 'white',
    padding: '20px',
    borderRadius: '10px',
    width: '60%',
    textAlign: 'center',
    fontSize: '18px',
    marginTop: '20px',
    transition: 'all 0.5s ease-in-out',
  },
  errorPopup: {
    backgroundColor: 'red',
    color: 'white',
    padding: '20px',
    borderRadius: '10px',
    width: '60%',
    textAlign: 'center',
    fontSize: '18px',
    marginTop: '20px',
    transition: 'all 0.5s ease-in-out',
  },
};

export default Home;
