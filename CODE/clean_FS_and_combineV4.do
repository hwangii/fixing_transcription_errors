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

local full_stlist `" "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "District of Columbia" "Florida" "Georgia"
 "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" 
 "Missouri" "Montana" "Nebraska" "Nevada" "New Hampshire" "New Jersey" "New Mexico" "New York" "North Carolina" "North Dakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" 
 "Rhode Island" "South Carolina" "South Dakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" 
 "Washington" "West Virginia" "Wisconsin" "Wyoming" "';



foreach curstatestr in "Rhode Island" {;

	if `"`curstatestr'"'=="Alabama" {;
		local scraper_ass_num=1;
		local ancestry_file_name="alabama";		
	};
	if `"`curstatestr'"'=="Alaska" {;
		local scraper_ass_num=2;
	};	
	else if `"`curstatestr'"'=="Arizona" {;
		local scraper_ass_num=4;
	};
	else if `"`curstatestr'"'=="Arkansas" {;
		local scraper_ass_num=5;
	};
	else if `"`curstatestr'"'=="California" {;
		local scraper_ass_num=6;
	};
	else if `"`curstatestr'"'=="Colorado" {;
		local scraper_ass_num=7;
	};
	else if `"`curstatestr'"'=="Connecticut" {;
		local scraper_ass_num=8;
	};
	else if `"`curstatestr'"'=="Delaware" {;
		local scraper_ass_num=9;
	};
	else if `"`curstatestr'"'=="District of Columbia" {;
		local scraper_ass_num=10;
	};
	else if `"`curstatestr'"'=="Florida" {;
		local scraper_ass_num=11;
	};
	else if `"`curstatestr'"'=="Georgia" {;
		local scraper_ass_num=12;
	};	
	else if `"`curstatestr'"'=="Hawaii" {;
		local scraper_ass_num=14;
	};
	else if `"`curstatestr'"'=="Idaho" {;
		local scraper_ass_num=15;
	};
	else if `"`curstatestr'"'=="Illinois" {;
		local scraper_ass_num=16;
	};
	else if `"`curstatestr'"'=="Indiana" {;
		local scraper_ass_num=17;
	};
	else if `"`curstatestr'"'=="Iowa" {;
		local scraper_ass_num=18;
	};
	else if `"`curstatestr'"'=="Kansas" {;
		local scraper_ass_num=19;
	};
	else if `"`curstatestr'"'=="Kentucky" {;
		local scraper_ass_num=20;
	};
	else if `"`curstatestr'"'=="Louisiana" {;
		local scraper_ass_num=21;
	};
	else if `"`curstatestr'"'=="Maine" {;
		local scraper_ass_num=22;
	};
	else if `"`curstatestr'"'=="Maryland" {;
		local scraper_ass_num=23;
	};
	else if `"`curstatestr'"'=="Massachusetts" {;
		local scraper_ass_num=24;
	};
	else if `"`curstatestr'"'=="Michigan" {;
		local scraper_ass_num=25;
	};
	else if `"`curstatestr'"'=="Minnesota" {;
		local scraper_ass_num=26;
	};
	else if `"`curstatestr'"'=="Mississippi" {;
		local scraper_ass_num=27;
	};	
	else if `"`curstatestr'"'=="Missouri" {;
		local scraper_ass_num=28;
	};
	else if `"`curstatestr'"'=="Montana" {;
		local scraper_ass_num=29;
	};
	else if `"`curstatestr'"'=="Nebraska" {;
		local scraper_ass_num=30;
	};
	else if `"`curstatestr'"'=="Nevada" {;
		local scraper_ass_num=31;
	};
	else if `"`curstatestr'"'=="New Hampshire" {;
		local scraper_ass_num=32;
	};
	else if `"`curstatestr'"'=="New Jersey" {;
		local scraper_ass_num=33;
	};	
	else if `"`curstatestr'"'=="New Mexico" {;
		local scraper_ass_num=34;
	};	
	else if `"`curstatestr'"'=="New York" {;
		local scraper_ass_num=35;
	};
	else if `"`curstatestr'"'=="North Carolina" {;
		local scraper_ass_num=36;
	};
	else if `"`curstatestr'"'=="North Dakota" {;
		local scraper_ass_num=37;
	};	
	else if `"`curstatestr'"'=="Ohio" {;
		local scraper_ass_num=38;
	};	
	else if `"`curstatestr'"'=="Oklahoma" {;
		local scraper_ass_num=39;
	};
	else if `"`curstatestr'"'=="Oregon" {;
		local scraper_ass_num=40;
	};
	else if `"`curstatestr'"'=="Pennsylvania" {;
		local scraper_ass_num=42;
	};
	else if `"`curstatestr'"'=="Rhode Island" {;
		local scraper_ass_num=44;
		local ancestry_file_name="rhode_island";
	};	
	else if `"`curstatestr'"'=="South Carolina" {;
		local scraper_ass_num=45;
	};
	else if `"`curstatestr'"'=="South Dakota" {;
		local scraper_ass_num=46;
	};
	else if `"`curstatestr'"'=="Tennessee" {;
		local scraper_ass_num=47;
	};
	else if `"`curstatestr'"'=="Texas" {;
		local scraper_ass_num=48;
	};
	else if `"`curstatestr'"'=="Utah" {;
		local scraper_ass_num=49;
	};
	else if `"`curstatestr'"'=="Vermont" {;
		local scraper_ass_num=50;
	};
	else if `"`curstatestr'"'=="Virginia" {;
		local scraper_ass_num=52;
	};
	else if `"`curstatestr'"'=="Washington" {;
		local scraper_ass_num=53;
	};
	else if `"`curstatestr'"'=="West Virginia" {;
		local scraper_ass_num=54;
	};
	else if `"`curstatestr'"'=="Wisconsin" {;
		local scraper_ass_num=55;
	};
	else if `"`curstatestr'"'=="Wyoming" {;
		local scraper_ass_num=56;
	};
	
	
	/*KEEP UNIQUE RECORDS IN THE ANCESTRY FILE*/
	use `"`trans_original'ancestry_`ancestry_file_name'.dta"',clear;
	
	di "Number of all ancestry records: ",_N;
	
	bysort nararollnumber imagenumber sheetnumberletter linep namefrst namelast age: keep if _n==1;
	
	di "After dropping duplicate records: ",_N;	
	
	bysort nararollnumber imagenumber sheetnumberletter linep: gen N1=_N;
	
	bysort nararollnumber imagenumber sheetnumberletter linep namefrst namelast age: gen N2=_N;
	
	keep if N1==N2;
	
	bysort nararollnumber imagenumber sheetnumberletter linep: keep if _n==1;
	
	di "After dropping records with potentially duplicate indexing: ",_N;
	
	drop N1 N2;
	
	capture drop _merge;
	
	save `"`trans_original'temp.dta"',replace;
	

	
	/*IMPORT AND CLEAN FS FILE*/
	capture import delimited `"`original_ext'\\[#`scraper_ass_num'] `curstatestr'.csv"',clear varnames(1) delimiter(comma) bindquote(strict) encoding(utf8);
	
	count;
	
	di "Number of all ancestry records: ",_N;	
	
	keep censuscounty eventdistrict narapublicationnumber nararollnumber imagenumber linenumber firstname lastname age linenumber sheetnumberletter;
	
	foreach v in narapublicationnumber nararollnumber imagenumber sheetnumberletter linenumber firstname lastname age {;
	
		capture drop if `v'=="";
		
		if _rc!=0 {;
		
			drop if `v'==.;
		
		};
		else if _rc==0 & `"`v'"'=="linenumber" {;
		
			drop if real(linenumber)==.;
			destring linenumber,replace;			
		
		};
	
	};
	
	di "After dropping records with missing values: ",_N;		
	
	rename (eventdistrict firstname lastname age linenumber) (fs_eventdistrict fs_namefrst fs_namelast fs_age linep);

	bysort nararollnumber imagenumber sheetnumberletter linep fs_namefrst fs_namelast fs_age: keep if _n==1;
	
	di "After dropping duplicate records: ",_N;	
	
	bysort nararollnumber imagenumber sheetnumberletter linep: gen N1=_N;
	
	bysort nararollnumber imagenumber sheetnumberletter linep fs_namefrst fs_namelast fs_age: gen N2=_N;
	
	keep if N1==N2;
	
	bysort nararollnumber imagenumber sheetnumberletter linep: keep if _n==1;
	
	drop N1 N2;
	
	di "After dropping records with potentially duplicate indexing: ",_N;
	

	
	/*MERGE AS AND FS FILES AND CLEAN FURTHER*/
	capture drop _merge;
	
	merge 1:1 nararollnumber imagenumber sheetnumberletter linep using `"`trans_original'temp.dta"',keep(1 2 3);
	
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
		
		reshape long namefrst namelast age eventdistrict,i(nararollnumber imagenumber sheetnumberletter linep) j(trans_no);
		
		keep if trans_no==_merge;
	
		save `"`trans_original'\\`ancestry_file_name'_unlinked.dta"', replace;		
		//save `"`trans_original'alabama_unlinked.dta"', replace;				
	
	restore;
	
	keep if _merge==3;
	
	drop _merge fs_eventdistrict; /*WE MANUALLY CHECKED eventdistrict AND fs_eventdistrict WHEN THEY ARE DIFFERENT FROM EACH OTHER, AND eventdistrict APPEARS TO BE CORRECT MORE OFTEN*/
	
	save `"`trans_original'\\`ancestry_file_name'_combined.dta"', replace;
	//save `"`trans_original'alabama_combined.dta"', replace;	
	
};

capture erase `"`trans_original'temp.dta"'
