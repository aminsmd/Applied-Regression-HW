pwd
global project "/Users/amin/Documents/winter2021/AppRegLab/ps5/"
display "$project"

cd "${project}"
global output "${project}output/"
use for_ps5.dta, clear

global controls "zread1 dblack dhispanic dasian dother dhighcol dcolplus ageinmonth bw_oz books books2 dmage_30plus dmage_teen wksesl momwic"

codebook $controls

gen sample_ps5 = 0 
replace sample_ps5 = 1 if !mi(zmath1, zmath2, t2extern, dblack, dhighcol, ageinmonth, bw_oz, dfemale, books, dmage_30plus, wksesl, momwic, zread1)
tab sample_ps5

egen ext_mean = mean(t2extern)
gen highext = .
replace highext = 1 if (t2extern > ext_mean & t2extern != .)
replace highext = 0 if t2extern <= ext_mean
tab highext

reg highext zmath1 dfemale $controls if sample_ps5 == 1

predict yhat_highext

hist yhat_highext, percent ///
title("probability of high externalizing behavior at school-entry") ///
subtitle("predicted by fall-K math score and controls, using LPM") ///
xtitle("probability") ///
ytitle("percent of observations") ///
note("Data come from ECLS-K", span) ///
name(lpm, replace)


reg highext zmath1 $controls if (dfemale == 1 & sample_ps5 == 1)

reg highext zmath1 $controls if (dfemale == 0 & sample_ps5 == 1)

gen books2Xfemale = books2 * dfemale

global interactions "zmath1Xfemale-booksXfemale books2Xfemale dmage_30plusXfemale-momwicXfemale"

reg highext zmath1 dfemale $controls $interactions if sample_ps5 == 1
