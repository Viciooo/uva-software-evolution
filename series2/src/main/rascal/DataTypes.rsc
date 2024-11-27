module DataTypes

data CloneLoc = cloneLoc(loc locFile,int startLine,int lastLine);
data PotentialClone = potentialClone(str content,int startLine,int lastLine);
data Clone = clone(str content,list[CloneLoc] cloneLocs,int window);
data MethodData = methodData(list[str] lines,list[int] indexes, loc method);
