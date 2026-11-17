/*JARO-WINKLER SIMILARITY OF 1940 TRANSCRIPTIONS TO FAMILYSEARCH PROFILE     */
/*NAMES (2026-11-15). MEN: FIRST NAME AND SURNAME; WOMEN: FIRST NAME ONLY.   */
/*COMPANION TO MATCHING/profile_names_score.do,                              */
/*WHICH REPORTS EXACT AGREEMENT; THIS REPORTS HOW CLOSE THE NAMES ARE.       */
/*                                                                           */
/*Same records, same normalised names, same reference names: it reads        */
/*profile_names.dta and the split profile names profile_names_score.do saved */
/*(refs_fullname.dta), normalises the census names with the same pnorm, and   */
/*keeps men whose profile gender does not contradict the census sex and whose */
/*profile has a usable first name and surname (the "first name and surname"  */
/*sample of profile_names.md), and women likewise with a usable profile first */
/*name ("All women: first name"). As a check it recomputes the exact-agreement*/
/*shares and stops unless they equal profile_names.md's.                     */
/*                                                                           */
/*Measure: Jaro-Winkler similarity (jarowinkler, Feigenbaum, ssc; Winkler    */
/*prefix weight 0.1), 0 to 1, between each source's first name and the       */
/*profile's first name, and between surnames. "Full name" is the mean of the */
/*two. A transcription the source does not have (empty after normalising)   */
/*scores 0, as it counts as not agreeing in profile_names.md.                */
/*Computed on distinct (transcription, profile) pairs, merged back.          */
/*                                                                           */
/*SOURCES: Ancestry, FamilySearch, ours (model alone; empty scores 0), and  */
/*ours+Anc (Ancestry filled in where the model field is empty; 2026-11-16).  */
/*Writes MATCHING/results/profile_names_jw.md.                               */

clear all
set more off
set linesize 255
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local out "$REP_F/fixing_transcription_errors/DATA/INTERMEDIATE/profile_names"
local md  "$REP_REPO/MATCHING/results/profile_names_jw.md"
local pn  `"`out'/profile_names.dta"'
local r_full `"`out'/refs_fullname.dta"'

/*pnorm: COPIED VERBATIM FROM MATCHING/profile_names_score.do (PN_NORMVER    */
/*2026-11-14a). THE EXACT-AGREEMENT CHECK BELOW FAILS IF THEY DIVERGE.       */
capture program drop pnorm
program define pnorm
	args in newvar
	quietly {
		gen `newvar' = ustrlower(`in')
		replace `newvar' = ustrregexra(ustrnormalize(`newvar', "nfd"), "\p{M}", "")
		replace `newvar' = ustrregexra(`newvar', `""[^"]*""', " ")
		replace `newvar' = ustrregexra(`newvar', "\([^)]*\)", " ")
		replace `newvar' = ustrregexra(`newvar', "['’.]", "")
		replace `newvar' = ustrregexra(`newvar', "[^a-z ]", " ")
		forvalues i = 1/2 {
			replace `newvar' = ustrregexra(" " + `newvar' + " ", " (jr|sr|ii|iii|iv|mr|mrs|miss|ms|dr|rev) ", " ")
		}
		replace `newvar' = strtrim(stritrim(`newvar'))
	}
end

/*THE SAVED SPLIT NAMES MUST BE THE ONES profile_names_score.do USED.*/
/*THEY ARE ATTACHED BY ROW POSITION (_id = _n), AS IN profile_names_score.do,*/
/*SO THEY MUST ALSO BE NEWER THAN profile_names.dta (ITS OWN REUSE RULE).    */
quietly use in 1 using `"`pn'"', clear
local t_pn = clock(`"`c(filedate)'"', "DMYhm")
quietly use in 1 using `"`r_full'"', clear
local ref_ver : char _dta[pn_normver]
assert `"`ref_ver'"'=="2026-11-14a"
local t_ref = clock(`"`c(filedate)'"', "DMYhm")
assert `t_ref'<. & `t_pn'<. & `t_ref'>`t_pn'

/*jwpair A B OUT: JW OF TWO STRING VARIABLES ON DISTINCT NON-EMPTY PAIRS;     */
/*OUT = 0 WHERE A IS EMPTY. B (THE PROFILE NAME) IS NON-EMPTY IN THE SAMPLE. */
capture program drop jwpair
program define jwpair
	args a b outv
	tempfile pairs
	preserve
	keep `a' `b'
	keep if `a'!="" & `b'!=""
	duplicates drop
	display "jarowinkler on " _N " distinct pairs of `a' x `b'"
	jarowinkler `a' `b', gen(`outv')
	save `pairs'
	restore
	merge m:1 `a' `b' using `pairs', keep(1 3) nogen
	assert `outv'<. if `a'!="" & `b'!=""
	replace `outv' = 0 if `a'==""
end

/*SAME ROW ORDER AS profile_names_score.do: _id = _n OF THE SAVED FILE.*/
use sex namefrst fs_namefrst namefrst_ml namelast fs_namelast namelast_ml_ditto cell gender deathdate using `"`pn'"', clear
gen long _id = _n
merge 1:1 _id using `"`r_full'"', assert(match) nogen keepusing(ref_first ref_last)
drop _id

gen byte has_dmonth = ustrregexm(lower(deathdate), "\b(jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec|january|february|march|april|june|july|august|september|october|november|december)\b")
drop deathdate
/*MEN: PROFILE GENDER NOT FEMALE, USABLE PROFILE FIRST NAME AND SURNAME.    */
/*WOMEN (2026-11-15): PROFILE GENDER NOT MALE, USABLE PROFILE FIRST NAME;   */
/*SCORED ON FIRST NAMES ONLY, SINCE A WOMAN'S PROFILE SURNAME MAY BE HER    */
/*MAIDEN OR MARRIED NAME (profile_names.md, "All women: first name").       */
gen byte men = sex==1 & lower(gender)!="female" & ref_first!="" & ref_last!=""
gen byte wom = sex==2 & lower(gender)!="male"   & ref_first!=""
keep if men | wom
drop sex gender
count if men
display "men in the first-name-and-surname sample: " r(N)
count if wom
display "women in the first-name sample: " r(N)

/*mf (2026-11-16): OUR NAME WITH ANCESTRY'S WHERE THE MODEL FIELD IS EMPTY, */
/*FIELD BY FIELD, AS THE LINKAGE TABLES' "NEW" TRANSCRIPTION. ml IS KEPT FOR */
/*THE CHECK AGAINST profile_names.md, WHICH SCORES THE MODEL NAMES ALONE.    */
gen byte fb_f = strtrim(namefrst_ml)==""
gen byte fb_l = strtrim(namelast_ml_ditto)==""
gen namefrst_mf = cond(fb_f, namefrst, namefrst_ml)
gen namelast_mf = cond(fb_l, namelast, namelast_ml_ditto)
count if men & has_dmonth & (fb_f | fb_l)
display "men with a death month, Ancestry filled in: " r(N)
count if wom & has_dmonth & fb_f
display "women with a death month, Ancestry first name filled in: " r(N)
drop fb_f fb_l
local f_mf  namefrst_mf
local l_mf  namelast_mf
local f_anc namefrst
local l_anc namelast
local f_fs  fs_namefrst
local l_fs  fs_namelast
local f_ml  namefrst_ml
local l_ml  namelast_ml_ditto
foreach s in anc fs ml mf {
	pnorm `f_`s'' _x
	gen cf_`s' = word(_x, 1)
	drop _x `f_`s''
	pnorm `l_`s'' _x
	gen cl_`s' = subinstr(_x, " ", "", .)
	drop _x `l_`s''
	gen byte ex_`s' = cf_`s'==ref_first & cf_`s'!="" & cl_`s'==ref_last & cl_`s'!=""
	gen byte xf_`s' = cf_`s'==ref_first & cf_`s'!=""
	jwpair cf_`s' ref_first jf_`s'
	/*hm_*: THE MODEL PRODUCED THE NAME (NON-EMPTY AFTER NORMALISING).*/
	if "`s'"=="ml" {
		gen byte hm_f = cf_ml!=""
		gen byte hm_l = cl_ml!=""
	}
	/*SURNAMES ARE SCORED FOR MEN ONLY.*/
	replace cl_`s' = "" if !men
	jwpair cl_`s' ref_last  jl_`s'
	replace jl_`s' = . if !men
	gen double jn_`s' = (jf_`s' + jl_`s')/2
	drop cf_`s' cl_`s'
}

/*hasml (2026-11-16): THE MODEL PRODUCED EVERY NAME SCORED: FIRST NAME AND  */
/*SURNAME FOR MEN, FIRST NAME FOR WOMEN. THE SLIDE USES THESE RECORDS ONLY.  */
gen byte hasml = (men & hm_f & hm_l) | (wom & hm_f)
drop hm_f hm_l
count if men & has_dmonth & hasml
display "men with a death month and model names: " r(N)
count if wom & has_dmonth & hasml
display "women with a death month and a model first name: " r(N)

/*CHECK: EXACT AGREEMENT EQUALS profile_names.md, "Men: first name and      */
/*surname" AND "Death month on profile: men, first name and surname".      */
/*(sample, group, anc fs ml) as printed there, to one decimal.             */
/*WOMEN: "All women: first name" AND "Death month on profile: all women,    */
/*first name". FORMAT: measure sample group anc fs ml.                      */
local chk ""
local chk `"`chk' "ex men all 59.0 68.5 63.1" "ex men disc 16.8 54.7 48.0" "ex men 0 73.2 73.2 68.1""'
local chk `"`chk' "ex men&has_dmonth all 58.4 67.6 62.4" "ex men&has_dmonth disc 17.1 53.5 47.7" "ex men&has_dmonth 0 72.3 72.3 67.4""'
local chk `"`chk' "xf wom all 72.4 76.1 74.6" "xf wom disc 53.4 67.2 66.1" "xf wom 0 79.3 79.3 77.7""'
local chk `"`chk' "xf wom&has_dmonth all 71.8 75.2 74.0" "xf wom&has_dmonth disc 53.0 66.0 65.6" "xf wom&has_dmonth 0 78.6 78.6 77.1""'
quietly count if men
assert r(N)==33593927
quietly count if men & has_dmonth
assert r(N)==27334035
quietly count if wom
assert r(N)==31426868
quietly count if wom & has_dmonth
assert r(N)==23365543
foreach c of local chk {
	tokenize `"`c'"'
	if "`3'"=="all"       local gc "1"
	else if "`3'"=="disc" local gc "inrange(cell,1,4)"
	else                  local gc "cell==`3'"
	local k 4
	foreach s in anc fs ml {
		quietly sum `1'_`s' if (`2') & `gc'
		local got = string(100*r(mean), "%5.1f")
		if strtrim("`got'")!="``k''" {
			display as error "exact agreement `1' `2' `3' `s': `got', profile_names.md ``k''"
			exit 9
		}
		local ++k
	}
}
display "CHECK PASSED: exact agreement reproduces profile_names.md"

capture file close md
file open md using `"`md'"', write replace text
file write md "# Jaro-Winkler similarity of 1940 transcriptions to FamilySearch profile names" _n _n
file write md "Generated by MATCHING/profile_names_jw.do. Do not edit by hand." _n _n
file write md "Mean Jaro-Winkler similarity (0 to 1; jarowinkler, prefix weight 0.1) between each source's name and the FamilySearch profile's, after the normalisation of MATCHING/profile_names_score.do. Sample: 1940 records in the 49 model states with all four human name fields present, attached one-to-one to a profile whose gender does not contradict the census sex. Men: profile has a usable first name and surname, scored on both (the 'first name and surname' sample of profile_names.md). Women: profile has a usable first name, scored on first names only, since a woman's profile surname may be her maiden or married name ('All women: first name'). The exact-agreement shares of profile_names.md are reproduced here as a check. Full name = mean of the first-name and surname similarities. A name the source does not have scores 0. Ours = the model's first name (namefrst_ml) and its surname with ditto marks resolved to the surname they refer to (namelast_ml_ditto), as in profile_names.md; no fallback to Ancestry. Sections marked 'model names present' keep only records where the model produced every name scored (both names for men, first name for women), so no source is scored on an empty model name; for men group 4 is then empty (shown as -), while for women it holds those whose model surname is missing, their first names being scored. Ours+Anc = ours with Ancestry's name wherever the model field is empty, field by field, as the linkage tables' New transcription; group 4 (missing) refers to the model names alone. Agreement with a selected, FamilySearch-linked reference, not accuracy. Cell 0 = Ancestry and FamilySearch agree; 1-4 = they disagree and our name matches Ancestry's (1), FamilySearch's (2), neither (3), or is missing (4)." _n

foreach spec in "men&has_dmonth&hasml|Men, death month on profile, model names present: first name and surname" "wom&has_dmonth&hasml|Women, death month on profile, model first name present: first name" "men&has_dmonth|Men, death month on profile: first name and surname" "men|Men, all profiles: first name and surname" "wom&has_dmonth|Women, death month on profile: first name" "wom|Women, all profiles: first name" {
	gettoken cond title : spec, parse("|")
	local title = substr("`title'", 2, .)
	if strpos("`cond'", "men") & !strpos("`cond'", "wom") {
		local measures "ex jn jf jl"
		local head "| group | N | exact: Ancestry | FamilySearch | ours | ours+Anc | JW full name: Ancestry | FamilySearch | ours | ours+Anc | JW first: Ancestry | FamilySearch | ours | ours+Anc | JW surname: Ancestry | FamilySearch | ours | ours+Anc |"
		local rule "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
	}
	else {
		local measures "xf jf"
		local head "| group | N | exact first: Ancestry | FamilySearch | ours | ours+Anc | JW first: Ancestry | FamilySearch | ours | ours+Anc |"
		local rule "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
	}
	file write md _n "## `title'" _n _n "`head'" _n "`rule'" _n
	foreach g in all 0 disc 1 2 3 4 {
		if "`g'"=="all"       local gc "1"
		else if "`g'"=="disc" local gc "inrange(cell,1,4)"
		else                  local gc "cell==`g'"
		quietly count if (`cond') & `gc'
		local nf = string(r(N), "%15.0fc")
		local row "| `g' | `nf' |"
		foreach m of local measures {
			foreach s in anc fs ml mf {
				quietly sum `m'_`s' if (`cond') & `gc'
				if inlist("`m'","ex","xf") local v = string(100*r(mean), "%5.1f")
				else           local v = string(r(mean), "%5.3f")
				if r(N)==0 local v "-"
				local row "`row' `v' |"
			}
		}
		file write md "`row'" _n
		display "`title' `row'"
	}
}
file close md
display "wrote `md'"

/*=========================================================*/
/*SPREAD (2026-11-17): THE SLIDE'S SAMPLES (DEATH MONTH, MODEL NAMES        */
/*PRESENT), GROUPS all, 0 (NON-TARGET) AND disc (TARGET). FOR ANCESTRY AND  */
/*OURS: MEAN AND SD OF THE JW SIMILARITY; AND OF THE PER-RECORD DIFFERENCE   */
/*ours - Ancestry: MEAN, SD, AND THE MEAN AS A SHARE OF ANCESTRY'S SD.       */
/*MEN: FULL NAME (jn); WOMEN: FIRST NAME (jf), AS ON THE SLIDE.             */
/*=========================================================*/
local sdmd "$REP_REPO/MATCHING/results/profile_names_jw_sd.md"
file open sd using `"`sdmd'"', write replace text
file write sd "# Spread of Jaro-Winkler similarity to FamilySearch profile names" _n _n
file write sd "Written by MATCHING/profile_names_jw.do. Samples as the slide 'Agreement with FamilySearch profiles': profile records a death month; the model produced every name scored. Men: full name (mean of first-name and surname JW); women: first name. Group 0 = Ancestry and FamilySearch agree (non-target); disc = they disagree (target). diff = ours - Ancestry, per record; diff/SD = mean diff divided by the SD of Ancestry's JW." _n _n
file write sd "| sample | group | N | Ancestry mean | Ancestry SD | ours mean | ours SD | diff mean | diff SD | diff/SD |" _n
file write sd "|---|---|---:|---:|---:|---:|---:|---:|---:|---:|" _n
gen double _d = .
foreach smp in men wom {
	local m = cond("`smp'"=="men", "jn", "jf")
	replace _d = `m'_ml - `m'_anc
	foreach g in all 0 disc {
		if "`g'"=="all"       local gc "1"
		else if "`g'"=="disc" local gc "inrange(cell,1,4)"
		else                  local gc "cell==0"
		local cond "`smp' & has_dmonth & hasml & `gc'"
		quietly sum `m'_anc if `cond'
		local n = r(N)
		local am = r(mean)
		local as = r(sd)
		quietly sum `m'_ml if `cond'
		assert r(N)==`n'
		local om = r(mean)
		local os = r(sd)
		quietly sum _d if `cond'
		assert r(N)==`n'
		local dm = r(mean)
		local ds = r(sd)
		local row = "| `smp' | `g' | " + string(`n', "%15.0fc") + " | " + string(`am', "%5.3f") + " | " + string(`as', "%5.3f") + " | " + string(`om', "%5.3f") + " | " + string(`os', "%5.3f") + " | " + string(`dm', "%6.3f") + " | " + string(`ds', "%5.3f") + " | " + string(`dm'/`as', "%6.2f") + " |"
		file write sd "`row'" _n
		display "SD `row'"
	}
}
drop _d
file close sd
display "wrote `sdmd'"
