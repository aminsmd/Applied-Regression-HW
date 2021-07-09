pwd
global project "/Users/amin/Documents/winter2021/AppRegLab/ps7/"
display "$project"

cd "${project}"
global output "${project}output/"
use for_ps7.dta, clear

tab p1primpk, m
tab p1primpk, m nolab

// adjust missing 
replace p1primpk=. if p1primpk==-9
tab p1primpk, nolab mi 

codebook p1primpk
gen ctr_care=0 if p1primpk!=.
replace ctr_care=1 if p1primpk==6|p1primpk==7
tab ctr_care, mi

tab p1primpk ctr_care, mi

tab cregion, gen(region)
rename region1 dnortheast
rename region2 dmidwest
rename region3 dsouth
rename region4 dwest

global controls "dmidwest dsouth dwest dcity drural dblack dhispanic dasian dother dfemale"
	*dnortheast, male, dtown, and dwhite as reference group

sum $controls dnortheast dtown dwhite

// Sample

gen sample_ps7 = 0
replace sample_ps7=1 if !mi(dwhite, dfemale, dcity, dmidwest, wksesl, ctr_care) 
tab sample_ps7, m

save "ps7_start.dta", replace

keep if sample_ps7==1

//logit and lpm comparison

logit ctr_care wksesl $controls

margins, dydx(wksesl) atmeans
 
predict care_logit 

regress ctr_care wksesl $controls
predict care_lpm

scatter care_lpm care_logit || function y = x

scatter care_lpm wksesl || scatter care_logit wksesl


twoway (scatter ctr_care wksesl) (lfit care_logit wksesl), name(g_2c1, replace)
twoway (scatter ctr_care wksesl) (lfit care_lpm wksesl), name(g_2c2, replace)

reg care_logit wksesl
reg care_lpm wksesl

// ses_bin

gen ses_bin= .20*floor(wksesl/.20)
hist ses_bin

collapse (mean)ctr_care (mean)care_lpm (mean)care_logit , by(ses_bin)

browse

// SES_bin - predictions scatter 

twoway (scatter ctr_care ses_bin, mcolor(black)) /// 
(lfit care_logit ses_bin, lcolor(black)), /// 
ytitle("preschool enrollment (likelihood)") ylab(-.5(.25)1) ///
xtitle("Socioeconomic Status") xlab(-5(1)3) /// 
title("Relation between SES and preschool enrollment", ///
size(4) justification(center) color(black)) legend(off) graphregion(fcolor(white)) /// 
plotregion(fcolor(white)) ///
name(binscatter1, replace)

twoway (scatter ctr_care ses_bin, mcolor(black)) /// 
(lfit care_lpm ses_bin, lcolor(black)), /// 
ytitle("preschool enrollment (likelihood)") ylab(-.5(.25)1) ///
xtitle("Socioeconomic Status") xlab(-5(1)3) /// 
title("Relation between SES and preschool enrollment", ///
size(4) justification(center) color(black)) legend(off) graphregion(fcolor(white)) /// 
plotregion(fcolor(white)) ///
name(binscatter2, replace)

use "ps7_start.dta", replace

keep if sample_ps7==1

// higherses SPline prediction

gen higherses = .
replace higherses = 1 if (wksesl >= -1 & wksesl != .)
replace higherses = 0 if wksesl < -1
tab higherses

gen highersesXses = wksesl * higherses

global interactions

foreach var of varlist dmidwest dsouth dwest dcity drural dblack dhispanic dasian dother dfemale{
	gen highersesX`var' = higherses * `var'
	global interactions "$interactions highersesX`var'"
}

regress ctr_care wksesl higherses highersesXses $controls $interactions
predict care_spline

gen ses_bin = .20 * floor(wksesl/.20)

collapse (mean)care_spline (mean)ctr_care, by(ses_bin higherses)

browse

//colorpalette9 s1

twoway (scatter ctr_care ses_bin if higherses==0, mcolor(purple)) /// 
(scatter ctr_care ses_bin if higherses==1, mcolor(red)) /// 
(lfit care_spline ses_bin if higherses==0, lcolor(purple)) ///
(lfit care_spline ses_bin if higherses==1, lcolor(red)), /// 
ytitle("preschool enrollment (likelihood)") ylab(0(.25)1) ///
xtitle("Socioeconomic Status") xlab(-5(1)3) /// 
title("Relation between SES and preschool enrollment", ///
size(4) justification(center) color(black)) legend(label(1 "low SES") label(2 "higher SES") ///
order(1 2)) graphregion(fcolor(white)) ///
plotregion(fcolor(white)) ///
name(spline, replace)






