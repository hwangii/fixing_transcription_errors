/*COMPARE for_mlp1940_tgt.dta WITH THE ORIGINAL for_mlp1940.dta (2026-11-20).*/
/*                                                                           */
/*The new file must equal the one sent to IPUMS except that non-target       */
/*records carry Ancestry's names in the _true_cleaned fields. Checks:        */
/*  1. same histids                                                          */
/*  2. histid age sex bpl namefrst namelast mi identical on every record     */
/*  3. target records: namefrst/namelast/mi_true_cleaned and                 */
/*     name_true_cleaned_exists identical                                    */
/*  4. non-target records: new _true_cleaned fields equal the original's     */
/*     Ancestry fields (namefrst namelast mi), name_true_cleaned_exists==0   */
/*Counts every difference before asserting, so a failure says how many.     */
/*Also reports how many non-target records lost model names.                */
/*                                                                           */
/*READ-ONLY. The original is expected (as received back, unmodified) at    */
/*F:/enum_date/DATA/INTERMEDIATE/for_mlp_original/for_mlp1940.dta.          */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local d   "$REP_F/enum_date/DATA/INTERMEDIATE"
local old "`d'/for_mlp_original/for_mlp1940.dta"
local new "`d'/for_mlp1940_tgt.dta"
local flags "`d'/tgt_flag1940.dta"

describe using `"`old'"'
local keepvars histid age sex bpl namefrst namelast mi namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned name_true_cleaned_exists

use `keepvars' using `"`old'"', clear
isid histid
/*RECORD WHICH BASELINE WAS COMPARED (2026-11-20 REVIEW).*/
display "original: " _N " records"
datasignature
/*EXPLICIT LIST: use <varlist> using KEEPS THE FILE'S ORDER, SO A RANGE    */
/*COULD SKIP OR CATCH THE WRONG VARIABLES (2026-11-20 REVIEW).             */
foreach v in age sex bpl namefrst namelast mi namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned name_true_cleaned_exists {
	rename `v' o_`v'
}
tempfile o
save `o'

use `keepvars' using `"`new'"', clear
isid histid
merge 1:1 histid using `o'
quietly count if _merge==1
display "only in new: " r(N)
quietly count if _merge==2
display "only in original: " r(N)
assert _merge==3
drop _merge

rename histid id
merge 1:1 id using `"`flags'"', keep(1 3) keepusing(tgt)
replace tgt = 0 if _merge==1
drop _merge
rename id histid
tab tgt

local bad 0
display _n "2. NON-NAME AND ANCESTRY FIELDS, ALL RECORDS"
foreach v in age sex bpl namefrst namelast mi {
	quietly count if `v' != o_`v'
	display "  `v' differs: " r(N)
	local bad = `bad' + r(N)
}
display _n "3. TARGET RECORDS: MODEL FIELDS"
foreach v in namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned name_true_cleaned_exists {
	quietly count if tgt & `v' != o_`v'
	display "  `v' differs: " r(N)
	local bad = `bad' + r(N)
}
display _n "4. NON-TARGET RECORDS: MODEL FIELDS NOW ANCESTRY"
quietly count if !tgt & !(namefrst_true_cleaned==o_namefrst & namelast_true_cleaned==o_namelast & mi_true_cleaned==o_mi)
display "  not equal to original Ancestry: " r(N)
local bad = `bad' + r(N)
quietly count if !tgt & name_true_cleaned_exists!=0
display "  name_true_cleaned_exists!=0: " r(N)
local bad = `bad' + r(N)

display _n "INFO: NON-TARGET RECORDS THAT HAD MODEL NAMES IN THE ORIGINAL"
quietly count if !tgt & o_name_true_cleaned_exists==1
display "  " r(N)
quietly count if !tgt & o_name_true_cleaned_exists==1 & !(o_namefrst_true_cleaned==o_namefrst & o_namelast_true_cleaned==o_namelast)
display "  of which the model's names differed from Ancestry's: " r(N)

display _n "TOTAL DIFFERENCES THAT SHOULD BE ZERO: `bad'"
assert `bad'==0
display "COMPARE PASSED"
