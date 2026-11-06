/* This code gives an example of how the various versions of the ABE/Ferrie algorithm are run in Stata. 
In this example we give the code to link the 1865 Norwegian census to the 1900 Norwegian census. However the
majority of this code is generic, and will apply to any data set. In order use this code for your specific data, 
standardize the variable names given to match the names used in Section I. 

A note on linking large data sets: When linking large files (e.g. full-count census data), in order 
to make the matching more computationally feasible begin by saving your observations by place of birth 
(e.g. before matching all American-born men in the 1900 census to the 1910 census you should have 100 
individual data files, 50 place of birth files from each census year). The following linking steps will 
then be completed for each place of birth separately (e.g. link Alabama in 1900 to Alabama in 1910, then 
Arizona in 1900 to Arizona in 1910, ect…)  */
*-------------------------------------------------------------------------------------------------------*/
set more off
clear all

/*SET YEARS*/
local year1=`1'
local year2=`2'
local name_type=`"`3'"' /*"_ans_cleaned", "_ans_nysiis", "_true_cleaned", "_true_nysiis", "_fs_cleaned"*/
local location=`4'
/*2026-11-06: OPTIONAL NAME TYPE FOR THE LATER CENSUS (DATASET B). EMPTY =   */
/*THE SAME AS DATASET A, WHICH IS THE ORIGINAL BEHAVIOUR. E.G. FAMILYSEARCH  */
/*NAMES IN 1930 ONLY: name_type "_fs_cleaned", name_type_B "_ans_cleaned".   */
local name_type_B=`"`5'"'
if `"`name_type_B'"'=="" local name_type_B `"`name_type'"'
/*SUFFIX FOR OUTPUT NAMES: EMPTY WHEN BOTH YEARS USE THE SAME NAME TYPE, SO  */
/*EXISTING DIRECTORIES AND FILES KEEP THEIR NAMES.                           */
local B_tag ""
if `"`name_type_B'"'!=`"`name_type'"' local B_tag `"`name_type_B'"'

if `"`name_type'"'=="" {
	di "ENTER NAME TYPE!!!"
	exit,clear
}

/* Specify directory locations: */
if `location'==1 { /*SERVER AT HOME*/

	/*2026-11-06: PATHS FROM replication/config.do; D:\Dropbox NO LONGER EXISTS.*/
	if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
	local original  "$REP_SNU/enum_date/DATA/ORIGINAL/"
	local intermediate "$REP_F/enum_date/DATA/INTERMEDIATE/"

	global MatchingDoFiles   "$REP_SNU/enum_date/CODE/abe_algorithm_code_july2020"  	    	/*location where all ABE/Ferrie matching algorithm files (and .ado files) are stored */
	global datadirA			 `"$REP_F/enum_date/DATA/INTERMEDIATE/divided_file`year1'`name_type'"'		  		/*location where the raw data for dataset A is held*/

	global datadirB			 `"$REP_F/enum_date/DATA/INTERMEDIATE/divided_file`year2'`name_type_B'"'  			/*location where the raw data for dataset B is held*/

}
else if `location'==2 { /*DESKTOP AT HOME*/

	local original "C:\Users\ilmyo\Dropbox\enum_date\DATA\ORIGINAL\"
	local intermediate "C:\Users\ilmyo\OneDrive\Desktop\enum_date\DATA\INTERMEDIATE\"	

	global MatchingDoFiles   "C:\Users\ilmyo\Dropbox\enum_date\CODE\abe_algorithm_code_july2020"  	    	/*location where all ABE/Ferrie matching algorithm files (and .ado files) are stored */
	global datadirA			 `"C:\Users\ilmyo\OneDrive\Desktop\enum_date\DATA\INTERMEDIATE\divided_file`year1'`name_type'"'		  		/*location where the raw data for dataset A is held*/
	
	global datadirB			 `"C:\Users\ilmyo\OneDrive\Desktop\enum_date\DATA\INTERMEDIATE\divided_file`year2'`name_type_B'"'  			/*location where the raw data for dataset B is held*/
	
	
}
else if `location'==3 { /*DAD'S DESKTOP*/

	local original "D:\Dropbox\enum_date\DATA\ORIGINAL\"
	local intermediate "D:\enum_date\DATA\INTERMEDIATE\"	
	
	global MatchingDoFiles   "D:\Dropbox\enum_date\CODE\abe_algorithm_code_july2020"  	    	/*location where all ABE/Ferrie matching algorithm files (and .ado files) are stored */
	global datadirA			 `"D:\enum_date\DATA\INTERMEDIATE\divided_file`year1'`name_type'"'		  		/*location where the raw data for dataset A is held*/

	global datadirB			 `"D:\enum_date\DATA\INTERMEDIATE\divided_file`year2'`name_type_B'"'  			/*location where the raw data for dataset B is held*/	

}

/*2026-11-06: THE BIRTHPLACE LIST COMES FROM DATASET A'S DIVIDED FILES. IT   */
/*WAS READ FROM matching_intgen`year1'.dta (MEN, NAMES PRESENT, bpl<900,     */
/*race 1-2), WHICH NO LONGER EXISTS UNDER THAT NAME (ONLY _old AND           */
/*_women_added). 1_divide_and_clean WROTE ONE norace<bpl>.dta PER BIRTHPLACE */
/*IN THAT SAME LIST, AND THE LOOP BELOW SKIPS ANY PAIR WITHOUT BOTH FILES,   */
/*SO THE PAIRS MATCHED ARE THE SAME. ONLY THE race 3 (norace) LIST IS USED.  */
local race3_bpl_list ""
local Afiles : dir `"$datadirA"' files "norace*.dta"
foreach f of local Afiles {
	local b = subinstr(subinstr(`"`f'"',"norace","",1),".dta","",1)
	local race3_bpl_list `race3_bpl_list' `b'
}
local race3_bpl_list : list sort race3_bpl_list
if `"`race3_bpl_list'"'=="" {
	display as error "no norace*.dta files in $datadirA"
	exit 601
}

*******************************************************************************
/* SECTION 1. Standardize and Clean Data
*******************************************************************************/
*******************************************************************************
/* SECTION 2. ABE/Ferrie matching algorithm
*******************************************************************************/
capture cd `"`intermediate'"'
capture mkdir r`name_type'`B_tag'`year1'_`year2' /*r FOR race*/

local dir_name=`"r`name_type'`B_tag'`year1'_`year2'"'

if `location'==1 {
	global outdir 			 `"$REP_F/enum_date/DATA/INTERMEDIATE/`dir_name'"' 						/*location to store cleaned data*/
}
else if `location'==2 {
	global outdir 			 `"C:\Users\ilmyo\OneDrive\Desktop\enum_date\DATA\INTERMEDIATE\\`dir_name'"' 						/*location to store cleaned data*/
}
else if `location'==3 {
	global outdir 			 `"D:\enum_date\DATA\INTERMEDIATE\\`dir_name'"' 						/*location to store cleaned data*/
}

foreach r in /*`race_list'*/ 3 {
	
	/*DO RACE BLOCKING ONLY IF `interval'==30*/
	if (`year2'-`year1'!=30) & `r'!=3 {
		continue
	}

	foreach b of numlist `race`r'_bpl_list' {

		if `r'==1 {
			local race="white"
		}
		else if `r'==2 {
			local race="black"
		}
		else if `r'==3 {
			local race="norace"
		}
		
		global A $datadirA\\`race'`b'.dta 				// cleaned & standardized data file A
		global B $datadirB\\`race'`b'.dta 				// cleaned & standardized data file B
		
		global outputfile `"${outdir}\\`race'`b'`name_type'`B_tag'"'  // file name to save matched data
		
		/*CHECK IF FILE EXISTS FOR BOTH YEARS*/
		capture confirm file "$A"
		local Aexists=1-_rc
		capture confirm file "$B"
		local Bexists=1-_rc		
		
		noisily di `Aexists',`Bexists'
		
		if `Aexists'==1 & `Bexists'==1 {
		
			/* 2.1 Set up abe matching algorithm.  */
			/* "match_vars" specifies which variables to link on. There are many options. Here we use NYSIIS standardized 
			names (f_name_nysiis l_name_nysiis), but you could instead use exact names (f_name_cleaned l_name_cleaned). In this 
			example we match on place of birth, other options include middle initial, race, or any other time-invariant characteristic. 
			*/
			global match_vars f_name l_name

			global timediff = `year2'-`year1' // number of years between the age reported in data set A and age reported in data set B. 

			/* 2.2 Find ABE matches, standard version */
			clear
			abematch $match_vars,  file_A($A) file_B($B) timevar(age) timediff($timediff) save($outputfile)  replace id_A(id) id_B(id) unique_m(2) unique_f(2) keep_A(l_name f_name) keep_B(l_name f_name) 
		
			* see abematch.sthlp for additional options 
		
			use $outputfile , clear
			
			if _N>0 {
			
				/* 2.3 More conservative matching, restrict sample to those unique within +-2 years of age. */
				gen fiveyr_band=unique_file2 == 1 & unique_match2 == 1 //only names unique within +- 2 years in own data sets & people without another potential match within +-2 years of birth

				save $outputfile , replace
			
			}
			else {
			
				erase $outputfile.dta
				
			}
			
		}
	}	
}

** last updated: Jan 14, 2018 
** please contact ranabr@stanford.edu (Ran Abramitzky), lboustan@princeton.edu (Leah Boustan), and/or kaeriksson@ucdavis.edu (Katherine Eriksson) 
** with any questions or feedback about this code. 
