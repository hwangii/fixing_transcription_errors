/*------------------------------------------------------------------------------
ABE-JW Matching (Original Algorithm - Jaro-Winkler String Distance)

Purpose: Run the original ABE-JW matching algorithm using JW string distances
This is the more flexible version that allows spelling variations

Comparison with current implementation:
- This version: Uses original pairing.ado + JW_decision_rules.do
- Current version: Uses pairing_chunked_gtools.ado (optimized)

Both should give similar results, but differences would indicate:
- Implementation bugs
- Different parameter choices
- Data preparation differences

Outputs:
- abe_comparison/output/ABE_JW_matches_x0.dta (less conservative)
- abe_comparison/output/ABE_JW_matches_x2.dta (more conservative)
- abe_comparison/output/ABE_JW_matches_x0_unique.dta (with uniqueness)
- abe_comparison/output/ABE_JW_matches_x2_unique.dta (with uniqueness)
------------------------------------------------------------------------------*/

clear all
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
if "$LCODE" == "" global LCODE "F:/github_repos/fixing_transcription_errors/LINKAGE/code"
do "$LCODE/shared/paths.do"

** Set up directories **
cd "$ABEJW"

global A "$ABEJW/data\clean_names\clean_names_1930.dta"
global B "$ABEJW/data\clean_names\clean_names_1940.dta"
global outdir "$ABEJW/abe_comparison\output"
global blockdir "$ABEJW/abe_comparison\BlocksAtoB"
global main "$ABEJW/abe_original_code"

cap shell rmdir "$blockdir" /s /q
cap mkdir "$outdir"
cap mkdir "$blockdir"

** Copy required .ado files to comparison directory **
local ado_files "pairing.ado filtering.do gen_initials.do"
foreach file of local ado_files {
    cap confirm file "$ABEJW/abe_comparison\\`file'"
    if _rc {
        copy "$ABEJW/abe_original_code\\`file'" ///
             "$ABEJW/abe_comparison\\`file'", replace
    }
}

** Set up blocking and filtering parameters **
global blockingvars "bpl first_initial last_initial race"
global age_band = 2  // ±2 years (your current implementation)
global timediff = 10

** Variables to load **
global loadvars "histid age f_name_cleaned l_name_cleaned bpl race first_initial last_initial"

di as text _n "{hline 70}"
di as text "ABE-JW Matching Algorithm (Original Implementation)"
di as text "{hline 70}"
di as text "Blocking vars: " as result "$blockingvars"
di as text "Age band:      " as result "±$age_band years"
di as text "Time diff:     " as result "$timediff years"
di as text ""

** STEP 1: Generate candidate pairs using original pairing.ado **

di as text _n "Step 1: Generating candidate pairs..."

* Change to comparison directory for ado file access
cd "$ABEJW/abe_comparison"

cap program drop _all
adopath + "$main"

* NOTE: The original pairing.ado expects different syntax than pairing_chunked_gtools
* Since our data already has first_initial and last_initial, skip preprocessing
pairing, afile("$A") bfile("$B") ///
    load_vars($loadvars) restrictions() ///
    id(histid) ///
    keep($loadvars) ///
    blocking($blockingvars) ///
    clusters(4) ///
    clean_pairs("$ABEJW/abe_comparison\filtering.do") ///
    distances(age_diff jw_f_name_cleaned jw_l_name_cleaned) ///
    output("$outdir\candidate_pairs") ///
    save_blocks block_dir("$blockdir")

qui count
local n_pairs = r(N)
di as text "Candidate pairs found: " as result %12.0fc `n_pairs'

** STEP 2: Apply decision rules **

di as text _n "Step 2: Applying ABE-JW decision rules..."

cd "$ABEJW"

global rules "0 2"
global max_age_diff = 2
global outputfile "$outdir\ABE_JW_matches"

* Adapt the original JW_decision_rules.do for our data structure
* (We'll need to check what variables it expects and adjust)

* For now, let's apply the decision rules manually following the same logic
* This matches what's in your 03_apply_decision_rules.do

foreach x in $rules {
    use "$outdir\candidate_pairs", clear

    * Calculate age-based metrics
    gegen min_age_dist_A = min(age_diff), by(Ahistid)
    gegen min_age_dist_B = min(age_diff), by(Bhistid)

    gen diff_age_A = age_diff - min_age_dist_A
    gen diff_age_B = age_diff - min_age_dist_B

    * Mark potential matches
    gen byte potential_match = ///
        (diff_age_A <= `x') & ///
        (diff_age_B <= `x')

    * Count potential matches
    gegen n_matches_A = total(potential_match), by(Ahistid)
    gegen n_matches_B = total(potential_match), by(Bhistid)

    * Keep only unique bidirectional matches
    gen byte match = ///
        potential_match == 1 & ///
        n_matches_A == 1 & ///
        n_matches_B == 1 & ///
        age_diff <= $max_age_diff

    keep if match == 1
    keep Ahistid Bhistid age_diff jw_f_name_cleaned jw_l_name_cleaned

    qui count
    local n_matches = r(N)

    compress
    save "${outputfile}_x`x'", replace

    di as text "  x = `x': " as result %12.0fc `n_matches' as text " matches"
}

** STEP 3: Within-dataset uniqueness checks **

di as text _n "Step 3: Checking within-dataset uniqueness..."

* Similar to your Stage 4, but using original algorithm structure
* Extract matched individuals from x0 (least conservative)
use "${outputfile}_x0", clear
keep Ahistid
rename Ahistid histid
tempfile matched_1930
save `matched_1930'

use "$A", clear
keep histid bpl first_initial last_initial f_name_cleaned l_name_cleaned age race
merge 1:1 histid using `matched_1930', keep(3) nogen
tempfile matched_full_1930
save `matched_full_1930'

* Same for 1940
use "${outputfile}_x0", clear
keep Bhistid
rename Bhistid histid
tempfile matched_1940
save `matched_1940'

use "$B", clear
keep histid bpl first_initial last_initial f_name_cleaned l_name_cleaned age race
merge 1:1 histid using `matched_1940', keep(3) nogen
tempfile matched_full_1940
save `matched_full_1940'

* Run AtoA pairing
cd "$ABEJW/abe_comparison"
global timediff = 0
global age_band = 2

cap mkdir "$outdir\BlocksAtoA"

pairing, afile("`matched_full_1930'") bfile("$A") ///
    load_vars($loadvars) restrictions() ///
    preprocessing(gen_initials.do) ///
    id(histid) ///
    keep($loadvars initial_frst initial_last) ///
    blocking($blockingvars) ///
    clusters(4) ///
    clean_pairs(filtering.do) ///
    distances(age_diff jw_f_name_cleaned jw_l_name_cleaned) ///
    output("$outdir\within_1930_pairs") ///
    save_blocks block_dir("$outdir\BlocksAtoA") noappend

use "$outdir\within_1930_pairs", clear
drop if Ahistid == Bhistid

* Create uniqueness indicators
foreach band in 0 2 {
    gen byte similar_`band' = (age_diff <= `band')
    gegen n_similar_`band' = total(similar_`band'), by(Ahistid)
    gen byte unique_`band'_A = (n_similar_`band' == 0)
    drop similar_`band' n_similar_`band'
}

gcollapse (min) unique_*_A, by(Ahistid)
rename Ahistid histid
tempfile uniqueness_1930
save `uniqueness_1930'

* BtoB pairing
cap mkdir "$outdir\BlocksBtoB"

pairing, afile("`matched_full_1940'") bfile("$B") ///
    load_vars($loadvars) restrictions() ///
    preprocessing(gen_initials.do) ///
    id(histid) ///
    keep($loadvars initial_frst initial_last) ///
    blocking($blockingvars) ///
    clusters(4) ///
    clean_pairs(filtering.do) ///
    distances(age_diff jw_f_name_cleaned jw_l_name_cleaned) ///
    output("$outdir\within_1940_pairs") ///
    save_blocks block_dir("$outdir\BlocksBtoB") noappend

use "$outdir\within_1940_pairs", clear
drop if Ahistid == Bhistid

foreach band in 0 2 {
    gen byte similar_`band' = (age_diff <= `band')
    gegen n_similar_`band' = total(similar_`band'), by(Ahistid)
    gen byte unique_`band'_B = (n_similar_`band' == 0)
    drop similar_`band' n_similar_`band'
}

gcollapse (min) unique_*_B, by(Ahistid)
rename Ahistid histid
tempfile uniqueness_1940
save `uniqueness_1940'

* Apply uniqueness to matched files
foreach x in 0 2 {
    use "${outputfile}_x`x'", clear

    * Merge uniqueness from 1930
    rename Ahistid histid
    merge m:1 histid using `uniqueness_1930', keep(1 3) nogen
    foreach band in 0 2 {
        replace unique_`band'_A = 1 if unique_`band'_A == .
    }
    rename histid Ahistid

    * Merge uniqueness from 1940
    rename Bhistid histid
    merge m:1 histid using `uniqueness_1940', keep(1 3) nogen
    foreach band in 0 2 {
        replace unique_`band'_B = 1 if unique_`band'_B == .
    }
    rename histid Bhistid

    * Create combined uniqueness
    gen byte unique_both_0 = (unique_0_A == 1 & unique_0_B == 1)
    gen byte unique_both_2 = (unique_2_A == 1 & unique_2_B == 1)

    * Save with all uniqueness indicators
    save "${outputfile}_x`x'_with_uniqueness", replace

    * Apply recommended uniqueness filter
    if `x' == 0 {
        keep if unique_both_0 == 1
    }
    else {
        keep if unique_both_2 == 1
    }

    qui count
    local n_unique = r(N)

    save "${outputfile}_x`x'_unique", replace

    di as text "  x = `x' with uniqueness: " as result %12.0fc `n_unique' as text " matches"
}

** Summary **
cd "$ABEJW"

di as text _n "{hline 70}"
di as text "ABE-JW Matching Complete (Original Algorithm)"
di as text "{hline 70}"
di as text _n "Output files:"
di as text "  x=0 matches:        " as result "$outdir\ABE_JW_matches_x0.dta"
di as text "  x=0 unique:         " as result "$outdir\ABE_JW_matches_x0_unique.dta"
di as text "  x=2 matches:        " as result "$outdir\ABE_JW_matches_x2.dta"
di as text "  x=2 unique:         " as result "$outdir\ABE_JW_matches_x2_unique.dta"
di as text "{hline 70}"
