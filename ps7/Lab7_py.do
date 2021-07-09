/********************************************************************************
 Lab 7
 Purpose: collapse, binned scatter, spline, and then some extras 
 Programmer: Paul Yoo, pyyoo@uci.edu 
 
 Note: this do file builds on the work of previous regression TAs
********************************************************************************/

global project "C:\Users\Jee Hyung Park\Dropbox\UCI Regression class\2021\Labs and Problem sets\"
global data "${project}data\"
global output "${project}output\"

* load data  
use "${data}for_lab7.dta", clear

*-------------------------------------------------------------------------------
* PS6 review: lpm vs logits 
*-------------------------------------------------------------------------------

global controls zread1 dblack dhispanic dasian dother ///
	ageinmonth bw_oz dfemale books books2 dmage_30plus dmage_teen wksesl momwic ///
	dhighcol dcolplus

reg highext zmath1 $controls if sample_ps5==1	
logit highext zmath1 $controls if sample_ps5==1

* how do you know if lpm and logits give you similar enough information? 
// when can you feel safe about just using lpm as your first move? 
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP 

reg highext zmath1 $controls if sample_ps5==1	
predict yhat_lpm 

logit highext zmath1 $controls if sample_ps5==1
predict yhat_logit  

* you can check the scatter for yhats 
scatter yhat_lpm yhat_logit 
// and then visually get a sense for whethere that looks pretty similar 
scatter yhat_lpm yhat_logit || function y= x
// you can kind of see when lpm and logit are different 

* you can also compare the basic marginal effects against lpm  
logit highext zmath1 $controls if sample_ps5==1
margins, dydx(zmath1) atmeans
reg highext zmath1 $controls if sample_ps5==1	 

// and you might decide that lpm is good enough 
// that you will start with lpm then add logits later 
// or decide that you lpm isn't good enough, even as your first move. 

*-------------------------------------------------------------------------------
* some basics of stata palettes // a handy user package (not required) - you can also just google the codes
*-------------------------------------------------------------------------------
/*
ssc install palettes, replace
net install palettes, replace from(https://raw.githubusercontent.com/benjann/palettes/master/)
net install colrspace, replace from(https://raw.githubusercontent.com/benjann/colrspace/master/)

help palettes
colorpalette9 s1
colorpalette9 s2
colorpalette9 s1r
colorpalette9 economist 
colorpalette9 mono 
linepalette  
symbolpalette
*/

*-------------------------------------------------------------------------------
* Motivating Example of binned scatter 
*-------------------------------------------------------------------------------/
* here's an ugly scatter that we created a couple of weeks ago  
twoway  (scatter zscience7 zses if lab4_sample==1 & dpublic==1, mcolor(black) msymbol(circle_hollow)) ///
		(scatter zscience7 zses if lab4_sample==1 & dpublic==0, mcolor(dkorange)) ///
		(lfit zscience7 zses if lab4_sample==1 & dpublic==1, lcolor(black) lpattern(dash)) ///
		(lfit zscience7 zses if lab4_sample==1 & dpublic==0, lcolor(dkorange) lpattern(solid)) ///
		, legend(order (1 "public" 2 "non-public")) ///
		ytitle("8th grade Science Test Score ") xtitle("STD. SES") /// 
		name(sesXschooltype_ugly, replace) ///

* let's bin the data (more on this later)
keep if lab4_sample==1 
gen zses_bin = .2*floor(zses/.2)
hist zses_bin, name(hist, replace)

* collapse the data to create binned scatter 
collapse (mean)zscience7 highext , by(zses_bin dpublic)

twoway  (scatter zscience7 zses if dpublic==1, mcolor(black) msymbol(circle_hollow)) ///
		(scatter zscience7 zses if dpublic==0, mcolor(dkorange)) ///
		(lfit zscience7 zses if dpublic==1, lcolor(black) lpattern(dash)) ///
		(lfit zscience7 zses if dpublic==0, lcolor(dkorange) lpattern(solid)) ///
		, legend(order (1 "public" 2 "non-public")) ///
		ytitle("8th grade Science Test Score ") xtitle("STD. SES") ///
		name(bin1, replace)
		
* recall what the histogram was like
// most of the data are actually above -2 SD
// so let's try limiting to just that and change the colors a bit 

twoway  (scatter zscience7 zses if dpublic==1 & zses <= -2, mcolor(gs3) msymbol(circle_hollow)) ///
		(scatter zscience7 zses if dpublic==1 & zses > -2, mcolor(black) msymbol(circle_hollow)) ///
		(scatter zscience7 zses if dpublic==0 & zses > -2, mcolor(cranberry) msymbol(diamond_hollow)) ///
		(lfit zscience7 zses if dpublic==1 & zses <= -2, lcolor(gs3) lpattern(dash)) ///
		(lfit zscience7 zses if dpublic==1 & zses > -2, lcolor(black) lpattern(dash)) ///
		(lfit zscience7 zses if dpublic==0 & zses, lcolor(cranberry) lpattern(dash_dot)) ///
		, legend(order (1 "public low ses" 2 "public higher ses" 3 "non-public")) ///
		ytitle("8th grade Science Test Score ") xtitle("STD. SES") ///
		name(bin2, replace)
// but we don't want to ignore them either. 
// it's not a good idea to get rid of them
// but we are presented with the problem of thinking about a non-linear relationship
// so we can try to fit multiple lines, using a spline function 
		
* let's take a closer look at just the public school kids 
twoway  (scatter zscience7 zses if dpublic==1 & zses <= -2, mcolor(gs3) msymbol(circle_hollow)) ///
		(scatter zscience7 zses if dpublic==1 & zses > -2 & zses < 0, mcolor(gs2) msymbol(circle_hollow)) ///
		(scatter zscience7 zses if dpublic==1 & zses >= 0, mcolor(black) msymbol(circle_hollow)) ///
		(lfit zscience7 zses if dpublic==1 & zses <= -2, lcolor(gs3) lpattern(dash)) ///
		(lfit zscience7 zses if dpublic==1 & zses > -2 & zses < 0 , lcolor(gs2) lpattern(dash)) ///
		(lfit zscience7 zses if dpublic==1 & zses >= 0, lcolor(black) lpattern(dash)) ///
		, legend(order (1 "public very low ses" 2 "public lower ses" 3 "public higher ses") size(small) rows(1)) ///
		title("Science test score and ses") ///
		subtitle(public school only) ///
		ytitle("8th grade Science Test Score ") xtitle("STD. SES") ///
		note("note: very low ses is lower than 2 SD below the mean, lower ses is within 2 SD below the mean," "higher ses is at or above the mean" ) ///
		name(bin3, replace)

// because of the sample size below -2, it's difficult to speak to the relationship between ses and science test score there. there may be a near 0 relationship or our data is too noisy for us to discern the average relationship
// however, fitting multiple relationships in this way, gives us some sense for how we might create our model
// this should remind you of  Greg's old paper on family income and years of schooling 		
				
* now let's go back to the student-level data and repeat these steps 

*-------------------------------------------------------------------------------
* creating bins 
*-------------------------------------------------------------------------------/
use "${data}for_lab7.dta", clear

* first recall that this analysis was limited to a particular sample 
keep if lab4_sample==1 

* how we create our bins? 
browse zses
sort zses

* we first have to settle on the bin size (let's go with .2)
// so we want something like 0.0 0.2 0.4 0.6.... 

* "floor" gives us something useful 
help floor
display 1.98
display floor(1.98)
display floor(1.91)
display floor(1.11)
// in short floor rounds down 

* it turns out that you can use a combination of floor, dividing by bin, multiplying by bin, to create the bin labels 
gen step1 = zses/.2
gen step2 = step1*.2 
// these two steps basically undo each other, but you stick floor in the middle of this process 
gen step3 = floor(step1)
// turns all of these into integers
gen step4 = step3 * .2 

* just do it all in one step 
gen zses_bin = .2*floor(zses/.2)
drop step1 step2 step3 step4

* when you create bins, it's generally a good idea to look at the bins
hist zses_bin, name(hist, replace)
hist zses, name(histraw, replace)
// it should look similar to the raw distribution 
// you should also notice that most of the observations are in a particular range of ses 

*-------------------------------------------------------------------------------
* collapsing the data (basic) 
*-------------------------------------------------------------------------------/
// there are multiple ways of creating binned scatterplots, but we'll cover how to collapse the data today
// this comes in handy for lots of other purposes, too 

desc
// there are current 21,410 rows 
codebook zses_bin
// there are 46 bins, so you want to get to 46 rows 
// or we want 92 bins, 46 for public and 46 for private 
// recall the binned scatter plot, 
// on your x-axis was your zses bins 
// on your y-axis was something you wanted to descsribe about each bin 

help collapse 

* after you collapse, you can't just hit control z to undo collapse
// so let's save a temporary file 
save "${data}lab7_prec_TMP.dta", replace 
use "${data}lab7_prec_TMP.dta", clear

* let's first collapse to just the 46 bins (or rows) for our public school students 
// restrict the sample to public school 
keep if dpublic == 1 
codebook zses_bin 
// notice you now have 45 unique values 

* then decide on what we want to keep 
collapse (mean) zscience7 dpublic, by(zses_bin)	
browse 
// notice, you have 46 rows 
// why? 
// one is missing 

su 	
	
* we basically have 2 variables + our dpublic (which )
scatter zscience7 zses_bin	

* we just do something fancy looking stuff to it 
// we are fitting 3 lines 
twoway  (scatter zscience7 zses if dpublic==1 & zses <= -2, mcolor(gs3) msymbol(circle_hollow)) ///
		(scatter zscience7 zses if dpublic==1 & zses > -2 & zses < 0, mcolor(gs2) msymbol(circle_hollow)) ///
		(scatter zscience7 zses if dpublic==1 & zses >= 0, mcolor(black) msymbol(circle_hollow)) ///
		(lfit zscience7 zses if dpublic==1 & zses <= -2, lcolor(gs3) lpattern(dash)) ///
		(lfit zscience7 zses if dpublic==1 & zses > -2 & zses < 0 , lcolor(gs2) lpattern(dash)) ///
		(lfit zscience7 zses if dpublic==1 & zses >= 0, lcolor(black) lpattern(dash)) ///
		, legend(order (1 "public very low ses" 2 "public lower ses" 3 "public higher ses") size(small) rows(1)) ///
		title("Science test score and ses") ///
		subtitle(public school only) ///
		ytitle("8th grade Science Test Score ") xtitle("STD. SES") ///
		note("note: very low ses is lower than 2 SD below the mean, lower ses is within 2 SD below the mean," "higher ses is at or above the mean" ) ///
		name(bin3, replace)


* we covered RD in the last couple of weeks, and binned scatters are essential to drawing out scatter to see if you have a RD design 
// it's very hard to find an RD example, and I'm not aware of any RD designs within the ecls-k 

*-------------------------------------------------------------------------------
* collapsing the data (a few more details) 
*-------------------------------------------------------------------------------/
* let's go back to our student level data 
use "${data}lab7_prec_TMP.dta", clear

// recall that we were first trying to plot the scatter for public school kids and private school kids 
// that means, for each ses bin, we want public school kids and private school kids 
// so we change our levels 

collapse (mean) zscience7, by(zses_bin dpublic)	
// of course it's possible that you do not have someone is each level 
// we can now fit our first scatter 

twoway  (scatter zscience7 zses if dpublic==1, mcolor(black) msymbol(circle_hollow)) ///
		(scatter zscience7 zses if dpublic==0, mcolor(dkorange)) ///
		(lfit zscience7 zses if dpublic==1, lcolor(black) lpattern(dash)) ///
		(lfit zscience7 zses if dpublic==0, lcolor(dkorange) lpattern(solid)) ///
		, legend(order (1 "public" 2 "non-public")) ///
		ytitle("8th grade Science Test Score ") xtitle("STD. SES") ///
		name(bin1, replace)	

* let's go back to our student level data again 
// what else can collapse do for us? 
use "${data}lab7_prec_TMP.dta", clear
// you can take whatever statistic that you want 

* let's say we wanted to count how many students were in each bin, how would we do that? 
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP

gen one = 1 
collapse (mean) zscience7 (sum) one, by(zses_bin dpublic)	
// there are many other ways to achieve this, too. 

*-------------------------------------------------------------------------------
* Binning the scatter was useful in giving us an idea about where you might want to apply the spline function 
*-------------------------------------------------------------------------------/

* let's go back to our student-level data 
use "${data}lab7_prec_TMP.dta", clear 

// for simplicity, we'll focus on our public school kids only
keep if dpublic == 1 

// let's create three segments  
// <= -2 
// betwene -2 and 0 
// 0 or above 

gen zses_vlow = zses <= -2 
gen zses_low = zses > -2 & zses <0 
gen zses_higher = zses >= 0 

foreach var of varlist zses_vlow zses_low zses_higher {
	replace `var' = . if mi(zses)
	su zses if `var' == 1
}
// okay, no overlap 

* recall the basic regression looks like this
reg zscience7 zses 

* how do I add the spline function? 
// hint: what does each "line" from the spline function need?
// STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP

foreach var of varlist zses_vlow zses_low zses_higher {
	gen zsesX`var' = zses*`var'
}

reg zscience7 zses zses_low zses_higher zsesXzses_low zsesXzses_higher 
// omit the very low group 
// the intercepts are harder to understand here because of how zses is constructed
// so focus on just the slopes 

cap drop yhat 
predict yhat 
scatter yhat zses 


// because of the way the bins were created I change the "<= -2" to < -2 )
twoway  (scatter yhat zses if dpublic==1 & zses < -2, mcolor(gs3) msymbol(circle_hollow)) ///
		(scatter yhat zses if dpublic==1 & zses > -2 & zses < 0, mcolor(gs2) msymbol(circle_hollow)) ///
		(scatter yhat zses if dpublic==1 & zses >= 0, mcolor(black) msymbol(circle_hollow)) ///
		(lfit yhat zses if dpublic==1 & zses < -2, lcolor(gs3) lpattern(dash)) ///
		(lfit yhat zses if dpublic==1 & zses > -2 & zses < 0 , lcolor(gs2) lpattern(dash)) ///
		(lfit yhat zses if dpublic==1 & zses >= 0, lcolor(black) lpattern(dash)) ///
		, legend(order (1 "public very low ses" 2 "public lower ses" 3 "public higher ses") size(small) rows(1)) ///
		title("Science test score and ses") ///
		subtitle(public school only) ///
		ytitle("8th grade Science Test Score ") xtitle("STD. SES") ///
		note("note: very low ses is lower than 2 SD below the mean, lower ses is within 2 SD below the mean," "higher ses is at or above the mean" ) ///
		ylab(-2(1)2) ///
		name(bin4, replace)
		
** the below is a follow up on Amin's question 

* #1 I'll create a figure, bin5, using lfit to fit a best fit line for zscience7 and zses 
// and remember that this is still at the student-level 

twoway  (scatter yhat zses if dpublic==1 & zses < -2, mcolor(gs3) msymbol(circle_hollow)) ///
		(scatter yhat zses if dpublic==1 & zses > -2 & zses < 0, mcolor(gs2) msymbol(circle_hollow)) ///
		(scatter yhat zses if dpublic==1 & zses >= 0, mcolor(black) msymbol(circle_hollow)) ///
		(lfit zscience7 zses if dpublic==1 & zses < -2, lcolor(gs3) lpattern(dash)) ///
		(lfit zscience7 zses if dpublic==1 & zses > -2 & zses < 0 , lcolor(gs2) lpattern(dash)) ///
		(lfit zscience7 zses if dpublic==1 & zses >= 0, lcolor(black) lpattern(dash)) ///
		, legend(order (1 "public very low ses" 2 "public lower ses" 3 "public higher ses") size(small) rows(1)) ///
		title("Science test score and ses") ///
		subtitle(public school only) ///
		ytitle("8th grade Science Test Score ") xtitle("STD. SES") ///
		note("note: very low ses is lower than 2 SD below the mean, lower ses is within 2 SD below the mean," "higher ses is at or above the mean" ) ///
		ylab(-2(1)2) ///
		name(bin5, replace)
		
* #2 be reassured that the line created using yhat and the line created using zcsience 7 is giving you the same line here, when we are using student-level data 

* #3 the "problem" (or discrepancy) occured when we collapsed this down the bin-level 
		
* so, let's collapse the data. 
gen count = 1 
collapse (mean) yhat zscience7 dpublic (sum) count , by(zses_bin)			
		
		
* #4 let's try re-creating figure bin4 in the collapsed form 

// because of the way the bins were created I change the "<= -2" to < -2 )
twoway  (scatter yhat zses if dpublic==1 & zses < -2, mcolor(gs3) msymbol(circle_hollow)) ///
		(scatter yhat zses if dpublic==1 & zses > -2 & zses < 0, mcolor(gs2) msymbol(circle_hollow)) ///
		(scatter yhat zses if dpublic==1 & zses >= 0, mcolor(black) msymbol(circle_hollow)) ///
		(lfit yhat zses if dpublic==1 & zses < -2, lcolor(gs3) lpattern(dash)) ///
		(lfit yhat zses if dpublic==1 & zses > -2 & zses < 0 , lcolor(gs2) lpattern(dash)) ///
		(lfit yhat zses if dpublic==1 & zses >= 0, lcolor(black) lpattern(dash)) ///
		, legend(order (1 "public very low ses" 2 "public lower ses" 3 "public higher ses") size(small) rows(1)) ///
		title("Science test score and ses") ///
		subtitle(public school only) ///
		ytitle("8th grade Science Test Score ") xtitle("STD. SES") ///
		note("note: very low ses is lower than 2 SD below the mean, lower ses is within 2 SD below the mean," "higher ses is at or above the mean" ) ///
		ylab(-2(1)2) ///
		name(bin6, replace)		

* #5, figure bin4 and figure bin6 is the same, but we are only using yhat here so that makes sense

* #6, the figure looked different when we did this (a collapsed version of bin5)
// this is when we fit a line on zscience7 and zses, instead of on yhat and zses

twoway  (scatter yhat zses if dpublic==1 & zses < -2, mcolor(gs3) msymbol(circle_hollow)) ///
		(scatter yhat zses if dpublic==1 & zses > -2 & zses < 0, mcolor(gs2) msymbol(circle_hollow)) ///
		(scatter yhat zses if dpublic==1 & zses >= 0, mcolor(black) msymbol(circle_hollow)) ///
		(lfit zscience7 zses if dpublic==1 & zses < -2, lcolor(gs3) lpattern(dash)) ///
		(lfit zscience7 zses if dpublic==1 & zses > -2 & zses < 0 , lcolor(gs2) lpattern(dash)) ///
		(lfit zscience7 zses if dpublic==1 & zses >= 0, lcolor(black) lpattern(dash)) ///
		, legend(order (1 "public very low ses" 2 "public lower ses" 3 "public higher ses") size(small) rows(1)) ///
		title("Science test score and ses") ///
		subtitle(public school only) ///
		ytitle("8th grade Science Test Score ") xtitle("STD. SES") ///
		note("note: very low ses is lower than 2 SD below the mean, lower ses is within 2 SD below the mean," "higher ses is at or above the mean" ) ///
		ylab(-2(1)2) ///
		name(bin7, replace)
		
* you should now notice (as we saw in lab) that the "line" created from the yhat scatter and the "lfit" line are different. Why is this happening? We did not have this problem when we were using student-level data. 

/* this discrepany is happening because of the low (and non-uniform) number of observations in the zses bins between -6 and -2. If you recall from the histogram, there was a small number of observation in each of these bins, but not in a uniform way. However, if we run lfit with the collapsed data, we are treating every bin equally. But we should not, and the yhat predictions were not created under this assumption (every bin was effectively weighted by the number of students in each bin).  

see how the counts vary below 
*/

list zses_bin count 

// you should also notice that the counts get small and not uniform in the very high SES also. This is why the right-most line (the line for higher ses kids) created using lfit in figure bin7 is also off. Lfit is treating each bin equally, but it should not. This is the inherent limitation of using binned scatter when you have few observations in a bin. The "middle" line (line for the low ses kids) are not as affected by this because there are a lot of kids in all of the bins, so mean value of Y is much more precise and less sensitive to bin size. You can't tell but the lfit of this middle line is also slightly off (ever so slightly)

// how can I be sure? 
// I can run the same lfit, but now weighted by the number of observations, and now the best fit lines and the yhat scatter are completely aligned. 

twoway  (scatter yhat zses if dpublic==1 & zses < -2, mcolor(gs3) msymbol(circle_hollow)) ///
		(scatter yhat zses if dpublic==1 & zses > -2 & zses < 0, mcolor(gs2) msymbol(circle_hollow)) ///
		(scatter yhat zses if dpublic==1 & zses >= 0, mcolor(black) msymbol(circle_hollow)) ///
		(lfit zscience7 zses if dpublic==1 & zses < -2 [aw=count], lcolor(gs3) lpattern(dash)) ///
		(lfit zscience7 zses if dpublic==1 & zses > -2 & zses < 0 [aw=count], lcolor(gs2) lpattern(dash)) ///
		(lfit zscience7 zses if dpublic==1 & zses >= 0 [aw=count], lcolor(black) lpattern(dash)) ///
		, legend(order (1 "public very low ses" 2 "public lower ses" 3 "public higher ses") size(small) rows(1)) ///
		title("Science test score and ses") ///
		subtitle(public school only) ///
		ytitle("8th grade Science Test Score ") xtitle("STD. SES") ///
		note("note: very low ses is lower than 2 SD below the mean, lower ses is within 2 SD below the mean," "higher ses is at or above the mean" ) ///
		ylab(-2(1)2) ///
		name(bin8, replace)
				