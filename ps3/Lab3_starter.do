/********************************************************************************
 Lab 3
 Purpose: printing tables, testing group differences (non-reference), egen (std)
 Programmer: Paul Yoo, pyyoo@uci.edu 
 
 Note: this do file builds on the work of previous regression TAs
********************************************************************************/

global project "C:\Users\Jee Hyung Park\Dropbox\UCI Regression class\2021\Labs and Problem sets\"
global data "${project}data\"
global output "${project}output\"

* load data  
use "${data}for_lab3.dta", clear

*-------------------------------------------------------------------------*
* Questions
*-------------------------------------------------------------------------*
/* last week: loops and bi-variate analyses  
 

			Q: Any questions from previous week?

*/
	
* quick review on loops with regressions 

forvalues i = 4(1)6 {
	
	display ""
	display ""
	display "*****************************"
	display " Regress externalizing `i' on math test score `i'"
	display "*****************************"
	
	reg t`i'extern math`i' 
} 

* Q: what if you also wanted to control for prior wave math score? 
 forvalues i = 4(1)6 {
	
	local j = `i' - 1 
	
	display ""
	display ""
	display "*****************************"
	display " Regress externalizing `i' on math test score `i' and `j' "
	display "*****************************"
	
	reg t`i'extern math`i' math`j'
} 

/* this is equivalent to 

	reg t4extern math4 math3 
	reg t5extern math5 math4 
	reg t6extern math6 math5
*/
		

*-------------------------------------------------------------------------*
* Printing Tables, Descriptives 
*-------------------------------------------------------------------------*

*Set up a global list of the variables you want to use
global tests "math1 math2 math3 math4 math5 read1 read2 read3 read4 read5" 
summarize $tests
summarize $tests, d
// this works, but this is not how things appear in papers/reports that you read 
// copy-paste is... pretty horrible. 


/*Table Formatting Guidelines
1. Avoid vertical lines (and unnecessary horizontal lines).
2. Try to keep the table contained on one page (e.g., margins).
3. Make the tables completely self-explanatory (e.g., write notes).
4. Use same font as the main text (e.g., Times New Roman), but 10 pt font is fine. 

stata does not give you this exact table, but more programs have been developed to help */

* Install estout 
// a handy program to print 
// findit estout
// ssc install estout
// for those using apporto, I'm told you have to run this line first 
// sysdir set PLUS "U:\Temp"

// this is usually the first table generating program you learn but there are others 

* create a descriptive table of wave 1-5 reading & math test scores, for boys and girls 

summarize $tests
summarize $tests, d

est clear // clear estimate 'STATA local memory'

estpost summarize $tests, d
est store s1 //est store in 'STATA local memory

estpost summarize $tests if dfemale==1, detail
est store s2

estpost summarize $tests if dfemale==0, detail
est store s3

*esttab to transfer table from 'STATA local memory' to excel 
esttab s1 s2 s3
// somethings not right... 

esttab s1 s2 s3 , ///
	cells("mean(fmt(3)) sd(fmt(3)) p50(fmt(0)) count(fmt(0))") ///
	title("Descriptive statistics of test scores") ///
	mtitle("Full sample" "Females" "Males") ///
	replace label 

// why do you need the quotes after cell?
esttab s1 s2 s3 , ///
	cells(mean(fmt(3)) sd(fmt(3)) p50(fmt(0)) count(fmt(0))) ///
	title(Descriptive statistics of test scores) ///
	mtitle("Full sample" "Females" "Males") ///
	replace label 
	
	
esttab s1 s2 s3 , ///
	cells("mean(fmt(3)) sd(fmt(3)) p50(fmt(0)) count(fmt(0))") ///
	title("Descriptive statistics of test scores") ///
	mtitle("Full sample" "Females" "Males") ///
	replace label 


// it would be convenient to print this into a separate file

esttab s1 s2 s3 using "${output}lab3_testscores_bygender.csv", ///
	cells("mean(fmt(3)) sd(fmt(3)) p50(fmt(0)) count(fmt(0))") ///
	title("Descriptive statistics of test scores") ///
	mtitle("Full sample" "Females" "Males") ///
	replace label nogaps //nogaps removes unnecessary spacings 

// for those not using globals 
// you can just add cd ..... location 
// and remove the global ${global}

// with one more slight change. 	
esttab s1 s2 s3 using "${output}testscores_bygender_num.csv", ///
	cells("mean(fmt(3)) sd(fmt(3)) p50(fmt(0)) count(fmt(0))") ///
	title("Descriptive statistics of test scores") ///
	mtitle("Full sample" "Females" "Males") ///
	replace label nogaps plain 
	*plain outputs # as # instead of "#" (which excel reads as words)
	
//note: open the .csv file in excel, and then manually save as excel file, then format if needed
	

label var math1 "Math- Kindergarten Entry" //changing the current label to sth more informative 
label var math2 "Math- Kindergarten Spring" // and esttab can use that when printing
label var math3 "Math- First Grade Fall"
label var math4 "Math- First Grade Spring"
label var math5 "Math- Third Grade Spring"

label var read1 "Reading- Kindergarten Entry"
label var read2 "Reading- Kindergarten Spring"
label var read3 "Reading- First Grade Fall"
label var read4 "Reading- First Grade Spring"
label var read5 "Reading- Third Grade Spring"



esttab s1 s2 s3 using "${output}lab3_testscores_bygender.csv", ///
	cells("mean(fmt(3)) sd(fmt(3)) p50(fmt(0)) count(fmt(0))") ///
	title("Descriptive statistics of test scores") ///
	mtitle("Full sample" "Females" "Males") ///
	replace label nogaps plain 
	
* side note: how does esttab know where the numbers are stored? 
sum math1 
return list 
	
	
* how do you go about printing regression tables? 

reg t6extern math6 
est store m1

est dir 
// it's getting stored, too, but with different information

* how do you pick out the statistics that you want? 
help esttab  

* Q: let's go back to our loop example. What can we do within this loop? 

	est clear

	 forvalues i = 4(1)6 {
		
		local j = `i' - 1 
		
		display ""
		display ""
		display "*****************************"
		display " Regress externalizing `i' on math test score `i' and `j' "
		display "*****************************"
		
		reg t`i'extern math`i' math`j'
		est store m`i'
	} 

	est dir 


/* this is equivalent to 

	reg t4extern math4 math3 
	est store m4
	reg t5extern math5 math4 
	est store m5
	reg t6extern math6 math5
	est store m6
*/
			
	
	
* print out a quick table onto stata 

esttab m4 m5 m6
esttab m4 m5 m6, ///
	b(2) se(2) r2

esttab m4 m5 m6, ///
	b(2) se(2) r2 ///	
	title("Regression Table") ///
	mtitle("model 4" "model 5" "model 6") ///
	label nogaps 
	
esttab m4 m5 m6 using "${output}lab3_sample_tab.csv", ///
	b(2) se(2) r2 ///	
	title("Regression Table") ///
	mtitle("model 4" "model 5" "model 6") ///
	label nogaps replace
	

	
*-------------------------------------------------------------------------*
* Group differences through regressions 
*-------------------------------------------------------------------------*

/* Lets run regressions investigating the relation between SES group (DUMMIES)  
and achievement in reading and math during kindergarten */

summarize ses1 ses2 ses3 ses4 ses5 read1 read2 math1 math2 
	// hmmmm N (sample size) differs by variable
misstable sum ses1 ses2 ses3 ses4 ses5 read1 read2 math1 math2

*Set an analysis sample (several ways to do the same thing)
	gen lab3_sample=0
	replace lab3_sample=1 if ses1!=. & math1!=. & math2!=. & read1!=. & read2!=.
		// What is the max we should expect: 17,622

	// another way to deal with missing 
	gen lab3_sample_v2 = 0 
	replace lab3_sample_v2 = 1 if !mi(ses1, math1, math2, read1, read2)
	tab lab3_sample lab3_sample_v2, m
	drop lab3_sample_v2

	tab lab3_sample //analysis N=16,160
		// we only allow participants who had no missing data into the analysis sample
		//!!! this is just ONE of the many ways you can handle missing data; others 
		//e.g., mean subsitution, multiple imputation (i)-- claim generalizability accordingly 
		
	// yet another way to deal with missing EGEN
	help egen 
	egen tmp_miss = rowmiss(ses1 math1 math2 read1 read2)
	tab tmp_miss
	gen lab3_sample_v3 = (tmp_miss == 0)
	tab lab3_sample lab3_sample_v3, m
	drop lab3_sample_v3

* interpreting dummy coefficients 
/*Remember, you must leave out a comparison group: arbitrary choice but
  affect how your results are presented-- all dummy coefficients within a set 
  of dummy variables will be interpreted in comparison with the omitted category.*/
  
reg math2 ses2 ses3 ses4 ses5 if lab3_sample==1
// interpret coef of ses5: 
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP


*Lagged-dependent variable control
reg math2 ses2 ses3 ses4 ses5 math1 if lab3_sample==1
// interpret ses5:  
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP

* If there's time, repeat with reading 

* if you want test two non-reference groups

*test or lincom right after regression 
reg math2 ses2 ses3 ses4 ses5 math1 if lab3_sample==1
test ses4=ses5 
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP


lincom ses4 - ses5
// lincom not often used
// test (or f-test) is the usual method 
// how can you check that the results are equivalent to test? 
 

*-------------------------------------------------------------------------* 
* Standardize the variable 
*-------------------------------------------------------------------------*
// mechanically, this scales the measure in terms of its standard deviation units 
// it's important to consider where the standard deviation comes from 

gen zmath1_manual = . 
su math1
replace zmath1_manual = math1 - 25.90539 
replace zmath1_manual = zmath1_manual  / 9.099181

// there's a way to do this with egen 
egen zmath1= std(math1) // egen is similar to gen, but allows for many more functions. "help egen" 
scatter zmath1 zmath1_manual
browse zmath1 zmath1_manual

// you see some rounding error 
// you can get rid of them by using the numbers that are stored in stata 
// if there's time. 


* standardize some more variables: math2, read1, read2 
egen zmath2= std(math2) 
egen zread1= std(read1) 
egen zread2= std(read2) 
sum zmath1 zmath2 zread1 zread2

reg zmath2 ses2 ses3 ses4 ses5 zmath1 if lab3_sample==1
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP
// interpret coef of ses5: participants in the highest SES quintile on average scored

// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP
// interpret coef of zread1: Holding SES constant, every 1 SD increase in fall of k

// NOTE: reg ___, beta 	outputs coefficients where all predictors and outcomes are standardized
// this however is rarely done and often people will just create the standardized variables. 
// but it's nice short-cut when you are quickly exploring. 

*Create a regression table

label var ses1 "SES- Lowest quintile"
label var ses2 "SES- Quintile 2"
label var ses3 "SES- Quintile 3"
label var ses4 "SES- Quintile 4"
label var ses5 "SES- Highest quintile"
label var zmath1 "(Standardized) Math- Kindergarten Fall"
label var zmath2 "(Standardized) Math- Kingergarten Spring"
label var zread1 "(Standardized) Reading- Kindergarten Fall"
label var zread2 "(Standardized) Reading- Kindergarten Spring"

est clear
reg zmath2 ses2 ses3 ses4 ses5 if lab3_sample==1
est store m1 //spring-k math

reg zread2 ses2 ses3 ses4 ses5 if lab3_sample==1
est store m2 //spring-k read

reg zmath2 ses2 ses3 ses4 ses5 zmath1 if lab3_sample==1
est store m3 //spring-k math with control

reg zread2 ses2 ses3 ses4 ses5 zread1 if lab3_sample==1
est store m4 //spring-k read with control


esttab m* using "${output}reg_ses.csv", ///
	title("Regression: SES predicting Standardized Spring-K reading and math") ///
	mtitle("Spring-K math" "Spring-K reading" "Spring-K math controlling for Fall" "Spring-K reading controlling for Fall") ///
	replace label nogaps b(2) se(2) r2 

*-------------------------------------------------------------------------* 
* END OF LAB. For the problem set
*-------------------------------------------------------------------------* 
// you need to know how to run anova's (you saw in in your fall terms + briefly in lab 1 + saw most of this in lecture) 

*example from lab 1 
// review for those who are not sure 
anova math3 kurban_r 
oneway math3 kurban_r, tab
pwmean math3, over(kurban_r) mcompare(tukey) effects


* save the data 
save "${data}for_ps3.dta", replace

