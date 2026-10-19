/*------------------------------------------------------------------------------
Stage 4: Within-Dataset Uniqueness Checks

Purpose: Check if matched individuals have near-duplicates within their own dataset
- For each matched person in 1930, find similar people in 1930 (AtoA)
- For each matched person in 1940, find similar people in 1940 (BtoB)
- Create uniqueness indicators for 0-year and 2-year age bands
- Filter matches based on uniqueness requirements

Why needed: JW distances are non-transitive - a matched person might be similar
to an unmatched person within their own dataset, making the match less reliable.

Outputs:
- data/matched/JW_matches_x0_unique.dta (with uniqueness filters)
- data/matched/JW_matches_x2_unique.dta (with uniqueness filters)
------------------------------------------------------------------------------*/

drop _all
clear all
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
if "$LCODE" == "" global LCODE "F:/github_repos/fixing_transcription_errors/LINKAGE/code"
do "$LCODE/shared/paths.do"

cd "$ABEJW"

** Load pairing command **

do "$C_ABEJW/ado/pairing_chunked_gtools.ado"

** Define Parameters **

global matched_dir "data\matched"
global clean_dir "data\clean_names"
global output_dir "data\matched"
global yr_bands "0 2"  // Age bands to check uniqueness within

cap mkdir "$output_dir"

/*==============================================================================
Step 1: Prepare Matched Individual Files (from x0 - least conservative sample)
==============================================================================*/

di as text _n "{hline 70}"
di as text "Preparing matched individual files..."
di as text "{hline 70}"

** Dataset A (1930): Extract matched individuals **

use "$matched_dir\JW_matches_x0.dta", clear
keep Ahistid
rename Ahistid histid
tempfile matched_ids_1930
save `matched_ids_1930'

** Merge to get full records from clean_names_1930 **

use "$clean_dir\clean_names_1930.dta", clear
keep histid bpl first_initial last_initial f_name_cleaned l_name_cleaned age race

merge 1:1 histid using `matched_ids_1930', keep(3) nogen
	
qui count
local n_matched_1930 = r(N)
di as text "Matched individuals in 1930: " as result %12.0fc `n_matched_1930'

tempfile matched_full_1930
save `matched_full_1930'

** Dataset B (1940): Extract matched individuals **

use "$matched_dir\JW_matches_x0.dta", clear
keep Bhistid
rename Bhistid histid
tempfile matched_ids_1940
save `matched_ids_1940'

** Merge to get full records from clean_names_1940 **

use "$clean_dir\clean_names_1940.dta", clear
keep histid bpl first_initial last_initial f_name_cleaned l_name_cleaned age race

merge 1:1 histid using `matched_ids_1940', keep(3) nogen
		
qui count
local n_matched_1940 = r(N)
di as text "Matched individuals in 1940: " as result %12.0fc `n_matched_1940'

tempfile matched_full_1940
save `matched_full_1940'

/*==============================================================================
Step 2: AtoA Pairing - Find Within-Dataset Similarities in 1930
==============================================================================*/

di as text _n "{hline 70}"
di as text "Step 2: AtoA - Finding within-dataset similarities in 1930..."
di as text "{hline 70}"

global timediff = 0    // Same year!
global age_band = 2    // Within ±2 years

cap mkdir "data\BlocksAtoA"

pairing_chunked_gtools, ///
    afile("`matched_full_1930'") ///
    bfile("$clean_dir\clean_names_1930.dta") ///
    id_vars(histid) ///
    id_type(string) ///
    blocking_vars(bpl first_initial last_initial race) ///
    clean_pairs("$C_ABEJW/ado/filtering.do") ///
    distances(jw_f_name_cleaned jw_l_name_cleaned age_diff) ///
    clusters(12) ///
    processors(2) ///
    max_pairs(1000000) ///
    batch_threshold(200000) ///
    batch_size(2000000) ///
    output("data\within_1930_pairs.dta") ///
    save_blocks block_dir("data\BlocksAtoA")

** Exclude self-matches **

use "data\within_1930_pairs.dta", clear
drop if Ahistid == Bhistid  // Person matched to themselves

qui count
local n_pairs_1930 = r(N)
di as text "AtoA pairs (excluding self-matches): " as result %12.0fc `n_pairs_1930'

tempfile ata_pairs
save `ata_pairs'

/*==============================================================================
Step 3: BtoB Pairing - Find Within-Dataset Similarities in 1940
==============================================================================*/

di as text _n "{hline 70}"
di as text "Step 3: BtoB - Finding within-dataset similarities in 1940..."
di as text "{hline 70}"

cap mkdir "data\BlocksBtoB"

pairing_chunked_gtools, ///
    afile("`matched_full_1940'") ///
    bfile("$clean_dir\clean_names_1940.dta") ///
    id_vars(histid) ///
    id_type(string) ///
    blocking_vars(bpl first_initial last_initial race) ///
    clean_pairs("$C_ABEJW/ado/filtering.do") ///
    distances(jw_f_name_cleaned jw_l_name_cleaned age_diff) ///
    clusters(12) ///
    processors(2) ///
    max_pairs(1000000) ///
    batch_threshold(200000) ///
    batch_size(2000000) ///
    output("data\within_1940_pairs.dta") ///
    save_blocks block_dir("data\BlocksBtoB")

** Exclude self-matches **

use "data\within_1940_pairs.dta", clear
drop if Ahistid == Bhistid  // Person matched to themselves

qui count
local n_pairs_1940 = r(N)
di as text "BtoB pairs (excluding self-matches): " as result %12.0fc `n_pairs_1940'

tempfile btb_pairs
save `btb_pairs'

/*==============================================================================
Step 4: Create Uniqueness Indicators
==============================================================================*/

di as text _n "{hline 70}"
di as text "Step 4: Creating uniqueness indicators..."
di as text "{hline 70}"

** For Dataset A (1930) **

use `ata_pairs', clear

foreach band in $yr_bands {
    di as text "  Creating uniqueness indicator for A (1930), age band = `band'"

    * Count similar people within age band
    gen byte similar_within_`band' = (age_diff <= `band')
    gegen n_similar_`band' = total(similar_within_`band'), by(Ahistid)

    * Person is unique if no similar people found (n_similar == 0)
    gen byte unique_within_`band'_yr_band_A = (n_similar_`band' == 0)

    drop similar_within_`band' n_similar_`band'
}

* Keep one row per matched individual with uniqueness indicators
gcollapse (min) unique_within_*_yr_band_A, by(Ahistid)

rename Ahistid histid
tempfile uniqueness_1930
save `uniqueness_1930'

qui count
local n_unique_1930 = r(N)
di as text "Uniqueness indicators for 1930: " as result %12.0fc `n_unique_1930' as text " individuals"

** For Dataset B (1940) **

use `btb_pairs', clear

foreach band in $yr_bands {
    di as text "  Creating uniqueness indicator for B (1940), age band = `band'"

    * Count similar people within age band
    gen byte similar_within_`band' = (age_diff <= `band')
    gegen n_similar_`band' = total(similar_within_`band'), by(Ahistid)

    * Person is unique if no similar people found
    gen byte unique_within_`band'_yr_band_B = (n_similar_`band' == 0)

    drop similar_within_`band' n_similar_`band'
}

* Keep one row per matched individual with uniqueness indicators
gcollapse (min) unique_within_*_yr_band_B, by(Ahistid)

rename Ahistid histid
tempfile uniqueness_1940
save `uniqueness_1940'

qui count
local n_unique_1940 = r(N)
di as text "Uniqueness indicators for 1940: " as result %12.0fc `n_unique_1940' as text " individuals"

/*==============================================================================
Step 5: Handle Individuals with No Similar Pairs (Automatically Unique)
==============================================================================*/

** For 1930: Add missing individuals (those with no similar pairs = unique) **

use `matched_ids_1930', clear
merge 1:1 histid using `uniqueness_1930', nogen

* Fill missing with 1 (unique) - these had no similar pairs at all
foreach band in $yr_bands {
    replace unique_within_`band'_yr_band_A = 1 if unique_within_`band'_yr_band_A == .
}

tempfile uniqueness_1930_complete
save `uniqueness_1930_complete'

** For 1940: Add missing individuals **

use `matched_ids_1940', clear
merge 1:1 histid using `uniqueness_1940', nogen

foreach band in $yr_bands {
    replace unique_within_`band'_yr_band_B = 1 if unique_within_`band'_yr_band_B == .
}

tempfile uniqueness_1940_complete
save `uniqueness_1940_complete'

/*==============================================================================
Step 6: Merge Uniqueness Indicators Back to Matched Datasets
==============================================================================*/

di as text _n "{hline 70}"
di as text "Step 6: Applying uniqueness filters to matched datasets..."
di as text "{hline 70}"

foreach x in 0 2 {
    use "$matched_dir\JW_matches_x`x'.dta", clear

    * Merge 1930 uniqueness
    rename Ahistid histid
    merge m:1 histid using `uniqueness_1930_complete', keep(1 3)
    qui count if _merge == 1
    if r(N) > 0 {
        di as error "WARNING: `r(N)' records in x`x' not found in 1930 uniqueness file"
    }
    drop _merge
    rename histid Ahistid

    * Merge 1940 uniqueness
    rename Bhistid histid
    merge m:1 histid using `uniqueness_1940_complete', keep(1 3)
    qui count if _merge == 1
    if r(N) > 0 {
        di as error "WARNING: `r(N)' records in x`x' not found in 1940 uniqueness file"
    }
    drop _merge
    rename histid Bhistid

    * Create combined uniqueness indicator
    foreach band in $yr_bands {
        gen byte unique_both_`band' = ///
            unique_within_`band'_yr_band_A == 1 & ///
            unique_within_`band'_yr_band_B == 1
    }

    * Save with uniqueness indicators
    compress
    save "$output_dir\JW_matches_x`x'_with_uniqueness.dta", replace

    * Create filtered versions based on recommended uniqueness requirements
    * x=0: typically requires uniqueness within 0-year band
    * x=2: typically requires uniqueness within 2-year band

    if `x' == 0 {
        keep if unique_both_0 == 1
        local unique_band = 0
    }
    else {
        keep if unique_both_2 == 1
        local unique_band = 2
    }

    qui count
    local n_matches = r(N)

    save "$output_dir\JW_matches_x`x'_unique.dta", replace

    di as text _n "Results for x = `x' (with uniqueness filter = `unique_band' years):"
    di as text "  Total matches:   " as result %12.0fc `n_matches'
    di as text "  File saved:      " as result "$output_dir\JW_matches_x`x'_unique.dta"
}

/*==============================================================================
Summary Statistics
==============================================================================*/

di as text _n "{hline 70}"
di as text "Stage 4: Within-Dataset Uniqueness Complete"
di as text "{hline 70}"

di as text _n "Uniqueness Statistics:"

foreach x in 0 2 {
    use "$output_dir\JW_matches_x`x'_with_uniqueness.dta", clear

    qui count
    local total = r(N)

    di as text _n "x = `x':"
    di as text "  Total matches (before uniqueness): " as result %12.0fc `total'

    foreach band in $yr_bands {
        qui count if unique_both_`band' == 1
        local n_unique = r(N)
        local pct = 100 * `n_unique' / `total'

        di as text "  Unique within ±`band' years:        " ///
            as result %12.0fc `n_unique' as text " (" as result %5.1f `pct' as text "%)"
    }
}

di as text _n "{hline 70}"
di as text "Next step: Merge matched data with original census records for analysis"
di as text "{hline 70}"

** Cleanup temporary block directories **

di as text _n "Cleaning up temporary files..."
shell rmdir "data\BlocksAtoA" /s /q
shell rmdir "data\BlocksBtoB" /s /q
cap erase "data\within_1930_pairs.dta"
cap erase "data\within_1940_pairs.dta"

di as text "Done!"
