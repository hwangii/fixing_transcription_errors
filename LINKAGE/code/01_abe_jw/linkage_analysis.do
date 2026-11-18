* ============================================================
* linkage_analysis.do
* Purpose:
*   1. Linkage rates for JW and ABE methods, old vs new
*      transcription. Denominator = 1940 men aged 10+ with both an
*      Ancestry and a FamilySearch transcription (2026-11-15; was
*      all men aged 8+).
*   2. Pair-level comparison of each matched file to true links.
*      For new vs old transcription: what pairs were added/removed,
*      and were they true or false matches?
*   3. Repeat analyses (1) and (2) restricting to 1940 records
*      where Ancestry and FamilySearch transcriptions disagree.
*
* 2026-11-15: SAME SAMPLE AND DEFINITIONS AS THE PAPER'S MAIN TABLE
* (tab:avg_performance, CODE/create_figures_SSHA2025.do), so that the
* paper and the slides report one linkage rate for one set of links:
*   - denominator: 1940 men aged 10+ with both transcriptions, from
*     linkage_sample1940.dta (LINKAGE/code/prep/build_linkage_sample1940.do,
*     built on machine A and copied to $D_FLAGS); was men aged 8+;
*   - target: Ancestry and FamilySearch disagree on the first or last
*     name (the file's target flag); was congruent == 0 from
*     ipums_fs_names_for_Deaglan1940.dta;
*   - numerator and every count: only links whose 1940 person is in the
*     denominator, in both samples (the full sample used to keep every
*     link);
*   - middle initials: each version its own in 1940, Ancestry's for Old
*     and ours for New (was ours for both); 1930 is Ancestry's in both.
* The ABE columns must then reproduce the main table's linkage rate and
* share validated; the file stops if they do not.
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
local sample_f    "$D_FLAGS/linkage_sample1940.dta"

local jw_new  "$D_LINKS/JW_matches_x2_unique_new.dta"
local jw_old  "$D_LINKS/JW_matches_x2_unique_old.dta"
local abe_new "$D_LINKS/link1930_1940_true_cleaned_noraceblock0.dta"
local abe_old "$D_LINKS/link1930_1940_ans_cleaned_noraceblock0.dta"

local true_links "$D_TRUTH/mlp_training1930_1940.dta"

* ============================================================
* PART 0: TEMPFILES
* ============================================================

* 1940 sample (full): men aged 10+ with both transcriptions, with each
* version's 1940 middle initial (mi_anc = Ancestry, mi_ml = ours)
use histid target mi_anc mi_ml using `sample_f', clear
isid histid
scalar N_men_1940_full = _N
repnum linkDenomAbe = N_men_1940_full, format(%15.0fc)
tempfile cn1940_full
save `cn1940_full'

* 1940 restricted: target records (Ancestry != FamilySearch)
keep if target == 1
scalar N_men_1940_restr = _N
repnum linkDenomAbeDisc = N_men_1940_restr, format(%15.0fc)
tempfile cn1940_restr
save `cn1940_restr'
keep histid
tempfile restr1940
save `restr1940'
tempfile den1940_restr
save `den1940_restr'

* 1940 non-target records (Ancestry == FamilySearch on first and last
* name), built exactly like restr (2026-11-18, review/handoff_nontarget_machineB.md)
use `cn1940_full', clear
assert inlist(target, 0, 1)
keep if target == 0
scalar N_men_1940_non = _N
tempfile cn1940_non
save `cn1940_non'
keep histid
tempfile den1940_non
save `den1940_non'
if N_men_1940_restr + N_men_1940_non != N_men_1940_full {
    di as error "restr + non != full: " N_men_1940_restr " + " N_men_1940_non " vs " N_men_1940_full
    exit 9
}

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

* Denominator populations, one per sample: every count below is
* restricted to these (fix 2026-11-15).
local den1940_full `men1940'

* True pairs: restricted to 1940 men
use `true_links', clear
keep histid1930 histid1940
duplicates drop histid1930 histid1940, force
rename histid1940 histid
merge m:1 histid using `men1940', keep(3) nogenerate
rename histid histid1940
tempfile true_pairs_full
save `true_pairs_full'

* True pairs: further restricted to 1940 target records
use `true_pairs_full', clear
rename histid1940 histid
merge m:1 histid using `restr1940', keep(3) nogenerate
rename histid histid1940
tempfile true_pairs_restr
save `true_pairs_restr'

* True pairs: 1940 non-target records
use `true_pairs_full', clear
rename histid1940 histid
merge m:1 histid using `den1940_non', keep(3) nogenerate
rename histid histid1940
tempfile true_pairs_non
save `true_pairs_non'

* Person-level true links (histid1940 -> true_histid1930)
* Single file — classification does not depend on congruence
use `true_pairs_full', clear
rename histid1930 true_histid1930
tempfile true_by1940
save `true_by1940'

* Person-level true links, 1930 side (histid1930 -> true_histid1940), from the
* FULL truth file: a 1930 person whose true 1940 match lies outside the
* denominator is still known to be linked to someone else. The truth file is
* one-to-one on both sides (36,690,338 pairs, machine A's file; checked 2026-11-09).
* Fix 2026-10-19: a pair is Directly Contradicted if EITHER of its people is
* truly linked to someone else. Before, only the 1940 side was checked, so a
* wrong link whose 1940 person is outside the truth set was Unverifiable.
use `true_links', clear
keep histid1930 histid1940
duplicates drop histid1930 histid1940, force
isid histid1930
rename histid1940 true_histid1940
tempfile true_by1930
save `true_by1930'


* ============================================================
* OUTER LOOP: run all analyses for full and restricted samples
* ============================================================

foreach samp in full restr non {

    di _newline _newline "============================================================"
    if "`samp'" == "full"  di "SAMPLE: FULL"
    if "`samp'" == "restr" di "SAMPLE: RESTRICTED (target == 1)"
    if "`samp'" == "non"   di "SAMPLE: NON-TARGET (target == 0)"
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

        * Only links whose 1940 person is in this sample's denominator
        * (fix 2026-11-15; the full sample used to keep every link).
        rename histid1940 histid
        merge m:1 histid using `den1940_`samp'', keep(3) nogenerate
        rename histid histid1940

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

        * Only links whose 1940 person is in this sample's denominator
        * (fix 2026-11-15; the full sample used to keep every link).
        rename histid1940 histid
        merge m:1 histid using `den1940_`samp'', keep(3) nogenerate
        rename histid histid1940

        * Classify matched pairs (two-sided; fix 2026-10-19)
        merge m:1 histid1940 using `true_by1940', keep(1 3) gen(person_merge)
        merge m:1 histid1930 using `true_by1930', keep(1 3) gen(merge30)

        count if person_merge == 1 & merge30 == 1
        scalar unverifiable_`samp'_`combo' = r(N)
        count if person_merge == 3 & histid1930 == true_histid1930
        scalar verified_`samp'_`combo' = r(N)
        count if (person_merge == 3 & histid1930 != true_histid1930) | (person_merge == 1 & merge30 == 3)
        scalar contradicted_`samp'_`combo' = r(N)
        drop merge30 true_histid1940

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
            * Each version's own 1940 initial (2026-11-15): Ancestry's
            * for old, ours for new.
            local miv = cond(strpos("`combo'", "_old"), "mi_anc", "mi_ml")
            rename histid1940 histid
            merge m:1 histid using `cn1940_`samp'', keep(1 3) nogenerate keepusing(`miv')
            rename histid histid1940
            rename `miv' mi1940
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

    * Non-target: Panel A only. Panel B is not computed: it pairs each
    * 1930 person's old and new link within the sample, so a link that
    * moves between target and non-target records would be counted as
    * removed in one sample and added in the other.
    if "`samp'" == "non" continue


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
        * Only links whose 1940 person is in this sample's denominator
        * (fix 2026-11-15; the full sample used to keep every link).
        rename histid1940 histid
        merge m:1 histid using `den1940_`samp'', keep(3) nogenerate
        rename histid histid1940
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
        * Only links whose 1940 person is in this sample's denominator
        * (fix 2026-11-15; the full sample used to keep every link).
        rename histid1940 histid
        merge m:1 histid using `den1940_`samp'', keep(3) nogenerate
        rename histid histid1940
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

        * 1930 side of the truth check (two-sided; fix 2026-10-19)
        merge m:1 histid1930 using `true_by1930', keep(1 3) gen(merge30)

        * Classify new link (net_added, changed)
        gen new_cat = .
        rename histid1940_new histid1940
        merge m:1 histid1940 using `true_by1940', keep(1 3) gen(merge_new)
        replace new_cat = 2 if inlist(status,"net_added","changed") & merge_new == 1 & merge30 == 1
        replace new_cat = 1 if inlist(status,"net_added","changed") & merge_new == 3 & histid1930 == true_histid1930
        replace new_cat = 3 if inlist(status,"net_added","changed") & ((merge_new == 3 & histid1930 != true_histid1930) | (merge_new == 1 & merge30 == 3))
        rename histid1940 histid1940_new
        drop true_histid1930 merge_new

        * Classify old link (net_removed, changed)
        gen old_cat = .
        rename histid1940_old histid1940
        merge m:1 histid1940 using `true_by1940', keep(1 3) gen(merge_old)
        replace old_cat = 2 if inlist(status,"net_removed","changed") & merge_old == 1 & merge30 == 1
        replace old_cat = 1 if inlist(status,"net_removed","changed") & merge_old == 3 & histid1930 == true_histid1930
        replace old_cat = 3 if inlist(status,"net_removed","changed") & ((merge_old == 3 & histid1930 != true_histid1930) | (merge_old == 1 & merge30 == 3))
        rename histid1940 histid1940_old
        drop true_histid1930 merge_old merge30 true_histid1940

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
* CHECK (2026-11-15): THE ABE COLUMNS REPRODUCE THE MAIN TABLE
* ============================================================
* Same links, sample, target and initials as tab:avg_performance
* (raw= values in replication/results/create_figures_SSHA2025.tex).
* A difference means the two tables still measure different things.

local p_n_restr 14416543
local p_n_full  51036859
local p_lr_restr_abe_old  8.88273284378925
local p_lr_restr_abe_new 19.4149041139752
local p_lr_full_abe_old  22.8142938812124
local p_lr_full_abe_new  24.6009379221398
local p_nv_restr_abe_old  308513
local p_nv_restr_abe_new  618732
local p_nv_full_abe_old  2512418
local p_nv_full_abe_new  2665324
local p_sv_restr_abe_old 65.4053475866495
local p_sv_restr_abe_new 83.5985531700316
local p_sv_full_abe_old  85.9879207998032
local p_sv_full_abe_new  87.137473718017
local bad 0
foreach samp in full restr {
    if N_men_1940_`samp' != `p_n_`samp'' {
        di as error "`samp' denominator: " N_men_1940_`samp' ", main table `p_n_`samp''"
        local bad 1
    }
    foreach combo in abe_old abe_new {
        if mi_denom_`samp'_`combo' != `p_nv_`samp'_`combo'' {
            di as error "`samp' `combo' links with both initials: " mi_denom_`samp'_`combo' ", main table `p_nv_`samp'_`combo''"
            local bad 1
        }
        if abs(100*rate_`samp'_`combo' - `p_lr_`samp'_`combo'') > 1e-9 {
            di as error "`samp' `combo' linkage rate: " %18.0g 100*rate_`samp'_`combo' ", main table `p_lr_`samp'_`combo''"
            local bad 1
        }
        if abs(100*mi_rate_`samp'_`combo' - `p_sv_`samp'_`combo'') > 1e-9 {
            di as error "`samp' `combo' share validated: " %18.0g 100*mi_rate_`samp'_`combo' ", main table `p_sv_`samp'_`combo''"
            local bad 1
        }
    }
}
if `bad' {
    di as error "CHECK FAILED: the ABE columns do not reproduce tab:avg_performance; no table written"
    exit 9
}
di "CHECK PASSED: the ABE columns reproduce tab:avg_performance"


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
        local caption "Linkage Quality: Old vs.\ New Transcription, 1930--1940. Denominator is 1940 men aged 10 and above with both an Ancestry and a FamilySearch transcription. MI match rate scores each version against its own 1940 middle initial (Ancestry's for Old, ours for New), as in the main table."
    }
    if "`samp'" == "restr" {
        local outtex "$OUT_TABLES/linkage_table_abe_jw_restricted.tex"
        local caption "Linkage Quality: Old vs.\ New Transcription, 1930--1940. Restricted to 1940 records where Ancestry and FamilySearch transcriptions disagree. Denominator is 1940 men aged 10 and above whose Ancestry and FamilySearch transcriptions disagree. MI match rate scores each version against its own 1940 middle initial (Ancestry's for Old, ours for New), as in the main table."
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


* ============================================================
* PART 5 (2026-11-18): NON-TARGET RECORDS, PANEL A
* ============================================================
* review/handoff_nontarget_machineB.md. Runs after the tables above, so
* a failure here cannot stop them; it stops only the non-target table.

* ---- Check 1: every count partitions, full = restr + non ----
local bad 0
foreach combo in jw_old jw_new abe_old abe_new {
    foreach s in N_linked verified unverifiable contradicted FN mi_denom mi_match {
        if `s'_full_`combo' != `s'_restr_`combo' + `s'_non_`combo' {
            di as error "`combo' `s': full " `s'_full_`combo' " != restr " `s'_restr_`combo' " + non " `s'_non_`combo'
            local bad 1
        }
    }
}

* ---- Check 2: denominator and ABE exact columns against
* MATCHING/results/tgt_linkage_abe.md, "Non-target records",
* Old and New (paper) ----
if N_men_1940_non != 36620316 {
    di as error "non-target denominator " N_men_1940_non ", expected 36,620,316"
    local bad 1
}
local e_links_abe_old 10363116
local e_links_abe_new  9756588
local e_nv_abe_old     2203905
local e_nv_abe_new     2046592
local e_sv_abe_old       88.87
local e_sv_abe_new       88.21
foreach combo in abe_old abe_new {
    if N_linked_non_`combo' != `e_links_`combo'' {
        di as error "non `combo' links: " N_linked_non_`combo' ", tgt_linkage_abe.md `e_links_`combo''"
        local bad 1
    }
    if mi_denom_non_`combo' != `e_nv_`combo'' {
        di as error "non `combo' links with both initials: " mi_denom_non_`combo' ", tgt_linkage_abe.md `e_nv_`combo''"
        local bad 1
    }
    if abs(100*mi_rate_non_`combo' - `e_sv_`combo'') > 0.005 {
        di as error "non `combo' share validated: " %6.3f 100*mi_rate_non_`combo' ", tgt_linkage_abe.md `e_sv_`combo''"
        local bad 1
    }
}
* Not gated, shown for comparison with the same file
di _newline "non-target ABE, this run vs tgt_linkage_abe.md (Old; New):"
di "  verified     " verified_non_abe_old     " vs 5407550; " verified_non_abe_new     " vs 5096391"
di "  unverifiable " unverifiable_non_abe_old " vs 4701840; " unverifiable_non_abe_new " vs 4440884"
di "  contradicted " contradicted_non_abe_old " vs 253726; "  contradicted_non_abe_new " vs 219313"
di "  recall (%)   " %5.2f 100*recall_non_abe_old " vs 38.59; " %5.2f 100*recall_non_abe_new " vs 36.37"

if `bad' {
    di as error "NON-TARGET CHECK FAILED: no non-target table written"
    exit 9
}
di "NON-TARGET CHECK PASSED"

* ---- Table ----
foreach combo in jw_old jw_new abe_old abe_new {
    local rate_`combo'         : di %5.2f  (rate_non_`combo'    * 100)
    local recall_`combo'       : di %5.2f  (recall_non_`combo'  * 100)
    local mi_rate_`combo'      : di %5.2f  (mi_rate_non_`combo' * 100)
    local verified_`combo'     : di %12.0fc verified_non_`combo'
    local unverifiable_`combo' : di %12.0fc unverifiable_non_`combo'
    local contradicted_`combo' : di %12.0fc contradicted_non_`combo'
}
local outtex "$OUT_TABLES/linkage_table_abe_jw_nontarget.tex"
local caption "Linkage Quality: Old vs.\ New Transcription, 1930--1940. Restricted to 1940 records where Ancestry and FamilySearch transcriptions agree (non-target records). Denominator is 1940 men aged 10 and above whose Ancestry and FamilySearch transcriptions agree. MI match rate scores each version against its own 1940 middle initial (Ancestry's for Old, ours for New), as in the main table."

file open f using "`outtex'", write replace
file write f "\begin{table}[htbp]" _n
file write f "\centering" _n
file write f "\caption{`caption'}" _n
file write f "\label{tab:linkage_quality_non}" _n
file write f "\begin{tabular}{lcccc}" _n
file write f "\toprule" _n
file write f " & \multicolumn{2}{c}{Jaro-Winkler} & \multicolumn{2}{c}{ABE} \\" _n
file write f "\cmidrule(lr){2-3}\cmidrule(lr){4-5}" _n
file write f " & Old & New & Old & New \\" _n
file write f "\midrule" _n
file write f "\multicolumn{5}{l}{\textit{Panel A: Coverage and Link Quality}} \\" _n
file write f "Match Rate (\%)       & `rate_jw_old'         & `rate_jw_new'         & `rate_abe_old'         & `rate_abe_new'         \\" _n
file write f "MI Match Rate (\%)    & `mi_rate_jw_old'      & `mi_rate_jw_new'      & `mi_rate_abe_old'      & `mi_rate_abe_new'      \\" _n
file write f "Verified Correct      & `verified_jw_old'     & `verified_jw_new'     & `verified_abe_old'     & `verified_abe_new'     \\" _n
file write f "Unverifiable          & `unverifiable_jw_old' & `unverifiable_jw_new' & `unverifiable_abe_old' & `unverifiable_abe_new' \\" _n
file write f "Directly Contradicted & `contradicted_jw_old' & `contradicted_jw_new' & `contradicted_abe_old' & `contradicted_abe_new' \\" _n
file write f "Recall (\%)           & `recall_jw_old'       & `recall_jw_new'       & `recall_abe_old'       & `recall_abe_new'       \\" _n
file write f "\bottomrule" _n
file write f "\end{tabular}" _n
file write f "\end{table}" _n
file close f
di _newline "LaTeX table written to: `outtex'"

repnum close
