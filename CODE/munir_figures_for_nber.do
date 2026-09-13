set scheme s1mono 
set seed 1000

/**********************************************************************/
/*ROOT PATHS: THESE ARE THE ONLY THREE LINES TO CHANGE IF FOLDERS MOVE.*/
/*Dropbox moved to the SNU ECON team folder; the code and the Overleaf */
/*project are now git repos under D:\repos\.                           */
/**********************************************************************/
local dropbox "D:\SNU ECON Dropbox\sam hwang\"
local code "D:\repos\fixing_transcription_errors\CODE\"
local overleaf "D:\repos\6638fa0fd89fbec05130caeb\"

local code_trans "`code'"
local original "`dropbox'fixing_transcription_errors\DATA\ORIGINAL\"
local trans_intermediate "`dropbox'fixing_transcription_errors\DATA\INTERMEDIATE\"
local intermediate "`dropbox'enum_date\DATA\INTERMEDIATE\"
local christian_torben "`dropbox'fixing_transcription_errors\DATA\TRANSCRIPTIONS\"
local intermediate_tr "`dropbox'fixing_transcription_errors\DATA\INTERMEDIATE\"
local original_ed "F:\enum_date\DATA\ORIGINAL\"
local intermediate_nondb "F:\enum_date\DATA\INTERMEDIATE\"
local trans_intermediate_f "F:\fixing_transcription_errors\DATA\INTERMEDIATE\"
local figure "`overleaf'figures\"

local beg_yr=1930
local label_size="1.05"
local label_position=12


/*
/************************************************************************/
/*IMPORT THE SOCIO-DEMOGRAPHIC CHARACTERISTICS OF RHODE ISLAND RESIDENTS*/
/************************************************************************/
do `"`code'usa00549_for_rhode_island_socio_demo_char.do"'
*/


/*
/*********************************************************************/
/*FIGURE 1: PICK THE ENUMERATION DISTRICT WITH THE AVERAGE LEGIBILITY*/
/*********************************************************************/
use `"`original'rhode_island_combined_with_nonditto_dummy.dta"',clear

merge 1:1 histid using `"`original'ancestry_rhode_island.dta"',keepusing(histid censuscounty eventdistrict sex) update

gen congruent=namefrst==fs_namefrst & namelast==fs_namelast if (_merge==3|_merge==4|_merge==5)
replace congruent=1 if _merge==2

bysort censuscounty eventdistrict: gen Nall=_N
bysort censuscounty eventdistrict: egen Ninc=total(congruent)
gen sh_cong=Ninc/Nall

bysort censuscounty eventdistrict: gen rep=_n==1

sum sh_cong,detail

gen diff_from_mean=abs(sh_cong-`r(mean)')

gsort diff_from_mean

tab eventdistrict if _n==1

merge 1:1 histid using `"`original_ed'rhode_island_socio_demo_char.dta"',keep(1 3) nogen

capture drop _merge
rename histid id_B
merge 1:1 id_B using `"`intermediate'link`beg_yr'_1940_ans_cleaned_noraceblock.dta"',keepusing(mi`beg_yr' mi1940 id_A fiveyr) keep(1 3)

gen linked_before=_merge==3 & fiveyr==1
gen validated_before=mi`beg_yr'==mi1940 if mi`beg_yr'!="" & mi1940!="" & linked_before==1

rename id_A id_A_before
drop mi`beg_yr' mi1940 fiveyr _merge


capture drop _merge
merge 1:1 id_B using `"`intermediate'link`beg_yr'_1940_true_cleaned_noraceblock.dta"',keepusing(mi`beg_yr' mi1940 id_A fiveyr) keep(1 3)

gen linked_after=_merge==3 & fiveyr==1
gen validated_after=mi`beg_yr'==mi1940 if mi`beg_yr'!="" & mi1940!="" & linked_after==1

rename id_A id_A_after
drop mi`beg_yr' mi1940 fiveyr _merge

numlabel,add

//gen congruentlegibility=namefrst==fs_namefrst & namelast==fs_namelast

bysort censuscounty eventdistrict: egen legibility=mean(congruent)

keep if sex==1 & age>=10

save `"`intermediate'temp.dta"',replace
*/


/*
/*******************************/
/*CREATE legibility_performance*/
/*******************************/
foreach val in 0 1 {

	capture cd `"`figure'"'
	
	if `val'==0 {
		local title="Incongruent transcription"
		local ytitle="Share linked"
	}
	else if `val'==1 {
		local title="Congruent transcription"
		local ytitle="Share linked"
	}

	use `"`intermediate'temp.dta"',clear	
	
	keep if congruent==`val'
	
	preserve
	
		keep linked_after sh_cong
		rename linked_after linked
		save `"`intermediate'temptemp.dta"',replace
	
	restore
	
	rename linked_before linked
	append using `"`intermediate'temptemp.dta"',gen(after) 
	binscatter linked sh_cong,by(after) saving(`val'.gph,replace) legend(order(1 "Before correction" 2 "After correction")) xtitle("Legibility") msymbols(circle_hollow diamond_hollow) mcolors(black%50 blue%50) ytitle(`"`ytitle'"') title(`"`title'"') linetype(none)
	
}

grc1leg 1.gph 0.gph,xcommon ycommon

graph export `"`figure'legibility_performance.pdf"', as(pdf) replace

capture erase 0.gph
capture erase 1.gph




/***************************************************************************************/
/*CREATE legibility_performance (USING WHETHER MACHINE TRANSCRIPTION IS CORRECT OR NOT)*/
/***************************************************************************************/
/*KEEP UNIQUE OBSERVATIONS FROM THE DANISH FILES*/
use `"`christian_torben'df_all_namefrst_archive_quality_tokens_round2.dta"',clear

bysort filename linep: keep if _N==1
rename (namefrst_anc namefrst_fams) (namefrst_danish fs_namefrst_danish)

save `"`christian_torben'temp1.dta"',replace

use `"`christian_torben'df_all_namelast_ditto_archive_quality_tokens_round2.dta"',clear

bysort filename linep: keep if _N==1
rename (namelast_anc namelast_fams) (namelast_danish fs_namelast_danish)

save `"`christian_torben'temp2.dta"',replace


use `"`original'rhode_island_combined_with_nonditto_dummy.dta"',clear
replace imagenumber_combined=imagenumber_combined+".jpg"
rename imagenumber_combined filename 
tostring linep,replace


merge 1:1 filename linep using `"`christian_torben'temp1.dta"',keepusing(namefrst_ml namefrst_danish fs_namefrst_danish) keep(1 3)
gen namefrst_merged=_merge==3 & namefrst==namefrst_danish & fs_namefrst==fs_namefrst_danish & namefrst_ml!=""
drop _merge

merge 1:1 filename linep using `"`christian_torben'temp2.dta"',keepusing(namelast_ml namelast_danish fs_namelast_danish) keep(1 3)
gen namelast_merged=_merge==3 & namelast==namelast_danish & fs_namelast==fs_namelast_danish & namelast_ml!=""
drop _merge

gen congruent=namefrst==fs_namefrst & namelast==fs_namelast if namefrst!="" & fs_namefrst!="" & namelast!="" & fs_namelast!=""

bysort county_folder_name eventdistrict: gen Nall=_N
bysort county_folder_name eventdistrict: egen Ninc=total(congruent)
gen sh_cong=Ninc/Nall

sum sh_cong,detail

/*MACHINE TRANSCRIPTION IS CORRECT FOR CONGRUENT TRANSCRIPTIONS IF THE MACHINE TRANSCRIPTION = HUMAN TRANSCRIPTION*/
gen machine_correct=namefrst==namefrst_ml & namelast==namelast_ml if congruent==1 & namefrst_merged==1 & namelast_merged==1

/*MACHINE TRANSCRIPTION IS CORRECT FOR INCONGRUENT TRANSCRIPTIONS IF THE MACHINE TRANSCRIPTION = ONE OF THE HUMAN TRANSCRIPTIONS*/
replace machine_correct=(namefrst==namefrst_ml|fs_namefrst==namefrst_ml) & (namelast==namelast_ml|fs_namelast==namelast_ml) if congruent==0 & namefrst_merged==1 & namelast_merged==1

capture cd `"`figure'"'

binscatter machine_correct sh_cong if congruent==1, saving(1.gph,replace) xtitle("Legibility") msymbols(diamond_hollow) mcolors(blue%50) title("Congruent") ytitle("Share of correct machine transcriptions") linetype(none)
binscatter machine_correct sh_cong if congruent==0, saving(0.gph,replace) xtitle("Legibility") msymbols(circle_hollow) mcolors(black%50) title("Incongruent") ytitle("") linetype(none)

graph combine 1.gph 0.gph,ycommon xcommon

graph export `"`figure'legibility_performance2.pdf"', as(pdf) replace
*/











/*******************************************************************************************************/
/*BUILD temp.dta: THE INPUT FOR BOTH BALANCE TABLES.                                                   */
/*                                                                                                     */
/*This loop was commented out and the temp.dta it produced has since been deleted, so both balance     */
/*tables below are unbuildable without it. Re-enabled.                                                 */
/*                                                                                                     */
/*It is a full-count pass over all 50 state files, so it is slow and only needs re-running when the     */
/*merged_<state>1940.dta files change. To skip it on a rerun, wrap it back in a block comment.         */
/*                                                                                                     */
/*At the county level, the share of records with transcription disagreement ranges from [X]\% to [Y]\%,*/
/*with notably higher rates occurring in urban areas ([Z]\% average disagreement),                     */
/*counties with above-median Black population ([W]\% average disagreement),                            */
/*and counties with below-median literacy rates ([V]\% average disagreement).                          */
/*******************************************************************************************************/
#delimit;
local full_stlist `" "Alabama" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "District of Columbia" "Florida" "Georgia"
 "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" 
 "Missouri" "Montana" "Nebraska" "Nevada" "New Hampshire" "New Jersey" "New Mexico" "New York" "North Carolina" "North Dakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" 
 "Rhode Island" "South Carolina" "South Dakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" 
 "Washington" "West Virginia" "Wisconsin" "Wyoming" "';
#delimit cr

local z=0
 
foreach curstatestr in `full_stlist' {

	qui do `"`code_trans'convert_state_name_to_file_name.do"' `"`curstatestr'"'
	local state_file_name="$state_file_name"
	
	use `"`trans_intermediate_f'merged_`state_file_name'1940.dta"',clear
	
	if _N>0 {
	
		local z=`z'+1	
	
		keep if _merge==1|_merge==3
		
		gen linked=_merge==3
		
		do `"`code_trans'create_socio_demographic_vars.do"'

		/*CLEAN NAMES*/
		foreach var in namefrst namelast namefrst_fs namelast_fs {

			replace `var'=lower(`var')

		}		

		gen bothname_nonmissing=namefrst!="" & namelast!=""
		gen incongruent=!(namefrst==namefrst_fs & namelast==namelast_fs) if linked==1 & namefrst!="" & namefrst_fs!="" & namelast!="" & namelast_fs!=""		
		
		label var incongruent "Incongruent transcription"
		label var linked "Two transcriptions are linked"
		
		#delimit;
		
		keep incongruent statefip countyicp edist linked age bpl bothname_nonmissing
		female northeast_bpl midwest_bpl south_bpl west_bpl foreign_born black american_indian asian 
		related_to_head grad_elem white_color farmer skilled unskilled urban farm incwage in_school
		father_foreign_born no_ed;
		
		#delimit cr
		
		if `z'>1 {
		
			append using `"`trans_intermediate_f'temp.dta"'
		
		}
		
		save `"`trans_intermediate_f'temp.dta"',replace

	}

}




/**********************************************************/
/*FIND VARIABLES THAT CORRELATE WITH INCONGRUENCY STRONGLY*/
/**********************************************************/
use `"`trans_intermediate_f'temp.dta"',clear

/*
#delimit;
foreach var in urban farm female black american_indian asian no_ed grad_elem foreign_born father_foreign_born in_school 
related_to_head northeast_bpl midwest_bpl south_bpl west_bpl white_color farmer skilled unskilled {;

	di `"`var' results shown below"';
	ttest incongruent,by(`var');

};
#delimit cr
*/

/*******************************************************************************/
/*TABLE: SOCIO-DEMOGRAPHIC CHARACTERISTICS OF THE ANALYSIS SAMPLE VS THE        */
/*POPULATION (tab:sample_characteristics in the paper). ALL STATES.             */
/*                                                                             */
/*Was: US | Northeast | Rhode Island. The Rhode Island column is dropped now    */
/*that the analysis sample is national. The Northeast column went with it -- it */
/*only ever existed as the intermediate reference between the US and RI, and    */
/*with RI gone it compares nothing. To put it back, re-insert                   */
/*"(mean if northeast==1)" as the second estimate.                             */
/*                                                                             */
/*The two columns are now:                                                     */
/*  col 1  the full population -- every record in temp.dta                     */
/*  col 2  the analysis sample -- records that are linked across the two        */
/*         transcriptions with all four names present, i.e. exactly the records */
/*         on which "incongruent" is defined and the paper's results rest.      */
/*Written to a NEW filename so the Rhode Island version is not clobbered.       */
/*******************************************************************************/
capture label var white_color "White-collar occupation"
capture label var skilled "Skilled occupation"
capture label var unskilled "Unskilled occupation"

keep if age>=10 & female==0

gen in_analysis_sample=incongruent!=.
label var in_analysis_sample "In analysis sample"

#delimit;

/*wide(mean) -- print only the means, dropping the standard-deviation second
                line, to match the Rhode Island table (which had been stripped
                of them by hand).  NOTE: the "oneline" option does the same job
                but only where a diff column exists; with this two-mean complex
                syntax it fails with "variable diff* not found", so wide(mean)
                is the right option here.
  nonumbers  -- ctitles() ADDS a title row, it does not replace balancetable's
                "(1) (2)" row; nonumbers is what removes that row.
  leftctitle -- without it the corner cell is filled with the word "Variable".*/
balancetable (mean) (mean if in_analysis_sample==1) incongruent black american_indian asian
northeast_bpl midwest_bpl south_bpl west_bpl foreign_born father_foreign_born
urban farm
no_ed grad_elem white_color skilled unskilled farmer incwage using `"`figure'balance_allstates.tex"',
varlabels replace wide(mean) nonumbers leftctitle("none") ctitles("US" "Analysis sample");

#delimit cr



/**********************************************************/
/*COMPARING PEOPLE CONGRUENT VS INCONGRUENT TRANSCRIPTIONS*/
/**********************************************************/
use `"`trans_intermediate_f'temp.dta"',clear

capture label var white_color "White-collar occupation"
capture label var skilled "Skilled occupation"
capture label var unskilled "Unskilled occupation"

/*ALL STATES: the "& statefip==44" restriction to Rhode Island is retired.*/
keep if age>=10 & female==0

#delimit;

balancetable incongruent black american_indian asian
northeast_bpl midwest_bpl south_bpl west_bpl foreign_born father_foreign_born
urban farm
no_ed grad_elem white_color skilled unskilled farmer incwage using `"`figure'incongruent_allstates.tex"',
varlabels replace oneline nonumbers leftctitle("none")
groups("Transcription" "\multirow{2}{*}{Diff.}", pattern(1 0 1) end("\cline{2-3}"))
ctitles("Congruent" "Incongruent" "");

#delimit cr





/*
/**********************************************************/
/*GEOGRAPHIC VARIATION OF INCONGRUENCY AT THE COUNTY LEVEL*/
/**********************************************************/
use `"`trans_intermediate_f'temp.dta"',clear


/*TTEST*/
sum age,detail

gen old=age>=`r(p50)'
gen below_30=age<30

sum incwage,detail
gen rich=incwage>=`r(p50)' if incwage!=.

foreach var in female old below_30 black american_indian asian northeast_bpl midwest_bpl south_bpl west_bpl foreign_born father_foreign_born urban farm no_ed grad_elem white_color skilled unskilled farmer rich {
	di `"`var' results below"'
	ttest incongruent,by(`var')
}
*/

/*
gen id=_n

#delimit;
collapse (count) N=id (mean) incongruent female age black american_indian asian 
northeast_bpl midwest_bpl south_bpl west_bpl foreign_born father_foreign_born
urban farm below_30 old
no_ed grad_elem white_color skilled unskilled farmer incwage rich, by(statefip countyicp);
#delimit cr

sum incongruent

foreach var in female age below_30 old black american_indian asian northeast_bpl midwest_bpl south_bpl west_bpl foreign_born father_foreign_born urban farm no_ed grad_elem white_color skilled unskilled farmer incwage {

	capture drop above_med

	di `"`var' results below"'
	sum `var',detail
	gen above_med=`var'>`r(p50)'
	
	ttest incongruent,by(above_med)
	
	/*
	capture drop above_med
	capture drop `var'_std
	sum `var'
	gen `var'_std=(`var'-`r(mean)')/`r(sd)'
	*/
	
}
*/

/*
/**************/
/*STANDARDIZED*/
/**************/
foreach var in incongruent female age black american_indian asian northeast_bpl midwest_bpl south_bpl west_bpl foreign_born urban farm grad_elem white_color skilled unskilled farmer incwage {
	capture drop `var'_std
	sum `var'
	gen `var'_std=(`var'-`r(mean)')/`r(sd)'
}

/*REGRESSION*/
#delimit;
reg incongruent_std female_std age_std black_std american_indian_std asian_std /*northeast_bpl_std*/ midwest_bpl_std south_bpl_std west_bpl_std foreign_born_std
 urban_std /*farm_std*/ grad_elem_std white_color_std skilled_std unskilled_std farmer_std incwage_std;
#delimit cr
*/



/*
/*******************************************/
/*POTENTIAL ERRORS IN MACHINE TRANSCRIPTION*/
/*******************************************/
use `"`christian_torben'df_all_namefrst_archive_quality_tokens_round2.dta"',clear

bysort filename linep: keep if _N==1
rename (namefrst_anc namefrst_fams) (namefrst fs_namefrst)

save `"`christian_torben'temp1.dta"',replace

use `"`christian_torben'df_all_namelast_ditto_archive_quality_tokens_round2.dta"',clear

bysort filename linep: keep if _N==1
rename (namelast_anc namelast_fams) (namelast fs_namelast)

save `"`christian_torben'temp2.dta"',replace

use `"`original'rhode_island_combined_with_nonditto_dummy.dta"',clear
replace imagenumber_combined=imagenumber_combined+".jpg"
rename imagenumber_combined filename 
tostring linep,replace

merge 1:1 filename linep using `"`christian_torben'temp1.dta"',/*keepusing(namefrst fs_namefrst namefrst_ml namefrst_ml_equals_namefrst_fams namefrst_ml_equals_namefrst_anc)*/ keep(1 3)
gen namefrst_merged=_merge==3
drop _merge

foreach var of varlist row-token_42 {
	rename `var' `var'_frst
}

merge 1:1 filename linep using `"`christian_torben'temp2.dta"',/*keepusing(namelast fs_namelast namelast_ml namelast_ml_equals_namelast_fams namelast_ml_equals_namelast_anc)*/ keep(1 3)
gen namelast_merged=_merge==3
drop _merge

foreach var of varlist row-token_42 {
	rename `var' `var'_last
}

keep if namefrst_merged==1 & namelast_merged==1

gen congruent=namefrst==fs_namefrst & namelast==fs_namelast

gen ml_incorrect_frst=namefrst_ml_frst!=namefrst if congruent==1
gen ml_incorrect_last=namelast_ml_last!=namelast if congruent==1
gen ml_correct_both_or_none=1 if congruent==1 & namefrst_ml_frst==namefrst & namelast_ml_last==namelast
//replace ml_correct_both_or_none=-1 if congruent==1 & namefrst_ml_frst!=namefrst & namelast_ml_last!=namelast /*IF I DO THIS, THEN THERE ARE NOT THAT MANY RECORDS I CAN USE FOR PANEL C*/
replace ml_correct_both_or_none=-1 if congruent==1 & !(namefrst_ml_frst==namefrst & namelast_ml_last==namelast)



jarowinkler namefrst namefrst_ml_frst,gen(jw_frst)
jarowinkler namelast namelast_ml_last,gen(jw_last)

/*********/
/*Panel B*/
/*********/
#delimit;

edit fs_namelast namelast namelast_ml_last if ml_incorrect_last==1 & nonditto==1 & jw_last>=0.8 & jw_last<1 &
(

(strpos(namelast,"a")>0 & strpos(namelast_ml_last,"a")==0 & strpos(namelast,"o")==0 & strpos(namelast_ml_last,"o")>0)
|(strpos(namelast,"o")>0 & strpos(namelast_ml_last,"o")==0 & strpos(namelast,"a")==0 & strpos(namelast_ml_last,"a")>0)

);

/*THIS IS HOW I FOUND ERNEST BOSSETTE*/

#delimit cr


/*********/
/*PANEL C*/
/*********/
keep if congruent==1 & jw_frst>=0.7 & jw_frst<=1 & jw_last>=0.7 & jw_last<=1 & nonditto==1

bysort namefrst namelast: egen max_=max(ml_correct_both_or_none)
bysort namefrst namelast: egen min_=min(ml_correct_both_or_none)

edit namefrst namelast namefrst_ml_frst namelast_ml_last ml_correct_both_ if max_==1 & min_==-1
*/



/*
/******************************************************/
/*DOCUMENT LEGIBILITY AND THE PERFORMANCE OF OUR MODEL*/
/******************************************************/
do `"`code'usa00589_for_rhode_island_socio_demo_char.do"'

/*********************************************************************/
/*FIGURE 1: PICK THE ENUMERATION DISTRICT WITH THE AVERAGE LEGIBILITY*/
/*********************************************************************/
use `"`original'rhode_island_combined_with_nonditto_dummy.dta"',clear

merge 1:1 histid using `"`original'ancestry_rhode_island.dta"',keepusing(histid censuscounty eventdistrict sex) update

gen congruent=namefrst==fs_namefrst & namelast==fs_namelast if (_merge==3|_merge==4|_merge==5)
replace congruent=1 if _merge==2

bysort censuscounty eventdistrict: gen Nall=_N
bysort censuscounty eventdistrict: egen Ninc=total(congruent)
gen sh_cong=Ninc/Nall

bysort censuscounty eventdistrict: gen rep=_n==1

sum sh_cong,detail

gen diff_from_mean=abs(sh_cong-`r(mean)')

gsort diff_from_mean

tab eventdistrict if _n==1

merge 1:1 histid using `"`original_ed'rhode_island_socio_demo_char.dta"',keep(1 3) nogen /*THIS IS CREATED IN usa00587_for_rhode_island_socio_demo_char.do*/

capture drop _merge
rename histid id_B
merge 1:1 id_B using `"`intermediate'link`beg_yr'_1940_ans_cleaned_noraceblock.dta"',keepusing(mi`beg_yr' mi1940 id_A fiveyr) keep(1 3)

gen linked_before=_merge==3 & fiveyr==1
gen validated_before=mi`beg_yr'==mi1940 if mi`beg_yr'!="" & mi1940!="" & linked_before==1

rename id_A id_A_before
drop mi`beg_yr' mi1940 fiveyr _merge


capture drop _merge
merge 1:1 id_B using `"`intermediate'link`beg_yr'_1940_true_cleaned_noraceblock.dta"',keepusing(mi`beg_yr' mi1940 id_A fiveyr) keep(1 3)

gen linked_after=_merge==3 & fiveyr==1
gen validated_after=mi`beg_yr'==mi1940 if mi`beg_yr'!="" & mi1940!="" & linked_after==1

rename id_A id_A_after
drop mi`beg_yr' mi1940 fiveyr _merge

numlabel,add

bysort censuscounty eventdistrict: egen legibility=mean(congruent)

/*RACE DUMMY*/
gen black=floor(raced/100)==2 if raced>=100 & raced<=620
gen american_indian=floor(raced/100)==3 if raced>=100 & raced<=620
gen asian=floor(raced/100)>=4 & floor(race/100)<=6 if raced>=100 & raced<=620

gen no_ed=higrade>=10 & higrade<=12 if higrade>=1 & higrade<=23
gen grad_elem=higrade>=11 & higrade<=23 if higrade>=1 & higrade<=23
label var grad_elem "Graduated elementary sch."

/*FOREIGN-BORN DUMMY*/
gen foreign_born=!(bpld>=100 & bpld<=12092) if bpld>=100 & bpld<=90022

/*FOREIGN-BORN FATHER DUMMY*/
gen father_foreign_born=!(fbpld>=100 & fbpld<=12092) if fbpld>=100 & fbpld<=90022

/*"CURRENTLY ENROLLED IN SCHOOL" DUMMY*/
gen in_school=school==2 if school>=1 & school<=2

/*"RELATED-TO-HEAD OF HOUSEHOLD" DUMMY*/
gen related_to_head=relate>=1 & relate<=10 if relate>=1 & relate<=13

/*"EVER MARRIED" DUMMY*/
gen ever_married=marst>=1 & marst<=5 if marst>=1 & marst<=6

/*BIRTH CENSUS REGION DUMMIES*/
gen northeast_bpl=(bpl==9|bpl==23|bpl==25|bpl==33|bpl==44|bpl==50|bpl==34|bpl==36|bpl==42) if bpl!=.
gen midwest_bpl=bpl==17|bpl==18|bpl==26|bpl==39|bpl==55|bpl==19|bpl==20|bpl==27|bpl==29|bpl==31|bpl==38|bpl==46 if bpl!=.
gen south_bpl=bpl==10|bpl==11|bpl==12|bpl==13|bpl==24|bpl==37|bpl==45|bpl==51|bpl==54|bpl==1|bpl==21|bpl==28|bpl==47|bpl==5|bpl==22|bpl==40|bpl==48 if bpl!=.
gen west_bpl=bpl==4|bpl==8|bpl==16|bpl==30|bpl==32|bpl==35|bpl==49|bpl==56|bpl==2|bpl==6|bpl==15|bpl==41|bpl==53 if bpl!=.

/*********************************************************************************/
/*OCCUPATION CATEGORIES BASED ON LONG AND FERRIE (2013, AMERICAN ECONOMIC REVIEW)*/
/*********************************************************************************/
#delimit;
/*WHITE COLLAR*/
gen white_color=(occ1950>=0 & occ1950<=99)| /*PROFESSIONAL, TECHNICAL*/
(occ1950>=200 & occ1950<=290)| /*MANAGERS, OFFICIALS, AND PROPRIETORS*/
(occ1950>=300 & occ1950<=390)| /*CLERICAL*/
(occ1950>=400 & occ1950<=490) if occ1950!=. & occ1950>=0 & occ1950<=970; /*SALES*/

label var white_color "White-collar";

/*FARMER*/
gen farmer=occ1950==100|occ1950==123 if occ1950!=. & occ1950>=0 & occ1950<=970; /*FARM OWNERS (INCLUDING TENANTS, BECAUSE WE CANNOT DIFFERENTIATE BETWEEN OWNER AND TENANTS) AND FARM MANAGERS*/

label var farmer "Farmer";

/*SKILLED*/
gen skilled=(occ1950>=500 & occ1950<=595)| /*CRAFTSMEN*/
(occ1950>=600 & occ1950<=690) if occ1950!=. & occ1950>=0 & occ1950<=970; /*OPERATIVES*/

label var skilled "Skilled";

/*UNSKILLED*/
gen unskilled=(occ1950>=700 & occ1950<=790)| /*SERVICE WORKERS*/
(occ1950>=810 & occ1950<=840)| /*FARM LABORERS*/
(occ1950>=910 & occ1950<=970) if occ1950!=. & occ1950>=0 & occ1950<=970; /*LABORERS*/

label var unskilled "Unskilled";

#delimit cr

/*RECODE EXISTING VARIABLES*/
replace urban=. if !(urban>=1 & urban<=2)
replace farm=. if !(farm>=1 & farm<=2)

recode urban (2=1) (1=0)
replace urban=. if urban!=1 & urban!=0

recode farm (2=1) (1=0)
replace farm=. if farm!=1 & farm!=0	

/*INCOME AND WAGE*/
replace incwage=. if incwage>5001

gen below_30=age<30

sum incwage,d
gen poor=incwage<`r(p50)' if incwage!=.

sum legibility if rep==1, d
gen lowest_quartile_leg=legibility<=`r(p25)'

keep if sex==1 & age>=10

/*WHO IS DIFFICULT TO LINK*/
foreach var in below_30 black american_indian asian northeast_bpl midwest_bpl south_bpl west_bpl foreign_born father_foreign_born urban farm no_ed grad_elem white_color skilled unskilled farmer poor non_english_mtongue {
	di `"`var'"'
	ttest linked_before,by(`var')
}

/*DIFFICULT TO LINK: NON-WHITES, SOUTHERN BORN, OR FOREIGN BORN*/
gen difficult_to_link=black==1|american_indian==1|asian==1|south_bpl==1|foreign_born==1

bysort censuscounty eventdistrict: replace rep=_n==1
bysort censuscounty eventdistrict: egen base_linkage_rate=mean(linked_before)
bysort censuscounty eventdistrict: egen sh_difficult=mean(difficult_to_link)

ttest legibility if rep==1,by(lowest_quartile_leg)
ttest base_linkage_rate if rep==1,by(lowest_quartile_leg)
ttest sh_difficult if rep==1,by(lowest_quartile_leg)
*/
/*^^ This closing delimiter was missing: the block comment opened above ran off
  the end of the file. Harmless while nothing below it mattered, but the file
  now has to run to completion for the balance tables, so it is closed here.*/
