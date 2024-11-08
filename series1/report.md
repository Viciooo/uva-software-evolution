1. Which metrics are used?
a) Volume: The overall volume of the source code influences the analysability of the system.
b) Complexity per unit: The complexity of source code units influences the system’s changeability and its testability.
c) Duplication: The degree of source code duplication (also called code cloning) influences analysability and change ability.
d) Unit size: The size of units influences their analysability and testability and therefore of the system as a whole.
e) Unit testing: The degree of unit testing influences the
analysability, stability, and testability of the system.

2. How are these metrics computed?
a) Volume: They use a simple line of code metric (LOC), which counts all lines of source code that are not comment or blank lines and the Programming Languages Table of Software Productivity Research LLC, since it differs across the languages.
We assign a rank based on that table:

| Rank | MY         | Java       | Cobol         | PL/SQL      |
|------|------------|------------|---------------|-------------|
| ++   | 0 – 8      | 0 – 66     | 0 – 131       | 0 – 46      |
| +    | 8 – 30     | 66 – 246   | 131 – 491     | 46 – 173    |
| o    | 30 – 80    | 246 – 665  | 491 – 1,310   | 173 – 461   |
| -    | 80 – 160   | 655 – 1,310| 1,310 – 2,621 | 461 – 922   |
| --   | > 160      | > 1,310    | > 2,621       | > 922       |

All we need to do is compute the LOC(excluding empty lines) and assign one of 5 ranks.

b)Complexity per unit: Cyclomatic complexity per unit is calculated for each unit. Each units score is then mapped to one of the four levels of complexity:

| CC   | Risk evaluation                 |
|------|---------------------------------|
| 1-10 | simple, without much risk       |
| 11-20| more complex, moderate risk     |
| 21-50| complex, high risk              |
| > 50 | untestable, very high risk      |


Finally we count the LOCs of each unit and map them to one of 4 buckets: moderate, high and very high(disregarding the simple without risk). We assign a rank based on that table:

| Rank | Moderate | High  | Very High |
|------|----------|-------|-----------|
| ++   | 25%      | 0%    | 0%        |
| +    | 30%      | 5%    | 0%        |
| o    | 40%      | 10%   | 0%        |
| -    | 50%      | 15%   | 5%        |
| --   | -        | -     | -         |


c)Duplication: We need to ignore the leading spaces. Each block of 6 lines that is present more then once is a dulicate. We go over the codebase using the moving window of 6 lines and check if it is a duplicate. At the end we should have number of lines duplicated and total number of lines. We assign a rank based on that table:

| Rank | Duplication |
|------|-------------|
| ++   | 0 – 3%      |
| +    | 3 – 5%      |
| o    | 5 – 10%     |
| -    | 10 – 20%    |
| --   | 20 – 100%   |

d)Unit size: They said that the LOC is used and it is similiar to calculating complexity per unit, so due to the lack of detail there is some guess work to be done.

My interpretation: The lines of code are counted for each unit and it is put in one of the four categories and then based on the percantage of code in each bucket the rank is assigned. The details were left off.

e)Unit testing: They measure the code coverage using one of the language specific tools and assign a rank based on that table:

| Rank | Unit Test Coverage |
|------|---------------------|
| ++   | 95 – 100%           |
| +    | 80 – 95%            |
| o    | 60 – 80%            |
| -    | 20 – 60%            |
| --   | 0 – 20%             |

Additionally they validate that the tests have assert statement. No fixed rate for assert statement was provided and it was described as a manuall process to validate the assigned rank.

3. How well do these metrics indicate what we really want to know about these systems and how can we judge that?



4. How can we improve any of the above?


Calculate at least the following metrics:
- Volume,
- Unit Size,
- Unit Complexity,
- Duplication.

Calculate scores for at least the following maintainability aspects based on the
SIG model:
- Maintainability (overall),
- Analysability,
- Changeability,
- Testability.
