/*ALL-STATES PRODUCING CODE FOR THE COUNTY CORRELATES AT DHTS-2026-10-12.tex */
/*LINE 746: "notably higher rates [of incongruent transcription] occurring in */
/*counties with above-median share of individuals born in the South, below   */
/*age 30, or without formal education". UNTIL 2026-11-03 THE ONLY CODE WAS    */
/*COMMENTED-OUT RHODE ISLAND CODE IN munir_figures_for_nber.do.               */
/*                                                                           */
/*SAME UNIT AS THE COUNTY PERCENTILES IN THAT SENTENCE                        */
/*(verify_inmates_and_county_stats.do): THE ANALYSIS SAMPLE (temp.dta, MEN    */
/*AGED 10+), COLLAPSED TO ONE ROW PER COUNTY, EACH COUNTY COUNTED ONCE.       */
/*FOR EACH CHARACTERISTIC: THE MEDIAN OF ITS COUNTY SHARE, THEN THE MEAN      */
/*INCONGRUENCE SHARE OF COUNTIES ABOVE VS AT-OR-BELOW THAT MEDIAN.            */
/*                                                                           */
/*DEFINITIONS, FROM THE EXISTING CODE:                                        */
/*  south   born in a census-South state (munir_figures_for_nber.do:619;     */
/*          temp.dta's bpl is the general code, 1-56 for states)             */
/*  below30 age<30 (munir_figures_for_nber.do:667)                           */
/*  noed    no schooling, higrade 1-3 (compute_subgroup_linkage_rates.do's    */
/*          recode (1 3=1); 99 and 0 are missing)                             */
/*READ-ONLY.                                                                  */
clear all
set more off

if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
repnum open using "$REP_RESULTS/compute_county_correlates.tex", script(CODE/compute_county_correlates.do)
local intermediate "$REP_SNU/enum_date/DATA/INTERMEDIATE"

use congruent bpl age higrade state_folder_name county_folder_name using `"`intermediate'/temp.dta"', clear
display "records: " _N

gen byte incong  = 1-congruent
gen byte south   = inlist(bpl,1,5,10,11,12,13,21,22,24) | inlist(bpl,28,37,40,45,47,48,51,54) if bpl<.
/*age IS NEVER MISSING HERE (temp.dta KEEPS age>=10 & age<.).*/
gen byte below30 = age<30
gen byte noed    = inrange(higrade,1,3) if inrange(higrade,1,23)

collapse (mean) incong south below30 noed, by(state_folder_name county_folder_name)
display "counties: " _N

foreach v in south below30 noed {
	local V = cond("`v'"=="south","South",cond("`v'"=="below30","Young","Noed"))
	quietly summarize `v', detail
	local med = r(p50)
	/*A COUNTY WITH NO VALID VALUE IS IN NEITHER GROUP.*/
	quietly summarize incong if `v' > `med' & `v' < .
	local hi = r(mean)
	local nhi = r(N)
	quietly summarize incong if `v' <= `med'
	local lo = r(mean)
	local nlo = r(N)
	display "`v': median county share " %5.3f `med' "  incongruence above " %5.3f `hi' " (`nhi' counties)  at/below " %5.3f `lo' " (`nlo')"
	repnum countyMedian`V'     = 100*`med', format(%4.1f)
	repnum countyIncongAbove`V' = 100*`hi', format(%4.1f)
	repnum countyIncongBelow`V' = 100*`lo', format(%4.1f)
}
repnum close
