module Coupling

import Utils;
import List;
import Set;
import String;
import lang::java::m3::Core;
import lang::java::m3::AST;

public map[str, value] calculateCBO() {
    list[loc] classes = getClasses();
    classDependencies = [];

    for (loc file <- classes) {
        int dependencies = calculateClassDepencies(file);
        classDependencies += <file.path, dependencies>;
    }

    list[int] cboValues = [];
    for (<_, dependencies> <- classDependencies) {
        cboValues += dependencies;
    };

    int totalClasses = size(classDependencies);
    int totalDependency = sum(cboValues);
    int maxDependency = max(cboValues);
    list[value] mostCoupledClasses = [className | <className, dependencies> <- classDependencies, dependencies == maxDependency];

    return (
        "averageCBO": totalDependency / totalClasses,
        "maxCBO": maxDependency,
        "mostCoupledClasses": mostCoupledClasses
    );
}

public int calculateClassDepencies(loc fileLoc) {
    M3 model = getModelFromFile(fileLoc);
    str projectName = extractRootDirectory(fileLoc.path);
    list[str] result = [];

    for (<_, to> <- model.typeDependency) {
        if(contains(to.path, projectName) && !contains(to.path, fileLoc.path)) {
            result += to.path;
        }
    }
    return size(toSet(result));
}

private str extractRootDirectory(str input) {
    list[str] parts = split("/", input);
    if (size(parts) > 1) {
        return parts[1];
    }
    return "";
}
