/*IS THE "marshall" CLEANING DEFECT GONE FROM THE v26 INPUTS? (2026-11-25) */
/*marshall_diag.log: the old stored cleaned names (abeclean <0.25) turned   */
/*lee, edgar, dock, abram, ... into "marshall" (~290k per year/source).     */
/*1f_v26_inputs.do rebuilt everything with 0.26. Here, per year:           */
/* (1) every "marshall" in the new Ancestry first name, tabulated against   */
/*     the raw Ancestry name it came from (divided_file<yr>_women_added);  */
/* (2) 1940: every "marshall" in the new model first name, tabulated        */
/*     against the raw Ancestry name (raw model output is not re-read);    */
/* (3) old stored cleaned name vs new, among records stored as "marshall": */
/*     the most common old->new pairs, so lee/edgar/... should now appear. */
/*READ-ONLY; writes only the log.                                          */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local f_intermediate "$REP_F/enum_date/DATA/INTERMEDIATE/"

foreach yr in 1930 1940 {
	/*RAW AND OLD STORED ANCESTRY NAMES, BOTH SEXES                        */
	local src `"`f_intermediate'divided_file`yr'_women_added"'
	local fl : dir `"`src'"' files "norace*.dta"
	if `"`fl'"'=="" {
		display as error "no norace*.dta files in `src'"
		exit 601
	}
	local k 0
	foreach f of local fl {
		local ++k
		use histid namefrst_ans namefrst_ans_cleaned using `"`src'/`f'"', clear
		tempfile r`k'
		save `r`k''
	}
	use `r1', clear
	forvalues i = 2/`k' {
		append using `r`i''
	}
	isid histid
	rename namefrst_ans_cleaned old_f
	tempfile raw
	save `raw'

	if `yr'==1940 use histid namefrst namefrst_true_cleaned using `"`f_intermediate'for_mlp1940_v26.dta"', clear
	else          use histid namefrst using `"`f_intermediate'for_mlp1930_v26.dta"', clear
	merge 1:1 histid using `raw', assert(3) nogen
	display _n "===== `yr': " %15.0fc _N " records"

	/*(1) NEW ANCESTRY "marshall"                                          */
	display "`yr' new Ancestry first name marshall: " _continue
	count if namefrst=="marshall"
	display "`yr' ... of which raw name lacks 'marsh': " _continue
	count if namefrst=="marshall" & !strpos(lower(namefrst_ans),"marsh")
	preserve
	keep if namefrst=="marshall"
	contract namefrst_ans
	gsort -_freq
	list in 1/`=min(25,_N)', noobs
	restore

	/*(2) NEW MODEL "marshall", 1940                                       */
	if `yr'==1940 {
		display "1940 new model first name marshall: " _continue
		count if namefrst_true_cleaned=="marshall"
		display "1940 ... of which raw Ancestry name lacks 'marsh': " _continue
		count if namefrst_true_cleaned=="marshall" & !strpos(lower(namefrst_ans),"marsh")
		preserve
		keep if namefrst_true_cleaned=="marshall" & !strpos(lower(namefrst_ans),"marsh")
		if _N {
			contract namefrst_ans
			gsort -_freq
			list in 1/`=min(25,_N)', noobs
		}
		restore
	}

	/*(3) OLD STORED "marshall" -> NEW                                      */
	display "`yr' old stored marshall: " _continue
	count if old_f=="marshall"
	display "`yr' old stored marshall, new still marshall: " _continue
	count if old_f=="marshall" & namefrst=="marshall"
	preserve
	keep if old_f=="marshall"
	contract namefrst
	gsort -_freq
	list in 1/`=min(25,_N)', noobs
	restore
}
display "MARSHALL CHECK V26 DONE"
