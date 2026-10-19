* Source census extract. Was hardcoded to D:/ABE_JW/DATA/ORIGINAL; that file is
* now inside the package and reached through $ABE_SRC (see code/shared/paths.do).
use serial namelast_ans namefrst_ans birthyr bpl sex histid age race using "$ABE_SRC/matching_intgen1940", clear
merge 1:1 histid using  "$D_CENSUS/marriage_status_1940.dta"

keep if _merge == 3
drop _merge
save "$D_CENSUS/1940_census_for_merge_with_bunmd", replace
