/*------------------------------------------------------------------------------
Master Script: Run All Algorithm Comparisons

This script runs all three matching methods in sequence and displays results.

Estimated runtime:
- ABE Exact:        ~5-10 minutes
- ABE-JW Original:  ~30-60 minutes (slower, not optimized)
- Current Impl:     Already completed (if you ran Stages 2-4)
- Comparison:       <1 minute

Total: ~40-70 minutes for full comparison
------------------------------------------------------------------------------*\\
*/

clear all
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
do "$ROOT/code/shared/paths.do"

cd "$ABEJW/abe_comparison"

di as text _n(2) "{hline 80}"
di as text "ABE ALGORITHM COMPARISON SUITE"
di as text "{hline 80}"
di as text _n "This will run three matching algorithms:"
di as text "  1. ABE Exact Matching (NYSIIS exact match)"
di as text "  2. ABE-JW Matching (Jaro-Winkler with original pairing.ado)"
di as text "  3. Comparison with your current implementation"
di as text ""
di as text "Estimated runtime: 40-70 minutes"
di as text "{hline 80}"

** Copy required .ado files **
di as text _n "Copying required files from abe_original_code..."

local ado_files "abematch.ado abeclean.ado pairing.ado filtering.do gen_initials.do"
local n_copied = 0
foreach file of local ado_files {
    cap confirm file "`file'"
    if _rc {
        cap confirm file "..\\abe_original_code\\`file'"
        if !_rc {
            copy "..\\abe_original_code\\`file'" "`file'", replace
            local ++n_copied
            di as text "  Copied: " as result "`file'"
        }
        else {
            di as error "  WARNING: `file' not found in abe_original_code"
        }
    }
    else {
        di as text "  Exists: " as result "`file'"
    }
}

if `n_copied' > 0 {
    di as result _n "Copied `n_copied' file(s)"
}

** Create output directory **
cap mkdir "output"

/*
** Part 1: ABE Exact Matching **
di as text _n(2) "{hline 80}"
di as text "PART 1\\3: ABE EXACT MATCHING (NYSIIS)"
di as text "{hline 80}"
di as text "This tests whether exact name matching would work better..."

local start_time = clock(c(current_time), "hms")

cap noi do "01_abe_exact_matching.do"
if _rc {
    di as error "ABE Exact matching failed with error code: " _rc
    di as error "Continuing to next method..."
}

local elapsed = (clock(c(current_time), "hms") - `start_time') / 60000
di as text _n "Time elapsed: " as result %5.1f `elapsed' as text " minutes"
*/

** Part 2: ABE-JW Matching (Original) **
di as text _n(2) "{hline 80}"
di as text "PART 2\\3: ABE-JW MATCHING (ORIGINAL ALGORITHM)"
di as text "{hline 80}"
di as text "This tests whether your implementation matches the original..."
di as text "NOTE: This may take 30-60 minutes (original pairing.ado is not optimized)"

local start_time = clock(c(current_time), "hms")

cap noi do "02_abe_jw_matching.do"

if _rc {
    di as error "ABE-JW matching failed with error code: " _rc
    di as error "Continuing to comparison..."
}

local elapsed = (clock(c(current_time), "hms") - `start_time') / 60000
di as text _n "Time elapsed: " as result %5.1f `elapsed' as text " minutes"

/*
** Part 3: Comparison **
di as text _n(2) "{hline 80}"
di as text "PART 3\\3: COMPARISON OF ALL METHODS"
di as text "{hline 80}"

cap noi do "03_compare_results.do"
if _rc {
    di as error "Comparison failed with error code: " _rc
}

** Final summary **
di as text _n(2) "{hline 80}"
di as text "COMPARISON COMPLETE"
di as text "{hline 80}"
di as text _n "Results saved to:"
di as text "  " as result "$ABEJW/abe_comparison\\output\\"
di as text ""
di as text "Files created:"
di as text "  ABE_exact_matches.dta"
di as text "  ABE_exact_matches_unique2yr.dta"
di as text "  ABE_JW_matches_x0.dta, ABE_JW_matches_x0_unique.dta"
di as text "  ABE_JW_matches_x2.dta, ABE_JW_matches_x2_unique.dta"
di as text ""
di as text "See the comparison table above for results."
di as text "{hline 80}"
