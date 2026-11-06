local yr_list=`"`1'"'
local interval=`2'
local location=`3'
local women_added=`"`4'"' /*"" OR "_women_added"*/
local reporting_error_only=`5'
local fsnames=`"`6'"' /*SUFFIX FOR THE LINK FILE NAMES; THE PAPER'S FILES USE "0"*/
/*2026-11-06: THE CENSUS YEARS WHOSE NAMES COME FROM FAMILYSEARCH WHERE IT   */
/*HAS THEM, E.G. "1930", "1940" OR "1930 1940". EMPTY = THE ORIGINAL RUN.    */
/*FAMILYSEARCH RUN, 1930-1940, MEN, SAME RECORDS AS THE PAPER'S ABE LINKS:   */
/*  do MATCHING/_matching_master_dofile.do "1930" 10 1 "" 0 0 "1930 1940"    */
local fs_years=`"`7'"'


if `location'==1 { /*SERVER AT HOME*/

	//local code "D:\Dropbox\enum_date\CODE\matching_and_intgen_est\"
	//local code "C:\Users\munir_and_sam\SNU ECON Dropbox\sam hwang\enum_date\CODE\matching_and_intgen_est\"
	/*2026-11-06: THE CODE NOW LIVES IN THIS REPO.*/
	if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
	local code "$REP_REPO/MATCHING/"
	
	//local original "D:\Dropbox\enum_date\DATA\ORIGINAL\"
	local original "C:\Users\munir_and_sam\SNU ECON Dropbox\sam hwang\enum_date\DATA\ORIGINAL\"
	
	local f_original "F:\enum_date\DATA\ORIGINAL\"

	//local intermediate "D:\Dropbox\enum_date\DATA\INTERMEDIATE\"
	local intermediate "C:\Users\munir_and_sam\SNU ECON Dropbox\sam hwang\DATA\INTERMEDIATE\"
	
	local f_intermediate "F:\enum_date\DATA\INTERMEDIATE\"

}
else if `location'==2 { /*DESKTOP AT HOME*/

	local code "C:\Users\ilmyo\Dropbox\enum_date\CODE\matching_and_intgen_est\"

	local original "C:\Users\ilmyo\Dropbox\enum_date\DATA\ORIGINAL\"
	local f_original "C:\Users\ilmyo\OneDrive\Desktop\enum_date\DATA\ORIGINAL\"

	local intermediate "C:\Users\ilmyo\Dropbox\enum_date\DATA\INTERMEDIATE\"
	local f_intermediate "C:\Users\ilmyo\OneDrive\Desktop\enum_date\DATA\INTERMEDIATE\"

}
else if `location'==3 { /*DAD'S DESKTOP*/

	local code "D:\Dropbox\enum_date\CODE\matching_and_intgen_est\"

	local original "D:\Dropbox\enum_date\DATA\ORIGINAL\"
	local f_original "D:\enum_date\DATA\ORIGINAL\"

	local intermediate "D:\Dropbox\enum_date\DATA\INTERMEDIATE\"
	local f_intermediate "D:\enum_date\DATA\INTERMEDIATE\"

}


/*2026-11-06: FAMILYSEARCH RUN. IT REUSES THE EXISTING MEN-ONLY ANCESTRY     */
/*DIVIDED FILES (THE RECORDS BEHIND THE PAPER'S ABE EXACT-NAME LINKS), SO    */
/*STEPS 0 AND 1 BELOW ARE SKIPPED: BUILD THE FAMILYSEARCH NAME FILES, SWAP   */
/*THEM INTO THE DIVIDED FILES, MATCH, APPEND, AND STOP.                      */
if `"`fs_years'"'!="" {

	if `"`women_added'"'!="" {
		display as error "the FamilySearch run is men only: leave women_added empty"
		exit 198
	}
	if `location'!=1 {
		display as error "the FamilySearch run is set up for machine A only (location 1)"
		exit 198
	}
	/*EACH YEAR'S FAMILYSEARCH FILES ARE BUILT ONCE AND REUSED BY LATER RUNS */
	/*(E.G. "1930", THEN "1940", THEN "1930 1940"). DELETE fs_names<yr>.dta */
	/*AND divided_file<yr>_fs_cleaned TO REBUILD THEM.                      */
	local fsdir "$REP_F/enum_date/DATA/INTERMEDIATE/"
	foreach y of local fs_years {
		capture confirm file `"`fsdir'fs_names`y'.dta"'
		if _rc do `"`code'0b_create_fs_names.do"' `y'
		else display "fs_names`y'.dta exists: reused"
		/*REUSED ONLY IF IT HAS EXACTLY THE ANCESTRY FOLDER'S FILES, SO A   */
		/*PARTLY BUILT FOLDER (AN INTERRUPTED RUN) IS REBUILT, NOT REUSED.  */
		local built : dir `"`fsdir'divided_file`y'_fs_cleaned"' files "norace*.dta"
		local want  : dir `"`fsdir'divided_file`y'_ans_cleaned"' files "norace*.dta"
		local built : list sort built
		local want  : list sort want
		if `"`built'"'!=`"`want'"' do `"`code'1b_fs_divided_files.do"' `y'
		else display "divided_file`y'_fs_cleaned complete: reused"
	}
	foreach yr in `yr_list' {
		do `"`code'2_ABE_matchingV3_master_christian_torben.do"' `yr' `interval' `location' `"`fs_years'"'
		do `"`code'3_append_and_clean_all_links_christian_torbenV2.do"' `yr' `interval' `location' `reporting_error_only' `"`fsnames'"' `"`fs_years'"'
	}
	exit
}

//do `"`code'0_create_file_for_matching_intgenV3.do"' `location'

//do `"`code'0_create_file_for_matching_intgenV4_women_added.do"' `location' `"`women_added'"'

foreach yr1 in /*1850 1860 1870 1880 1900 1910 1920 1930*/ 1940 {

	//do `"`code'1_divide_and_clean_everyoneV5_server_christian_torben.do"' `yr1' `location' `reporting_error_only' `"`fsnames'"'
	//do `"`code'1_divide_and_clean_everyoneV5_server_mortality_schedule.do"' `yr1' `location'
	//do `"`code'1_divide_and_clean_everyoneV5_server_nber.do"' `yr1' `location' `reporting_error_only' `"`fsnames'"'
	//do `"`code'1_divide_and_clean_everyoneV5_server_ssha2025.do"' `yr1' `location'

	do `"`code'1_divide_and_clean_everyoneV5_women_addedV2.do"' `yr1' `location' `"`women_added'"'

}

if `"`women_added'"'=="" {

	foreach yr in `yr_list' {

		//do `"`code'2_ABE_matchingV3_master.do"' `yr' `interval' `location'
		
		//do `"`code'3_append_and_clean_all_links.do"' `yr' `interval' `location' `reporting_error_only'
		//do `"`code'3_append_and_clean_all_links_christian_torben.do"' `yr' `interval' `location' `reporting_error_only' `"`fsnames'"'
		//do `"`code'3_append_and_clean_all_links_mortality_schedule.do"' `yr' `interval' `location' `reporting_error_only'	

		
		do `"`code'2_ABE_matchingV3_master_christian_torben.do"' `yr' `interval' `location'
		do `"`code'3_append_and_clean_all_links_christian_torbenV2.do"' `yr' `interval' `location' `reporting_error_only' `"`fsnames'"'

		
	}

}
