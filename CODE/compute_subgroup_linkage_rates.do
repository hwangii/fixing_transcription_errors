/*PRODUCING CODE FOR THE SUBGROUP LINKAGE FIGURES QUOTED IN SECTION 4.3 OF  */
/*DHTS-2026-10-12.tex. THE DRAFT PREVIOUSLY QUOTED RHODE-ISLAND-ERA VALUES  */
/*(+14.5, +9.2, +14.5 percent) THAT DISAGREED WITH THE ALL-STATES FIGURE     */
/*THEY SAT BESIDE. RUN 2026-10-12: foreign-born 16.63->17.98 (+8.1%),       */
/*no schooling 11.90->12.73 (+7.0%), non-English mother tongue 19.94->21.49 */
/*(+7.8%). RACE IS COMPUTED BY compute_race_linkage_rates.do.               */

/*USES THE FIGURE'S OWN RECODES (create_figures_SSHA2025.do:272,274) SO THE   */
/*NUMBERS MATCH all_states_socio_demo_combinedV2.pdf EXACTLY. READ-ONLY.     */
clear all
set more off

/*REPLICATION PACKAGE: THE NUMBERS THE DRAFT QUOTES ARE WRITTEN BY repnum  */
/*TO THE FILE BELOW, NOT ONLY DISPLAYED. SEE replication/README.md.         */
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
repnum open using "$REP_RESULTS/compute_subgroup_linkage_rates.tex", script(CODE/compute_subgroup_linkage_rates.do)
local intermediate "D:/SNU ECON Dropbox/sam hwang/enum_date/DATA/INTERMEDIATE"

use bpl higrade non_english_mtongue linked_before linked_after using `"`intermediate'/temp.dta"', clear
display "records: " _N

recode bpl (1/120=1) (150/900=2)
recode higrade (1 3=1) (4/9=2) (10/12=3) (13/15=4) (16/19=5) (20/23=6) (99=.)

/*foreign-born = bpl category 2; no schooling = higrade category 1*/
/*EACH SPEC IS: CONDITION, repnum KEY SUFFIX, LABEL.*/
foreach spec in "bpl==2 Foreignborn Foreign-born" "higrade==1 Noschool No-schooling" "non_english_mtongue==1 Nonenglish Non-English-mother-tongue" {
	gettoken cond rest : spec
	gettoken key lab : rest
	quietly summarize linked_before if `cond'
	local b=r(mean)
	local n=r(N)
	quietly summarize linked_after if `cond'
	local a=r(mean)
	display "`lab' : before " %6.4f `b' "  after " %6.4f `a' "  increase " %5.1f 100*(`a'/`b'-1) "%   (N=`n')"
	repnum linkBase`key'  = 100*`b',       format(%4.1f)
	repnum linkAfter`key' = 100*`a',       format(%4.1f)
	repnum linkGain`key'  = 100*(`a'/`b'-1), format(%4.1f)
	repnum n`key'         = `n',           format(%15.0fc)
}
repnum close
