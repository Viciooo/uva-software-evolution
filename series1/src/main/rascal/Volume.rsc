module Volume
import Utils;
import IO;
import List;

import lang::java::m3::Core;
import lang::java::m3::AST;

public int volumeLevel(){
    int locNum = 0;
    for (class <- getClasses()) {
        locNum += fileLoc(class);
    }

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

public str volumeRank(){
    str rank = mapLevelToRank(volumeLevel());
    return "Volume rank: <rank>";
}
