clear

local yr_list=`"`1'"'
local interval=`2'
local location=`3'
local reporting_error_only=`4'
local fsnames=`"`5'"' /*A SUFFIX FOR THE OUTPUT FILE NAME ONLY; THE PAPER'S FILES USE "0"*/
/*2026-11-06: THE CENSUS YEARS WHOSE NAMES COME FROM FAMILYSEARCH, AS IN    */
/*2_ABE_matchingV3_master_christian_torben.do. EMPTY = ORIGINAL BEHAVIOUR.  */
local fs_years=`"`6'"'

if `location'==1 { /*SERVER AT HOME*/

	/*2026-11-06: PATHS FROM replication/config.do; D:\Dropbox NO LONGER EXISTS.*/
	if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
	local original "$REP_SNU/enum_date/DATA/ORIGINAL/"
	local f_original "$REP_F/enum_date/DATA/ORIGINAL/"

	local intermediate "$REP_SNU/enum_date/DATA/INTERMEDIATE/"
	local f_intermediate "$REP_F/enum_date/DATA/INTERMEDIATE/"

}
else if `location'==2 { /*DESKTOP AT HOME*/

	local original "C:\Users\ilmyo\Dropbox\enum_date\DATA\ORIGINAL\"
	local f_original "C:\Users\ilmyo\OneDrive\Desktop\enum_date\DATA\ORIGINAL\"

	local intermediate "C:\Users\ilmyo\Dropbox\enum_date\DATA\INTERMEDIATE\"
	local f_intermediate "C:\Users\ilmyo\OneDrive\Desktop\enum_date\DATA\INTERMEDIATE\"

}
else if `location'==3 { /*DAD'S DESKTOP*/

	local original "D:\Dropbox\enum_date\DATA\ORIGINAL\"
	local f_original "D:\enum_date\DATA\ORIGINAL\"

	local intermediate "D:\Dropbox\enum_date\DATA\INTERMEDIATE\"
	local f_intermediate "D:\enum_date\DATA\INTERMEDIATE\"

}

if `reporting_error_only'==1 {
	local filenametag="reporting_error_only"
}
else {
	local filenametag=""
}

/*************************************************************************/
/*FAMILYSEARCH NAMES (2026-11-06). ONE LINK FILE PER RUN, IN THE SAME     */
/*FORMAT AS link<yr1>_<yr2>_{ans,true}_cleaned_noraceblock<suffix>.dta:   */
/*    link<yr1>_<yr2>_fs<years>_cleaned_noraceblock<suffix>.dta           */
/*e.g. link1930_1940_fs1930_1940_cleaned_noraceblock0.dta. THE MIDDLE     */
/*INITIALS ARE EACH SIDE'S OWN (FROM THE DIVIDED FILES THE NAMES WERE     */
/*MATCHED FROM), AS THE ML VERSION DOES FOR 1940. fs_used<yr> MARKS A     */
/*RECORD WHOSE NAME CAME FROM FAMILYSEARCH IN AT LEAST ONE FIELD.         */
/*THE ORIGINAL BRANCH BELOW READS matching_intgen<yr>.dta, WHICH NO LONGER*/
/*EXISTS UNDER THAT NAME; THIS BRANCH DOES NOT NEED IT.                   */
/*************************************************************************/
if `"`fs_years'"'!="" {

	foreach yr1 in `yr_list' {

		local yr2=`yr1'+`interval'
		local typeA "_ans_cleaned"
		local typeB "_ans_cleaned"
		if strpos(`" `fs_years' "', " `yr1' ") local typeA "_fs_cleaned"
		if strpos(`" `fs_years' "', " `yr2' ") local typeB "_fs_cleaned"
		local B_tag ""
		if "`typeB'"!="`typeA'" local B_tag "`typeB'"
		local ver = "_fs" + subinstr(strtrim(stritrim(`"`fs_years'"')), " ", "_", .)

		local rdir `"`f_intermediate'r`typeA'`B_tag'`yr1'_`yr2'"'
		local files : dir `"`rdir'"' files "norace*.dta"
		if `"`files'"'=="" {
			display as error "no link files in `rdir'"
			exit 601
		}

		/*THE BIRTHPLACES THAT CAN HAVE LINKS: THOSE WITH A DIVIDED FILE IN    */
		/*BOTH YEARS. A LINK FILE FOR ANY OTHER BIRTHPLACE IS LEFT OVER FROM AN */
		/*EARLIER RUN, AND STOPS THE APPEND. (A BIRTHPLACE IN BOTH WITH NO FILE */
		/*IS FINE: THE MATCHER ERASES EMPTY OUTPUTS.)                           */
		local Af : dir `"`f_intermediate'divided_file`yr1'`typeA'"' files "norace*.dta"
		local Bf : dir `"`f_intermediate'divided_file`yr2'`typeB'"' files "norace*.dta"
		local AB : list Af & Bf

		tempfile all
		local z=0
		foreach f of local files {

			local b = subinstr(subinstr(`"`f'"',"norace","",1),"`typeA'`B_tag'.dta","",1)
			local fb "norace`b'.dta"
			if !`: list fb in AB' {
				display as error "`rdir'/`f' has no matching divided files in both years: stale output from an earlier run?"
				exit 459
			}
			use id_A id_B fiveyr_band f_name_A l_name_A f_name_B l_name_B using `"`rdir'/`f'"', clear

			/*EACH SIDE'S MIDDLE INITIAL, AND WHETHER ITS NAME CAME FROM      */
			/*FAMILYSEARCH, FROM THE SAME-BIRTHPLACE DIVIDED FILE.            */
			foreach side in A B {
				local y    = cond("`side'"=="A", `yr1', `yr2')
				local type = cond("`side'"=="A", "`typeA'", "`typeB'")
				rename id_`side' id
				if "`type'"=="_fs_cleaned" {
					merge m:1 id using `"`f_intermediate'divided_file`y'`type'/norace`b'.dta"', keepusing(mi fs_frst_used fs_last_used) keep(1 3)
					gen byte fs_used`y' = fs_frst_used==1 | fs_last_used==1
					drop fs_frst_used fs_last_used
				}
				else {
					merge m:1 id using `"`f_intermediate'divided_file`y'`type'/norace`b'.dta"', keepusing(mi) keep(1 3)
				}
				/*EVERY LINKED id CAME FROM THESE FILES.*/
				assert _merge==3
				drop _merge
				rename (id mi) (id_`side' mi`y')
			}

			local ++z
			if `z'>1 append using `all'
			save `all', replace
		}

		save `"`intermediate'link`yr1'_`yr2'`ver'_cleaned_noraceblock`filenametag'`fsnames'.dta"', replace
		display "wrote link`yr1'_`yr2'`ver'_cleaned_noraceblock`filenametag'`fsnames'.dta: " _N " candidate links from `z' birthplace files"
	}
	exit
}

/******************/
/*APPEND ALL LINKS*/
/******************/
foreach yr1 in `yr_list' {

	local yr2=`yr1'+`interval'
	
	use sex race bpl namefrst_ans_cleaned namelast_ans_cleaned using `"`original'matching_intgen`yr1'.dta"',clear

	keep if sex==1
	drop if namefrst_ans_cleaned==""|namelast_ans_cleaned==""
	keep if bpl<900
	keep if race==1|race==2
	
	/*OBTAIN BPL LISTS*/
	levelsof bpl, local(race3_bpl_list)

	foreach linkvar_type in "_cleaned" {

		foreach ver in _ans _true {
			
			/***********************/
			/*WITH RACE NOT BLOCKED*/
			/***********************/			
			local z=0
			local race_str="norace"
			
			foreach b in `race3_bpl_list' {
			
				capture confirm file `"`f_intermediate'r`ver'`linkvar_type'`yr1'_`yr2'\\`race_str'`b'`ver'`linkvar_type'.dta"'
				
				if _rc==0 {
				
					di `"`race_str'"', `b'
				
					local z=`z'+1
					
					if `z'==1 {
						use id_A id_B fiveyr_band f_name_A l_name_A f_name_B l_name_B using `"`f_intermediate'r`ver'`linkvar_type'`yr1'_`yr2'\\`race_str'`b'`ver'`linkvar_type'.dta"',clear
					}
					else {
						append using `"`f_intermediate'r`ver'`linkvar_type'`yr1'_`yr2'\\`race_str'`b'`ver'`linkvar_type'.dta"',keep(id_A id_B fiveyr_band f_name_A l_name_A f_name_B l_name_B)
					}
					
					/*
					/*MERGE INDICATOR FOR IF TRUE NAME/AGE EXISTS*/
					if `yr2'!=1940 {
					
						rename id_A id
						merge 1:1 id using `"`f_intermediate'divided_file`yr1'_true`linkvar_type'\\`race_str'`b'.dta"',keepusing(name_true`linkvar_type'_exists) update keep(1 2 3 4 5)
						rename id id_A
						
					}
					else {
					
						rename id_B id
						merge 1:1 id using `"`f_intermediate'divided_file`yr2'_true`linkvar_type'\\`race_str'`b'.dta"',keepusing(name_true`linkvar_type'_exists) update keep(1 2 3 4 5)
						rename id id_B
					
					}
					
					drop if _merge==2 & name_true`linkvar_type'_exists==. & true_age_exists==.
					drop _merge
					*/
					
				}
			
			}			
			
			/****************************/
			/*MERGE MIDDLE NAME INITIALS*/
			/****************************/			
			rename id_A histid
			merge m:1 histid using `"`original'matching_intgen`yr1'.dta"',keepusing(mi) keep(1 3) nogen
			rename (mi histid id_B) (mi`yr1' id_A histid)
			
			merge m:1 histid using `"`original'matching_intgen`yr2'.dta"',keepusing(mi) keep(1 3) nogen				
			rename (mi histid) (mi`yr2' id_B)
			
			if `"`ver'"'=="_true" & `yr2'==1940 {
			
				rename id_B id
			
				foreach b in `race3_bpl_list' {
			
					capture confirm file `"`f_intermediate'divided_file`yr2'_true`linkvar_type'\\`race_str'`b'.dta"'
					
					if _rc==0 {
			
						merge m:1 id using `"`f_intermediate'divided_file`yr2'_true`linkvar_type'\\`race_str'`b'.dta"',keepusing(mi_true_cleaned name_true`linkvar_type'_exists) update keep(1 3 4 5)
						replace mi`yr2'=mi_true_cleaned if _merge==3|_merge==4|_merge==5
						drop _merge mi_true_cleaned
					
					}
					
				}
			
				rename id id_B
			
			}
			
			save `"`intermediate'link`yr1'_`yr2'`ver'`linkvar_type'_noraceblock`filenametag'`fsnames'.dta"',replace							
			
		}
	}

}
