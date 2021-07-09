/********************************************************************************
 Lab 5 + Lab 6
 Purpose: binary outcomes, lpm, logits, and logistics. 
 Programmer: Paul Yoo, pyyoo@uci.edu 
 
 Note: this do file builds on the work of previous regression TAs
********************************************************************************/

global project "C:\Users\Jee Hyung Park\Dropbox\UCI Regression class\2021\Labs and Problem sets\"
global data "${project}data\"
global output "${project}output\"

* load data  
use "${data}for_lab5.dta", clear

// !! EXAM NEXT WEEK !! 
// VERY VERY IMPORTANT: For the exam, your writing/language must be clear, complete, and appropriate to the analysis presented. 
// FOR PS 5, you will do work on LPM (easy), then for PS 6, you will work on logits and margins (less easy)
// we cover both in this lab 

*-------------------------------------------------------------------------*
* Questions from last week? 
*-------------------------------------------------------------------------*
/* last week: tests, interactions
 

			Q: Any questions from previous week?

*/

/*-------------------------------------------------------------------------*
RQ for lab: predicting attrition in ECLS-K at spring of first grade (wave 4) using age, gender, ethnicity, reading and math score, and urbanicity in at fall-k. 
*-------------------------------------------------------------------------*/
// let's get through this section within 10 minutes 

*** First, let's do some checking and cleaning: predictor variables

* sum continuous variables
sum age zread1 zmath1

* tab categorical variables
foreach var in  dfemale dblack dhispanic dasian dother kurban_r {
	tab `var', mi
} 
//have missing but already coded as .

*generate dummies for urbanicity (this time let's not collapse categories)
tab kurban_r
tab kurban_r, nolab

tab kurban_r, gen(tmp)
desc
rename tmp1 dcity 
rename tmp2 dtown 
rename tmp3 drural 
// did this handle the missings correctly? 

tab1 kurban_r dcity dtown drural, missing //tab1 is more condensed input for multiple tab
tab kurban_r dcity, m

* let's assign these to a global 
global predictors "age dfemale dblack dhispanic dasian dother zread1 zmath1 dcity drural" 
// Q: which dummies did we leave out? 
// Q: who is in our reference group if we regressed outcome on all of these variables? 
// Q: are these two questions the same? 
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP 
 
// we left out white, male, living in suburb (URBAN FRINGE AND LARGE TOWN) as reference/omitted/comparison group
// these two questions are not the same 
// the reference is something with 0's on all of these variables 
	
* generate analysis sample indicator 
gen sample_lab5=.
replace sample_lab5=1 if age!=. & dfemale!=. & dblack!=. & zread1!=. & zmath1!=. & dcity!=. 
//no need to add(doesn't hurt to add either): dhispanic!=. & dasian!=. & dother!=. & drural!=.
//can you explain why? 

tab sample_lab5 // N=17555
// Q: do I need a zero? 

		
* generate OUTCOME variable (name it attrit)
// we are defining attrition (dropping out of sample) at wave 4 as those who had missing on 
// assessment (simply use read4) AND parent survey (p4learn) AND teacher survey (t4learn)
// Q: how do we create this? 
// Q: what proportion of our sample droped out? 
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP 
// take 3 minutes to code this (send me the answer (not the code))

gen attrit=0 
//we are starting with 0 instead of . because attrition cannot be missing 
replace attrit=1 if read4==. & p4learn==. & t4learn==.
tab attrit if sample_lab5==1, mi
// about 18% of the sample (N=3194) dropped out 	
	
	
*-------------------------------------------------------------------------*
* Analysis: LPM, linear probability models 
*-------------------------------------------------------------------------*
// let's get through this in about 20 minutes 


reg attrit dcity dtown drural
// what just happened? 
reg attrit i.kurban_r
// what happened? 
reg attrit ib1.kurban_r
reg attrit ib2.kurban_r
reg attrit ib3.kurban_r
// what's happening here? 
// we quickly saw this next time. You don't have to do this but it can be convenient sometimes. 

reg attrit $predictors if sample_lab5==1
// let's interpret the coefficents here. 
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP 


	/* For every 1 year increase in age, we expect a 0.2 percentage point lower
	probability of attriting from the sample, holding all other variables constant.
	That association is NOT statistically significant. */
	
	/* interpret coefficient of dhispanic: Hispanic children were more likely to attri than white children, 	holding all other variables constant, by 2.5 percentage points*/
	
	* interpret coefficient of zmath1: for every 1 SD increase in fall-k math,  
	* we expect a 2.7 percentage point lower likelihood of attrition, holding all other variables constant. 
	
	* children from central cities were 2 percentage point more likely to attrit compared with kids from suburb 
		
*REVIEW from lecture: what's the limitation with LPM?
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP 
	// residual are not right
	// reg could technically give you probability <0 or >100%

help predict 	
* how to get y-hat (predicted Y, fitted Y, modeled Y, expected Y)	
	
* PRESENTING results: histogram out each individual's predicted probability 

reg attrit $predictors if sample_lab5==1
predict lpm
hist lpm, percent ///
title("Probability of attrition from ECLS-K by first grade") ///
	subtitle("predicted by demographics and fall-k test scores, using LPM") ///
	xtitle("probability of attrition") ///
	ytitle("percent of observations") ///
	note("Attrition defined as missing reading assessment, and approach to learning item on parent and teacher survey", span) ///
saving("${output}lab5_lpm", replace) name(lab5lpm, replace)

// NOTICE, 

*-------------------------------------------------------------------------*
// Above is what you need to know for PS 5 -- pretty simple.  
// Below is what you need to know for PS 6 -- not pretty 
*-------------------------------------------------------------------------*
// remember we have a midterm during next lab time 
// I'll hold office hours  
// logit = log odds 
// this will take up the hour of today's lab (or maybe less)

* quick reminder about predictors 
global predictors "age dfemale dblack dhispanic dasian dother zread1 zmath1 dcity drural" 
// notice we don't add all the variables. 
// white, male, living in suburb as omitted group (notice the full description of our reference group-the constant)

// FYI, I hate logits.....
// but you have to be know how they work...
// and some fields (esp. pyschology) is committed to them...
// other disciplines, less so... 
// so you end up presenting results in both ways to satisfy different readers. You (or your journal) will choose which goes in the appendix. 

* logit  
logit attrit $predictors if sample_lab5==1
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP 

// interpret hispanic
// compared with white, Hispanic children had a .15 higher log odds (p-value = 0.010) of attriting from the sample by the end of first grade, holding constant test scores at Kindergarten entry and urbancity. 
	
// interpret age. 
// One year increase in age is associated with a .016 lower log odds of attriting from the sample at the end of first grade, holding Kindergarten entry test scores and urbancity constant. However, this association is NOT statistically significant.
	
	******** BUT Who can understand LOG ODDS (RATIO) ???!! ******** 

* transforming log odds into odds ratio (then, change in odds): logit, or  /  logistic 
// to calculate odds ratio: e^B
// age: e^-.0163 = odds ratio which is .984 

logit attrit $predictors if sample_lab5==1
logit attrit $predictors if sample_lab5==1, coefl
display exp(_b[age])
// what does this mean? 
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP 
// this means the odds are 1.6 percent (1-.984) lower 
// but why? 
// notice, I am saying percent (not percentage point)
// big difference. 

// Hispanic: e^.152 = odds ratio which is 1.164 
// odds are 16.4 percent higher  


logit attrit $predictors if sample_lab5==1	
logit attrit $predictors if sample_lab5==1, or
// the or option, or odds ratio gives us .... the odds ratio (which is slightly better..)
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP 
	
	// For students one year older, we expect the odds of attriting from 
	// the sample to be lower by 2 percent. (odds ratio = .98) 

	// Hispanic children have 16.4 percent higher odds than White children 
	// to have attrited from the sample. (odds ratio = 1.164) 
	
	// For studentw with 1 SD higher fall-k math score, we expect the odds of attriting from 
	// the sample to be lower by (1- .81)= 19 percent. (odds ratio = .81) 
	
	// Children from rural areas have odds (1-.62) = 38 percent lower than children from large towns
	// to have attrited from the sample. (odds ratio = .62) 

	// For an one year increase in age, the odds of attriting from 
	// the sample drop by 2%. (odds ratio = .98) 
	
	// Hispanic children have odds 16.4% higher than White children 
	// to have attrited from the sample. (odds ratio = 1.164) 

	
logit attrit $predictors if sample_lab5==1, or
logistic attrit $predictors if sample_lab5==1
// notice the two lines above are the same 
// this is almost always the case 

	
	


*-------------------------------------------------------------------------------
* .... let's try to make life slightly easier .... 
*-------------------------------------------------------------------------------
// Log odds can be any number between minus and plus infinity, so it can be written as a linear function of our predictor set. Probability cannot be minus or infinity. 
// ..... but odds...odds ratio... just aren't as intuitive as probability... 
// we now start the painful tour of the world of odds...and the like. 
// recall the probability of gettings heads on a coin flip is .5 
// the odds of gettings heads on a coin flip is 1. 
// Say your have an unfair coin such that 
// P(heads) = .75 
// P(tails) = .25
// imagine an outcome variable heads = 1 for heads... heads = 0 for tails 
// what are your odds of getting heads?
// .75/.25 = 3
// what are your odds of getting tails?
// .25/.75 = 1/3
// what are your odds ratio that we talk about? 
// (odds Y=1 | X= d+1)/ (odds Y=1 | X= d)
// If OR > 1 then the odds of Y=1 increase as x increases
// If OR < 1 then the odds of Y=1 decrease as x increases
// the e^beta of X (odds ratio) of interest shows you the effect of the independent variable on the odds ratio 
// so if e^beta of X = 2... then your odds of getting heads doubles (or increase by 100%)... not 200%!!
// because recall that your denominator is the odds given X ... your units (or base) are in odds given X (have to adjust for 1)
// if your predictor is a dummy: the odds of getting heads (P(1)) is two times higher than when x = 1 than when x= 0 
// so if if e^beta of X = .5... then your odds of getting heads shrinks by a half (or by 50%)
// so if if e^beta of X = 1... then your odds do NOT change as X changes (more precisely, we cannot reject this null hypothesis)

// tired yet? 
// missing probabilities? 
// p/1-p = e^(b0+b1x)
// plug in b0, b1, x and solve for the probabillity given x = some value. 
// ... oh no!... 
// a more intuitive way
// Probability = odds / 1 + odds
// odds of getting heads was 3 
// probability = 3/(3+1) = .75 (see above)
// how do you get STATA to just give you the numbers that you desire? 
// that's where margin's come in (below), but let's get moving. 

*-------------------------------------------------------------------------------
* Margins: probability at certain point of x 
*-------------------------------------------------------------------------------
// note mfx is an old stata command
logit attrit $predictors if sample_lab5==1
margins
// what is this number?
logit attrit $predictors if sample_lab5==1
predict my_yhat
sum my_yhat
// that's what the defaul margin gives you... could be useful later, but that's the base code 
// what we want is the probabilty as some value of some X 

margins, at(age=(4.5 5.5 6.5))
// this gives you the “average predicted probability” if everyone in the dataset was treated as if he/she was in at those ages, then the predicted probability of outcome would be the numbers presented.
// you don't really want this. 

margins, at(age=(4.5 5.5 6.5)) atmeans 
margins, at(age=(4.5 5.5 6.5) (mean) _all) 

// atmeans specifies that covariates be fixed at their means and is shorthand for at( (mean) _all).
// the at option is telling to get the "margins" at those ages 

	// The probability of dropping out for participants of age 4.5 yrs old 
	// is 18.0%, holding all other predictors at their GRAND mean.
	
	// don't forget to add "GRAND mean" --- this is equivalent to saying holding all covariates constant at their mean. 

	// The probability of dropping out for participants of age 5.5 yrs old
	// is 17.7%, holding all other predictors at their GRAND mean.
	
	// The probability of dropping out for participants of age 6.5 yrs old
	// is 17.5%, holding all other predictors at their GRAND mean.

margins, dydx(age) at(age=(5 6)) atmeans
margins, dydx(*) atmeans
mfx	
reg attrit $predictors if sample_lab5==1
	
	// this helps you get the slope. 
	
	// The decrease in probability of dropping out for being 1 year older is 
	// 0.239 pp for students who are 5 years old, holding all other predictors at their GRAND mean
	
	// The decrease in probability of dropping out for being 1 year older is 
	// 0.237 pp for students who are 6 years old, holding all other predictors at their GRAND mean

	// not very different. 
	
* now let's run this and practice 

logit attrit $predictors if sample_lab5==1
margins, at(zmath1=(-1 0 1)) atmeans 
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP 
	// The probability of dropping out for participants scoring 1SD below the math mean
	// is 21%, holding all other predictors at their GRAND mean.

	// The probability of dropping out for participants scoring at the math mean
	// is 18%, holding all other predictors at their GRAND mean.

	// The probability of dropping out for participants scoring 1SD above the math mean
	// is 15%, holding all other predictors at their GRAND mean.


* change in probability: margins, dydx(predictor) at(predictor= ...
logit attrit $predictors if sample_lab5==1
margins, dydx(zmath1) at(zmath1=(-1 0 1)) atmeans

	// The decrease in probability of dropping out with an increase in 1 SD math score
	// is 3.4 pp for students scoring 1SD math below mean, holding all other predictors at their GRAND mean
	
	// The decrease in probability of dropping out with an increase in 1 SD math score
	// is 3 pp for students scoring at math mean, holding all other predictors at their GRAND mean
	
	// The decrease in probability of dropping out with an increase in 1 SD math score
	// is 2.6 pp for students scoring 1SD above the mean, holding all other predictors at their GRAND mean
	
	// you can kind of get this by subtracting the probabilities but not exactly. 
	
* Let's save 
save "${data}for_ps5.dta", replace



