/*TARGET-ONLY LINKS WITHOUT THE "InvalidPred" SENTINEL, 1930-1940, MEN        */
/*(2026-11-22). MACHINE A. ABE EXACT.                                        */
/*                                                                           */
/*As _tgt_only_run.do's target-only version, with the one change that        */
/*1e_tgtns_divided_files.do replaces "invalidpred" by Ancestry's name field   */
/*(the fallback the pipeline applies to an empty model field). Writes        */
/*  link1930_1940_mltgtns1940_cleaned_noraceblock0.dta                       */
/*through the same matcher and append as _tgt_only_run.do. Every other file  */
/*is read only. Refuses to start if any output or intermediate exists.       */
/*                                                                           */
/*  powershell -File replication/Run-Stata.ps1 MATCHING/_tgtns_run.do         */

if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local code "$REP_REPO/MATCHING/"
local intermediate "$REP_SNU/enum_date/DATA/INTERMEDIATE/"
local fi "$REP_F/enum_date/DATA/INTERMEDIATE/"

which abeclean
which abematch

capture confirm file `"`intermediate'link1930_1940_mltgtns1940_cleaned_noraceblock0.dta"'
if !_rc {
	display as error "link1930_1940_mltgtns1940_cleaned_noraceblock0.dta exists; move it aside first"
	exit 602
}
foreach d in divided_file1940_tgtns_cleaned r_ans_cleaned_tgtns_cleaned1930_1940 {
	mata: st_local("dex", strofreal(direxists(st_local("fi") + "`d'")))
	if `dex' {
		display as error "`fi'`d' exists; move it aside first"
		exit 602
	}
}
/*THE SOURCE MUST BE THE TARGET-ONLY BUILD THE CURRENT RESULTS USE.*/
mata: st_local("dex", strofreal(direxists(st_local("fi") + "divided_file1940_tgt_cleaned")))
if !`dex' {
	display as error "`fi'divided_file1940_tgt_cleaned missing; run 1c_tgt_divided_files.do"
	exit 601
}

do `"`code'1e_tgtns_divided_files.do"'

/*1930 ANCESTRY (DATASET A), 1940 OURS (DATASET B), LOCATION 1 = MACHINE A*/
do `"`code'2_ABE_matchingV3_christian_torben.do"' 1930 1940 "_ans_cleaned" 1 "_tgtns_cleaned"
/*ARGS: yrs interval location reporting_error_only fsnames fs_years fstype ml_years mltype*/
do `"`code'3_append_and_clean_all_links_christian_torbenV2.do"' "1930" 10 1 0 0 "" "" "1940" "_tgtns_cleaned"

confirm file `"`intermediate'link1930_1940_mltgtns1940_cleaned_noraceblock0.dta"'
display "TGTNS RUN DONE"

/*SCORE ALL FIVE VERSIONS (REWRITES MATCHING/results/tgt_linkage_abe.md;   */
/*THE FOUR EXISTING COLUMNS ARE GATED AGAINST THE MAIN TABLE).            */
do `"`code'score_tgt_links.do"'
