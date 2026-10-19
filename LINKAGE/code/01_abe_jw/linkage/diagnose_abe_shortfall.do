/*------------------------------------------------------------------------------
Why does the full-count ABE reconstruction fall ~1,600 pairs short?

run_abe_match.do reproduced Massachusetts EXACTLY (488,439 pairs, identical
fields). On the full count it lands 1,615 pairs short for the old vintage and
1,021 short for the new -- 0.0095% and 0.0056%. Small, but Massachusetts was
exact, so this is not general noise and should be explained rather than
tolerated.

The first question is directional:

  * If the reconstruction is a strict SUBSET of the original, the rule is the
    same and something is dropping a few pairs at a boundary.
  * If it also contains pairs the original lacks, the two runs are resolving
    something differently -- ties, ordering, or a parameter that only bites on
    birthplaces Massachusetts does not exercise.

Those imply very different fixes, so establish which before theorising.

Then locate the missing pairs by birthplace. Concentrated in a few birthplaces
points at a specific failure; spread thinly across many points at tie-breaking.

Reads only. Writes nothing except a small summary file.
------------------------------------------------------------------------------*/

drop _all
clear all
set more off

if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
do "$ROOT/code/shared/paths.do"

local vintage "old"

if "`vintage'" == "old" {
    local bpldir "$ABEJW/data/by_bpl"
    local tag    "ans_cleaned"
}
else {
    local bpldir "$ABEJW/data/by_bpl_new_transcription"
    local tag    "true_cleaned"
}

local original "$D_LINKS/link1930_1940_`tag'_noraceblock0.dta"
local recon    "$D_LINKS/link1930_1940_`tag'_noraceblock0_RECONSTRUCTED.dta"

foreach f in "`original'" "`recon'" {
    capture confirm file "`f'"
    if _rc {
        di as error "missing: `f'"
        exit 601
    }
}

di as text _n "{hline 78}"
di as result "ABE shortfall diagnosis  --  vintage `vintage'"
di as text "{hline 78}"

*==============================================================================
* 1. Direction: subset, superset, or both?
*==============================================================================

use id_A id_B using "`original'", clear
quietly count
local n_orig = r(N)
tempfile orig
quietly save `orig'

use id_A id_B using "`recon'", clear
quietly count
local n_recon = r(N)

quietly merge 1:1 id_A id_B using `orig', generate(_m)

quietly count if _m == 3
local n_both = r(N)
quietly count if _m == 1
local n_only_recon = r(N)
quietly count if _m == 2
local n_only_orig = r(N)

di as text _n "{hline 78}"
di as result "DIRECTION"
di as text "{hline 78}"
di as text "  original pairs        : " %14.0fc `n_orig'
di as text "  reconstruction pairs  : " %14.0fc `n_recon'
di as text "  in both               : " %14.0fc `n_both'
di as text "  reconstruction ONLY   : " %14.0fc `n_only_recon'
di as text "  original ONLY         : " %14.0fc `n_only_orig'

if `n_only_recon' == 0 {
    di as result _n "  => the reconstruction is a strict SUBSET of the original."
    di as text    "     Same rule; a few pairs are being dropped somewhere."
}
else {
    di as error _n "  => NOT a subset: the reconstruction contains " ///
       %12.0fc `n_only_recon' " pairs the original lacks."
    di as text    "     The two runs resolve something differently."
}

* keep the disagreeing pairs for step 2
quietly keep if _m != 3
rename _m _side
tempfile diff
quietly save `diff'

*==============================================================================
* 2. Where are they? Build histid -> bpl from the matcher's own inputs.
*==============================================================================
* The link files carry no bpl column, so recover it from the per-birthplace
* input files -- which is exactly the partition the matcher used.

use "`bpldir'/bpl_list.dta", clear
quietly levelsof bpl, local(bpls) clean

tempfile map
local first 1
foreach b of local bpls {
    quietly use histid using "`bpldir'/bpl_`b'/clean_names_1930.dta", clear
    quietly generate int bpl = `b'
    if `first' {
        quietly save `map', replace
        local first 0
    }
    else {
        quietly append using `map'
        quietly save `map', replace
    }
}
quietly use `map', clear
quietly count
local n_map = r(N)
quietly duplicates drop histid, force
quietly save `map', replace
di as text _n "  A-side id -> bpl map: " %14.0fc `n_map' " ids"

use `diff', clear
rename id_A histid
quietly merge m:1 histid using `map', keep(1 3) nogenerate

di as text _n "{hline 78}"
di as result "MISSING PAIRS BY BIRTHPLACE (original only)"
di as text "{hline 78}"

preserve
    quietly keep if _side == 2
    quietly count
    local n_miss = r(N)
    quietly count if missing(bpl)
    local n_nobpl = r(N)
    di as text "  missing pairs         : " %14.0fc `n_miss'
    di as text "  whose A-side id is NOT in any bpl input file : " %10.0fc `n_nobpl'
    if `n_nobpl' > 0 {
        di as error "  ^ those A-side records are absent from the matcher's input"
        di as error "    entirely, so no parameter change could recover them."
    }

    quietly drop if missing(bpl)
    if _N > 0 {
        contract bpl, freq(n_missing)
        gsort -n_missing
        di as text _n "  top birthplaces by missing pairs:"
        list bpl n_missing in 1/`=min(20,_N)', noobs clean
        quietly count
        di as text _n "  birthplaces affected : " %6.0f r(N)
    }
restore

di as text _n "{hline 78}"
di as result "DONE"
di as text "{hline 78}"
