pwd
global project "/Users/amin/Documents/winter2021/AppRegLab/ps6/"
display "$project"

cd "${project}"
global output "${project}output/"
use for_ps6.dta, clear

global controls "zread1 dblack dhispanic dasian dother dhighcol dcolplus ageinmonth bw_oz books books2 dmage_30plus dmage_teen wksesl momwic"

global interactions "zmath1Xfemale-dcolplusXfemale"

codebook $controls

reg highext zmath1 dfemale $controls if sample_ps5 == 1

logit highext zmath1 dfemale $controls if sample_ps5 == 1

logit highext zmath1 dfemale $controls if sample_ps5 == 1, or

su zmath1

margins, at(zmath1=(-1 0 1)) atmeans

logit highext zmath1 dfemale $controls if sample_ps5 == 1

margins, dydx(zmath1) at(zmath1=(-1 0 1)) atmeans
