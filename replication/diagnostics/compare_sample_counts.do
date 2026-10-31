/*****************************************************************************/
/*WHERE DO THE TWO SAMPLES DIFFER? (2026-10-31)                               */
/*                                                                           */
/*THE DRAFT'S "51,066,203 records transcribed by both" (LINE 400) IS THE     */
/*BALANCE FILE'S SAMPLE: make_balance_exhibits.do, incongruent<. AMONG MALES */
/*10+. THE LINKAGE RESULTS USE create_figures_SSHA2025.do'S ANALYSIS SAMPLE, */
/*51,036,859. NEITHER FILE KEEPS A COMMON PERSON ID (THE BALANCE FILE HAS NO */
/*histid), SO THIS COUNTS BOTH BY STATE x COUNTY x ENUMERATION DISTRICT AND  */
/*REPORTS WHERE THE COUNTS DISAGREE.                                         */
/*                                                                           */
/*READ-ONLY. COUNTS GO TO replication/results/compare_sample_counts.tex; THE */
/*CELL-LEVEL COMPARISON IS SAVED TO $REP_SCRATCH IF THAT IS SET.             */
/*****************************************************************************/

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"

repnum open using "$REP_RESULTS/compare_sample_counts.tex", script(replication/diagnostics/compare_sample_counts.do)

/*BALANCE SAMPLE, AS make_balance_exhibits.do DEFINES IT.*/
use statefip countyicp edist age female incongruent using "$REP_F/fixing_transcription_errors/DATA/INTERMEDIATE/temp.dta", clear
keep if age>=10 & age<. & female==0 & incongruent<.
quietly count
repnum cmpBalN = r(N), format(%15.0fc)
quietly count if incongruent==1
repnum cmpBalInc = r(N), format(%15.0fc)
gen long nB = 1
collapse (sum) nB incB=incongruent, by(statefip countyicp edist)
tempfile bal
save `bal'

/*ANALYSIS SAMPLE, AS create_figures_SSHA2025.do SAVES IT.*/
use statefip countyicp eventdistrict congruent using "$REP_SNU/enum_date/DATA/INTERMEDIATE/temp.dta", clear
quietly count
repnum cmpAnaN = r(N), format(%15.0fc)
quietly count if congruent==0
repnum cmpAnaInc = r(N), format(%15.0fc)
rename eventdistrict edist
gen long nA = 1
gen byte incA = congruent==0
collapse (sum) nA incA, by(statefip countyicp edist)

merge 1:1 statefip countyicp edist using `bal'
foreach v in nA nB incA incB {
	replace `v' = 0 if missing(`v')
}
gen long d = nB - nA
gen long dinc = incB - incA

/*CELLS IN ONLY ONE FILE, AND THE RECORDS IN THEM.*/
quietly count if _merge==1
repnum cmpCellsAnaOnly = r(N), format(%15.0fc)
quietly summarize nA if _merge==1
repnum cmpRecsAnaOnly = r(sum), format(%15.0fc)
quietly count if _merge==2
repnum cmpCellsBalOnly = r(N), format(%15.0fc)
quietly summarize nB if _merge==2
repnum cmpRecsBalOnly = r(sum), format(%15.0fc)

/*CELLS IN BOTH, WITH DIFFERENT COUNTS.*/
quietly count if _merge==3 & d!=0
repnum cmpCellsDiffer = r(N), format(%15.0fc)
quietly summarize d if _merge==3 & d>0
repnum cmpRecsBalMore = r(sum), format(%15.0fc)
quietly summarize d if _merge==3 & d<0
repnum cmpRecsAnaMore = -r(sum), format(%15.0fc)
quietly summarize d
repnum cmpNetGap = r(sum), format(%15.0fc)
repnum close

/*WHERE THE GAP SITS, FOR READING IN THE LOG.*/
tab _merge
preserve
collapse (sum) nA nB d dinc, by(statefip)
list statefip nA nB d dinc if d!=0, noobs sep(0)
restore
gsort -d
list statefip countyicp edist nA nB d _merge in 1/30, noobs sep(0)
gsort d
list statefip countyicp edist nA nB d _merge in 1/15, noobs sep(0)
summarize d if _merge==3 & d!=0, detail

if `"$REP_SCRATCH"'!="" save `"$REP_SCRATCH/compare_sample_cells.dta"', replace
