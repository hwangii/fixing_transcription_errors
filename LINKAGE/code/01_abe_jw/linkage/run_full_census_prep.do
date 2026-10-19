/*------------------------------------------------------------------------------
Full Census Prep: Split by BPL

Purpose: Prepare full-count census data for state-by-state matching
- Loads full 1930 and 1940 censuses
- Generates initials from pre-cleaned names
- Filters to males, drops missing blocking vars
- Splits into per-bpl files for independent matching
- Creates bpl lookup (values present in both years)

Prerequisites:
- Full census files at the paths specified below
- Variables expected: age histid mi f_name l_name sex birthyr race bpl

Outputs:
- data/full_census/clean_names_{1930,1940}.dta  (full cleaned files)
- data/by_bpl/bpl_{X}/clean_names_{1930,1940}.dta (per-bpl files)
- data/by_bpl/bpl_list.dta (bpl values in both years, with counts)
------------------------------------------------------------------------------*/

drop _all
clear all
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
do "$ROOT/code/shared/paths.do"

cd "$ABEJW"

** Configuration **

* Step 0's output, now kept canonically in data/names/cleaned/ (see
* linkage/00_merge_names_to_census.do). Previously read from a duplicate copy
* under abe_jw/data/clean_names/, which is archived.
local raw_1930 "$D_NAMES/clean_names_1930_old"
local raw_1940 "$D_NAMES/clean_names_1940_old"

cap mkdir "data\full_census"
cap mkdir "data\by_bpl"

** Process Each Census Year **

foreach yr in 1930 1940 {

    di as text _n(2) "{hline 70}"
    di as text "Processing `yr' census..."
    di as text "{hline 70}"

    timer clear 1
    timer on 1

    use "`raw_`yr''", clear

    * Keep relevant variables
    keep age histid mi f_name l_name sex birthyr race bpl

    * Generate cleaned name variables and initials
    rename f_name f_name_cleaned
    rename l_name l_name_cleaned
    gen first_initial = substr(f_name_cleaned, 1, 1)
    gen last_initial = substr(l_name_cleaned, 1, 1)

    * Males only
    keep if sex == 1

    * Keep only variables needed for matching
    keep histid age bpl race f_name_cleaned l_name_cleaned first_initial last_initial

    * Drop records with missing blocking variables (can't match these)
    qui count
    local n_before = r(N)
    drop if missing(bpl) | missing(race) | first_initial == "" | last_initial == ""
    qui count
    local n_after = r(N)
    local n_dropped = `n_before' - `n_after'
    if `n_dropped' > 0 {
        di as text "  Dropped " as result %12.0fc `n_dropped' as text " records with missing blocking vars"
    }
    di as text "  Males with complete blocking vars: " as result %12.0fc `n_after'

    compress

    * Sort by bpl for efficient splitting
    hashsort bpl
    qui save "data\full_census\clean_names_`yr'.dta", replace
    di as text "  Saved full clean file: data\full_census\clean_names_`yr'.dta"

    * Compute bpl index (row ranges per bpl)
    keep bpl
    gen long _row = _n
    gegen long _start = min(_row), by(bpl)
    gegen long _end = max(_row), by(bpl)
    gen long _count = _end - _start + 1
    gegen _seq = seq(), by(bpl)
    qui keep if _seq == 1
    keep bpl _start _end _count
    rename _count n_`yr'

    qui count
    local n_bpl = r(N)
    di as text "  Unique bpl values: " as result `n_bpl'

    * Store index for later bpl list creation
    tempfile index_`yr'
    qui save `index_`yr''

    * Split by bpl using row ranges (fast: reads only relevant rows)
    mkmat bpl _start _end, matrix(idx)
    local saved = 0

    forval i = 1/`n_bpl' {
        local b = idx[`i', 1]
        local s = idx[`i', 2]
        local e = idx[`i', 3]

        cap mkdir "data\by_bpl\bpl_`b'"

        qui use "data\full_census\clean_names_`yr'.dta" in `s'/`e', clear
        qui save "data\by_bpl\bpl_`b'\clean_names_`yr'.dta", replace
        local ++saved

        if mod(`saved', 10) == 0 {
            di as text "    Split `saved'/`n_bpl' bpl groups..."
        }
    }

    timer off 1
    qui timer list 1
    di as text "  Split `saved' bpl groups in " as result %6.1f `r(t1)' as text " seconds"
}

** Create BPL Lookup (values present in both years) **

di as text _n(2) "{hline 70}"
di as text "Creating bpl lookup..."
di as text "{hline 70}"

use `index_1930', clear
keep bpl n_1930
qui merge 1:1 bpl using `index_1940', keep(3) nogen keepusing(bpl n_1940)

gen long n_total = n_1930 + n_1940

sort bpl
qui save "data\by_bpl\bpl_list.dta", replace

qui count
local n_both = r(N)
qui sum n_1930
local total_1930 = r(sum)
qui sum n_1940
local total_1940 = r(sum)

di as text "BPL values in both years: " as result `n_both'
di as text "Total 1930 males to match: " as result %12.0fc `total_1930'
di as text "Total 1940 males to match: " as result %12.0fc `total_1940'

* Show largest bpl groups
di as text _n "Largest 10 bpl groups:"
hashsort -n_total
list bpl n_1930 n_1940 n_total in 1/`=min(10, _N)', noobs

di as text _n "{hline 70}"
di as text "Prep complete. Next: run_full_census_match.do"
di as text "{hline 70}"
