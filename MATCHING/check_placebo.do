/*PLACEBO CHECK FOR THE FAMILYSEARCH LINKING PATH (2026-11-06).              */
/*                                                                           */
/*Run after                                                                  */
/*  do MATCHING/_matching_master_dofile.do "1930" 10 1 "" 0 0 "1930 1940" 1  */
/*which sends the Ancestry names through the same path the FamilySearch run  */
/*uses (1b with no name swapped in, the revised matcher, the new append      */
/*branch). Its links must equal the paper's ABE exact-name Ancestry links,   */
/*link1930_1940_ans_cleaned_noraceblock0.dta: the same pairs, the same       */
/*conservative-band flag, the same names, the same middle initials. Any      */
/*difference means the FamilySearch run is not comparable, and stops here.   */
/*READ-ONLY.                                                                 */

if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local intermediate "$REP_SNU/enum_date/DATA/INTERMEDIATE/"

use id_A id_B fiveyr_band f_name_A l_name_A f_name_B l_name_B mi1930 mi1940 using `"`intermediate'link1930_1940_ans_cleaned_noraceblock0.dta"', clear
quietly count if fiveyr_band==1
display "paper's Ancestry links: " _N ", of which in the conservative band: " r(N)
isid id_A id_B
foreach v in fiveyr_band f_name_A l_name_A f_name_B l_name_B mi1930 mi1940 {
	rename `v' `v'_paper
}
tempfile paper
save `paper'

use id_A id_B fiveyr_band f_name_A l_name_A f_name_B l_name_B mi1930 mi1940 using `"`intermediate'link1930_1940_fsplacebo1930_1940_cleaned_noraceblock0.dta"', clear
display "placebo links: " _N
isid id_A id_B
merge 1:1 id_A id_B using `paper'
tab _merge

local bad 0
quietly count if _merge!=3
if r(N) {
	display as error r(N) " links are in only one of the two files"
	local bad 1
}
foreach v in fiveyr_band f_name_A l_name_A f_name_B l_name_B mi1930 mi1940 {
	quietly count if _merge==3 & `v'!=`v'_paper
	display "`v' differs: " r(N)
	if r(N) local bad 1
}
if `bad' {
	display as error "PLACEBO FAILED: the FamilySearch path does not reproduce the Ancestry links"
	exit 9
}
display "PLACEBO PASSED: identical to link1930_1940_ans_cleaned_noraceblock0.dta"
