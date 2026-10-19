/*------------------------------------------------------------------------------
Validate the ABE reconstruction against the original link files.

run_abe_match.do is a RECONSTRUCTION: the script that produced
data/links/link1930_1940_*_noraceblock0.dta does not exist on any drive, and its
parameters were inferred from the surviving artifacts. Matching row COUNTS would
be weak evidence -- two different parameterisations can land on similar totals.

This script asks the decisive question instead: are the pairs the SAME pairs?

Method
------
The originals are full-census, with no bpl column, so they cannot be filtered to
Massachusetts directly. But bpl is a blocking variable: every link's A-side
record lives in exactly one bpl file. So restricting the originals to A-side ids
that appear in by_bpl/bpl_25 recovers precisely the original's Massachusetts
links, and that is a like-for-like comparison set for the test run.

Reports
-------
  1. pair-level set agreement (in both / mine only / original only)
  2. for pairs in both: whether every non-key variable agrees
  3. whether f_name_A holds CLEANED or RAW names -- the one remaining ambiguity
     in the reconstruction, since both are str16 and width cannot discriminate
------------------------------------------------------------------------------*/

drop _all
clear all
set more off

if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
do "$ROOT/code/shared/paths.do"

local vintage "old"
local test_bpl 25

if "`vintage'" == "old" {
    local bpldir "$ABEJW/data/by_bpl"
    local tag    "ans_cleaned"
}
else {
    local bpldir "$ABEJW/data/by_bpl_new_transcription"
    local tag    "true_cleaned"
}

local original    "$D_LINKS/link1930_1940_`tag'_noraceblock0.dta"
local reconstruct "$ABEJW/data/matched_abe_`vintage'/link1930_1940_`tag'_noraceblock0_bpl`test_bpl'.dta"

foreach f in "`original'" "`reconstruct'" {
    capture confirm file "`f'"
    if _rc {
        di as error "missing: `f'"
        exit 601
    }
}

di as text _n "{hline 74}"
di as result "Validating ABE reconstruction  --  vintage `vintage', bpl `test_bpl'"
di as text "{hline 74}"
di as text "  original    : `original'"
di as text "  reconstruct : `reconstruct'"

*==============================================================================
* 1. A-side universe for this bpl
*==============================================================================

use histid using "`bpldir'/bpl_`test_bpl'/clean_names_1930.dta", clear
rename histid id_A
quietly duplicates drop id_A, force
quietly count
local n_univ = r(N)
tempfile univ
quietly save `univ'
di as text _n "  A-side ids in bpl `test_bpl' : " %12.0fc `n_univ'

*==============================================================================
* 2. Restrict the originals to that universe
*==============================================================================

use "`original'", clear
quietly count
local n_orig_all = r(N)
quietly merge m:1 id_A using `univ', keep(3) nogenerate
quietly count
local n_orig_bpl = r(N)
di as text "  original links, all bpl      : " %12.0fc `n_orig_all'
di as text "  original links, bpl `test_bpl' only  : " %12.0fc `n_orig_bpl'

* rename so the merge below can compare rather than silently keep master values
foreach v of varlist _all {
    if !inlist("`v'", "id_A", "id_B") rename `v' o_`v'
}
tempfile orig
quietly save `orig'

*==============================================================================
* 3. Pair-level set comparison
*==============================================================================

use "`reconstruct'", clear
quietly count
local n_recon = r(N)

* Is (id_A,id_B) actually a key? abematch iterates age bands, so in principle a
* pair could be emitted more than once. Check before merging rather than letting
* a 1:1 merge abort the run.
quietly duplicates tag id_A id_B, generate(_dup)
quietly count if _dup > 0
local n_dup_recon = r(N)
drop _dup
if `n_dup_recon' > 0 {
    di as error _n "  WARNING: " %12.0fc `n_dup_recon' ///
       " reconstruction rows share an (id_A,id_B) pair"
    di as error "  deduplicating before the comparison"
    quietly duplicates drop id_A id_B, force
    quietly count
    di as error "  rows after dedup: " %12.0fc r(N)
}
else di as text _n "  (id_A,id_B) is unique in the reconstruction"

capture merge 1:1 id_A id_B using `orig', generate(_cmp)
if _rc {
    di as error "  merge 1:1 failed (rc = " _rc ")"
    di as error "  (id_A,id_B) is not unique in the ORIGINAL -- rerun with m:1"
    exit _rc
}

quietly count if _cmp == 3
local n_both = r(N)
quietly count if _cmp == 1
local n_mine = r(N)
quietly count if _cmp == 2
local n_theirs = r(N)

local pct_recall = cond(`n_orig_bpl' > 0, 100 * `n_both' / `n_orig_bpl', 0)
local pct_prec   = cond(`n_recon'    > 0, 100 * `n_both' / `n_recon',    0)

di as text _n "{hline 74}"
di as result "PAIR-LEVEL AGREEMENT"
di as text "{hline 74}"
di as text "  reconstruction pairs   : " %12.0fc `n_recon'
di as text "  original pairs (bpl)   : " %12.0fc `n_orig_bpl'
di as text "  in BOTH                : " %12.0fc `n_both' ///
   "  (" %5.1f `pct_recall' "% of original, " %5.1f `pct_prec' "% of mine)"
di as text "  reconstruction only    : " %12.0fc `n_mine'
di as text "  original only          : " %12.0fc `n_theirs'

*==============================================================================
* 4. Variable-level agreement on the shared pairs
*==============================================================================

di as text _n "{hline 74}"
di as result "VARIABLE AGREEMENT (on the " %12.0fc `n_both' " shared pairs)"
di as text "{hline 74}"

foreach v in f_name_A l_name_A f_name_B l_name_B fiveyr_band mi1930 mi1940 {
    capture confirm variable `v'
    if _rc {
        di as text "  " %-14s "`v'" " : not in reconstruction"
        continue
    }
    capture confirm variable o_`v'
    if _rc {
        di as text "  " %-14s "`v'" " : not in original"
        continue
    }
    quietly count if _cmp == 3 & `v' != o_`v'
    local nd = r(N)
    local pd = cond(`n_both' > 0, 100 * `nd' / `n_both', 0)
    if `nd' == 0 di as result "  " %-14s "`v'" " : identical"
    else         di as error  "  " %-14s "`v'" " : " %12.0fc `nd' " differ (" %5.2f `pd' "%)"
}

*==============================================================================
* 5. Cleaned or raw names? The one width-indistinguishable ambiguity
*==============================================================================
* f_name_A is str16 in both the originals and in clean_names (raw f_name), so
* string width cannot say which the original carried. Compare directly.

di as text _n "{hline 74}"
di as result "CLEANED vs RAW NAMES on the A side"
di as text "{hline 74}"

* by_bpl carries only f_name_cleaned; the raw f_name lives in clean_names.
* Pull both and see which one the original's f_name_A reproduces.

preserve
    keep if _cmp == 3
    keep id_A f_name_A o_f_name_A
    quietly count
    local n_chk = r(N)

    tempfile shared
    quietly save `shared'

    * cleaned side
    use histid f_name_cleaned using "`bpldir'/bpl_`test_bpl'/clean_names_1930.dta", clear
    rename histid id_A
    quietly duplicates drop id_A, force
    quietly merge 1:m id_A using `shared', keep(3) nogenerate
    tempfile withclean
    quietly save `withclean'

    * raw side
    use histid f_name using "$D_NAMES/clean_names_1930_old.dta", clear
    rename histid id_A
    rename f_name f_name_rawsrc
    quietly duplicates drop id_A, force
    quietly merge 1:m id_A using `withclean', keep(3) nogenerate

    quietly count
    local n_join = r(N)

    quietly count if o_f_name_A == f_name_cleaned
    local n_clean = r(N)
    quietly count if o_f_name_A == f_name_rawsrc
    local n_raw = r(N)
    quietly count if f_name_cleaned == f_name_rawsrc
    local n_same = r(N)

    local p_clean = cond(`n_join' > 0, 100 * `n_clean' / `n_join', 0)
    local p_raw   = cond(`n_join' > 0, 100 * `n_raw'   / `n_join', 0)
    local p_same  = cond(`n_join' > 0, 100 * `n_same'  / `n_join', 0)

    di as text "  pairs joined to both sources        : " %12.0fc `n_join'
    di as text "  original f_name_A == f_name_cleaned : " %12.0fc `n_clean' ///
       "  (" %5.1f `p_clean' "%)"
    di as text "  original f_name_A == f_name (raw)   : " %12.0fc `n_raw' ///
       "  (" %5.1f `p_raw' "%)"
    di as text "  cleaned == raw (test is only informative"
    di as text "    where these disagree)             : " %12.0fc `n_same' ///
       "  (" %5.1f `p_same' "%)"

    * the discriminating subset: rows where cleaned and raw actually differ
    quietly count if f_name_cleaned != f_name_rawsrc
    local n_disc = r(N)
    if `n_disc' > 0 {
        quietly count if f_name_cleaned != f_name_rawsrc & o_f_name_A == f_name_cleaned
        local d_clean = r(N)
        quietly count if f_name_cleaned != f_name_rawsrc & o_f_name_A == f_name_rawsrc
        local d_raw = r(N)
        di as text _n "  on the " %9.0fc `n_disc' " rows where cleaned != raw:"
        di as result "    matches cleaned : " %12.0fc `d_clean' ///
           "  (" %5.1f (100 * `d_clean' / `n_disc') "%)"
        di as result "    matches raw     : " %12.0fc `d_raw' ///
           "  (" %5.1f (100 * `d_raw' / `n_disc') "%)"
    }
    else {
        di as text "  cleaned and raw never disagree here -- test uninformative"
    }
restore

di as text _n "{hline 74}"
di as result "DONE"
di as text "{hline 74}"
