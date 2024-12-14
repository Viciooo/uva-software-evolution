module DataTypes

data PotentialClone = potentialClone(str content,int startLine,int lastLine);

data CloneLoc = cloneLoc(loc locFile,str rawLines, int startLine,int lastLine);
data Clone = clone(str content,list[CloneLoc] cloneLocs,int size);
data LocationData = locationData(list[str] lines,str rawLines, list[int] indexes, loc location);
