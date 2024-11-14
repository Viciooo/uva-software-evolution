module Utils
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import Set;
import String;

private list[str] splitLines(str text) = [ s | s <- split("\n", text), /^\s*$/ !:= s ];
private list[str] trimLines(list[str] lines) = [ trim(l) | l <- lines ];

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
// /Users/spoton/Documents/uva/evolution/test-java-project1
// /Users/spoton/Documents/uva/evolution/hsqldb-2.3.1
// /Users/spoton/Documents/uva/evolution/smallsql0.21_src
private loc projectLocation = |file:///Users/spoton/Documents/uva/evolution/smallsql0.21_src|;
private str fileContent(loc file) = readFile(file);
public list[str] fileContentLines(loc file) = removeComments(splitLines(fileContent(file)));

public list[loc] getMethods() = toList(methods(getModel()));
public list[loc] getClasses() = toList(classes(getModel()));
public int fileLoc(loc file) = size(fileContentLines(file));


public list[Declaration] getASTs() {
    M3 model = createM3FromMavenProject(projectLocation);
    list[Declaration] asts = [createAstFromFile(f, true)
    | f <- files(model.containment), isCompilationUnit(f)];
    return asts;
}

public M3 getModel() {
	return createM3FromDirectory(projectLocation);
}

public M3 getModelFromFile(loc file) {
	return createM3FromFile(file);
}


public str mapLevelToRank(int level) {
    switch(level) {
        case 1: return "--";
        case 2: return "-";
        case 3: return "o";
        case 4: return "+";
        case 5: return "++";
        default: return "błąd";
    }
}
