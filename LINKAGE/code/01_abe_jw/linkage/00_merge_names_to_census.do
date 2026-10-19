
drop _all
clear all
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
if "$LCODE" == "" global LCODE "F:/github_repos/fixing_transcription_errors/LINKAGE/code"
do "$LCODE/shared/paths.do"


local a_dataset "$ABE_SRC/matching_intgen1930.dta"
local a_old_names_dir "$ABEJW/data\full_census\names\divided_file1930_ans_cleaned"

local a_raw_name_vars namefrst_ans namelast_ans 
local a_cleaned_name_vars namefrst_ans_cleaned mi namelast_ans_cleaned
local a_birthplace_vars bpl
local a_id_var histid
local a_age_var birthyr
local a_race_var race
local a_sex_var sex
local a_census_yr 1930

local b_dataset "$ABE_SRC/matching_intgen1940.dta"

local b_old_names_dir "$ABEJW/data\full_census\names\divided_file1940_ans_cleaned"
local b_new_names_dir "$ABEJW/data\full_census\names\divided_file1940_true_cleaned"
local b_raw_name_vars namefrst_ans namelast_ans 
local b_cleaned_name_vars namefrst_ans_cleaned mi namelast_ans_cleaned
local b_birthplace_vars bpl
local b_id_var histid
local b_age_var birthyr
local b_race_var race
local b_sex_var sex
local b_census_yr 1940

** Dataset A OLD ** 

local files : dir "`a_old_names_dir'" files "*.dta"
foreach file in `files' {
	append using "`a_old_names_dir'/`file'"
}

cap rename id histid 
merge 1:1 histid using `a_dataset', keepusing(`a_id_var' `a_birthplace_vars' `a_age_var' `a_race_var' `a_sex_var')
keep if _merge == 3
drop _merge

* Step 0's products are the canonical cleaned-name files. They live in
* data/names/cleaned/ -- the same copies the table scripts read -- rather than in a
* separate abe_jw/data/clean_names/ tree, which used to hold a second 21 GB
* copy of exactly these files.
save "$D_NAMES/clean_names_1930_old", replace

** Dataset B OLD ** 

clear

local files : dir "`b_old_names_dir'" files "*.dta"
foreach file in `files' {
	append using "`b_old_names_dir'/`file'"
}


cap rename id histid 
merge 1:1 histid using `b_dataset', keepusing(`b_id_var' `b_birthplace_vars' `b_age_var' `b_race_var' `b_sex_var')
keep if _merge == 3
drop _merge

save "$D_NAMES/clean_names_1940_old", replace

** Dataset B NEW ** 
clear

local files : dir "`b_new_names_dir'" files "*.dta"
foreach file in `files' {
	append using "`b_new_names_dir'/`file'"
}

cap rename id histid 
merge 1:1 histid using `b_dataset', keepusing(`b_id_var' `b_birthplace_vars' `b_age_var' `b_race_var' `b_sex_var')
keep if _merge == 3
drop _merge

drop name_true_cleaned_exists
rename mi_true_cleaned mi

save "$D_NAMES/clean_names_1940_new", replace
