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

data Clone = clone(str content,list[loc] cloneLocs,int window);

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

    while(clonesFoundForWindow) {
        logMsgAndTime("Looking for duplicates of size <window>...",startTime);
        clonesFoundForWindow = false;
        for(loc method <- methods) {
            list[str] lines = fileContentLines(method);

            list[str] allSubsets = subsetsOfSize(lines,window);
            lrel[str, int] allSubsetsWithCounts = compressDuplicatesList(allSubsets);

            for (<s,c> <- allSubsetsWithCounts) {
                int h = stringToHash(s);

                if (h in clones) {
                    clones[h] = clone(s, clones[h].cloneLocs + [method | _ <- [0..c]],window);
                } else {
                    clones[h] = clone(s, [method | _ <- [0..c]],window);
                }

                if(size(clones[h].cloneLocs) > 1){
                    clonesFoundForWindow=true;
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
            set[loc] methods = reduceMethodsToThoseWithNewlyFoundClones(clones,window);
        }
    }
    logMsgAndTime("Removing smaller containing clones...",startTime);
    clones = removeClonesStrictlyContainingInBiggerClone(clones);

    logMsgAndTime("Preparing statistics...",startTime);
    list[Clone] cloneList = [clones[h] | h <- domain(clones)];
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

private set[loc] reduceMethodsToThoseWithNewlyFoundClones(map[int,Clone] clones,int window){
    set[loc] locs = {};

    for (int h <- domain(clones)) {
        if(clones[h].window == window){
            locs += toSet(clones[h].cloneLocs);
        }
    }
    return locs;
}

private map[int,Clone] removeClonesStrictlyContainingInBiggerClone(map[int,Clone] clones){
    println("removeClonesStrictlyContainingInBiggerClone: <size(domain(clones))>");
    set[int] keysToDelete = {};
    for(int i <- domain(clones)){
        for(int j <- domain(clones)){
            if(i==j) continue;
            bool frequencyMatches = size(clones[i].cloneLocs)==size(clones[j].cloneLocs);
            if(frequencyMatches && contains(clones[i].content,clones[j].content)){
                keysToDelete += j;
            }
        }    
    }

    for(int key <- keysToDelete){
        clones = delete(clones, key);
    }
    return clones;
}
