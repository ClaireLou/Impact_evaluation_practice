*Created by: Claire Stein 
*All errors are the author's alone 

*To report errors/make suggestions or ask questions, please feel free to contact me - c.l.stein@rug.nl
*Last edited: 07/26/2024


clear
set more off
cd "/Users/clairestein/Documents/PhD_material/Impact_evaluation_summerschool"

cap log close
set logtype text
log using Logs/Power.txt, replace

/**** Example: Power Calculations with Clustering (STATA)
Using sampsi, power, and clustersampsi for different designs.
****/


/*** STEP 1: Power Visualization — Varying Effect Sizes ***/
* Goal: How power changes with different sample sizes and effect sizes
power twomeans 60 (65(5)80), sd(40) n(400(20)600) graph

/*
Interpretation:
- Simulates power across treatment effects of +5 to +20 (from 65 to 80)
- Uses SD = 40, common in savings outcomes
- Graph shows how larger effects or more observations boost power
*/


/*** STEP 1b: Power Visualization — Varying Standard Deviations ***/
* Goal: Fix effect size (60 vs. 70), vary SD to see impact on power
power twomeans 60 70, sd(20 25 30 40) n(400(20)600) graph

/*
Interpretation:
- Larger SD (outcome variance) reduces power
- Helps assess how sensitive results are to measurement precision
*/


/*** STEP 2: Power Calculation — Two-Sample (No Clustering) ***/
* Goal: Sample size required to detect a $5 difference in savings
sampsi 60 65, sd1(20) sd2(20) alpha(0.05) power(0.8)


 /*
Interpretation:
- Estimates sample size needed per group (control/treatment)
- Assumes independent randomization, no clustering
- SD = 20 in both groups
*/


/*** STEP 3: Power Calculation — Clustered Design ***/
* Goal: Calculate required number of clusters per arm
clustersampsi samplesize means, mu1(60) mu2(65) sd1(15) sd2(15) rho(0.05) m(30) alpha(0.05) beta(0.8)


 /*
Interpretation:
- Assumes group-level (e.g. savings group) randomization
- ICC = 0.05 reflects within-cluster similarity
- 30 individuals per cluster (m)
- Computes design effect and required number of clusters
*/

log close



