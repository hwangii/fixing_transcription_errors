local matching_vars="namefrst namelast age roll imageno"

use "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\ancestry_rhode_island1850.dta",clear
//use "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\temptemptemp.dta",clear
bysort `matching_vars': keep if _N==1
capture drop _merge
save "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\temptemp.dta",replace

import delimited "C:\Users\suntr\Downloads\Telegram Desktop\1850 Rhode Island - NEW\Export - Images - 1.csv", bindquote(strict) stripquote(yes) encoding(utf8) clear
save "C:\Users\suntr\Downloads\Telegram Desktop\1850 Rhode Island - NEW\temp1.dta",replace

import delimited "C:\Users\suntr\Downloads\Telegram Desktop\1850 Rhode Island - NEW\Export - Records - 1.csv", bindquote(strict) stripquote(yes) encoding(utf8) clear
save "C:\Users\suntr\Downloads\Telegram Desktop\1850 Rhode Island - NEW\temp3.dta",replace

import delimited "C:\Users\suntr\Downloads\Telegram Desktop\1850 Rhode Island - NEW\Export - Persons - 1.csv", bindquote(strict) stripquote(yes) encoding(utf8) clear
save "C:\Users\suntr\Downloads\Telegram Desktop\1850 Rhode Island - NEW\temp2.dta",replace

split fs_sort_key,parse("_")
drop if real(fs_sort_key1)==.
destring fs_sort_key1 fs_sort_key2 fs_sort_key3 fs_sort_key4,replace

rename (fs_sort_key1 fs_sort_key2) (roll imageno)

replace roll=roll-4190815

gen namefrst=upper(pr_name_gn_1)
gen namelast=upper(pr_name_surn_1)
rename pr_age age

split age,parse(" years")
gen age_cleaned=real(age1) if real(age1)!=. & age2==""
replace age_cleaned=real(age1) if real(age1)!=. & strpos(age2," months")>0
replace age_cleaned=0 if strpos(age1," month")>0|strpos(age1," day")>0

rename (age_cleaned age) (age age_orig)

gen sex=1 if pr_sex_code=="Male"
replace sex=2 if pr_sex_code=="Female"

bysort `matching_vars': keep if _N==1

merge 1:1 `matching_vars' using "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\temptemp.dta"

preserve

	keep if _merge==3
	drop _merge
	save "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\temptemptemp3.dta",replace

restore


preserve

	keep if _merge==1
	drop _merge
	rename imageno imageno_orig
	gen imageno=imageno_orig+1
	save "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\temptemptemp1.dta",replace

restore


preserve

	keep if _merge==2
	rename imageno imageno_orig
	gen imageno=imageno_orig
	drop _merge
	save "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\temptemptemp2.dta",replace

restore




use "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\temptemptemp1.dta",clear
merge 1:1 `matching_vars' using "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\temptemptemp2.dta"



//preserve

keep if _merge==3
drop _merge
append using "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\temptemptemp3.dta"

//restore



/*
preserve

keep if _merge==1
drop _merge
save "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\temptemptemp1.dta",replace

restore


preserve

keep if _merge==2
drop _merge imageno
rename imageno imageno_orig
gen imageno=imageno_orig+1
save "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\temptemptemp2.dta",replace

restore


use "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\temptemptemp1.dta",clear
merge 1:1 namefrst namelast sex age roll imageno using "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\temptemptemp2.dta"
