local location=`1'
local women_added=`"`2'"' /*"" OR "_women_added"*/

if `location'==1 { /*SERVER AT HOME*/

	local original "D:\Dropbox\enum_date\DATA\ORIGINAL\"
	local f_original "F:\enum_date\DATA\ORIGINAL\"

	local intermediate "D:\Dropbox\enum_date\DATA\INTERMEDIATE\"
	local f_intermediate "F:\enum_date\DATA\INTERMEDIATE\"
	local code "D:\Dropbox\enum_date\CODE\"
	
	local trans_intermediate_f "F:\fixing_transcription_errors\DATA\INTERMEDIATE\"

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
	local code "D:\Dropbox\enum_date\CODE\"	

}


/*
/********/
/*IMPORT*/
/********/
if `"`women_added'"'=="" {

	do `"`code'matching_and_intgen_est\0_import_00394_1850.do"'
	do `"`code'matching_and_intgen_est\0_import_00395_1860.do"'
	do `"`code'matching_and_intgen_est\0_import_00396_1870.do"'
	do `"`code'matching_and_intgen_est\0_import_00445_1880.do"'
	do `"`code'matching_and_intgen_est\0_import_00446_1900.do"'
	do `"`code'matching_and_intgen_est\0_import_00447_1910.do"'
	do `"`code'matching_and_intgen_est\0_import_00448_1920.do"'
	do `"`code'matching_and_intgen_est\0_import_00449_1930.do"'
	do `"`code'matching_and_intgen_est\0_import_00450_1940.do"'

}
else {

	/*
	do `"`code'matching_and_intgen_est\0_import_00648_1850_women_added.do"'
	do `"`code'matching_and_intgen_est\0_import_00649_1860_women_added.do"'
	do `"`code'matching_and_intgen_est\0_import_00650_1870_women_added.do"'
	do `"`code'matching_and_intgen_est\0_import_00651_1880_women_added.do"'
	do `"`code'matching_and_intgen_est\0_import_00652_1900_women_added.do"'
	do `"`code'matching_and_intgen_est\0_import_00653_1910_women_added.do"'
	do `"`code'matching_and_intgen_est\0_import_00654_1920_women_added.do"'
	*/
	
	do `"`code'matching_and_intgen_est\0_import_00655_1930_women_added.do"'
	do `"`code'matching_and_intgen_est\0_import_00656_1940_women_added.do"'

}


/***********************/
/*MERGE AND CLEAN NAMES*/
/***********************/
foreach yr in /*1850 1860 1870 1880 1900 1910 1920*/ 1930 1940 {
	
	use `"`original'matching_intgen`yr'`women_added'.dta"',clear
	
	capture drop namefrst* namelast*
	
	if `yr'==1850|`yr'==1880 {
		replace histid=lower(histid)
	}
	
	merge 1:1 histid using `"`f_intermediate'name_only`yr'.dta"',keepusing(namefrst namelast) keep(1 3) nogen /*THE name_only`yr'.dta IS CREATED IN THE DOFILE clean_data_for_analysis.do*/

	abeclean namefrst namelast,sex(sex) initial(mi) nickname
	
	save `"`original'matching_intgen`yr'`women_added'.dta"',replace
	
}
*/

/******************/
/*DIVIDE THE FILES*/
/******************/
foreach yr in /*1850 1860 1870 1880 1900 1910 1920*/ 1930 1940 {

	use `"`original'matching_intgen`yr'`women_added'.dta"',clear
	
	/*AT THIS POINT WE ARE NOT SUPPOSED TO HAVE THESE VARIABLES THAT ARE OBTAINED FROM SCRAPED FILES*/
	foreach var in namefrst_true_cleaned namefrst_true_nysiis namelast_true_cleaned namelast_true_nysiis true_age true_name_cleaned_exists true_name_nysiis_exists true_age_exists filename row {
		capture drop `var'
	}	
	

	/*CREATE VARIABLES FOR LINKING TO THE NEW TRANSCRIPTION*/
	if `yr'==1940 {
	
		merge 1:1 histid using `"`trans_intermediate_f'ancestry_all`yr'.dta"',keepusing(nararollnumber imagenumber linenumber) keep(1 3) nogen

		tostring nararollnumber imagenumber,gen(temp1 temp2)
		
		foreach n in 1 2 {
		
			replace temp`n'="0"+temp`n' if strlen(temp`n')==4
			replace temp`n'="00"+temp`n' if strlen(temp`n')==3
			replace temp`n'="000"+temp`n' if strlen(temp`n')==2
			replace temp`n'="0000"+temp`n' if strlen(temp`n')==1
			
		}

		gen filename="m-t0627-"+temp1+"-"+temp2	
		
		gen row = linenumber if linenumber <= 40
		replace row = linenumber - 40 if linenumber>=41 & linenumber<=80
		
		drop linenumber nararollnumber imagenumber temp1 temp2
	
		local linking_var="filename row"
	
	}
	else {
	
		local linking_var=""
	
	}

	save `"`original'matching_intgen`yr'`women_added'.dta"',replace
	
	/****************************************************/
	/*OBTAIN THE LIST OF RACE AND RACE-SPECIFIC BPL LIST*/
	/****************************************************/	
	use `"`original'matching_intgen`yr'`women_added'.dta"', clear
	
	if `"`women_added'"'=="" {
	
		keep if sex==1
		
	}
	else {
	
		keep if sex==1|sex==2
	
	}
	
	drop if namefrst_ans_cleaned==""|namelast_ans_cleaned==""
	keep if bpl<900
	keep if race==1|race==2

	levelsof bpl, local(bpl_list)	
	
	capture mkdir `"`f_intermediate'divided_file`yr'`women_added'"'	
	
	foreach b in `bpl_list' {
	
		use namefrst_ans* namelast_ans* age bpl mi histid `linking_var' sex if bpl==`b' using `"`original'matching_intgen`yr'`women_added'.dta"',clear
		drop bpl
		save `"`f_intermediate'divided_file`yr'`women_added'\norace`b'.dta"',replace
	
	}	

}
