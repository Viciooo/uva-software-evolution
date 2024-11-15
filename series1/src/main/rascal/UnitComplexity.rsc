module UnitComplexity
import Utils;
import IO;
import List;
import Set;
import String;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Utils;

public lrel[int, int] projectCyclomaticComplexityByMethod(project){
    list[loc] classes = getClasses(project);
    complexities = [];
    logging = [];
    for(loc class <- classes){
        ast = createAstFromFile(class, true);
        
        visit(ast) {
            case m:\method(_,_,_,_,_) : {
                logging += <m.name, calculateMethodComplexity(m)>;
                complexities += <fileLoc(m@src), calculateMethodComplexity(m)>;
            }
            case c:\constructor(_,_,_,_) : {
                logging += <c.name, calculateMethodComplexity(c)>;
                complexities += <fileLoc(c@src), calculateMethodComplexity(c)>;
            }
        }
    }
    println(logging);
    return complexities;
}

public int calculateMethodComplexity(method){
    int result = 1;
    int doStmt = 0;
    set[loc] visited = {};
        visit (method) {
            case s:\if(_,_) :{
                 visited += s@src;
                 }
            case s:\if(_,_,_) :{visited += s@src;
                 }
            case s:\case(_) :{visited += s@src;
                 }
            case s:\defaultCase() :{visited += s@src;
                 }
            case s:\do(_,_) : {
                
                doStmt += 1;
                visited += s@src;
            }
            case s:\while(_,_) :{visited += s@src;
                 }
            case s:\for(_,_,_) :{visited += s@src;
                 }
            case s:\for(_,_,_,_) :{visited += s@src;
                 }
            case s:\foreach(_,_,_) :{visited += s@src;
                 }
            case s:\catch(_,_):{visited += s@src;
                 }
            case s:\conditional(_,_,_):{visited += s@src;
                 }
            case s:\infix(_,"&&",_) :{visited += s@src;
                 }
            case s:\infix(_,"||",_) :{visited += s@src;
                 }
        }
        result += size(visited);
        result -= doStmt; // do-while statement is counted as 2
        return result;
}

private tuple[real,real,real] calculateComplexityBuckets(project){
    lrel[int,int] complexities = projectCyclomaticComplexityByMethod(project);
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

public int unitComplexityLevel(project){
    tuple[real,real,real] buckets = calculateComplexityBuckets(project);
    
    real moderate = buckets[0];
    real high = buckets[1];
    real veryHigh = buckets[2];
    println("Moderate: <moderate>\nHigh:<high>\nVery high: <veryHigh>");
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

public void printUnitComplexityRank(int level){
    println("Unit complexity rank: <mapLevelToRank(level)>");
}
