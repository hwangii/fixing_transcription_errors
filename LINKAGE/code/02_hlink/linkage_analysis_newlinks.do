* ============================================================
* linkage_analysis_single.do
* Purpose:
*   Method-agnostic version of linkage_analysis.do. Runs the full
*   set of analyses for ONE linking method, whichever method is
*   specified in the METHOD CONFIGURATION block below. Nothing
*   below that block refers to a specific linking method.
*
*   1. Linkage rates, old vs new transcription.
*      Denominator = all men in 1940 census.
*   2. Pair-level comparison of each matched file to true links.
*      For new vs old transcription: what pairs were added/removed,
*      and were they true or false matches?
*   3. Repeat analyses (1) and (2) restricting to 1940 records
*      where Ancestry and FamilySearch transcriptions disagree.
* ============================================================

clear all
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
if "$LCODE" == "" global LCODE "F:/github_repos/fixing_transcription_errors/LINKAGE/code"
do "$LCODE/shared/paths.do"

* ---- Common file paths (all derived from paths.do) ----
local names1930   "$D_APPENDED/divided_file1930_ans_cleaned_women_added.dta"
local names1940   "$D_APPENDED/divided_file1940_true_cleaned_women_added.dta"
local congruent_f "$D_FLAGS/ipums_fs_names_for_Deaglan1940.dta"

local true_links "$D_TRUTH/mlp_training1930_1940.dta"

local outdir      "$OUT_TABLES"


* ============================================================
* METHOD CONFIGURATION  <-- the only block that needs editing
* ============================================================
*   mlabel   Display name for the method (used in table headers
*            and captions). LaTeX-safe text.
*   mtag     Short tag used in output filenames, labels, and log
*            output. No spaces.
*   link_new Matched-links file built on the NEW transcription.
*   link_old Matched-links file built on the OLD transcription.
*   id1930   Name of the 1930 person-ID variable in those files.
*   id1940   Name of the 1940 person-ID variable in those files.
*   keepif   Optional restriction applied when a links file is
*            loaded, written as a full if-condition (e.g.
*            "fiveyr_band == 1"). Leave empty for no restriction.
* ------------------------------------------------------------

local mlabel   "HLINK"
local mtag     "HLINK"
local link_new "$D_LINKS/matches_after.dta"
local link_old "$D_LINKS/matches_before.dta"
local id1930   "histid1930"
local id1940   "histid1940"
local keepif   ""

* Example configurations:
*   mlabel "ABE"          mtag "abe"  id1930 "id_A"     id1940 "id_B"       keepif "fiveyr_band == 1"
*   mlabel "Jaro-Winkler" mtag "jw"   id1930 "Ahistid"  id1940 "Bhistid"    keepif ""

* ---- Sanity check on the configuration ----
foreach req in mlabel mtag link_new link_old id1930 id1940 {
    if "``req''" == "" {
        di as error "METHOD CONFIGURATION incomplete: `req' is not set."
        exit 198
    }
}
foreach f in link_new link_old {
    capture confirm file "``f''"
    if _rc {
        di as error "Cannot find `f': ``f''"
        exit 601
    }
}


* ============================================================
* HELPER: load a matched-links file and standardise it
* ============================================================

capture program drop prep_links
program define prep_links
    args path id30 id40 cond
    use "`path'", clear
    if "`cond'" != "" {
        keep if `cond'
    }
    if "`id30'" != "histid1930" rename `id30' histid1930
    if "`id40'" != "histid1940" rename `id40' histid1940
    keep histid1930 histid1940
    duplicates drop histid1930 histid1940, force
end


* ============================================================
* HELPER: normalise variable names in a names file
* ============================================================
* The appended files in data/transcriptions/appended do not use the same variable
* names as the older clean_names extracts: the histid is called
* id, and the middle initial can be mi_true_cleaned or
* mi_ans_cleaned. This renames whichever variant is present to
* the canonical histid and mi, so everything downstream can
* assume a single schema. Call it straight after -use-. It is a
* no-op on files that already use the canonical names.
*
* Optional arguments override the candidate lists, in preference
* order:
*     normalize_names, idvars(histid id) mivars(mi mi_true_cleaned)

capture program drop normalize_names
program define normalize_names
    syntax [, IDVars(string) MIVars(string)]

    if "`idvars'" == "" local idvars "histid id"
    if "`mivars'" == "" local mivars "mi mi_true_cleaned mi_ans_cleaned"

    * Matching is done against the exact variable list via posof,
    * not with -confirm variable-, because confirm accepts
    * abbreviations: when mi_true_cleaned is present and mi is
    * not, confirm variable mi succeeds on the abbreviation and
    * the rename below would be skipped.
    quietly ds
    local have `r(varlist)'

    * ---- histid ----
    local p : list posof "histid" in have
    if `p' == 0 {
        local got ""
        foreach v of local idvars {
            if "`got'" == "" {
                local q : list posof "`v'" in have
                if `q' > 0 local got "`v'"
            }
        }
        if "`got'" == "" {
            di as error "normalize_names: no histid variable found"
            di as error "  looked for: `idvars'"
            di as error "  data has:   `have'"
            exit 111
        }
        capture confirm string variable `got'
        if _rc {
            local t : type `got'
            di as error "normalize_names: `got' is `t', not a string"
            exit 109
        }
        rename `got' histid
        di as text "  normalize_names: `got' -> histid"
    }

    * ---- mi ----
    local p : list posof "mi" in have
    if `p' == 0 {
        local got ""
        foreach v of local mivars {
            if "`got'" == "" {
                local q : list posof "`v'" in have
                if `q' > 0 local got "`v'"
            }
        }
        if "`got'" == "" {
            di as error "normalize_names: no middle-initial variable found"
            di as error "  looked for: `mivars'"
            di as error "  data has:   `have'"
            exit 111
        }
        rename `got' mi
        di as text "  normalize_names: `got' -> mi"
    }
end


* ============================================================
* PART 0: TEMPFILES
* ============================================================

* 1940 clean names (full) — restricted to boys age 8+
use `names1940', clear
normalize_names
keep if age >= 8
scalar N_men_1940_full = _N
keep histid mi
tempfile cn1940_full
save `cn1940_full'

* 1940 restricted to congruent == 0 (Ancestry != FamilySearch)
use `congruent_f', clear
keep if congruent == 0
keep histid
tempfile restr1940
save `restr1940'

* 1940 restricted clean names + denominator
use `cn1940_full', clear
merge 1:1 histid using `restr1940', keep(3) nogenerate
scalar N_men_1940_restr = _N
tempfile cn1940_restr
save `cn1940_restr'

* 1930 clean names
use `names1930', clear
normalize_names
keep histid mi
tempfile cn1930
save `cn1930'

* 1940 men (for filtering true links to 1940 side)
use `cn1940_full', clear
keep histid
tempfile men1940
save `men1940'

* True pairs: restricted to 1940 men
use `true_links', clear
keep histid1930 histid1940
duplicates drop histid1930 histid1940, force
rename histid1940 histid
merge m:1 histid using `men1940', keep(3) nogenerate
rename histid histid1940
tempfile true_pairs_full
save `true_pairs_full'

* True pairs: further restricted to 1940 congruent == 0
use `true_pairs_full', clear
rename histid1940 histid
merge m:1 histid using `restr1940', keep(3) nogenerate
rename histid histid1940
tempfile true_pairs_restr
save `true_pairs_restr'

* Person-level true links (histid1940 -> true_histid1930)
* Single file — classification does not depend on congruence
use `true_pairs_full', clear
rename histid1930 true_histid1930
tempfile true_by1940
save `true_by1940'


* ============================================================
* OUTER LOOP: run all analyses for full and restricted samples
* ============================================================

foreach samp in full restr {

    di _newline _newline "============================================================"
    di "METHOD: `mlabel'"
    if "`samp'" == "full"  di "SAMPLE: FULL"
    if "`samp'" == "restr" di "SAMPLE: RESTRICTED (congruent == 0)"
    di "============================================================"

    * ============================================================
    * PART 1: LINKAGE RATES
    * ============================================================

    di _newline "===== LINKAGE RATES ====="

    foreach ver in old new {

        prep_links "`link_`ver''" "`id1930'" "`id1940'" "`keepif'"

        * If restricted, keep only pairs where histid1940 is in restricted set
        if "`samp'" == "restr" {
            rename histid1940 histid
            merge m:1 histid using `restr1940', keep(3) nogenerate
            rename histid histid1940
        }

        scalar N_linked_`samp'_`ver' = _N
        scalar rate_`samp'_`ver'     = N_linked_`samp'_`ver' / N_men_1940_`samp'

        di "`mtag'_`ver': " N_linked_`samp'_`ver' " pairs linked" ///
           "  |  rate = " %6.4f rate_`samp'_`ver'
    }


    * ============================================================
    * PART 2: PAIR-LEVEL COMPARISON TO TRUE LINKS
    * ============================================================

    di _newline "===== LINK QUALITY (THREE CATEGORIES) ====="

    foreach ver in old new {

        prep_links "`link_`ver''" "`id1930'" "`id1940'" "`keepif'"

        if "`samp'" == "restr" {
            rename histid1940 histid
            merge m:1 histid using `restr1940', keep(3) nogenerate
            rename histid histid1940
        }

        * Classify matched pairs (1940-centric)
        merge m:1 histid1940 using `true_by1940', keep(1 3) gen(person_merge)

        count if person_merge == 1
        scalar unverifiable_`samp'_`ver' = r(N)
        count if person_merge == 3 & histid1930 == true_histid1930
        scalar verified_`samp'_`ver' = r(N)
        count if person_merge == 3 & histid1930 != true_histid1930
        scalar contradicted_`samp'_`ver' = r(N)

        * Recall: FN = true pairs not recovered
        preserve
            keep histid1930 histid1940
            merge 1:1 histid1930 histid1940 using `true_pairs_`samp'', keep(1 2 3) gen(pair_merge)
            count if pair_merge == 2
            scalar FN_`samp'_`ver' = r(N)
        restore

        scalar recall_`samp'_`ver' = verified_`samp'_`ver' / ///
            (verified_`samp'_`ver' + FN_`samp'_`ver')

        * Middle initial match rate
        preserve
            keep histid1930 histid1940
            rename histid1930 histid
            merge m:1 histid using `cn1930', keep(1 3) nogenerate
            rename histid histid1930
            rename mi mi1930
            rename histid1940 histid
            merge m:1 histid using `cn1940_`samp'', keep(1 3) nogenerate
            rename histid histid1940
            rename mi mi1940
            keep if mi1930 != "" & mi1940 != ""
            count
            scalar mi_denom_`samp'_`ver' = r(N)
            count if mi1930 == mi1940
            scalar mi_match_`samp'_`ver' = r(N)
            scalar mi_rate_`samp'_`ver'  = mi_match_`samp'_`ver' / mi_denom_`samp'_`ver'
        restore

        di "`mtag'_`ver':" ///
           "  Verified=" verified_`samp'_`ver' ///
           "  Unverifiable=" unverifiable_`samp'_`ver' ///
           "  Contradicted=" contradicted_`samp'_`ver' ///
           "  Recall=" %5.3f recall_`samp'_`ver' ///
           "  MI match rate=" %5.3f mi_rate_`samp'_`ver'
    }


    * ============================================================
    * PART 3: NEW vs OLD — net added, net removed, changed links
    * ============================================================

    di _newline "===== NEW vs OLD TRANSCRIPTION: PAIR CHANGES ====="

    * ---- Load new transcription pairs ----
    prep_links "`link_new'" "`id1930'" "`id1940'" "`keepif'"
    if "`samp'" == "restr" {
        rename histid1940 histid
        merge m:1 histid using `restr1940', keep(3) nogenerate
        rename histid histid1940
    }
    duplicates drop histid1930, force
    rename histid1940 histid1940_new
    tempfile newlinks_`samp'
    save `newlinks_`samp''

    * ---- Load old transcription pairs ----
    prep_links "`link_old'" "`id1930'" "`id1940'" "`keepif'"
    if "`samp'" == "restr" {
        rename histid1940 histid
        merge m:1 histid using `restr1940', keep(3) nogenerate
        rename histid histid1940
    }
    duplicates drop histid1930, force
    rename histid1940 histid1940_old

    * ---- Merge on histid1930 ----
    merge 1:1 histid1930 using `newlinks_`samp'', gen(id_merge)

    gen status = ""
    replace status = "net_removed" if id_merge == 1
    replace status = "net_added"   if id_merge == 2
    replace status = "unchanged"   if id_merge == 3 & histid1940_old == histid1940_new
    replace status = "changed"     if id_merge == 3 & histid1940_old != histid1940_new

    * ---- Merge with true links (1940-centric) ----
    * For net_added/unchanged/changed: classify using histid1940_new
    * For net_removed: classify using histid1940_old
    * We need to merge twice — once per 1940 ID column

    * Classify new link (net_added, changed)
    gen new_cat = .
    rename histid1940_new histid1940
    merge m:1 histid1940 using `true_by1940', keep(1 3) gen(merge_new)
    replace new_cat = 2 if inlist(status,"net_added","changed") & merge_new == 1
    replace new_cat = 1 if inlist(status,"net_added","changed") & merge_new == 3 & histid1930 == true_histid1930
    replace new_cat = 3 if inlist(status,"net_added","changed") & merge_new == 3 & histid1930 != true_histid1930
    rename histid1940 histid1940_new
    drop true_histid1930 merge_new

    * Classify old link (net_removed, changed)
    gen old_cat = .
    rename histid1940_old histid1940
    merge m:1 histid1940 using `true_by1940', keep(1 3) gen(merge_old)
    replace old_cat = 2 if inlist(status,"net_removed","changed") & merge_old == 1
    replace old_cat = 1 if inlist(status,"net_removed","changed") & merge_old == 3 & histid1930 == true_histid1930
    replace old_cat = 3 if inlist(status,"net_removed","changed") & merge_old == 3 & histid1930 != true_histid1930
    rename histid1940 histid1940_old
    drop true_histid1930 merge_old

    * ---- NET ADDED ----
    count if status == "net_added"
    scalar added_total_`samp' = r(N)
    count if status == "net_added" & new_cat == 1
    scalar added_verified_`samp' = r(N)
    count if status == "net_added" & new_cat == 2
    scalar added_unverifiable_`samp' = r(N)
    count if status == "net_added" & new_cat == 3
    scalar added_contradicted_`samp' = r(N)

    * ---- NET REMOVED ----
    count if status == "net_removed"
    scalar removed_total_`samp' = r(N)
    count if status == "net_removed" & old_cat == 1
    scalar removed_verified_`samp' = r(N)
    count if status == "net_removed" & old_cat == 2
    scalar removed_unverifiable_`samp' = r(N)
    count if status == "net_removed" & old_cat == 3
    scalar removed_contradicted_`samp' = r(N)

    * ---- CHANGED LINKS ----
    * Good
    count if status == "changed" & old_cat == 2 & new_cat == 1
    scalar chg_unv_ver_`samp' = r(N)
    count if status == "changed" & old_cat == 3 & new_cat == 1
    scalar chg_con_ver_`samp' = r(N)

    * Bad
    count if status == "changed" & old_cat == 1 & new_cat == 2
    scalar chg_ver_unv_`samp' = r(N)
    count if status == "changed" & old_cat == 1 & new_cat == 3
    scalar chg_ver_con_`samp' = r(N)
    count if status == "changed" & old_cat == 2 & new_cat == 3
    scalar chg_unv_con_`samp' = r(N)
    count if status == "changed" & old_cat == 3 & new_cat == 3
    scalar chg_con_con_`samp' = r(N)

    * Neutral
    count if status == "changed" & old_cat == 2 & new_cat == 2
    scalar chg_unv_unv_`samp' = r(N)
    count if status == "changed" & old_cat == 3 & new_cat == 2
    scalar chg_con_unv_`samp' = r(N)

    di _newline "`mtag' (`samp') — status breakdown:"
    tab status

} // end foreach samp


* ============================================================
* PART 4: LATEX TABLES
* ============================================================

capture mkdir "`outdir'"

foreach samp in full restr {

    * ---- Format Panel A scalars ----
    foreach ver in old new {
        local rate_`ver'         : di %5.2f  (rate_`samp'_`ver'    * 100)
        local recall_`ver'       : di %5.2f  (recall_`samp'_`ver'  * 100)
        local mi_rate_`ver'      : di %5.2f  (mi_rate_`samp'_`ver' * 100)
        local verified_`ver'     : di %12.0fc verified_`samp'_`ver'
        local unverifiable_`ver' : di %12.0fc unverifiable_`samp'_`ver'
        local contradicted_`ver' : di %12.0fc contradicted_`samp'_`ver'
    }

    * ---- Format Panel B scalars ----
    foreach cat in verified unverifiable contradicted {
        local n_a = added_`cat'_`samp'
        local p_a : di %4.1f (`n_a' / added_total_`samp' * 100)
        local f_a : di %9.0fc `n_a'
        local b_added_`cat' "`f_a' (`p_a'\%)"

        local n_r = removed_`cat'_`samp'
        local p_r : di %4.1f (`n_r' / removed_total_`samp' * 100)
        local f_r : di %9.0fc `n_r'
        local b_removed_`cat' "`f_r' (`p_r'\%)"
    }

    * ---- Set output file and caption ----
    * Filenames use a lowercased method tag so they stay consistent
    * across linkages; mlabel keeps its original case for display.
    local ftag = strlower("`mtag'")
    if "`samp'" == "full" {
        local outtex "`outdir'/linkage_table_`ftag'.tex"
        local caption "Linkage Quality, `mlabel' Links: Old vs.\ New Transcription, 1930--1940. Denominator is all men in the 1940 census."
    }
    if "`samp'" == "restr" {
        local outtex "`outdir'/linkage_table_`ftag'_restricted.tex"
        local caption "Linkage Quality, `mlabel' Links: Old vs.\ New Transcription, 1930--1940. Restricted to 1940 records where Ancestry and FamilySearch transcriptions disagree. Denominator is men in the 1940 census with discordant transcriptions."
    }

    file open f using "`outtex'", write replace

    file write f "\begin{table}[htbp]" _n
    file write f "\centering" _n
    file write f "\caption{`caption'}" _n
    file write f "\label{tab:linkage_quality_`mtag'_`samp'}" _n
    file write f "\begin{tabular}{lcc}" _n
    file write f "\toprule" _n
    file write f " & \multicolumn{2}{c}{`mlabel'} \\" _n
    file write f "\cmidrule(lr){2-3}" _n
    file write f " & Old & New \\" _n

    * Panel A
    file write f "\midrule" _n
    file write f "\multicolumn{3}{l}{\textit{Panel A: Coverage and Link Quality}} \\" _n
    file write f "Match Rate (\%)       & `rate_old'         & `rate_new'         \\" _n
    file write f "MI Match Rate (\%)    & `mi_rate_old'      & `mi_rate_new'      \\" _n
    file write f "Verified Correct      & `verified_old'     & `verified_new'     \\" _n
    file write f "Unverifiable          & `unverifiable_old' & `unverifiable_new' \\" _n
    file write f "Directly Contradicted & `contradicted_old' & `contradicted_new' \\" _n
    file write f "Recall (\%)           & `recall_old'       & `recall_new'       \\" _n

    * Panel B
    file write f "\midrule" _n
    file write f "\multicolumn{3}{l}{\textit{Panel B: Net New Links (New Transcription vs.\ Old)}} \\" _n
    file write f "\multicolumn{3}{l}{\textit{\quad Added}} \\" _n
    file write f "\quad (Good) Verified Correct      & \multicolumn{2}{c}{`b_added_verified'}     \\" _n
    file write f "\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{`b_added_unverifiable'} \\" _n
    file write f "\quad (Bad) Directly Contradicted  & \multicolumn{2}{c}{`b_added_contradicted'} \\" _n
    file write f "\multicolumn{3}{l}{\textit{\quad Removed}} \\" _n
    file write f "\quad (Bad) Verified Correct       & \multicolumn{2}{c}{`b_removed_verified'}     \\" _n
    file write f "\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{`b_removed_unverifiable'} \\" _n
    file write f "\quad (Good) Directly Contradicted & \multicolumn{2}{c}{`b_removed_contradicted'} \\" _n

    file write f "\bottomrule" _n
    file write f "\end{tabular}" _n
    file write f "\end{table}" _n

    file close f
    di _newline "LaTeX table written to: `outtex'"
}
