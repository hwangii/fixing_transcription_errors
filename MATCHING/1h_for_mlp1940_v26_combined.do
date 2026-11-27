/*ONE 1940 FILE FOR IPUMS MLP LINKING, v26 BASE, THREE NAME VERSIONS         */
/*(2026-11-27). MACHINE A. Read only on its inputs (1f_v26_inputs.do output): */
/*  for_mlp1940_v26.dta      Old (Ancestry) + New (model on every record)      */
/*  for_mlp1940_v26_tgt.dta  same layout; model columns = Target-only          */
/*Writes for_mlp1940_v26_combined.dta, one row per record (both sexes):        */
/*  histid age sex bpl                                                         */
/*  namefrst namelast mi                          Old: Ancestry, cleaned       */
/*  namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned               */
/*      name_true_cleaned_exists                  New: model names            */
/*  namefrst_tgt_cleaned namelast_tgt_cleaned mi_tgt_cleaned                  */
/*      name_tgt_cleaned_exists                   Target-only: model names on */
/*                                                target records, Ancestry's  */
/*                                                elsewhere                   */
/*Same layout as the original for_mlp1940.dta plus the four tgt columns.      */
/*Refuses to overwrite.                                                       */
/*                                                                            */
/*  powershell -File replication/Run-Stata.ps1 MATCHING/1h_for_mlp1940_v26_combined.do */

if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local fi "$REP_F/enum_date/DATA/INTERMEDIATE/"
local out `"`fi'for_mlp1940_v26_combined.dta"'
capture confirm file `"`out'"'
if !_rc {
	display as error "`out' exists; move it aside first"
	exit 602
}

use histid age sex bpl namefrst namelast mi namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned name_true_cleaned_exists using `"`fi'for_mlp1940_v26_tgt.dta"', clear
isid histid
rename (namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned name_true_cleaned_exists) (namefrst_tgt_cleaned namelast_tgt_cleaned mi_tgt_cleaned name_tgt_cleaned_exists)
rename (age sex bpl namefrst namelast mi) (age_t sex_t bpl_t namefrst_t namelast_t mi_t)
tempfile t
save `t'

use `"`fi'for_mlp1940_v26.dta"', clear
isid histid
local N = _N
merge 1:1 histid using `t', assert(3) nogenerate
/*THE TWO FILES SHARE EVERYTHING BUT THE MODEL COLUMNS.                       */
foreach v in age sex bpl namefrst namelast mi {
	assert `v' == `v'_t
	drop `v'_t
}
/*TARGET-ONLY = NEW OR OLD, RECORD BY RECORD, AND BOTH OCCUR.                 */
gen byte isnew = namefrst_tgt_cleaned==namefrst_true_cleaned & namelast_tgt_cleaned==namelast_true_cleaned & mi_tgt_cleaned==mi_true_cleaned & name_tgt_cleaned_exists==name_true_cleaned_exists
gen byte isold = namefrst_tgt_cleaned==namefrst & namelast_tgt_cleaned==namelast & mi_tgt_cleaned==mi & name_tgt_cleaned_exists==0
assert isnew | isold
quietly count if name_tgt_cleaned_exists==1
local ntgt = r(N)
quietly count if !isnew
local ndiff = r(N)
assert `ntgt'>0 & `ndiff'>0
drop isnew isold
assert _N==`N'
order histid age sex bpl namefrst namelast mi namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned name_true_cleaned_exists namefrst_tgt_cleaned namelast_tgt_cleaned mi_tgt_cleaned name_tgt_cleaned_exists
compress
save `"`out'"'
display "records `N'; target with model names `ntgt'; Target-only differs from New on `ndiff'"
display "COMBINED MLP FILE DONE"
