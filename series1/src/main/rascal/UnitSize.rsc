module UnitSize

import Utils;
import IO;
import List;
import Set;
import String;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::Math;

// Since there were no clear guidelines on the size of methods, we created our own based on:
// https://dzone.com/articles/rule-30-%E2%80%93-when-method-class-or

// Citing Bob Martin:
//“This is not an assertion that I can justify. I can't produce any references to research that shows that very small functions are better.”

// We will use the following guidelines:
// Risk evaluation
// 0-20 simple, without much risk
// 21-50 more complex, moderate risk
// 51-100 complex, high risk
// >100 untestable, very high risk

// Rank classification:
// rank moderate high very high
// ++ 25% 0% 0%
// + 30% 5% 0%
// o 40% 10% 0%
// - 50% 15% 5%
// -- - - -


private list[int] calculateUnitSize(){
    list[loc] methods = getMethods();
    list[int] sizes = [];
    for(loc method <- methods){
        sizes += [fileLoc(method)];
    };
    return sizes;
}

private tuple[real,real,real] calculateUnitSizeBuckets(){
    list[int] unitSizes = calculateUnitSize();
    real low = 0.0;
    real medium = 0.0;
    real high = 0.0;
    real veryHigh = 0.0;
    real totalLoc = 0.0;
    for(unitSize <- unitSizes){
        if(unitSize <= 20){
            low += unitSize;
        } else if(unitSize <= 50){
            medium += unitSize;
        } else if(unitSize <= 100){
            high += unitSize;
        } else {
            veryHigh += unitSize;
        }
    }
    totalLoc = low + medium + high + veryHigh;
    return <medium*100/totalLoc, high*100/totalLoc, veryHigh*100/totalLoc>;
}

public int unitSizeLevel(){
    tuple[real,real,real] buckets = calculateUnitSizeBuckets();
    
    real moderate = buckets[0];
    real high = buckets[1];
    real veryHigh = buckets[2];

    if(moderate <= 25.0 && high <= 0.0 && veryHigh <= 0.0){
        return 5;
    }else if(moderate <= 30.0 && high <= 5.0 && veryHigh <= 0.0){
        return 4;
    }else if(moderate <= 40.0 && high <= 10.0 && veryHigh <= 0.0){
        return 3;
    }else if(moderate <= 50.0 && high <= 15.0 && veryHigh <= 5.0){
        return 2;
    }else{
        return 1;
    }
}

public str unitSizeRank(){
    str rank = mapLevelToRank(unitSizeLevel());
    return "Unit size rank: <rank>";
}
