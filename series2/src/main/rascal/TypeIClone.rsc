module TypeIClone

import IO;
import List;
import Map;
import Set;
import String;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::Math;
import Utils;
import util::Reflective;
import util::Benchmark;

private int stringToHash(str text) {
    return getHashCode(text);
}
data CloneLoc = cloneLoc(loc locFile,int startLine,int lastLine);
data PotentialClone = potentialClone(str content,int startLine,int lastLine);
data Clone = clone(str content,list[CloneLoc] cloneLocs,int window);
data MethodData = methodData(list[str] lines,list[int] indexes, loc method);

public void findClones(loc project) {
    real startTime = realTime()/1000.0;

    map[int, Clone] clones = ();
    list[loc] methods = getMethods(project);
    int window = 3;
    real totalLOC = 0.0;
    for(m <- methods){
        totalLOC += fileLoc(m)*1.0;
    }
    real duplicatedLines = 0.0;
    bool clonesFoundForWindow = true;
    Clone biggestCloneClass = clone("",[],0);
    Clone mostFrequentClone = clone("",[],0);
    set[int] usedMethods = {};

    // create a set of tuples (method,lines,indexes) before starting the search
    // figure out a way maybe use map - to remove any methods without new clones
    map[int,MethodData] methodData = getMethodData(methods);

    while(clonesFoundForWindow) {
        logMsgAndTime("Looking for duplicates of size <window>...",startTime);
        clonesFoundForWindow = false;
        usedMethods = {};

        for(int methodHash <- domain(methodData)) {
            list[str] lines = methodData[methodHash].lines;
            list[int] indexes = methodData[methodHash].indexes;
            loc method = methodData[methodHash].method;

            list[PotentialClone] allSubsets = potentialClonesOfSize(lines,indexes,window);

            for (pc <- allSubsets) {
                int h = stringToHash(pc.content);

                if (h in clones) {
                    clones[h] = clone(
                        pc.content,
                        clones[h].cloneLocs + [cloneLoc(method,pc.startLine,pc.lastLine)],
                        window);
                } else {
                    clones[h] = clone(
                        pc.content,
                        [cloneLoc(method,pc.startLine,pc.lastLine)],
                        window);
                }

                if(size(clones[h].cloneLocs) > 1){
                    clonesFoundForWindow=true;
                    usedMethods += {methodHash};
                    biggestCloneClass = clones[h];
                    // appendToFile(|file:///Users/spoton/Documents/uva/evolution/uva-software-evolution/series2/src/main/rascal/clones.logs|, "=======================================================\n");
                    // appendToFile(|file:///Users/spoton/Documents/uva/evolution/uva-software-evolution/series2/src/main/rascal/clones.logs|, "<clones[h]>\n");
                    // appendToFile(|file:///Users/spoton/Documents/uva/evolution/uva-software-evolution/series2/src/main/rascal/clones.logs|, "=======================================================\n");
                }

                if(size(clones[h].cloneLocs) > size(mostFrequentClone.cloneLocs)){
                    mostFrequentClone = clones[h];
                }
            }
        }
        clones = removeClonesOfSize1(clones);
        window += 1;

        if(clonesFoundForWindow){
            methodData = reduceMethodsToThoseWithNewlyFoundClones(methodData,usedMethods);
        }
    }
    logMsgAndTime("Removing smaller containing clones...",startTime);

    list[Clone] cloneList = removeClonesStrictlyContainingInBiggerClone(clones,startTime);

    logMsgAndTime("Preparing statistics...",startTime);
    for (c <- cloneList){
        duplicatedLines += c.window*size(c.cloneLocs);
    }
    real percentDuplicatedLines = duplicatedLines*100.0 / totalLOC;
    println("percentDuplicatedLines: <percentDuplicatedLines>%");
    int numberOfCloneClasses = size(cloneList);
    println("numberOfCloneClasses: <numberOfCloneClasses>");
    int numberOfClones = 0;
    for(c <- cloneList){
        numberOfClones += size(c.cloneLocs);
    }
    println("numberOfClones: <numberOfClones>");
    int biggestClonInLines = biggestCloneClass.window;
    println("biggestClonInLines: <biggestClonInLines>");
    int biggestClonInMembers = size(mostFrequentClone.cloneLocs);
    println("biggestClonInMembers: <biggestClonInMembers>");
    println("\nExample clones:");
    for(c <- cloneList[0..3]){
        println("Content:\n<c.content>");
        println("Number of lines: <c.window>");
        println("Number of members: <size(c.cloneLocs)>");
        println("Locations with clones:\n<c.cloneLocs>\n");
    }
}

private void logMsgAndTime(str msg,real startTime){
    real endTime = realTime()/1000.0;
    real elapsedTime = endTime - startTime;
    println("Time elapsed: <elapsedTime>s");
    println(msg);
}

private map[int,Clone] removeClonesOfSize1(map[int,Clone] clones){
    set[int] keysToDelete = {};
    
    for (int h <- domain(clones)) {
        if(size(clones[h].cloneLocs) == 1){
            keysToDelete += h;
        }
    }
    
    for (int key <- keysToDelete) {
        clones = delete(clones, key);
    }
    
    return clones;
}

private map[int, MethodData] reduceMethodsToThoseWithNewlyFoundClones(map[int, MethodData] methodData, set[int] methodUsed) {
    set[int] keysToRemove = domain(methodData) - methodUsed;
    for (int key <- keysToRemove) {
        methodData = delete(methodData, key);
    }
    return methodData;
}

private list[Clone] removeClonesStrictlyContainingInBiggerClone(map[int, Clone] clones, real startDate) {
    set[int] keysToDelete = {};
    
    logMsgAndTime("starting search process over <size(domain(clones))> clones...", startDate);
    int cnt = 0;
    // Convert map to a sorted list of clones by .window in descending order
    list[Clone] sortedClones = sort([clones[h] | h <- domain(clones)], bool(Clone c1, Clone c2){return c1.window > c2.window;});
    
    // Now, compare clones using the sorted list to reduce redundant comparisons
    for (int i <- [0..size(sortedClones)]) {
        Clone cloneI = sortedClones[i];
        if(cnt % 100 == 0){
            logMsgAndTime("completed <i> clones...", startDate);
        }
        for (int j <- [i+1..size(sortedClones)]) { // Start from i + 1, because j must have a smaller .window
            Clone cloneJ = sortedClones[j];
            
            // If cloneJ's window is smaller than cloneI's, compare them
            if (cloneI.window > cloneJ.window && size(cloneI.cloneLocs) == size(cloneJ.cloneLocs) && 
                contains(cloneI.content, cloneJ.content)) {
                keysToDelete += j;
            }
        }
        cnt += 1;
    }

    logMsgAndTime("starting deletion process of <size(keysToDelete)> clones...", startDate);
    
    // Delete the clones marked for removal
    list[Clone] remainders = [];
    set[int] keysToKeep = toSet([0..size(sortedClones)]) - keysToDelete;
    for (int i <- [0..size(sortedClones)]) {
        if(i in keysToKeep){
            remainders += [sortedClones[i]];
        }
    }

    return remainders;
}




private list[PotentialClone] potentialClonesOfSize(list[str] lines, list[int] indexes, int s){
    list[PotentialClone] result = [];

    if (s > size(lines)) {
        return [];
    }
    for (int i <- [0..size(lines)-s]) {
        PotentialClone pc = potentialClone("",indexes[i],indexes[i+s-1]);
        for(int j <- [i..i+s]){
            pc.content += lines[j];
        }
        result += [pc];
    }
    return result;
}

private map[int,MethodData] getMethodData(list[loc] methods){
    map[int,MethodData] md = ();

    for(loc m <- methods){
        result = fileContentLines(m);
        h = stringToHash("<m>");
        md[h] = methodData(result[0],result[1],m);
    }
    return md;
}
