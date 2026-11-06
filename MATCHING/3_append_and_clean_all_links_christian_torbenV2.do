clear

local yr_list=`"`1'"'
local interval=`2'
local location=`3'
local reporting_error_only=`4'
local fsnames=`"`5'"'

if `location'==1 { /*SERVER AT HOME*/

	local original "D:\Dropbox\enum_date\DATA\ORIGINAL\"
	local f_original "F:\enum_date\DATA\ORIGINAL\"

	local intermediate "D:\Dropbox\enum_date\DATA\INTERMEDIATE\"
	local f_intermediate "F:\enum_date\DATA\INTERMEDIATE\"

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
