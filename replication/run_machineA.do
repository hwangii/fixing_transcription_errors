/*****************************************************************************/
/*MASTER FOR MACHINE A (ARTS-ECON-CM): EVERY DRAFT EXHIBIT AND NUMBER THAT    */
/*THIS MACHINE'S DATA PRODUCES, FROM THE FROZEN INTERMEDIATE FILES.           */
/*                                                                           */
/*Run it through the driver, which checks the paper repo is clean, runs this */
/*file, runs the claim check, and shows which exhibits and results changed:  */
/*    .\replication\Run-MachineA.ps1               (full run, hours)          */
/*    .\replication\Run-MachineA.ps1 -SkipRebuild  (existing analysis file)   */
/*                                                                           */
/*SCOPE. This is the ANALYSIS tier: frozen intermediates -> exhibits. The     */
/*BUILD tier (raw census + scrapes -> intermediates) cannot run today: its    */
/*stages in clean_FS_and_combineV5_nber.do are commented out, and the         */
/*existing CODE/_master_for_creating_training_dataset.do cd's to a folder     */
/*that no longer exists. See replication/README.md, "What is not covered".   */
/*                                                                           */
/*RUNTIME. create_figures_SSHA2025.do reads a 43 GB file and rewrites the     */
/*22 GB analysis file; expect hours. -SkipRebuild (global REP_SKIP_REBUILD=1)*/
/*skips it and runs everything else on the existing analysis file.           */
/*****************************************************************************/

version 15.1
clear all
set more off

do "D:/repos/fixing_transcription_errors/replication/config.do"

if "$REP_SKIP_REBUILD" == "" global REP_SKIP_REBUILD 0


/*================================ PREFLIGHT ================================*/
/*EVERY FROZEN INPUT THE SCRIPTS READ. A MISSING ONE STOPS THE RUN HERE,     */
/*IN SECONDS, INSTEAD OF HOURS IN -- OR, WORSE, AFTER A `capture` SWALLOWS IT.*/
local snu_ft  "$REP_SNU/fixing_transcription_errors/DATA"
local snu_ed  "$REP_SNU/enum_date/DATA"
local f_ft    "$REP_F/fixing_transcription_errors/DATA"
local f_ed    "$REP_F/enum_date/DATA"
local model   "`snu_ft'/TRANSCRIPTIONS/USCensus1940FullCount/output_and_output1_ssha2025"

local inputs `""`snu_ft'/ORIGINAL/census1940_all_labeled_data.dta""'
local inputs `"`inputs' "`snu_ed'/INTERMEDIATE/link1930_1940_ans_cleaned_noraceblock0.dta""'
local inputs `"`inputs' "`snu_ed'/INTERMEDIATE/link1930_1940_true_cleaned_noraceblock0.dta""'
local inputs `"`inputs' "`f_ed'/ORIGINAL/all_states_socio_demo_char_for_SSHA2025.dta""'
local inputs `"`inputs' "$REP_REPO/CODE/label_socio_demo.do""'
foreach s of global REP_A_STATES {
	local inputs `"`inputs' "`f_ft'/INTERMEDIATE/merged_`s'1940.dta""'
}
foreach s in al ar az ca co ct dc de fl ga ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy {
	local inputs `"`inputs' "`model'/`s'/merged_data.dta""'
}
/*SEC 4.3 (MATCHING/fs_avg_performance.do, fs_cells.do): THE FAMILYSEARCH-    */
/*NAME LINK FILES AND THE ANCESTRY DIVIDED FILES THEIR INITIALS COME FROM.    */
foreach v in fs1930_1940 fs1930 fs1940 {
	local inputs `"`inputs' "`snu_ed'/INTERMEDIATE/link1930_1940_`v'_cleaned_noraceblock0.dta""'
}
foreach y in 1930 1940 {
	local dfiles : dir `"`f_ed'/INTERMEDIATE/divided_file`y'_ans_cleaned"' files "norace*.dta"
	if `"`dfiles'"' == "" local inputs `"`inputs' "`f_ed'/INTERMEDIATE/divided_file`y'_ans_cleaned/norace*.dta""'
	foreach f of local dfiles {
		local inputs `"`inputs' "`f_ed'/INTERMEDIATE/divided_file`y'_ans_cleaned/`f'""'
	}
}
if $REP_SKIP_REBUILD == 1 {
	local inputs `"`inputs' "`snu_ed'/INTERMEDIATE/temp.dta""'
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

/*THE CHECK THAT THE PAPER REPO HAS NO UNCOMMITTED CHANGES TO figures/ LIVES */
/*IN Run-MachineA.ps1: STATA IGNORES `shell` IN BATCH MODE.                  */


/*================================== RUN ====================================*/
/*ORDER MATTERS: create_figures_SSHA2025.do WRITES THE ANALYSIS FILE          */
/*(enum_date/DATA/INTERMEDIATE/temp.dta) THAT THE FOUR compute/verify         */
/*SCRIPTS AND make_balance_exhibits.do READ. SINCE 2026-10-31 THE BALANCE    */
/*TABLES NO LONGER READ THE F: temp.dta BUILT BY munir_figures_for_nber.do;   */
/*THE WHOLE PAPER USES ONE SAMPLE DEFINITION.                                 */

local scripts ""
if $REP_SKIP_REBUILD == 0 local scripts "create_figures_SSHA2025"
local scripts "`scripts' compute_race_linkage_rates compute_subgroup_linkage_rates verify_inmates_and_county_stats compute_county_correlates compute_legibility_quartiles make_balance_exhibits compute_model_agreement_on_discordant"

local t 0
foreach s of local scripts {
	local ++t
	display as text _n "{hline 78}" _n "RUNNING CODE/`s'.do" _n "{hline 78}"
	/*WALL-CLOCK, NOT `timer`: EACH SCRIPT'S `clear all` RESETS STATA'S TIMERS.*/
	local t0 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
	do "$REP_REPO/CODE/`s'.do"
	local t1 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
	display as text "DONE `s' in " %6.1f (`t1'-`t0')/60000 " min"
}

/*============================== DIAGNOSTICS ================================*/
/*READ-ONLY CHECKS ON THE ANALYSIS FILE WHOSE RESULTS THE CLAIM CHECK USES:  */
/*MIDDLE-INITIAL VALIDATION BY LINK STATUS AND WITH ONE FIXED 1940 INITIAL.  */
/*ABOUT 15 MINUTES. middle_initial_sources.do IS A ONE-OFF AND WRITES NOTHING.*/
foreach s in validation_by_link_status validation_fixed_initials {
	local ++t
	display as text _n "{hline 78}" _n "RUNNING replication/diagnostics/`s'.do" _n "{hline 78}"
	local t0 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
	do "$REP_REPO/replication/diagnostics/`s'.do"
	local t1 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
	display as text "DONE `s' in " %6.1f (`t1'-`t0')/60000 " min"
}

/*========================= SEC 4.3: FAMILYSEARCH NAMES ======================*/
/*TABLES 9-11. EACH STOPS UNLESS ITS ANCESTRY AND OURS COLUMNS REPRODUCE      */
/*TABLE 4. THEY WRITE MATCHING/results/fs_avg_performance.tex AND fs_cells.tex;*/
/*Run-MachineA.ps1 THEN RUNS MATCHING/fs_draft_tables.py, WHICH TURNS THEM    */
/*INTO THE DRAFT'S figures/fs_*_allstates.tex. ABOUT 1 HOUR 45 MINUTES.       */
foreach s in fs_avg_performance fs_cells {
	local ++t
	display as text _n "{hline 78}" _n "RUNNING MATCHING/`s'.do" _n "{hline 78}"
	local t0 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
	do "$REP_REPO/MATCHING/`s'.do"
	local t1 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
	display as text "DONE `s' in " %6.1f (`t1'-`t0')/60000 " min"
}

display as text _n "{hline 78}"
display as text "run_machineA.do finished: `t' scripts. Next:"
display as text "  python MATCHING/fs_draft_tables.py $REP_PAPER"
display as text "  python replication/check_claims.py"
display as text "  git -C $REP_PAPER diff --stat figures/"
display as text "{hline 78}"
