export function extractPathFromLoc(loc) {
    // Step 1: Remove everything before and including "java+method:///"
    const methodPart = loc.split("java+method:///")[1];
    if (!methodPart) return null; // Ensure the split worked

    // Step 3: Take everything until the '('
    const beforeParenthesis = methodPart.split('(')[0];

    // Step 4: Extract the portion before the last '/' and after it
    const lastSlashIndex = beforeParenthesis.lastIndexOf('/');
    if (lastSlashIndex === -1) return null; // No '/' found
    const classPart = beforeParenthesis.slice(0, lastSlashIndex);
    const methodPartFinal = beforeParenthesis.slice(lastSlashIndex + 1);

    // Step 5: Combine the parts with ".java"
    const result = `${classPart}.java/${methodPartFinal}`;

    return result;
}

export function toNodesAndLinks(clones, depth) {
    var nodesMap = new Map();
    var links = new Set();
  
    var currDepth = 0;
    
    clones.forEach(c => {
      c.methods.forEach(m => {
        if(!m.name){
            return
        }
        const parts = m.name.split('/');
        currDepth = 0;
        
        while (currDepth < Math.min(depth, parts.length)) {
          const path = parts.slice(0, currDepth).join('/');
  
          // Update nodesMap with the path as the key and window as the value (clonedLines)
          if (nodesMap.has(path)) {
            nodesMap.set(path, nodesMap.get(path) + c.window); // Assuming window is the value to add
          } else {
            nodesMap.set(path, c.window); // Initialize with window value
            if (currDepth !== 0) {
              const previousPath = parts.slice(0, currDepth - 1).join('/');
              links.add({ source: previousPath, target: path });
            }
          }
          currDepth += 1;
        }
      });
    });
  
    const nodes = Array.from(nodesMap.entries()).map(([key, value]) => ({
      id: key,
      size: value,
      tooltip: `lines: ${value}`
    }));
  
    return { nodes, links: Array.from(links) }; // Return both nodes and links as arrays
  }
