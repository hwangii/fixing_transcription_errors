local yr_list=`"`1'"'
local interval=`2'
local location=`3'
local women_added=`"`4'"' /*"" OR "_women_added"*/
local reporting_error_only=`5'
local fsnames=`"`6'"'


if `location'==1 { /*SERVER AT HOME*/

	//local code "D:\Dropbox\enum_date\CODE\matching_and_intgen_est\"
	local code "C:\Users\munir_and_sam\SNU ECON Dropbox\sam hwang\enum_date\CODE\matching_and_intgen_est\"
	
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
