/********************************************************************************
 PS 8
 Programmer: Paul Yoo, pyyoo@uci.edu 
 
 Note: this do file builds on the work of previous regression TAs
********************************************************************************/
 
global project "/Users/amin/Documents/winter2021/AppRegLab/ps8/"
global data "${project}data/"
global output "${project}output/"

use "${data}for_ps8.dta", clear

global controls dblack dhispanic dasian dother age dfemale bw_oz books dmage_30plus dmage_teen wksesl momwic dhighcol dcolplus   


*------------------------------------------------------------------------------
* analyze our sample (update this a little)
*------------------------------------------------------------------------------

est clear 

** Level Model

*simple
reg zach4 ztimeacadem2 if sample_ps9==1
est store s1

*with control
reg zach4 ztimeacadem2 $controls if sample_ps9==1
est store s2

*with control and fixed effect
areg zach4 ztimeacadem2 $controls if sample_ps9==1, absorb(school2)
est store s3 

*with control and fixed effect and cluster s.e. 
areg zach4 ztimeacadem2 $controls if sample_ps9==1, absorb(school2) cluster(school2)
est store s4 

** Simple Change
gen ach_change= zach4 - zach2
label var ach_change "Spring K to 1st Achievement"

*simple
reg ach_change ztimeacadem2 if sample_ps9==1
est store c1

*with control
reg ach_change ztimeacadem2 $controls if sample_ps9==1
est store c2

*with control and fix effect
areg ach_change ztimeacadem2 $controls if sample_ps9==1, absorb(school2)
est store c3

*with control and fixed effect and cluster s.e. 
areg ach_change ztimeacadem2 $controls if sample_ps9==1, absorb(school2) cluster(school2)
est store c4 


** Resid Change
*simple
reg zach4 ztimeacadem2 zach2 if sample_ps9==1
est store r1

*with control
reg zach4 ztimeacadem2 zach2 $controls if sample_ps9==1
est store r2

*with control and fix effect
areg zach4 ztimeacadem2 zach2 $controls if sample_ps9==1, absorb(school2)
est store r3

*with control and fixed effect and cluster s.e. 
areg zach4 ztimeacadem2 zach2 $controls if sample_ps9==1, absorb(school2) cluster(school2)
est store r4

esttab s* c* r* using "${output}ps8_t1.csv", b(3) se(3) r2 nogaps label replace

// My Experiment

gen chtime = ztimeacadem4 - ztimeacadem2

reg ach_change chtime $controls if sample_ps9==1

areg ach_change chtime $controls if sample_ps9==1, absorb(school2)

areg ach_change chtime $controls b1yrskin if sample_ps9==1, absorb(school2)

areg ach_change ztimeacadem2 $controls if sample_ps9==1, absorb(school2) cluster(school2)

areg ach_change ztimeacadem2 $controls b1yrskin if sample_ps9==1, absorb(school2) cluster(school2)

gen years_kin_more_10 = b1yrskin > 10

gen years_kin_10Xztimeacadem2 = ztimeacadem2 * years_kin_more_10

areg ach_change ztimeacadem2 years_kin_more_10 years_kin_10Xztimeacadem2 $controls b1yrskin if sample_ps9==1, absorb(school2) cluster(school2)







