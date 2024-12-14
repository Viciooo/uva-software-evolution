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

public void findClones(loc project,int smallestClone, list[str] excludedPaths) {
    real startTime = realTime()/1000.0;

    list[loc] locations = getRelevantLocations(project,excludedPaths);
    int window = smallestClone; // starting window size. We use it for detecting clones using moving window
    list[Clone] clones = []; // result list of detected clones.

    map[int,LocationData] locationData = getLocationData(locations); // hashed loc strings are the keys, values are what we need to find clones

    result = firstIteration(locationData,window); // initial clones are created using unique process, later we just try to build on top of found clones.
    // We do it by trying to include next line. We take clone of size X and try to make it of size X+1 by appending the next line and checking if that is a clone.

    list[Clone] clonesLastIteration = result[0]; // for each iteration we will need last iteration to build on top of, via clone extension
    locationData = result[1];
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
                int locHash = stringToHash("<cl.locFile>"); // we create loc hash to get information about normalised location
                LocationData md = locationData[locHash];
                int idxInIndexes = indexOf(md.indexes,cl.lastLine); // gets index of line in normalised location of clone location's last line
                if(cl.lastLine == md.indexes[-1]){ // if last line of clone is last line of location - extension not possible
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

            map[str,list[CloneLoc]] extensionPossible = ();
            for(str s <- domain(nextLine)){
                if(size(nextLine[s]) == 1) noExtensionPossible += nextLine[s];
                else extensionPossible[s] = nextLine[s];
            }

            if(size(noExtensionPossible) > 1){ // if at least 2 were noExtensionPossible then we have a final clone to save
                clones += [clone(c.content,noExtensionPossible,c.size)];
                biggestCloneClass = c;
                if(size(c.cloneLocs) > size(mostFrequentClone.cloneLocs)){
                    mostFrequentClone = c;
                }
            }
            for(str s <- domain(extensionPossible)){
                list[CloneLoc] cloneLocsFamily = extensionPossible[s];
                list[CloneLoc] newExtendedLocs = [];
                for(l <- cloneLocsFamily){
                        locHash = stringToHash("<l.locFile>");
                        md = locationData[locHash];
                        idxInIndexes = indexOf(md.indexes,l.lastLine);
                        newLastIdx = md.indexes[idxInIndexes+1]; // gets real line in normalised file
                        newExtendedLocs += [cloneLoc(l.locFile,md.rawLines,l.startLine,newLastIdx)];
                }
                clonesThisIteration += [clone(c.content+s,newExtendedLocs,c.size+1)];
            }
        }

        if(size(clonesThisIteration) > 0){
            println("size(clonesThisIteration): <size(clonesThisIteration)>");
            window += 1;
            clonesFoundForWindow = true;
            clonesLastIteration = clonesThisIteration; // naturally with the end of iteration this iteration becomes last iteration
        }
    }
    clones = removeSubsumption(clones,startTime);
    printStatistics(startTime,clones,biggestCloneClass,mostFrequentClone, locations);
    writeClonesToJson(clones);
    logMsgAndTime("\nFinished in:",startTime);
}

private tuple[list[Clone],map[int,LocationData],Clone,Clone] firstIteration(map[int,LocationData] locData, int window){
    Clone biggestCloneClass = clone("",[],0);
    Clone mostFrequentClone = clone("",[],0);
    set[int] usedLocations = {};
    map[int,Clone] clones = ();

    for(int locationHash <- domain(locData)) {
        list[str] lines = locData[locationHash].lines;
        list[int] indexes = locData[locationHash].indexes;
        loc location = locData[locationHash].location;
        str rawLines =  locData[locationHash].rawLines;

        list[PotentialClone] allSubsets = potentialClonesOfSize(lines,indexes,window);

        for (pc <- allSubsets) {
            int h = stringToHash(pc.content);

            if (h in clones) {
                clones[h] = clone(
                    pc.content,
                    clones[h].cloneLocs + [cloneLoc(location,rawLines,pc.startLine,pc.lastLine)],
                    window);
            } else {
                clones[h] = clone(
                    pc.content,
                    [cloneLoc(location,rawLines,pc.startLine,pc.lastLine)],
                    window);
            }

            if(size(clones[h].cloneLocs) > 1){
                usedLocations += {locationHash};
                biggestCloneClass = clones[h];
            }

            if(size(clones[h].cloneLocs) > size(mostFrequentClone.cloneLocs)){
                mostFrequentClone = clones[h];
            }
        }
    }
    clones = removeClonesOfSize1(clones);
    cloneList = [clones[h] | h <- domain(clones)];
    return <cloneList,locData,biggestCloneClass,mostFrequentClone>;
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

private list[Clone] removeSubsumption(list[Clone] clones, real startDate) {
    set[int] indicesToDelete = {};
    
    logMsgAndTime("starting search process over <size(clones)> clones...", startDate);
    int cnt = 0;
    
    // Sort the list of clones by .size in descending order
    list[Clone] sortedClones = sort(clones, bool(Clone c1, Clone c2){return c1.size > c2.size;});
    
    // Now, compare clones using the sorted list to reduce redundant comparisons
    for (int i <- [0..size(sortedClones) - 1]) {
        if(i in indicesToDelete) continue;
        Clone cloneI = sortedClones[i];
        if(cnt % 100 == 0){
            logMsgAndTime("subsumption done for <i>/<size(sortedClones)> clones...", startDate);
        }
        for (int j <- [i + 1..size(sortedClones) - 1]) { // Start from i + 1, because j must have a smaller .size
            if(j in indicesToDelete) continue;
            Clone cloneJ = sortedClones[j];
            
            // If cloneJ's window is smaller than cloneI's, compare them
            if (cloneI.size > cloneJ.size && size(cloneI.cloneLocs) == size(cloneJ.cloneLocs) && 
                contains(cloneI.content, cloneJ.content)) {
                indicesToDelete += {j};  // Mark index j for removal
            }
        }
        cnt += 1;
    }

    logMsgAndTime("starting deletion process of <size(indicesToDelete)> clones...", startDate);
    
    // Delete the clones marked for removal
    list[Clone] remainders = [];
    set[int] indicesToKeep = toSet([0..size(sortedClones) - 1]) - indicesToDelete;  // Set of indices to keep
    for (int i <- [0..size(sortedClones) - 1]) {
        if(i in indicesToKeep){
            remainders += [sortedClones[i]];
        }
    }

    return remainders;
}
