/*FAMILYSEARCH 1930 NAMES x TARGET-ONLY 1940 NAMES, ABE LINKS, MEN          */
/*(2026-11-18). MACHINE A.                                                   */
/*                                                                           */
/*The slides' "Adding FamilySearch names" frame has a column with            */
/*FamilySearch's 1930 names and our 1940 names                               */
/*(link1930_1940_fs1930_ml1940_cleaned_noraceblock0.dta, 2026-11-14, our     */
/*names on every 1940 record). The slides now use our names on 1940 target   */
/*records only, so this links the same 1930 FamilySearch divided files to    */
/*divided_file1940_tgt_cleaned (1c_tgt_divided_files.do), through the same   */
/*code path as the 2026-11-14 run (_matching_master_dofile.do with fs_years  */
/*1930, ml_years 1940), with mltype _tgt_cleaned. Writes                     */
/*  link1930_1940_fs1930_mltgt1940_cleaned_noraceblock0.dta                  */
/*                                                                           */
/*INPUTS REUSED, NOT REBUILT: divided_file1930_fs_cleaned (built by          */
/*1b_fs_divided_files.do for the 2026-11-14 run; it does not depend on       */
/*target status) and divided_file1940_tgt_cleaned (2026-11-17). Both must    */
/*hold the same birthplace files as their Ancestry counterparts (checked).   */
/*Refuses to start if the output or its stage-2 folder exists.               */
/*                                                                           */
/*  powershell -File replication/Run-Stata.ps1 MATCHING/_fs_tgt_run.do        */

if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local code "$REP_REPO/MATCHING/"
local intermediate "$REP_SNU/enum_date/DATA/INTERMEDIATE/"
local fi "$REP_F/enum_date/DATA/INTERMEDIATE/"

which abeclean
which abematch

capture confirm file `"`intermediate'link1930_1940_fs1930_mltgt1940_cleaned_noraceblock0.dta"'
if !_rc {
	display as error "link1930_1940_fs1930_mltgt1940_cleaned_noraceblock0.dta exists; move it aside first"
	exit 602
}
mata: st_local("dex", strofreal(direxists(st_local("fi") + "r_fs_cleaned_tgt_cleaned1930_1940")))
if `dex' {
	display as error "`fi'r_fs_cleaned_tgt_cleaned1930_1940 exists; move it aside first"
	exit 602
}

/*THE REUSED INPUTS EXIST AND COVER THE SAME BIRTHPLACES AS THEIR ANCESTRY */
/*COUNTERPARTS.                                                            */
foreach p in "1930 fs ans" "1940 tgt ans" {
	tokenize `p'
	local a : dir `"`fi'divided_file`1'_`2'_cleaned"' files "norace*.dta"
	local b : dir `"`fi'divided_file`1'_`3'_cleaned"' files "norace*.dta"
	local a : list sort a
	local b : list sort b
	if `"`a'"'=="" | !`: list a === b' {
		display as error "divided_file`1'_`2'_cleaned missing or not the same birthplace files as divided_file`1'_`3'_cleaned"
		exit 459
	}
	display "divided_file`1'_`2'_cleaned: " `: word count `a'' " birthplace files, as _`3'_cleaned"
}

/*STAGE 2 AS 2_ABE_matchingV3_master_christian_torben.do CALLS IT FOR      */
/*fs_years 1930 (typeA _fs_cleaned), WITH typeB _tgt_cleaned IN 1940.      */
do `"`code'2_ABE_matchingV3_christian_torben.do"' 1930 1940 "_fs_cleaned" 1 "_tgt_cleaned"
/*ARGS: yrs interval location reporting_error_only fsnames fs_years fstype ml_years mltype*/
do `"`code'3_append_and_clean_all_links_christian_torbenV2.do"' "1930" 10 1 0 0 "1930" "_fs_cleaned" "1940" "_tgt_cleaned"

confirm file `"`intermediate'link1930_1940_fs1930_mltgt1940_cleaned_noraceblock0.dta"'
display "FS-TGT-DONE"
