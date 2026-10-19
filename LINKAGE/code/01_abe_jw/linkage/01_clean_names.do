** Keep only relevant variables for linking 
** -- merge back at the end to create final linked dataset

drop _all
clear all 
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
if "$LCODE" == "" global LCODE "F:/github_repos/fixing_transcription_errors/LINKAGE/code"
do "$LCODE/shared/paths.do"

** Define Locals ** 


cd "$ABEJW"

local a_dataset "$ABEJW/data\raw_census\delaware_1930.dta"

local a_raw_name_vars namefrst_ans namelast_ans 
local a_cleaned_name_vars namefrst_ans_cleaned mi namelast_ans_cleaned
local a_birthplace_vars bpl
local a_id_var histid
local a_age_var birthyr
local a_race_var race
local a_sex_var sex
local a_census_yr 1930

local b_dataset "$ABEJW/data\raw_census\delaware_1940.dta"

local b_raw_name_vars namefrst_ans namelast_ans 
local b_cleaned_name_vars namefrst_ans_cleaned mi namelast_ans_cleaned
local b_birthplace_vars bpl
local b_id_var histid
local b_age_var birthyr
local b_race_var race
local b_sex_var sex
local b_census_yr 1940

cap mkdir "data\clean_names"

** Dataset A ** 

use `a_dataset', clear

	keep `a_id_var' `a_raw_name_vars' `a_cleaned_name_vars' `a_birthplace_vars' ///
		 `a_age_var' `a_race_var' `a_sex_var'
	compress

	gen census_yr = `a_census_yr'
	gen age = census_yr - birthyr

	if "`a_cleaned_name_vars'" == "" {
		abeclean `a_raw_name_vars', sex(`a_sex_var') middle nonysiis
	}

rename (`a_cleaned_name_vars') (f_name_cleaned m l_name_cleaned)
gen first_initial = substr(f_name_cleaned, 1, 1)
gen last_initial = substr(l_name_cleaned, 1, 1)

** Male only ** 
keep if sex == 1
drop sex

save "data\clean_names\clean_names_`a_census_yr'", replace

** Dataset B ** 

use `b_dataset', clear

	keep `b_id_var' `b_raw_name_vars' `b_cleaned_name_vars' `b_birthplace_vars' ///
		 `b_age_var' `b_race_var' `b_sex_var'
	compress

	gen census_yr = `b_census_yr'
	gen age = census_yr - birthyr

	if "`b_cleaned_name_vars'" == "" {
		abeclean `b_raw_name_vars', sex(`b_sex_var') middle nonysiis
	}

rename (`b_cleaned_name_vars') (f_name_cleaned mi l_name_cleaned)
gen first_initial = substr(f_name_cleaned, 1, 1)
gen last_initial = substr(l_name_cleaned, 1, 1)

** Male only ** 
keep if sex == 1
drop sex

save "data\clean_names\clean_names_`b_census_yr'", replace
