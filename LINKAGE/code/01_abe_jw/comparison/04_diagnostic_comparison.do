/*------------------------------------------------------------------------------
Diagnostic Comparison: Where Do the Match Counts Diverge?

This script identifies at which stage the match counts diverge between:
- ABE-JW Original (using pairing.ado)
- Current Implementation (using pairing_chunked_gtools)

Tests:
1. Number of candidate pairs after pairing (before decision rules)
2. Number of matches after decision rules (x=0 and x=2)
3. Distribution of matches by block characteristics

This will tell us if the bug is in:
- The pairing stage (different candidate pairs generated)
- The decision rule stage (different filtering logic)
- Block processing (missing or corrupted blocks)
------------------------------------------------------------------------------*/

clear all
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
if "$LCODE" == "" global LCODE "F:/github_repos/fixing_transcription_errors/LINKAGE/code"
do "$LCODE/shared/paths.do"

cd "$ABEJW"

di as text _n(2) "{hline 80}"
di as text "DIAGNOSTIC COMPARISON: ABE-JW Original vs Current Implementation"
di as text "{hline 80}"

** Part 1: Compare Candidate Pairs (After Pairing, Before Decision Rules) **

di as text _n(2) "{hline 80}"
di as text "PART 1: Candidate Pairs Comparison (After Pairing Step)"
di as text "{hline 80}"

* Count candidate pairs from ABE-JW Original
cap confirm file "abe_comparison\output\candidate_pairs.dta"
if _rc == 0 {
    use "abe_comparison\output\candidate_pairs.dta", clear
    qui count
    local n_pairs_original = r(N)

    qui sum age_diff, detail
    local age_diff_mean_orig = r(mean)
    local age_diff_p50_orig = r(p50)

    qui sum jw_f_name_cleaned, detail
    local jw_f_mean_orig = r(mean)

    qui sum jw_l_name_cleaned, detail
    local jw_l_mean_orig = r(mean)

    * Count unique individuals
    gegen n_A = tag(Ahistid)
    qui sum n_A
    local n_unique_A_orig = r(sum)

    gegen n_B = tag(Bhistid)
    qui sum n_B
    local n_unique_B_orig = r(sum)

    di as text _n "ABE-JW Original (pairing.ado):"
    di as text "  Candidate pairs:     " as result %12.0fc `n_pairs_original'
    di as text "  Unique 1930 persons: " as result %12.0fc `n_unique_A_orig'
    di as text "  Unique 1940 persons: " as result %12.0fc `n_unique_B_orig'
    di as text "  Avg pairs per A:     " as result %6.2f `=`n_pairs_original'/`n_unique_A_orig''
    di as text "  Avg pairs per B:     " as result %6.2f `=`n_pairs_original'/`n_unique_B_orig''
    di as text "  Mean age_diff:       " as result %6.2f `age_diff_mean_orig'
    di as text "  Mean JW first name:  " as result %6.4f `jw_f_mean_orig'
    di as text "  Mean JW last name:   " as result %6.4f `jw_l_mean_orig'
}
else {
    di as error "  ERROR: candidate_pairs.dta not found for ABE-JW Original"
    di as error "  Run 02_abe_jw_matching.do first"
    local n_pairs_original = 0
    local n_unique_A_orig = 0
    local n_unique_B_orig = 0
}

* Count candidate pairs from Current Implementation (need to combine all blocks)
di as text _n "Current Implementation (pairing_chunked_gtools):"

cap confirm file "data\BlocksAtoB\Block_key.dta"
if _rc == 0 {
    use "data\BlocksAtoB\Block_key.dta", clear
    qui levelsof block_number, local(blocks) clean

    local n_blocks : word count `blocks'
    di as text "  Found `n_blocks' blocks"

    clear
    local blocks_loaded = 0
    foreach block_num of local blocks {
        * Check for split blocks
        use "data\BlocksAtoB\Block_key.dta", clear
        qui keep if block_number == `block_num'
        qui sum _is_split
        local is_split = r(max)
        qui sum _is_merged
        local is_merged = r(max)

        clear

        if `is_merged' == 1 {
            cap confirm file "data\BlocksAtoB\Block`block_num'_merged.dta"
            if _rc == 0 {
                qui append using "data\BlocksAtoB\Block`block_num'_merged.dta"
                local ++blocks_loaded
            }
        }
        else if `is_split' == 1 {
            use "data\BlocksAtoB\Block_key.dta", clear
            qui keep if block_number == `block_num'
            qui levelsof chunk_num, local(chunks) clean

            clear
            foreach chunk of local chunks {
                cap confirm file "data\BlocksAtoB\Block`block_num'_`chunk'.dta"
                if _rc == 0 {
                    qui append using "data\BlocksAtoB\Block`block_num'_`chunk'.dta"
                }
            }
            if _N > 0 local ++blocks_loaded
        }
        else {
            cap confirm file "data\BlocksAtoB\Block`block_num'.dta"
            if _rc == 0 {
                qui append using "data\BlocksAtoB\Block`block_num'.dta"
                local ++blocks_loaded
            }
        }
    }

    qui count
    local n_pairs_current = r(N)

    if `n_pairs_current' > 0 {
        qui sum age_diff, detail
        local age_diff_mean_curr = r(mean)

        qui sum jw_f_name_cleaned, detail
        local jw_f_mean_curr = r(mean)

        qui sum jw_l_name_cleaned, detail
        local jw_l_mean_curr = r(mean)

        gegen n_A = tag(Ahistid)
        qui sum n_A
        local n_unique_A_curr = r(sum)

        gegen n_B = tag(Bhistid)
        qui sum n_B
        local n_unique_B_curr = r(sum)

        di as text "  Blocks loaded:       " as result %12.0fc `blocks_loaded' as text " / " as result `n_blocks'
        di as text "  Candidate pairs:     " as result %12.0fc `n_pairs_current'
        di as text "  Unique 1930 persons: " as result %12.0fc `n_unique_A_curr'
        di as text "  Unique 1940 persons: " as result %12.0fc `n_unique_B_curr'
        di as text "  Avg pairs per A:     " as result %6.2f `=`n_pairs_current'/`n_unique_A_curr''
        di as text "  Avg pairs per B:     " as result %6.2f `=`n_pairs_current'/`n_unique_B_curr''
        di as text "  Mean age_diff:       " as result %6.2f `age_diff_mean_curr'
        di as text "  Mean JW first name:  " as result %6.4f `jw_f_mean_curr'
        di as text "  Mean JW last name:   " as result %6.4f `jw_l_mean_curr'
    }
}
else {
    di as error "  ERROR: Block_key.dta not found for Current Implementation"
    di as error "  Run code/02_match_jw.do first"
    local n_pairs_current = 0
    local n_unique_A_curr = 0
    local n_unique_B_curr = 0
}

** Summary of Part 1 **
if `n_pairs_original' > 0 & `n_pairs_current' > 0 {
    local diff_pairs = `n_pairs_original' - `n_pairs_current'
    local pct_diff = 100 * `diff_pairs' / `n_pairs_original'

    di as text _n(2) "{hline 80}"
    di as text "PART 1 SUMMARY: Candidate Pairs"
    di as text "{hline 80}"
    di as text "Original:        " as result %12.0fc `n_pairs_original' as text " pairs"
    di as text "Current:         " as result %12.0fc `n_pairs_current' as text " pairs"
    di as text "Difference:      " as result %12.0fc `diff_pairs' ///
        as text " (" as result %+6.2f `pct_diff' as text "%)"

    if abs(`pct_diff') > 1 {
        di as error _n "⚠️  SIGNIFICANT DIFFERENCE IN CANDIDATE PAIRS!"
        di as error "The bug is in the PAIRING stage (before decision rules)"
        di as error "pairing.ado and pairing_chunked_gtools are generating different pairs"
    }
    else {
        di as result _n "✓ Candidate pairs are similar between methods"
        di as text "The difference is likely in the DECISION RULES stage"
    }
}

** Part 2: Compare Final Matches (After Decision Rules) **

di as text _n(2) "{hline 80}"
di as text "PART 2: Final Matches Comparison (After Decision Rules)"
di as text "{hline 80}"

foreach x in 0 2 {
    di as text _n "Decision rule x = `x':"

    * Original
    cap confirm file "abe_comparison\output\ABE_JW_matches_x`x'.dta"
    if _rc == 0 {
        use "abe_comparison\output\ABE_JW_matches_x`x'.dta", clear
        qui count
        local n_matches_orig_x`x' = r(N)
        di as text "  Original:  " as result %12.0fc `n_matches_orig_x`x'' as text " matches"
    }
    else {
        local n_matches_orig_x`x' = 0
        di as error "  Original:  File not found"
    }

    * Current
    cap confirm file "data\matched\JW_matches_x`x'.dta"
    if _rc == 0 {
        use "data\matched\JW_matches_x`x'.dta", clear
        qui count
        local n_matches_curr_x`x' = r(N)
        di as text "  Current:   " as result %12.0fc `n_matches_curr_x`x'' as text " matches"
    }
    else {
        local n_matches_curr_x`x' = 0
        di as error "  Current:   File not found"
    }

    * Difference
    if `n_matches_orig_x`x'' > 0 & `n_matches_curr_x`x'' > 0 {
        local diff = `n_matches_orig_x`x'' - `n_matches_curr_x`x''
        local pct = 100 * `diff' / `n_matches_orig_x`x''
        di as text "  Difference:" as result %12.0fc `diff' ///
            as text " (" as result %+6.2f `pct' as text "%)"
    }
}

** Final Summary **

di as text _n(2) "{hline 80}"
di as text "DIAGNOSTIC SUMMARY"
di as text "{hline 80}"

di as text _n "Candidate Pairs (Pairing Stage):"
if `n_pairs_original' > 0 & `n_pairs_current' > 0 {
    local diff = `n_pairs_original' - `n_pairs_current'
    local pct = 100 * abs(`diff') / `n_pairs_original'
    di as text "  Difference: " as result %+6.2f `pct' as text "%"

    if abs(`pct') > 5 {
        di as error _n "⚠️  PRIMARY BUG LOCATION: PAIRING STAGE"
        di as text _n "The pairing commands are generating different candidate pairs."
        di as text "This could be due to:"
        di as text "  1. Different blocking behavior"
        di as text "  2. Different filtering in clean_pairs()"
        di as text "  3. Blocks being dropped or missing in current implementation"
        di as text "  4. Different JW distance calculation"
    }
}
else {
    di as error "  Cannot compare - missing data"
}

di as text _n "Final Matches (Decision Rules Stage):"
if `n_matches_orig_x0' > 0 & `n_matches_curr_x0' > 0 {
    local diff = `n_matches_orig_x0' - `n_matches_curr_x0'
    local pct = 100 * abs(`diff') / `n_matches_orig_x0'
    di as text "  x=0 Difference: " as result %+6.2f `pct' as text "%"
}
if `n_matches_orig_x2' > 0 & `n_matches_curr_x2' > 0 {
    local diff = `n_matches_orig_x2' - `n_matches_curr_x2'
    local pct = 100 * abs(`diff') / `n_matches_orig_x2'
    di as text "  x=2 Difference: " as result %+6.2f `pct' as text "%"
}

di as text _n "{hline 80}"
di as text "Next step: Investigate the stage with the largest difference"
di as text "{hline 80}"