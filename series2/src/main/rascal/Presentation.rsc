module Presentation
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
import lang::json::IO;

import DataTypes;

loc resultFile = |project://series2/result.txt|;

public void printStatistics(real startTime,list[Clone] clones, Clone biggestCloneClass,Clone mostFrequentClone, list[loc] methods){
    logMsgAndTime("Preparing statistics...",startTime);

    real duplicatedLines = sum([c.window*size(c.cloneLocs) | c <- clones])*1.0;
    real totalLOC = sum([fileLoc(m)*1.0 | m <- methods]);
    real percentDuplicatedLines = duplicatedLines*100.0 / totalLOC;
    appendToFile(resultFile, "Percent Duplicated Lines: <percentDuplicatedLines>%\n");

    int numberOfCloneClasses = size(clones);
    appendToFile(resultFile, "numberOfCloneClasses: <numberOfCloneClasses>\n");

    int numberOfClones = sum([size(c.cloneLocs) | c <- clones]);
    appendToFile(resultFile, "Total Number Of Clones: <numberOfClones>\n");

    appendToFile(resultFile, "Biggest Clon In Lines:\n");
    printClone(biggestCloneClass);

    appendToFile(resultFile, "Biggest Clon In Members:\n");
    printClone(mostFrequentClone);
}

public void printClone(Clone c){
    appendToFile(resultFile, "Content:\n<c.content>\n");
    appendToFile(resultFile, "Number of lines: <c.window>\n");
    appendToFile(resultFile, "Number of members: <size(c.cloneLocs)>\n");
    appendToFile(resultFile, "Locations with clones:\n");
    int cnt = 0;
    for(cl <- c.cloneLocs){
        appendToFile(resultFile, "<cnt>:\n");
        appendToFile(resultFile, "   <cl.locFile>\n");
        appendToFile(resultFile, "   Method line: <cl.startLine> to <cl.lastLine>\n\n");
        cnt += 1;
    }
}

public void logMsgAndTime(str msg,real startTime){
    real endTime = realTime()/1000.0;
    real elapsedTime = endTime - startTime;
    println("Time elapsed: <elapsedTime>s");
    println(msg);
}

public void writeClonesToJson(list[Clone] clones){
    loc jsonFile = |project://series2/clones.json|;
    writeJSON(jsonFile,clones);
}
