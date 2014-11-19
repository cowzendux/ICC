* Determine ICC & Design effect
* Written by Jamie DeCoster

* This function takes two strings as arguments.
* The first is a list of outcome variables. Even if you have only one outcome, 
* you should put it in a list.
* The second is the name of the cluster variable for which you want
* the ICC and design effect. You can only specify a single cluster variable.
* The function prints the ICC and design effect to the output window
* and also returns a list of the ICCs.

*********
* Version History
*********
* 2012-07-22 Created
* 2014-11-14 Suppressed calculation messages
    Used SPSS tables for output
* 2014-11-14a Put statistics in columns
* 2014-11-14b Allowed multiple outcomes
* 2014-11-19 Corrected error from failing to import CellText

set printback = off.

begin program python.
import spss, spssaux
from spss import CellText

def ICC(outcomeList, cluster):
   submitstring = """OMS /SELECT ALL EXCEPT = [WARNINGS] 
    /DESTINATION VIEWER = NO 
    /TAG = 'NoJunk'."""
   spss.Submit(submitstring)

   bvarList = []
   wvarList = []
   numgroupsList = []
   casesperclusterList = []
   iccList = []
   designeffectList = []

   for outcome in outcomeList:
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

# Append stats to list
       bvarList.append(bvar)
       wvarList.append(wvar)
       numgroupsList.append(numgroups)
       casesperclusterList.append(casespercluster)
       iccList.append(icc)
       designeffectList.append(designeffect)

   submitstring = """OMSEND TAG = 'NoJunk'."""
   spss.Submit(submitstring)

# Put results into a pivot table
   spss.StartProcedure("ICC")
   table = spss.BasePivotTable(outcome + " clustered by " + cluster,
"OMS table subtype")
   coldim1=table.Append(spss.Dimension.Place.column,"cluster = " + cluster)
   rowdim1=table.Append(spss.Dimension.Place.row,"outcome")

   rowvarCatlist = []
   for var in outcomeList:
        t = CellText.String(var)
        rowvarCatlist.append(t)

   statCatlist = [CellText.String("Between-cluster variance"),
CellText.String("Within-cluster variance"),
CellText.String("Number of clusters"),
CellText.String("Average number of cases per cluster"),
CellText.String("ICC"),
CellText.String("Design effect")]
   table.SetCategories(rowdim1, rowvarCatlist) 
   table.SetCategories(coldim1, statCatlist)
   
   for count in range(len(outcomeList)):
        o = outcomeList[count]
        table[(CellText.String("Between-cluster variance"),
CellText.String(o))] = CellText.Number(bvarList[count], 
spss.FormatSpec.GeneralStat)
        table[(CellText.String("Within-cluster variance"),
CellText.String(o))] = CellText.Number(wvarList[count], 
spss.FormatSpec.GeneralStat)
        table[(CellText.String("Number of clusters"),
CellText.String(o))] = CellText.Number(numgroupsList[count], 
spss.FormatSpec.Count)
        table[(CellText.String("Average number of cases per cluster"),
CellText.String(o))] = CellText.Number(casesperclusterList[count], 
spss.FormatSpec.GeneralStat)
        table[(CellText.String("ICC"),
CellText.String(o))] = CellText.Number(iccList[count], 
spss.FormatSpec.GeneralStat)
        table[(CellText.String("Design effect"),
CellText.String(o))] = CellText.Number(designeffectList[count], 
spss.FormatSpec.GeneralStat)
   spss.EndProcedure()

   return iccList

end program python.

set printback = on.
