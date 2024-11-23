module TypeIClone

import IO;
import List;
import Map;
import String;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::Math;
import Utils;
import util::Reflective;

private int stringToHash(str text) {
    return getHashCode(text);
}

data Clone = clone(str content,list[loc] cloneLocs,int window);

public void findClones(loc project) {
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
        clonesFoundForWindow = false;
        for(loc method <- methods) {
            list[str] lines = fileContentLines(method);

            list[str] allSubsets = subsetsOfSize(lines,window);
            lrel[str, int] allSubsetsWithCounts = compressList(allSubsets);

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
                }

                if(size(clones[h].cloneLocs) > size(mostFrequentClone.cloneLocs)){
                    mostFrequentClone = clones[h];
                }
            }
        }
        clones = removeClonesOfSize1(clones);
        window += 1;

        if(clonesFoundForWindow){
            set[loc] methods = reduceMethodsToThoseWithClones(clones);
        }
    }
    clones = removeClonesStrictlyContainingInBiggerClone(clones);
    list[Clone] cloneList = [clones[h] | h <- domain(clones)];

    // A report of cloning statistics showing at least the % of duplicated lines,
    // number of clones, number of clone classes, biggest clone (in lines),
    // biggest clone class (in members), and example clones.
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

    // for(c <- cloneList){
    //     appendToFile(|file:///Users/spoton/Documents/uva/evolution/uva-software-evolution/series2/src/main/rascal/clones.logs|, "=======================================================\n");
    //     appendToFile(|file:///Users/spoton/Documents/uva/evolution/uva-software-evolution/series2/src/main/rascal/clones.logs|, "<c.content>\n");
    //     appendToFile(|file:///Users/spoton/Documents/uva/evolution/uva-software-evolution/series2/src/main/rascal/clones.logs|, "=======================================================\n");
    // }

    // appendToFile(|file:///Users/spoton/Documents/uva/evolution/uva-software-evolution/series2/src/main/rascal/clones.logs|, "\nbiggestCloneClass: <biggestCloneClass>\n");
    // appendToFile(|file:///Users/spoton/Documents/uva/evolution/uva-software-evolution/series2/src/main/rascal/clones.logs|, "mostFrequentClone: <mostFrequentClone>\n");
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

private set[loc] reduceMethodsToThoseWithClones(map[int,Clone] clones){
    set[loc] locs = {};

    for (int h <- domain(clones)) {
        locs += toSet(clones[h].cloneLocs);
    }
    return locs;
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

public lrel[str,int] compressList(list[str] givenList){
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

private map[int,Clone] removeClonesStrictlyContainingInBiggerClone(map[int,Clone] clones){
    set[int] keysToDelete = {};
    for(int i <- domain(clones)){
        for(int j <- domain(clones)){
            if(i==j) continue;

            bool frequencyMatches = size(clones[i].cloneLocs)==size(clones[j].cloneLocs);
            if(frequencyMatches && contains(clones[i].content,clones[j].content)){
                keysToDelete += j;
            }
            if(frequencyMatches && contains(clones[j].content,clones[i].content)){
                keysToDelete += i;
            }
        }    
    }

    for(int key <- keysToDelete){
        clones = delete(clones, key);
    }
    return clones;
}
