pwd
global project "/Users/amin/Documents/winter2021/AppRegLab/ps4/"
display "$project"

cd "${project}"
global output "${project}output/"
use for_ps4.dta, clear

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

global controls "age_m weight_o dfemale p1chlboo over30 teenager wksesl dwicmom"
global race_dummies "dblack dhispanic dasian dother"
global standardized_tests "zmath1 zmath2 zmath4 zmath5"
global all_variables "zmath1 zmath2 zmath4 zmath5 age_m weight_o dfemale p1chlboo over30 teenager wksesl dwicmom"

// 1. Quadratic

// a.

// b.

lookfor books

replace p1chlboo = . if p1chlboo < 0

reg zmath1 p1chlboo

gen booksq = p1chlboo * p1chlboo

reg zmath1 p1chlboo booksq

display -(.0150433)/(2 * -.0000481)

// 2. Tables

foreach var of varlist race gender p1wicmom p1hmafb p1weighp age p1chlboo{
	replace `var' = . if `var' < 0
}

replace wksesl = . if wksesl == -9

gen over30 = .
replace over30=0 if p1hmafb !=. 
replace over30=1 if (p1hmafb > 30 & p1hmafb <100)
tab over30 , m	

gen teenager = .
replace teenager=0 if p1hmafb !=. 
replace teenager=1 if (12 < p1hmafb & p1hmafb < 20)
tab teenager , m	

gen dwicmom = .
replace dwicmom=0 if p1wicmom !=. 
replace dwicmom=1 if p1wicmom == 1
tab dwicmom , m	

gen weight_o = .
replace weight_o = 16 * p1weighp if p1weighp != .

gen age_m = .
replace age_m = 12 * age if age != .


gen replicate_sample = 0 
replace replicate_sample = 1 if !mi(zmath1, zmath2, zmath4, zmath5, race, dfemale, over30, teenager, dwicmom, weight_o, wksesl, age, p1chlboo)
tab replicate_sample

// Table 1

est clear

// full sample
estpost summarize $all_variables if replicate_sample == 1, detail
est store s1

// white students
estpost summarize $all_variables if replicate_sample == 1 & dwhite == 1, detail
est store s2

// black students
estpost summarize $all_variables if replicate_sample == 1 & dblack == 1, detail
est store s3

//hispanic students
estpost summarize $all_variables if replicate_sample == 1 & dhispanic == 1, detail
est store s4

//hispanic students
estpost summarize $all_variables if replicate_sample == 1 & dasian == 1, detail
est store s5

label var age_m "Age (in months)"
label var weight_o "Birth Weight (oz)"
label var dfemale "Female"
label var p1chlboo "Number of children's books"
label var over30 "Mother over 30 at first birth"
label var teenager "Mother a teenager at first birth"
label var dfemale "Female"
label var wksesl "Socioeconomic status measure"
label var dwicmom "Mother receives WIC benefits"
label var dblack "Black"
label var dhispanic "Hispanic"
label var dasian "Asian"
label var dother "Other"

esttab s1 s2 s3 s4 s5 using "${output}ps4_table1.csv", ///
	cells("mean(fmt(3)) sd(fmt(3))") ///
	title("Descriptive Statistics of All Analysis Variables by Race") ///
	mtitle("Full sample" "White" "Black" "Hispanic" "Asian") ///
	addnote("SD = Standard Deviation, Note. The sample is restricted to those with no missing data on any of the variables presented.  Test scores are normalized IRT scores, standardized to a mean of 0 and SD of 1 in the full, unrestricted sample. Standard deviations are only presented for continuous variables.") ///
	replace label nogaps plain

// Table 2

est clear

foreach var of varlist $standardized_tests{
	reg `var' $race_dummies if replicate_sample == 1
	est store `var'_1
	reg `var' $race_dummies $controls if replicate_sample == 1
	est store `var'_2
}

esttab zmath1_1 zmath2_1 zmath4_1 zmath5_1 zmath1_2 zmath2_2 zmath4_2 zmath5_2 using "${output}ps4_table2.csv", ///
	b(3) se(3) r2 ///
	title("Estimated Racial Achievement Gap Over the First Four Years of School, Math (Replication of Fryer and Levitt, 2006)") ///
	mtitle("K- Entry" "Spring K" "Spring 1st" "Spring 3rd" "K- Entry" "Spring K" "Spring 1st" "Spring 3rd" ) ///
	addnote("Note. Test scores are standardized IRT score. Non-Hispanic Whites are the omitted race category. Standard errors are in parentheses.") ///
	replace label
	
	
// 3. Graph



// 5. Add dummies

// Create dummy variables for mother’s education and paste your code for this into your answer sheet. That is, take the “wkmomed” variable and generate three mutually exclusive dummy variables: 
// 1) mothers with less than a high school diploma; 
// 2) mothers with a high school diploma, vocational school, or some college; 
// 3) mothers that graduated from college or attended graduate school. 

tab wkmomed

replace wkmomed = . if wkmomed < 0

gen dmomed1 = .
replace dmomed1=0 if wkmomed !=. 
replace dmomed1=1 if wkmomed < 3
tab dmomed1 , m	

gen dmomed2 = .
replace dmomed2=0 if wkmomed !=. 
replace dmomed2=1 if ( wkmomed >= 3 & wkmomed < 6)
tab dmomed2 , m

gen dmomed3 = .
replace dmomed3=0 if wkmomed !=. 
replace dmomed3=1 if (wkmomed >= 6 & wkmomed != . )
tab dmomed3 , m

// 6. Prepare controls

// •	Standardized fall of kindergarten reading achievement “zread1”
// •	Dummies for race (omit Whites as the comparison group)—dblack, dhispanic, dasian, dother
// •	Mom’s education dummies that you created (omit mothers with less than a high school diploma as the comparison group)
// •	The following variables from the Fryer & Levitt controls from Q2: age in months, birthweight in oz, female, number of children’s books, mother over 30 at first birth, mom a teenager at first birth, socioeconomic status, mom received WIC benefits. (notice, we are not adding books2)

global interactcontrols "zread1 dblack dhispanic dasian dother dmomed2 dmomed3 age_m weight_o dfemale p1chlboo over30 teenager wksesl dwicmom"

// 7. Interactions

gen interact_samp = 0 
replace interact_samp = 1 if !mi(zmath1, zmath2, zread1, zread2, race, dfemale, over30, teenager, dwicmom, weight_o, wksesl, age, p1chlboo)
tab interact_samp

est clear

// b

reg zmath2 zmath1 if (dfemale == 1 & interact_samp == 1)
est store m1

reg zmath2 zmath1 if (dfemale == 0 & interact_samp == 1)
est store m2
// c

gen zmath1Xdfemale = zmath1 * dfemale

reg zmath2 zmath1 dfemale zmath1Xdfemale if interact_samp == 1
est store m3

// e

reg zmath2 zmath1 $interactcontrols zmath1Xdfemale if interact_samp == 1
est store m4
// g

global interactions

foreach var of varlist zread1 dblack dhispanic dasian dother dmomed2 dmomed3 age_m weight_o dfemale p1chlboo over30 teenager wksesl dwicmom{
	gen `var'Xdfemale = `var' * dfemale
	global interactions "$interactions `var'Xdfemale"
}

global interactions "zmath1Xdfemale $interactions"

reg zmath2 zmath1 $interactcontrols $interactions if interact_samp == 1
est store m5

test zmath1Xdfemale = zread1Xdfemale = dblackXdfemale = dhispanicXdfemale = dasianXdfemale = dotherXdfemale = dmomed2Xdfemale = dmomed3Xdfemale = age_mXdfemale = weight_oXdfemale = dfemaleXdfemale = p1chlbooXdfemale = over30Xdfemale = teenagerXdfemale = wkseslXdfemale = dwicmomXdfemale = 0

label var zmath1Xdfemale "Math K entry score x Female"


esttab m* using "${output}ps4_table3.csv", ///
	b(3) se(3) r2 nogaps label replace ///
	keep(zmath1 dfemale zmath1Xdfemale _cons) ///
	addnote("Note. Standard errors in parentheses. Inc. indicates included. Control variables include: child ethnicity, age, birthweight in ounces, number of books in the home, number of books in the home squared, whether mother was over 30 at first birth, whether mother was a teenager at first birth, ECLS-K derived continuous measure of socioeconomic status, whether mother received WIC benefits during pregnancy, mother’s level of education (less than high school diploma is the omitted category). *p<.05, **p<.01, ***p<.001.") ///
	mtitle("Model 1" "Model 2" "Model 3" "Model 4" "Model 5")

