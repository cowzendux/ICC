#ICC

SPSS Python Extension function to calculate intra-class correlation and design effect

The function prints the ICC and design effect to the output window and also returns the ICC as the output of the function.

This and other SPSS Python Extension functions can be found at http://www.stat-help.com/python.html

##Usage
**ICC(outcome, cluster)**
* "outcome" is a string providing the name of the variable that you think is affected by the clustering. This argument is required.
* "cluster" is a string providing the name of the variable that defines the clusters. This argument is required.

##Example
**ICC("test_score", "classroom")**
* Assuming that test scores were assessed separately for different students, this would calculate the ICC and design effect of classroom on the test score.
