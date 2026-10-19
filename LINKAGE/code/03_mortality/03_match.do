** Run Match -- Oldnames** 

local prefix_old "abe_exact_matches_old_"
local existing_files: dir "$match_bunmd_old" files "*.dta"

di `existing_files'

local existing_files_cleaned ""
foreach f of local existing_files {
    local existing_files_cleaned "`existing_files_cleaned' `=subinstr("`f'", "`prefix_old'", "", 1)'"
}

di "`existing_files_cleaned'"

local census_files: dir "$split_census" files "*.dta"
local remaining_files_old: list census_files - existing_files_cleaned

di `remaining_files_old'

local n_census: word count `remaining_files_old'
di "Matching `n_census' census files..."

local file_num = 0
foreach file of local remaining_files_old {
    local ++file_num
    di "Matching census file `file_num'/`n_census': `file'"

	global A "${split_census}/`file'"
	di "$A"
	global B "${split_bunmd}/`file'"
	di "$B"
	
	local file_cleaned: subinstr local file " " "_", all
	di "`file_cleaned'"
	
	local outputfile_oldnames "${match_bunmd_old}/ABE_exact_matches_old_`file_cleaned'"  // file name to save matched data 
	local outputfile_no_dta_oldnames = subinstr("`outputfile_oldnames'", ".dta", "", .)
	
	if fileexists("$A") & fileexists("$B"){
	
		/* Workaround for using one file with multiple names to match on */

		use "$A", clear

		rename f_name_old_cleaned fname_cleaned
		rename l_name_old_cleaned lname_cleaned

		rename age census_age

		tempfile temp_A
		save `temp_A', replace

		/* Find ABE matches, standard version */

		clear
		abematch $match_vars,  file_A("`temp_A'") file_B("$B") ///
			timevar(census_age) timediff($timediff ) save(`outputfile_oldnames')  ///
			replace id_A(id) id_B(ssn) unique_m(2) unique_f(2) ///
			keep_A(l_name_old mi_old f_name_old) keep_B(fname mname lname) 
			
		rename census_age age_1940

		/* ABE matches, conservative version */

		keep if unique_file2 == 1  // keep only names unique within +- 2 years in own data sets
		keep if unique_match2 == 1 // drop people that have another potential match within +-2 years of birth

		save "`outputfile_no_dta_oldnames'_5yr_band.dta", replace
				
		erase `temp_A'
		}
}

** Run Match -- Newnames ** 

local prefix_new "abe_exact_matches_new_"
local existing_files_cleaned: dir "$match_bunmd_new" files "*.dta"

di `existing_files'

local existing_files_cleaned ""
foreach f of local existing_files {
    local existing_files_cleaned "`existing_files_cleaned' `=subinstr("`f'", "`prefix_new'", "", 1)'"
}

di "`existing_files_cleaned'"

local census_files: dir "$split_census" files "*.dta"
local remaining_files_new: list census_files - existing_files_cleaned

di `remaining_files_new'

local n_census: word count `remaining_files_new'
di "Matching `n_census' census files..."


local file_num = 0
foreach file of local census_files {
    local ++file_num
    di "Matching census file `file_num'/`n_census': `file'"

	global A "${split_census}/`file'"
	di "$A"
	global B "${split_bunmd}/`file'"
	di "$B"
	
	local file_cleaned: subinstr local file " " "_", all
	di "`file_cleaned'"
	
	local outputfile_newnames "${match_bunmd_new}/ABE_exact_matches_new_`file_cleaned'"  // file name to save matched data 
	local outputfile_no_dta_newnames = subinstr("`outputfile_newnames'", ".dta", "", .)
		
	if fileexists("$A") & fileexists("$B"){
	
		/* Workaround for using one file with multiple names to match on */

		use "$A", clear
		
		rename f_name_new_cleaned fname_cleaned
		rename l_name_new_cleaned lname_cleaned

		rename age census_age

		tempfile temp_A
		save `temp_A', replace

		/* Find ABE matches, standard version */

		clear
		abematch $match_vars,  file_A("`temp_A'") file_B("$B") ///
			timevar(census_age) timediff($timediff ) save(`outputfile_newnames')  ///
			replace id_A(id) id_B(ssn) unique_m(2) unique_f(2) ///
			keep_A(l_name_new mi_new f_name_new) keep_B(fname mname lname) 
			
		rename census_age age_1940

		/* ABE matches, conservative version */

		keep if unique_file2 == 1  // keep only names unique within +- 2 years in own data sets
		keep if unique_match2 == 1 // drop people that have another potential match within +-2 years of birth

		save "`outputfile_no_dta_newnames'_5yr_band.dta", replace
				
		erase `temp_A'
		}
}
