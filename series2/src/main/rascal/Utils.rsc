module Utils
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import Set;
import Map;
import String;

private list[str] splitLines(str text) = [ s | s <- split("\n", text), /^\s*$/ !:= s ];
private list[str] removeComments(list[str] lines) {
    list[str] result = [];
    bool inBlockComment = false;
    for (str line <- lines) {
        line = trim(line);

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
    }

    return result;
}

private str fileContent(loc file) = readFile(file);
public list[str] fileContentLines(loc file) = removeComments(splitLines(fileContent(file)));

public list[loc] getMethods(loc projectLocation) = toList(methods(getModel(projectLocation)));
public list[loc] getClasses(loc projectLocation) = toList(classes(getModel(projectLocation)));
public int fileLoc(loc file) = size(fileContentLines(file));


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

public lrel[str,int] compressDuplicatesList(list[str] givenList){
    map[str, int] counts = ();
    for (str item <- givenList) {
        if (item in counts) {
            counts[item] += 1;
        } else {
            counts[item] = 1;
        }
    }
    return [<k, v> | k <- domain(counts), v <- [counts[k]]];
}

public list[str] subsetsOfSize(list[str] lines, int s){
    list[str] result = [];

    if (s > size(lines)) {
        return result;
    }
    for (int i <- [0..size(lines)-s]) {
        str subset = "";
        for(int j <- [i..i+s]){
            subset += lines[j];
        }
        result += [subset];
    }
    return result;
}
