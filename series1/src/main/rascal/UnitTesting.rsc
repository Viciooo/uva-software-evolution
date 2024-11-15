module UnitTesting
import IO;
import Utils;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Map;
import util::Math;
import analysis::statistics::Descriptive;
import String;


public void unitTestingAssertStatistics(project){
    list[loc] methods = getMethods(project);
    list[loc] methodsWithTest = [m | m <- methods, contains(m.file, "test")];
    list[int] assertCounts = sort([countAsserts(fileContentLines(m)) | m <- methodsWithTest]);
    real meanAsserts = mean(assertCounts);
    real medianAsserts = median(assertCounts);
    println("Mean asserts per test method: <meanAsserts>");
    println("Median asserts per test method: <medianAsserts>");
    tuple[int,int,int] q = quartiles(assertCounts);
    println("25% of test functions have \<= <q[0]> asserts");
    println("50% of test functions have \<= <q[1]> asserts");
    println("75% of test functions have \<= <q[2]> asserts");

}

public int countAsserts(list[str] textContent){
    int counter = 0;
    for(l <- textContent){
        if(contains(l, "assert")) counter += 1;
    }
    return counter;
}

private tuple[int,int,int] quartiles(list[int] values){
    int q1 = percentile(values, 25);
    int q2 = percentile(values, 50);
    int q3 = percentile(values, 75);
    return <q1, q2, q3>;
}

