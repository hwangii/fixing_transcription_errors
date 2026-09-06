local original "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\"

local state="rhode_island"

set seed 1000

use `"`original'\\`state'_unlinked.dta"',clear

bysort nararoll censuscounty eventdistrict sheetnumberletter linep: keep if _N==2
bysort nararoll censuscounty eventdistrict sheetnumberletter linep: egen min_trans_no=min(trans_no)
bysort nararoll censuscounty eventdistrict sheetnumberletter linep: egen max_trans_no=max(trans_no)

keep if min_trans_no==1 & max_trans_no==2

gsort nararoll county_folder eventdistrict sheetnumberletter linep trans_no
bysort nararoll county_folder eventdistrict sheetnumberletter linep: gen diff=imagenumber[1]-imagenumber[2]

egen temp_id=group(nararoll county_folder eventdistrict sheetnumberletter linep)

gsort temp_id trans_no

/*ASSIGN VALUES OF VARIABLE THAT EXIST EITHER IN FS RECORDS OR ANCESTRY (BUT NOT BOTH)*/
foreach var in histid serial sex image_id_sam enumdist {
	by temp_id: replace `var'=`var'[2] if _n==1
}

foreach var in narapublicationnumber linep_orig {
	by temp_id: replace `var'=`var'[1] if _n==2
}

/*DROP UNNECESSARY VARIABLES*/
foreach v in _merge min_trans_no max_trans_no linenumber_orig ll min_linep min_linep1 min_linep2 pernum lineh over41 {
	capture drop `v'
}

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
use `"`original'\\`state'_combined.dta"',clear

append using `"`original'temp1.dta"',gen(incorrect_imagenumber)


preserve

	/*SAMPLE 100 RECORDS THAT ARE MATCHED ON INFERRED LINE OR HAVE INCORRECT IMAGE NUMBER*/
	keep if (namefrst!=fs_namefrst|namelast!=fs_namelast|age!=fs_age) & ((matched_on_imagenumber==1 & linep_orig==.)|(incorrect_imagenumber==1)) /*KEEP ONLY THE FAMILYSEARCH RECORDS*/

	sample 100,count

	gsort censuscounty eventdistrict imagenumber linep
	edit censuscounty eventdistrict imagenumber linep namefrst fs_namefrst namelast fs_namelast age fs_age

restore


//replace test_sample=0 if namefrst!=fs_namefrst|namelast!=fs_namelast|age!=fs_age

/*
/*INVESTIGATE RECORDS THAT ARE ONLY IN RHODE ISLAND*/
merge 1:1 histid using `"`original'ancestry_`state'.dta"',keep(2) nogen

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

//save `"`original'\\`state'_combined_with_nonditto_dummy.dta"',replace

//export delimited using `"`original'\\`state'_combined_with_nonditto_dummy.csv"', replace



//capture erase `"`original'temp1.dta"'
