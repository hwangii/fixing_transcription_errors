/*WHERE DO THE MIDDLE INITIALS IN THE TWO LINK FILES COME FROM? (2026-11-01) */
/*                                                                           */
/*validation_by_link_status.do found that links pairing the same two people  */
/*validate differently before and after (target group: 63.4% -> 79.2%). So   */
/*mi1930 or mi1940 must differ between the ans (old names) and true (our     */
/*names) link files. This finds which side differs, and whether either file's */
/*middle initials match the Ancestry or our model's transcription.           */
/*READ-ONLY.                                                                  */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local intermediate "$REP_SNU/enum_date/DATA/INTERMEDIATE/"

describe using `"`intermediate'link1930_1940_ans_cleaned_noraceblock0.dta"'
describe using `"`intermediate'link1930_1940_true_cleaned_noraceblock0.dta"'

use id_B id_A mi1930 mi1940 fiveyr_band using `"`intermediate'link1930_1940_ans_cleaned_noraceblock0.dta"', clear
rename (id_A mi1930 mi1940 fiveyr_band) (id_A_ans mi1930_ans mi1940_ans fiveyr_ans)
merge 1:1 id_B using `"`intermediate'link1930_1940_true_cleaned_noraceblock0.dta"', keepusing(id_A mi1930 mi1940 fiveyr_band)
rename (id_A mi1930 mi1940 fiveyr_band) (id_A_true mi1930_true mi1940_true fiveyr_true)
tab _merge

/*SAME 1940 PERSON, SAME 1930 PARTNER, BOTH LINKED.*/
gen byte kept = _merge==3 & id_A_ans==id_A_true & fiveyr_ans==1 & fiveyr_true==1
count if kept
display "kept pairs where mi1940 differs: "
count if kept & mi1940_ans!=mi1940_true
display "kept pairs where mi1930 differs: "
count if kept & mi1930_ans!=mi1930_true
keep if kept & (mi1940_ans!=mi1940_true | mi1930_ans!=mi1930_true)
gen byte both_mi_differ = mi1940_ans!=mi1940_true & mi1930_ans!=mi1930_true
tab both_mi_differ
gen byte e40 = mi1940_ans=="" 
gen byte n40 = mi1940_true==""
tab e40 n40
set seed 20261101
gen double u = runiform()
sort u
list id_B id_A_ans mi1930_ans mi1930_true mi1940_ans mi1940_true in 1/40, clean noobs
