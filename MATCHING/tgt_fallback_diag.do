/*DIAGNOSTIC FOR 1c_tgt_divided_files.do (2026-11-17). READ ONLY: WRITES     */
/*NOTHING BUT ITS LOG AND MATCHING/results/tgt_fallback_diag.md.              */
/*                                                                           */
/*The first run of _tgt_only_run.do stopped on 1c's check: 436 of 1,031,654   */
/*records with name_true_cleaned_exists==0 in divided_file1940_true_cleaned   */
/*have f_name/l_name different from divided_file1940_ans_cleaned. This lists  */
/*them (both versions) and tabulates how they differ. It also describes the   */
/*4,819,575 divided-file records not in census1940_all_labeled_data.dta      */
/*(treated as non-target): their count by birthplace file and age range.     */

if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local fi "$REP_F/enum_date/DATA/INTERMEDIATE/"
local srcT `"`fi'divided_file1940_true_cleaned"'
local srcA `"`fi'divided_file1940_ans_cleaned"'
local md "$REP_REPO/MATCHING/results/tgt_fallback_diag.md"

/*ALL ids IN census1940_all_labeled_data.dta (NOT tgt_flag1940.dta, WHICH */
/*NOW HOLDS TARGET ids ONLY), ONCE.                                        */
use histid using "$REP_SNU/fixing_transcription_errors/DATA/ORIGINAL/census1940_all_labeled_data.dta", clear
rename histid id
tempfile ids
save `ids'

local fT : dir `"`srcT'"' files "norace*.dta"
tempfile bad nomatch
local zb 0
local zn 0
foreach f of local fT {
	use id f_name l_name mi using `"`srcA'/`f'"', clear
	rename (f_name l_name mi) (f_ans l_ans mi_ans)
	tempfile a
	save `a'
	use `"`srcT'/`f'"', clear
	merge 1:1 id using `a', assert(3) nogen
	gen file = "`f'"
	preserve
	keep if name_true_cleaned_exists==0 & !(f_name==f_ans & l_name==l_ans)
	if _N {
		local ++zb
		if `zb'>1 append using `bad'
		save `bad', replace
	}
	restore
	merge 1:1 id using `ids', keep(1 3)
	keep if _merge==1
	keep id age file
	if _N {
		local ++zn
		if `zn'>1 append using `nomatch'
		save `nomatch', replace
	}
}

file open md using `"`md'"', write replace text
file write md "# Diagnostic for 1c_tgt_divided_files.do's fallback check" _n _n "Written by MATCHING/tgt_fallback_diag.do." _n _n

local nb 0
if `zb' {
use `bad', clear
local nb = _N
gen byte d_f = f_name!=f_ans
gen byte d_l = l_name!=l_ans
gen byte e_new = f_name=="" | l_name==""
gen byte e_ans = f_ans=="" | l_ans==""
file write md "## Records without model names whose names differ from _ans_cleaned: `nb'" _n _n
foreach v in d_f d_l e_new e_ans {
	quietly count if `v'
	file write md "- `v': " (r(N)) _n
}
file write md _n "| file | id | f_name (true) | f_ans | l_name (true) | l_ans |" _n "|---|---|---|---|---|---|" _n
sort file id
local k = min(_N, 60)
forvalues i = 1/`k' {
	file write md "| " (file[`i']) " | " (id[`i']) " | " (f_name[`i']) " | " (f_ans[`i']) " | " (l_name[`i']) " | " (l_ans[`i']) " |" _n
}
list file id f_name f_ans l_name l_ans, clean noobs
}
else file write md "## Records without model names whose names differ from _ans_cleaned: 0" _n

if !`zn' {
	file write md _n "## Divided-file records not in census1940_all_labeled_data.dta: 0" _n
	file close md
	display "wrote `md'"
	exit
}
use `nomatch', clear
local nn = _N
file write md _n "## Divided-file records not in census1940_all_labeled_data.dta: `nn'" _n _n
quietly count if age<10
file write md "- age under 10: " (r(N)) _n
quietly count if age>=10 & age<.
file write md "- age 10+: " (r(N)) _n
quietly count if age>=.
file write md "- age missing: " (r(N)) _n
contract file, freq(n)
gsort -n
file write md _n "Largest birthplace files:" _n _n "| file | records |" _n "|---|---:|" _n
local k = min(_N, 15)
forvalues i = 1/`k' {
	file write md "| " (file[`i']) " | " (n[`i']) " |" _n
}
file close md
display "wrote `md'"
