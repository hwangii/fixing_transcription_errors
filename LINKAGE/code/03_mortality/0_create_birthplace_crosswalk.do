****************************************************
* 0. Build harmonized birthplace crosswalk
*    - Census:  string birthplace var = bpl
*    - BUNMD:   string birthplace var = bpl_string
****************************************************

* --- 0a. Get unique birthplace strings from census ---
di "Collecting birthplace strings from census..."
use "$census_raw", clear

* keep only birthplace string
keep bpl
rename bpl bpl_code
decode bpl, gen(bpl)
keep bpl

drop if missing(bpl)
duplicates drop

tempfile c_bpl
save `c_bpl'

* --- 0b. Get unique birthplace strings from BUNMD ---
di "Collecting birthplace strings from BUNMD..."
import delimited "$bunmd_raw", clear varnames(1)

rename bpl bpl_code_original 
rename bpl_string bpl
keep bpl
drop if missing(bpl)
duplicates drop

tempfile b_bpl
save `b_bpl'

* --- 0c. Combine and clean strings ---
di "Building birthplace crosswalk..."
use `c_bpl', clear
append using `b_bpl'

* raw string: bpl
* cleaned version for generic matching
gen bpl_std = strlower(strtrim(bpl))

* collapse multiple internal spaces to single spaces
while strpos(bpl_std, "  ") {
    replace bpl_std = subinstr(bpl_std, "  ", " ", .)
}
replace bpl_std = strtrim(bpl_std)

* cleaned version specifically for states (remove punctuation but keep spaces)
gen  bpl_state = bpl_std
replace bpl_state = subinstr(bpl_state, ".", "", .)
replace bpl_state = subinstr(bpl_state, ",", "", .)
replace bpl_state = subinstr(bpl_state, ";", "", .)
replace bpl_state = subinstr(bpl_state, ":", "", .)
replace bpl_state = subinstr(bpl_state, "-", " ", .)   // e.g. "new-york" -> "new york"
while strpos(bpl_state, "  ") {
    replace bpl_state = subinstr(bpl_state, "  ", " ", .)
}
replace bpl_state = strtrim(bpl_state)

* Some common alias fixes for states / DC (extend as you see issues)
replace bpl_state = "district of columbia" if inlist(bpl_state, ///
    "washington dc", "washington d c", "dc", "d c", "dist of columbia")

* You can add more ad hoc replacements here as you discover them, e.g.:
* replace bpl_state = "new york" if inlist(bpl_state, "n y", "n.y.", "newyork")

* --- 0d. Use Stata's state() to recognize 50 states + DC ---
* state() returns FIPS numeric code for recognized US state names / abbreviations

statastates, name(bpl_state)
gen stfips = state_fips
drop state_abbrev state_fips _merge

replace bpl = bpl_state if bpl == ""

* Define harmonized birthplace code:
* - For recognized US states / DC: use "US-XX" where XX = FIPS
* - For others: use the generic cleaned string bpl_std
gen str20 stcode = ""
replace stcode = "US-" + string(stfips, "%02.0f") if stfips < .

gen  bpl_h = cond(stfips < ., stcode, bpl_std)

* Now bpl_h is the harmonized birthplace "code":
* - identical across census & BUNMD for the 50 states (and DC)
* - equal to cleaned text for others (countries, territories, etc.)
 
keep bpl bpl_h
duplicates drop

save "$output_dir/bpl_crosswalk.dta", replace
di "Saved harmonized birthplace crosswalk to $output_dir/bpl_crosswalk.dta"
