/*FAMILYSEARCH VERSIONS (a)-(d), ABE EXACT, 1930-1940, MEN, v26 BASE         */
/*(2026-11-25). MACHINE A. Builds the inputs (1g_v26_fs_inputs.do) and      */
/*links the four versions:                                                   */
/*  (a) 1930 v26_ans x 1940 v26_fstgt   -> link1930_1940_v26_fstgt1940_...   */
/*  (b) not run: equals (a) by construction (see below)                      */
/*  (c) 1930 v26_fs  x 1940 v26_fs      -> link1930_1940_v26_fs1930_1940_... */
/*  (d) 1930 v26_fs  x 1940 v26_fsmltgt -> link1930_1940_v26_fs1930_1940_mltgt1940_... */
/*(all ..._cleaned_noraceblock0.dta). Refuses to start if any output or     */
/*matcher folder exists.                                                     */
/*                                                                           */
/*  powershell -File replication/Run-Stata.ps1 MATCHING/_v26_fs_run.do       */

if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local code "$REP_REPO/MATCHING/"
local intermediate "$REP_SNU/enum_date/DATA/INTERMEDIATE/"
local fi "$REP_F/enum_date/DATA/INTERMEDIATE/"

which abeclean
which abematch

/*RUNS: typeA typeB tag                                                     */
local r1 _v26_ans_cleaned _v26_fstgt_cleaned   _v26_fstgt1940
/*(b) IS NOT RUN (AUTHOR, 2026-11-25): A NON-TARGET RECORD HAS FAMILYSEARCH  */
/*NAME == ANCESTRY NAME BY THE TARGET DEFINITION, AND fs_names1940 HOLDS    */
/*ONLY census1940_all_labeled_data RECORDS, SO (b) EQUALS (a) BY            */
/*CONSTRUCTION. divided_file1940_v26_fs_cleaned IS STILL BUILT FOR (c).     */
local r2 _v26_fs_cleaned  _v26_fs_cleaned      _v26_fs1930_1940
local r3 _v26_fs_cleaned  _v26_fsmltgt_cleaned _v26_fs1930_1940_mltgt1940

forvalues i = 1/3 {
	tokenize `r`i''
	capture confirm file `"`intermediate'link1930_1940`3'_cleaned_noraceblock0.dta"'
	if !_rc {
		display as error "link1930_1940`3'_cleaned_noraceblock0.dta exists; move it aside first"
		exit 602
	}
	local B ""
	if "`2'"!="`1'" local B "`2'"
	mata: st_local("dex", strofreal(direxists(st_local("fi") + "r`1'`B'1930_1940")))
	if `dex' {
		display as error "`fi'r`1'`B'1930_1940 exists; move it aside first"
		exit 602
	}
}

do `"`code'1g_v26_fs_inputs.do"'

forvalues i = 1/3 {
	tokenize `r`i''
	local tA `1'
	local tB `2'
	local tag `3'
	display _n "===== RUN `i': `tA' x `tB' -> `tag'"
	if "`tA'"=="`tB'" do `"`code'2_ABE_matchingV3_christian_torben.do"' 1930 1940 "`tA'" 1
	else              do `"`code'2_ABE_matchingV3_christian_torben.do"' 1930 1940 "`tA'" 1 "`tB'"
	/*ARGS 3_append: yrs interval location reporting_error_only fsnames fs_years */
	/*fstype ml_years mltype anstype typeA typeB tag                             */
	do `"`code'3_append_and_clean_all_links_christian_torbenV2.do"' "1930" 10 1 0 0 "" "" "" "" "" "`tA'" "`tB'" "`tag'"
	confirm file `"`intermediate'link1930_1940`tag'_cleaned_noraceblock0.dta"'
}
display "V26 FS RUN DONE"
