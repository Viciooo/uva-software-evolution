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
