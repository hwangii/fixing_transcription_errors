/*------------------------------------------------------------------------------
Check for Missing Blocking Variables

This checks if observations are being dropped due to missing blocking variables
in pairing_chunked_gtools but NOT in original pairing.ado
------------------------------------------------------------------------------*/

clear all

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
if "$LCODE" == "" global LCODE "F:/github_repos/fixing_transcription_errors/LINKAGE/code"
do "$LCODE/shared/paths.do"

cd "$ABEJW"

di as text _n "{hline 80}"
di as text "CHECKING FOR MISSING BLOCKING VARIABLES"
di as text "{hline 80}"

local blocking_vars "bpl first_initial last_initial race"

** Check 1930 data **
use "data\clean_names\clean_names_1930.dta", clear

qui count
local total_1930 = r(N)

foreach var of local blocking_vars {
    qui count if missing(`var')
    local miss_`var'_1930 = r(N)
    local pct = 100 * r(N) / `total_1930'
    di as text "1930 - `var' missing: " as result %8.0fc r(N) as text " (" as result %5.2f `pct' as text "%)"
}

* Count observations with ANY missing blocking var
qui count if missing(bpl) | missing(first_initial) | missing(last_initial) | missing(race)
local missing_any_1930 = r(N)
local pct_1930 = 100 * `missing_any_1930' / `total_1930'

di as text _n "1930 SUMMARY:"
di as text "  Total observations:     " as result %10.0fc `total_1930'
di as text "  With ANY missing block var: " as result %10.0fc `missing_any_1930' ///
    as text " (" as result %5.2f `pct_1930' as text "%)"
di as text "  Available for pairing:  " as result %10.0fc `total_1930' - `missing_any_1930' ///
    as text " (" as result %5.2f 100 - `pct_1930' as text "%)"

** Check 1940 data **
use "data\clean_names\clean_names_1940.dta", clear

qui count
local total_1940 = r(N)

foreach var of local blocking_vars {
    qui count if missing(`var')
    local miss_`var'_1940 = r(N)
    local pct = 100 * r(N) / `total_1940'
    di as text "1940 - `var' missing: " as result %8.0fc r(N) as text " (" as result %5.2f `pct' as text "%)"
}

* Count observations with ANY missing blocking var
qui count if missing(bpl) | missing(first_initial) | missing(last_initial) | missing(race)
local missing_any_1940 = r(N)
local pct_1940 = 100 * `missing_any_1940' / `total_1940'

di as text _n "1940 SUMMARY:"
di as text "  Total observations:     " as result %10.0fc `total_1940'
di as text "  With ANY missing block var: " as result %10.0fc `missing_any_1940' ///
    as text " (" as result %5.2f `pct_1940' as text "%)"
di as text "  Available for pairing:  " as result %10.0fc `total_1940' - `missing_any_1940' ///
    as text " (" as result %5.2f 100 - `pct_1940' as text "%)"

** Diagnosis **
di as text _n(2) "{hline 80}"
di as text "DIAGNOSIS"
di as text "{hline 80}"

if `missing_any_1930' > 0 | `missing_any_1940' > 0 {
    di as error _n "⚠️  BLOCKING VARIABLE DROPOUT DETECTED!"
    di as text _n "pairing_chunked_gtools DROPS observations with missing blocking variables."
    di as text "The original pairing.ado might handle these differently."
    di as text _n "Impact on candidate pairs:"
    di as text "  - Observations dropped from 1930: " as result %5.2f `pct_1930' as text "%"
    di as text "  - Observations dropped from 1940: " as result %5.2f `pct_1940' as text "%"
    di as text "  - Estimated reduction in pairs:  " as result %5.2f ///
        (1 - (1-`pct_1930'/100) * (1-`pct_1940'/100)) * 100 as text "%"

    di as text _n "SOLUTION:"
    di as text "  Option 1: Fill missing blocking variables in Stage 1 (01_clean_names.do)"
    di as text "  Option 2: Modify pairing_chunked_gtools to NOT drop missing blocking vars"
    di as text "  Option 3: Use different blocking variables that don't have missing values"
}
else {
    di as result "✓ No missing blocking variables found"
    di as text "The bug is NOT due to blocking variable dropout"
}

di as text _n "{hline 80}"