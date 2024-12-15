import { extractPathFromLoc } from "./transformations";

class CloneLocation {
  constructor(locFile, startLine, lastLine, rawLines) {
    this.name = extractPathFromLoc(locFile);
    this.startLine = startLine + 1;
    this.lastLine = lastLine + 1;
    this.rawLines = rawLines;
  }

}

export class Clone {
  constructor(content, cloneLocs, size) {
    this.content = content;
    this.methods = cloneLocs.map(
      loc => new CloneLocation(loc.locFile, loc.startLine, loc.lastLine, loc.rawLines)
    );
    this.size = size;
  }

  static createFromJSON(jsonData) {
    if (!Array.isArray(jsonData)) {
      throw new Error('Expected an array of clones');
    }

    return jsonData.map(item => new Clone(
      item.content,
      item.cloneLocs,
      item.size
    ));
  }
}
