/*THE "marshall" CLEANING ANOMALY: WHICH 1930/1940 FILES CARRY IT?          */
/*(2026-11-23). check_mlp_abe_fname_diff.log: 287,379 men have a different  */
/*model first name in divided_file1940_true_cleaned (ABE input; built on    */
/*machine A, 2026-02, abeclean version unknown) than in                     */
/*divided_file1940_true_cleaned_women_added (MLP input); in the first file  */
/*the name is "marshall" where the second has lee, edgar, dock, abram, ...  */
/*abeclean 0.25's patch note reads "fixed issue with marshall"; the copy    */
/*installed now is 0.26.                                                    */
/*                                                                           */
/*PART A (1930 true_cleaned): the same men-only vs women-added comparison   */
/*of the true_cleaned files as for 1940. There is no 1930 model, so these  */
/*hold Ancestry's cleaned names copied by 1_divide (2026-11-23 REVIEW); a  */
/*difference would still show an inconsistency between the two inputs.    */
/*The installed abeclean is printed by `which` (expected 0.26, 2020-07-08).*/
/*PART B (Ancestry names, 1930 and 1940, both sources): re-run the          */
/*installed abeclean (0.26) on Ancestry's raw names (namefrst_ans,          */
/*namelast_ans, with each record's sex; men-only 1930 files have no sex and */
/*are men) and compare with the stored namefrst_ans_cleaned /               */
/*namelast_ans_cleaned, so an old-version artefact in Ancestry's cleaned    */
/*names would show. Counts of differences, of stored "marshall" that 0.26   */
/*does not give, and the most frequent stored->0.26 pairs.                  */
/*READ-ONLY; writes only the log.                                           */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local f_intermediate "$REP_F/enum_date/DATA/INTERMEDIATE/"
which abeclean

/*PART A                                                                    */
foreach v in M W {
	if "`v'"=="M" local d `"`f_intermediate'divided_file1930_true_cleaned"'
	else          local d `"`f_intermediate'divided_file1930_true_cleaned_women_added"'
	local fl : dir `"`d'"' files "norace*.dta"
	if `"`fl'"'=="" {
		display as error "no norace*.dta files in `d'"
		exit 601
	}
	local k 0
	foreach f of local fl {
		local ++k
		use `"`d'/`f'"' in 1, clear
		capture confirm variable sex
		if !_rc use id sex f_name l_name using `"`d'/`f'"' if sex==1, clear
		else use id f_name l_name using `"`d'/`f'"', clear
		capture drop sex
		rename (f_name l_name) (f_`v' l_`v')
		tempfile u`k'
		save `u`k''
	}
	use `u1', clear
	forvalues i = 2/`k' {
		append using `u`i''
	}
	isid id
	display "1930 true_cleaned `v': " %15.0fc _N " men in `k' files"
	tempfile up`v'
	save `up`v''
}
use `upM', clear
merge 1:1 id using `upW'
tab _merge
keep if _merge==3
display "1930 true_cleaned first name differs: " _continue
count if f_M!=f_W
display "1930 true_cleaned surname differs: " _continue
count if l_M!=l_W
display "1930 true_cleaned first name marshall, M / W: " _continue
count if f_M=="marshall"
count if f_W=="marshall"
keep if f_M!=f_W | l_M!=l_W
if _N {
	preserve
	keep if f_M!=f_W
	contract f_M f_W
	gsort -_freq
	list in 1/`=min(30,_N)', noobs
	restore
	keep if l_M!=l_W
	if _N {
		contract l_M l_W
		gsort -_freq
		list in 1/`=min(30,_N)', noobs
	}
}

/*PART B                                                                    */
foreach yr in 1930 1940 {
	foreach v in M W {
		if "`v'"=="M" local d `"`f_intermediate'divided_file`yr'"'
		else          local d `"`f_intermediate'divided_file`yr'_women_added"'
		local fl : dir `"`d'"' files "norace*.dta"
		if `"`fl'"'=="" {
			display as error "no norace*.dta files in `d'"
			exit 601
		}
		local n 0
		local nf 0
		local nl 0
		local nmar 0
		local k 0
		foreach f of local fl {
			local ++k
			use `"`d'/`f'"' in 1, clear
			capture confirm variable sex
			local hassex = !_rc
			if `hassex' use histid sex namefrst_ans namelast_ans namefrst_ans_cleaned namelast_ans_cleaned using `"`d'/`f'"', clear
			else {
				use histid namefrst_ans namelast_ans namefrst_ans_cleaned namelast_ans_cleaned using `"`d'/`f'"', clear
				gen byte sex = 1
			}
			rename (namefrst_ans_cleaned namelast_ans_cleaned) (sf sl)
			abeclean namefrst_ans namelast_ans, sex(sex) nickname nonysiis
			local n = `n' + _N
			quietly count if sf!=namefrst_ans_cleaned
			local nf = `nf' + r(N)
			quietly count if sl!=namelast_ans_cleaned
			local nl = `nl' + r(N)
			quietly count if sf=="marshall" & namefrst_ans_cleaned!="marshall"
			local nmar = `nmar' + r(N)
			keep if sf!=namefrst_ans_cleaned | sl!=namelast_ans_cleaned
			keep histid sex namefrst_ans sf namefrst_ans_cleaned namelast_ans sl namelast_ans_cleaned
			tempfile q`k'
			save `q`k''
		}
		display _n "`yr' `v' Ancestry: `n' records in `k' files; first name stored != 0.26: `nf'; surname: `nl'; stored marshall that 0.26 does not give: `nmar'"
		use `q1', clear
		forvalues i = 2/`k' {
			append using `q`i''
		}
		if _N {
			preserve
			keep if sf!=namefrst_ans_cleaned
			if _N {
				contract sf namefrst_ans_cleaned
				gsort -_freq
				list in 1/`=min(25,_N)', noobs
			}
			restore
			keep if sl!=namelast_ans_cleaned
			if _N {
				contract sl namelast_ans_cleaned
				gsort -_freq
				list in 1/`=min(15,_N)', noobs
			}
		}
	}
}
display "MARSHALL DIAG DONE"
