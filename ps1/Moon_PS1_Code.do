/********************************************************************************
Problem set 1
Youngsun Moon
********************************************************************************/


**************************************Q1**************************************
pwd
global project "/Users/amin/Documents/winter2021/AppRegLab"
display "$project"

cd "${project}"
use for_ps1.dta, clear


**************************************Q2**************************************
desc
//a. 21,409 observations
//b. 307 variables

lookfor race
tab race
/*c.  HISPANIC, RACE SPECIFIED  8.59%
HISPANIC, RACE NOT SPECIFIED 9.28% 
Total 17.87% */

tab race gender, row
//d. 5,703

lookfor age
codebook age
//e. mean 5.70068, std .36215

codebook gender
codebook race
su age if gender==1 & race==2
//f. mean 5.693381, std .3705138 

su age if gender==2 & race==5
//g. mean 5.59979, std .3285002 

su age
list childid if gender==2 & race==5 & age<4.6
//h. 1163005C


**************************************Q3**************************************
lookfor ses
su wksesl  
//a. mean .005461 std .8031039  

su wksesl if wksesq5==1
su wksesl if wksesq5==2
su wksesl if wksesq5==3
su wksesl if wksesq5==4
su wksesl if wksesq5==5

bysort wksesq5: su wksesl

/*b. Q1: -4.75 -.64
Q2: -.64 -.31
Q3: -.31 .06
Q4:  .06 .62
Q5:  .62 2.75 */

gen dses1=.
replace dses1=0 if wksesq5!=1
replace dses1=1 if wksesq5==1
tab dses1 wksesq5, m

gen dses2=.
replace dses2=0 if wksesq5!=2
replace dses2=1 if wksesq5==2
tab dses2 wksesq5, m

gen dses3=.
replace dses3=0 if wksesq5!=3
replace dses3=1 if wksesq5==3
tab dses3 wksesq5, m

gen dses4=. 
replace dses4=0 if wksesq5!=4
replace dses4=1 if wksesq5==4
tab dses4 wksesq5, m

gen dses5=.
replace dses5=0 if wksesq5!=5
replace dses5=1 if wksesq5==5
tab dses5 wksesq5, m

//c. code above
//d. 3,973

tab wksesq5 if gender==1 & race==1
tab dses2 if gender==1 & race==1
//e. 1,078


**************************************Q4**************************************
hist read1, name(read1, replace)
hist math1, name(math1, replace)
//a.

twoway (kdensity read1), name(read1, replace)
twoway (kdensity math1), name(math1, replace)
//b.

ttest read1, by(gender)
//d. The results of a two-sample t-test demonstrated that on average, females (M=35.85, SD=10.08) scored statistically significantly higher compared to males (M=34.60, SD=10.28) on the reading test they took in kindergarten, t(17619) = -8.11, p<.001. In general, we could say the females did better on their reading test than males in kindergarten level.

replace race=. if race==-9
anova read1 race
oneway read1 race, tab
//e. A one-way ANOVA was conducted to examine how students of different race generally scored on the reading test in kindergarten. The results of the ANOVA showed a significant difference in the reading test scores across race, F(7, 17583) = 124.18, p<.001.

browse math1 math2 math3 math4 math5 math6 math7
//OR
codebook math1 if math1<0
codebook math7 if math7<0
/*f. Wave 1-4: NOT APPLICABLE, NOT ASCERTAINED
Wave 5-7: NOT ASCERTAINED */

save for_lab2.dta, replace












