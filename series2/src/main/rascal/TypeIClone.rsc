module TypeIClone
import Exception;
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

    list[loc] methods = getMethods(project);
    int window = 30;
    list[Clone] clones = [];

    map[int,MethodData] methodData = getMethodData(methods);

    result = getInitialClones(methodData,window);

    list[Clone] clonesLastIteration = result[0];
    methodData = result[1];
    Clone biggestCloneClass = result[2];
    Clone mostFrequentClone = result[3];

    if(size(clonesLastIteration) == 0){
        println("No clones of size <window> found!");
        return;
    }
    window+=1;
    bool clonesFoundForWindow = true;
    real totalLOC = 0.0;
    for(m <- methods){
        totalLOC += fileLoc(m)*1.0;
    }
    real duplicatedLines = 0.0;

    while(clonesFoundForWindow) {
        logMsgAndTime("Looking for duplicates of size <window>...",startTime);
        clonesFoundForWindow = false;
        list[Clone] clonesThisIteration = [];

        for(Clone c <- clonesLastIteration){
            map[str,list[CloneLoc]] nextLine = ();
            list[CloneLoc] skipped = [];
            for(CloneLoc cl <- c.cloneLocs){
                int locHash = stringToHash("<cl.locFile>");
                MethodData md = methodData[locHash];
                int idxInIndexes = indexOf(md.indexes,cl.lastLine);
                if(cl.lastLine == md.indexes[-1]){ // if last line of clone is last line of method - skip
                    skipped += [cl];
                    continue;
                }
                int newLastIdx = md.indexes[idxInIndexes+1]; // gets real line in normalised file
                str newLastLine = md.lines[idxInIndexes+1]; // gets next line value
                if(newLastLine in domain(nextLine)){
                    nextLine[newLastLine] += [cl];
                }else{
                    nextLine[newLastLine] = [cl];
                }
            }

            if(size(domain(nextLine)) == 1 && size(skipped) == 0){ // all can be extended, then this clone is redundant, because there is a bigger one
                list[CloneLoc] newLocs = [];
                str newLastLine = "&"; // some dummy init
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
            if(size(skipped) > 1){ // if at least 2 were skipped then we have a final clone to save
                clones += [clone(c.content,skipped,c.window)];
                biggestCloneClass = c;
                if(size(c.cloneLocs) > size(mostFrequentClone.cloneLocs)){
                    mostFrequentClone = c;
                }
            }
            list[CloneLoc] finalLocs = [];

            for(str s <- domain(nextLine)){
                list[CloneLoc] thoseClonLocs = nextLine[s];

                if(size(thoseClonLocs) > 1){
                    list[CloneLoc] newLocs = [];
                    for(l <- thoseClonLocs){
                        locHash = stringToHash("<l.locFile>");
                        md = methodData[locHash];
                        idxInIndexes = indexOf(md.indexes,l.lastLine);
                        newLastIdx = md.indexes[idxInIndexes+1]; // gets real line in normalised file
                        newLocs += [cloneLoc(l.locFile,l.startLine,newLastIdx)];
                    }
                    clonesThisIteration += [clone(c.content+s,newLocs,c.window+1)];
                }else{
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
            clonesFoundForWindow = true; // commented for tests
            clonesLastIteration = clonesThisIteration;
        }
    }
    logMsgAndTime("Preparing statistics...",startTime);
    for (c <- clones){
        duplicatedLines += c.window*size(c.cloneLocs);
    }
    real percentDuplicatedLines = duplicatedLines*100.0 / totalLOC;
    println("percentDuplicatedLines: <percentDuplicatedLines>%");
    int numberOfCloneClasses = size(clones);
    println("numberOfCloneClasses: <numberOfCloneClasses>");
    int numberOfClones = 0;
    for(c <- clones){
        numberOfClones += size(c.cloneLocs);
    }
    println("numberOfClones: <numberOfClones>");
    int biggestClonInLines = biggestCloneClass.window;
    println("biggestClonInLines: <biggestClonInLines>");

    println("biggestCloneClass.content: <biggestCloneClass.content>");
    println("biggestCloneClass.cloneLocs: <biggestCloneClass.cloneLocs>");

    int biggestClonInMembers = size(mostFrequentClone.cloneLocs);
    println("biggestClonInMembers: <biggestClonInMembers>");
    println("\nExample clones:");
    for(c <- clones[0..3]){
        println("Content:\n<c.content>");
        println("Number of lines: <c.window>");
        println("Number of members: <size(c.cloneLocs)>");
        println("Locations with clones:\n<c.cloneLocs>\n");
    }
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
