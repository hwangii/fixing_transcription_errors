/*****************************************************************************/
/*SIZE TWO HAZARDS BOTH REVIEWERS RAISED ON 2026-10-15                        */
/*(review/reports/2026-10-15_185622-HEAD_1..HEAD-{codex,agy}):                */
/*                                                                           */
/*  1. `keep if age>=10` RETAINS age==. (MISSING IS LARGER THAN ANY NUMBER). */
/*  2. `congruent = namefrst==fs_namefrst & namelast==fs_namelast` SCORES A  */
/*     BLANK-TO-BLANK FIELD AS AGREEMENT ("" == "" IS TRUE).                 */
/*                                                                           */
/*READ-ONLY: COUNTS ONLY, WRITES NO .dta AND NO EXHIBIT. RESULTS GO TO       */
/*replication/results/size_missing_age_and_blank_names.tex.                  */
/*                                                                           */
/*ARGUMENT `1' PICKS THE FILE:                                               */
/*  balance  F:/.../INTERMEDIATE/temp.dta, read by make_balance_exhibits.do  */
/*           (Tables 2-3), BEFORE its age/sex filter is applied.             */
/*  analysis enum_date/.../temp.dta, read by create_figures_SSHA2025.do's     */
/*           downstream scripts, AFTER its `keep if sex==1 & age>=10`.        */
/*****************************************************************************/

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"

args which
if "`which'" == "" local which "balance"

if "`which'" == "balance" {
	repnum open using "$REP_RESULTS/size_hazards_balance.tex", script(replication/diagnostics/size_missing_age_and_blank_names.do balance)
	/*NO NAME FIELDS IN THIS FILE: munir_figures_for_nber.do:257 DEFINES      */
	/*incongruent ONLY WHERE ALL FOUR NAME FIELDS ARE NON-BLANK, SO THE        */
	/*BLANK-NAME HAZARD CANNOT REACH TABLES 2-3. ONLY AGE IS SIZED HERE.       */
	use age female incongruent using "$REP_F/fixing_transcription_errors/DATA/INTERMEDIATE/temp.dta", clear
	/*THE SAMPLE make_balance_exhibits.do KEEPS, AND THE PART OF IT AGE==.*/
	quietly count if age>=10 & female==0
	repnum hzBalKept = r(N), format(%15.0fc)
	quietly count if missing(age) & female==0
	repnum hzBalMissingAge = r(N), format(%15.0fc)
	quietly count if missing(age) & female==0 & incongruent<.
	repnum hzBalMissingAgeInSample = r(N), format(%15.0fc)
	repnum close
	exit
}
else if "`which'" == "analysis" {
	repnum open using "$REP_RESULTS/size_hazards_analysis.tex", script(replication/diagnostics/size_missing_age_and_blank_names.do analysis)
	use age namefrst namelast fs_namefrst fs_namelast congruent using "$REP_SNU/enum_date/DATA/INTERMEDIATE/temp.dta", clear
	quietly count
	repnum hzAnaKept = r(N), format(%15.0fc)
	quietly count if missing(age)
	repnum hzAnaMissingAge = r(N), format(%15.0fc)
}
else {
	display as error "argument must be balance or analysis"
	exit 198
}

/*BLANK NAME FIELDS IN THE KEPT SAMPLE, AND AGREEMENTS RESTING ON ""=="".   */
/*A FIELD-LEVEL ""=="" MATCH IS ONLY POSSIBLE IF BOTH SIDES ARE BLANK.       */
gen byte anyblank  = namefrst=="" | namelast=="" | fs_namefrst=="" | fs_namelast==""
gen byte vacuous   = (namefrst=="" & fs_namefrst=="") | (namelast=="" & fs_namelast=="")
gen byte agree     = namefrst==fs_namefrst & namelast==fs_namelast
local P = cond("`which'"=="balance", "hzBal", "hzAna")
quietly count if anyblank
repnum `P'AnyBlank = r(N), format(%15.0fc)
quietly count if agree & vacuous
local nv = r(N)
repnum `P'VacuousAgree = `nv', format(%15.0fc)
repnum `P'VacuousAgreePct = 100*`nv'/_N, format(%9.4f)
repnum close
