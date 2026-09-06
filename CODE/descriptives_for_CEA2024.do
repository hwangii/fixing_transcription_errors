local code "D:\Dropbox\fixing_transcription_errors\CODE\"
local original "D:\Dropbox\enum_date\DATA\ORIGINAL\"
local original_d "D:\enum_date\DATA\ORIGINAL\"
local intermediate "D:\Dropbox\enum_date\DATA\INTERMEDIATE\"
local intermediate_nondb "D:\enum_date\DATA\INTERMEDIATE\"


local correct_error_original "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\"
local christian_torben "D:\Dropbox\fixing_transcription_errors\DATA\TRANSCRIPTIONS\"

/*
/*IMPORT MOBILITY MEASURE OF RESIDENCES IN RHODE ISLAND*/
do `"`code'usa00547_for_CEA_Rhode_Island_mobility_measure.do"'
*/

/*
/*CENSUS TREE LINKAGE*/
import delimited `"`original_d'1910_1940.csv"',clear
rename histid1940 histid
save `"`intermediate_nondb'1910_1940.dta"',replace
*/


/*KEEP THE IMAGE NAME, LINE NUMBER, AND HISTID*/
use `"`correct_error_original'rhode_island_combined.dta"',clear

keep linep imagenumber_combined histid namefrst namelast fs_namefrst fs_namelast fs_age

replace imagenumber_combined=imagenumber_combined+".jpg"

tostring linep,replace

rename imagenumber_combined filename

merge 1:1 filename linep using `"`christian_torben'df_all_namefrst_archive_quality.dta"',keepusing(quality namefrst_ml) keep(3) nogen
rename quality namefrst_quality

merge 1:1 filename linep using `"`christian_torben'df_all_namelast_archive_quality.dta"',keepusing(quality namelast_ml) keep(3) nogen
rename quality namelast_quality

merge 1:1 histid using `"`intermediate_nondb'1910_1940.dta"',keep(1 3)

merge 1:1 histid using `"`original_d'rhode_island_mobility1940.dta"',nogen

gen linked=_merge==3 if age>=27 & age!=.


/*CREATE HEATMAP*/
gen quality1=namefrst_quality
replace quality1="D" if quality1!="" & quality1!="A" & quality1!="B" & quality1!="C"

gen quality1_num=4 if quality1=="A"
replace quality1_num=3 if quality1=="B"
replace quality1_num=2 if quality1=="C"
replace quality1_num=1 if quality1=="D"



gen quality2=namelast_quality
replace quality2="D" if quality2!="" & quality2!="A" & quality2!="B" & quality2!="C"

gen quality2_num=4 if quality2=="A"
replace quality2_num=3 if quality2=="B"
replace quality2_num=2 if quality2=="C"
replace quality2_num=1 if quality2=="D"

gen high_quality=quality1_num==4 & quality2_num==4 if quality1_num!=. & quality2_num!=.

//heatplot linked i.quality2_num i.quality1_num





/*
save `"`correct_error_original'temptemp`location'.dta"',replace



/*************************/
/*MERGE CENSUS TREE LINKS*/
/*************************/

	
	
				/**********************************************************************************/
				/*KEEP THE CORRECTED FIRST NAME FROM THE PROTOTYPE CREATED BY CHRISTIAN AND TORBEN*/
				/**********************************************************************************/			
				use bad_segmentation namefrst_ml namefrst_anc filename linep using `"`christian_torben'df_nonagreements_namefrst_archive_extended_ver2_corrected.dta"' if bad_segmentation==0 & namefrst_ml!=namefrst_anc & namefrst_ml!="" , clear
				//use bad_segmentation namefrst_ml namefrst_anc filename linep using `"`christian_torben'df_all_namefrst_archive.dta"' if bad_segmentation==0 & namefrst_ml!=namefrst_anc & namefrst_ml!="" , clear			
				
				merge 1:1 filename linep using `"`correct_error_original'temptemp`location'.dta"',keepusing(histid namelast) nogen keep(1 3)
				
				merge m:1 histid using `"`original'matching_intgen`yr'.dta"',keepusing(age sex) keep(3) nogen
				
				rename (namefrst_ml namelast age) (namefrst_true namelast_true true_age)
				
				abeclean namefrst_true namelast_true,sex(sex) initial(mi) nickname nonysiis
				
				keep if namefrst`name_type'!="" & lower(namefrst`name_type')!="invalidpred" & namelast`name_type'!="" & true_age!=.
				
				keep namefrst`name_type' namelast`name_type' true_age histid mi
		
				save `"`intermediate'temp`location'_firstname.dta"',replace
				
		
		
				/*********************************************************************************/
				/*KEEP THE CORRECTED LAST NAME FROM THE PROTOTYPE CREATED BY CHRISTIAN AND TORBEN*/
				/*********************************************************************************/			
				use bad_segmentation namelast_ml namelast filename linep using `"`christian_torben'df_nonagreements_namelast_archive_extended_ver2_corrected.dta"' if bad_segmentation==0 & namelast_ml!=namelast & namelast_ml!="" , clear
				//use bad_segmentation namelast_ml namelast_anc filename linep using `"`christian_torben'df_all_namelast_archive.dta"' if bad_segmentation==0 & namelast_ml!=namelast_anc & namelast_ml!="" , clear			
				
				merge 1:1 filename linep using `"`correct_error_original'temptemp`location'.dta"',keepusing(histid namefrst) nogen keep(1 3)
				
				merge m:1 histid using `"`original'matching_intgen`yr'.dta"',keepusing(age sex) keep(3) nogen
				
				rename (namefrst namelast_ml age) (namefrst_true namelast_true true_age)
				
				abeclean namefrst_true namelast_true,sex(sex) initial(mi) nickname nonysiis
				
				keep if namefrst`name_type'!="" & lower(namelast`name_type')!="invalidpred" & namelast`name_type'!="" & true_age!=.
				
				keep namefrst`name_type' namelast`name_type' true_age histid mi
		
				save `"`intermediate'temp`location'_lastname.dta"',replace			
				
				
				
				/**********************************************************/
				/*COMBINE THE CORRECTED FIRST NAME AND CORRECTED LAST NAME*/
				/**********************************************************/			
				use `"`intermediate'temp`location'_firstname.dta"',clear
				
				rename (namefrst`name_type' namelast`name_type' true_age mi) (Fnamefrst Fnamelast Ftrue_age Fmi)
				
				merge 1:1 histid using `"`intermediate'temp`location'_lastname.dta"',keep(1 2 3)
				
				rename (namefrst`name_type' namelast`name_type' true_age mi) (Lnamefrst Lnamelast Ltrue_age Lmi)			
				
				gen namefrst`name_type'=Fnamefrst if _merge!=2
				replace namefrst`name_type'=Lnamefrst if _merge==2
				
				gen mi`name_type'=Fmi if _merge!=2
				replace mi`name_type'=Lmi if _merge==2
				
				gen namelast`name_type'=Lnamelast if _merge!=1
				replace namelast`name_type'=Fnamelast if _merge==1
				
				gen true_age=Ftrue_age if _merge!=2
				replace true_age=Ltrue_age if _merge==2
				
				keep namefrst`name_type' namelast`name_type' true_age histid mi`name_type'
				
				keep if namefrst`name_type'!="" & namelast`name_type'!=""
				
				save `"`intermediate'temp`location'.dta"',replace				






/*
/*
import delimited `"`original_d'\\`beg_yr'_1940.csv"',clear
keep histid1910 histid1940
rename (histid`beg_yr' histid1940) (id_A_centree id_B)
save `"`intermediate_nondb'\\`beg_yr'_1940.dta"',replace
*/



use `"`intermediate'link`beg_yr'_1940_ans_cleaned_noraceblock`fsnames'.dta"',clear

rename (id_A fiveyr_band mi`beg_yr' mi1940) (id_A_ans fiveyr_band_ans mi`beg_yr'_ans mi1940_ans)

merge 1:1 id_B using `"`intermediate'link`beg_yr'_1940_true_cleaned_noraceblock`fsnames'.dta"',keepusing(id_A fiveyr_band mi`beg_yr' mi1940) keep(1 3) nogen

merge 1:1 id_B using `"`intermediate_nondb'\\`beg_yr'_1940.dta"',keepusing(id_A_centree) keep(1 3)

gen not_linked_in_centree=_merge==1
drop _merge

gen same_link=(id_A_ans!="" & fiveyr_band_ans==1) & (id_A!="" & fiveyr_band==1) & id_A==id_A_ans
gen new_link=(id_A_ans==""|fiveyr_band_ans!=1) & id_A!="" & fiveyr_band==1

gen linked_before=fiveyr_band_ans==1
gen linked_after=fiveyr_band==1

gen link_removed=(id_A_ans!="" & fiveyr_band_ans==1) & (id_A==""|fiveyr_band!=1)
gen diff_link=(id_A_ans!="" & fiveyr_band_ans==1) & (id_A!="" & fiveyr_band==1) & id_A!=id_A_ans

gen val_before=mi`beg_yr'_ans==mi1940_ans if mi`beg_yr'_ans!="" & mi1940_ans!=""
gen val_after=mi`beg_yr'==mi1940 if mi`beg_yr'!="" & mi1940!=""

tab linked_before if name_true_cleaned_exists==1
sum val_before if name_true_cleaned_exists==1 & linked_before==1

tab linked_after if name_true_cleaned_exists==1
sum val_after if name_true_cleaned_exists==1 & linked_after==1

tab same_link if name_true_cleaned_exists==1
tab new_link if name_true_cleaned_exists==1
tab diff_link if name_true_cleaned_exists==1
tab link_removed if name_true_cleaned_exists==1










/*
use histid using `"`original'matching_intgen1940.dta"',clear
rename histid id_B

merge 1:1 id_B using `"`intermediate'link`beg_yr'_1940_ans_cleaned_noraceblock.dta"',keepusing(id_A fiveyr_band name_true_cleaned_exists) keep(1 3) nogen

rename (id_A fiveyr_band) (id_A_ans fiveyr_band_ans)

merge 1:1 id_B using `"`intermediate'link`beg_yr'_1940_true_cleaned_noraceblock`fsnames'.dta"',keepusing(id_A fiveyr_band) keep(1 3) nogen

gen same_link=(id_A_ans!="" & fiveyr_band_ans==1) & (id_A!="" & fiveyr_band==1) & id_A==id_A_ans
gen new_link=(id_A_ans==""|fiveyr_band_ans!=1) & id_A!="" & fiveyr_band==1
gen linked_before=fiveyr_band_ans==1
gen linked_after=fiveyr_band==1
gen link_removed=(id_A_ans!="" & fiveyr_band_ans==1) & (id_A==""|fiveyr_band!=1)
gen diff_link=(id_A_ans!="" & fiveyr_band_ans==1) & (id_A!="" & fiveyr_band==1) & id_A!=id_A_ans

tab linked_before if name_true_cleaned_exists!=1
tab link_removed if name_true_cleaned_exists!=1
tab new_link if name_true_cleaned_exists!=1
tab linked_after if name_true_cleaned_exists!=1
