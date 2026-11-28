/*CENSUS VARIABLES FOR MACHINE B'S JARO-WINKLER RERUN, v26 BASE (2026-11-27).*/
/*MACHINE A. Read only on its inputs.                                        */
/*                                                                           */
/*B's LINKAGE/code/01_abe_jw/linkage/00_merge_names_to_census.do merges the  */
/*name shards 1:1 on histid with matching_intgen<yr>.dta for bpl birthyr     */
/*race sex and keeps _merge==3. B's copies predate the v26 base (1940 from   */
/*extract 00450), so the merge would drop or relabel v26 men. This writes,   */
/*for exactly the men of the v26 shards, the same variables from the source */
/*the v26 base was built from (matching_intgen<yr>_women_added, IPUMS        */
/*00655/00656; review/handoff_jw_inputs_machineA.md item 2):                 */
/*  F:/enum_date/DATA/INTERMEDIATE/jw_census_vars<yr>_v26.dta                */
/*      histid bpl birthyr race sex, one row per v26 man, sorted by histid   */
/*Checks: every shard man is in the source once; his bpl is the shard's      */
/*birthplace, his age the shard's age, sex 1, race non-missing. Exit 9     */
/*otherwise.                                                                */
/*The three 1940 shard sets (ans/true/tgt) hold the same men                 */
/*(check_v26_same_input.do), so one 1940 file serves all three.              */
/*Refuses to overwrite.                                                      */
/*                                                                           */
/*  powershell -File replication/Run-Stata.ps1 MATCHING/1j_v26_jw_census_vars.do */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local fi "$REP_F/enum_date/DATA/INTERMEDIATE/"
local orig "$REP_SNU/enum_date/DATA/ORIGINAL/"
foreach yr in 1930 1940 {
	capture confirm file `"`fi'jw_census_vars`yr'_v26.dta"'
	if !_rc {
		display as error "jw_census_vars`yr'_v26.dta exists; move it aside first"
		exit 602
	}
}

foreach yr in 1930 1940 {
	/*THE v26 MEN, WITH THE BIRTHPLACE OF THEIR SHARD                        */
	local d `"`fi'divided_file`yr'_v26_ans_cleaned"'
	local fl : dir `"`d'"' files "norace*.dta"
	if `"`fl'"'=="" {
		display as error "no shards in `d'"
		exit 601
	}
	clear
	local k 0
	foreach f of local fl {
		local b = subinstr(subinstr("`f'", "norace", "", 1), ".dta", "", 1)
		confirm integer number `b'
		local ++k
		preserve
		use id age using `"`d'/`f'"', clear
		gen int sbpl = `b'
		tempfile s
		save `s'
		restore
		append using `s'
	}
	rename (id age) (histid sage)
	isid histid
	local N = _N
	tempfile men
	save `men'

	use histid bpl birthyr race sex age using `"`orig'matching_intgen`yr'_women_added.dta"', clear
	/*ONE ROW PER histid IN THE SOURCE FOR THE MEN WE KEEP (CHECKED BELOW).  */
	merge m:1 histid using `men', keep(2 3)
	local bad 0
	quietly count if _merge==2
	display "`yr': v26 men not in the source: " r(N)
	local bad = `bad' + r(N)
	keep if _merge==3
	drop _merge
	duplicates tag histid, gen(dup)
	quietly count if dup
	display "`yr': v26 men on more than one source row: " r(N)
	local bad = `bad' + r(N)
	drop dup
	quietly count if bpl != sbpl
	display "`yr': birthplace differs from the shard's: " r(N)
	local bad = `bad' + r(N)
	quietly count if age != sage
	display "`yr': age differs from the shard's: " r(N)
	local bad = `bad' + r(N)
	quietly count if sex != 1
	display "`yr': not sex 1: " r(N)
	local bad = `bad' + r(N)
	/*EVERY RACE: 0_create...:159 LIMITS ONLY THE LIST OF BIRTHPLACES TO RACE  */
	/*1|2, AND EACH BIRTHPLACE FILE IS RELOADED WITH ALL RACES (LINE 167).    */
	tab race, missing
	quietly count if missing(race)
	display "`yr': race missing: " r(N)
	local bad = `bad' + r(N)
	quietly count if missing(birthyr)
	display "`yr': birthyr missing (reported, not an error): " r(N)
	if `bad' {
		display as error "`yr': CHECK FAILED"
		exit 9
	}
	assert _N==`N'
	keep histid bpl birthyr race sex
	order histid bpl birthyr race sex
	sort histid
	compress
	save `"`fi'jw_census_vars`yr'_v26.dta"'
	display "`yr': `k' shards, `N' men written"
}
display "JW CENSUS VARS DONE"
