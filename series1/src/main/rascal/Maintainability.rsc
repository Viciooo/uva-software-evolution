module Maintainability

import Volume;
import UnitComplexity;
import UnitSize;
import Duplication;
import Coupling;
import UnitTesting;

import Utils;

import IO;

// We will omit the unit testing part, it is taken care of by the designated tools.

public int analisabilityLevel(int volume, int duplication, int unitSize){
    int analisability = (volume + duplication + unitSize) / 3;
    return analisability;
}

public int changeabilityLevel(int complexity, int duplication){
    int changability = (complexity + duplication) / 2;
    return changability;
}

public int testabilityLevel(int complexity, int unitSize){
    int testability = (complexity + unitSize) / 2;
    return testability;
}


public str maintainabilityRank(int volume, int duplication, int unitSize, int complexity){
    int maintainability = (
        analisabilityLevel(volume, duplication, unitSize) + 
        changeabilityLevel(complexity, duplication) +
        testabilityLevel(complexity, unitSize)
    ) / 3;

    str rank = mapLevelToRank(maintainability);
    return "Maintainability rank: <rank>";
}

public str analisabilityRank(int volume, int duplication, int unitSize){
    str rank = mapLevelToRank(analisabilityLevel(volume, duplication, unitSize));
    return "Analisability rank: <rank>";
}

public str changeabilityRank(int complexity, int duplication){
    str rank = mapLevelToRank(changeabilityLevel(complexity, duplication));
    return "Changeability rank: <rank>";
}

public str testabilityRank(int complexity, int unitSize){
    str rank = mapLevelToRank(testabilityLevel(complexity, unitSize));
    return "Testability rank: <rank>";
}

public void printAllMetrics(){
    int volume = volumeLevel();
    println(volumeRank());

    int duplication = duplicationLevel();
    println(duplicationRank());

    int unitSize = unitSizeLevel();
    println(unitSizeRank());

    int complexity = unitComplexityLevel();
    println(unitComplexityRank());

    println(maintainabilityRank(volume, duplication, unitSize, complexity));
    println(analisabilityRank(volume, duplication, unitSize));
    println(changeabilityRank(complexity, duplication));
    println(testabilityRank(complexity, unitSize));

    println(calculateCoupling());
    println(unitTestingAssertStatistics());
}

