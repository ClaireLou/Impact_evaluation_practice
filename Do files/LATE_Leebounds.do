*Created by: Claire Stein 
*All errors are the author's alone 

*To report errors/make suggestions or ask questions, please feel free to contact me - c.l.stein@rug.nl
*Last edited: 07/26/2024


clear
set more off
cd "/Users/clairestein/Documents/PhD_material/Impact_evaluation_summerschool"

cap log close
set logtype text
log using Logs/LATE_LeeBounds.txt, replace

/**** Youth Financial Literacy Study in Ghana - LATE and Leebounds (Updated)
Dataset: GhanaVocationalFinance_randomized_endline.dta
Includes treatment, take-up, and survey attrition.
****/

/*** STEP 1: Load dataset ***/
use Dataset/GhanaVocationalFinance_randomized_endline.dta, clear

/*** STEP 2: Descriptive table of compliance and attrition ***/
tab took_training treatment
/*
randomization was done at the school level, so control group could not benefit from the treatment */

tab took_training endline_observed if treatment == 1
/*
Interpretation:
- 4 students neither took up training nor participated in the survey
- 134 students did not take up training but responded to the survey
- 37 students took training but did not respond to the survey
- 725 students took training and responded to the survey
*/



/*** STEP 3: LATE Estimation ***/
/*
Estimate TOT (LATE) using IV: treatment instrumenting actual take-up (took_training)
Only among observed students (compliers)
*/
reg took_training treatment i.strata, vce(cluster schoolid)

ivregress 2sls end_savings (took_training = treatment) i.strata, vce(cluster schoolid)
//estimates store late_savings



/*** STEP 4: Attrition test ***/

/* manually check attrition (do not respond to the survey) */
tab endline_observed treatment

reg endline_observed treatment i.strata, vce(cluster schoolid)

reg endline_observed treatment female household_income rural i.strata, vce(cluster schoolid)
* Check if attrition differs across treatment and control and across other characteristics


/*** STEP 5: Lee Bounds ***/


/*
Lee bounds to adjust for attrition bias — trimming treated group to match control attrition
*/
ssc install leebounds, replace

reg end_savings treatment i.strata, vce(cluster schoolid)
/*
check coefficient to interpret bounds
*/

leebounds end_savings treatment, select(endline_observed)
leebounds end_savings treatment, select(endline_observed) tight(strata)




/*** STEP 5b: Lee Bounds (manually)
The leebounds command does not allow for clustering, fixed effects, etc. so let's also see how to do it manually

Approach: Trim the treatment group to match the attrition rate in the control group, assuming:
- Best-case scenario (lower bound): those lost in treatment had the worst outcomes
- Worst-case scenario (upper bound): those lost in treatment had the best outcomes
*/


* i. Tabulate attrition by treatment status
tab endline_observed treatment
/*
- Control attrition rate = 125/1100 = 11.36%
- Treatment attrition rate = 41/900 = 4.56%
→ Differential attrition = 6.8% (higher in control)
→ We will trim 6.8% of the observed treatment group to match
→ 6.8% × 900 = ~61 observations to trim
*/


* ii. Generate ranked variables for trimming (within treatment group)
set seed 124  		// for reproducibility

* Only rank non-missing endline observations
egen Asc_rank_end_savings = rank(end_savings) if treatment == 1 & end_savings < ., unique	// ascending (to trim top savings)
egen Desc_rank_end_savings = rank(-end_savings) if treatment == 1 & end_savings < ., unique // descending (to trim bottom savings)


sort end_savings

br end_savings Asc_rank_end_savings Desc_rank_end_savings if treatment == 1

* iii. Create upper and lower bound outcome variables
gen 	upper_end_savings = end_savings
replace upper_end_savings = . if treatment == 1 & Asc_rank_end_savings <= 61
// Trimming best outcomes -> conservative upper bound

gen 	lower_end_savings = end_savings
replace lower_end_savings = . if treatment == 1 & Desc_rank_end_savings <= 61
// Trimming worst outcomes -> conservative lower bound

* Optional: Browse trimmed data
br end_savings Asc_rank_end_savings Desc_rank_end_savings upper_end_savings lower_end_savings if treatment == 1


* iv. Estimate treatment effects using trimmed outcomes
reg lower_end_savings treatment i.strata, vce(cluster schoolid)

reg upper_end_savings treatment i.strata, vce(cluster schoolid)




log close
