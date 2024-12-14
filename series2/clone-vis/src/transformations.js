export function extractPathFromLoc(loc) {
    // Remove the prefix and split at the "|"
    if (!loc.includes("/src/")){
        return loc;
    }
    const withoutPrefix = loc.substring(loc.indexOf("/src/") + 5);
    const parts = withoutPrefix.split("|");

    // Extract the file path (first part) and the tuple (last part)
    const filePath = parts[0];
    const tuple = parts[1];

    // Extract content after the tuple's first two values
    const tupleParts = tuple.split(",");
    const trimmedTuple = tupleParts.slice(2).join(",");

    return `${filePath}(${trimmedTuple})`;
}

export function toNodesAndLinks(clones, depth) {
    depth+=1; // depth on the UI is understood as distance from the root, here it's how many path elements we take
    var nodesMap = new Map();
    var links = new Set();

    var currDepth = 0;

    clones.forEach(c => {
        c.methods.forEach(m => {
            if (!m.name) {
                return
            }
            const parts = m.name.split('/');
            currDepth = 0;
            console.log(parts);
            while (currDepth <= Math.min(depth, parts.length)) {
                const path = parts.slice(0, currDepth).join('/');

                // Update nodesMap with the path as the key and size as the value (clonedLines)
                if (nodesMap.has(path)) {
                    nodesMap.set(path, nodesMap.get(path) + c.size);
                } else {
                    nodesMap.set(path, c.size);
                    if (currDepth !== 0) {
                        const previousPath = parts.slice(0, currDepth - 1).join('/');
                        links.add({source: previousPath, target: path});
                    }
                }
                currDepth += 1;
            }
        });
    });

    const nodes = Array.from(nodesMap.entries()).map(([key, value]) => ({
        id: key,
        size: value*10,
        tooltip: `cloned lines: ${value}\npath: ${key}`,
    }));

    return {nodes, links: Array.from(links)};
}
