module Duplication

import Utils;
import IO;
import List;
import Set;
import String;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::Math;

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
        duplicates += calculateLineDuplication(lines);
    };
    real duplication = duplicates * 100 / totalLines;
    // println("Duplicated lines: <duplication>%");
    // println("Total lines: <totalLines>");
    // println("Duplicated lines: <duplicates>");

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

public int calculateLineDuplication(list[str] lines) {
    int windowSize = 6; // Size of the window to compare lines
    set[str] uniqueDuplicates = {}; // Set to store unique duplicate sequences
    int duplicatedLinesCounter = 0;       // Counter for duplicated lines
    // str content = "";

    if (size(lines) < windowSize) {
        return 0;
    }
    for (int i <- [0 .. size(lines) - windowSize]) {
        list[str] currentWindow = lines[i .. i + windowSize];
        if ("<currentWindow>" in uniqueDuplicates) {
            continue; // Skip if we already found this duplicate
        }

        if (size(currentWindow) != 6){
            println("Problem with window size");
            println(currentWindow);
            println("i: <i>");
            println("i + windowSize: <i + windowSize>");
            continue;
        }
        
        
        for (int j <- [i + 1 .. size(lines) - windowSize]) {
            list[str] comparisonWindow = lines[j .. j + windowSize];
            // str content1 = "currentWindow: <currentWindow>\n";
            // str content2 = "comparisonWindow: <comparisonWindow>\n\n";
            // content += content1;
            // content += content2;
            
            if ("<currentWindow>" == "<comparisonWindow>") { // We have to compare them as strings
                // println("Found duplicate: <currentWindow>");
                if (!("<currentWindow>" in uniqueDuplicates)) {
                    uniqueDuplicates += {"<currentWindow>"};
                    duplicatedLinesCounter += windowSize; // Add for currentWindow. We want to count duplicated lines, that includes the one that we started with
                }
                duplicatedLinesCounter += windowSize; // Add for each duplicate
            }
        }
    }
    // println(uniqueDuplicates);
    // writeFile(|file:///Users/spoton/Documents/uva/evolution/uva-software-evolution/series1/output.txt|, content);
    return duplicatedLinesCounter;
}
