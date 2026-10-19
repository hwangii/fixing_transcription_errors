drop _all
clear all
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
if "$LCODE" == "" global LCODE "F:/github_repos/fixing_transcription_errors/LINKAGE/code"
do "$LCODE/shared/paths.do"

cd "$ABEJW"

global output_dir "data\matched\"
global clean_dir "data\clean_names\"

use ${clean_dir}clean_names_1930.dta
keep if !missing(bpl, age, f_name_cleaned, l_name_cleaned, race)

qui summ bpl
local n_denom = r(N)
di "`n_denom'"

use ${output_dir}JW_matches_x0_unique.dta, clear
qui summ unique_both_0
local n_num = r(N)
di "`n_num'"

local match_rate = `n_num' / `n_denom' * 100
di %9.2f `match_rate'
