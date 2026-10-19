/*------------------------------------------------------------------------------
Compare Matching Results Across Implementations

This script compares match rates from:
1. ABE Exact (NYSIIS exact match - original algorithm)
2. ABE-JW Original (original algorithm implementation)
3. Current Implementation (your pairing_chunked_gtools version)

Purpose: Diagnose whether low match rates are due to:
- Implementation differences
- Algorithm choice (exact vs JW)
- Data quality issues
- Parameter choices
------------------------------------------------------------------------------*/

clear all
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
do "$ROOT/code/shared/paths.do"

cd "$ABEJW"

** Get population counts **
use "data\clean_names\clean_names_1930.dta", clear
qui count if sex == 1
local pop_1930_male = r(N)
qui count if sex == 1 & age >= 20 & age <= 40
local pop_1930_prime = r(N)

use "data\clean_names\clean_names_1940.dta", clear
qui count if sex == 1
local pop_1940_male = r(N)

** Display header **
di as text _n(2) "{hline 80}"
di as text "COMPARISON OF MATCHING ALGORITHMS"
di as text "{hline 80}"
di as text _n "Population:"
di as text "  1930 Men:              " as result %12.0fc `pop_1930_male'
di as text "  1930 Prime-age (20-40):" as result %12.0fc `pop_1930_prime'
di as text "  1940 Men:              " as result %12.0fc `pop_1940_male'
di as text ""

** Table header **
di as text "{hline 80}"
di as text "Method              | Matches  | Rate    | With Uniqueness | Rate   "
di as text "{hline 80}"

** 1. ABE Exact Matching **
cap confirm file "abe_comparison\output\ABE_exact_matches.dta"
if !_rc {
    use "abe_comparison\output\ABE_exact_matches.dta", clear
    qui count
    local n_exact = r(N)
    local rate_exact = 100 * `n_exact' / `pop_1930_male'

    cap confirm file "abe_comparison\output\ABE_exact_matches_unique2yr.dta"
    if !_rc {
        use "abe_comparison\output\ABE_exact_matches_unique2yr.dta", clear
        qui count
        local n_exact_uniq = r(N)
        local rate_exact_uniq = 100 * `n_exact_uniq' / `pop_1930_male'
    }
    else {
        local n_exact_uniq = .
        local rate_exact_uniq = .
    }
}
else {
    local n_exact = .
    local rate_exact = .
    local n_exact_uniq = .
    local rate_exact_uniq = .
}

di as text "ABE Exact (NYSIIS)  | " ///
    as result %8.0fc `n_exact' as text " | " ///
    as result %6.2f `rate_exact' as text "% | " ///
    as result %15.0fc `n_exact_uniq' as text " | " ///
    as result %6.2f `rate_exact_uniq' as text "%"

** 2. ABE-JW Original (x=0) **
cap confirm file "abe_comparison\output\ABE_JW_matches_x0.dta"
if !_rc {
    use "abe_comparison\output\ABE_JW_matches_x0.dta", clear
    qui count
    local n_jw_x0 = r(N)
    local rate_jw_x0 = 100 * `n_jw_x0' / `pop_1930_male'

    cap confirm file "abe_comparison\output\ABE_JW_matches_x0_unique.dta"
    if !_rc {
        use "abe_comparison\output\ABE_JW_matches_x0_unique.dta", clear
        qui count
        local n_jw_x0_uniq = r(N)
        local rate_jw_x0_uniq = 100 * `n_jw_x0_uniq' / `pop_1930_male'
    }
    else {
        local n_jw_x0_uniq = .
        local rate_jw_x0_uniq = .
    }
}
else {
    local n_jw_x0 = .
    local rate_jw_x0 = .
    local n_jw_x0_uniq = .
    local rate_jw_x0_uniq = .
}

di as text "ABE-JW Original x=0 | " ///
    as result %8.0fc `n_jw_x0' as text " | " ///
    as result %6.2f `rate_jw_x0' as text "% | " ///
    as result %15.0fc `n_jw_x0_uniq' as text " | " ///
    as result %6.2f `rate_jw_x0_uniq' as text "%"

** 3. ABE-JW Original (x=2) **
cap confirm file "abe_comparison\output\ABE_JW_matches_x2.dta"
if !_rc {
    use "abe_comparison\output\ABE_JW_matches_x2.dta", clear
    qui count
    local n_jw_x2 = r(N)
    local rate_jw_x2 = 100 * `n_jw_x2' / `pop_1930_male'

    cap confirm file "abe_comparison\output\ABE_JW_matches_x2_unique.dta"
    if !_rc {
        use "abe_comparison\output\ABE_JW_matches_x2_unique.dta", clear
        qui count
        local n_jw_x2_uniq = r(N)
        local rate_jw_x2_uniq = 100 * `n_jw_x2_uniq' / `pop_1930_male'
    }
    else {
        local n_jw_x2_uniq = .
        local rate_jw_x2_uniq = .
    }
}
else {
    local n_jw_x2 = .
    local rate_jw_x2 = .
    local n_jw_x2_uniq = .
    local rate_jw_x2_uniq = .
}

di as text "ABE-JW Original x=2 | " ///
    as result %8.0fc `n_jw_x2' as text " | " ///
    as result %6.2f `rate_jw_x2' as text "% | " ///
    as result %15.0fc `n_jw_x2_uniq' as text " | " ///
    as result %6.2f `rate_jw_x2_uniq' as text "%"

** 4. Current Implementation (x=0) **
cap confirm file "data\matched\JW_matches_x0.dta"
if !_rc {
    use "data\matched\JW_matches_x0.dta", clear
    qui count
    local n_current_x0 = r(N)
    local rate_current_x0 = 100 * `n_current_x0' / `pop_1930_male'

    cap confirm file "data\matched\JW_matches_x0_unique.dta"
    if !_rc {
        use "data\matched\JW_matches_x0_unique.dta", clear
        qui count
        local n_current_x0_uniq = r(N)
        local rate_current_x0_uniq = 100 * `n_current_x0_uniq' / `pop_1930_male'
    }
    else {
        local n_current_x0_uniq = .
        local rate_current_x0_uniq = .
    }
}
else {
    local n_current_x0 = .
    local rate_current_x0 = .
    local n_current_x0_uniq = .
    local rate_current_x0_uniq = .
}

di as text "Current Impl x=0    | " ///
    as result %8.0fc `n_current_x0' as text " | " ///
    as result %6.2f `rate_current_x0' as text "% | " ///
    as result %15.0fc `n_current_x0_uniq' as text " | " ///
    as result %6.2f `rate_current_x0_uniq' as text "%"

** 5. Current Implementation (x=2) **
cap confirm file "data\matched\JW_matches_x2.dta"
if !_rc {
    use "data\matched\JW_matches_x2.dta", clear
    qui count
    local n_current_x2 = r(N)
    local rate_current_x2 = 100 * `n_current_x2' / `pop_1930_male'

    cap confirm file "data\matched\JW_matches_x2_unique.dta"
    if !_rc {
        use "data\matched\JW_matches_x2_unique.dta", clear
        qui count
        local n_current_x2_uniq = r(N)
        local rate_current_x2_uniq = 100 * `n_current_x2_uniq' / `pop_1930_male'
    }
    else {
        local n_current_x2_uniq = .
        local rate_current_x2_uniq = .
    }
}
else {
    local n_current_x2 = .
    local rate_current_x2 = .
    local n_current_x2_uniq = .
    local rate_current_x2_uniq = .
}

di as text "Current Impl x=2    | " ///
    as result %8.0fc `n_current_x2' as text " | " ///
    as result %6.2f `rate_current_x2' as text "% | " ///
    as result %15.0fc `n_current_x2_uniq' as text " | " ///
    as result %6.2f `rate_current_x2_uniq' as text "%"

di as text "{hline 80}"

** Interpretation **
di as text _n "INTERPRETATION:"
di as text "{hline 80}"
di as text ""
di as text "If ABE Exact has much higher match rates than ABE-JW:"
di as text "  → JW distance threshold (0.1) may be too strict for your data"
di as text "  → Names may be spelled very inconsistently between censuses"
di as text ""
di as text "If ABE-JW Original ≈ Current Implementation:"
di as text "  → Implementation is correct"
di as text "  → Low rates are due to data quality or algorithm choice"
di as text ""
di as text "If ABE-JW Original >> Current Implementation:"
di as text "  → Bug in current implementation"
di as text "  → Check blocking variables, filtering, or decision rules"
di as text ""
di as text "Expected rates for 1930-1940 linkage (prime-age men):"
di as text "  ABE Exact:           30-50%"
di as text "  ABE-JW (less cons):  25-45%"
di as text "  ABE-JW (more cons):  20-35%"
di as text "{hline 80}"
