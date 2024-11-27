module Utils
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import Set;
import Map;
import String;
import util::Reflective;

import DataTypes;

private list[str] splitLines(str text) = [ s | s <- split("\n", text)];
private tuple[list[str],list[int]] removeCommentsAndWhitespace(list[str] lines) {
    list[str] result = [];
    list[int] indexes = [];
    int idx = -1;
    bool inBlockComment = false;

    for (str line <- lines) {
        idx+=1;

        if (/^\s*$/ := line) {
            continue;
        }

        line = trim(line); // this is breaking formating - maybe we save it as a field in clone model?

        if (inBlockComment) {
            if (contains(line,"*/")) {
                inBlockComment = false;
            }
            continue;
        }

        if (startsWith(line,"//")) {
            continue;
        }

        if (contains(line,"/*")) {
            inBlockComment = true;
            continue;
        }

        result += [line];
        indexes += [idx];

    }

    return <result,indexes>;
}

private str fileContent(loc file) = readFile(file);
public tuple[list[str],list[int]] fileContentLines(loc file){
    // [lines,indexes] - to help visualize the clones despite the normalization
    // We planned using loc.begin.line and loc.end.line, but they don't work
    // in java+method locs - getting UnavailableInformation()

    list[str] lines = splitLines(fileContent(file));
    return removeCommentsAndWhitespace(lines);
}

public list[loc] getMethods(loc projectLocation) = toList(methods(getModel(projectLocation)));
public list[loc] getClasses(loc projectLocation) = toList(classes(getModel(projectLocation)));
public int fileLoc(loc file) = size(fileContentLines(file)[0]);


public list[Declaration] getASTs(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    list[Declaration] asts = [createAstFromFile(f, true)
    | f <- files(model.containment), isCompilationUnit(f)];
    return asts;
}

public M3 getModel(loc projectLocation) {
	return createM3FromDirectory(projectLocation);
}

public M3 getModelFromFile(loc file) {
    return createM3FromFile(file);
}

public int stringToHash(str text) {
    return getHashCode(text);
}

public map[int,MethodData] getMethodData(list[loc] methods){
    map[int,MethodData] md = ();

    for(loc m <- methods){
        result = fileContentLines(m);
        h = stringToHash("<m>");
        md[h] = methodData(result[0],result[1],m);
    }
    return md;
}

