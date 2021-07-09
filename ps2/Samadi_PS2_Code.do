pwd
global project "/Users/amin/Documents/winter2021/AppRegLab/ps2"
display "$project"

cd "${project}"
use for_ps2.dta, clear

***************************Q2******************

display "math"
forvalues i = 1(1)7 {
	display "`i'"
	tab math`i' if math`i' < 0
}

display "read"
forvalues i = 1(1)7 {
	display "`i'"
	tab read`i' if read`i' < 0
}

display "general knowledge"
forvalues i = 1(1)4 {
	display "`i'"
	tab genknow`i' if genknow`i' < 0
}

display "science"
forvalues i = 5(1)7 {
	display "`i'"
	tab science`i' if science`i' < 0
}



replace read1 = . if read1 < 0
replace read2 = . if read2 < 0
replace math1 = . if math1 < 0
replace math2 = . if math2 < 0
replace genknow1 = . if genknow1 < 0
replace genknow2 = . if genknow2 < 0

foreach var of varlist read3-science7{
	replace `var' = . if `var' < 0
}

su math4

codebook gender
codebook race
lookfor ses
codebook wksesq5

su read3 if race == 2 & gender == 2 & wksesq5 == 4

sum science7 if wksesq5 == 1, detail

***************************Q3******************

scatter read1 read2

corr read1 read2

reg read2 read1

scatter math2 read1

corr math2 read1

corr math1 read2 if gender == 1
corr math1 read2 if gender == 2

lookfor ses

corr read1 wksesl

forvalues i=1(1)5 {
	display "SES `i'"
	reg read1 wksesl if wksesq5 == `i'
}

scatter read1 wksesl if wksesq5 == 1 || scatter read1 wksesl if wksesq5 == 2 || scatter read1 wksesl if wksesq5 == 3 || scatter read1 wksesl if wksesq5 == 4 || scatter read1 wksesl if wksesq5 == 5 || lfit read1 wksesl if wksesq5 == 1 || lfit read1 wksesl if wksesq5 == 2 || lfit read1 wksesl if wksesq5 == 3 || lfit read1 wksesl if wksesq5 == 4 || lfit read1 wksesl if wksesq5 == 5

*************************Q4**********************

lookfor lunch

reg read2 read1

reg read2 read1 s2kflnch

reg read2 read1 wksesl

corr wksesl read1

************************Q5************************

replace c1r4rpb3 = . if c1r4rpb3 < 0

corr read1 c1r4rpb3

replace c1r4mpb8 = . if c1r4mpb8 < 0

corr read1 c1r4mpb8


save week2hw_clean.dta, replace























