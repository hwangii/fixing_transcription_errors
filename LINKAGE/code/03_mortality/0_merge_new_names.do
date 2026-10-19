drop _all
clear all
capture log close
log using "$log_dir/merge_names.smcl", replace

********************************************************************************
* Step 1: Append all "old names" aux files into one tempfile
********************************************************************************

local census_files: dir "divided_file1940_ans_cleaned" files "*.dta"
local n_census: word count `census_files'
di "Appending `n_census' old-names files..."

clear
local first = 1
foreach file of local census_files {
    if `first' {
        use id mi *name* using "divided_file1940_ans_cleaned/`file'", clear
        local first = 0
    }
    else {
        append using "divided_file1940_ans_cleaned/`file'", keep(id mi *name*)
    }
}

* gduplicates drop id, force

rename (mi f_name l_name) (mi_old f_name_old l_name_old)
tempfile old_names
save `old_names'

********************************************************************************
* Step 2: Append all "new names" aux files into one tempfile
********************************************************************************
local census_files: dir "divided_file1940_true_cleaned_third_batch" files "*.dta"
local n_census: word count `census_files'
di "Appending `n_census' new-names files..."

clear
local first = 1
foreach file of local census_files {
    if `first' {
        use id mi_true_cleaned f_name l_name name_true_cleaned_exists ///
            using "divided_file1940_true_cleaned_third_batch/`file'", clear
        local first = 0
    }
    else {
        append using "divided_file1940_true_cleaned_third_batch/`file'", ///
            keep(id mi_true_cleaned f_name l_name name_true_cleaned_exists)
    }
}

* gduplicates drop id, force

rename (mi_true_cleaned f_name l_name) (mi_new f_name_new l_name_new)
tempfile new_names
save `new_names'

********************************************************************************
* Step 3: Load main file and do just 2 merges
********************************************************************************
use "$census_raw", clear
rename histid id
drop *name*

* Single merge for old names
merge 1:1 id using `old_names', keep(master match) nogen

* Single merge for new names  
merge 1:1 id using `new_names', keep(master match) nogen

save "$intermediate/1940_census_old_and_new_names.dta", replace
log close
