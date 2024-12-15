module Volume
import Utils;
import IO;
import List;

import lang::java::m3::Core;
import lang::java::m3::AST;

public int volumeLevel(project){
    int locNum = 0;
    for (class <- getClasses(project)) {
        locNum += fileLoc(class);
    }
    println("Total lines of code: <locNum/1000> KLOC");
    
    if(locNum <= 66000){
        return 5;
    } else if(locNum <= 246000){
        return 4;
    } else if(locNum <= 665000){
        return 4;
    } else if(locNum < 665000){
        return 3;
    } else if(locNum < 1310000){
        return 2;
    } else {
        return 1;
    }
}

public void printVolumeRank(int level){
    println("Volume rank: <mapLevelToRank(level)>");
}
