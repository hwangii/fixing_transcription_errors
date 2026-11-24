/*WHY DO 61,959 MEN HAVE A DIFFERENT FIRST NAME IN THE MLP AND ABE 1940     */
/*INPUTS? (2026-11-23; check_mlp_abe_same_input.log). Ancestry's names are  */
/*identical in the two sources (extract_diff_diag.log), so the difference   */
/*is in the model-name side. Hypothesis (user): the MLP input's model names */
/*were never passed through abeclean. Test: run abeclean on the MLP name    */
/*and see whether it changes it and whether it reproduces the ABE name. An  */
/*MLP name that abeclean leaves unchanged was already cleaned, so a missing */
/*abeclean pass cannot explain it (raw model output is not re-read here).   */
/*Also compares the two upstream model-name files directly                 */
/*(divided_file1940_true_cleaned vs _true_cleaned_women_added, men) to see  */
/*whether the difference predates 1c/1d/1e. Blank names are counted apart.  */
/*abeclean comes from replication/stata via config.do's adopath.            */
/*Also tabulates the differences by target status and model-name flag,     */
/*and lists examples. READ-ONLY; writes only the log.                       */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local f_intermediate "$REP_F/enum_date/DATA/INTERMEDIATE/"
local srcA `"`f_intermediate'divided_file1940_tgtns_cleaned"'
local mlp  `"`f_intermediate'for_mlp1940_tgtns.dta"'
local flags `"`f_intermediate'tgt_flag1940.dta"'

local fA : dir `"`srcA'"' files "norace*.dta"
local k 0
foreach f of local fA {
	local ++k
	use id f_name l_name mi_true_cleaned name_true_cleaned_exists using `"`srcA'/`f'"', clear
	rename (id f_name l_name mi_true_cleaned name_true_cleaned_exists) (histid a_f a_l a_mi a_ex)
	tempfile p`k'
	save `p`k''
}
use `p1', clear
forvalues i = 2/`k' {
	append using `p`i''
}
tempfile abe
save `abe'

use histid sex namefrst namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned name_true_cleaned_exists using `"`mlp'"' if sex==1, clear
merge 1:1 histid using `abe', keep(3) nogen
keep if namefrst_true_cleaned != a_f
display "men whose first name differs: " %12.0fc _N
rename histid id
merge 1:1 id using `"`flags'"', keep(1 3) keepusing(tgt)
rename id histid
gen byte tgt1 = _merge==3
drop _merge
tab tgt1 name_true_cleaned_exists, missing
tab name_true_cleaned_exists a_ex, missing
display "blank MLP first name: " _continue
count if namefrst_true_cleaned==""
display "blank ABE first name: " _continue
count if a_f==""
gen byte mlp_is_anc = namefrst_true_cleaned==namefrst
display "MLP name equals Ancestry's cleaned name: " _continue
count if mlp_is_anc
display "ABE name equals Ancestry's cleaned name: " _continue
count if a_f==namefrst

/*TEST: DOES abeclean OF THE MLP NAME GIVE THE ABE NAME?                     */
gen f_test = namefrst_true_cleaned
gen l_test = namelast_true_cleaned
abeclean f_test l_test, sex(sex) initial(mi_test) nickname nonysiis
gen byte reproduces = f_test_cleaned==a_f & a_f!=""

display "abeclean(MLP first name) == ABE first name: " _continue
count if reproduces
display "abeclean(MLP first name) == MLP first name (already clean): " _continue
count if f_test_cleaned==namefrst_true_cleaned
tab tgt1 reproduces, missing

/*EXAMPLES                                                                  */
list histid tgt1 name_true_cleaned_exists namefrst namefrst_true_cleaned f_test_cleaned a_f in 1/40, noobs abbreviate(10)
contract namefrst_true_cleaned a_f
gsort -_freq
list in 1/40, noobs

/*UPSTREAM: THE TWO MODEL-NAME FILES BEFORE ANY TARGET RESTRICTION.         */
clear
foreach v in M W {
	if "`v'"=="M" local d `"`f_intermediate'divided_file1940_true_cleaned"'
	else          local d `"`f_intermediate'divided_file1940_true_cleaned_women_added"'
	local fl : dir `"`d'"' files "norace*.dta"
	local k 0
	foreach f of local fl {
		local ++k
		use `"`d'/`f'"' in 1, clear
		capture confirm variable sex
		if !_rc use id sex f_name name_true_cleaned_exists using `"`d'/`f'"' if sex==1, clear
		else use id f_name name_true_cleaned_exists using `"`d'/`f'"', clear
		capture drop sex
		rename (f_name name_true_cleaned_exists) (f_`v' ex_`v')
		tempfile u`k'
		save `u`k''
	}
	use `u1', clear
	forvalues i = 2/`k' {
		append using `u`i''
	}
	tempfile up`v'
	save `up`v''
}
use `upM', clear
merge 1:1 id using `upW', keep(3) nogen
display "upstream men in both: " %15.0fc _N
display "upstream first name differs: " _continue
count if f_M!=f_W
display "upstream model-name flag differs: " _continue
count if ex_M!=ex_W
tab ex_M ex_W if f_M!=f_W, missing
keep if f_M!=f_W
list id f_M f_W ex_M ex_W in 1/`=min(30,_N)', noobs
display "FNAME DIFF CHECK DONE"
