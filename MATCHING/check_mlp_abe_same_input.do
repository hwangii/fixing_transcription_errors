/*ARE THE MEN IN THE MLP 1940 INPUT AND THE ABE 1940 INPUT THE SAME NAMES? */
/*(2026-11-23). The method comparison is clean only if MLP and ABE link on  */
/*identical 1940 names, record for record; MLP's file may also hold women.  */
/*                                                                           */
/*  MLP: for_mlp1940_tgtns.dta (1d_for_mlp_tgtns.do), sex==1                */
/*       histid namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned */
/*       name_true_cleaned_exists                                           */
/*  ABE: divided_file1940_tgtns_cleaned/norace*.dta (1e_tgtns_divided_files)*/
/*       id f_name l_name mi_true_cleaned name_true_cleaned_exists          */
/*                                                                           */
/*Reports: men in each file only; among men in both, how many differ on     */
/*each field (names, initial, model-name flag, age, birthplace), with       */
/*examples. Passes only if the two sets of men are identical AND nothing    */
/*differs; otherwise exits 9 (2026-11-23 REVIEW). A difference caused by    */
/*1_divide's (filename,row) duplicate screen running on men only for ABE    */
/*but on both sexes for MLP would show here as a flag or name difference.  */
/*READ-ONLY; writes only the log.                                           */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local f_intermediate "$REP_F/enum_date/DATA/INTERMEDIATE/"
local srcA `"`f_intermediate'divided_file1940_tgtns_cleaned"'
local mlp  `"`f_intermediate'for_mlp1940_tgtns.dta"'
confirm file `"`mlp'"'

local fA : dir `"`srcA'"' files "norace*.dta"
if `"`fA'"'=="" {
	display as error "no norace*.dta files in `srcA'"
	exit 601
}
local k 0
foreach f of local fA {
	local ++k
	local b = subinstr(subinstr("`f'", "norace", "", 1), ".dta", "", 1)
	confirm integer number `b'
	use id age f_name l_name mi_true_cleaned name_true_cleaned_exists using `"`srcA'/`f'"', clear
	rename (id age f_name l_name mi_true_cleaned name_true_cleaned_exists) (histid a_age a_f a_l a_mi a_ex)
	gen a_bpl = `b'
	tempfile p`k'
	save `p`k''
}
use `p1', clear
forvalues i = 2/`k' {
	append using `p`i''
}
isid histid
display "ABE men: " %15.0fc _N " in `k' files"
tempfile abe
save `abe'

use histid sex age bpl namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned name_true_cleaned_exists using `"`mlp'"', clear
isid histid
tab sex, missing
quietly count if sex==1
display "MLP men: " %15.0fc r(N) " of " %15.0fc _N " records"
merge 1:1 histid using `abe'
/*AN ABE RECORD MUST BE A MAN IN THE MLP FILE IF IT IS THERE AT ALL.        */
quietly count if _merge==3 & sex!=1
local n_notman = r(N)
display "in both but not a man in MLP: " %15.0fc r(N)
quietly count if _merge==1 & sex==1
local n_mlponly = r(N)
display "MLP men not in ABE: " %15.0fc r(N)
quietly count if _merge==2
local n_abeonly = r(N)
display "ABE men not in MLP: " %15.0fc r(N)

keep if _merge==3 & sex==1
display "men in both: " %15.0fc _N
gen byte d_f  = namefrst_true_cleaned != a_f
gen byte d_l  = namelast_true_cleaned != a_l
gen byte d_mi = mi_true_cleaned != a_mi
gen byte d_ex = name_true_cleaned_exists != a_ex
gen byte d_age = age != a_age
gen byte d_bpl = bpl != a_bpl
gen byte d_any = d_f | d_l | d_mi | d_ex | d_age | d_bpl
foreach v in d_f d_l d_mi d_ex d_age d_bpl d_any {
	quietly count if `v'
	display "`v': " %15.0fc r(N)
}
local nboth = _N
quietly count if d_any
local ndiff = r(N)
if `ndiff' {
	keep if d_any
	list histid namefrst_true_cleaned a_f namelast_true_cleaned a_l mi_true_cleaned a_mi name_true_cleaned_exists a_ex age a_age bpl a_bpl in 1/`=min(30,_N)', noobs abbreviate(12)
}
if `ndiff'==0 & `nboth'>0 & `n_notman'==0 & `n_mlponly'==0 & `n_abeonly'==0 {
	display "CHECK PASSED: same men in both files, with identical names, initials, flags, ages and birthplaces"
}
else {
	display as error "CHECK FAILED: see counts and examples above"
	exit 9
}
