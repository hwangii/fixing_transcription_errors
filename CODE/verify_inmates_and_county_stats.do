/*AUDIT OF TWO SECTION 4.3 CLAIMS, RUN 2026-10-14.                          */
/*  INMATES: the draft said their linking rate 'decreased slightly (-1%)'.  */
/*  It rises, 14.99 -> 16.09 percent, a gain of 7.3% on 304,454 records.    */
/*  The old claim also contradicted the figure, where no marker is below 0. */
/*  COUNTY PERCENTILES: the draft's '18% and 42%' is CORRECT -- computed    */
/*  across 3,139 counties the 5th and 95th percentiles are 17.6 and 42.5.   */
/*  Left unchanged in the paper; recorded here so it is not re-audited.     */

clear all
set more off
local intermediate "D:/SNU ECON Dropbox/sam hwang/enum_date/DATA/INTERMEDIATE"

use relate congruent linked_before linked_after state_folder_name county_folder_name using `"`intermediate'/temp.dta"', clear
display "records: " _N

/*THE FIGURE'S OWN RECODE (create_figures_SSHA2025.do:269). CATEGORY 4 IS   */
/*LABELLED "Inmates" IN label_socio_demo.do:9.                             */
recode relate (1 2 3 5 7 9=1) (4 6 8 10=2) (11 12=3) (13=4)

quietly summarize linked_before if relate==4
local b=r(mean)
local n=r(N)
quietly summarize linked_after if relate==4
local a=r(mean)
display "INMATES : before " %6.4f `b' "  after " %6.4f `a' "  change " %5.1f 100*(`a'/`b'-1) "%   (N=`n')"

/*COUNTY-LEVEL SHARE OF RECORDS WITH INCONGRUENT TRANSCRIPTION.*/
gen byte incong = 1-congruent
collapse (mean) incong, by(state_folder_name county_folder_name)
display ""
display "counties: " _N
quietly summarize incong, detail
display "COUNTY incongruence share:  p5 = " %5.3f r(p5) "   p95 = " %5.3f r(p95) "   median = " %5.3f r(p50)
