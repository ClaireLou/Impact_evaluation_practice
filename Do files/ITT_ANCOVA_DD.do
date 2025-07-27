*Created by: Claire Stein 
*All errors are the author's alone 

*To report errors/make suggestions or ask questions, please feel free to contact me - c.l.stein@rug.nl
*Last edited: 07/26/2024


clear
set more off
cd "/Users/clairestein/Documents/PhD_material/Impact_evaluation_summerschool"

cap log close
set logtype text
log using Logs/ITT_ANCOVA_DD.txt, replace


/**** Youth Financial Literacy Study in Ghana - ITT ANCOVA and Double Difference (DD)
Randomization at school level
Dataset: GhanaVocationalFinance_randomized_endline.dta
****/

/*** STEP 1: Load Data ***/
use Dataset/GhanaVocationalFinance_randomized_endline.dta, clear

describe
summarize

/*** STEP 2: ITT Estimation ***/
/*
Estimate Intention-to-Treat effects by comparing means between treatment and control
We cluster SEs at school level, and control for strata if stratified randomization was done.
*/
reg end_savings 		treatment 				i.strata, vce(cluster schoolid)

/*Add controls (age, gender)*/
reg end_savings 		treatment age female 	i.strata, vce(cluster schoolid)	


//Practice ITT estimations on your own with other variables: end_savings end_business_knowledge end_entrepreneurship_index end_confidence end_finlit_score end_knows_budgeting end_mobile_money_use 




/*** STEP 3: ANCOVA Estimation ***/
/*
ANCOVA = Adjust for baseline outcome. Higher power than DD when baseline is predictive.
*/
reg end_savings 		treatment savings 		i.strata, vce(cluster schoolid)


/*** STEP 4: Difference-in-Differences Estimation ***/
/*
Stack baseline and endline data, create time and interaction terms
*/

/*
You'll need to run lines 47 to 54 together, not one by one */

gen time = 1   														//Generate endline time indicator 
tempfile endline													//Create and save a temporary file
save `endline'

use Dataset/GhanaVocationalFinance_randomized_baseline.dta, clear
gen time = 0   														//Generate baseline time indicator

append using `endline'												//Stack baseline and endline datasets


gen 	Y_savings 		= savings									//Generate the stacked outcome var (baseline)
replace Y_savings 		= end_savings 	if time == 1				//Add endline data to the variable

gen 	post_T = treatment * time									//Generate the interaction term			

/*Let's check what happened in the dataset after these commands*/
sort unique_ID
br unique_ID treatment time post_T Y_savings 


reg 	Y_savings 	treatment time  post_T 			i.strata, vce(cluster schoolid)


reg 	Y_savings 					treatment##time i.strata, vce(cluster schoolid)


*** Done ***
log close
