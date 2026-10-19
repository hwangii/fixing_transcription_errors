* ============================================================
* linkage_analysis.do
* Purpose:
*   1. Linkage rates for JW and ABE methods, old vs new
*      transcription. Denominator = all men in 1940 census.
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

* ---- Replication package (2026-10-18): the numbers the draft quotes ----
* Written by repnum to the tracked replication/results/linkage_abe_jw.tex.
* Adds output only; nothing below that writes the table is changed.
if `"$REP_REPO"' == "" do "F:/github_repos/fixing_transcription_errors/replication/config.do"
repnum open using "$REP_RESULTS/linkage_abe_jw.tex", script(LINKAGE/code/01_abe_jw/linkage_analysis.do)

* ---- File paths (all derived from paths.do) ----
local names1930   "$D_NAMES/clean_names_1930_old.dta"
local names1940   "$D_NAMES/clean_names_1940_new.dta"
local congruent_f "$D_FLAGS/ipums_fs_names_for_Deaglan1940.dta"

local jw_new  "$D_LINKS/JW_matches_x2_unique_new.dta"
local jw_old  "$D_LINKS/JW_matches_x2_unique_old.dta"
local abe_new "$D_LINKS/link1930_1940_true_cleaned_noraceblock0.dta"
local abe_old "$D_LINKS/link1930_1940_ans_cleaned_noraceblock0.dta"

local true_links "$D_TRUTH/mlp_training1930_1940.dta"

* ============================================================
* PART 0: TEMPFILES
* ============================================================

* 1940 clean names (full) — restricted to boys age 8+
use `names1940', clear
keep if age >= 8
scalar N_men_1940_full = _N
repnum linkDenomAbe = N_men_1940_full, format(%15.0fc)
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
repnum linkDenomAbeDisc = N_men_1940_restr, format(%15.0fc)
tempfile cn1940_restr
save `cn1940_restr'

* 1930 clean names
use `names1930', clear
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
    if "`samp'" == "full"  di "SAMPLE: FULL"
    if "`samp'" == "restr" di "SAMPLE: RESTRICTED (congruent == 0)"
    di "============================================================"

    * ============================================================
    * PART 1: LINKAGE RATES
    * ============================================================

    di _newline "===== LINKAGE RATES ====="

    foreach combo in "jw_new" "jw_old" "abe_new" "abe_old" {

        use ``combo'', clear
        if inlist("`combo'", "abe_new", "abe_old") {
            keep if fiveyr_band == 1
            rename id_A histid1930
            rename id_B histid1940
        }
        else {
            rename Ahistid histid1930
            rename Bhistid histid1940
        }
        keep histid1930 histid1940
        duplicates drop histid1930 histid1940, force

        * If restricted, keep only pairs where histid1940 is in restricted set
        if "`samp'" == "restr" {
            rename histid1940 histid
            merge m:1 histid using `restr1940', keep(3) nogenerate
            rename histid histid1940
        }

        scalar N_linked_`samp'_`combo' = _N
        scalar rate_`samp'_`combo'     = N_linked_`samp'_`combo' / N_men_1940_`samp'

        di "`combo': " N_linked_`samp'_`combo' " pairs linked" ///
           "  |  rate = " %6.4f rate_`samp'_`combo'
    }


    * ============================================================
    * PART 2: PAIR-LEVEL COMPARISON TO TRUE LINKS
    * ============================================================

    di _newline "===== LINK QUALITY (THREE CATEGORIES) ====="

    foreach combo in "jw_new" "jw_old" "abe_new" "abe_old" {

        use ``combo'', clear
        if inlist("`combo'", "abe_new", "abe_old") {
            keep if fiveyr_band == 1
            rename id_A histid1930
            rename id_B histid1940
        }
        else {
            rename Ahistid histid1930
            rename Bhistid histid1940
        }
        keep histid1930 histid1940
        duplicates drop histid1930 histid1940, force

        if "`samp'" == "restr" {
            rename histid1940 histid
            merge m:1 histid using `restr1940', keep(3) nogenerate
            rename histid histid1940
        }

        * Classify matched pairs (1940-centric)
        merge m:1 histid1940 using `true_by1940', keep(1 3) gen(person_merge)

        count if person_merge == 1
        scalar unverifiable_`samp'_`combo' = r(N)
        count if person_merge == 3 & histid1930 == true_histid1930
        scalar verified_`samp'_`combo' = r(N)
        count if person_merge == 3 & histid1930 != true_histid1930
        scalar contradicted_`samp'_`combo' = r(N)

        * Recall: FN = true pairs not recovered
        preserve
            keep histid1930 histid1940
            merge 1:1 histid1930 histid1940 using `true_pairs_`samp'', keep(1 2 3) gen(pair_merge)
            count if pair_merge == 2
            scalar FN_`samp'_`combo' = r(N)
        restore

        scalar recall_`samp'_`combo' = verified_`samp'_`combo' / ///
            (verified_`samp'_`combo' + FN_`samp'_`combo')

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
            scalar mi_denom_`samp'_`combo' = r(N)
            count if mi1930 == mi1940
            scalar mi_match_`samp'_`combo' = r(N)
            scalar mi_rate_`samp'_`combo'  = mi_match_`samp'_`combo' / mi_denom_`samp'_`combo'
        restore

        di "`combo':" ///
           "  Verified=" verified_`samp'_`combo' ///
           "  Unverifiable=" unverifiable_`samp'_`combo' ///
           "  Contradicted=" contradicted_`samp'_`combo' ///
           "  Recall=" %5.3f recall_`samp'_`combo' ///
           "  MI match rate=" %5.3f mi_rate_`samp'_`combo'
    }


    * ============================================================
    * PART 3: NEW vs OLD — net added, net removed, changed links
    * ============================================================

    di _newline "===== NEW vs OLD TRANSCRIPTION: PAIR CHANGES ====="

    foreach method in "jw" "abe" {

        * ---- Load new transcription pairs ----
        use ``method'_new', clear
        if "`method'" == "abe" {
            keep if fiveyr_band == 1
            rename id_A histid1930
            rename id_B histid1940
        }
        else {
            rename Ahistid histid1930
            rename Bhistid histid1940
        }
        keep histid1930 histid1940
        if "`samp'" == "restr" {
            rename histid1940 histid
            merge m:1 histid using `restr1940', keep(3) nogenerate
            rename histid histid1940
        }
        duplicates drop histid1930, force
        rename histid1940 histid1940_new
        tempfile new_`method'_`samp'
        save `new_`method'_`samp''

        * ---- Load old transcription pairs ----
        use ``method'_old', clear
        if "`method'" == "abe" {
            keep if fiveyr_band == 1
            rename id_A histid1930
            rename id_B histid1940
        }
        else {
            rename Ahistid histid1930
            rename Bhistid histid1940
        }
        keep histid1930 histid1940
        if "`samp'" == "restr" {
            rename histid1940 histid
            merge m:1 histid using `restr1940', keep(3) nogenerate
            rename histid histid1940
        }
        duplicates drop histid1930, force
        rename histid1940 histid1940_old

        * ---- Merge on histid1930 ----
        merge 1:1 histid1930 using `new_`method'_`samp'', gen(id_merge)

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
        scalar added_total_`samp'_`method' = r(N)
        count if status == "net_added" & new_cat == 1
        scalar added_verified_`samp'_`method' = r(N)
        count if status == "net_added" & new_cat == 2
        scalar added_unverifiable_`samp'_`method' = r(N)
        count if status == "net_added" & new_cat == 3
        scalar added_contradicted_`samp'_`method' = r(N)

        * ---- NET REMOVED ----
        count if status == "net_removed"
        scalar removed_total_`samp'_`method' = r(N)
        count if status == "net_removed" & old_cat == 1
        scalar removed_verified_`samp'_`method' = r(N)
        count if status == "net_removed" & old_cat == 2
        scalar removed_unverifiable_`samp'_`method' = r(N)
        count if status == "net_removed" & old_cat == 3
        scalar removed_contradicted_`samp'_`method' = r(N)

        * ---- CHANGED LINKS ----
        * Good
        count if status == "changed" & old_cat == 2 & new_cat == 1
        scalar chg_unv_ver_`samp'_`method' = r(N)
        count if status == "changed" & old_cat == 3 & new_cat == 1
        scalar chg_con_ver_`samp'_`method' = r(N)

        * Bad
        count if status == "changed" & old_cat == 1 & new_cat == 2
        scalar chg_ver_unv_`samp'_`method' = r(N)
        count if status == "changed" & old_cat == 1 & new_cat == 3
        scalar chg_ver_con_`samp'_`method' = r(N)
        count if status == "changed" & old_cat == 2 & new_cat == 3
        scalar chg_unv_con_`samp'_`method' = r(N)
        count if status == "changed" & old_cat == 3 & new_cat == 3
        scalar chg_con_con_`samp'_`method' = r(N)

        * Neutral
        count if status == "changed" & old_cat == 2 & new_cat == 2
        scalar chg_unv_unv_`samp'_`method' = r(N)
        count if status == "changed" & old_cat == 3 & new_cat == 2
        scalar chg_con_unv_`samp'_`method' = r(N)

        di _newline "`method' (`samp') — status breakdown:"
        tab status
    }

} // end foreach samp


* ============================================================
* PART 4: LATEX TABLES
* ============================================================

capture mkdir "$OUT_TABLES"

foreach samp in full restr {

    * ---- Format Panel A scalars ----
    foreach combo in jw_old jw_new abe_old abe_new {
        local rate_`combo'         : di %5.2f  (rate_`samp'_`combo'    * 100)
        local recall_`combo'       : di %5.2f  (recall_`samp'_`combo'  * 100)
        local mi_rate_`combo'      : di %5.2f  (mi_rate_`samp'_`combo' * 100)
        local verified_`combo'     : di %12.0fc verified_`samp'_`combo'
        local unverifiable_`combo' : di %12.0fc unverifiable_`samp'_`combo'
        local contradicted_`combo' : di %12.0fc contradicted_`samp'_`combo'
    }

    * ---- Format Panel B scalars ----
    foreach method in jw abe {

        foreach cat in verified unverifiable contradicted {
            local n_a = added_`cat'_`samp'_`method'
            local p_a : di %4.1f (`n_a' / added_total_`samp'_`method' * 100)
            local f_a : di %9.0fc `n_a'
            local b_added_`cat'_`method' "`f_a' (`p_a'\%)"

            local n_r = removed_`cat'_`samp'_`method'
            local p_r : di %4.1f (`n_r' / removed_total_`samp'_`method' * 100)
            local f_r : di %9.0fc `n_r'
            local b_removed_`cat'_`method' "`f_r' (`p_r'\%)"
        }
    }

    * ---- Set output file and caption ----
    if "`samp'" == "full" {
        local outtex "$OUT_TABLES/linkage_table_abe_jw.tex"
        local caption "Linkage Quality: Old vs.\ New Transcription, 1930--1940. Denominator is all men in the 1940 census."
    }
    if "`samp'" == "restr" {
        local outtex "$OUT_TABLES/linkage_table_abe_jw_restricted.tex"
        local caption "Linkage Quality: Old vs.\ New Transcription, 1930--1940. Restricted to 1940 records where Ancestry and FamilySearch transcriptions disagree. Denominator is men in the 1940 census with discordant transcriptions."
    }

    file open f using "`outtex'", write replace

    file write f "\begin{table}[htbp]" _n
    file write f "\centering" _n
    file write f "\caption{`caption'}" _n
    file write f "\label{tab:linkage_quality_`samp'}" _n
    file write f "\begin{tabular}{lcccc}" _n
    file write f "\toprule" _n
    file write f " & \multicolumn{2}{c}{Jaro-Winkler} & \multicolumn{2}{c}{ABE} \\" _n
    file write f "\cmidrule(lr){2-3}\cmidrule(lr){4-5}" _n
    file write f " & Old & New & Old & New \\" _n

    * Panel A
    file write f "\midrule" _n
    file write f "\multicolumn{5}{l}{\textit{Panel A: Coverage and Link Quality}} \\" _n
    file write f "Match Rate (\%)       & `rate_jw_old'         & `rate_jw_new'         & `rate_abe_old'         & `rate_abe_new'         \\" _n
    file write f "MI Match Rate (\%)    & `mi_rate_jw_old'      & `mi_rate_jw_new'      & `mi_rate_abe_old'      & `mi_rate_abe_new'      \\" _n
    file write f "Verified Correct      & `verified_jw_old'     & `verified_jw_new'     & `verified_abe_old'     & `verified_abe_new'     \\" _n
    file write f "Unverifiable          & `unverifiable_jw_old' & `unverifiable_jw_new' & `unverifiable_abe_old' & `unverifiable_abe_new' \\" _n
    file write f "Directly Contradicted & `contradicted_jw_old' & `contradicted_jw_new' & `contradicted_abe_old' & `contradicted_abe_new' \\" _n
    file write f "Recall (\%)           & `recall_jw_old'       & `recall_jw_new'       & `recall_abe_old'       & `recall_abe_new'       \\" _n

    * Panel B
    file write f "\midrule" _n
    file write f "\multicolumn{5}{l}{\textit{Panel B: Net New Links (New Transcription vs.\ Old)}} \\" _n
    file write f "\multicolumn{5}{l}{\textit{\quad Added}} \\" _n
    file write f "\quad (Good) Verified Correct      & \multicolumn{2}{c}{`b_added_verified_jw'}     & \multicolumn{2}{c}{`b_added_verified_abe'}     \\" _n
    file write f "\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{`b_added_unverifiable_jw'} & \multicolumn{2}{c}{`b_added_unverifiable_abe'} \\" _n
    file write f "\quad (Bad) Directly Contradicted  & \multicolumn{2}{c}{`b_added_contradicted_jw'} & \multicolumn{2}{c}{`b_added_contradicted_abe'} \\" _n
    file write f "\multicolumn{5}{l}{\textit{\quad Removed}} \\" _n
    file write f "\quad (Bad) Verified Correct       & \multicolumn{2}{c}{`b_removed_verified_jw'}     & \multicolumn{2}{c}{`b_removed_verified_abe'}     \\" _n
    file write f "\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{`b_removed_unverifiable_jw'} & \multicolumn{2}{c}{`b_removed_unverifiable_abe'} \\" _n
    file write f "\quad (Good) Directly Contradicted & \multicolumn{2}{c}{`b_removed_contradicted_jw'} & \multicolumn{2}{c}{`b_removed_contradicted_abe'} \\" _n

    file write f "\bottomrule" _n
    file write f "\end{tabular}" _n
    file write f "\end{table}" _n

    file close f
    di _newline "LaTeX table written to: `outtex'"
}

repnum close
