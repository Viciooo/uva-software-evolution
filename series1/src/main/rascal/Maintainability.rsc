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


public void printMaintainabilityRank(int volume, int duplication, int unitSize, int complexity){
    int rank = (
        analisabilityLevel(volume, duplication, unitSize) + 
        changeabilityLevel(complexity, duplication) +
        testabilityLevel(complexity, unitSize)
    ) / 3;
    println("Maintainability rank: <mapLevelToRank(rank)>");
}

public void printAnalisabilityRank(int volume, int duplication, int unitSize){
    str rank = mapLevelToRank(analisabilityLevel(volume, duplication, unitSize));
    println("Analisability rank: <rank>");
}

public void printChangeabilityRank(int complexity, int duplication){
    str rank = mapLevelToRank(changeabilityLevel(complexity, duplication));
    println("Changeability rank: <rank>");
}

public void printTestabilityRank(int complexity, int unitSize){
    str rank = mapLevelToRank(testabilityLevel(complexity, unitSize));
    println("Testability rank: <rank>");
}

public void printAllMetrics(loc project){
    println("---------------VOLUME---------------");
    int volume = volumeLevel(project);
    printVolumeRank(volume);
    println("---------------VOLUME END---------------");

    println("---------------DUPLICATION---------------");
    int duplication = duplicationLevel(project);
    printDuplicationRank(duplication);
    println("---------------DUPLICATION END---------------");

    println("---------------UNIT SIZE---------------");
    int unitSize = unitSizeLevel(project);
    printUnitSizeRank(unitSize);
    println("---------------UNIT SIZE END---------------");

    println("---------------UNIT COMPLEXITY---------------");
    int complexity = unitComplexityLevel(project);
    printUnitComplexityRank(complexity);
    println("---------------UNIT COMPLEXITY END---------------");

    println("---------------MAINTAINABILITY---------------");
    printMaintainabilityRank(volume, duplication, unitSize, complexity);
    println("---------------MAINTAINABILITY END---------------");

    println("---------------ANALISABILITY---------------");
    printAnalisabilityRank(volume, duplication, unitSize);
    println("---------------ANALISABILITY END---------------");

    println("---------------CHANGEABILITY---------------");
    printChangeabilityRank(complexity, duplication);
    println("---------------CHANGEABILITY END---------------");

    println("---------------TESTABILITY---------------");
    printTestabilityRank(complexity, unitSize);
    println("---------------TESTABILITY END---------------");

    println("---------------COUPLING---------------");
    calculateCoupling(project);
    println("---------------COUPLING END---------------");

    println("---------------UNIT TESTING---------------");
    unitTestingAssertStatistics(project);
    println("---------------UNIT TESTING END---------------");
}

