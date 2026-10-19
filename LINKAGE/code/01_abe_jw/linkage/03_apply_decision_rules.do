/*------------------------------------------------------------------------------
Stage 3: Apply ABE-JW Decision Rules

Purpose: Apply decision rules to candidate pairs from Stage 2
- Uses TWO-PASS approach for correct global minimum calculation:
  Pass 1: Load ALL blocks, calculate global min_age_dist for each individual
  Pass 2: Apply decision rules using global minimums (not block-level)
- Handles split blocks (Block{N}_{C}.dta), merged blocks (Block{N}_merged.dta),
  and unsplit blocks (Block{N}.dta)
- Uses gtools (gegen) for speed
- RAM-efficient: loads all blocks once in Pass 1, then processes individually
- Implements three-scenario matching logic:
  1. No potential match → drop
  2. Unique bidirectional match → accept
  3. Multiple matches → apply age-based decision rule with parameter x

CRITICAL FIX: Previously calculated min_age_dist per block, which gave incorrect
reference points for individuals appearing in multiple blocks. Now calculates
globally across ALL candidate pairs before applying decision rules.

Outputs:
- data/matched/JW_matches_x0.dta (less conservative)
- data/matched/JW_matches_x2.dta (more conservative)
------------------------------------------------------------------------------*/

drop _all
clear all
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
do "$ROOT/code/shared/paths.do"

** Define Parameters **

cd "$ABEJW"

global block_dir "data\BlocksAtoB"
global output_dir "data\matched"
global rules "0 2"              // Decision rule x values (0 = less conservative, 2 = more conservative)
global max_age_diff = 2         // Maximum age difference for final matches

cap mkdir "$output_dir"

** Load Block Key to Identify All Blocks **

use "$block_dir\Block_key.dta", clear

// Get unique block numbers (each block may have multiple tasks/chunks)
gegen block_list = group(block_number), missing
qui levelsof block_number, local(blocks) clean

local n_blocks : word count `blocks'
di as text _n "Found `n_blocks' blocks to process"

** PASS 1: Calculate Global Minimum Age Distances **

di as text _n "Pass 1: Calculating global minimum age distances across all blocks..."

clear
local blocks_loaded_pass1 = 0

foreach block_num of local blocks {
    * Identify all files for this block (handles split, merged, and unsplit)
    use "$block_dir\Block_key.dta", clear
    qui keep if block_number == `block_num'

    * Check what type of block this is
    qui sum _is_split
    local is_split = r(max)
    qui sum _is_merged
    local is_merged = r(max)

    * Load appropriate file(s) and append
    clear

    if `is_merged' == 1 {
        cap confirm file "$block_dir\Block`block_num'_merged.dta"
        if _rc == 0 {
            qui append using "$block_dir\Block`block_num'_merged.dta"
            local ++blocks_loaded_pass1
        }
    }
    else if `is_split' == 1 {
        qui use "$block_dir\Block_key.dta", clear
        qui keep if block_number == `block_num'
        qui levelsof chunk_num, local(chunks) clean

        clear
        foreach chunk of local chunks {
            cap confirm file "$block_dir\Block`block_num'_`chunk'.dta"
            if _rc == 0 {
                qui append using "$block_dir\Block`block_num'_`chunk'.dta"
            }
        }
        if _N > 0 local ++blocks_loaded_pass1
    }
    else {
        cap confirm file "$block_dir\Block`block_num'.dta"
        if _rc == 0 {
            qui append using "$block_dir\Block`block_num'.dta"
            local ++blocks_loaded_pass1
        }
    }
}

qui count
local total_pairs = r(N)
di as text "  Loaded " as result `blocks_loaded_pass1' as text " blocks with " as result %12.0fc `total_pairs' as text " total candidate pairs"

* Calculate GLOBAL minimum age distances for each individual
di as text "  Calculating global minimums..."
gegen min_age_dist_A = min(age_diff), by(Ahistid)
gegen min_age_dist_B = min(age_diff), by(Bhistid)

* Keep only the minimum age distances for each individual
gcollapse (min) min_age_dist_A, by(Ahistid)
tempfile global_mins_A
save `global_mins_A'

* Reload and get B minimums
clear
foreach block_num of local blocks {
    use "$block_dir\Block_key.dta", clear
    qui keep if block_number == `block_num'
    qui sum _is_split
    local is_split = r(max)
    qui sum _is_merged
    local is_merged = r(max)

    clear
    if `is_merged' == 1 {
        cap confirm file "$block_dir\Block`block_num'_merged.dta"
        if _rc == 0 {
            qui append using "$block_dir\Block`block_num'_merged.dta"
        }
    }
    else if `is_split' == 1 {
        qui use "$block_dir\Block_key.dta", clear
        qui keep if block_number == `block_num'
        qui levelsof chunk_num, local(chunks) clean
        clear
        foreach chunk of local chunks {
            cap confirm file "$block_dir\Block`block_num'_`chunk'.dta"
            if _rc == 0 {
                qui append using "$block_dir\Block`block_num'_`chunk'.dta"
            }
        }
    }
    else {
        cap confirm file "$block_dir\Block`block_num'.dta"
        if _rc == 0 {
            qui append using "$block_dir\Block`block_num'.dta"
        }
    }
}

gegen min_age_dist_B = min(age_diff), by(Bhistid)
gcollapse (min) min_age_dist_B, by(Bhistid)
tempfile global_mins_B
save `global_mins_B'

di as result "  Global minimums calculated"

** PASS 2: Apply Decision Rules Using Global Minimums **

di as text _n "Pass 2: Applying decision rules with global minimums..."

local block_counter = 0
tempfile all_matches_x0 all_matches_x2

foreach block_num of local blocks {
    local ++block_counter
    if mod(`block_counter', 10) == 0 {
        di as text "Processing block `block_counter'/`n_blocks' (Block `block_num')..."
    }

    * Identify all files for this block (handles split, merged, and unsplit)
    use "$block_dir\Block_key.dta", clear
    qui keep if block_number == `block_num'

    * Check what type of block this is
    qui sum _is_split
    local is_split = r(max)
    qui sum _is_merged
    local is_merged = r(max)

    * Load appropriate file(s)
    clear

    if `is_merged' == 1 {
        * Merged block: Block{N}_merged.dta
        cap confirm file "$block_dir\Block`block_num'_merged.dta"
        if _rc == 0 {
            qui use "$block_dir\Block`block_num'_merged.dta"
        }
    }
    else if `is_split' == 1 {
        * Split block: append all Block{N}_{C}.dta files
        qui use "$block_dir\Block_key.dta", clear
        qui keep if block_number == `block_num'
        qui levelsof chunk_num, local(chunks) clean

        clear
        foreach chunk of local chunks {
            cap confirm file "$block_dir\Block`block_num'_`chunk'.dta"
            if _rc == 0 {
                qui append using "$block_dir\Block`block_num'_`chunk'.dta"
            }
        }
    }
    else {
        * Unsplit block: Block{N}.dta
        cap confirm file "$block_dir\Block`block_num'.dta"
        if _rc == 0 {
            qui use "$block_dir\Block`block_num'.dta"
        }
    }

    * Skip if block is empty or doesn't exist
    qui count
    if r(N) == 0 {
        continue
    }

    ** Apply Decision Rules Using Global Minimums **

    * Merge global minimum age distances
    merge m:1 Ahistid using `global_mins_A', keep(1 3) nogen
    merge m:1 Bhistid using `global_mins_B', keep(1 3) nogen

    * For individuals not in global mins (shouldn't happen), use block-level min as fallback
    qui count if missing(min_age_dist_A)
    if r(N) > 0 {
        gegen temp_min_A = min(age_diff), by(Ahistid)
        replace min_age_dist_A = temp_min_A if missing(min_age_dist_A)
        drop temp_min_A
    }
    qui count if missing(min_age_dist_B)
    if r(N) > 0 {
        gegen temp_min_B = min(age_diff), by(Bhistid)
        replace min_age_dist_B = temp_min_B if missing(min_age_dist_B)
        drop temp_min_B
    }

    * Calculate age differences from GLOBAL minimums
    gen diff_age_A = age_diff - min_age_dist_A
    gen diff_age_B = age_diff - min_age_dist_B

    * For each x value, create potential match indicator
    foreach x in $rules {

        * Mark potential matches based on x threshold
        * Keep pair if it's within x years of the GLOBAL best match for BOTH A and B
        gen byte potential_match_x`x' = ///
            (diff_age_A <= `x') & ///
            (diff_age_B <= `x')

        * Count potential matches for each individual (using gegen)
        gegen n_matches_A_x`x' = total(potential_match_x`x'), by(Ahistid)
        gegen n_matches_B_x`x' = total(potential_match_x`x'), by(Bhistid)

        * Keep only unique bidirectional matches
        * AND respect max_age_diff threshold
        gen byte match_x`x' = ///
            potential_match_x`x' == 1 & ///
            n_matches_A_x`x' == 1 & ///
            n_matches_B_x`x' == 1 & ///
            age_diff <= $max_age_diff

        * Verify no duplicates (sanity check)
        gegen count_A = total(match_x`x'), by(Ahistid)
        gegen count_B = total(match_x`x'), by(Bhistid)
        qui sum count_A if match_x`x' == 1
        if r(max) > 1 {
            di as error "ERROR: Duplicate match found for A in block `block_num', x=`x'"
            di as error "This should not happen - check matching logic"
        }
        qui sum count_B if match_x`x' == 1
        if r(max) > 1 {
            di as error "ERROR: Duplicate match found for B in block `block_num', x=`x'"
            di as error "This should not happen - check matching logic"
        }
        drop count_A count_B
    }

    ** Save Matches for Each x Value **

    foreach x in $rules {
        preserve

        qui keep if match_x`x' == 1
        qui count
        local n_matches = r(N)

        if `n_matches' > 0 {
            * Keep only ID variables and key metrics
            keep Ahistid Bhistid age_diff jw_f_name_cleaned jw_l_name_cleaned

            * Append to cumulative results
            if `block_counter' == 1 {
                tempfile matches_x`x'_block`block_num'
                qui save `matches_x`x'_block`block_num''
            }
            else {
                tempfile matches_x`x'_block`block_num'
                qui save `matches_x`x'_block`block_num''
            }
        }

        restore
    }
}

** Combine All Blocks for Each x Value **

di as text _n "Combining results across all blocks..."

foreach x in $rules {
    clear

    * Append all block results
    local file_count = 0
    foreach block_num of local blocks {
        cap confirm file `matches_x`x'_block`block_num''
        if _rc == 0 {
            qui append using `matches_x`x'_block`block_num''
            local ++file_count
        }
    }

    * Check for duplicates across blocks
    if _N > 0 {
        gisid Ahistid Bhistid, missok
        if _rc {
            di as error "WARNING: Duplicate matches found across blocks for x=`x'"
            di as error "Removing duplicates..."
            gegen tag = tag(Ahistid Bhistid)
            qui keep if tag == 1
            drop tag
        }

        * Verify one-to-one matching
		bysort Ahistid: gen count_A = _N
		bysort Bhistid: gen count_B = _N

        *gegen count_A = count(Ahistid), by(Ahistid)
        *gegen count_B = count(Bhistid), by(Bhistid)
        
		qui sum count_A
        assert r(max) == 1
        qui sum count_B
        assert r(max) == 1
        drop count_A count_B
    }

    * Save final matched dataset
    qui compress
    qui summ age_diff
    local n_matches = r(N)

    save "$output_dir\JW_matches_x`x'.dta", replace

    di as text _n "Results for x = `x':"
    di as text "  Matches found: " as result %12.0fc `n_matches'
    di as text "  File saved:    " as result "$output_dir\JW_matches_x`x'.dta"
}

/*

** Summary Statistics **

di as text _n "{hline 70}"
di as text "Stage 3: Decision Rules Complete"
di as text "{hline 70}"

foreach x in $rules {
    use "$output_dir\JW_matches_x`x'.dta", clear
    qui count
    local n = r(N)

    qui sum age_diff, detail
    local age_mean = r(mean)
    local age_p50 = r(p50)
    local age_max = r(max)

    qui sum jw_f_name_cleaned, detail
    local jw_f_mean = r(mean)
    local jw_f_p50 = r(p50)

    qui sum jw_l_name_cleaned, detail
    local jw_l_mean = r(mean)
    local jw_l_p50 = r(p50)

    di as text _n "x = `x' (Conservative level: " as result ///
        cond(`x'==0, "Lower", "Higher") as text "):"
    di as text "  Total matches:        " as result %12.0fc `n'
    di as text "  Age diff (mean/med):  " as result %4.2f `age_mean' ///
        as text " / " as result %4.2f `age_p50'
    di as text "  Age diff (max):       " as result %4.0f `age_max'
    di as text "  JW first (mean/med):  " as result %5.3f `jw_f_mean' ///
        as text " / " as result %5.3f `jw_f_p50'
    di as text "  JW last (mean/med):   " as result %5.3f `jw_l_mean' ///
        as text " / " as result %5.3f `jw_l_p50'
}

di as text _n "{hline 70}"
di as text "Next step: Stage 4 - Within-dataset uniqueness checks"
di as text "{hline 70}"
