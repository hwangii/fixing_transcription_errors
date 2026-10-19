/*------------------------------------------------------------------------------
Diagnostic: Investigate Low Match Rates
------------------------------------------------------------------------------*/

drop _all
clear all
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
do "$ROOT/code/shared/paths.do"

cd "$ABEJW"

di as text _n "{hline 70}"
di as text "Diagnostic Analysis: Match Rate Investigation"
di as text "{hline 70}"

/*==============================================================================
Part 1: Population Counts by Age and Sex
==============================================================================*/

** 1930 population **
use "data\clean_names\clean_names_1930.dta", clear

di as text _n "1930 Delaware Population:"
qui count
di as text "  Total: " as result %12.0fc r(N)

qui count if sex == 1
local men_1930 = r(N)
di as text "  Men: " as result %12.0fc `men_1930'

qui count if sex == 2
di as text "  Women: " as result %12.0fc r(N)

** Prime-age men **
qui count if sex == 1 & age >= 20 & age <= 40
local prime_men_1930 = r(N)
di as text "  Prime-age men (20-40): " as result %12.0fc `prime_men_1930'

** 1940 population **
use "data\clean_names\clean_names_1940.dta", clear

di as text _n "1940 Delaware Population:"
qui count
di as text "  Total: " as result %12.0fc r(N)

qui count if sex == 1
di as text "  Men: " as result %12.0fc r(N)

qui count if sex == 2
di as text "  Women: " as result %12.0fc r(N)

qui count if sex == 1 & age >= 20 & age <= 40
di as text "  Prime-age men (20-40): " as result %12.0fc r(N)

/*==============================================================================
Part 2: Match Rates by Type
==============================================================================*/

di as text _n "{hline 70}"
di as text "Match Rates by Type (for ALL men)"
di as text "{hline 70}"

foreach x in 0 2 {
    di as text _n "=== x = `x' ==="

    ** Before uniqueness filtering **
    cap confirm file "data\matched\JW_matches_x`x'.dta"
    if _rc == 0 {
        use "data\matched\JW_matches_x`x'.dta", clear
        qui count
        local n_matches = r(N)
        local rate = 100 * `n_matches' / `men_1930'

        di as text "Before uniqueness:"
        di as text "  Matches: " as result %12.0fc `n_matches'
        di as text "  Rate:    " as result %5.2f `rate' as text "%"
    }

    ** After uniqueness filtering **
    cap confirm file "data\matched\JW_matches_x`x'_unique.dta"
    if _rc == 0 {
        use "data\matched\JW_matches_x`x'_unique.dta", clear
        qui count
        local n_matches_uniq = r(N)
        local rate_uniq = 100 * `n_matches_uniq' / `men_1930'
        local pct_kept = 100 * `n_matches_uniq' / `n_matches'

        di as text "After uniqueness:"
        di as text "  Matches: " as result %12.0fc `n_matches_uniq'
        di as text "  Rate:    " as result %5.2f `rate_uniq' as text "%"
        di as text "  % kept:  " as result %5.1f `pct_kept' as text "%"
    }
}

/*==============================================================================
Part 3: Race Consistency Check
==============================================================================*/

di as text _n "{hline 70}"
di as text "Race Consistency Analysis (using x0 matches)"
di as text "{hline 70}"

cap confirm file "data\matched\JW_matches_x0.dta"
if _rc == 0 {
    use "data\matched\JW_matches_x0.dta", clear

    ** Merge in race from both years **
    rename Ahistid histid
    merge m:1 histid using "data\clean_names\clean_names_1930.dta", ///
        keepusing(race) keep(1 3) nogen
    rename race race_1930
    rename histid Ahistid

    rename Bhistid histid
    merge m:1 histid using "data\clean_names\clean_names_1940.dta", ///
        keepusing(race) keep(1 3) nogen
    rename race race_1940
    rename histid Bhistid

    ** Check consistency **
    gen byte race_mismatch = (race_1930 != race_1940)

    qui count
    local total = r(N)
    qui count if race_mismatch == 1
    local n_mismatch = r(N)
    local pct_mismatch = 100 * `n_mismatch' / `total'

    di as text "Race coding consistency:"
    di as text "  Matches with consistent race: " as result %12.0fc `total' - `n_mismatch'
    di as text "  Matches with race mismatch:   " as result %12.0fc `n_mismatch' ///
        as text " (" as result %5.2f `pct_mismatch' as text "%)"

    if `pct_mismatch' > 5 {
        di as error _n "WARNING: High race mismatch rate!"
        di as error "Blocking on race may be excluding valid matches."
    }
}
else {
    di as error "Cannot find JW_matches_x0.dta - run Stage 3 first"
}

/*==============================================================================
Part 4: Match Rates by Age Group
==============================================================================*/

di as text _n "{hline 70}"
di as text "Match Rates by Age Group (1930 age, using x0 matches)"
di as text "{hline 70}"

** Get 1930 population by age **
use "data\clean_names\clean_names_1930.dta", clear
keep if sex == 1  // Men only

gen age_group = .
replace age_group = 1 if age >= 0 & age <= 9
replace age_group = 2 if age >= 10 & age <= 19
replace age_group = 3 if age >= 20 & age <= 29
replace age_group = 4 if age >= 30 & age <= 39
replace age_group = 5 if age >= 40 & age <= 49
replace age_group = 6 if age >= 50 & age <= 59
replace age_group = 7 if age >= 60

gcollapse (count) n_1930=histid, by(age_group)
tempfile pop_1930
save `pop_1930'

** Get matched counts by age **
cap confirm file "data\matched\JW_matches_x0.dta"
if _rc == 0 {
    use "data\matched\JW_matches_x0.dta", clear

    rename Ahistid histid
    merge m:1 histid using "data\clean_names\clean_names_1930.dta", ///
        keepusing(age sex) keep(3) nogen
    keep if sex == 1

    gen age_group = .
    replace age_group = 1 if age >= 0 & age <= 9
    replace age_group = 2 if age >= 10 & age <= 19
    replace age_group = 3 if age >= 20 & age <= 29
    replace age_group = 4 if age >= 30 & age <= 39
    replace age_group = 5 if age >= 40 & age <= 49
    replace age_group = 6 if age >= 50 & age <= 59
    replace age_group = 7 if age >= 60

    gcollapse (count) n_matched=histid, by(age_group)

    merge 1:1 age_group using `pop_1930', nogen
    gen match_rate = 100 * n_matched / n_1930

    di as text _n "Age Group   | N (1930) | Matched  | Rate"
    di as text "{hline 45}"

    forvalues i = 1/7 {
        qui sum n_1930 if age_group == `i'
        local n = r(mean)
        qui sum n_matched if age_group == `i'
        local m = r(mean)
        qui sum match_rate if age_group == `i'
        local r = r(mean)

        if `i' == 1 di as text "0-9         | " as result %8.0fc `n' as text " | " as result %8.0fc `m' as text " | " as result %5.2f `r' as text "%"
        if `i' == 2 di as text "10-19       | " as result %8.0fc `n' as text " | " as result %8.0fc `m' as text " | " as result %5.2f `r' as text "%"
        if `i' == 3 di as text "20-29       | " as result %8.0fc `n' as text " | " as result %8.0fc `m' as text " | " as result %5.2f `r' as text "%"
        if `i' == 4 di as text "30-39       | " as result %8.0fc `n' as text " | " as result %8.0fc `m' as text " | " as result %5.2f `r' as text "%"
        if `i' == 5 di as text "40-49       | " as result %8.0fc `n' as text " | " as result %8.0fc `m' as text " | " as result %5.2f `r' as text "%"
        if `i' == 6 di as text "50-59       | " as result %8.0fc `n' as text " | " as result %8.0fc `m' as text " | " as result %5.2f `r' as text "%"
        if `i' == 7 di as text "60+         | " as result %8.0fc `n' as text " | " as result %8.0fc `m' as text " | " as result %5.2f `r' as text "%"
    }
}

di as text _n "{hline 70}"
di as text "Diagnostic Analysis Complete"
di as text "{hline 70}"
