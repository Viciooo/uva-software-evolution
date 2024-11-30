module Tests
import Utils;
import IO;
import UnitTesting;
import UnitComplexity;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Duplication;

test bool testFileLoc() {
    loc project = |project://series1/resources/CommandLine.java|;
    println(fileLoc(project));
    return fileLoc(project) == 73;
}

test bool testCountAsserts(){
    loc project = |project://series1/resources/TestThreads.java|;
    return countAsserts(fileContentLines(project)) == 5;
}

test bool testCalculateMethodComplexity(){
    loc project = |project://series1/resources/CommandLine.java|;
    ast = createAstFromFile(project, true);
    complexities = [];
    visit(ast) {
        case m:\method(_,_,_,_,_) : {
            complexities += <m.name, calculateMethodComplexity(m)>;
        }
        case c:\constructor(_,_,_,_) : {
            complexities += <c.name, calculateMethodComplexity(c)>;
        }
    }
    return complexities == [<"main",9>,<"printRS",7>];
}

test bool testCalculateDuplicates(){
    loc project = |project://series1/resources/CommandLine.java|;
    return calculateDuplicates(fileContentLines(project)) == 108;
}
