#ICC

SPSS Python Extension function to calculate intra-class correlation and design effect

The function prints the ICC and design effect to the output window and also returns the ICC as the output of the function.

This and other SPSS Python Extension functions can be found at http://www.stat-help.com/python.html

##Usage
**ICC(outcomeList, cluster)**
* "outcomeList" is a list of strings providing the names of the variables that you think is affected by the clustering. This needs to be a list (i.e., contained within brackets) even if you only want the ICC for one outcome. This argument is required.
* "cluster" is a string providing the name of the variable that defines the clusters. You can only identify a single cluster. This argument is required.

##Example
**ICC(["pretest_score", "posttest_score"], "classroom")**
* This would calculate the ICC and design effect of classroom on both the pretest score and the posttest score.
