clear
local yr_list=`"`1'"'
local location=`2'
local women_added=`"`3'"' /*"" OR "_women_added"*/

if `location'==1 { /*SERVER AT HOME*/

	local original "C:\Users\munir_and_sam\SNU ECON Dropbox\sam hwang\enum_date\DATA\ORIGINAL\"
	local f_original "F:\enum_date\DATA\ORIGINAL\"

	local intermediate "C:\Users\munir_and_sam\SNU ECON Dropbox\sam hwang\enum_date\DATA\INTERMEDIATE\"
	local f_intermediate "F:\enum_date\DATA\INTERMEDIATE\"
	
	local correct_error_original "C:\Users\munir_and_sam\SNU ECON Dropbox\sam hwang\fixing_transcription_errors\DATA\ORIGINAL\"
	local christian_torben "C:\Users\munir_and_sam\SNU ECON Dropbox\sam hwang\fixing_transcription_errors\DATA\TRANSCRIPTIONS\"	

}
else if `location'==2 { /*DESKTOP AT HOME*/

	local original "C:\Users\ilmyo\Dropbox\enum_date\DATA\ORIGINAL\"
	local f_original "C:\Users\ilmyo\OneDrive\Desktop\enum_date\DATA\ORIGINAL\"

	local intermediate "C:\Users\ilmyo\Dropbox\enum_date\DATA\INTERMEDIATE\"
	local f_intermediate "C:\Users\ilmyo\OneDrive\Desktop\enum_date\DATA\INTERMEDIATE\"

}
else if `location'==3 { /*DAD'S DESKTOP*/

	local original "C:\Users\munir_and_sam\SNU ECON Dropbox\sam hwang\enum_date\DATA\ORIGINAL\"
	local f_original "D:\enum_date\DATA\ORIGINAL\"

	local intermediate "C:\Users\munir_and_sam\SNU ECON Dropbox\sam hwang\enum_date\DATA\INTERMEDIATE\"
	local f_intermediate "D:\enum_date\DATA\INTERMEDIATE\"
	
	local correct_error_original "C:\Users\munir_and_sam\SNU ECON Dropbox\sam hwang\fixing_transcription_errors\DATA\ORIGINAL\"
	local christian_torben "C:\Users\munir_and_sam\SNU ECON Dropbox\sam hwang\fixing_transcription_errors\DATA\TRANSCRIPTIONS\"

}


label drop _all

foreach yr in `yr_list' {

	use sex race bpl namefrst_ans_cleaned namelast_ans_cleaned using `"`original'matching_intgen`yr'`women_added'.dta"',clear

	if `"`women_added'"'=="" {
	
		keep if sex==1
	
	}
	
	drop if namefrst_ans_cleaned==""|namelast_ans_cleaned==""
	keep if bpl<900
	keep if race==1|race==2

	/*OBTAIN RACE-SPECIFIC */
	levelsof race,local(race_list)
	
	foreach r in `race_list' {
		levelsof bpl if race==`r',local(race`r'_bpl_list)
	}
	
	/*OBTAIN BPL LISTS*/
	levelsof bpl, local(race3_bpl_list)

	foreach name_type in /*"_ans_cleaned"*/ "_true_cleaned" {

		capture mkdir `"`f_intermediate'divided_file`yr'`name_type'`women_added'"'	
		
	
		/*ONLY DO THIS IF _TRUE AND 1940 (BECAUSE THAT IS WHAT CHRISTIAN AND TORBEN HAVE CREATED)s*/		
		if strpos(`"`name_type'"',"_true")>0 & `yr'==1940 {

			/******************************************************/
			/*APPEND FIXED TRANSCRIPTION (SOME STATES ARE MISSING)*/
			/******************************************************/
			#delimit;
			
			local z=0;
			
			cd `"`christian_torben'USCensus1940FullCount\output_and_output1_ssha2025"';
			
			foreach stabb in "al" "ar" "az" "ca" "co" "ct" "dc" "de" "fl" "ga" 
							 "hi" "ia" "id" "il" "in" "ks" "ky" "la" "ma" "md" 
							 "me" "mi" "mn" "mo" "ms" "mt" "nc" "nd" "ne" "nh" 
							 "nj" "nm" "nv" "ny" "oh" "ok" "or" "pa" "ri" "sc"
							 "sd" "tn" "tx" "ut" "va" "vt" "wa" "wi" "wv" "wy" {;
				
				local z=`z'+1;

				cd `"`stabb'"';
				
				if `z'==1 {;
				
					use filename row namefrst_ml namelast_ml_ditto parsing_quality using merged_data.dta, clear;
				
				};
				else {;
				
					append using merged_data.dta, keep(filename row namefrst_ml namelast_ml_ditto parsing_quality);
				
				};
				
				cd ..;
							 
							 
			};
			
			#delimit cr			
			
			bysort filename row: gen N1=_N
			bysort filename row namefrst_ml namelast_ml_ditto parsing_quality: gen N2=_N
			
			keep if N1==N2
			
			bysort filename row: keep if _n==1
			
			keep if (namefrst_ml!=""|namelast_ml_ditto!="") & parsing_quality!=. 
			 
			drop N1 N2 
			 
			save `"`correct_error_original'temptemptemp`location'.dta"', replace
			
		}

		local zz=0
		
		foreach r in /*`race_list'*/ 3 {

			if `r'==1 {
				local race_str="white"
			}
			else if `r'==2 {
				local race_str="black"			
			}
			else if `r'==3 {
				local race_str="norace"
			}

			foreach b in `race`r'_bpl_list' {
			
				noisily di `"`yr', `b'"'

				if strpos(`"`name_type'"',"_true")>0 & `yr'==1940 {
				
					/*MERGE THE TRUE NAME*/
					local existing_type=subinstr(`"`name_type'"',"_true","_ans",.)
					
					use namefrst`existing_type' namelast`existing_type' age histid filename row sex using `"`f_intermediate'divided_file`yr'`women_added'\\`race_str'`b'.dta"',clear 
	
					replace filename=filename+".jpg"
	
					merge m:1 filename row using `"`correct_error_original'temptemptemp`location'.dta"',keep(1 3) keepusing(namefrst_ml namelast_ml_ditto)

					bysort filename row: gen N=_N
				
					rename (namefrst_ml namelast_ml_ditto) (namefrst`name_type' namelast`name_type')

					/*IF filename - row ARE DUPLICATES, IGNORE THE NEW TRANSCRIPTIONS*/
					replace namefrst`name_type'="" if N>1 & _merge==3
					replace namelast`name_type'="" if N>1 & _merge==3
					
					/*CREATE INDICATOR FOR OBSERVATIONS WITH TRUE NAMES AND/OR AGE*/
					gen name`name_type'_exists=_merge==3 & N==1
					gen true_age_exists=0
	
					/*FOR THOSE THAT ARE NOT IN 1 PERCENT SAMPLE, REPLICATE THE VALUES IN THE CENSUS*/
					replace namefrst`name_type'=namefrst_ans if namefrst`name_type'=="" & namefrst_ans!=""
					replace namelast`name_type'=namelast_ans if namelast`name_type'=="" & namelast_ans!=""
					replace true_age=age if true_age_exists!=1
					
					abeclean namefrst`name_type' namelast`name_type',sex(sex) initial(mi`name_type') nickname nonysiis 
					drop _merge

					keep namefrst`name_type'_cleaned namelast`name_type'_cleaned true_age histid name`name_type'_exists true_age_exists mi`name_type' sex
					rename (namefrst`name_type'_cleaned namelast`name_type'_cleaned true_age) (namefrst`name_type' namelast`name_type' age)
				
				}
				else {

					use namefrst_ans_cleaned namelast_ans_cleaned age mi histid sex using `"`f_intermediate'divided_file`yr'`women_added'\\`race_str'`b'.dta"',clear
					
					if `"`name_type'"'=="_true_cleaned" {
						rename (namefrst_ans_cleaned namelast_ans_cleaned mi) (namefrst`name_type' namelast`name_type' mi`name_type')
					}
					
				}				
				
				/*************/
				/*CLEAN NAMES*/
				/*************/
				rename namefrst f_name 			// call first name "f_name"
				rename namelast l_name 			// call last name "l_name"
				rename histid id						// generate unique identifier, or rename existing identifier "id"
				
				save `"`f_intermediate'divided_file`yr'`name_type'`women_added'\\`race_str'`b'.dta"',replace
			
			
				/*************************************/
				/*CREATE FILES FOR IPUM'S MLP LINKING*/
				/*************************************/
				if `"`women_added'"'=="_women_added" {
			
					local zz=`zz'+1
					
					gen bpl=`b'
		
					/*RENAME VARIABLES FOR CLARITY*/
					if `"`name_type'"'=="_true_cleaned" {
					
						if `yr'==1940 {

							keep age id mi_true_cleaned f_name l_name sex name_true_cleaned_exists bpl
							rename (id f_name l_name) (histid namefrst`name_type' namelast`name_type')
						
						}
						else {

							keep age id mi_true_cleaned f_name l_name sex bpl				
							rename (id f_name l_name mi`name_type') (histid namefrst namelast mi)						
						
						}
					
					}
					else {
					
						keep age id mi f_name l_name sex bpl
						rename (id f_name l_name) (histid namefrst namelast)					
					
					}
					
					noisily di `"here `zz'"'
					
					if `zz'>1 {
					
						append using `"`f_intermediate'for_mlp`yr'`name_type'.dta"'
					
					}
					
					save `"`f_intermediate'for_mlp`yr'`name_type'.dta"', replace
				
				}
			
			}
			
		}
	
	}
	
	use `"`f_intermediate'for_mlp`yr'_ans_cleaned.dta"', clear
	merge 1:1 histid using `"`f_intermediate'for_mlp`yr'_true_cleaned.dta"', keep(1 3 4 5) nogen update
	save `"`f_intermediate'for_mlp`yr'.dta"', replace
	
	//capture erase `"`f_intermediate'for_mlp`yr'_ans_cleaned.dta"'
	//capture erase `"`f_intermediate'for_mlp`yr'_true_cleaned.dta"'

}

capture erase `"`intermediate'temp`location'_firstname.dta"'
capture erase `"`intermediate'temp`location'_lastname.dta"'
//capture erase `"`correct_error_original'temptemp`location'.dta"'
