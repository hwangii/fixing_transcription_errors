/*DO ABE EXACT AND THE MLP SEE THE SAME MEN AND NAMES IN THE v26 INPUTS?     */
/*(2026-11-25). 1f_v26_inputs.do writes the ABE shards (men) and the MLP     */
/*files (both sexes) from one source, so for every man they must agree on    */
/*id, birthplace, age, names, initial and model-name flag. Checked:          */
/*  1930: divided_file1930_v26_ans_cleaned  vs for_mlp1930_v26 (Ancestry)    */
/*  1940: divided_file1940_v26_ans_cleaned  vs for_mlp1940_v26 (Ancestry)    */
/*        divided_file1940_v26_true_cleaned vs for_mlp1940_v26 (model)       */
/*        divided_file1940_v26_tgt_cleaned  vs for_mlp1940_v26_tgt (model)   */
/*Stops (exit 9) on any difference, including men present on one side only.  */
/*READ-ONLY; writes only the log.                                           */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local fi "$REP_F/enum_date/DATA/INTERMEDIATE/"
local bad 0

foreach c in 1930ans 1940ans 1940true 1940tgt {
	local yr = substr("`c'",1,4)
	local t  = substr("`c'",5,.)
	local d `"`fi'divided_file`yr'_v26_`t'_cleaned"'
	local fl : dir `"`d'"' files "norace*.dta"
	if `"`fl'"'=="" {
		display as error "no norace*.dta files in `d'"
		exit 601
	}
	local k 0
	foreach f of local fl {
		local ++k
		use `"`d'/`f'"', clear
		gen int bpl = real(subinstr(subinstr("`f'","norace","",1),".dta","",1))
		assert !missing(bpl)
		tempfile p`k'
		save `p`k''
	}
	use `p1', clear
	forvalues i = 2/`k' {
		append using `p`i''
	}
	rename id histid
	isid histid
	if "`t'"=="ans" rename (age mi f_name l_name bpl) (a_age a_mi a_f a_l a_bpl)
	else rename (age mi_true_cleaned f_name l_name bpl name_true_cleaned_exists) (a_age a_mi a_f a_l a_bpl a_ex)
	tempfile abe
	save `abe'

	local mf = cond("`t'"=="tgt", "for_mlp1940_v26_tgt", "for_mlp`yr'_v26")
	if "`t'"=="ans" use histid sex age bpl namefrst namelast mi using `"`fi'`mf'.dta"' if sex==1, clear
	else {
		use histid sex age bpl namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned name_true_cleaned_exists using `"`fi'`mf'.dta"' if sex==1, clear
		rename (namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned name_true_cleaned_exists) (namefrst namelast mi ex)
	}
	merge 1:1 histid using `abe'
	display _n "===== `c': ABE shards vs `mf' (men)"
	tab _merge
	quietly count if _merge!=3
	local nd = r(N)
	if `nd' {
		preserve
		keep if _merge!=3
		list histid sex _merge in 1/`=min(20,_N)', noobs
		restore
	}
	keep if _merge==3
	gen byte d = age!=a_age | bpl!=a_bpl | namefrst!=a_f | namelast!=a_l | mi!=a_mi
	if "`t'"!="ans" replace d = 1 if ex!=a_ex
	quietly count if d
	local nd = `nd' + r(N)
	display "`c': men in both " %15.0fc _N "; records differing or on one side only: `nd'"
	if `nd' {
		keep if d
		if _N {
			if "`t'"=="ans" list histid age a_age bpl a_bpl namefrst a_f namelast a_l mi a_mi in 1/`=min(20,_N)', noobs
			else list histid age a_age bpl a_bpl namefrst a_f namelast a_l mi a_mi ex a_ex in 1/`=min(20,_N)', noobs
		}
		local bad 1
	}
}
if `bad' {
	display as error "ABE and MLP v26 inputs differ"
	exit 9
}
display "V26 SAME INPUT CHECK PASSED"
