module Main
import TypeIClone;
import IO;

void main(loc project, list[str] excludedPaths,int smallestClone) {
    findClones(project,smallestClone,excludedPaths);
}
