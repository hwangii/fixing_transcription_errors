/*CHECK THE RACE FIGURES IN DHTS-2026-10-12.tex AGAINST THE DATA BEHIND      */
/*all_states_socio_demo_combinedV2.pdf. THE DRAFT SAYS BASELINE LINKAGE OF   */
/*18.3 PERCENT FOR NON-WHITE AND 27.1 FOR WHITE RESIDENTS, WITH INCREASES OF */
/*11.4 AND 12.2 PERCENT. READING THE MARKERS OFF THE FIGURE GIVES ROUGHLY    */
/*11 AND 24 PERCENT BASELINE AND 6.3 AND 8.2 PERCENT INCREASES, SO THE FOUR  */
/*NUMBERS LOOK LIKE RHODE-ISLAND-ERA LEFTOVERS. READ-ONLY.                   */

clear all
set more off

local intermediate "D:/SNU ECON Dropbox/sam hwang/enum_date/DATA/INTERMEDIATE"

use race linked_before linked_after validated_before validated_after using `"`intermediate'/temp.dta"', clear

display "records: " _N

/*THE SAME RECODE THE FIGURE USES (create_figures_SSHA2025.do:271):          */
/*1 = white, 2 = EVERY non-white category pooled.                            */
recode race (1=1) (2 3 4 5 6 7=2)
label define racegrp 1 "White" 2 "Non-white", replace
label values race racegrp

tabulate race, missing

display ""
display "=============== LINKAGE RATE BY RACE ==============="
foreach r in 1 2 {
	quietly summarize linked_before if race==`r'
	local b`r' = r(mean)
	local n`r' = r(N)
	quietly summarize linked_after if race==`r'
	local a`r' = r(mean)
	local pct`r' = 100*(`a`r''/`b`r'' - 1)
}

display "White     : before " %6.4f `b1' "  after " %6.4f `a1' "  increase " %5.1f `pct1' "%  (N=`n1')"
display "Non-white : before " %6.4f `b2' "  after " %6.4f `a2' "  increase " %5.1f `pct2' "%  (N=`n2')"

display ""
display "=============== SHARE VALIDATED BY RACE ==============="
foreach r in 1 2 {
	quietly summarize validated_before if race==`r'
	local vb`r' = r(mean)
	quietly summarize validated_after if race==`r'
	local va`r' = r(mean)
	local vp`r' = 100*(`va`r''/`vb`r'' - 1)
}
display "White     : before " %6.4f `vb1' "  after " %6.4f `va1' "  increase " %5.1f `vp1' "%"
display "Non-white : before " %6.4f `vb2' "  after " %6.4f `va2' "  increase " %5.1f `vp2' "%"
display "======================================================"
