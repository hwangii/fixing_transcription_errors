local yr_list=`"`1'"'
local interval=`2'
local location=`3'
/*2026-11-06: THE CENSUS YEARS WHOSE NAMES COME FROM FAMILYSEARCH WHERE IT HAS */
/*THEM (1b_fs_divided_files.do), E.G. "1930", "1940" OR "1930 1940". EMPTY =   */
/*THE ORIGINAL BEHAVIOUR: ANCESTRY (_ans) AND ML (_true) NAMES IN BOTH YEARS.  */
local fs_years=`"`4'"'

if `location'==1 {
	/*2026-11-06: THE CODE LIVES IN THIS REPO (MATCHING/); D:\Dropbox IS GONE.*/
	if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
	local code "$REP_REPO/MATCHING/"
}
else if `location'==2 {
	local code "C:\Users\ilmyo\Dropbox\enum_date\CODE\\matching_and_intgen_est\"
}
else if `location'==3 {
	local code "D:\Dropbox\enum_date\CODE\\matching_and_intgen_est\"
}

foreach yr in `yr_list' {

	local yr1=`yr'
	local yr2=`yr'+`interval'

	if `"`fs_years'"'=="" {

		foreach name_type in "_ans_cleaned" "_true_cleaned" /*"_ans_nysiis" "_true_nysiis"*/ {

			do `"`code'2_ABE_matchingV3_christian_torben.do"' `yr1' `yr2' `"`name_type'"' `location'

		}
	}
	else {

		/*ONE RUN: FAMILYSEARCH NAMES IN THE LISTED YEARS, ANCESTRY OTHERWISE.*/
		local typeA "_ans_cleaned"
		local typeB "_ans_cleaned"
		if strpos(`" `fs_years' "', " `yr1' ") local typeA "_fs_cleaned"
		if strpos(`" `fs_years' "', " `yr2' ") local typeB "_fs_cleaned"
		if "`typeA'"=="_ans_cleaned" & "`typeB'"=="_ans_cleaned" {
			display as error "fs_years (`fs_years') names neither `yr1' nor `yr2'"
			exit 198
		}
		do `"`code'2_ABE_matchingV3_christian_torben.do"' `yr1' `yr2' `"`typeA'"' `location' `"`typeB'"'
	}
}
