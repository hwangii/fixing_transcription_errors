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
*/

/*
/*******************/
/*RHODE ISLAND ONLY*/
/*******************/
//forvalues k=1/126 {
foreach k in 7 19 34 48 61 73 85 92 101 109 117 122 126 {

	di `k'

	use `"`cenorig'p`k'.dta"', clear
	
	#delimit;
	
		keep image_ark_id person_ark_id displayname
		
		pr_age pr_age_orig
		
		pr_name_pre_1 pr_name_pre_orig_1 pr_name_pre_2 pr_name_pre_orig_2 

		pr_name_gn_1 pr_name_gn_orig_1 pr_name_gn_2 pr_name_gn_orig_2
		
		pr_name_surn_1 pr_name_surn_orig_1 pr_name_surn_2 pr_name_surn_orig_2 
		
		pr_name_suf_1 pr_name_suf_orig_1 pr_name_suf_2 pr_name_suf_orig_2;
	
	#delimit cr
	
	foreach nt in pre gn surn suf {
	
		foreach type in "" "_orig" {
	
			foreach num in 1 2 {
			
				* To check if it's string:			
				local vartype : type pr_name_`nt'`type'_`num'

				if substr("`vartype'"', 1, 3) != "str" {
					drop pr_name_`nt'`type'_`num'
					gen pr_name_`nt'`type'_`num'=""
				}
			
				foreach comm in lower ustrtrim ustrltrim stritrim ustrrtrim {
				
					replace pr_name_`nt'`type'_`num'=`comm'(pr_name_`nt'`type'_`num')
				
				}

			}
		
		}
		
	}	
	
	egen nprefix=rownonmiss(pr_name_pre_1 pr_name_pre_orig_1 pr_name_pre_2 pr_name_pre_orig_2), strok
	egen nsuffix=rownonmiss(pr_name_suf_1 pr_name_suf_orig_1 pr_name_suf_2 pr_name_suf_orig_2), strok
	
	keep if nprefix==0 & nsuffix==0
	
	merge m:1 image_ark_id using `"`cenorig'images.dta"',keepusing(state_name county_name township_name enumeration_district_name) keep(3) nogen

	/*MERGE histid*/
	merge 1:1 image_ark_id person_ark_id using `"`cenorig'final1930.dta"', keepusing(histid) keep(3) nogen /*final1930.dta HAS ONLY THE LINKED OBSERVATIONS*/

	/*MERGE ANCESTRY DATA*/
	merge 1:1 histid using `"`trans_original'ancestry_all1930.dta"',keepusing(statefip countyicp namefrst namelast nararollnumber imagenumber linenumber) keep(3) nogen

	/*CLEAN NAMES*/
	foreach comm in lower ustrtrim ustrltrim stritrim ustrrtrim {

		replace namefrst=`comm'(namefrst)
		replace namelast=`comm'(namelast)		
	
	}
	
	#delimit;

		keep image_ark_id person_ark_id 
			 pr_age pr_age_orig
			 pr_name_gn_orig_1 pr_name_surn_orig_1 
			 state_name county_name township_name enumeration_district_name 
			 statefip countyicp namefrst namelast nararollnumber imagenumber linenumber;

			 rename (pr_name_gn_orig_1 pr_name_surn_orig_1) (fs_namefrst fs_namelast);
		
		keep if namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="";
	
	#delimit cr
	
	save `"`trans_original'census1930_all_labeled_data_`k'.dta"',replace
	
}
*/



/*****************************************************************/
/*CREATE COUNTY-LEVEL FILE WITH SHARE OF DISAGREED TRANSCRIPTIONS*/
/*****************************************************************/
local z=0

foreach k in 7 19 34 48 61 73 85 92 101 109 117 122 126 {
	
	local z=`z'+1
	
	if `z'==1 {
		use `"`trans_original'census1930_all_labeled_data_`k'.dta"', clear
	}
	else {
		append using `"`trans_original'census1930_all_labeled_data_`k'.dta"', force
	}
	
}

save `"`trans_original'census1930_all_labeled_data.dta"', replace





use `"`trans_original'census1930_all_labeled_data.dta"', clear

gen same=fs_namefrst==namefrst & fs_namelast==namelast

bysort state_name county_name township_name enumeration_district_name: egen sh_same_ed=mean(same)
bysort state_name county_name township_name enumeration_district_name imagenumber: egen sh_same_page=mean(same)

bysort state_name county_name township_name enumeration_district_name: gen N_ed=_N
bysort state_name county_name township_name enumeration_district_name imagenumber: gen N_page=_N

keep if N_page>=45 & N_page<=50

gsort -sh_same_page state_name county_name township_name enumeration_district_name imagenumber linenumber

edit pr_age fs_namefrst fs_namelast state_name county_name township_name enumeration_district_name imagenumber
