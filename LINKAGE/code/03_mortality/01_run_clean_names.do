* Start logging
capture log close
log using "$log_dir/02_run_clean_names.log", replace text

***********************
* CLEAN CENSUS NAMES
***********************
cap mkdir "$clean_census"

use "$intermediate/1940_census_old_and_new_names.dta", clear

abeclean f_name_old l_name_old, sex(sex) initial(mi_old_cleaned) nicknames nonysiis

abeclean f_name_new l_name_new, sex(sex) initial(mi_new_cleaned) nicknames nonysiis

save "$clean_census/1940_census_cleaned_names", replace

***********************
* CLEAN BUNMD NAMES
***********************

cap mkdir "$clean_bunmd"

import delimited "$bunmd_raw", clear varnames(1)

abeclean fname lname, sex(sex) initial(middle_name_cleaned) nickname nonysiis

* Save cleaned file
save "$clean_bunmd/bunmd_cleaned_names", replace

di "All name cleaning complete."
log close
