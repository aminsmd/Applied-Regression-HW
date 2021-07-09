/********************************************************************************
 Lab 4
 Purpose: f-tests, interactions
 Programmer: Paul Yoo, pyyoo@uci.edu 
 
 Note: this do file builds on the work of previous regression TAs
********************************************************************************/

global project "C:\Users\Jee Hyung Park\Dropbox\UCI Regression class\2021\Labs and Problem sets\"
global data "${project}data\"
global output "${project}output\"

* load data  
use "${data}for_lab4.dta", clear


*-------------------------------------------------------------------------*
* Previously in Lab 3 
*-------------------------------------------------------------------------*
** printing tables, testing group differences (non-reference), egen (std)
/* 

			Q: Any questions from previous week?

*/


/*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*

you need to know 
(1) read a regression output
(2) how to construct an equation from a table of coefficients (or from a regression output)
(3) print and format tables in APA formatting // will cover this at the end today (please remind me if I forget)
(4) understand what it means to control for something 

if you feel uncomfortable with these after today's lab, 
talk me after lab or at OH

*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*/

*-------------------------------------------------------------------------* 
* let's invest in things to save time
*-------------------------------------------------------------------------* 

desc math*
label var math6 "Math-5th grade spring"
label var math7 "Math-8th grade spring"

desc read*
label var read6 "Reading-5th grade spring"
label var read7 "Reading-8th grade spring"

desc science*
label var science5 "Science-3rd grade spring"
label var science6 "Science-5th grade spring"
label var science7 "Science-8th grade spring"

desc genknow*
label var genknow1 "General Knowledge-Kindergarten entry"
label var genknow2 "General Knowledge-Kindergarten spring"
label var genknow3 "General Knowledge-First grade fall"
label var genknow4 "General Knowledge-First grade spring"

// you can of course create your own, and invest in the code
// and then carry over the code to the next files you work only 
// if you think it's worth it. 

* while we are at it... let's create all the standardized test scores 
// what's the best way to do this? 
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP
foreach var of varlist math* read* science* genknow*{
	// paul show one line of code here. 
	egen z`var' = std(`var')
}

desc 

* I'll add some fancy code below that I won't really go over but will ... make life easier for you
foreach var of varlist math* read* science* genknow*{
	cap drop z`var'
	egen z`var' = std(`var')
	local lab: variable label `var'
	label var z`var' "Std: `lab'"
	
}

// and some variables of the past has crept in (a limitation to using the *)
// but we won't need them (and if we ever do, you know how to create them)

drop zmathgain zreadgain 

// also let's get rid of those weird estimates that are not going away
drop _est*

*-------------------------------------------------------------------------* 
* Let's quickly review Quadratics 
*-------------------------------------------------------------------------* 
// for more details, review lecture or read Gordon page 316 

* let's create a std ses variable 
egen zses = std(wksesl)

* let's start with the simple regression
reg zscience7 zses 
	
* add in the squared term: allowing a 'threshold' into the model where 
*in/decrease in outcome by predictor slows down/speed up 

* square the predictor
gen zsessq = zses * zses 
reg zscience7 zses zsessq  //need the original term for sq term to be in! 
	
	/* 
		where is the threshold? 
		quadratic func:  y= ax^2 + bx + c
		min/max: x = -b/2a
		if a is +, parabola opens up, meaning it has a MIN
		if a is -, parabola opens down, meaning it has a MAX
	*/

	
* in our equation, a is coef of zsessq, b if coef of zses
	display -.4544/[2*(-.0128)] 
		// max is at SES of 17.75 SD
		// is this a U-shape or inverted U-shape: 

* there is another way to compute this, without typying out the numbers
reg zscience7 zses zsessq, coefl
	// add an option for coefficient legend to see how some of the betas are stored 
	display _b[zses]
	display _b[zsessq]
	display -_b[zses]/(2*_b[zsessq])
	display -.4544/[2*(-.0128)] 
	// stuff like this gets useful when you get deeper into loops and you want to 
	// see some numbers for some variables (without hard-coding the numbers)
	
	
*interpret in practical terms: 
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP
	


* let's visualize quadratic relationship, quick and dirty 
scatter zscience7 zses || lfit zscience7 zses || qfit zscience7 zses

// not the best graph.... 
// and we can see that it looks pretty linear
// but the scatter is just too much for us to make sense of this. 
// don't worry about this for now, we'll get to visualizations later. 


*-------------------------------------------------------------------------*
* Interaction: getting set up 
*-------------------------------------------------------------------------*
// Examine how children's SES predicts their standardized science score in grade 8 
// controlling for grade5 science score, age, gender, and ethnicity. 
// We also want to know if the association differ by school type. 


* outcome: standardized science score in grade 8
// we have already standardized this up top 
desc zscience7
				
* predictor: standardized ses 
desc zses

* controls: grade5 science score, age, gender, and ethnicity
// Q: should we standardize the grade 5 science score? will this matter? 
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP
// paul add answer. 

sum zscience6 //good to go
sum zscience6 age dfemale dwhite dblack dhispanic dasian dother	

	// let's put these into a gobal 
	global controls "zscience6 age dfemale dblack dhispanic dasian dother"
	// notice I am leaving white out as the reference group
	// and also male 
		
* moderator: school type
tab cs_type2, m // catholic, other religious, other private, public
tab cs_type2, nolab // wow, no missing data, whats happening 

// let's create a dummy for public school 
gen dpublic=. 
replace dpublic=0 if cs_type2!=. 
replace dpublic=1 if cs_type2==4
tab cs_type2 dpublic, m		 
		
		
* make an analysis sample with only non-missing cases (so that we can compare across models) 
cap drop lab4_sample
gen lab4_sample=0
replace lab4_sample=1 if zscience7!=. & zses!=. & science6!=. & age!=. & dfemale!=. & dblack!=. & dpublic!=.
tab lab4_sample 
	// lots of people excluded... 
	// this is very important... 
	// you have to skeptical about who is making up your sample (but more on this in future weeks)
	// we're now ready for the running analyses with interactions 
	
*-------------------------------------------------------------------------*
* Interaction : running the analysis 
*-------------------------------------------------------------------------*		
	
* model 1 : simple bivariate using SES to predict standardized science score in grade 8
reg zscience7 zses if lab4_sample==1 
	// 1 standard deviation increase in SES predicts 0.45 standard deviation (p-value < 0.000) higher 
	// grade 8 science score, on average. 	
	// note.. p-value cannot = 0 
		
* reg model 2: WITH CONTROLS, how did SES predict standardized science score in grade 8
reg zscience7 zses $controls if lab4_sample==1 
	// practice interpreting the output 
	// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP
	
* reg model 3: WITH CONTROL, only for PUBLIC school
reg zscience7 zses $controls if lab4_sample==1 & dpublic==1
	// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP
	
*  reg model 4: WITH CONTROL, only for NON-PUBLIC school
reg zscience7 zses $controls if lab4_sample==1 & dpublic==0
	// practice interpreting the output 
	// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP
	
/* or */ bysort  dpublic: reg zscience7 zses $controls if lab4_sample==1

******* until now, it's really been review: we now turn to interactions *****
	
* reg model 5: WITH CONTROL, school type INTERACTION with predictor
// generate the interaction variable 
gen zsesXpublic=zses*dpublic

reg zscience7 zses dpublic zsesXpublic if lab4_sample==1 	
// ! important !: to include interaction, ALWAYS include the main effects
// WHAT HAPPENS IF YOU OMIT THE MAIN EFFECT IN A REGRESSION MODEL WITH AN INTERACTION?
// actually very complicated (much more so than what we covered in lecture
// read more about it here (can't cover it here)
// https://stats.idre.ucla.edu/stata/faq/what-happens-if-you-omit-the-main-effect-in-a-regression-model-with-an-interaction/#:~:text=Remote%20Consulting-,What%20happens%20if%20you%20omit%20the%20main%20effect,regression%20model%20with%20an%20interaction%3F&text=The%20simple%20answer%20is%20no,were%20included%20in%20the%20model.

// interpret the simpler regression equation
reg zscience7 zses dpublic zsesXpublic if lab4_sample==1 	

// now add controls 
reg zscience7 zses dpublic zsesXpublic $controls if lab4_sample==1 	
// interpret zses: 
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP1

// Q: what is the relationship between ses and science test score for students in public school? 
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP1

// is the this relationship between ses and science test score different for students in public schools and private schools? how do you know? 

// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP1


* shortcut: when you don't want to manually create interaction terms 
reg zscience7 c.zses##i.dpublic $controls if lab4_sample==1 	
// don't forget all the # 
reg zscience7 c.zses#i.dpublic $controls if lab4_sample==1 	
// if you do, it drops the main effect variables 

reg zscience7 c.zses##ib0.dpublic $controls if lab4_sample==1 	
reg zscience7 c.zses##ib1.dpublic $controls if lab4_sample==1 	
		
	* c.var for continuous variable
	* i.var for categorical variable
	* ib0.var for Categorical variable, reference group set for group with 0 
	
	
* fully saturated model (or fully interacted model) : interact with predictor and all controls 
// the idea is to create interaction terms with each control variable
// e.g., gen science6Xpublic = science6*dpublic
//		gen ageXpublic = age*dpublic

		foreach var in $controls {
			gen `var'Xpublic= `var' * dpublic
			}
	
* global interactions list 
global interactions_control "zsesXpublic-dotherXpublic"


*fully saturated interaction		
reg zscience7 zses dpublic $controls $interactions_control if lab4_sample==1 	
	* zses(0.0576) zsesXpublic (0.0376)
	* SES is positively associated with grade 8 science score controlling for ... 
	*...AND THEIR INTERACTION WITH BEING IN PUBLIC SCHOOL,
	* the association is (marginally) even more pronounced for public school than private school students. 

// some small illustration of why using fully saturated models are considered better practice
reg zscience7 zses $controls if lab4_sample==1 & dpublic == 1 // .0951302
reg zscience7 zses $controls if lab4_sample==1 & dpublic == 0 //.0575764
reg zscience7 zses dpublic zsesXpublic $controls 
reg zscience7 zses dpublic $controls $interactions_control
// for now, I just want to expose you to fully saturated models 
// and there's a question on the PS that asks you to do this 

					
* Joint F-test: is the relation between zscience7 and zses and student characteristics systematically different for students in public and private school?
test zsesXpublic = zscience6Xpublic = ageXpublic = dfemaleXpublic = dblackXpublic = dhispanicXpublic = dasianXpublic = dotherXpublic = 0
	
	* pooled model suggests the model for public school students is different from model for private school students	
	* F = 7.04, p < .0001
	// but you knew this already from looking at the regression table 

* another way (the more traditional way is to do this)
test zsesXpublic = 0
test zscience6Xpublic = 0, accum
test ageXpublic = 0, accum 
test dfemaleXpublic = 0, accum 
test dblackXpublic = 0, accum 
test dhispanicXpublic = 0, accum
test dasianXpublic = 0, accum
test dotherXpublic = 0, accum


* of course, a loop is better for this. 
test zsesXpublic = 0
foreach var of varlist  zscience6Xpublic ageXpublic dfemaleXpublic dblackXpublic dhispanicXpublic dasianXpublic dotherXpublic{
	test `var' = 0, accum
}       			
			 	 
* esttab out models to compare (main interest is the SES coefficient) 
est clear 

*m1 
reg zscience7 zses if lab4_sample==1 	
est sto m1 // no control

*m2
reg zscience7 zses $controls if lab4_sample==1 	
est sto m2 // control no interaction

*m3
reg zscience7 zses dpublic zsesXpublic $controls if lab4_sample==1 	
est sto m3 // control with interaction

*m4
reg zscience7 zses dpublic $controls $interactions_control if lab4_sample==1 	
est sto m4 // fully saturated interaction

esttab m* using "${output}science7byses.csv", ///
	b(3) se(3) r2 nogaps label replace ///
	mtitle("no control" "control no interaction" "control with interaction" "fully saturated interaction")
	// oh wow i don't need all that control by SES interactions
	
esttab m* using "${output}science7byses.csv", ///
	b(3) se(3) r2 nogaps label replace ///
	keep(zses dpublic zsesXpublic) ///
	mtitle("no control" "control no interaction" "control with interaction" "fully saturated interaction")


* some basic visuals 
// if time color colorpalette (package to install)
// https://boris.unibe.ch/116571/1/Jann-2018-palettes.pdf

twoway  (scatter zscience7 zses if lab4_sample==1 & dpublic==1) ///
		(scatter zscience7 zses if lab4_sample==1 & dpublic==0) 

twoway  (scatter zscience7 zses if lab4_sample==1 & dpublic==1, mcolor(sanb) msymbol(circle_hollow)) ///
		(scatter zscience7 zses if lab4_sample==1 & dpublic==0, mcolor(dkorange)) 
	
twoway  (scatter zscience7 zses if lab4_sample==1 & dpublic==1, mcolor(sanb) msymbol(circle_hollow)) ///
		(scatter zscience7 zses if lab4_sample==1 & dpublic==0, mcolor(dkorange)) ///		
		(lfit zscience7 zses if lab4_sample==1 & dpublic==1, lcolor(sanb) lpattern(dash)) ///
		(lfit zscience7 zses if lab4_sample==1 & dpublic==0, lcolor(dkorange) lpattern(solid))
		
twoway  (scatter zscience7 zses if lab4_sample==1 & dpublic==1, mcolor(sanb) msymbol(circle_hollow)) ///
		(scatter zscience7 zses if lab4_sample==1 & dpublic==0, mcolor(dkorange)) ///
		(lfit zscience7 zses if lab4_sample==1 & dpublic==1, lcolor(sanb) lpattern(dash)) ///
		(lfit zscience7 zses if lab4_sample==1 & dpublic==0, lcolor(dkorange) lpattern(solid)) ///
		, legend(order (1 "public" 2 "non-public")) ///
		ytitle("8th grade Science Test Score ") xtitle("STD. SES") /// 
		name(sesXschooltype_ugly, replace) 
	
graph save "${output}sesXschooltype_ugly.gph", replace

// becareful with the label 
twoway  (scatter zscience7 zses if lab4_sample==1 & dpublic==0, mcolor(dkorange)) ///
		(scatter zscience7 zses if lab4_sample==1 & dpublic==1, mcolor(sanb) msymbol(circle_hollow)) ///
		(lfit zscience7 zses if lab4_sample==1 & dpublic==0, lcolor(dkorange) lpattern(solid)) ///
		(lfit zscience7 zses if lab4_sample==1 & dpublic==1, lcolor(sanb) lpattern(dash)) ///
		, legend(order (1 "public" 2 "non-public")) ///
		ytitle("8th grade Science Test Score ") xtitle("STD. SES") /// 
		name(sesXschooltype_ugly2wrong, replace) 

// important: the best fit line is always not the regression line (well, only the bivariate regression line)
// you can graph a function, but we won't cover that in this class, unless there's time at the end of the quarter. 		
	
	
// there's another way to graph just the lines with "margins"
// we're going to cover margins later but here's a quick preview 
reg zscience7 i.dpublic##c.zses $controls
margins, at(zses=(-2(1)2) dpublic=(0 1))
marginsplot
// notice this is not a fully interacted model. 
// it's slightly trickier to code this, as you will see later
// it's also nice for getting a quick visual 

*-------------------------------------------------------------------------*
* Interaction : some Practice 
*-------------------------------------------------------------------------*		
// Predict first grade externalizing problems using first grade level of sadness, 
// controlling for spring-k level of sadness. 
// Does the association differ by gender?


* recode missing 
sum t4extern p4sadlon p2sadlon 
foreach var in t4extern p4sadlon p2sadlon {
replace `var'=. if `var'<0
}

gen sadXfemale=p4sadlon*dfemale
reg t4extern p4sadlon p2sadlon dfemale sadXfemale
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP1

	   
twoway (scatter t4extern p4sadlon if dfemale==0, mcolor(blue) msymbol(circle_hollow)) ///
	   (scatter t4extern p4sadlon if dfemale==1, mcolor(red)) ///
	   (lfit t4extern p4sadlon if dfemale==0, lcolor(blue) lpattern(dash)) ///
	   (lfit t4extern p4sadlon if dfemale==1, lcolor(red) lpattern(solid)) ///
	   , legend(order(1 "male scat" 2 "female scat" 3 "male line" 4 "female line")) ///
	   name(sadXfemale_pextern, replace)	   

twoway (scatter t4extern p4sadlon if dfemale==0, mcolor(blue) msymbol(circle_hollow)) ///
	   (scatter t4extern p4sadlon if dfemale==1, mcolor(red)) ///
	   (lfit t4extern p4sadlon if dfemale==0, lcolor(blue) lpattern(dash)) ///
	   (lfit t4extern p4sadlon if dfemale==1, lcolor(red) lpattern(solid)) ///
	   , legend(order(1 "male" 2 "female" 3 "male" 4 "female")) ///
	   name(sadXfemale_pextern2, replace)	   
	   
twoway (scatter t4extern p4sadlon if dfemale==0, mcolor(blue) msymbol(circle_hollow)) ///
	   (scatter t4extern p4sadlon if dfemale==1, mcolor(red)) ///
	   (lfit t4extern p4sadlon if dfemale==0, lcolor(blue) lpattern(dash)) ///
	   (lfit t4extern p4sadlon if dfemale==1, lcolor(red) lpattern(solid)) ///
	   , legend(order(1 "male" 2 "female")) ///
	   name(sadXfemale_pextern3, replace)

twoway (lfit t4extern p4sadlon if dfemale==0, lcolor(blue) lpattern(dash)) ///
	   (lfit t4extern p4sadlon if dfemale==1, lcolor(red) lpattern(solid)) ///
	   , legend(order(1 "male" 2 "female")) ///
	   name(sadXfemale_pextern_noscat, replace)

twoway (lfit t4extern p4sadlon if dfemale==0, lcolor(blue) lpattern(dash)) ///
	   (lfit t4extern p4sadlon if dfemale==1, lcolor(red) lpattern(solid)) ///
	   , legend(order(1 "male" 2 "female")) ///
	   ylabel(1(1)4) ///
	   name(sadXfemale_pextern_noscat2, replace)


*-------------------------------------------------------------------------*
* Interaction : more Practice
*-------------------------------------------------------------------------*		
// Does kindergarten teacher's age predict student's math score? 
// Does that association differ in rural area or inner city compared with the suburb?
// (graph this out) 

sum b1age
replace b1age=. if b1age<0 // predictor good to go
reg zmath2 b1age // on average, teacher age does not predict zmath2
tab kurban_r
tab kurban_r, nol
gen dsuburb=0 //i'm comparing suburb to everyone else 
replace dsuburb=1 if kurban_r==2

gen tageXsuburb=b1age*dsuburb
reg zmath2 b1age dsuburb tageXsuburb

twoway (scatter  zmath2 b1age if dsuburb==0, mcolor(blue) msymbol(circle_hollow)) ///
	   (scatter  zmath2 b1age if dsuburb==1, mcolor(red)) ///
	   (lfit  zmath2 b1age if dsuburb==0, lcolor(blue) lpattern(dash)) ///
	   (lfit  zmath2 b1age if dsuburb==1, lcolor(red) lpattern(solid)), ///
	   legend(label(1 "non-suburb") label(2 "suburb") order (1 2))
		
twoway (lfit  zmath2 b1age if dsuburb==0, lcolor(blue) lpattern(dash)) ///
	   (lfit  zmath2 b1age if dsuburb==1, lcolor(red) lpattern(solid)), ///
	   legend(label(1 "non-suburb") label(2 "suburb") order (1 2))
		
	
	
*-------------------------------------------------------------------------* 
* Paul: show how to format tables!! 
*-------------------------------------------------------------------------* 

	
*-------------------------------------------------------------------------*
* Adding in some variables for PS4 (internal cleaning)
*-------------------------------------------------------------------------*
// this will only work on my (Paul's) Computer. For PS4, you must use the dataset on canvas for the problem set! 

cap drop _merge
merge 1:1 childid using "C:\Users\Jee Hyung Park\Dropbox\UCI Regression class\2021\Labs and Problem sets\lastyear\data\for_ps4.dta", ///
	gen(merge)	keepusing(p1weighp p1chlboo p1hmafb p1wicmom)
drop merge 

*------------------------------------------------------------------------------
* SAVE THE DATASET 
*------------------------------------------------------------------------------
save "${data}for_ps4.dta", replace 




