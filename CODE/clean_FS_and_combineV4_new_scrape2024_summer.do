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

local full_stlist `" "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "District of Columbia" "Florida" "Georgia"
 "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" 
 "Missouri" "Montana" "Nebraska" "Nevada" "New Hampshire" "New Jersey" "New Mexico" "New York" "North Carolina" "North Dakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" 
 "Rhode Island" "South Carolina" "South Dakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" 
 "Washington" "West Virginia" "Wisconsin" "Wyoming" "';

/*************************************************************************************************************/
/*FIRST WE NEED TO FIGURE OUT HOW WE SHOULD MODIFY THE FS ROLL NUMBER SO THAT IT MATCHES ANCESTRY ROLL NUMBER*/
/*************************************************************************************************************/ 
foreach curstatestr in /*"Alabama"*/ "Rhode Island" {;

	do `"`code_trans'convert_state_name_to_file_name.do"' `"`curstatestr'"';
	
	local ancestry_file_name="$ancestry_file_name";
	local scraper_ass_num=$scraper_ass_num;

	local sheet_id1="nararollnumber imagenumber sheetnumberletter";
	local sheet_id2="nararollnumber censuscounty eventdistrict sheetnumberletter";	


	/******************************************/
	/*KEEP UNIQUE RECORDS IN THE ANCESTRY FILE*/
	/******************************************/	
	use `"`trans_original'ancestry_`ancestry_file_name'.dta"',clear;
	
	di "Number of all ancestry records: ",_N;
	
	bysort `sheet_id1' linep namefrst namelast age: keep if _n==1;
	
	bysort `sheet_id1': egen min_linep=min(linep);	
	
	di "After dropping duplicate records: ",_N;	
	
	bysort `sheet_id1' linep: gen N1=_N;
	
	bysort `sheet_id1' linep namefrst namelast age: gen N2=_N;
	
	keep if N1==N2;
	
	bysort `sheet_id1' linep: keep if _n==1;
	
	di "After dropping records with potentially duplicate indexing: ",_N;
	
	drop N1 N2;
	
	capture drop _merge;
	
	count;
	
	save `"`trans_original'temp.dta"',replace;


	/**********************************************/
	/*OBTAIN THE MINIMUM LINE NUMBER FOR EACH PAGE*/
	/**********************************************/	
	foreach n in 1 2 {;

		use `"`trans_original'ancestry_`ancestry_file_name'.dta"',clear;
		
		bysort `sheet_id`n'': egen min_linep=min(linep);	
		
		keep `sheet_id`n'' min_linep;
		
		bysort `sheet_id`n'': keep if _n==1;
		
		save `"`trans_original'temptemp`n'.dta"',replace;
	
	};
	
	/*******************************/
	/*IMPORT NEWLY SCRAPED FS FILES*/
	/*******************************/	
	import delimited `"`telegram'\\`ancestry_file_name'1.csv"',clear varnames(1) delimiter(comma) bindquote(strict) encoding(utf8);
	keep event_county event_district_orig fs_record source_line_nbr_orig pr_name_gn_orig_1 pr_name_surn_orig_1 pr_age_orig source_sheet_nbr_orig source_sheet_ltr_orig;
	save `"`trans_original'temp1.dta"',replace;
	
	capture import delimited `"`telegram'\\`ancestry_file_name'2.csv"',clear varnames(1) delimiter(comma) bindquote(strict) encoding(utf8);
	keep event_county event_district_orig fs_record source_line_nbr_orig pr_name_gn_orig_1 pr_name_surn_orig_1 pr_age_orig source_sheet_nbr_orig source_sheet_ltr_orig;
	save `"`trans_original'temp2.dta"',replace;	
	
	capture import delimited `"`telegram'\\`ancestry_file_name'3.csv"',clear varnames(1) delimiter(comma) bindquote(strict) encoding(utf8);		
	keep event_county event_district_orig fs_record source_line_nbr_orig pr_name_gn_orig_1 pr_name_surn_orig_1 pr_age_orig source_sheet_nbr_orig source_sheet_ltr_orig;	
	append using `"`trans_original'temp1.dta"';
	append using `"`trans_original'temp2.dta"';	
	
	count;
	
	/*****************************/
	/*CLEAN VARIABLES IN FS FILES*/
	/*****************************/
	/*ROLL, IMAGE, AND LINE NUMBER*/
	split fs_record_id,parse("_");
	
	destring fs_record_id1 fs_record_id2 fs_record_id3, replace;
	
	sum fs_record_id1;
	replace fs_record_id1=fs_record_id1-5457995;	
	
	/*SHEET NUMBER AND LETTER*/
	tostring source_sheet_nbr_orig,replace;
	
	gen sheetnumberletter=source_sheet_nbr_orig+source_sheet_ltr_orig;
	
	gen narapublicationnumber="T627";
	

	rename (event_county event_district_orig fs_record_id1 fs_record_id2 source_line_nbr_orig pr_name_gn_orig_1 pr_name_surn_orig_1 pr_age_orig fs_record_id3)
	       (censuscounty eventdistrict nararollnumber imagenumber linep firstname lastname age ll);
	
	di "Number of all FamilySearch records: ",_N;	
	
	keep censuscounty eventdistrict narapublicationnumber imagenumber linep firstname lastname age linep sheetnumberletter ll nararollnumber;
	
	/*MERGE MINIMUM PLINE NUMBER OF EACH PAGE*/
	merge m:1 `sheet_id1' using `"`trans_original'temptemp1.dta"',keep(1 3) nogen;
	rename min_linep min_linep1;

	merge m:1 `sheet_id2' using `"`trans_original'temptemp2.dta"',keep(1 3) nogen;	
	rename min_linep min_linep2;	
	
	gen over41=min_linep1>=41 if min_linep1!=.;
	replace over41=min_linep2>=41 if over41==. & min_linep2!=.;
	
	
	/*INFER LINE NUMBER*/
	rename linep linep_orig;
	gen linep=linep_orig if linep_orig!=.;
	replace linep=ll+1 if linep==. & over41==0;
	replace linep=ll+41 if linep==. & over41==1;

	
	/*DROP RECORDS WITH MISSING VALUES IN KEY VARIABLES*/
	foreach v in `sheet_id1' linep firstname lastname age {;
	
		capture drop if `v'=="";
		
		if _rc!=0 {;
		
			di `"`v'"';
			drop if `v'==.;
		
		};
		else if _rc==0 & `"`v'"'=="linenumber" {;
		
			di `"`v'"';		
			drop if real(linep)==.;
			destring linep,replace;			
		
		};
	
	};
	
	di "After dropping records with missing values: ",_N;		
	
	rename (eventdistrict firstname lastname age) (fs_eventdistrict fs_namefrst fs_namelast fs_age);

	bysort `sheet_id1' linep fs_namefrst fs_namelast fs_age: keep if _n==1;
	
	di "After dropping duplicate records: ",_N;	
	
	bysort `sheet_id1' linep: gen N1=_N;
	
	bysort `sheet_id1' linep fs_namefrst fs_namelast fs_age: gen N2=_N;
	
	keep if N1==N2;
	
	bysort `sheet_id1' linep: keep if _n==1;
	
	drop N1 N2;
	
	di "After dropping records with potentially duplicate indexing: ",_N;


	
	/*MERGE AS AND FS FILES AND CLEAN FURTHER*/
	capture drop _merge;
	
	merge 1:1 `sheet_id1' linep using `"`trans_original'temp.dta"',keep(1 2 3);
	
	foreach var in fs_namefrst fs_namelast namelast namefrst {;
	
		replace `var'=lower(`var');
	
	};
	
	gen county_folder_name=lower(censuscounty)+"-county";
	
	tostring nararollnumber imagenumber,gen(temp1 temp2);
	
	foreach n in 1 2 {;
	
		replace temp`n'="0"+temp`n' if strlen(temp`n')==4;
		replace temp`n'="00"+temp`n' if strlen(temp`n')==3;	
		replace temp`n'="000"+temp`n' if strlen(temp`n')==2;		
		replace temp`n'="0000"+temp`n' if strlen(temp`n')==1;			
		
	};
	
	gen imagenumber_combined="m-t0627-"+temp1+"-"+temp2;

	drop temp1 temp2;

	gsort county_folder_name fs_eventdistrict imagenumber_combined linep;
	
	order county_folder_name eventdistrict fs_eventdistrict imagenumber_combined linep namefrst fs_namefrst namelast fs_namelast age fs_age;

	/*KEEP THE UNLINKED RECORDS PER REQUEST OF CHRISTIAN (FOR TESTING PURPOSES)*/
	preserve;
	
		keep if _merge==1|_merge==2;
		
		rename (fs_eventdistrict fs_namefrst fs_namelast fs_age eventdistrict namefrst namelast age) (eventdistrict1 namefrst1 namelast1 age1 eventdistrict2 namefrst2 namelast2 age2);
		
		reshape long namefrst namelast age eventdistrict,i(`sheet_id1' linep) j(trans_no);
		
		keep if trans_no==_merge;
	
		save `"`trans_original'\\`ancestry_file_name'_unlinked.dta"', replace;		
	
	restore;
	
	keep if _merge==3;
	
	gen matched_on_imagenumber=_merge==3;
	
	drop _merge fs_eventdistrict; /*WE MANUALLY CHECKED eventdistrict AND fs_eventdistrict WHEN THEY ARE DIFFERENT FROM EACH OTHER, AND eventdistrict APPEARS TO BE CORRECT MORE OFTEN*/
	
	save `"`trans_original'\\`ancestry_file_name'_combined.dta"', replace;

	
};

//capture erase `"`trans_original'temp.dta"'
//capture erase `"`trans_original'temp1.dta"'
