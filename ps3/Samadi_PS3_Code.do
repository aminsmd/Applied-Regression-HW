pwd
global project "/Users/amin/Documents/winter2021/AppRegLab/ps3/"
display "$project"

cd "${project}"
global output "${project}output/"
use for_ps3.dta, clear


//2


// Locate the variables for teacher-reported internalizing, externalizing, and approaches to learning.  We will use the fall AND spring kindergarten measures of these behavioral ratings (Hint: use “lookfor” command to find the variables. Beware, our dataset also contains parent-reported ratings of the same behaviors.  The teacher-reported variables should begin with the letter “t” (e.g., t1learn, t1extern, etc.).  

// On each of the 6 variables, missing values need to be recoded to “.” (Hint: after recoding them, you should have a mean of “2.96” for teacher-reported approaches to learning in the fall, with a range of 1 to 4). Recode these values and paste your code into your answer sheet.  

lookfor internalizing
lookfor externalizing
lookfor approaches

forvalues i = 1(1)2 {
	replace t`i'intern = . if t`i'intern < 0
	replace t`i'extern = . if t`i'extern < 0
	replace t`i'learn = . if t`i'learn < 0
}


//3

// Descriptive Table 

// Set an analysis sample “ps3_sample” that only includes students who had non-missing data on all 6 teacher behavioral reports, and non-missing data on race/ethnicity. The analysis sample should include 16,873 students. Paste your code for creating this analysis sample into your answer sheet.   

gen ps3_sample = 0 
replace ps3_sample = 1 if !mi(t1intern, t2intern, t1extern, t2extern, t1learn, t2learn, race)
tab ps3_sample

// Generate a single descriptive table that includes means, standard deviations, and values at the 25th and 75th percentiles for each of our 6 behavioral measures. Present these descriptive statistics for the full analysis sample, White students in the analysis sample, Black students in the analysis sample, and Hispanic students in the analysis sample. All descriptive statistics should include two digits after the decimal. Format the table according to APA standards and guidelines outlined in the lab; see below for an example. Paste the table into your answer sheet. (My table is in blue, and your table should be in black) 

global beh_mes "t1intern t2intern t1extern t2extern t1learn t2learn"

est clear

// full sample
estpost summarize $beh_mes if ps3_sample == 1, detail
est store s1

// white students
estpost summarize $beh_mes if ps3_sample == 1 & race == 1, detail
est store s2

// black students
estpost summarize $beh_mes if ps3_sample == 1 & race == 2, detail
est store s3

//hispanic students
estpost summarize $beh_mes if ps3_sample == 1 & race == (3 | 4), detail
est store s4

label var t1intern "Internalizing Problem - fall K"
label var t2intern "Internalizing Problem - spring K"
label var t1extern "externalizing Problem - fall K"
label var t2extern "externalizing Problem - spring K"
label var t1learn "Approach to Learning - fall K"
label var t2learn "Approach to Learning - spring K"

esttab s1 s2 s3 s4 using "${output}ps3_behavioralmeasures.csv", ///
	cells("mean(fmt(2)) sd(fmt(2)) p25(fmt(2)) p75(fmt(2))") ///
	title("Descriptive statistics of behavioral measures") ///
	mtitle("Full sample" "White" "Black" "Hispanic") ///
	addnote("SD = Standard Deviation, p25 = 25th percentile, p75 = 75th percentile") ///
	replace label nogaps plain

//4

// Run ANOVA comparing ethnicity group differences (i.e. Black, Asian, Hispanic, White, Other; hint: use simplified race categorical variable) on spring teacher-reported externalizing, internalizing, and approaches to learning. Paste your code below.


oneway t2extern race_simp if ps3_sample == 1
oneway t2intern race_simp if ps3_sample == 1
oneway t2learn race_simp if ps3_sample == 1

// What is the mean externalizing behavioral problems for White students and Asian Students? What is their group difference in externalizing behavioral problems? Is this group difference statistically significant? How do you know (report the apprpriate statistics)?  

codebook race_simp

oneway t2extern race_simp if ps3_sample == 1, tab
pwmean t2extern if ps3_sample == 1, over(race_simp) mcompare(tukey) effects

// Run three regression models investigating the links between ethnicity (i.e., race dummies) and spring teacher-reported externalizing, internalizing, and approaches to learning. The dummy variable for White will be omitted as the comparison group. Paste the code for all three regressions into your answer sheet. 


foreach var of varlist t2extern t2intern t2learn {
	reg `var' dblack dhispanic dasian dother if ps3_sample == 1
}

// Standardize the fall and spring teacher reported measures of internalizing, externalizing, and approaches to learning.  Copy and paste your code for this step into your answer sheet. 

foreach var of varlist t1intern t2intern t1extern t2extern t1learn t2learn {
	egen z`var' = std(`var')
}

su zt1intern

// Re-run the regression models from step 4.c with the standardized dependent variables.  Did the results meaningfully change when compared with the raw score models?

foreach var of varlist t2extern t2intern t2learn {
	reg z`var' dblack dhispanic dasian dother if ps3_sample == 1
}

// Report and interpret the coefficient relating the standardized measure of spring teacher-reported internalizing to whether a student identifies as Black.

reg zt2intern dblack dhispanic dasian dother if ps3_sample == 1

// Now, run the set of standardized regressions again, but add the lagged measure of the dependent variable for each model as a control.  Paste your code into the answer sheet (Hint: This means that for the externalzing regression, the dependent variable will be the spring externalizing measure and the independent variables will be the set of ethnicity dummies, in addition to the standardized measure of fall teacher-reported externalizing).

reg zt2extern dblack dhispanic dasian dother zt1extern if ps3_sample == 1
reg zt2intern dblack dhispanic dasian dother zt1intern if ps3_sample == 1
reg zt2learn dblack dhispanic dasian dother zt1learn if ps3_sample == 1

// Compare the internalizing model in step 4.h with the model in step 4.i (i.e., the standardized model without lagged control vs. the standardized model with lagged control).  Describe what happened to the coefficients produced by the set of ethnicity dummies once the control for fall internalizing was added. Intuitively, what does this change suggest about the nature of teacher’s perceptions of student behavioral problems over the course of the kindergarten year?  



// Generate a table that presents estimates of the relations between ethnicity and spring kinderharten teacher-reported beahviors when 1) not controlling for fall teacher ratings ratings and 2) controlling for fall teacher ratings. The table should include 2 models for each spring measure of behavior (i.e., internalizing, externalizing, and approches to learning): the first model will just include the set of ethnicity dummies and the second model will add the lagged depenent variable. Omit White students as the comparison group in each of the models.  

// In other words, generate an APA-formatted table that displays the estimates from steps 4.h and 4.i. Your table should have 6 columns in total, and include notes on anything needed to fully interpret the coefficients. These notes are very important because you want your table to be self-contained as much as possible so that a reader who is skimming your paper can fully understand your table. Paste the table into your answer sheet (Hint: remember to use your analysis sample variable to keep the sample size constant across the models). 

est clear

reg zt2extern dblack dhispanic dasian dother if ps3_sample == 1
est store ext1
reg zt2intern dblack dhispanic dasian dother if ps3_sample == 1
est store int1
reg zt2learn dblack dhispanic dasian dother if ps3_sample == 1
est store lrn1


reg zt2extern dblack dhispanic dasian dother zt1extern if ps3_sample == 1
est store ext2
reg zt2intern dblack dhispanic dasian dother zt1intern if ps3_sample == 1
est store int2
reg zt2learn dblack dhispanic dasian dother zt1learn if ps3_sample == 1
est store lrn2

label var dblack "black"
label var dhispanic "hispanic"
label var dasian "asian"
label var dother "other"

label var zt1intern "Standardized Internalizing Problem - fall K"
label var zt2intern "Standardized Internalizing Problem - spring K"
label var zt1extern "Standardized externalizing Problem - fall K"
label var zt2extern "Standardized externalizing Problem - spring K"
label var zt1learn "Standardized Approach to Learning - fall K"
label var zt2learn "Standardized Approach to Learning - spring K"


esttab ext1 int1 lrn1 ext2 int2 lrn2 using "${output}ps3-regression-tables_2.csv", ///
	b(2) se(2) r2 ///
	title("Behavioral measurements gap between white students and other ethnicities in spring of kindergarten") ///
	mtitle("externalizing behavior" "internalizing behavior" "approach-to-learning" "externalizing behavior" "internalizing behavior" "approach-to-learning" ) ///
	addnote("Note: First three columns include regression results without controling for fall measurements and the second three columns include results with controling of fall measurements. Whites measurements are omitted from the set, therefore all the coefficients are relative to that group") ///
	replace label

	
save for_lab4.dta, replace
