/*****************************************************************************/
/*BUILD MASTER, v26 BASE, MACHINE A (2026-11-27).                            */
/*                                                                           */
/*Rebuilds every 1930-1940 linking input from the raw IPUMS names with       */
/*abeclean 0.26 (the earlier stored names carried the pre-0.25 "marshall"    */
/*defect), the two files sent to IPUMS for MLP linking, the ABE exact links  */
/*on the same names, and their scores. One source for every method: the ABE */
/*inputs are the men of the MLP inputs, name for name.                      */
/*                                                                           */
/*    powershell -File replication/Run-Stata.ps1 replication/build_v26_machineA.do -TimeoutMinutes 2400 */
/*                                                                           */
/*Every step refuses to overwrite its outputs, so this runs on a clean       */
/*INTERMEDIATE folder only (move the v26 outputs aside first). Each step can */
/*also be run on its own, in this order. Expect about a day in all, mostly  */
/*the six ABE runs (about 3 hours each) and the two scorers.               */
/*                                                                           */
/*Inputs (read only): divided_file{1930,1940}_women_added (IPUMS 00655/00656,*/
/*from 0_create_file_for_matching_intgenV4_women_added.do), the 49 states'  */
/*model output merged_data.dta, tgt_flag1940.dta, fs_names{1930,1940}.dta    */
/*(0b_create_fs_names.do), census1940_all_labeled_data.dta, the truth file   */
/*and linkage_sample1940.dta (scorers), the paper's two ABE link files       */
/*(scorers' reproduction check).                                             */
/*Also: divided_file{1930,1940}_ans_cleaned (scorers, the paper's initials) */
/*and for_mlp_original/for_mlp1940.dta (step 3, comparison with what IPUMS */
/*linked before). Each step preflights its own inputs when it starts.       */
/*****************************************************************************/

version 15.1
clear all
set more off
do "D:/repos/fixing_transcription_errors/replication/config.do"
local m "$REP_REPO/MATCHING"

/*STEP: SCRIPT                      WRITES                                   */
/* 1  1f_v26_inputs                 divided_file{1930,1940}_v26_ans_cleaned, */
/*                                  divided_file1940_v26_{true,tgt}_cleaned, */
/*                                  for_mlp1930_v26, for_mlp1940_v26{,_tgt}  */
/* 2  1h_for_mlp1940_v26_combined   for_mlp1940_v26_combined (to IPUMS)      */
/* 3  verify_mlp_v26_independent    nothing; exit 9 on any difference        */
/* 4  _v26_run                      check_v26_same_input (exit 9 on any      */
/*                                  difference), then ABE Old/New/Target-only*/
/* 5  score_v26_links               MATCHING/results/v26_linkage_abe.md      */
/* 6  _v26_fs_run                   1g_v26_fs_inputs, then FS (a),(c),(d)    */
/* 7  _v26_fs_e_run                 FS (e)                                   */
/* 8  score_v26_fs_links            MATCHING/results/v26_fs_linkage_abe.md   */
local steps 1f_v26_inputs 1h_for_mlp1940_v26_combined verify_mlp_v26_independent _v26_run score_v26_links _v26_fs_run _v26_fs_e_run score_v26_fs_links

local t 0
foreach s of local steps {
	local ++t
	display as text _n "{hline 78}" _n "STEP `t': MATCHING/`s'.do" _n "{hline 78}"
	local t0 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
	do "`m'/`s'.do"
	local t1 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
	display as text "DONE `s' in " %6.1f (`t1'-`t0')/60000 " min"
}
display as text _n "build_v26_machineA.do finished: `t' steps. Next:"
display as text "  python replication/hash_ipums_v26.py --force   (only if these files are to be sent again)"
