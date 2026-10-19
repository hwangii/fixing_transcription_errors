/*------------------------------------------------------------------------------
Follow-up: WHY are those 1,615 A-side records absent from the matcher's input?

Step 1 (diagnose_abe_shortfall.do) established:
  - the reconstruction is a strict SUBSET of the original (0 extra pairs)
  - all 1,615 missing pairs have A-side ids absent from every by_bpl input file

So the matching rule is right and the INPUT PARTITION differs. The by_bpl split
holds 62,048,998 of the 62,079,010 records in clean_names_1930_old -- a gap of
30,012 dropped by run_full_census_prep.do, which:

    keep if sex == 1
    drop if missing(bpl) | missing(race) | first_initial == "" | last_initial == ""
    ... then bpl_list keeps only birthplaces present in BOTH years

This script asks which of those rules excluded the 1,615, by looking them up in
clean_names_1930_old and reporting the values of the filtered-on variables.

Reads only.
------------------------------------------------------------------------------*/

drop _all
clear all
set more off

if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
do "$ROOT/code/shared/paths.do"

local tag "ans_cleaned"
local original "$D_LINKS/link1930_1940_`tag'_noraceblock0.dta"
local recon    "$D_LINKS/link1930_1940_`tag'_noraceblock0_RECONSTRUCTED.dta"

* ---- recover the missing pairs' A-side ids ----
use id_A id_B using "`recon'", clear
tempfile r
quietly save `r'

use id_A id_B using "`original'", clear
quietly merge 1:1 id_A id_B using `r', keep(1) nogenerate
quietly count
local n_miss = r(N)
di as text _n "  missing pairs: " %10.0fc `n_miss'

keep id_A
quietly duplicates drop id_A, force
quietly count
local n_ids = r(N)
di as text "  distinct A-side ids: " %10.0fc `n_ids'
rename id_A histid
tempfile missids
quietly save `missids'

* ---- look them up in the FULL cleaned-name file ----
use histid sex race bpl f_name l_name using "$D_NAMES/clean_names_1930_old.dta", clear
quietly count
local n_clean = r(N)
quietly merge 1:m histid using `missids', keep(3) nogenerate
quietly count
local n_found = r(N)

di as text _n "{hline 78}"
di as result "ARE THE MISSING A-SIDE RECORDS IN clean_names_1930_old?"
di as text "{hline 78}"
di as text "  clean_names_1930_old rows : " %14.0fc `n_clean'
di as text "  of the " %6.0f `n_ids' " missing ids, found here : " %10.0fc `n_found'

if `n_found' == 0 {
    di as error _n "  None are in the cleaned-name file either -- the originals were"
    di as error "  built from a different/earlier input than this package holds."
    exit 0
}

* ---- which prep filter would have excluded them? ----
quietly generate byte no_race  = missing(race)
quietly generate byte no_bpl   = missing(bpl)
quietly generate byte no_fi    = (substr(f_name, 1, 1) == "")
quietly generate byte no_li    = (substr(l_name, 1, 1) == "")
quietly generate byte not_male = (sex != 1)

di as text _n "  Which prep filter excludes them (a record can trip more than one):"
foreach v in not_male no_bpl no_race no_fi no_li {
    quietly count if `v' == 1
    di as text "    " %-10s "`v'" " : " %8.0fc r(N)
}

quietly count if !not_male & !no_bpl & !no_race & !no_fi & !no_li
local n_clean_pass = r(N)
di as text _n "  pass EVERY prep filter yet are still absent from by_bpl : " ///
   %8.0fc `n_clean_pass'

if `n_clean_pass' > 0 {
    di as text "  => these were dropped by the bpl_list step, which keeps only"
    di as text "     birthplaces present in BOTH census years."
    preserve
        quietly keep if !not_male & !no_bpl & !no_race & !no_fi & !no_li
        contract bpl, freq(n)
        gsort -n
        di as text _n "  their birthplaces:"
        list bpl n in 1/`=min(15,_N)', noobs clean
    restore
}

di as text _n "{hline 78}"
di as result "DONE"
di as text "{hline 78}"
