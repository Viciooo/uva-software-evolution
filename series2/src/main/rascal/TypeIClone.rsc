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

import Presentation;
import DataTypes;

public void findClones(loc project) {
    real startTime = realTime()/1000.0;

    list[loc] methods = getMethods(project); // gets all method location within the project directory
    int window = 3; // starting window size. We use it for detecting clones using moving window
    list[Clone] clones = []; // result list of detected clones.

    map[int,MethodData] methodData = getMethodData(methods); // hashed loc strings are the keys, values are what we need to find clones

    result = getInitialClones(methodData,window); // initial clones are created using unique process, later we just try to build on top of found clones.
    // We do it by trying to include next line. We take clone of size X and try to make it of size X+1 by appending the next line and checking if that is a clone.

    list[Clone] clonesLastIteration = result[0]; // for each iteration we will need last iteration to build on top of, via clone extension
    methodData = result[1];
    Clone biggestCloneClass = result[2]; // biggestCloneClass is a clone class with the most lines
    Clone mostFrequentClone = result[3]; // mostFrequentClone is a clone that is repeated te most

    if(size(clonesLastIteration) == 0){ // if no clones are found in the first iteration, no reason to continue
        println("No clones of size <window> found!");
        return;
    }
    bool clonesFoundForWindow = true;
    window+=1;

    while(clonesFoundForWindow) {
        logMsgAndTime("Looking for duplicates of size <window>...",startTime);
        clonesFoundForWindow = false;
        list[Clone] clonesThisIteration = []; // each iteration we start with an empty list

        for(Clone c <- clonesLastIteration){ // for each clone of last iteration we will try to extend it into clone of size +1
            map[str,list[CloneLoc]] nextLine = (); // map stores nextLines of a clone for each group of clone locations
            list[CloneLoc] noExtensionPossible = []; // clone locs with no possible extensions
            for(CloneLoc cl <- c.cloneLocs){
                int locHash = stringToHash("<cl.locFile>"); // we create loc hash to get information about normalised method
                MethodData md = methodData[locHash];
                int idxInIndexes = indexOf(md.indexes,cl.lastLine); // gets index of line in normalised method of clone location's last line 
                if(cl.lastLine == md.indexes[-1]){ // if last line of clone is last line of method - extension not possible
                    noExtensionPossible += [cl];
                    continue;
                }
                int newLastIdx = md.indexes[idxInIndexes+1]; // gets index in not normalised file
                str newLastLine = md.lines[idxInIndexes+1]; // gets new last line value
                if(newLastLine in domain(nextLine)){ // we want to group them by new last line, each key with at least 2 values is a new clone
                    nextLine[newLastLine] += [cl];
                }else{
                    nextLine[newLastLine] = [cl];
                }
            }

            if(size(domain(nextLine)) == 1 && size(noExtensionPossible) == 0){ // all can be extended, then this clone is redundant, because there is a bigger one
                list[CloneLoc] newLocs = [];
                str newLastLine;
                for(l <- c.cloneLocs){
                    locHash = stringToHash("<l.locFile>");
                    md = methodData[locHash];
                    idxInIndexes = indexOf(md.indexes,l.lastLine);
                    newLastIdx = md.indexes[idxInIndexes+1]; // gets real line in normalised file
                    newLastLine = md.lines[idxInIndexes+1];
                    l.lastLine = newLastIdx;
                    newLocs += [cloneLoc(l.locFile,l.startLine,newLastIdx)];
                }
                clonesThisIteration += [clone(c.content+newLastLine,newLocs,c.window+1)];
                continue;
            }
            if(size(domain(nextLine)) == 0){ // none can be extended - we have to save it to final list - this is a final clone for sure
                clones += [c];
                biggestCloneClass = c;
                if(size(c.cloneLocs) > size(mostFrequentClone.cloneLocs)){
                    mostFrequentClone = c;
                }
                continue;
            }
            if(size(noExtensionPossible) > 1){ // if at least 2 were noExtensionPossible then we have a final clone to save
                clones += [clone(c.content,noExtensionPossible,c.window)];
                biggestCloneClass = c;
                if(size(c.cloneLocs) > size(mostFrequentClone.cloneLocs)){
                    mostFrequentClone = c;
                }
            }
            list[CloneLoc] finalLocs = [];

            for(str s <- domain(nextLine)){
                list[CloneLoc] thoseClonLocs = nextLine[s];

                if(size(nextLine[s]) > 1){ // if at least 2 locations have the same extension then we have a next clone
                    list[CloneLoc] newLocs = [];
                    for(l <- thoseClonLocs){
                        locHash = stringToHash("<l.locFile>");
                        md = methodData[locHash];
                        idxInIndexes = indexOf(md.indexes,l.lastLine);
                        newLastIdx = md.indexes[idxInIndexes+1]; // gets real line in normalised file
                        newLocs += [cloneLoc(l.locFile,l.startLine,newLastIdx)];
                    }
                    clonesThisIteration += [clone(c.content+s,newLocs,c.window+1)];
                }else{ // if clone locs have differing extensions, then there will be no bigger clone with them
                    finalLocs += thoseClonLocs;
                }
            }
            if(size(finalLocs) > 1){
                clones += [clone(c.content,finalLocs,c.window)];
                biggestCloneClass = c;
                if(size(c.cloneLocs) > size(mostFrequentClone.cloneLocs)){
                    mostFrequentClone = c;
                }
            }
        }

        if(size(clonesThisIteration) > 0){
            println("size(clonesThisIteration): <size(clonesThisIteration)>");
            window += 1;
            clonesFoundForWindow = true;
            clonesLastIteration = clonesThisIteration; // naturally with the end of iteration this iteration becomes last iteration
        }
    }
    printStatistics(startTime,clones,biggestCloneClass,mostFrequentClone, methods);
    writeClonesToJson(clones);
    logMsgAndTime("\nFinished in:",startTime);
}

private tuple[list[Clone],map[int,MethodData],Clone,Clone] getInitialClones(map[int,MethodData] methodData, int window){
    Clone biggestCloneClass = clone("",[],0);
    Clone mostFrequentClone = clone("",[],0);
    set[int] usedMethods = {};
    map[int,Clone] clones = ();

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
                usedMethods += {methodHash};
                biggestCloneClass = clones[h];
            }

            if(size(clones[h].cloneLocs) > size(mostFrequentClone.cloneLocs)){
                mostFrequentClone = clones[h];
            }
        }
    }
    clones = removeClonesOfSize1(clones);
    cloneList = [clones[h] | h <- domain(clones)];
    return <cloneList,methodData,biggestCloneClass,mostFrequentClone>;
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
