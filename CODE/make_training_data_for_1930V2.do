clear

local cendir "F:\updated_census_recvd_aug2021\ubc_1930_3-5\1930_3-5\"
local trans_original "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\"
local trans_original_f "F:\fixing_transcription_errors\DATA\ORIGINAL\"
local cenorig "F:\sshrc_idg_mortality\DATA\ORIGINAL\familysearch_census1930\"

set more off

/*
/********************************/
/*IMPORT AND CLEAN ANCESTRY DATA*/
/********************************/
/***********/
/*HOUSEHOLD*/
/***********/
clear
quietly infix                             ///
  str     rectype              1-1        ///
  double  serial               12-19      ///
  byte    statefip             41-42      ///
  int     countyicp            1139-1142  ///
  int     reel                 1806-1809  ///
  double  enumdist             1846-1854  ///  
  using `"`cendir'us1930d_usa_res.dat"'
gen  _line_num = _n
drop if rectype != `"H"'
sort _line_num
drop rectype _line_num

save `"`cendir'nber_training_data1930_H.dta"',replace



/*********************************************************************************************************************/
/*********************************************************************************************************************/
/*********************************************************************************************************************/
clear
quietly infix                             ///
  str     rectype              1-1        ///
  double  serialp              12-19      ///
  int     pernum               20-23      ///
  int     age                  58-60      ///  
  str     namelast             1697-1712  ///
  str     namefrst             1713-1728  ///
  str     histid               2331-2366  ///
  str     us1930d_1056         3599-3602  ///  
  str     us1930d_1057         3603-3605  ///
  using `"`cendir'us1930d_usa_res.dat"'
drop if rectype != `"P"'
drop rectype

destring us1930d_1056 us1930d_1057,replace

rename serialp serial

merge m:1 serial using `"`cendir'nber_training_data1930_H.dta"',keep(3) nogen

rename (reel us1930d_1056 us1930d_1057) (nararollnumber imagenumber linenumber)

gsort nararollnumber imagenumber linenumber

gen non_ditto=1 if namelast[_n]!=namelast[_n-1]

bysort histid: keep if _N==1

keep histid namefrst namelast serial pernum non_ditto nararollnumber imagenumber linenumber statefip countyicp age enumdist

save `"`trans_original'ancestry_all1930.dta"',replace
*/

/********************************************/
/*IMPORT 1930 FAMILYSEARCH DATA AND CLEAN IT*/
/********************************************/
/*IMPORT IMAGE FILE*/
import delimited `"`cenorig'Export - Images - 1.csv"', bindquote(strict) varnames(1) stripquote(yes) encoding(utf8) clear
save `"`cenorig'images.dta"', replace

forvalues k=1/126 {

	import delimited `"`cenorig'Export - Persons - `k'.csv"', bindquote(strict) varnames(1) stripquote(yes) encoding(utf8) clear
	
	foreach muni in state county township {
		
		replace event_`muni'_orig=event_`muni' if event_`muni'_orig=="" & event_`muni'!=""
		drop event_`muni'
		
	}
	
	save `"`cenorig'p`k'.dta"',replace
	
}



/*
/*******************/
/*RHODE ISLAND ONLY*/
/*******************/
local z=0

forvalues k=1/126 {
//forvalues k=1/1 {

	di `k'

	use `"`cenorig'p`k'.dta"', clear
	
	#delimit;
	
		keep image_ark_id person_ark_id
		pr_age pr_age_orig 
		pr_name_pre_1 pr_name_pre_orig_1 
		pr_name_gn_1 pr_name_gn_orig_1
		pr_name_surn_1 pr_name_surn_orig_1 
		pr_name_suf_1 pr_name_suf_orig_1
		displayname;
	
	#delimit cr
	
	//tostring _all, replace
	
	foreach nt in pre gn surn suf {
		replace pr_name_`nt'`type'_1=lower(pr_name_`nt'`type'_1)
	}	
	
	/*
	#delimit;
	
		drop event_district_enumeration_nbr_o pr_name_matr_orig_1 event_division_civil_minor_orig 
		event_address_orig event_neighborhood event_populated event_range_orig  event_ward_orig event_commune 
		event_commune_orig event_dependency event_incorporated_place event_sub_district event_ward event_ward_district_orig
		event_date_orig source_house_nbr_orig pr_bir_borough pr_bir_county_top pr_bir_dependency pr_bir_district pr_bir_neighborhood
		pr_bir_province pr_bir_region pr_bir_township pr_bir_village pr_bir_parish pr_res_event_type pr_occupation_code_orig
		pr_flag_can_read_orig pr_flag_can_write_orig pr_flag_own_or_rent_orig pr_dea_event_type pr_dea_date pr_dea_place_orig
		misc_home_value_orig misc_worker_class_orig misc_flag_attended_school_orig misc_flag_can_read_english_orig
		misc_flag_can_speak_english_orig misc_flag_can_write_english_orig misc_flag_veteran_orig misc_flag_employed_orig pr_arr_event_type;
		
	#delimit cr
	*/
	
	merge m:1 image_ark_id using `"`cenorig'images.dta"',keepusing(state_name county_name township_name enumeration_district_name) keep(1 3) 


	/*NAMES HAVE TWO VERSIONS*/
	foreach type in "" "_orig" {

		/*MAKE ALL NAMES LOWER CASE*/
		foreach nt in pre gn surn suf {
			replace pr_name_`nt'`type'_1=lower(pr_name_`nt'`type'_1)
		}

		/*FIX THE REPEATED PREFIX*/
		foreach rep in "dr" "miss" "mr" "mrs" "mrs." "rev" "doctor" "dr." "madame" "master" "mistress" "mme" "mr." "ms" "ms." "rev." "reverend" {

			replace pr_name_pre`type'_1=`"`rep'"' if pr_name_pre`type'_1==`"`rep', `rep'"'|pr_name_pre`type'_1==`"`rep'., `rep'"'|pr_name_pre`type'_1==`"`rep', `rep'."'
			
			//gen repeated=strpos(displayname,`"`rep', `rep' "')
			//local str_length=strlen(`"`rep', `rep' "')
			//replace displayname=`"`rep' "'+ substr(displayname,(`str_length'+1),strlen(displayname)-`str_length') if repeated>=1 & repeated!=.
			//drop repeated	
			
		}	  
		
		/**************/
		/*CLEAN SUFFIX*/
		/**************/
		/*FIX THE REPEATED SUFFIXES*/
		#delimit;
		foreach rep in "2nd" "3rd" "4th" "i" "ii" "iii" "jr" "jr." "junior" "md" "no name as yet" "nun" "son-in-law" 
		"sr" "sr." "twin" "2d" "3d" "third" "sn" "second" "lll" "jr 111" "jr 3rd" "american citizen" "adopted daughter" "twins" 
		"companion" {;

			replace pr_name_suf`type'_1=`"`rep'"' if pr_name_suf`type'_1==`"`rep', `rep'"'|pr_name_suf`type'_1==`"`rep'., `rep'"'|pr_name_suf`type'_1==`"`rep', `rep'."';
			
			//gen repeated=strpos(displayname,`", `rep', `rep'"');
			//local str_length=strlen(`", `rep', `rep'"');
			//replace displayname=substr(displayname,1,strlen(displayname)-`str_length')+`", `rep'"' if repeated>=1 & repeated!=.;
			//drop repeated;
			
		};
		#delimit cr
		
		/*
		/*SOME PREFIXEX ARE FAMILY RELATIONS/OCCUPATION (OR SOME GIBBERISH)...*/
		#delimit;

		replace pr_name_pre`type'_1="sister" if pr_name_suf`type'_1=="sister";	
		replace pr_name_pre`type'_1="father" if pr_name_suf`type'_1=="father";

		foreach pre in "blank" "able seaman" "brother" "cook" "daughter" "grand-aunt" "head" "lodger" "mistress" "mother" "property owner" "roomer" 
		"seaman" "servant" "son-in-law" "stepdaughter" "stepfather" "stepson" "superintendent" "wife" 
		
		"adopted daughter" "aunt" "boarder" "brother-in-law" "child" "daughter-in-law" "grandson" "infant" "inmate" "laborer" "laundry ironer" 
		"mother-in-law" "nephew" "nurse" "orphan" "patient" "sister-in-law" "store watchman" "student" "student nurse" {;
			replace pr_name_pre`type'_1="" if pr_name_pre`type'_1==`"`pre'"';
		};		
		
		/*SOME SUFFIXES ARE FAMILY RELATIONS/OCCUPATION (OR SOME GIBBERISH)...*/		
		foreach suf in "blank" "none" "sister" "father" "brother" "daughter" "great aunt" "head" "mother" "officer"
		"prisoner" "roomer" "servant" "son" "son-in-law" "step father" "stepdaughter" "stepson" "superintendant" "superintendent" 
		"wife" "lodger" "unknown" "nun" "adopted" "cook" "american citizen" "own of property" "329a" "dominique" 
		 {;
			replace pr_name_suf`type'_1="" if pr_name_suf`type'_1==`"`suf'"';
		};
		#delimit cr	
		*/
		
		/*CONSTRUCT NAMES*/
		gen fs_namefrst`type'=pr_name_gn`type'_1 if pr_name_pre`type'_1=="" & pr_name_gn`type'_1!=""
		replace fs_namefrst`type'=pr_name_pre`type'_1+" "+pr_name_gn`type'_1 if pr_name_pre`type'_1!="" & pr_name_gn`type'_1!=""	
		replace fs_namefrst`type'=fs_namefrst`type'+" "+pr_name_suf`type'_1 if pr_name_suf`type'_1!=""
		
		gen fs_namelast`type'=pr_name_surn`type'_1 if pr_name_surn`type'_1!=""
		
		foreach comm in ustrtrim ustrltrim stritrim ustrrtrim {
			replace fs_namefrst`type'=`comm'(fs_namefrst`type')
			replace fs_namelast`type'=`comm'(fs_namelast`type')		
		}	
		
		/*
		gen name_combined`type'=fs_namefrst`type'+" "+fs_namelast`type' if fs_namefrst`type'!="" & fs_namelast`type'!=""
		replace name_combined`type'=fs_namefrst`type' if fs_namefrst`type'!="" & fs_namelast`type'==""
		replace name_combined`type'=fs_namelast`type' if fs_namefrst`type'=="" & fs_namelast`type'!=""

		foreach comm in ustrtrim ustrltrim stritrim ustrrtrim {
			replace name_combined`type'=`comm'(name_combined`type')
		}
		*/
	}

	/*COMPARE THE DISPLAYED NAME AND THE NAMES CONSTRUCTED FROM THE NAMEFRST AND NAMELAST*/
	//replace displayname=lower(displayname)
	//replace name_combined=lower(name_combined)
	//replace name_combined_orig=lower(name_combined_orig)

	//ustrdist displayname name_combined, gen(editd)
	//ustrdist displayname name_combined_orig, gen(editd_orig)
	
	ustrdist fs_namefrst fs_namefrst_orig,gen(editd_frst)
	ustrdist fs_namelast fs_namelast_orig,gen(editd_last)

	//gen editd_lt1=editd<=1 if editd!=.
	//gen editd_orig_lt1=editd_orig<=1 if editd_orig!=.

	//sum editd_lt1
	//sum editd_orig_lt1

	/*FILL IN THE BLANKS*/
	replace fs_namelast=fs_namelast_orig if fs_namelast=="" & fs_namelast_orig!=""
	replace fs_namefrst=fs_namefrst_orig if fs_namefrst=="" & fs_namefrst_orig!=""
	replace fs_namelast_orig=fs_namelast if fs_namelast_orig=="" & fs_namelast!=""
	replace fs_namefrst_orig=fs_namefrst if fs_namefrst_orig=="" & fs_namefrst!=""

	keep image_ark_id person_ark_id fs_namefrst* fs_namelast* /*pr_age pr_age_orig state_name county_name township_name enumeration_district_name*/ editd_frst editd_last /*pr_name_suf_1 pr_name_suf_orig_1 pr_name_pre_1 pr_name_pre_orig_1*/

	//bysort person_ark_id: keep if _N==1	
	
	/*
	keep if (fs_namefrst!=fs_namefrst_orig|fs_namelast!=fs_namelast_orig) & strpos(fs_namefrst," jr")==0 & strpos(fs_namefrst_orig," jr")==0 & strpos(fs_namefrst," sr")==0 & strpos(fs_namefrst_orig," sr")==0 /*TO FIX THE NAMES FURTHER*/
	keep fs_namefrst fs_namefrst_orig fs_namelast fs_namelast_orig pr_name_suf_1 pr_name_suf_orig_1 pr_name_pre_1 pr_name_pre_orig_1 /*TO FIX THE NAMES FURTHER*/
	*/
	
	save `"`trans_original'census1930_all_labeled_data_`k'.dta"',replace	
	
}
*/



/*
/*****************************************************************/
/*CREATE COUNTY-LEVEL FILE WITH SHARE OF DISAGREED TRANSCRIPTIONS*/
/*****************************************************************/
use `"`trans_original'census1930_all_labeled_data_1.dta"'
forvalues k=2/126 {
	append using `"`trans_original'census1930_all_labeled_data_`k'.dta"'
}

/*MERGE histid*/
merge 1:1 image_ark_id person_ark_id using `"`cenorig'final1930.dta"', keepusing(histid) keep(1 3) nogen /*final1930.dta HAS ONLY THE LINKED OBSERVATIONS*/

/*MERGE ANCESTRY DATA*/
merge m:1 histid using `"`trans_original'ancestry_all1930.dta"',keepusing(statefip countyicp namefrst namelast) keep(1 2 3) nogen

/*
/*CLEAN NAMES*/
foreach comm in lower ustrtrim ustrltrim stritrim ustrrtrim {
	replace namefrst=`comm'(namefrst)
	replace namelast=`comm'(namelast)		
}

bysort statefip countyicp: gen N=_N

gen linked=person_ark_id!=""
gen nm_fullnames=fs_namefrst_orig!="" & namefrst!="" & fs_namelast_orig!="" & namelast!="" if linked==1
gen disagreement=fs_namefrst_orig!=namefrst|fs_namelast_orig!=namelast if nm_fullnames==1 & editd_frst+editd_last<=1
//gen disagreement=fs_namefrst_orig!=namefrst|fs_namelast_orig!=namelast if nm_fullnames==1

foreach type in linked nm_fullnames disagreement {

	bysort statefip countyicp: egen N`type'=total(`type')

}

gen sh_linked=Nlinked/N
gen sh_nm_fullnames=Nnm_fullnames/Nlinked

keep if disagreement!=.

collapse (mean) sh_disagreement=disagreement (firstnm) sh_linked sh_nm_fullnames N, by(statefip countyicp)

keep statefip countyicp N sh_*

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

save `"`trans_original'census1930_for_maps.dta"', replace
export delimited using `"`trans_original_f'sh_disagreement1930.csv"', replace





/****************************************/
/****************************************/
/****BELOW RETIRED (FOR NOW AT LEAST)****/
/****************************************/
/****************************************/
/*
/*MERGE THE NAMES OF THE STATE/COUNTY/TOWNSHIP/ENUMERATION DISTRICTS FROM THE images FILE (WHICH HELP US LOCATE THE IMAGE FILES FOR EACH RECORD)*/
use `"`trans_original'all_FS1930.dta"', clear

	
	if _N>0 {
	
		local z=`z'+1
		
		if `z'>1 {
		
			append using `"`trans_original'all_FS1930.dta"',force
		
		}
		
		save `"`trans_original'all_FS1930.dta"', replace
	
	}

	
	
	
	/*
	/*MERGE histid*/
	merge 1:1 image_ark_id person_ark_id using `"`cenorig'final1930.dta"', keepusing(histid) keep(1 3) nogen

	/*MERGE ANCESTRY DATA*/
	merge m:1 histid using `"`trans_original'ancestry_all1930.dta"'

	/*KEEP ONLY THE RECORDS WITH NAMES FROM BOTH FAMILYSEARCH AND ANCESTRY*/
	keep if _merge==3 & editd_frst+editd_last<=1

	/*CLEAN ANCESTRY NAMES*/
	foreach comm in lower ustrtrim ustrltrim stritrim ustrrtrim {
		replace namefrst=`comm'(namefrst)
		replace namelast=`comm'(namelast)		
	}	

	rename (fs_namefrst_orig fs_namelast_orig pr_age_orig) (namefrst_fs namelast_fs age_fs)

	#delimit;

		keep histid namefrst namelast namefrst_fs namelast_fs age age_fs statefip countyicp
		nararollnumber imagenumber linenumber serial pernum non_ditto
		/*image_ark_id state_name county_name township_name enumeration_district_name*/ editd_frst editd_last enumdist;

	#delimit cr

	//keep if namelast!="" & namefrst!="" & namefrst_fs!="" & namelast_fs!="" & age!=. & age_fs!=""			

	save `"`trans_original'census1930_all_labeled_data_`k'.dta"',replace
	*/
