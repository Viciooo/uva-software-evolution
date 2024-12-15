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
        indexes += [idx];

    }

    return <result,indexes>;
}

private str fileContent(loc file) = readFile(file);
public tuple[list[str],list[int]] normalisedFileContentLines(loc file){
    list[str] lines = splitLines(fileContent(file));
    return removeCommentsAndWhitespace(lines);
}


public list[loc] getRelevantLocations(loc sourceLocation, list[str] excludedPaths) {
    list[loc] files = toList(files(createM3FromDirectory(sourceLocation)));

    if(size(excludedPaths) > 0){
        list[loc] remainingFiles = [];
        for(f <- files){
            for(s <- excludedPaths){
                if(!contains("<f>",s)){
                    remainingFiles += [f];
                }
            }
        }
        files = remainingFiles;
    }
    
    results = [];
    for(loc class <- files){
        ast = createAstFromFile(class, true);
        
        visit(ast) {
            case d:\enum(_,_,_,_,_) : {
                results += d@src;
            }
            case d:\interface(_,_,_,_,_,_) : {
                results += d@src;
            }
            case d:\constructor(_,_,_,_,_) : {
                results += d@src;
            }
            case d:\initializer(_,_) : {
                results += d@src;
            }
            case d:\method(_,_,_,_,_,_,_) : {
                results += d@src;
            }
            case d:\method(_,_,_,_,_,_) : {
                results += d@src;
            }
        }
    }
    return results;
}

public int locNormalizedSize(loc location) = size(normalisedFileContentLines(location)[0]);

public int stringToHash(str text) {
    return getHashCode(text);
}

public map[int,LocationData] getLocationData(list[loc] locations){
    map[int,LocationData] locData = ();

    for(loc l <- locations){
        result = normalisedFileContentLines(l);
        rawLines = fileContent(l);
        h = stringToHash("<l>");
        locData[h] = locationData(result[0],rawLines,result[1],l);
    }
    return locData;
}

