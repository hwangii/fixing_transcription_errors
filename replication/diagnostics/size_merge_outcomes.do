/*****************************************************************************/
/*SIZE WHAT THE THREE MERGES IN create_figures_SSHA2025.do DROP (2026-10-30). */
/*                                                                           */
/*ALL THREE ARE 1:1 WITH keep(1 3) AND NO assert(). 1:1 ALREADY STOPS ON A   */
/*DUPLICATE KEY, SO THE OPEN QUESTION IS ONLY HOW MANY RECORDS GO UNMATCHED: */
/*  m1  labeled 1940 data <- socio-demographics (histid). sex AND age COME    */
/*      FROM THE USING FILE, SO AN UNMATCHED MASTER RECORD HAS sex==. AND IS */
/*      DROPPED SILENTLY BY THE LATER `keep if sex==1`.                      */
/*  m2  <- 1930-1940 links on the OLD transcription (id_B = histid)          */
/*  m3  <- 1930-1940 links on the NEW transcription                          */
/*  FOR m2/m3, _merge==1 IS "NOT LINKED" BY DESIGN; _merge==2 IS A LINK WHOSE */
/*  1940 RECORD IS NOT IN THE LABELED DATA, AND IS DISCARDED.                */
/*                                                                           */
/*READ-ONLY: WRITES NO .dta AND NO EXHIBIT. COUNTS GO TO                     */
/*replication/results/size_merges.tex. PATHS MATCH create_figures_SSHA2025.do */
/*LINES 10-30.                                                               */
/*****************************************************************************/

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"

local original     "$REP_SNU/fixing_transcription_errors/DATA/ORIGINAL/"
local intermediate "$REP_SNU/enum_date/DATA/INTERMEDIATE/"
local original_ed  "$REP_F/enum_date/DATA/ORIGINAL/"
local linksuf "0"
local beg_yr=1930

repnum open using "$REP_RESULTS/size_merges.tex", script(replication/diagnostics/size_merge_outcomes.do)

/*m1: AS IN THE SCRIPT, BUT KEEPING _merge==2 TO COUNT IT.                   */
use histid using `"`original'census1940_all_labeled_data.dta"', clear
quietly count
repnum mOneN = r(N), format(%15.0fc)
merge 1:1 histid using `"`original_ed'all_states_socio_demo_char_for_SSHA2025.dta"', keepusing(sex age)
tab _merge
foreach k in 1 2 3 {
	quietly count if _merge==`k'
	local w = word("Master Using Matched", `k')
	repnum mOne`w' = r(N), format(%15.0fc)
}
/*USING-ONLY RECORDS THAT WOULD HAVE BEEN IN THE SAMPLE: MALES 10+ IN THE    */
/*CENSUS WITH NO LABELED (TRANSCRIPTION) RECORD.                             */
quietly count if _merge==2 & sex==1 & age>=10 & age<.
repnum mOneUsingMalesTen = r(N), format(%15.0fc)
drop if _merge==2
drop _merge

/*m2 AND m3, ON THE FULL MASTER (THE SCRIPT MERGES BEFORE ITS SEX/AGE FILTER) */
/*AND THEN ON THE ANALYSIS SAMPLE.                                           */
rename histid id_B
local i = 1
foreach t in ans true {
	local P = word("mTwo mThree", `i')
	merge 1:1 id_B using `"`intermediate'link`beg_yr'_1940_`t'_cleaned_noraceblock`linksuf'.dta"', keepusing(fiveyr)
	tab _merge
	foreach k in 1 2 3 {
		quietly count if _merge==`k'
		local w = word("Master Using Matched", `k')
		repnum `P'`w' = r(N), format(%15.0fc)
	}
	quietly count if _merge==2 & fiveyr==1
	repnum `P'UsingFiveyr = r(N), format(%15.0fc)
	quietly count if _merge==3 & sex==1 & age>=10 & age<.
	repnum `P'MatchedSample = r(N), format(%15.0fc)
	drop if _merge==2
	drop _merge fiveyr
	local ++i
}

/*THE SCRIPT'S ANALYSIS SAMPLE; MUST EQUAL hzAnaKept (51,036,859).           */
quietly count if sex==1 & age>=10 & age<.
repnum mSample = r(N), format(%15.0fc)
repnum close
