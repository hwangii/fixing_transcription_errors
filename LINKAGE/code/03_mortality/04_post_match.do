** compare match rates -- oldnames and newnames ** 

drop _all
clear all
set more off 
capture log close
log using $log_dir/post_match.smcl, replace

** Raw match rates **


import delimited using "$bunmd_raw", clear varnames(1)

keep ssn byear sex
keep if sex == 1 & byear <= 1940

* Explicit path. This was -save temp, replace- with no directory, so it landed
* in whatever folder Stata happened to be started from, while
* 05_make_linkage_table.do looks for it at $D_MORT/temp.dta. Nothing in this
* pipeline cd's to $D_MORT, so the two only agreed by accident.
save "$D_MORT/temp.dta", replace


** Get denominator for match rate

use "$D_MORT/temp.dta", clear

summ sex
global denom = r(N)
 
di $denom

drop _all

******************************
** ABE OLD (exact + conservative)

local all_match_files: dir "$match_bunmd_old" files "*.dta"
*di `all_match_files'
local conservative_match_files: dir "$match_bunmd_old" files "*5yr*.dta"
*di `conservative_match_files'

local exact_match_files: list all_match_files - conservative_match_files

*di `exact_match_files'

** Append old matches

local file_num = 0
foreach file of local exact_match_files {
		qui append using ${match_bunmd_old}/`file'
	}

drop if missing(timediff_A) | missing(timediff_B)

summ timediff_A
local num_exact_old = r(N)

di $denom

local match_rate_exact_old = `num_exact_old' / ${denom}
di `match_rate_exact_old'

keep if mi_old_A != "" & mname_B != "" 

summ timediff_A
local validated_sample = r(N)

di `validated_sample'

local share_validated_sample = `validated_sample' / `num_exact_old'
di `share_validated_sample'

keep if lower(mi_old_A) == lower(mname_B)
summ timediff_A
local num_validated = r(N)

local share_validated_old_exact = `num_validated' / `validated_sample' 
di `share_validated_old_exact'

** Append conservative matches

drop _all

local file_num = 0
foreach file of local conservative_match_files {
		qui append using ${match_bunmd_old}/`file'
	}

drop if missing(timediff_A) | missing(timediff_B)

summ timediff_A
local num_conservative_old = r(N)

di $denom

local match_rate_conservative_old = `num_conservative_old' / ${denom}
di `match_rate_conservative_old'

keep if mi_old_A != "" & mname_B != "" 

summ timediff_A
local validated_sample = r(N)

di `validated_sample'

local share_validated_sample = `validated_sample' / `num_conservative_old'
di `share_validated_sample'

keep if lower(mi_old_A) == lower(mname_B)
summ timediff_A
local num_validated = r(N)

local share_validated_old_cons = `num_validated' / `validated_sample' 
di `share_validated_old_cons'
	
******************************
** ABE NEW (exact + conservative)

drop _all

local all_match_files: dir "$match_bunmd_new" files "*.dta"
*di `all_match_files'
local conservative_match_files: dir "$match_bunmd_new" files "*5yr*.dta"
*di `conservative_match_files'

local exact_match_files: list all_match_files - conservative_match_files

*di `exact_match_files'

** Append new matches

local file_num = 0
foreach file of local exact_match_files {
		qui append using ${match_bunmd_new}/`file'
	}

drop if missing(timediff_A) | missing(timediff_B)

summ timediff_A
local num_exact_new = r(N)

di $denom

local match_rate_exact_new = `num_exact_new' / ${denom}
di `match_rate_exact_new'

keep if mi_new_A != "" & mname_B != "" 

summ timediff_A
local validated_sample = r(N)

di `validated_sample'

local share_validated_sample = `validated_sample' / `num_exact_new'
di `share_validated_sample'

keep if lower(mi_new_A) == lower(mname_B)
summ timediff_A
local num_validated = r(N)

local share_validated_new_exact = `num_validated' / `validated_sample' 
di `share_validated_new_exact'

** Append conservative matches

drop _all

local file_num = 0
foreach file of local conservative_match_files {
		qui append using ${match_bunmd_new}/`file'
	}

drop if missing(timediff_A) | missing(timediff_B)

summ timediff_A
local num_conservative_new = r(N)

di $denom

local match_rate_conservative_new = `num_conservative_new' / ${denom}
di `match_rate_conservative_new'

keep if mi_new_A != "" & mname_B != "" 

summ timediff_A
local validated_sample = r(N)

di `validated_sample'

local share_validated_sample = `validated_sample' / `num_conservative_new'
di `share_validated_sample'

keep if lower(mi_new_A) == lower(mname_B)
summ timediff_A
local num_validated = r(N)

local share_validated_new_cons = `num_validated' / `validated_sample'
di `share_validated_new_cons'

******************************
** APPEND AND SAVE FINAL MATCHED FILES

** Old names — exact matches
drop _all
local exact_match_files: dir "$match_bunmd_old" files "ABE_exact_matches_old_*.dta"
local conservative_match_files: dir "$match_bunmd_old" files "*5yr*.dta"
local exact_match_files: list exact_match_files - conservative_match_files
foreach file of local exact_match_files {
	qui append using "$match_bunmd_old/`file'"
}
save "$output_dir/censoc_bunmd_matched_oldnames.dta", replace

** Old names — conservative matches
drop _all
local conservative_match_files: dir "$match_bunmd_old" files "*5yr*.dta"
foreach file of local conservative_match_files {
	qui append using "$match_bunmd_old/`file'"
}
save "$output_dir/censoc_bunmd_matched_oldnames_conservative.dta", replace

** New names — exact matches
drop _all
local exact_match_files: dir "$match_bunmd_new" files "ABE_exact_matches_new_*.dta"
local conservative_match_files: dir "$match_bunmd_new" files "*5yr*.dta"
local exact_match_files: list exact_match_files - conservative_match_files
foreach file of local exact_match_files {
	qui append using "$match_bunmd_new/`file'"
}
save "$output_dir/censoc_bunmd_matched_newnames.dta", replace

** New names — conservative matches
drop _all
local conservative_match_files: dir "$match_bunmd_new" files "*5yr*.dta"
foreach file of local conservative_match_files {
	qui append using "$match_bunmd_new/`file'"
}
save "$output_dir/censoc_bunmd_matched_newnames_conservative.dta", replace

capture log close
