/*****************************************************************/
/*THIS DOFILE IS MODIFICATION OF 10_compare_AN_with_FS_sheetno.do*/
/*****************************************************************/
clear
#delimit;
local code "D:\test_selection_on_unobservable\CODE\";
local original "D:\Dropbox\test_selection_on_unobservable\DATA\ORIGINAL\";
local original_ext "F:\test_selection_on_unobservable\DATA\ORIGINAL\";
local original_logan "D:\Dropbox\test_selection_on_unobservable\DATA\ORIGINAL\cleaned_streets_urban_transition\";
local original_db "D:\Dropbox\test_selection_on_unobservable\DATA\ORIGINAL\familysearch\";
local original_db2 "D:\Dropbox\test_selection_on_unobservable\DATA\ORIGINAL\";
local intermediate_db "D:\Dropbox\test_selection_on_unobservable\DATA\INTERMEDIATE\";
local intermediate_ext "E:\test_selection_on_unobservable_seagate\DATA\INTERMEDIATE\";
local trans_original "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\";
local code_trans "D:\Dropbox\fixing_transcription_errors\CODE\";
local telegram "C:\Users\suntr\Downloads\Telegram Desktop\";
local trans_intermediate_f "F:\fixing_transcription_errors\DATA\INTERMEDIATE\";
local census1940_folder "F:\updated_census_recvd_aug2021\";
local original "F:\updated_census_recvd_aug2021\ubc_1940_3-4\1940_3-4\";

local full_stlist `" "Alabama" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "District of Columbia" "Florida" "Georgia"
 "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" 
 "Missouri" "Montana" "Nebraska" "Nevada" "New Hampshire" "New Jersey" "New Mexico" "New York" "North Carolina" "North Dakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" 
 "Rhode Island" "South Carolina" "South Dakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" 
 "Washington" "West Virginia" "Wisconsin" "Wyoming" "';


 /*
/***************************/
/*IMPORT FAMILYSEARCH FILES*/
/***************************/ 
foreach curstatestr in `full_stlist' {;

	do `"`code_trans'convert_state_name_to_file_name.do"' `"`curstatestr'"';
	
	local scraper_ass_num=$scraper_ass_num;	
	local state_file_name="$state_file_name";

	capture import delimited `"`original_ext'\\[#`scraper_ass_num'] `curstatestr'.csv"',clear bindquote(strict) varnames(1) stripquote(yes) encoding(utf8);
	
	//keep censuscounty eventdistrict narapublicationnumber nararollnumber imagenumber linenumber firstname lastname age birthplace linenumber sheetnumberletter;
	
	drop relationshiptoheadcode relationshiptohead eventplacelowestlevel censustownshiporothercivildivisi censusplace sheetnumber sheetletter previousresidencestate
	previousresidencecounty previousresidencecity minorcivildivision eventplacelowestlevel ededdescription eddescription city;
	
	do `"`code_trans'convert_state_name_to_statefip"' `"`curstatestr'"';
	
	//bysort nararollnumber imagenumber linenumber: keep if _N==1;
	
	save `"`trans_intermediate_f'familysearch_`state_file_name'.dta"',replace;
	
};


/**************************/
/*CLEAN FAMILYSEARCH FILES*/
/**************************/
foreach curstatestr in `full_stlist' {;

	qui do `"`code_trans'convert_state_name_to_file_name.do"' `"`curstatestr'"';
	
	local state_file_name="$state_file_name";

	use uniqueidentifier firstname lastname age birthplace nararollnumber imagenumber linenumber censuscounty eventdistrict sheetnumberletter using `"`trans_intermediate_f'familysearch_`state_file_name'.dta"',clear;
	
	foreach var in nararollnumber imagenumber linenumber {;
		capture drop if real(`var')==.;
	};
	
	destring nararollnumber imagenumber linenumber,replace;
	
	bysort nararollnumber imagenumber linenumber firstname lastname age birthplace: keep if _n==1;
	
	bysort nararollnumber imagenumber linenumber: keep if _N==1;
	
	rename (firstname lastname age birthplace) (namefrst_fs namelast_fs age_fs bpl_str_fs);
	
	capture replace age_fs="" if real(age_fs)==.;
	capture destring age_fs,replace;
	
	save `"`trans_intermediate_f'familysearch_`state_file_name'_cleaned.dta"',replace;
	
};


/**********************************/
/*MERGE ANCESTRY WITH FAMILYSEARCH*/
/**********************************/
foreach curstatestr in `full_stlist' {;

	qui do `"`code_trans'convert_state_name_to_file_name.do"' `"`curstatestr'"';
	local state_file_name="$state_file_name";

	use `"`trans_intermediate_f'ancestry_`state_file_name'1940.dta"',clear;
	
	/*IDENTIFY NON-DITTOS*/
	/*_n IS NON-DITTO IF YOUR LAST NAME IS DIFFERENT FROM _n-1*/
	gsort nararollnumber imagenumber linenumber;
	
	gen non_ditto=1 if namelast[_n]!=namelast[_n-1];
	
	merge 1:1 nararollnumber imagenumber linenumber using `"`trans_intermediate_f'familysearch_`state_file_name'_cleaned.dta"',keepusing(uniqueidentifier namefrst_fs namelast_fs age_fs bpl_str_fs censuscounty eventdistrict sheetnumberletter) update keep(1 2 3 4 5);
	
	save `"`trans_intermediate_f'merged_`state_file_name'1940.dta"',replace;

};
*/


/*
/**************************************************************/
/*NOT SURE IF WE WILL HAVE THE STUFF ABOUT BLACKS IN THE PAPER*/
/**************************************************************/
/***********************************************************/
/*CLEAN AND KEEP ONLY THE BLACK ENUMERATION DISTRICT SAMPLE*/
/***********************************************************/
#delimit cr
local z=0

foreach curstatestr in `full_stlist' {

	qui do `"`code_trans'convert_state_name_to_file_name.do"' `"`curstatestr'"'
	local state_file_name="$state_file_name"
	
	use `"`trans_intermediate_f'merged_`state_file_name'1940.dta"',clear
	
	keep if _merge==3
	
	keep histid uniqueidentifier namefrst namelast namefrst_fs namelast_fs age age_fs statefip countyicp edist censuscounty nararollnumber imagenumber linenumber serial pernum non_ditto
	rename edist eventdistrict

	/*CLEAN NAMES*/
	foreach var in namefrst namelast namefrst_fs namelast_fs {

	replace `var'=lower(`var')
	
	}	

	/*CONSTRUCT VARIABLES THAT IDENTIFY THE LOCATION OF THE IMAGE FILES*/
	gen state_folder_name=subinstr(lower(`"`curstatestr'"')," ","-",.)
	
	gen county_folder_name=lower(censuscounty)+"-county";
	
	tostring nararollnumber imagenumber,gen(temp1 temp2)
	
	foreach n in 1 2 {
	
		replace temp`n'="0"+temp`n' if strlen(temp`n')==4
		replace temp`n'="00"+temp`n' if strlen(temp`n')==3
		replace temp`n'="000"+temp`n' if strlen(temp`n')==2
		replace temp`n'="0000"+temp`n' if strlen(temp`n')==1
		
	}
	
	gen imagenumber_combined="m-t0627-"+temp1+"-"+temp2
	
	drop temp1 temp2
	
	merge m:1 statefip countyicp eventdistrict using `"`trans_original'sampled_edist_for_nber_0929_2024.dta"',keep(3) nogen keepusing(statefip countyicp eventdistrict)

	if _N>0 {
	
		local z=`z'+1
		
		if `z'>1 {
		
			append using `"`trans_original'sampled_edist_for_nber_0929_2024_training_data_fixed.dta"'
		
		}
	
		save `"`trans_original'sampled_edist_for_nber_0929_2024_training_data_fixed.dta"',replace
	
	}

}
*/


/*
/***************************************************/
/*COMBINE ALL THE LABELED DATA ACROSS STATES (1940)*/
/***************************************************/
#delimit cr
local z=0

foreach curstatestr in `full_stlist' {

	qui do `"`code_trans'convert_state_name_to_file_name.do"' `"`curstatestr'"'
	local state_file_name="$state_file_name"
	
	use `"`trans_intermediate_f'merged_`state_file_name'1940.dta"',clear
	
	keep if _merge==3
	
	keep histid uniqueidentifier namefrst namelast namefrst_fs namelast_fs age age_fs statefip countyicp edist censuscounty nararollnumber imagenumber linenumber serial pernum non_ditto
	rename edist eventdistrict

	/*CLEAN NAMES*/
	foreach var in namefrst namelast namefrst_fs namelast_fs {

		replace `var'=lower(`var')
	
	}	

	/*CONSTRUCT VARIABLES THAT IDENTIFY THE LOCATION OF THE IMAGE FILES*/
	gen state_folder_name=subinstr(lower(`"`curstatestr'"')," ","-",.)
	
	gen county_folder_name=lower(censuscounty)+"-county";
	
	tostring nararollnumber imagenumber,gen(temp1 temp2)
	
	foreach n in 1 2 {
	
		replace temp`n'="0"+temp`n' if strlen(temp`n')==4
		replace temp`n'="00"+temp`n' if strlen(temp`n')==3
		replace temp`n'="000"+temp`n' if strlen(temp`n')==2
		replace temp`n'="0000"+temp`n' if strlen(temp`n')==1
		
	}
	
	gen imagenumber_combined="m-t0627-"+temp1+"-"+temp2
	
	drop temp1 temp2
	
	keep if namelast!="" & namefrst!="" & namefrst_fs!="" & namelast_fs!="" & age!=. & age_fs!=.			

	if _N>0 {
	
		local z=`z'+1
		
		if `z'>1 {
		
			append using `"`trans_original'census1940_all_labeled_data.dta"'
		
		}
	
		save `"`trans_original'census1940_all_labeled_data.dta"',replace
	
	}

}
*/


/***************************************************/
/*CREATE COUNTY-LEVEL HEATMAP OF SHARE DISAGREEMENT*/
/***************************************************/
#delimit cr
use `"`trans_original'census1940_all_labeled_data.dta"', clear

gen disagree=namelast!=namelast_fs|namefrst!=namefrst_fs

collapse (mean) sh_disagreement=disagree (count) N=disagree,by(statefip countyicp)

/*NEED TO CONVERT COUNTYICP TO COUNTYFIP (SEE https://usa.ipums.org/usa-action/variables/COUNTYICP#codes_section)*/
gen countyfip = floor(countyicp / 10)

* Maryland correction: statefip == 24
replace countyfip = countyfip + 2 if statefip == 24 & countyfip >= 7 & countyfip != 51

* Nevada corrections: statefip == 32
replace countyfip = 27 if statefip == 32 & countyicp == 250  // Pershing
replace countyfip = 25 if statefip == 32 & countyicp == 510  // Ormsby
replace countyfip = 27 if statefip == 32 & countyicp == 270  // Rio Virgin (historical)

* Create full 5-digit FIPS code
gen FIPS = string(statefip, "%02.0f") + string(countyfip, "%03.0f")

save `"`trans_original'census1940_for_maps.dta"', replace
export delimited using `"`trans_intermediate_f'sh_disagreement1940.csv"', replace
