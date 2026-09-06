local original "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\"

set seed 1000

use `"`original'rhode_island_unlinked.dta"',clear

bysort nararoll county_folder eventdistrict sheetnumberletter linep: keep if _N==2
bysort nararoll county_folder eventdistrict sheetnumberletter linep: egen min_trans_no=min(trans_no)
bysort nararoll county_folder eventdistrict sheetnumberletter linep: egen max_trans_no=max(trans_no)
keep if min_trans_no==1|max_trans_no==2

gsort nararoll county_folder eventdistrict sheetnumberletter linep trans_no
bysort nararoll county_folder eventdistrict sheetnumberletter linep: gen diff=imagenumber[1]-imagenumber[2]

egen temp_id=group(nararoll county_folder eventdistrict sheetnumberletter linep)

/*
/*SAMPLE 100 PAIRS OF RECORDS AND CHECK IF ANCESTRY AND FAMILYSEARCH RECORDS IN FACT CORRESPOND TO THE SAME RECORDS*/
/*ALSO CHECK IF FAMILYSEARCH IMAGENUMBERS ARE IN FACT THE TRUE IMAGENUMBER*/

preserve

	keep if trans_no==1 /*KEEP ONLY THE FAMILYSEARCH RECORDS*/

	sample 100,count
	
	save `"`original'temp.dta"',replace

restore

merge m:1 temp_id using `"`original'temp.dta"',keep(3) nogen

gsort temp_id trans_no
edit county_folder eventdistrict nararoll imagenumber trans_no linep namefrst namelast age

/*CHECKED!*/
*/

gsort temp_id trans_no

/*ASSIGN VALUES OF VARIABLE THAT EXIST EITHER IN FS RECORDS OR ANCESTRY (BUT NOT BOTH)*/
foreach var in histid serial sex image_id_sam enumdist {
	by temp_id: replace `var'=`var'[2] if _n==1
}

by temp_id: replace narapublicationnumber=narapublicationnumber[1] if _n==2

drop _merge min_trans_no max_trans_no
capture drop pernum lineh

reshape wide imagenumber imagenumber_combined namefrst namelast age,i(temp_id) j(trans_no)


/*RENAME VARIABLES*/
foreach var in imagenumber imagenumber_combined namefrst namelast age {
	rename (`var'1 `var'2) (fs_`var' `var')
}

drop imagenumber imagenumber_combined temp_id
rename (fs_imagenumber fs_imagenumber_combined) (imagenumber imagenumber_combined)

save `"`original'temp1.dta"', replace





/*********************/
/*IDENTIFY NON-DITTOS*/
/*********************/
use `"`original'rhode_island_combined.dta"',clear

append using `"`original'temp1.dta"',gen(test_sample)
replace test_sample=0 if namefrst!=fs_namefrst|namelast!=fs_namelast|age!=fs_age



/*
/*INVESTIGATE RECORDS THAT ARE ONLY IN RHODE ISLAND*/
merge 1:1 histid using `"`original'ancestry_rhode_island.dta"',keep(2) nogen

sample 100,count
*/



gsort nararollnumber imagenumber linep

/*SAME OR CONSECUTIVE NARA ROLL NUMBER*/
gen same_nararollnumber=nararollnumber[_n]==nararollnumber[_n-1]
gen consecutive_nararollnumber=nararollnumber[_n]==(nararollnumber[_n-1]+1)

/*SAME OR CONSECUTIVE IMAGE NUMBER*/
gen same_image=imagenumber[_n]==imagenumber[_n-1]
gen consecutive_image=imagenumber[_n]==(imagenumber[_n-1]+1)

/*CONSECUTIVE LINE NUMBERS*/
gen consecutive_linep=linep[_n]==(linep[_n-1]+1)
gen consecutive_linep_pagechange=(linep[_n]==1 & linep[_n-1]==80)|(linep[_n]==41 & linep[_n-1]==40)

gen namelast_change=namelast[_n]!=namelast[_n-1]

#delimit;

gen nonditto=(same_nararollnumber==1 & same_image==1 & consecutive_linep==1 & namelast_change==1)|
(same_nararollnumber==1 & consecutive_image==1 & consecutive_linep_pagechange==1 & namelast_change==1);

#delimit cr

drop same_nararollnumber-namelast_change

//save `"`original'rhode_island_combined_with_nonditto_dummy.dta"',replace

//export delimited using `"`original'rhode_island_combined_with_nonditto_dummy.csv"', replace



capture erase `"`original'temp1.dta"'
