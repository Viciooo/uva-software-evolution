module DataTypes

data CloneLoc = cloneLoc(loc locFile,str rawLines, int startLine,int lastLine);
data PotentialClone = potentialClone(str content,int startLine,int lastLine);
data Clone = clone(str content,list[CloneLoc] cloneLocs,int window);
data MethodData = methodData(list[str] lines,str rawLines, list[int] indexes, loc method);
