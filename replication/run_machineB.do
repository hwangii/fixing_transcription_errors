/*****************************************************************************/
/*MASTER FOR MACHINE B (ARTS-ECON-SHSRV): TABLES 5-8 -- DEAGLAN'S ABE/JW AND  */
/*HLINK LINKAGE TABLES -- AND THE MORTALITY TABLE, FROM HIS FROZEN LINK FILES.*/
/*                                                                           */
/*Run it through the driver, which checks the paper repo is clean, runs this */
/*file, extracts the tables into the paper's figures/, runs the claim check, */
/*and shows what changed:                                                    */
/*    .\replication\Run-MachineB.ps1                                         */
/*                                                                           */
/*SCOPE. Deaglan's TABLE tier only: LINKAGE/code/00_run_all_tables.do, which */
/*aggregates already-linked pairs. No matching is rerun (ABE/JW matching and  */
/*the third-party HLINK step are not reproducible here; see LINKAGE/          */
/*DOCUMENTATION.md, "Known gaps").                                           */
/*                                                                           */
/*CODE COMES FROM THIS REPO (LINKAGE/code, via $LCODE); DATA FROM HIS FOLDER  */
/*ON F: (via $ROOT). Both are set by config.do. His scripts write their      */
/*tables to $ROOT/output/tables, overwriting the 2026-09-06 run; the          */
/*originals are committed byte-for-byte in the paper repo's                  */
/*deaglan_results/current/, which is what the driver compares against.       */
/*                                                                           */
/*RUNTIME. ~4h10m on 2026-09-06 (ABE/JW 88 min, HLINK 159 min, mortality      */
/*minutes). Stata's tempfiles need headroom on the scratch drive.             */
/*****************************************************************************/

version 15.1
clear all
set more off

do "F:/github_repos/fixing_transcription_errors/replication/config.do"
if "$REP_MACHINE" != "B" {
	display as error "run_machineB.do runs on machine B only (this is machine $REP_MACHINE)."
	exit 198
}


/*================================ PREFLIGHT ================================*/
/*EVERY INPUT THE THREE TABLE SCRIPTS READ, PLUS THE CODE ITSELF. A MISSING  */
/*ONE STOPS THE RUN HERE, IN SECONDS, INSTEAD OF HOURS IN.                    */
/*05_make_linkage_table.do REBUILDS mortality/temp.dta FROM THE 7 GB BUNMD    */
/*CSV IF IT IS ABSENT. That would be a different computation from the one     */
/*being reproduced, so its absence is an error here, not a fallback.          */
local D "$REP_LINK/data"

local inputs `""$LCODE/00_run_all_tables.do""'
local inputs `"`inputs' "$LCODE/shared/paths.do""'
local inputs `"`inputs' "$LCODE/01_abe_jw/linkage_analysis.do""'
local inputs `"`inputs' "$LCODE/02_hlink/linkage_analysis_newlinks.do""'
local inputs `"`inputs' "$LCODE/03_mortality/05_make_linkage_table.do""'
/*Table 5-6: ABE / Jaro-Winkler*/
local inputs `"`inputs' "`D'/names/cleaned/clean_names_1930_old.dta""'
local inputs `"`inputs' "`D'/names/cleaned/clean_names_1940_new.dta""'
local inputs `"`inputs' "`D'/links/derived/JW_matches_x2_unique_new.dta""'
local inputs `"`inputs' "`D'/links/derived/JW_matches_x2_unique_old.dta""'
local inputs `"`inputs' "`D'/links/derived/link1930_1940_true_cleaned_noraceblock0.dta""'
local inputs `"`inputs' "`D'/links/derived/link1930_1940_ans_cleaned_noraceblock0.dta""'
/*Tables 7-8: HLINK*/
local inputs `"`inputs' "`D'/transcriptions/appended/divided_file1930_ans_cleaned_women_added.dta""'
local inputs `"`inputs' "`D'/transcriptions/appended/divided_file1940_true_cleaned_women_added.dta""'
local inputs `"`inputs' "`D'/links/derived/matches_after.dta""'
local inputs `"`inputs' "`D'/links/derived/matches_before.dta""'
/*Both census-to-census linkages*/
local inputs `"`inputs' "`D'/names/flags/ipums_fs_names_for_Deaglan1940.dta""'
local inputs `"`inputs' "`D'/truth/mlp_training1930_1940.dta""'
/*Mortality (not in the draft; rebuilt because 00_run_all_tables.do runs it)*/
local inputs `"`inputs' "`D'/mortality/temp.dta""'
foreach spec in oldnames oldnames_conservative newnames newnames_conservative {
	local inputs `"`inputs' "`D'/mortality/working/censoc_bunmd_matched_`spec'.dta""'
}

local nmiss 0
foreach f of local inputs {
	capture confirm file `"`f'"'
	if _rc {
		display as error "MISSING INPUT: `f'"
		local ++nmiss
	}
}
if `nmiss' > 0 {
	display as error "`nmiss' input(s) missing -- nothing was run."
	exit 601
}
local ninputs : word count `inputs'
display as text "preflight: all `ninputs' inputs present"

/*Run-MachineB.ps1 -PreflightOnly: test the setup in seconds, run nothing.  */
if "$REP_PREFLIGHT_ONLY" == "1" {
	display as text "REP_PREFLIGHT_ONLY=1: stopping after preflight."
	exit
}

/*THE CHECKS ON THE PAPER REPO, THE EXTRACTION INTO figures/ AND THE CLAIM   */
/*CHECK LIVE IN Run-MachineB.ps1: STATA IGNORES `shell` IN BATCH MODE.       */


/*================================== RUN ====================================*/
display as text _n "{hline 78}" _n "RUNNING LINKAGE/code/00_run_all_tables.do" _n "{hline 78}"
/*WALL-CLOCK, NOT `timer`: THE SCRIPT'S `clear all` RESETS STATA'S TIMERS.  */
local t0 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
do "$LCODE/00_run_all_tables.do"
local t1 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
display as text "DONE 00_run_all_tables in " %6.1f (`t1'-`t0')/60000 " min"

display as text _n "{hline 78}"
display as text "run_machineB.do finished. Next (Run-MachineB.ps1 does these):"
display as text "  python replication/extract_deaglan_tables.py --regenerated $REP_LINK/output/tables"
display as text "  python replication/check_claims.py"
display as text "{hline 78}"
