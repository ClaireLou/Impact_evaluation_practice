*Created by: Claire Stein 
*All errors are the author's alone 

*To report errors/make suggestions or ask questions, please feel free to contact me - c.l.stein@rug.nl
*Last edited: 07/26/2024

clear
set more off
cd "/Users/clairestein/Documents/PhD_material/Impact_evaluation_summerschool"

cap log close
set logtype text
log using Logs/BalanceTestPractice.txt, replace

/**** Youth Financial Literacy Study in Ghana - Balance tests
Randomization at school level
Dataset: GhanaVocationalFinance_randomized_baseline.dta
****/

/*** STEP 1: Load randomized dataset ***/
/*
We use the merged dataset with individual-level observations
and school-level treatment assignment:
    GhanaVocationalFinance_randomized_baseline.dta
*/

use Dataset/GhanaVocationalFinance_randomized_baseline.dta, clear

/*** STEP 2a: Explore the data ***/
/*
Quick check:
    - Variable names and labels
    - Number of schools (clusters)
    - Number of students
    - Distribution of treatment
*/

describe
summarize
tab schoolid treatment

/*** STEP 2b: Reminder - Why balance tests? ***/
/*
Goal:
    - Check if treatment and control schools are balanced
    - We expect no major significant differences at baseline (less than 5%)
*/

/*** STEP 3a: Balance test - Method 1: collapse to school-level ***/
/*
For each school, calculate the average of baseline covariates
Then test for balance at the school level (since randomization is at school level)
*/

collapse (mean) savings financial_literacy_score confidence 	///
				knows_budgeting mobile_money_use 				///
				household_income caregiver_edu age female rural ///
				, by(schoolid treatment strata)

/* T-tests at school level */
ttest savings					, by(treatment)
ttest financial_literacy_score	, by(treatment)
ttest confidence				, by(treatment)

/* Optional: regressions at school level */
reg savings 					treatment
reg financial_literacy_score 	treatment
reg confidence 					treatment

/* Optional: save school-level dataset */
save DatasetPractice/GhanaVocationalFinance_schoollevel_balance.dta, replace

/*** STEP 3b: Balance test - Method 2: individual-level regressions with clustering ***/

/*
Alternative approach:
Regress baseline covariates on treatment, with clustered SEs (schoolid)
Keeps individual-level data
*/

use Dataset/GhanaVocationalFinance_randomized_baseline.dta, clear

reg savings 					treatment 	i.strata, vce(cluster schoolid)
reg financial_literacy_score 	treatment 	i.strata, vce(cluster schoolid)
reg confidence 					treatment 	i.strata, vce(cluster schoolid)
reg household_income 			treatment 	i.strata, vce(cluster schoolid)
reg knows_budgeting				treatment 	i.strata, vce(cluster schoolid)

cap log close
