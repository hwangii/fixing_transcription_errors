/*------------------------------------------------------------------------------
verify_paths.do -- check that every path this package depends on resolves.

Run this after moving the package, changing ROOT, or reorganising data. It
touches nothing and takes seconds. Every global in paths.do is checked, then
the specific files each pipeline needs.

    Start-Process "C:\Program Files (x86)\Stata15\StataMP-64.exe" `
      -ArgumentList '/e','do','"F:\Deaglan\Census_Transcriptions\code\shared\verify_paths.do"' `
      -Wait -NoNewWindow -WorkingDirectory "F:\Deaglan\Census_Transcriptions\output\logs"

Exits 0 if everything resolves, 9 if anything is missing.
------------------------------------------------------------------------------*/

drop _all
clear all
set more off

if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
if "$LCODE" == "" global LCODE "F:/github_repos/fixing_transcription_errors/LINKAGE/code"
do "$LCODE/shared/paths.do"

global NFAIL 0

* Check one file. This is a program rather than a loop over a list because
*     local files "A" "B" "C"
* does NOT create a three-element list: Stata strips only the outermost quote
* pair, so the macro becomes  A" "B" "C  and the first element carries a stray
* trailing quote. That silently reports a present file as missing.
capture program drop chkfile
program define chkfile
    args f
    capture confirm file "`f'"
    if _rc {
        di as error "  MISS  `f'"
        global NFAIL = $NFAIL + 1
    }
    else di as result "  OK    " as text "`f'"
end

* ---------------------------------------------------------------
* 1. Directory globals
* ---------------------------------------------------------------
di as text _n "{hline 78}"
di as result "DIRECTORIES"
di as text "{hline 78}"

foreach g in ROOT CODE C_ABEJW C_HLINK C_MORT DATA D_CENSUS D_NAMES     ///
             D_FLAGS D_TRANSCRIPT D_APPENDED D_LINKS D_LINKS_RAW       ///
             D_TRUTH D_MORT OUT OUT_TABLES OUT_LOGS ABEJW ABE_SRC {
    local p "${`g'}"
    * a directory is confirmed by the presence of its own path as a dir:
    * -confirm file- fails on directories, so test with a wildcard listing
    local ok = 0
    mata: st_local("ok", strofreal(direxists(st_local("p"))))
    if `ok' == 1 {
        di as text "  " %-14s "`g'" as result " OK   " as text "`p'"
    }
    else {
        di as text "  " %-14s "`g'" as error " MISS " as text "`p'"
        global NFAIL = $NFAIL + 1
    }
}

* ---------------------------------------------------------------
* 2. Files the TABLE scripts need
* ---------------------------------------------------------------
di as text _n "{hline 78}"
di as result "TABLE INPUTS"
di as text "{hline 78}"

chkfile "$D_LINKS/link1930_1940_ans_cleaned_noraceblock0.dta"
chkfile "$D_LINKS/link1930_1940_true_cleaned_noraceblock0.dta"
chkfile "$D_LINKS/JW_matches_x2_unique_old.dta"
chkfile "$D_LINKS/JW_matches_x2_unique_new.dta"
chkfile "$D_LINKS/matches_before.dta"
chkfile "$D_LINKS/matches_after.dta"
chkfile "$D_TRUTH/mlp_training1930_1940.dta"
chkfile "$D_NAMES/clean_names_1930_old.dta"
chkfile "$D_NAMES/clean_names_1940_old.dta"
chkfile "$D_NAMES/clean_names_1940_new.dta"
chkfile "$D_FLAGS/ipums_fs_names_for_Deaglan1940.dta"
chkfile "$D_APPENDED/divided_file1930_ans_cleaned_women_added.dta"
chkfile "$D_APPENDED/divided_file1940_true_cleaned_women_added.dta"
chkfile "$D_LINKS_RAW/step1_matches_before.csv"
chkfile "$D_LINKS_RAW/step2_matches_after.csv"
chkfile "$D_MORT/working/censoc_bunmd_matched_oldnames.dta"
chkfile "$D_MORT/working/censoc_bunmd_matched_newnames_conservative.dta"
chkfile "$D_MORT/temp.dta"

* ---------------------------------------------------------------
* 3. Files the LINKAGE steps need
* ---------------------------------------------------------------
di as text _n "{hline 78}"
di as result "LINKAGE INPUTS"
di as text "{hline 78}"

chkfile "$ABEJW/data/by_bpl/bpl_list.dta"
chkfile "$ABEJW/data/by_bpl_new_transcription/bpl_list.dta"
chkfile "$ABEJW/data/full_census/clean_names_1930.dta"
chkfile "$ABEJW/data/full_census/clean_names_1940.dta"
chkfile "$ABE_SRC/matching_intgen1930.dta"
chkfile "$ABE_SRC/matching_intgen1940.dta"
chkfile "$C_ABEJW/ado/pairing_chunked_gtools.ado"
chkfile "$C_ABEJW/ado/filtering.do"
chkfile "$C_ABEJW/reference/abematch.ado"
chkfile "$C_ABEJW/reference/abeclean.ado"

* ---------------------------------------------------------------
* 4. Per-bpl trees: spot-check that the splits are populated
* ---------------------------------------------------------------
di as text _n "{hline 78}"
di as result "PER-BPL SPLITS"
di as text "{hline 78}"

foreach tree in by_bpl by_bpl_new_transcription {
    capture confirm file "$ABEJW/data/`tree'/bpl_list.dta"
    if _rc {
        di as error "  MISS  $ABEJW/data/`tree'/bpl_list.dta"
        global NFAIL = $NFAIL + 1
        continue
    }
    quietly use "$ABEJW/data/`tree'/bpl_list.dta", clear
    quietly count
    local n_bpl = r(N)
    quietly levelsof bpl, local(bpls) clean

    local missing 0
    foreach b of local bpls {
        foreach yr in 1930 1940 {
            capture confirm file "$ABEJW/data/`tree'/bpl_`b'/clean_names_`yr'.dta"
            if _rc local ++missing
        }
    }
    if `missing' == 0 {
        di as result "  OK    " as text %-28s "`tree'" ///
           "`n_bpl' bpl values, all split files present"
    }
    else {
        di as error "  MISS  `tree': `missing' of " ///
           %1.0f (2*`n_bpl') " split files absent"
        global NFAIL = $NFAIL + 1
    }
}

* ---------------------------------------------------------------
* 5. Nothing should point outside the package
* ---------------------------------------------------------------
di as text _n "{hline 78}"
di as result "SELF-CONTAINMENT"
di as text "{hline 78}"

foreach g in ABEJW ABE_SRC D_NAMES D_FLAGS D_TRANSCRIPT D_APPENDED ///
             D_LINKS D_LINKS_RAW D_TRUTH D_MORT {
    local p "${`g'}"
    if strpos("`p'", "$ROOT") == 1 {
        di as result "  OK    " as text %-10s "`g'" " inside package"
    }
    else {
        di as error "  OUT   `g' = `p'"
        global NFAIL = $NFAIL + 1
    }
}

* ---------------------------------------------------------------
di as text _n "{hline 78}"
if $NFAIL == 0 {
    di as result "ALL PATHS RESOLVE"
    di as text "{hline 78}"
}
else {
    di as error "$NFAIL PROBLEM(S) -- see MISS/OUT lines above"
    di as text "{hline 78}"
    exit 9
}
