* Determine ICC & Design effect
* Written by Jamie DeCoster

* This function takes two strings as arguments.
* The first is the name of the outcome variable.
* The second is the name of the cluster variable for which you want
* the ICC and design effect.
* The function prints the ICC and design effect to the output window
* and also returns the ICC.

*********
* Version History
*********
* 2012-07-22 Created

set printback = off.

begin program python.
import spss, spssaux

def ICC(outcome, cluster):
#   ICC = between variance / (within variance + between variance)
   cmd = """MIXED %s
  /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, 
    ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
  /FIXED=| SSTYPE(3)
  /METHOD=REML
  /RANDOM=INTERCEPT | SUBJECT(%s) COVTYPE(VC).
""" %(outcome, cluster)
   handle,failcode=spssaux.CreateXMLOutput(
		cmd,
		omsid="Mixed",
		subtype="Covariance Parameter Estimates",
		visible=False)
   result=spssaux.GetValuesFromXMLWorkspace(
		handle,
		tableSubtype="Covariance Parameter Estimates",
		cellAttrib="text")
   bvar = float(result[2])
   wvar = float(result[0])
   icc = float(bvar/(bvar + wvar))
   
# Design effect = 1 + (ICC * (# of observations per cluster - 1))
# Need to determine the total number of clusters

   cmd = """FREQUENCIES VARIABLES=%s
  /ORDER=ANALYSIS.
""" %(cluster)
   handle,failcode=spssaux.CreateXMLOutput(
		cmd,
		omsid="Frequencies",
		subtype="Frequencies",
		visible=False)
   result=spssaux.GetValuesFromXMLWorkspace(
  handle,
		tableSubtype="Frequencies",
		cellAttrib="text")
   numgroups = (len(result)-3)/4
   casecount=spss.GetCaseCount()
   casespercluster = casecount/float(numgroups)
   designeffect = 1 + icc*(casespercluster - 1) 
   
   print "********"
   print "Outcome = " + outcome
   print "Cluster variable = " + cluster
   print "Between-cluster variance = " + str(bvar)
   print "Within-cluster variance = " + str(wvar)
   print "Number of clusters = " + str(numgroups)
   print "Average number of cases per cluster = " + str(casespercluster)
   print "ICC = " + str(icc)
   print "Design effect = " + str(designeffect)
   print "********"
   return icc

end program python.

set printback = on.
