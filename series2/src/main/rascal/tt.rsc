module tt

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Utils;
import List;
import Set;

public list[loc] getRelevantLocations(loc sourceLocation) {
    list[loc] files = toList(files(createM3FromDirectory(sourceLocation)));
    results = [];
    println(files);
    for(loc class <- files){
        ast = createAstFromFile(class, true);
        
        visit(ast) {
            case d:\enum(_,_,_,_,_) : {
                results += d@src;
            }
            case d:\interface(_,_,_,_,_,_) : {
                results += d@src;
            }
            case d:\constructor(_,_,_,_,_) : {
                results += d@src;
            }
            case d:\initializer(_,_) : {
                results += d@src;
            }
            case d:\method(_,_,_,_,_,_,_) : {
                results += d@src;
            }
            case d:\method(_,_,_,_,_,_) : {
                results += d@src;
            }
        }
    }
    return results;
}
