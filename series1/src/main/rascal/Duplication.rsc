module Duplication

import Utils;
import IO;
import List;
import Set;
import String;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::Math;
import Map;

// Duplicate can be counted in 2 ways:
// 1. Counting each duplicate as 1
// 2. Counting each duplicate as the number of times it appears
// We will choose the latter, because it is not the number of duplicated functions that
// adds to duplication and thus danger but the sheer number of duplicated lines. Over time 
// they will corode, no matter if they originate from one or many functions.

// This method punishes heavily duplication blocks of size bigger then 6, as it counts them many times adding all subsets of size 6.
// It is something to be aware of, but as a rule of thumb repetition of more then 6 lines is in our opinion much more worse then that of size 6, 
// leading as to believe that this approach is acceptable.

public str duplicationRank(){
    str rank = mapLevelToRank(duplicationLevel());
    return "Duplication rank: <rank>";
}

public int duplicationLevel(){
    list[loc] methods = getMethods();
    int duplicates = 0;
    real totalLines = 0.0;
    
    for(loc method <- methods){
        list[str] lines = fileContentLines(method);
        totalLines += size(lines);
        duplicates += calculateDuplicates(lines);
    };
    real duplication = duplicates * 100 / totalLines;
    // println("Duplicated lines: <duplication>%");
    // println("Total lines: <totalLines>");

    if(duplication <= 3.0){
        return 5;
    } else if(duplication <= 5.0){
        return 4;
    } else if(duplication <= 10.0){
        return 3;
    } else if(duplication <= 20.0){
        return 2;
    } else {
        return 1;
    }
}

private int calculateDuplicates(list[str] lines) {
    int windowSize = 6;
    if(size(lines) < windowSize){
        return 0;
    }
    
    map[str, int] windows = ();
    int duplicatedLinesCounter = 0;

    for (int i <- [0 .. size(lines) - windowSize]) {
        str window = "<lines[i .. i + windowSize]>";
        if (window in windows) {
            if(windows[window]==0){
                windows[window] += windowSize; // we need to add twice for the first time
                duplicatedLinesCounter += windowSize;
            }
            windows[window] += windowSize;
            duplicatedLinesCounter += windowSize;
        }else{
            windows[window] = 0;
        }
    }
    return duplicatedLinesCounter;
}
