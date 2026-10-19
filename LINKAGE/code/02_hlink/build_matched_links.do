* ============================================================
* build_matched_links.do
* ============================================================
* Combines the HLINK step-1 and step-2 match CSVs into the two
* files the linkage table reads:
*     data/links/matches_before.dta   (66,807,539 pairs)
*     data/links/matches_after.dta    (68,498,407 pairs)
*
* CONFLICT RULE: step 2 supersedes step 1. A step-1 pair survives
* only if NEITHER of its records appears anywhere in step 2, which
* catches both collision types -- one 1930 record linked to two
* different 1940 records, and two 1930 records linked to the same
* 1940 record.
*
* ------------------------------------------------------------
* PROVENANCE -- READ THIS BEFORE TRUSTING THIS FILE
*
* The original build_matched_links.do was deleted. This file was
* RECONSTRUCTED from the command echo preserved in
* output/build_matched_links.log (run of 15 Aug 2026, 18:23).
* The body below is verbatim from that echo.
*
* The SETTINGS block was NOT in the echo -- the original opened
* its log after those lines -- so the five values below are
* INFERRED from paths and counts printed in the run output:
*   mldir    <- "importing ...\Matched_Links\step2_matches_before.csv"
*   intdir   <- "saved: ...\Matched_Links\intermediate\step2_before_clean.dta"
*   sfx      <- "" (intermediate filenames carry no suffix)
*   reimport <- 1 (the CSVs were imported in that run)
*   testrun  <- 0 (full 66.4m/54.5m row counts, not a capped test)
*
* Verified against the surviving outputs: this logic reproduces
* the same pair set as the independent prep_HLINK_matches.do
* implementation, matching to the row (66,807,539 / 68,498,407).
*
* NOT RE-RUN as part of the table rebuild -- matches_*.dta already
* exist. Re-running costs a full re-import of ~36 GB of CSV.
* ------------------------------------------------------------

clear all
set more off

* ---- Path bootstrap ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
do "$ROOT/code/shared/paths.do"

* ============================================================
* SETTINGS (reconstructed -- see PROVENANCE above)
* ============================================================
* csvdir holds the third-party HLINK output this script imports; mldir is where
* the links we derive from it are written. They used to be the same folder.
local csvdir   "$D_LINKS_RAW"
local mldir    "$D_LINKS"
local intdir   "$D_LINKS/intermediate"
local sfx      ""
local reimport 1
local testrun  0

capture mkdir "`intdir'"



* ============================================================
* PROGRAM: import one CSV, filter, rename, save
* ============================================================

capture program drop import_step

program define import_step
    syntax, csvfile(string) outfile(string) [maxrows(integer 0)]

    * rowrange() counts the header as row 1, so ask for maxrows+1
    if `maxrows' > 0 {
        local lastrow = `maxrows' + 1
        local rowopt "rowrange(1:`lastrow')"
    }
    else {
        local rowopt ""
    }

    di as txt _newline "  importing `csvfile' ..."

    * colrange(1:4) skips probability_array, which is by far the
    * widest column and is not needed downstream
    import delimited using "`csvfile'", ///
        varnames(1) colrange(1:4) stringcols(1 2) bindquote(strict) ///
        `rowopt' clear

    quietly count
    di as txt "    rows read:               " as res %15.0fc r(N)

    * prediction arrives numeric or string depending on how the
    * quoting is parsed — handle either
    capture confirm string variable prediction
    if _rc == 0 {
        quietly keep if prediction == "1"
    }
    else {
        quietly keep if prediction == 1
    }

    quietly count
    di as txt "    rows with prediction==1: " as res %15.0fc r(N)

    rename histid_a histid1930
    rename histid_b histid1940
    keep  histid1930 histid1940 probability
    order histid1930 histid1940 probability

    label variable histid1930  "1930 census HISTID (histid_a)"
    label variable histid1940  "1940 census HISTID (histid_b)"
    label variable probability "Model match probability"

    save "`outfile'", replace
    di as txt "    saved: `outfile'"
end



* ============================================================
* MAIN LOOP: before, after
* ============================================================

foreach when in before after {

    di as txt _newline(2) "============================================================"
    di as txt "VINTAGE: `when'"
    di as txt "============================================================"

    local f_s1   "`intdir'\step1_`when'_clean`sfx'.dta"
    local f_s2   "`intdir'\step2_`when'_clean`sfx'.dta"
    local f_id30 "`intdir'\step2_`when'_ids1930`sfx'.dta"
    local f_id40 "`intdir'\step2_`when'_ids1940`sfx'.dta"

    * --------------------------------------------------------
    * Import both steps
    * --------------------------------------------------------
    if `reimport' {
        di as txt _newline "-- STEP 2 --"
        import_step, csvfile("`csvdir'\step2_matches_`when'.csv") ///
                     outfile("`f_s2'") maxrows(`testrun')

        di as txt _newline "-- STEP 1 --"
        import_step, csvfile("`csvdir'\step1_matches_`when'.csv") ///
                     outfile("`f_s1'") maxrows(`testrun')
    }
    else {
        di as txt _newline "reimport == 0: reusing existing intermediate files"
    }

    * --------------------------------------------------------
    * Records step 2 already linked, on BOTH sides
    *
    * Two kinds of cross-step conflict have to be caught:
    *   (a) one 1930 record linked to different 1940 records by
    *       step 1 and step 2  -> collide on histid1930
    *   (b) two different 1930 records linked to the same 1940
    *       record by step 1 and step 2 -> collide on histid1940
    * Step 2 wins in both, so a step 1 pair survives only if
    * NEITHER of its records appears anywhere in step 2.
    * --------------------------------------------------------
    quietly describe using "`f_s2'"
    local n_s2 = r(N)

    * "use varlist using" reads a single column off disk rather
    * than loading the whole ~5 GB file
    use histid1930 using "`f_s2'", clear
    quietly duplicates drop
    quietly count
    local n_s2_id30 = r(N)
    save "`f_id30'", replace

    use histid1940 using "`f_s2'", clear
    quietly duplicates drop
    quietly count
    local n_s2_id40 = r(N)
    save "`f_id40'", replace

    * --------------------------------------------------------
    * Step 1: drop pairs that collide with step 2 on either side
    * --------------------------------------------------------
    use "`f_s1'", clear
    quietly count
    local n_s1 = r(N)

    merge m:1 histid1930 using "`f_id30'", keep(master) nogenerate
    quietly count
    local n_s1_mid = r(N)

    merge m:1 histid1940 using "`f_id40'", keep(master) nogenerate
    quietly count
    local n_s1_kept = r(N)

    local n_drop30  = `n_s1' - `n_s1_mid'
    local n_drop40  = `n_s1_mid' - `n_s1_kept'
    local n_s1_drop = `n_s1' - `n_s1_kept'

    * --------------------------------------------------------
    * Combine and save
    * --------------------------------------------------------
    append using "`f_s2'"

    sort histid1930 histid1940
    quietly count
    local n_total = r(N)

    quietly by histid1930: generate byte first30 = (_n == 1)
    quietly count if first30 == 1
    local n_persons = r(N)
    drop first30

    label data "1930-1940 links, `when' transcription; step2 supersedes step1"
    save "`mldir'\matches_`when'`sfx'.dta", replace

    * Distinct 1940 records. Costs a second sort, but it is the
    * check that the many-to-one case was actually handled: any
    * gap between this and the pair count now comes from within
    * step 1 or within step 2, never from a cross-step collision.
    sort histid1940
    quietly by histid1940: generate byte first40 = (_n == 1)
    quietly count if first40 == 1
    local n_rec1940 = r(N)

    * --------------------------------------------------------
    * Report
    * --------------------------------------------------------
    di as txt _newline "----- `when': summary -----"
    di as txt "step 2 pairs (all kept):         " as res %15.0fc `n_s2'
    di as txt "  distinct histid1930 in step 2: " as res %15.0fc `n_s2_id30'
    di as txt "  distinct histid1940 in step 2: " as res %15.0fc `n_s2_id40'
    di as txt "step 1 pairs read:               " as res %15.0fc `n_s1'
    di as txt "  dropped, 1930 side in step 2:  " as res %15.0fc `n_drop30'
    di as txt "  dropped, 1940 side in step 2:  " as res %15.0fc `n_drop40'
    di as txt "  superseded in total:           " as res %15.0fc `n_s1_drop'
    di as txt "  retained:                      " as res %15.0fc `n_s1_kept'
    di as txt "combined pairs:                  " as res %15.0fc `n_total'
    di as txt "  distinct histid1930:           " as res %15.0fc `n_persons'
    di as txt "  distinct histid1940:           " as res %15.0fc `n_rec1940'
    di as txt "saved: `mldir'\matches_`when'`sfx'.dta"
}

