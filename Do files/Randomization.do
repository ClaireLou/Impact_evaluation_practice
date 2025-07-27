*Created by: Claire Stein 
*All errors are the author's alone 

*To report errors/make suggestions or ask questions, please feel free to contact me - c.l.stein@rug.nl
*Last edited: 07/26/2024


clear							// clear any data in memory
set more off					// avoid pauses in the output
cd "/Users/clairestein/Documents/PhD_material/Impact_evaluation_summerschool" 
//create a pathway (directory) for your work - where you'll find the datasets and save logs and new data 

cap log close					// close any existing log file (quietly)
set logtype text				// use plain text format for log
log using Logs/RandomizationPractice.txt, replace

/**** Youth Financial Literacy Study in Ghana - Randomizing 
Stratified randomization at school level
Starting from: GhanaVocationalFinance_schoollist.dta (N = 40 schools) 
***/

/*** STEP 1: Load school list (one row per school) ***/
/*
We start with a dataset of 40 vocational schools
Variables: % female (prop_female), school size (school_size)
*/

use Dataset/GhanaVocationalFinance_schoollist.dta, clear

/*** STEP 2a: Explore the dataset ***/
/*
Quick look at the dataset:
 - Variable names and labels
 - Summary stats for key variables
 - How many schools
*/

describe

summarize


/*** STEP 2b: Construct strata: % female x school size ***/
/*
Four strata: High female + large school, etc.
Why? To improve balance across treatment/control on key school characteristics
*/

sum prop_female, detail
gen high_female = prop_female > r(p50)

sum school_size, detail
gen large_school = school_size > r(p50)

tab high_female large_school    // 2x2 cross-tab

egen strata = group(high_female large_school), label
label variable strata "Strata number: % female x school size"

tab strata


/*** STEP 3: Stratified randomization ***/
/*
Randomization unit = school
50% of schools assigned to Treatment within each stratum
Ensures T/C balance across: % female and school size

Note: If the number of schools in a stratum is odd, we can't assign exactly half to T/C.
For example, 7 schools → 3 vs 4. That's okay — randomization is still valid.
*/


set seed 314159                                // Set seed for reproducibility
gen random = runiform()                        // Random number per school

bysort strata (random): gen strata_index = _n   // Rank within stratum
bysort strata: gen strata_size = _N             // Stratum size
gen treat = strata_index <= strata_size/2       // 50% Treatment

/*
This rounds down when stratum size is odd, so treatment group may have fewer units.
Total balance may not be exactly 50/50 across all strata.
*/


gen treatment = "Control"
replace treatment = "Treatment" if treat == 1
label variable treatment "Treatment group"

tab treatment strata                           // Show distribution across strata


/*** STEP 4 (optional): Save randomization ***/
/*
Save into: DatasetPractice/GhanaVocationalFinance_schoolrandomization.dta 
You may need to create a new folder to save your data 
*/

save DatasetPractice/GhanaVocationalFinance_schoolrandomization.dta, replace


cap log close


