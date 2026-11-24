/*DO THE MEN-ONLY AND WOMEN-ADDED 1930/1940 SOURCES DESCRIBE THE SAME MEN?  */
/*(2026-11-23). ABE links on divided_file<yr> (IPUMS extracts 00449/00450,  */
/*0_create_file_for_matching_intgenV4_women_added.do), MLP on               */
/*divided_file<yr>_women_added (extracts 00655/00656). check_mlp_abe_same_  */
/*input.do found 1940 men whose age (1.9%), birthplace (0.9%) or first name */
/*(61,959) differ between the two inputs. This compares the raw divided     */
/*files, before any model names, for 1930 and 1940, so the differences can  */
/*be traced to the extracts. READ-ONLY; writes only the log.                */
/*                                                                           */
/*Per year: men in each source only; among men in both, records differing  */
/*in Ancestry's cleaned first name, surname, initial, age, birthplace; the  */
/*distribution of the age difference; examples of each kind.                */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local f_intermediate "$REP_F/enum_date/DATA/INTERMEDIATE/"

foreach yr in 1940 1930 {
	foreach v in M W {
		if "`v'"=="M" local d `"`f_intermediate'divided_file`yr'"'
		else          local d `"`f_intermediate'divided_file`yr'_women_added"'
		local fl : dir `"`d'"' files "norace*.dta"
		local fl : list sort fl
		local fl`v' `fl'
		if `"`fl'"'=="" {
			display as error "no norace*.dta files in `d'"
			exit 601
		}
		local k 0
		foreach f of local fl {
			local b = subinstr(subinstr("`f'", "norace", "", 1), ".dta", "", 1)
			confirm integer number `b'
			local ++k
			use histid sex age mi namefrst_ans_cleaned namelast_ans_cleaned using `"`d'/`f'"', clear
			gen int bpl = `b'
			tempfile p`k'
			save `p`k''
		}
		use `p1', clear
		forvalues i = 2/`k' {
			append using `p`i''
		}
		isid histid
		/*WOMEN ARE KEPT IN THE WOMEN-ADDED SOURCE SO A SEX CHANGE BETWEEN THE  */
		/*EXTRACTS SHOWS AS SUCH, NOT AS A MISSING MAN (2026-11-23 REVIEW).      */
		if "`v'"=="W" tab sex, missing
		else assert sex==1
		rename (sex age mi namefrst_ans_cleaned namelast_ans_cleaned bpl) (sex_`v' age_`v' mi_`v' f_`v' l_`v' bpl_`v')
		display "`yr' `v': " %15.0fc _N " records in `k' files"
		tempfile s`v'
		save `s`v''
	}
	/*BIRTHPLACE FILES IN ONE SOURCE ONLY.                                    */
	local onlyM : list flM - flW
	local onlyW : list flW - flM
	display `"`yr' birthplace files in men-only source only: `onlyM'"'
	display `"`yr' birthplace files in women-added source only: `onlyW'"'
	use `sM', clear
	merge 1:1 histid using `sW'
	display "`yr': men-only source only " _continue
	count if _merge==1
	display "`yr': women-added source only, men " _continue
	count if _merge==2 & sex_W==1
	display "`yr': in both but a woman in the women-added source " _continue
	count if _merge==3 & sex_W!=1
	preserve
	keep if _merge==1
	if _N list histid f_M l_M age_M bpl_M in 1/`=min(15,_N)', noobs abbreviate(8)
	restore
	keep if _merge==3 & sex_W==1
	drop _merge sex_M sex_W
	display "`yr': men in both " %15.0fc _N
	gen byte d_f   = f_M != f_W
	gen byte d_l   = l_M != l_W
	gen byte d_mi  = mi_M != mi_W
	gen byte d_age = age_M != age_W
	gen byte d_bpl = bpl_M != bpl_W
	foreach x in f l mi age bpl {
		quietly count if d_`x'
		display "`yr' differs in `x': " %15.0fc r(N)
	}
	gen int dage = age_W - age_M if d_age
	tab dage if inrange(dage,-12,12), missing
	gen dage_bin = cond(missing(age_M)|missing(age_W), 99, cond(abs(dage)<=12, 0, cond(abs(dage)<=50, 1, 2))) if d_age
	label define dbin 0 "|d|<=12" 1 "12<|d|<=50" 2 "|d|>50" 99 "a side missing", replace
	label values dage_bin dbin
	tab dage_bin, missing
	quietly summarize dage
	if r(N) display "`yr' age difference: mean " r(mean) ", min " r(min) ", max " r(max)
	/*THE 30 MOST COMMON BIRTHPLACE CHANGES, ALL CODES.                      */
	preserve
	keep if d_bpl
	contract bpl_M bpl_W
	gsort -_freq
	list in 1/`=min(30,_N)', noobs
	restore
	foreach x in f l mi age bpl {
		display _n "`yr': examples differing in `x'"
		preserve
		keep if d_`x'
		if _N list histid f_M f_W l_M l_W mi_M mi_W age_M age_W bpl_M bpl_W in 1/`=min(15,_N)', noobs abbreviate(8)
		restore
	}
	/*ARE THE FIRST-NAME DIFFERENCES CONCENTRATED WHERE AGE/BPL ALSO DIFFER?   */
	tab d_f d_age, missing
	tab d_f d_bpl, missing
}
display "EXTRACT DIFF DIAG DONE"
