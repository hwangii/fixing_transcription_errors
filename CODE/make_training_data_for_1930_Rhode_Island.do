clear

local cendir "F:\updated_census_recvd_aug2021\ubc_1930_3-5\1930_3-5\"
local trans_original "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\"
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

keep histid namefrst namelast serial pernum non_ditto nararollnumber imagenumber linenumber statefip countyicp age

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



/*******************/
/*RHODE ISLAND ONLY*/
/*******************/
local z=0

forvalues k=103/106 {

	di `k'

	use _all using `"`cenorig'p`k'.dta"' if event_state_orig=="Rhode Island", clear
	
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
	if _N>0 {
	
		local z=`z'+1
		
		if `z'>1 {
		
			append using `"`trans_original'rhode_island_FS1930.dta"'
		
		}
		
		save `"`trans_original'rhode_island_FS1930.dta"', replace
	
	}
	
	
}

/*MERGE THE NAMES OF THE STATE/COUNTY/TOWNSHIP/ENUMERATION DISTRICTS FROM THE images FILE (WHICH HELP US LOCATE THE IMAGE FILES FOR EACH RECORD)*/
use `"`trans_original'rhode_island_FS1930.dta"', clear
merge m:1 image_ark_id using `"`cenorig'images.dta"',keepusing(state_name county_name township_name enumeration_district_name) keep(1 3) 


/*NAMES HAVE TWO VERSIONS*/
foreach type in "" "_orig" {

	/*MAKE ALL NAMES LOWER CASE*/
	foreach nt in pre gn surn suf {
		replace pr_name_`nt'`type'_1=lower(pr_name_`nt'`type'_1)
	}

	/*CLEAN PREFIX*/
	foreach rep in "dr" "miss" "mr" "mrs" "rev" {

		replace pr_name_pre`type'_1=`"`rep'"' if pr_name_pre`type'_1==`"`rep', `rep'"'
		
		gen repeated=strpos(displayname,`"`rep', `rep' "')
		local str_length=strlen(`"`rep', `rep' "')
		replace displayname=`"`rep' "'+ substr(displayname,(`str_length'+1),strlen(displayname)-`str_length') if repeated>=1 & repeated!=.

		drop repeated	
		
	}	  
	
	/**************/
	/*CLEAN SUFFIX*/
	/**************/
	/*FIX THE REPEATED SUFFIXES*/
	#delimit;
	foreach rep in "2nd" "3rd" "4th" "i" "ii" "iii" "jr" "jr." "junior" "md" "no name as yet" "nun" "son-in-law" 
	"sr" "sr." "twin" "2d" "3d" "third" "sn" "second" "lll" "jr 111" "jr 3rd" "american citizen" {;

		replace pr_name_suf`type'_1=`"`rep'"' if pr_name_suf`type'_1==`"`rep', `rep'"';
		
		gen repeated=strpos(displayname,`", `rep', `rep'"');
		local str_length=strlen(`", `rep', `rep'"');
		replace displayname=substr(displayname,1,strlen(displayname)-`str_length')+`", `rep'"' if repeated>=1 & repeated!=.;

		drop repeated;
		
	};
	#delimit cr
	
	/*SOME PREFIXEX/SUFFIXES ARE FAMILY RELATIONS/OCCUPATION (OR SOME GIBBERISH)...*/
	#delimit;

	replace pr_name_pre`type'_1="sister" if pr_name_suf`type'_1=="sister";	
	replace pr_name_pre`type'_1="father" if pr_name_suf`type'_1=="father";
	
	foreach suf in "blank" "none" "sister" "father" "brother" "daughter" "great aunt" "head" "mother" "officer"
	"prisoner" "roomer" "servant" "son" "son-in-law" "step father" "stepdaughter" "stepson" "superintendant" "superintendent" 
	"wife" "lodger" "unknown" "nun" "adopted" "cook" "american citizen" "own of property" "329a" "dominique" {;
		replace pr_name_suf`type'_1="" if pr_name_suf`type'_1==`"`suf'"';
	};
	
	foreach pre in "blank" "able seaman" "brother" "cook" "daughter" "grand-aunt" "head" "lodger" "mistress" "mother" "property owner" "roomer" 
	"seaman" "servant" "son-in-law" "stepdaughter" "stepfather" "stepson" "superintendent" "wife" {;
		replace pr_name_pre`type'_1="" if pr_name_pre`type'_1==`"`pre'"';
	};
	#delimit cr	
	
	/*CONSTRUCT NAMES*/
	gen fs_namefrst`type'=pr_name_gn`type'_1 if pr_name_pre`type'_1=="" & pr_name_gn`type'_1!=""
	replace fs_namefrst`type'=pr_name_pre`type'_1+" "+pr_name_gn`type'_1 if pr_name_pre`type'_1!="" & pr_name_gn`type'_1!=""	
	replace fs_namefrst`type'=fs_namefrst`type'+" "+pr_name_suf`type'_1 if pr_name_suf`type'_1!=""
	
	gen fs_namelast`type'=pr_name_surn`type'_1 if pr_name_surn`type'_1!=""
	
	foreach comm in ustrtrim ustrltrim stritrim ustrrtrim {
		replace fs_namefrst`type'=`comm'(fs_namefrst`type')
		replace fs_namelast`type'=`comm'(fs_namelast`type')		
	}	
	
	gen name_combined`type'=fs_namefrst`type'+" "+fs_namelast`type' if fs_namefrst`type'!="" & fs_namelast`type'!=""
	replace name_combined`type'=fs_namefrst`type' if fs_namefrst`type'!="" & fs_namelast`type'==""
	replace name_combined`type'=fs_namelast`type' if fs_namefrst`type'=="" & fs_namelast`type'!=""

	foreach comm in ustrtrim ustrltrim stritrim ustrrtrim {
		replace name_combined`type'=`comm'(name_combined`type')
	}

}

/*COMPARE THE DISPLAYED NAME AND THE NAMES CONSTRUCTED FROM THE NAMEFRST AND NAMELAST*/
replace displayname=lower(displayname)
replace name_combined=lower(name_combined)
replace name_combined_orig=lower(name_combined_orig)

strdist displayname name_combined, gen(editd)
strdist displayname name_combined_orig, gen(editd_orig)
strdist fs_namefrst fs_namefrst_orig,gen(editd_frst)
strdist fs_namelast fs_namelast_orig,gen(editd_last)

gen editd_lt1=editd<=1 if editd!=.
gen editd_orig_lt1=editd_orig<=1 if editd_orig!=.

sum editd_lt1
sum editd_orig_lt1

/*FILL IN THE BLANKS*/
replace fs_namelast=fs_namelast_orig if fs_namelast=="" & fs_namelast_orig!=""
replace fs_namefrst=fs_namefrst_orig if fs_namefrst=="" & fs_namefrst_orig!=""
replace fs_namelast_orig=fs_namelast if fs_namelast_orig=="" & fs_namelast!=""
replace fs_namefrst_orig=fs_namefrst if fs_namefrst_orig=="" & fs_namefrst!=""

keep image_ark_id person_ark_id fs_namefrst* fs_namelast* pr_age pr_age_orig state_name county_name township_name enumeration_district_name editd_frst editd_last

bysort person_ark_id: keep if _N==1

/*MERGE histid*/
merge 1:1 image_ark_id person_ark_id using `"`cenorig'final1930.dta"', keepusing(histid) keep(1 3) nogen

/*MERGE ANCESTRY DATA*/
merge m:1 histid using `"`trans_original'ancestry_all1930.dta"'

keep if _merge==1|_merge==3|(_merge==2 & statefip==44)

/*KEEP ONLY THE RECORDS WITH NAMES FROM BOTH FAMILYSEARCH AND ANCESTRY*/
keep if _merge==3 & editd_frst+editd_last<=1

/*CLEAN ANCESTRY NAMES*/
foreach comm in lower ustrtrim ustrltrim stritrim ustrrtrim {
	replace namefrst=`comm'(namefrst)
	replace namelast=`comm'(namelast)		
}	

rename (fs_namefrst_orig fs_namelast_orig pr_age_orig) (namefrst_fs namelast_fs age_fs)

keep histid namefrst namelast namefrst_fs namelast_fs age age_fs statefip countyicp nararollnumber imagenumber linenumber serial pernum non_ditto image_ark_id state_name county_name township_name enumeration_district_name

keep if namelast!="" & namefrst!="" & namefrst_fs!="" & namelast_fs!="" & age!=. & age_fs!=""			

save `"`trans_original'census1930_RI_labeled_data.dta"',replace
capture erase `"`trans_original'rhode_island_FS1930.dta"'
