/*****************************************************************************/
/*DECOMPOSE THE 29,344-RECORD GAP BETWEEN THE TWO SAMPLES (2026-10-31).       */
/*                                                                           */
/*BOTH SAMPLES START FROM THE SAME PER-STATE FILES, merged_<state>1940.dta    */
/*(ANCESTRY MERGED WITH FAMILYSEARCH, clean_FS_and_combineV5_nber.do:102).   */
/*  BALANCE (draft line 400, 51,066,203): munir_figures_for_nber.do:233-278  */
/*    _merge==3, ALL FOUR NAMES NON-BLANK; THEN make_balance_exhibits.do     */
/*    KEEPS sex==1 (female==0) & age>=10.                                    */
/*  ANALYSIS (linkage results, 51,036,859):                                  */
/*    clean_FS_and_combineV5_nber.do:176-238 KEEPS _merge==3, ALL FOUR NAMES */
/*    NON-BLANK, AND age!=. & age_fs!=.  (THE EXTRA CONDITION);              */
/*    create_figures_SSHA2025.do:66,94 THEN MERGES THE MEN-ONLY IPUMS        */
/*    EXTRACT BY histid AND KEEPS sex==1 & age>=10 USING ITS sex AND age.    */
/*                                                                           */
/*THIS REBUILDS THE BALANCE SAMPLE RECORD BY RECORD AND CLASSIFIES EVERY     */
/*RECORD NOT IN THE ANALYSIS SAMPLE. READ-ONLY; COUNTS GO TO                 */
/*replication/results/decompose_sample_gap.tex.                              */
/*****************************************************************************/

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"

local dir "$REP_F/fixing_transcription_errors/DATA/INTERMEDIATE/"
local files : dir "`dir'" files "merged_*1940.dta"

repnum open using "$REP_RESULTS/decompose_sample_gap.tex", script(replication/diagnostics/decompose_sample_gap.do)

tempfile acc
local z = 0
foreach f of local files {
	use histid _merge sex age age_fs namefrst namelast namefrst_fs namelast_fs using `"`dir'`f'"', clear
	keep if _merge==3 & namefrst!="" & namelast!="" & namefrst_fs!="" & namelast_fs!=""
	/*BALANCE'S OWN SEX/AGE FILTER, ON THE STATE FILE'S sex AND age.*/
	gen byte in_bal = sex==1 & age>=10 & age<.
	/*THE LABELED DATA'S EXTRA CONDITION.*/
	gen byte agefs_ok = age<. & age_fs<.
	keep if in_bal | agefs_ok
	keep histid in_bal agefs_ok sex age
	rename (sex age) (sex_st age_st)
	if `z' > 0 append using `acc'
	save `acc', replace
	local ++z
}
display "state files read: `z'"

quietly count if in_bal
repnum gapBalN = r(N), format(%15.0fc)

/*THE ANALYSIS SAMPLE'S REMAINING STEP: THE IPUMS EXTRACT BY histid.*/
merge 1:1 histid using "$REP_F/enum_date/DATA/ORIGINAL/all_states_socio_demo_char_for_SSHA2025.dta", keepusing(sex age) keep(1 3)
gen byte in_ana = agefs_ok & _merge==3 & sex==1 & age>=10 & age<.
quietly count if in_ana
repnum gapAnaN = r(N), format(%15.0fc)

/*IN BALANCE, NOT IN ANALYSIS, BY THE FIRST CONDITION THAT EXCLUDES THEM.*/
quietly count if in_bal & !in_ana & !agefs_ok
repnum gapBalOnlyAgefsMissing = r(N), format(%15.0fc)
quietly count if in_bal & !in_ana & agefs_ok & _merge==1
repnum gapBalOnlyNotInExtract = r(N), format(%15.0fc)
quietly count if in_bal & !in_ana & agefs_ok & _merge==3
repnum gapBalOnlyAgeDiffers = r(N), format(%15.0fc)
/*IN ANALYSIS, NOT IN BALANCE: THE EXTRACT'S age/sex PUT THEM IN, THE STATE  */
/*FILE'S DID NOT.                                                            */
quietly count if in_ana & !in_bal
repnum gapAnaOnly = r(N), format(%15.0fc)
repnum close

tab in_bal in_ana
tab age_st if in_bal & !in_ana & agefs_ok & _merge==3, missing
