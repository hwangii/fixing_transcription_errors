/*------------------------------------------------------------------------------
Full Census Match: Loop Over BPL Values (New Transcription)

Purpose: Run the full matching pipeline (Stages 2-4) independently for each
bpl value, then append results into final match files.

Since bpl is a blocking variable, matching never crosses bpl boundaries.
Each bpl can be processed independently with identical results.

Features:
- Resume: skips bpl values that already have final output files
- Per-bpl timing and progress logging
- Cleanup: removes intermediate block files after each bpl
- Appends all per-bpl results at the end

Prerequisites:
- Run run_full_census_prep_new_transcription.do first
- data/by_bpl_new_transcription/bpl_list.dta must exist
- data/by_bpl_new_transcription/bpl_{X}/clean_names_{1930,1940}.dta must exist

Outputs (per bpl):
- data/by_bpl_new_transcription/bpl_{X}/JW_matches_x{0,2}.dta
- data/by_bpl_new_transcription/bpl_{X}/JW_matches_x{0,2}_unique.dta

Outputs (combined):
- data/matched_new_transcription/JW_matches_x{0,2}.dta
- data/matched_new_transcription/JW_matches_x{0,2}_unique.dta
------------------------------------------------------------------------------*/

drop _all
clear all
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
do "$ROOT/code/shared/paths.do"

cd "$ABEJW"

** Configuration **

local clusters = 12         // Parallel clusters
local processors = 2        // Processors per cluster
local max_pairs = 5000000   // Max pairs before block splitting
local batch_threshold = 200000  // Blocks smaller than this get merged
local batch_size = 2000000  // Target pairs per merged group
local max_age_diff = 2      // Max age difference for final matches
local cleanup = 1           // 1 = delete block files after each bpl

** Load pairing command **

do "$C_ABEJW/ado/pairing_chunked_gtools.ado"

** Load BPL List **

use "data\by_bpl_new_transcription\bpl_list.dta", clear
sort bpl
qui levelsof bpl, local(bpl_values) clean
local n_bpl : word count `bpl_values'

di as text _n "{hline 70}"
di as text "Full Census Matching (New Transcription): `n_bpl' bpl values to process"
di as text "{hline 70}"

** Main Loop: Process Each BPL **

local n_done = 0
local n_skipped = 0

foreach b of local bpl_values {

    ** Resume Check **
    cap confirm file "data\by_bpl_new_transcription\bpl_`b'\JW_matches_x2_unique.dta"
    if _rc == 0 {
        local ++n_skipped
        continue
    }

    local ++n_done
    local elapsed_bpl = `n_done' + `n_skipped'

    di as text _n(2) "{hline 70}"
    di as text "BPL `b' (`elapsed_bpl'/`n_bpl')"
    di as text "{hline 70}"

    timer clear 99
    timer on 99

    * Verify input files exist
    cap confirm file "data\by_bpl_new_transcription\bpl_`b'\clean_names_1930.dta"
    if _rc {
        di as error "  Missing clean_names_1930 for bpl `b', skipping"
        continue
    }
    cap confirm file "data\by_bpl_new_transcription\bpl_`b'\clean_names_1940.dta"
    if _rc {
        di as error "  Missing clean_names_1940 for bpl `b', skipping"
        continue
    }

    /*==================================================================
    Stage 2: Generate Candidate Pairs
    ==================================================================*/

    global timediff = 10
    global age_band = 2

    * Check if pairing already completed (candidate_pairs.dta exists)
    cap confirm file "data\by_bpl_new_transcription\bpl_`b'\candidate_pairs.dta"
    if _rc {
        * Check if partially completed (Block_key.dta exists = can resume)
        cap confirm file "data\by_bpl_new_transcription\bpl_`b'\BlocksAtoB\Block_key.dta"
        if _rc == 0 {
            di as text _n "  Stage 2: Resuming pairing from partial run..."
            pairing_chunked_gtools, ///
                afile("data\by_bpl_new_transcription\bpl_`b'\clean_names_1930.dta") ///
                bfile("data\by_bpl_new_transcription\bpl_`b'\clean_names_1940.dta") ///
                id_vars(histid) id_type(string) ///
                blocking_vars(bpl first_initial last_initial race) ///
                clean_pairs("$C_ABEJW/ado/filtering.do") ///
                distances(jw_f_name_cleaned jw_l_name_cleaned age_diff) ///
                clusters(`clusters') processors(`processors') ///
                max_pairs(`max_pairs') ///
                batch_threshold(`batch_threshold') batch_size(`batch_size') ///
                batch_small_blocks ///
                output("data\by_bpl_new_transcription\bpl_`b'\candidate_pairs") ///
                save_blocks block_dir("data\by_bpl_new_transcription\bpl_`b'\BlocksAtoB") ///
                resume
        }
        else {
            di as text _n "  Stage 2: Generating candidate pairs..."
            cap mkdir "data\by_bpl_new_transcription\bpl_`b'\BlocksAtoB"
            pairing_chunked_gtools, ///
                afile("data\by_bpl_new_transcription\bpl_`b'\clean_names_1930.dta") ///
                bfile("data\by_bpl_new_transcription\bpl_`b'\clean_names_1940.dta") ///
                id_vars(histid) id_type(string) ///
                blocking_vars(bpl first_initial last_initial race) ///
                clean_pairs("$C_ABEJW/ado/filtering.do") ///
                distances(jw_f_name_cleaned jw_l_name_cleaned age_diff) ///
                clusters(`clusters') processors(`processors') ///
                max_pairs(`max_pairs') ///
                batch_threshold(`batch_threshold') batch_size(`batch_size') ///
                batch_small_blocks ///
                output("data\by_bpl_new_transcription\bpl_`b'\candidate_pairs") ///
                save_blocks block_dir("data\by_bpl_new_transcription\bpl_`b'\BlocksAtoB")
        }
    }
    else {
        di as text _n "  Stage 2: Candidate pairs already exist, skipping..."
    }

    cd "$ABEJW"

    * Check for empty results
    use "data\by_bpl_new_transcription\bpl_`b'\candidate_pairs.dta", clear
    qui count
    local n_pairs = r(N)
    di as text "  Candidate pairs: " as result %12.0fc `n_pairs'

    if `n_pairs' == 0 {
        * No pairs - create empty match files and skip
        foreach x in 0 2 {
            clear
            gen str histid = ""
            rename histid Ahistid
            gen str Bhistid = ""
            gen float age_diff = .
            gen float jw_f_name_cleaned = .
            gen float jw_l_name_cleaned = .
            qui save "data\by_bpl_new_transcription\bpl_`b'\JW_matches_x`x'.dta", replace
            qui save "data\by_bpl_new_transcription\bpl_`b'\JW_matches_x`x'_unique.dta", replace
        }
        di as text "  No candidate pairs, skipping stages 3-4"
        timer off 99
        qui timer list 99
        di as text "  Completed bpl `b' in " as result %6.1f `r(t99)' as text " seconds"
        continue
    }

    /*==================================================================
    Stage 3: Apply Decision Rules
    ==================================================================*/

    * Check if Stage 3 already completed (need BOTH x0 and x2)
    cap confirm file "data\by_bpl_new_transcription\bpl_`b'\JW_matches_x0.dta"
    local x0_exists = (_rc == 0)
    cap confirm file "data\by_bpl_new_transcription\bpl_`b'\JW_matches_x2.dta"
    local x2_exists = (_rc == 0)
    local stage3_done = `x0_exists' & `x2_exists'

    if !`stage3_done' {
        di as text "  Stage 3: Applying decision rules..."

        * Calculate global minimum age distances
        gegen float min_age_A = min(age_diff), by(Ahistid)
        gegen float min_age_B = min(age_diff), by(Bhistid)

        gen float diff_A = age_diff - min_age_A
        gen float diff_B = age_diff - min_age_B

        * Apply rules for each x value
        foreach x in 0 2 {
            * Potential match: within x years of best match for BOTH sides
            gen byte pot`x' = (diff_A <= `x') & (diff_B <= `x')
            gegen long nA`x' = total(pot`x'), by(Ahistid)
            gegen long nB`x' = total(pot`x'), by(Bhistid)

            * Unique bidirectional match within max_age_diff
            gen byte match`x' = (pot`x' == 1) & (nA`x' == 1) & (nB`x' == 1) & ///
                                 (age_diff <= `max_age_diff')
        }

        * Save matches for each x
        foreach x in 0 2 {
            preserve
            qui keep if match`x' == 1
            keep Ahistid Bhistid age_diff jw_f_name_cleaned jw_l_name_cleaned
            qui count
            local n_x`x' = r(N)
            qui compress
            qui save "data\by_bpl_new_transcription\bpl_`b'\JW_matches_x`x'.dta", replace
            restore
        }

        di as text "  Matches: x=0 = " as result %8.0fc `n_x0' ///
            as text ", x=2 = " as result %8.0fc `n_x2'
    }
    else {
        di as text "  Stage 3: Match files already exist, skipping..."
        use "data\by_bpl_new_transcription\bpl_`b'\JW_matches_x0.dta", clear
        qui count
        local n_x0 = r(N)
        use "data\by_bpl_new_transcription\bpl_`b'\JW_matches_x2.dta", clear
        qui count
        local n_x2 = r(N)
        di as text "  Matches: x=0 = " as result %8.0fc `n_x0' ///
            as text ", x=2 = " as result %8.0fc `n_x2'
    }

    clear

    * Skip Stage 4 if no matches
    if `n_x0' == 0 {
        foreach x in 0 2 {
            use "data\by_bpl_new_transcription\bpl_`b'\JW_matches_x`x'.dta", clear
            qui save "data\by_bpl_new_transcription\bpl_`b'\JW_matches_x`x'_unique.dta", replace
        }
        di as text "  No matches, skipping Stage 4"

        if `cleanup' {
            cap shell rmdir "data\by_bpl_new_transcription\bpl_`b'\BlocksAtoB" /s /q
            cap erase "data\by_bpl_new_transcription\bpl_`b'\candidate_pairs.dta"
        }

        timer off 99
        qui timer list 99
        di as text "  Completed in " as result %6.1f `r(t99)' as text " seconds"
        continue
    }

    /*==================================================================
    Stage 4: Within-Dataset Uniqueness
    ==================================================================*/

    di as text "  Stage 4: Within-dataset uniqueness checks..."

    ** 4a: Prepare matched individual files **

    * 1930 matched individuals
    use "data\by_bpl_new_transcription\bpl_`b'\JW_matches_x0.dta", clear
    keep Ahistid
    rename Ahistid histid
    tempfile m_ids_1930
    qui save `m_ids_1930'

    use "data\by_bpl_new_transcription\bpl_`b'\clean_names_1930.dta", clear
    qui merge 1:1 histid using `m_ids_1930', keep(3) nogen
    local matched_1930_file = "data\by_bpl_new_transcription\bpl_`b'\__matched_1930.dta"
    qui save "`matched_1930_file'"

    * 1940 matched individuals
    use "data\by_bpl_new_transcription\bpl_`b'\JW_matches_x0.dta", clear
    keep Bhistid
    rename Bhistid histid
    tempfile m_ids_1940
    qui save `m_ids_1940'

    use "data\by_bpl_new_transcription\bpl_`b'\clean_names_1940.dta", clear
    qui merge 1:1 histid using `m_ids_1940', keep(3) nogen
    local matched_1940_file = "data\by_bpl_new_transcription\bpl_`b'\__matched_1940.dta"
    qui save "`matched_1940_file'"

    ** 4b: AtoA Pairing (within 1930) **

    global timediff = 0
    global age_band = 2

    cap shell rmdir "data\by_bpl_new_transcription\bpl_`b'\BlocksAtoA" /s /q
    cap mkdir "data\by_bpl_new_transcription\bpl_`b'\BlocksAtoA"

    pairing_chunked_gtools, ///
        afile("`matched_1930_file'") ///
        bfile("data\by_bpl_new_transcription\bpl_`b'\clean_names_1930.dta") ///
        id_vars(histid) id_type(string) ///
        blocking_vars(bpl first_initial last_initial race) ///
        clean_pairs("$C_ABEJW/ado/filtering.do") ///
        distances(jw_f_name_cleaned jw_l_name_cleaned age_diff) ///
        clusters(`clusters') processors(`processors') ///
        max_pairs(`max_pairs') ///
        batch_threshold(`batch_threshold') batch_size(`batch_size') ///
        batch_small_blocks ///
        output("data\by_bpl_new_transcription\bpl_`b'\within_1930_pairs")

    cd "$ABEJW"

    * Create uniqueness indicators for 1930
    use "data\by_bpl_new_transcription\bpl_`b'\within_1930_pairs.dta", clear
    qui drop if Ahistid == Bhistid

    if _N > 0 {
        foreach band in 0 2 {
            gen byte sim_`band' = (age_diff <= `band')
            gegen long n_sim_`band' = total(sim_`band'), by(Ahistid)
            gen byte unique_`band'_A = (n_sim_`band' == 0)
            drop sim_`band' n_sim_`band'
        }
        gcollapse (min) unique_*_A, by(Ahistid)
        rename Ahistid histid
    }
    else {
        clear
        gen str histid = ""
        gen byte unique_0_A = .
        gen byte unique_2_A = .
    }
    tempfile uniq_1930
    qui save `uniq_1930'

    ** 4c: BtoB Pairing (within 1940) **

    cap shell rmdir "data\by_bpl_new_transcription\bpl_`b'\BlocksBtoB" /s /q
    cap mkdir "data\by_bpl_new_transcription\bpl_`b'\BlocksBtoB"

    pairing_chunked_gtools, ///
        afile("`matched_1940_file'") ///
        bfile("data\by_bpl_new_transcription\bpl_`b'\clean_names_1940.dta") ///
        id_vars(histid) id_type(string) ///
        blocking_vars(bpl first_initial last_initial race) ///
        clean_pairs("$C_ABEJW/ado/filtering.do") ///
        distances(jw_f_name_cleaned jw_l_name_cleaned age_diff) ///
        clusters(`clusters') processors(`processors') ///
        max_pairs(`max_pairs') ///
        batch_threshold(`batch_threshold') batch_size(`batch_size') ///
        batch_small_blocks ///
        output("data\by_bpl_new_transcription\bpl_`b'\within_1940_pairs")

    cd "$ABEJW"

    * Create uniqueness indicators for 1940
    use "data\by_bpl_new_transcription\bpl_`b'\within_1940_pairs.dta", clear
    qui drop if Ahistid == Bhistid

    if _N > 0 {
        foreach band in 0 2 {
            gen byte sim_`band' = (age_diff <= `band')
            gegen long n_sim_`band' = total(sim_`band'), by(Ahistid)
            gen byte unique_`band'_B = (n_sim_`band' == 0)
            drop sim_`band' n_sim_`band'
        }
        gcollapse (min) unique_*_B, by(Ahistid)
        rename Ahistid histid
    }
    else {
        clear
        gen str histid = ""
        gen byte unique_0_B = .
        gen byte unique_2_B = .
    }
    tempfile uniq_1940
    qui save `uniq_1940'

    ** 4d: Apply uniqueness to matched files **

    foreach x in 0 2 {
        use "data\by_bpl_new_transcription\bpl_`b'\JW_matches_x`x'.dta", clear

        * Merge 1930 uniqueness
        rename Ahistid histid
        qui merge m:1 histid using `uniq_1930', keep(1 3) nogen
        foreach band in 0 2 {
            replace unique_`band'_A = 1 if unique_`band'_A == .
        }
        rename histid Ahistid

        * Merge 1940 uniqueness
        rename Bhistid histid
        qui merge m:1 histid using `uniq_1940', keep(1 3) nogen
        foreach band in 0 2 {
            replace unique_`band'_B = 1 if unique_`band'_B == .
        }
        rename histid Bhistid

        * Apply uniqueness filter
        if `x' == 0 {
            keep if (unique_0_A == 1 & unique_0_B == 1)
        }
        else {
            keep if (unique_2_A == 1 & unique_2_B == 1)
        }

        keep Ahistid Bhistid age_diff jw_f_name_cleaned jw_l_name_cleaned
        qui count
        local n_uniq_x`x' = r(N)

        qui compress
        qui save "data\by_bpl_new_transcription\bpl_`b'\JW_matches_x`x'_unique.dta", replace
    }

    di as text "  Unique matches: x=0 = " as result %8.0fc `n_uniq_x0' ///
        as text ", x=2 = " as result %8.0fc `n_uniq_x2'

    /*==================================================================
    Cleanup and Progress
    ==================================================================*/

    if `cleanup' {
        cap shell rmdir "data\by_bpl_new_transcription\bpl_`b'\BlocksAtoB" /s /q
        cap shell rmdir "data\by_bpl_new_transcription\bpl_`b'\BlocksAtoA" /s /q
        cap shell rmdir "data\by_bpl_new_transcription\bpl_`b'\BlocksBtoB" /s /q
        cap erase "data\by_bpl_new_transcription\bpl_`b'\candidate_pairs.dta"
        cap erase "data\by_bpl_new_transcription\bpl_`b'\within_1930_pairs.dta"
        cap erase "data\by_bpl_new_transcription\bpl_`b'\within_1940_pairs.dta"
        cap erase "`matched_1930_file'"
        cap erase "`matched_1940_file'"
    }

    timer off 99
    qui timer list 99
    di as text "  Completed bpl `b' in " as result %6.1f `r(t99)' as text " seconds"
}

di as text _n "Processed `n_done' bpl values, skipped `n_skipped' (already done)"

/*======================================================================
Append All BPL Results Into Final Files
======================================================================*/

di as text _n(2) "{hline 70}"
di as text "Appending per-bpl results..."
di as text "{hline 70}"

cap mkdir "data\matched_new_transcription"

foreach suffix in "x0" "x2" "x0_unique" "x2_unique" {
    clear

    foreach b of local bpl_values {
        cap confirm file "data\by_bpl_new_transcription\bpl_`b'\JW_matches_`suffix'.dta"
        if _rc == 0 {
            qui append using "data\by_bpl_new_transcription\bpl_`b'\JW_matches_`suffix'.dta"
        }
    }

    qui count
    local n = r(N)

    if `n' > 0 {
        qui compress
        qui save "data\matched_new_transcription\JW_matches_`suffix'.dta", replace
    }

    di as text "  JW_matches_`suffix': " as result %12.0fc `n' as text " matches"
}

** Summary **

di as text _n "{hline 70}"
di as text "Full Census Matching (New Transcription) Complete"
di as text "{hline 70}"

use "data\by_bpl_new_transcription\bpl_list.dta", clear
qui sum n_1930
local pop = r(sum)

foreach x in 0 2 {
    cap confirm file "data\matched_new_transcription\JW_matches_x`x'_unique.dta"
    if _rc == 0 {
        use "data\matched_new_transcription\JW_matches_x`x'_unique.dta", clear
        qui count
        local n = r(N)
        local rate = 100 * `n' / `pop'
        di as text "  x=`x' unique matches: " as result %12.0fc `n' ///
            as text " (rate: " as result %5.2f `rate' as text "%)"
    }
}

di as text "{hline 70}"