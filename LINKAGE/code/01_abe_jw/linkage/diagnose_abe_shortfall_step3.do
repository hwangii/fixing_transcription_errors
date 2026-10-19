/*------------------------------------------------------------------------------
Final step: what ARE the 1,615 pairs the reconstruction does not produce?

Step 1: the reconstruction is a strict subset of the original (0 extra pairs);
        all missing pairs' A-side ids are absent from the matcher's input.
Step 2: all 1,615 of those A-side records ARE in clean_names_1930_old, are male,
        and have bpl and race -- but 791 have a blank FIRST name and 947 a blank
        LAST name. run_full_census_prep.do drops them because a record with no
        initial cannot be blocked.

ABE matches on EXACT cleaned names. So if a pair's 1930 first name is blank, its
1940 first name must be blank too, or they could not have matched. This script
checks that directly in the original link file rather than inferring it, and
reports what fraction of the missing pairs are joined on an empty name field.

That decides how to read the shortfall: if these are blank-on-blank joins, the
reconstruction is not missing real links -- it is declining to make spurious
ones, and is arguably the better output.

Reads only.
------------------------------------------------------------------------------*/

drop _all
clear all
set more off

if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
do "$ROOT/code/shared/paths.do"

foreach tag in ans_cleaned true_cleaned {

di as text _n(2) "{hline 78}"
di as result "VINTAGE: `tag'"
di as text "{hline 78}"

local original "$D_LINKS/link1930_1940_`tag'_noraceblock0.dta"
local recon    "$D_LINKS/link1930_1940_`tag'_noraceblock0_RECONSTRUCTED.dta"

use id_A id_B using "`recon'", clear
tempfile r
quietly save `r'

* the missing pairs, WITH their name fields as the original recorded them
use id_A id_B f_name_A l_name_A f_name_B l_name_B fiveyr_band using "`original'", clear
quietly merge 1:1 id_A id_B using `r', keep(1) nogenerate
quietly count
local n = r(N)

di as text _n "{hline 78}"
di as result "WHAT ARE THE " %6.0f `n' " MISSING PAIRS?"
di as text "{hline 78}"

quietly generate byte blank_f = (trim(f_name_A) == "" | trim(f_name_B) == "")
quietly generate byte blank_l = (trim(l_name_A) == "" | trim(l_name_B) == "")
quietly generate byte blank_any = (blank_f | blank_l)

foreach v in blank_f blank_l blank_any {
    quietly count if `v' == 1
    local c = r(N)
    di as text "  " %-34s "`v'" " : " %8.0fc `c' "  (" %5.1f (100*`c'/`n') "%)"
}

* both sides blank on the same field -- the join could only have been blank-on-blank
quietly count if trim(f_name_A) == "" & trim(f_name_B) == ""
local bf = r(N)
quietly count if trim(l_name_A) == "" & trim(l_name_B) == ""
local bl = r(N)
di as text _n "  first name blank on BOTH sides   : " %8.0fc `bf'
di as text "  last  name blank on BOTH sides   : " %8.0fc `bl'

quietly count if fiveyr_band == 1
di as text _n "  of these, fiveyr_band == 1       : " %8.0fc r(N) ///
   "   (these would enter the table)"

di as text _n "  a sample:"
list f_name_A l_name_A f_name_B l_name_B fiveyr_band in 1/`=min(8,_N)', noobs clean

}   // end vintage loop

di as text _n "{hline 78}"
di as result "DONE"
di as text "{hline 78}"
