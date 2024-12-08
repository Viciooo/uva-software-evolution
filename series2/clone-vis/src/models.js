import { extractPathFromLoc } from "./transformations";

class CloneLocation {
  constructor(locFile, startLine, lastLine, rawLines) {
    this.name = extractPathFromLoc(locFile);
    this.startLine = startLine + 1; // don't understand why :laughing-in-js:
    this.lastLine = lastLine + 1; // don't understand why :laughing-in-js:
    this.rawLines = rawLines;
  }

}

export class Clone {
  constructor(content, cloneLocs, window) {
    this.content = content;
    this.methods = cloneLocs.map(
      loc => new CloneLocation(loc.locFile, loc.startLine, loc.lastLine, loc.rawLines)
    );
    this.window = window;
  }

  static createFromJSON(jsonData) {
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
