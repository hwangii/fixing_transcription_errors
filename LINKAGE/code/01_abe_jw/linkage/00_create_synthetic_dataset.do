drop _all 
clear all

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
if "$LCODE" == "" global LCODE "F:/github_repos/fixing_transcription_errors/LINKAGE/code"
do "$LCODE/shared/paths.do"

* raw_census/ is scratch for the small-scale demo pipeline (stages 01-05 and
* comparison/). Its previous contents are in _archive/; this script regenerates
* them, so create the directory rather than assuming it exists.
capture mkdir "$ABEJW/data/raw_census"

use "$ABE_SRC/matching_intgen1930.dta", clear
keep if statefip == 10
save "$ABEJW/data\raw_census\delaware_1930.dta", replace

*keep if statefip == 42
*save "$ABEJW/data\raw_census\penn_1930.dta", replace

use "$ABE_SRC/matching_intgen1940.dta", clear
keep if statefip == 10
save "$ABEJW/data\raw_census\delaware_1940.dta", replace

*keep if statefip == 42
*save "$ABEJW/data\raw_census\penn_1940.dta", replace
