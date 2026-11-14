/*DOES THE CURRENT CODE REPRODUCE THE RHODE ISLAND RESULTS? (2026-11-13)      */
/*                                                                           */
/*The 2026-08-28 draft reported tab:avg_performance for Rhode Island only,   */
/*from CODE/create_figures.do. The paper now reports all states, from        */
/*CODE/create_figures_SSHA2025.do. This takes the current analysis file      */
/*(temp.dta, written by create_figures_SSHA2025.do), keeps Rhode Island, and */
/*recomputes the table's four rows with the current definitions, beside the  */
/*August numbers. Close, not identical, is expected:                         */
/*  - the RI-era link files (no "0" suffix) no longer exist; the current     */
/*    "0" pair (2026-02-15) was linked over all states;                      */
/*  - the old script built its sample from an RI-only file in which records  */
/*    without a FamilySearch transcription counted as congruent; the        */
/*    current sample needs both transcriptions with all four names present.  */
/*A DESCRIPTIVE COMPARISON, NOT A PASS/FAIL TEST: with the links and the     */
/*sample rule both changed, no tolerance could be justified in advance. The  */
/*judgement of "close enough" is recorded with the result, by hand.          */
/*READ-ONLY. WRITES NOTHING BUT ITS LOG.                                     */

clear all
set more off
set linesize 255
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local intermediate "$REP_SNU/enum_date/DATA/INTERMEDIATE/"

capture log close rilog
log using "$REP_REPO/replication/diagnostics/ri_replication_table.log", text replace name(rilog)

use state_folder_name namefrst namelast fs_namefrst fs_namelast linked_before linked_after validated_before validated_after using `"`intermediate'temp.dta"' if strpos(lower(state_folder_name), "rhode") > 0, clear

/*CONFIRM THE STATE LABEL CAUGHT EXACTLY ONE STATE, AND SOMETHING.*/
tab state_folder_name, missing
quietly levelsof state_folder_name, local(st)
assert `: word count `st'' == 1
assert _N > 0

/*SAME DEFINITION AS create_figures_SSHA2025.do:117.*/
gen target = !(namefrst==fs_namefrst & namelast==fs_namelast)

/*AUGUST 2026-08-28 DRAFT, TABLE 4 (RHODE ISLAND), FOR COMPARISON.*/
local old_n_target      84538
local old_n_all        299880
local old_lb_target     0.084
local old_la_target     0.208
local old_lb_all        0.270
local old_la_all        0.302
local old_nvb_target     2078
local old_nva_target     4835
local old_vb_target     0.608
local old_va_target     0.839
local old_nvb_all       21663
local old_nva_all       24265
local old_vb_all        0.857
local old_va_all        0.876

display as text _n "{hline 100}"
display as text "RHODE ISLAND: CURRENT CODE AND LINKS vs AUGUST 2026-08-28 DRAFT"
display as text "{hline 100}"
display as text %-28s "row" %14s "Aug: N" %10s "Aug: bef" %10s "Aug: aft" %14s "now: N" %10s "now: bef" %10s "now: aft"

foreach grp in target all {
	local cond = cond("`grp'"=="target", "if target==1", "")

	quietly count `cond'
	local n = r(N)
	quietly sum linked_before `cond'
	local lb = r(mean)
	quietly sum linked_after `cond'
	local la = r(mean)
	display as result %-28s "Linkage rate, `grp'" %14.0fc `old_n_`grp'' %10.3f `old_lb_`grp'' %10.3f `old_la_`grp'' %14.0fc `n' %10.3f `lb' %10.3f `la'

	quietly sum validated_before `cond'
	local nvb = r(N)
	local vb = r(mean)
	quietly sum validated_after `cond'
	local nva = r(N)
	local va = r(mean)
	display as result %-28s "Share validated, `grp'" %14.0fc `old_nvb_`grp'' %10.3f `old_vb_`grp'' %10.3f `old_va_`grp'' %14.0fc `nvb' %10.3f `vb' %10.3f `va'
	display as result %-28s "   (validated N after)" %14.0fc `old_nva_`grp'' %20s "" %14.0fc `nva'
}

quietly count if target==1
display as text _n "Target share of RI sample now: " %5.1f 100*r(N)/_N "%  (August text: 29.9%, from the balance table)"

log close rilog
