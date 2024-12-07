# Report

### Explanation of clone detection algorithm
**Description:**
**1.** *Data preperation phase* - Firstly we use AST model to extract methods from the project and normalise them, saving the results in the hashmap.
**2.** *First run* - We start looking for the clones of size 3 by using the moving window strategy. For each method we start from line 0 in the normalised content and take first 3 lines, saving them in the hashmap using hash of those lines as the key, as value we save 1. Then we move to the line 1 and do the same for lines 1,2,3,.... If the key already exists in the map we increment the value instead. After doing it for all the methods we remove records that have value of 1 - those are not clones. We will use the results of the first iteration for creating clones of size 4.
**3.** *Following runs* - We use *first iteration*, by trying to extend clones of size 3 into clones of size 4. For each clone family of size 3 we will try to take the next line.

**[3.1.]** All clone locations that can not be extended (either include last line of the method or have only single occurrence) are saved as final clones.
**[3.2]** All the other clone locations have occured at least 2 times which makes them into new clones of size+1. They are saved as a result of current iteration.
**[3.3]** After doing [**3.1**] and [**3.2**] for each clone family we check if any clones were found during *this iteration*. If not we finish the search. If any were found we save *this iteration* as *last iteration* - we will use it in the next run.
**[3.4]** Repeat [**3.1**], [**3.2**] and [**3.3**] untill no more clone families can be found.

**4.** *Removing subsumption* - we start by sorting the clones by descendingly by their number of lines. Then we check all smaller clones for containing in this clone. All with the content containing in the bigger clone are marked as deleted and will be ignored in future comparisons. We do the same for the next clone and any that follows it.

**Motivation:**
The final version of the algorithm underwent at least a dozen optimizations. Initially we started with treating all the iterations like *First run* described in point 2 of the *Description*, but it was extremely slow for the *hsqldb* project(~16min), detecting subsumption took 90% of the time because of the sheer number of redundant clone families found. We also did not narrow the search domain looking for clones of size **x+1** in the methods that did not have clones of size **x**.

We thought that our approach was valid for the **first run**, but we could detect next clones a lot faster then the initial one. We even thought for a moment that we could completely avoid checking for the subsumption thanks to the extension, but shortly realised that that did not protect us from subsumption in different methods.

**Reflection:**
Overall we were able to avoid subsumption in the same file which was extremely frequent and slowed us down. Using custom data types helped in keeping track of the flow of data and increased readability. 

We feel pretty happy about our final solution. After hours of work we were able to complete clone detection of:
- smallsql - in <3s
- hsqldb - in 152s
Tested on Mac M1 Pro

### The requirements your tool satisfies from the perspective of a maintainer

### The implementation of your visualization(s) and a critical reflection (positive and negative) that establishes to which extent the requirements have been satisfied by your visualizations

