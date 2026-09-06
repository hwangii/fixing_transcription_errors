local original "D:\Dropbox\enum_date\DATA\ORIGINAL\"
local original_d "F:\enum_date\DATA\ORIGINAL\"
local intermediate "D:\Dropbox\enum_date\DATA\INTERMEDIATE\"
local intermediate_nondb "F:\enum_date\DATA\INTERMEDIATE\"
local beg_yr=`1'
local fsnames=""




/*IMPORT CENSUS TREE LINKS*/
import delimited `"`original_d'\\`beg_yr'_1940.csv"',clear


keep histid`beg_yr' histid1940
rename (histid`beg_yr' histid1940) (id_A_centree id_B)
save `"`intermediate_nondb'\\`beg_yr'_1940.dta"',replace




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











use statefip histid using `"`original'matching_intgen1940.dta"',clear
rename histid id_B

keep if statefip==44

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
