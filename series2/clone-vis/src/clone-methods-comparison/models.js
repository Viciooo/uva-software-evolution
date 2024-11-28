class CloneLocation {
  constructor(locFile, startLine, lastLine) {
    this.locFile = locFile;
    this.startLine = startLine;
    this.lastLine = lastLine;
  }
}

class Clone {
  constructor(content, cloneLocs, window) {
    this.content = content;
    this.cloneLocs = cloneLocs.map(
      loc => new CloneLocation(loc.locFile, loc.startLine, loc.lastLine)
    );
    this.window = window;
  }

  static createFromJSON(jsonData) {
    // Check if jsonData is an array before calling map
    if (!Array.isArray(jsonData)) {
      throw new Error('Expected an array of clones');
    }
    
    return jsonData.map(item => new Clone(
      item.content,
      item.cloneLocs,
      item.window
    ));
  }
}

export function getCloneList() {
  return fetch('clones.json')
    .then(response => response.json())  // First, resolve the JSON data
    .then(jsonData => Clone.createFromJSON(jsonData))  // Now pass the data to createFromJSON
    .catch(error => {
      console.error("Error loading clones:", error);
    });
}
