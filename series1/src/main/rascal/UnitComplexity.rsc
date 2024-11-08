module UnitComplexity
import Utils;
import IO;
import List;
import Set;
import String;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Utils;
import util::Math;

private lrel[int, int] projectCyclomaticComplexityByMethod(){
    list[loc] classes = getClasses();
    complexities = [];
    for(loc class <- classes){
        ast = createAstFromFile(class, true);
        
        visit(ast) {
            case m:\method(_,_,_,_,_) : {
                complexities += <fileLoc(m@src), calculateMethodComplexity(m)>;
            }
            case c:\constructor(_,_,_,_) : {
                complexities += <fileLoc(c@src), calculateMethodComplexity(c)>;
            }
        }
    }

    return complexities;
}

private int calculateMethodComplexity(method){
    int result = 1;
    int doStmt = 0;
        visit (method) {
            case \if(_,_) : result += 1;
            case \if(_,_,_) : result += 1;
            case \case(_) : result += 1;
            case \do(_,_) : {
                result += 1;
                doStmt += 1;
            }
            case \while(_,_) : result += 1;
            case \for(_,_,_) : result += 1;
            case \for(_,_,_,_) : result += 1;
            case \foreach(_,_,_) : result += 1;
            case \catch(_,_): result += 1;
            case \conditional(_,_,_): result += 1;
            case \infix(_,"&&",_) : result += 1;
            case \infix(_,"||",_) : result += 1;
        }
        result -= doStmt; // do-while statement is counted as 2
        return result;
}

private tuple[real,real,real] calculateComplexityBuckets(){
    lrel[int,int] complexities = projectCyclomaticComplexityByMethod();
    real low = 0.0;
    real medium = 0.0;
    real high = 0.0;
    real veryHigh = 0.0;
    real totalLoc = 0.0;
    for(<locNum,c> <- complexities){
        if(c <= 10){
            low += locNum;
        } else if(c <= 20){
            medium += locNum;
        } else if(c <= 50){
            high += locNum;
        } else {
            veryHigh += locNum;
        }
    }
    totalLoc = low + medium + high + veryHigh;
    return <medium*100/totalLoc, high*100/totalLoc, veryHigh*100/totalLoc>;
}

public int unitComplexityLevel(){
    tuple[real,real,real] buckets = calculateComplexityBuckets();
    
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

public str unitComplexityRank(){
    str rank = mapLevelToRank(unitComplexityLevel());
    return "Unit complexity rank: " + rank;
}
