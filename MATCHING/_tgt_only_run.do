/*TARGET-ONLY LINKS, 1930-1940, MEN (2026-11-17). MACHINE A.                 */
/*                                                                           */
/*The slides say we replace names only on target records. This links 1930    */
/*Ancestry names to 1940 names in two versions, through the same code path:  */
/*  link1930_1940_mltgt1940_cleaned_noraceblock0.dta  model names on target  */
/*      records only, Ancestry's elsewhere (1c_tgt_divided_files.do)         */
/*  link1930_1940_ml1940_cleaned_noraceblock0.dta     model names on every   */
/*      record: the paper's "New" names, rerun here so the two differ only   */
/*      in which 1940 records get model names                                */
/*Refuses to start if any output or intermediate folder already exists.     */
/*                                                                           */
/*  powershell -File replication/Run-Stata.ps1 MATCHING/_tgt_only_run.do      */

if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local code "$REP_REPO/MATCHING/"
local intermediate "$REP_SNU/enum_date/DATA/INTERMEDIATE/"

which abeclean
which abematch

/*NEITHER OUTPUT MAY EXIST ALREADY: THIS RUN NEVER REPLACES A LINK FILE.*/
foreach v in mltgt1940 ml1940 {
	capture confirm file `"`intermediate'link1930_1940_`v'_cleaned_noraceblock0.dta"'
	if !_rc {
		display as error "link1930_1940_`v'_cleaned_noraceblock0.dta exists; move it aside first"
		exit 602
	}
}

/*NOR MAY ANY INTERMEDIATE FOLDER OR FILE THIS RUN WRITES: AN EXISTING ONE */
/*COULD BE A PAPER INPUT OR A PARTIAL EARLIER RUN.                         */
local fi "$REP_F/enum_date/DATA/INTERMEDIATE/"
foreach d in divided_file1940_tgt_cleaned r_ans_cleaned_tgt_cleaned1930_1940 r_ans_cleaned_true_cleaned1930_1940 {
	mata: st_local("dex", strofreal(direxists(st_local("fi") + "`d'")))
	if `dex' {
		display as error "`fi'`d' exists; move it aside first"
		exit 602
	}
}
capture confirm file `"`fi'tgt_flag1940.dta"'
if !_rc {
	display as error "`fi'tgt_flag1940.dta exists; move it aside first"
	exit 602
}

do `"`code'1c_tgt_divided_files.do"'

foreach t in _tgt_cleaned _true_cleaned {
	/*1930 ANCESTRY (DATASET A), 1940 OURS (DATASET B), LOCATION 1 = MACHINE A*/
	do `"`code'2_ABE_matchingV3_christian_torben.do"' 1930 1940 "_ans_cleaned" 1 "`t'"
	/*ARGS: yrs interval location reporting_error_only fsnames fs_years fstype ml_years mltype*/
	do `"`code'3_append_and_clean_all_links_christian_torbenV2.do"' "1930" 10 1 0 0 "" "" "1940" "`t'"
}
