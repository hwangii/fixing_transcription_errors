/*SCORE: HOW OFTEN EACH 1940 TRANSCRIPTION AGREES WITH THE PROFILE NAME      */
/*(2026-11-13). Reads profile_names.dta from profile_names_build.do.        */
/*                                                                           */
/*SOURCES: Ancestry (namefrst, namelast), FamilySearch's census index        */
/*(fs_namefrst, fs_namelast) and ours (namefrst_ml, namelast_ml_ditto).      */
/*                                                                           */
/*REFERENCE NAMES: the profile's fullname (and the father's name) is         */
/*lowercased, with accents, punctuation, quoted nicknames, bracketed text,   */
/*titles and generational suffixes removed, then split into first, middle   */
/*and last by extrname (STB-13 dm13), as qq_tradeoff does for these same     */
/*profiles, run once per distinct name. Comparisons:                         */
/*  first name: extrname's first name, against the first word of each census */
/*              first-name field (which may carry a middle initial)         */
/*  surname, men: extrname's last name, against the census surname field,    */
/*              both with spaces removed ("van hooser" = "vanhooser")        */
/*  surname, never-married women (marst==6): extrname's last name of the     */
/*              father's name, compared the same way                         */
/*              (preferred parent set; robustness: parent_no==1, and dropping */
/*              women with more than one father). Profiles of married women   */
/*              may hold a maiden name, a married name, or both, so women    */
/*              who are or were ever married are scored on first names only. */
/*A transcription the model did not produce (cell 4) counts as not agreeing. */
/*Records whose profile gender contradicts the census sex are dropped.       */
/*                                                                           */
/*THIS MEASURES AGREEMENT WITH A SELECTED REFERENCE, NOT ACCURACY.          */
/*KNOWN BIAS, STATED WITH THE RESULTS: users find and attach 1940 records    */
/*through FamilySearch's own index, and profile names may be entered from    */
/*the attached record, so FamilySearch's census transcription is favoured by */
/*construction. It cannot be removed here, only signed: in cell 1, where our  */
/*name equals Ancestry's and differs from FamilySearch's, the bias works      */
/*against us, so agreement there is the conservative comparison.            */
/*Writes MATCHING/results/profile_names.md.                                  */

clear all
set more off
set linesize 255
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local out "$REP_F/fixing_transcription_errors/DATA/INTERMEDIATE/profile_names"
local md  "$REP_REPO/MATCHING/results/profile_names.md"

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
		/*TWICE, BECAUSE ADJACENT TOKENS SHARE THE SPACE BETWEEN THEM.*/
		forvalues i = 1/2 {
			replace `newvar' = ustrregexra(" " + `newvar' + " ", " (jr|sr|ii|iii|iv|mr|mrs|miss|ms|dr|rev) ", " ")
		}
		replace `newvar' = strtrim(stritrim(`newvar'))
	}
end

use `"`out'/profile_names.dta"', clear
display "records: " _N

/*PROFILE GENDER MUST AGREE WITH CENSUS SEX.*/
gen byte pmale = lower(gender)=="male"
gen byte pfem  = lower(gender)=="female"
local n_all = _N
count if (sex==1 & pfem) | (sex==2 & pmale)
local n_gender = r(N)
display "dropped: profile gender contradicts census sex: " r(N)
drop if (sex==1 & pfem) | (sex==2 & pmale)

/*extrname IS SLOW, SO IT RUNS ON DISTINCT VALUES AND IS MERGED BACK (THE   */
/*PATTERN OF qq_tradeoff/data_construction_v9_stage3_names_dedup.do).        */
/*Its parts come back cased and with periods ("Van Hooser", "A."): letters   */
/*only, lowercased, are kept. A name with no surname part gets none.         */
capture program drop xsplit
program define xsplit
	args src fvar lvar
	tempfile parts
	preserve
	keep `src'
	drop if `src'==""
	duplicates drop
	display "extrname on " _N " distinct values of `src'"
	extrname `src', first(_xf) middle(_xm) last(_xl) odd(_xo)
	quietly count if _xo!=0 & !missing(_xo)
	display "  flagged odd by extrname: " r(N) " (" %4.1f 100*r(N)/_N "%)"
	gen `fvar' = ustrregexra(lower(_xf), "[^a-z]", "")
	gen `lvar' = ustrregexra(lower(_xl), "[^a-z]", "")
	keep `src' `fvar' `lvar'
	save `parts'
	restore
	merge m:1 `src' using `parts', keep(1 3) nogen
end

/*REFERENCE NAMES*/
pnorm fullname _pf
xsplit _pf ref_first ref_last
drop _pf
foreach f in pref p1 {
	pnorm father_`f' _fa
	xsplit _fa _faf ref_last_`f'
	drop _fa _faf
}

/*CENSUS NAMES: THE FIELDS ARE ALREADY SEPARATE. FIRST WORD OF THE FIRST-   */
/*NAME FIELD; THE WHOLE SURNAME FIELD WITH SPACES REMOVED.                   */
local f_anc namefrst
local l_anc namelast
local f_fs  fs_namefrst
local l_fs  fs_namelast
local f_ml  namefrst_ml
local l_ml  namelast_ml_ditto
foreach s in anc fs ml {
	pnorm `f_`s'' _x
	gen cf_`s' = word(_x, 1)
	drop _x
	pnorm `l_`s'' _x
	gen cl_`s' = subinstr(_x, " ", "", .)
	drop _x
}

/*MATCH INDICATORS: AN EMPTY TRANSCRIPTION NEVER MATCHES.*/
foreach s in anc fs ml {
	gen byte mf_`s' = cf_`s'==ref_first & cf_`s'!=""
	foreach r in last last_pref last_p1 {
		gen byte m`r'_`s' = cl_`s'==ref_`r' & cl_`s'!=""
	}
}

/*SAMPLES: (condition on the record, surname reference variable)            */
gen byte men  = sex==1
gen byte nmw  = sex==2 & marst==6
gen byte wom  = sex==2
gen byte nmw1 = nmw & n_fathers==1

capture file close md
file open md using `"`md'"', write replace text
file write md "# Agreement of 1940 transcriptions with FamilySearch profile names" _n _n
file write md "Generated by MATCHING/profile_names_score.do from profile_names.dta (MATCHING/profile_names_build.do). Do not edit by hand." _n _n
file write md "Percent agreeing with the FamilySearch profile, by source, among 1940 records in the 49 model states with all four human name fields present, attached one-to-one to a profile, whose profile gender does not contradict the census sex, and which have the reference name the row needs. This is agreement with a selected, FamilySearch-linked reference, not accuracy: profiles are often built from the FamilySearch-indexed record. Cell 0 = Ancestry and FamilySearch agree; 1-4 = they disagree and our name matches Ancestry's (1), FamilySearch's (2), neither (3), or is missing (4)." _n _n
file write md "## Sample" _n _n "| step | records |" _n "|---|---:|" _n
foreach c in n_census n_xwalk n_xmh n_xmu n_linked n_noipums n_noinfo {
	local v : char _dta[`c']
	local `c' = string(`v', "%15.0fc")
}
file write md "| human-complete 1940 records, 49 states | `n_census' |" _n
file write md "| crosswalk rows (histid-profile pairs) | `n_xwalk' |" _n
file write md "| ... crosswalk rows dropped: their record is attached to >1 profile | `n_xmh' |" _n
file write md "| ... crosswalk rows dropped: their profile is attached to >1 record (rows can be in both groups) | `n_xmu' |" _n
file write md "| human-complete records attached to exactly one profile | `n_linked' |" _n
file write md "| ... of which no IPUMS row (no sex or marital status) | `n_noipums' |" _n
file write md "| ... of which no profile info row (no name) | `n_noinfo' |" _n
file write md "| dropped: profile gender contradicts census sex | " %15.0fc (`n_gender') " |" _n

capture program drop scoreblock
program define scoreblock
	/*scoreblock TITLE SAMPLEVAR MEASURE [extra condition]                   */
	/*MEASURE: first | full_<r> | last_<r>, r in last last_pref last_p1      */
	args title svar measure extra
	file write md _n "## `title'" _n _n
	file write md "| group | N | Ancestry | FamilySearch | ours |" _n "|---|---:|---:|---:|---:|" _n
	tempvar ok m_anc m_fs m_ml
	if "`measure'"=="first" {
		gen byte `ok' = `svar' & ref_first!=""
		foreach s in anc fs ml {
			gen byte `m_`s'' = mf_`s'
		}
	}
	else {
		local r = substr("`measure'", strpos("`measure'", "_")+1, .)
		local kind = substr("`measure'", 1, strpos("`measure'", "_")-1)
		if "`kind'"=="full" gen byte `ok' = `svar' & ref_first!="" & ref_`r'!=""
		else                gen byte `ok' = `svar' & ref_`r'!=""
		foreach s in anc fs ml {
			if "`kind'"=="full" gen byte `m_`s'' = mf_`s' & m`r'_`s'
			else                gen byte `m_`s'' = m`r'_`s'
		}
	}
	if `"`extra'"'!="" replace `ok' = `ok' & (`extra')
	foreach g in all 0 disc 1 2 3 4 {
		if "`g'"=="all"       local gc "1"
		else if "`g'"=="disc" local gc "inrange(cell,1,4)"
		else                  local gc "cell==`g'"
		quietly count if `ok' & `gc'
		local n = r(N)
		if `n'==0 {
			file write md "| `g' | 0 | | | |" _n
			continue
		}
		foreach s in anc fs ml {
			quietly sum `m_`s'' if `ok' & `gc'
			local p_`s' = string(100*r(mean), "%5.1f")
		}
		local nf = string(`n', "%15.0fc")
		file write md "| `g' | `nf' | `p_anc' | `p_fs' | `p_ml' |" _n
		display "`title' | `g' | N=`nf' | anc `p_anc' fs `p_fs' ml `p_ml'"
	}
end

/*MAIN*/
scoreblock "Men: first name and surname" men full_last
scoreblock "Men: first name" men first
scoreblock "Men: surname" men last_last
scoreblock "Never-married women: first name and surname (father's surname, preferred parents)" nmw full_last_pref
scoreblock "Never-married women: surname (father's surname, preferred parents)" nmw last_last_pref
scoreblock "All women: first name" wom first

/*ROBUSTNESS: WOMEN'S FATHER*/
scoreblock "Robustness: never-married women, father with parent_no==1" nmw full_last_p1
scoreblock "Robustness: never-married women with exactly one father" nmw1 full_last_pref

/*ROBUSTNESS: PROFILE HAS A BIRTH DATE (AT LEAST ONE NON-CENSUS FACT)*/
scoreblock "Robustness: men, profile has a birth date" men full_last `"birthdate!="""'

/*ROBUSTNESS: THE APPENDIX'S RULE (3) -- AT LEAST ONE SOURCE MATCHES.        */
/*IT SELECTS ON THE OUTCOME, SO IT IS SHOWN BESIDE THE MAIN RESULT ONLY.     */
scoreblock "Rule (3): men, at least one source matches first name and surname" men full_last "(mf_anc & mlast_anc) | (mf_fs & mlast_fs) | (mf_ml & mlast_ml)"

file close md
display "wrote `md'"
