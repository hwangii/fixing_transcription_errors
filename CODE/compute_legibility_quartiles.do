/*ALL-STATES REPLACEMENT FOR THE LEGIBILITY-QUARTILE CLAIM AT                 */
/*DHTS-2024-11-18.tex:732 -- "records from enumeration districts in the lowest */
/*quartile of legibility ... 125% higher rates of transcription disagreement   */
/*and 30% lower baseline linking rates". Those figures are Rhode-Island-era:   */
/*both reviewers found the only quartile calculation in the repo is commented- */
/*out RI code (munir_figures_for_nber.do:672-692).                             */
/*                                                                             */
/*READ-ONLY. temp.dta IS THE ALL-STATES ANALYSIS FILE BUILT BY                 */
/*create_figures_SSHA2025.do; IT IS ALREADY RESTRICTED TO sex==1 & age>=10.    */

clear all
set more off

/*REPLICATION PACKAGE: THE NUMBERS THE DRAFT QUOTES ARE WRITTEN BY repnum  */
/*TO THE FILE BELOW, NOT ONLY DISPLAYED. SEE replication/README.md.         */
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
repnum open using "$REP_RESULTS/compute_legibility_quartiles.tex", script(CODE/compute_legibility_quartiles.do)

local intermediate "D:/SNU ECON Dropbox/sam hwang/enum_date/DATA/INTERMEDIATE"

/*temp.dta IS BUILT BY create_figures_SSHA2025.do. IT IS THE 51,036,859-RECORD   */
/*ALL-STATES ANALYSIS FILE, ALREADY RESTRICTED TO sex==1 & age>=10.            */

use congruent legibility linked_before linked_after state_folder_name county_folder_name eventdistrict using `"`intermediate'/temp.dta"', clear

display "records loaded: " _N

/*DISAGREEMENT IS THE COMPLEMENT OF CONGRUENCY, AS USED THROUGHOUT THE PAPER.*/
gen disagree = 1 - congruent

/*QUARTILES OF LEGIBILITY. legibility IS AN ENUMERATION-DISTRICT MEAN ALREADY */
/*ATTACHED TO EVERY RECORD, SO RECORD-WEIGHTED QUARTILES PUT EQUAL NUMBERS OF */
/*RECORDS -- NOT OF DISTRICTS -- IN EACH BIN. THAT IS THE RIGHT WEIGHTING FOR  */
/*A CLAIM ABOUT "RECORDS FROM DISTRICTS IN THE LOWEST QUARTILE".              */
xtile leg_q = legibility, nq(4)

tabulate leg_q, missing

display ""
display "=============== BY LEGIBILITY QUARTILE ==============="
table leg_q, contents(mean disagree mean linked_before mean linked_after n disagree)

/*THE THREE COMPARISONS THE SENTENCE COULD MEAN, ALL REPORTED SO THE DRAFT CAN */
/*STATE WHICHEVER IT USES EXPLICITLY RATHER THAN LEAVING THE BASE IMPLICIT.    */
quietly sum disagree if leg_q==1
local d1=r(mean)
quietly sum disagree if leg_q==4
local d4=r(mean)
quietly sum disagree
local dall=r(mean)

quietly sum linked_before if leg_q==1
local l1=r(mean)
quietly sum linked_before if leg_q==4
local l4=r(mean)
quietly sum linked_before
local lall=r(mean)

quietly sum linked_after if leg_q==1
local a1=r(mean)
quietly sum linked_after if leg_q==4
local a4=r(mean)

display ""
display "disagreement rate   Q1=" %6.4f `d1' "  Q4=" %6.4f `d4' "  all=" %6.4f `dall'
display "  Q1 vs Q4 : " %6.1f 100*(`d1'/`d4'-1) "% higher"
display "  Q1 vs all: " %6.1f 100*(`d1'/`dall'-1) "% higher"
display ""
display "linked_before       Q1=" %6.4f `l1' "  Q4=" %6.4f `l4' "  all=" %6.4f `lall'
display "  Q1 vs Q4 : " %6.1f 100*(`l1'/`l4'-1) "%"
display "  Q1 vs all: " %6.1f 100*(`l1'/`lall'-1) "%"
display ""
display "linked_after        Q1=" %6.4f `a1' "  Q4=" %6.4f `a4'
display "  improvement in Q1: " %6.1f 100*(`a1'/`l1'-1) "%"
display "  improvement in Q4: " %6.1f 100*(`a4'/`l4'-1) "%"
display "======================================================"

/*Q1 IS THE LEAST LEGIBLE QUARTILE, Q4 THE MOST. IN PERCENT.*/
repnum legDisagreeLowest   = 100*`d1', format(%4.1f)
repnum legDisagreeHighest  = 100*`d4', format(%4.1f)
repnum legLinkBaseLowest   = 100*`l1', format(%4.1f)
repnum legLinkBaseHighest  = 100*`l4', format(%4.1f)
repnum legLinkAfterLowest  = 100*`a1', format(%4.1f)
repnum legLinkAfterHighest = 100*`a4', format(%4.1f)
repnum legGainLowest       = 100*(`a1'/`l1'-1), format(%4.1f)
repnum legGainHighest      = 100*(`a4'/`l4'-1), format(%4.1f)
repnum close
