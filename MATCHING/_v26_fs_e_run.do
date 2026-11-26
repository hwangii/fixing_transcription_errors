/*FAMILYSEARCH VERSION (e), ABE EXACT, 1930-1940, MEN, v26 BASE (2026-11-26).*/
/*MACHINE A. 1930 FamilySearch wherever it exists (per field, Ancestry        */
/*fallback), 1940 Ancestry: 1930 divided_file1930_v26_fs_cleaned x 1940       */
/*divided_file1940_v26_ans_cleaned (both built already, 1g_v26_fs_inputs.do   */
/*and 1f_v26_inputs.do; read only). Writes                                    */
/*  link1930_1940_v26_fs1930_cleaned_noraceblock0.dta                         */
/*Refuses to start if the output or its matcher folder exists.               */
/*                                                                           */
/*  powershell -File replication/Run-Stata.ps1 MATCHING/_v26_fs_e_run.do      */

if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local code "$REP_REPO/MATCHING/"
local intermediate "$REP_SNU/enum_date/DATA/INTERMEDIATE/"
local fi "$REP_F/enum_date/DATA/INTERMEDIATE/"

which abeclean
which abematch

local tA _v26_fs_cleaned
local tB _v26_ans_cleaned
local tag _v26_fs1930
capture confirm file `"`intermediate'link1930_1940`tag'_cleaned_noraceblock0.dta"'
if !_rc {
	display as error "link1930_1940`tag'_cleaned_noraceblock0.dta exists; move it aside first"
	exit 602
}
mata: st_local("dex", strofreal(direxists(st_local("fi") + "r`tA'`tB'1930_1940")))
if `dex' {
	display as error "`fi'r`tA'`tB'1930_1940 exists; move it aside first"
	exit 602
}
/*THE INPUTS EXIST AND THE 1930 FAMILYSEARCH FILES ARE THE v26 ANCESTRY      */
/*FILES' BIRTHPLACES.                                                       */
local a : dir `"`fi'divided_file1930_v26_fs_cleaned"' files "norace*.dta"
local b : dir `"`fi'divided_file1930_v26_ans_cleaned"' files "norace*.dta"
local c : dir `"`fi'divided_file1940_v26_ans_cleaned"' files "norace*.dta"
local a : list sort a
local b : list sort b
if `"`a'"'=="" | `"`c'"'=="" | !`: list a === b' {
	display as error "v26 input folders missing or inconsistent"
	exit 459
}

do `"`code'2_ABE_matchingV3_christian_torben.do"' 1930 1940 "`tA'" 1 "`tB'"
/*ARGS 3_append: yrs interval location reporting_error_only fsnames fs_years */
/*fstype ml_years mltype anstype typeA typeB tag                             */
do `"`code'3_append_and_clean_all_links_christian_torbenV2.do"' "1930" 10 1 0 0 "" "" "" "" "" "`tA'" "`tB'" "`tag'"
confirm file `"`intermediate'link1930_1940`tag'_cleaned_noraceblock0.dta"'
display "V26 FS (e) RUN DONE"
