/*ABE EXACT, 1930-1940, MEN, ON THE v26 INPUTS (2026-11-25). MACHINE A.     */
/*                                                                           */
/*1f_v26_inputs.do rebuilt every input from the 00655/00656 raw names with   */
/*abeclean 0.26 (the old stored names carried the pre-0.25 "marshall"        */
/*defect). This links the three versions the slides report, 1930 always     */
/*Ancestry (divided_file1930_v26_ans_cleaned):                              */
/*  Old         1940 Ancestry     -> link1930_1940_v26_cleaned_noraceblock0  */
/*  New         1940 model names  -> link1930_1940_v26_ml1940_cleaned_...0   */
/*  Target-only 1940 model names on target records only                      */
/*                                -> link1930_1940_v26_mltgt1940_cleaned_..0 */
/*Runs check_v26_same_input.do first (exit 9 on any difference). Every input is read only. Refuses to    */
/*start if any output or matcher folder exists.                             */
/*                                                                           */
/*  powershell -File replication/Run-Stata.ps1 MATCHING/_v26_run.do          */

if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local code "$REP_REPO/MATCHING/"
local intermediate "$REP_SNU/enum_date/DATA/INTERMEDIATE/"
local fi "$REP_F/enum_date/DATA/INTERMEDIATE/"

which abeclean
which abematch

foreach v in v26 v26_ml1940 v26_mltgt1940 {
	capture confirm file `"`intermediate'link1930_1940_`v'_cleaned_noraceblock0.dta"'
	if !_rc {
		display as error "link1930_1940_`v'_cleaned_noraceblock0.dta exists; move it aside first"
		exit 602
	}
}
/*THE MATCHER WRITES r<typeA><typeB if different><yr1>_<yr2> UNDER ITS CWD   */
/*($REP_F/.../INTERMEDIATE, 2_ABE line 99); A LEFTOVER FOLDER WOULD MIX RUNS.*/
foreach d in r_v26_ans_cleaned1930_1940 r_v26_ans_cleaned_v26_true_cleaned1930_1940 r_v26_ans_cleaned_v26_tgt_cleaned1930_1940 {
	mata: st_local("dex", strofreal(direxists(st_local("fi") + "`d'")))
	if `dex' {
		display as error "`fi'`d' exists; move it aside first"
		exit 602
	}
}
foreach d in divided_file1930_v26_ans_cleaned divided_file1940_v26_ans_cleaned divided_file1940_v26_true_cleaned divided_file1940_v26_tgt_cleaned {
	mata: st_local("dex", strofreal(direxists(st_local("fi") + "`d'")))
	if !`dex' {
		display as error "`fi'`d' missing; run 1f_v26_inputs.do"
		exit 601
	}
}

/*MANDATORY PREFLIGHT (2026-11-25 REVIEW): ABE AND MLP INPUTS IDENTICAL.     */
do `"`code'check_v26_same_input.do"'

/*ARGS 2_ABE: yr1 yr2 typeA location typeB                                  */
/*ARGS 3_append: yrs interval location reporting_error_only fsnames fs_years */
/*               fstype ml_years mltype anstype                              */
/*OLD                                                                       */
do `"`code'2_ABE_matchingV3_christian_torben.do"' 1930 1940 "_v26_ans_cleaned" 1
do `"`code'3_append_and_clean_all_links_christian_torbenV2.do"' "1930" 10 1 0 0 "" "" "" "" "_v26_ans_cleaned"
confirm file `"`intermediate'link1930_1940_v26_cleaned_noraceblock0.dta"'
/*NEW                                                                       */
do `"`code'2_ABE_matchingV3_christian_torben.do"' 1930 1940 "_v26_ans_cleaned" 1 "_v26_true_cleaned"
do `"`code'3_append_and_clean_all_links_christian_torbenV2.do"' "1930" 10 1 0 0 "" "" "1940" "_v26_true_cleaned" "_v26_ans_cleaned"
confirm file `"`intermediate'link1930_1940_v26_ml1940_cleaned_noraceblock0.dta"'
/*TARGET-ONLY                                                               */
do `"`code'2_ABE_matchingV3_christian_torben.do"' 1930 1940 "_v26_ans_cleaned" 1 "_v26_tgt_cleaned"
do `"`code'3_append_and_clean_all_links_christian_torbenV2.do"' "1930" 10 1 0 0 "" "" "1940" "_v26_tgt_cleaned" "_v26_ans_cleaned"
confirm file `"`intermediate'link1930_1940_v26_mltgt1940_cleaned_noraceblock0.dta"'
display "V26 RUN DONE"
