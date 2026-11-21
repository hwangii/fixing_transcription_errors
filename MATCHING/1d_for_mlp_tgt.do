/*TARGET-ONLY 1940 FILE FOR IPUMS MLP LINKING (2026-11-20).                   */
/*                                                                           */
/*The file sent to IPUMS for MLP linking, for_mlp1940.dta, was built by      */
/*MATCHING/1_divide_and_clean_everyoneV5_women_addedV2.do (lines 201-253)    */
/*with the model's names on every 1940 record that has them. We now replace  */
/*names only on target records (as 1c_tgt_divided_files.do does for ABE).   */
/*This rebuilds it as for_mlp1940_tgt.dta, same variables and layout:        */
/*  histid age sex bpl namefrst namelast mi              Ancestry, cleaned   */
/*  namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned              */
/*      target record: the model's (Ancestry's where the model gave none),   */
/*      from divided_file1940_true_cleaned_women_added                       */
/*      other record: Ancestry's, from divided_file1940_ans_cleaned_women_added */
/*  name_true_cleaned_exists  1 only for target records with model names     */
/*bpl is the birthplace code in the divided file's name (norace<bpl>.dta),   */
/*as in the original (gen bpl=`b').                                          */
/*                                                                           */
/*Target flag: tgt_flag1940.dta, written by 1c_tgt_divided_files.do from     */
/*census1940_all_labeled_data.dta (all 122,551,263 records, both sexes);     */
/*it holds target histids only, so an unmatched record is not a target.     */
/*                                                                           */
/*for_mlp1930.dta is unchanged (Ancestry names only) and is not rebuilt.    */
/*READ-ONLY EXCEPT FOR for_mlp1940_tgt.dta, WHICH MUST NOT EXIST YET.        */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local f_intermediate "$REP_F/enum_date/DATA/INTERMEDIATE/"
local srcT  `"`f_intermediate'divided_file1940_true_cleaned_women_added"'
local srcA  `"`f_intermediate'divided_file1940_ans_cleaned_women_added"'
local flags `"`f_intermediate'tgt_flag1940.dta"'
local out   `"`f_intermediate'for_mlp1940_tgt.dta"'

capture confirm file `"`out'"'
if !_rc {
	display as error "`out' exists; move it aside first"
	exit 602
}
confirm file `"`flags'"'

local fT : dir `"`srcT'"' files "norace*.dta"
local fA : dir `"`srcA'"' files "norace*.dta"
local fT : list sort fT
local fA : list sort fA
if !`: list fT === fA' {
	display as error "_true_cleaned and _ans_cleaned hold different birthplace files"
	exit 459
}
if `"`fT'"'=="" {
	display as error "no norace*.dta files in `srcT'"
	exit 601
}

tempfile ans
local tot 0
local ntgt 0
local ntgtml 0
local nml 0
local k 0
foreach f of local fT {
	local b = subinstr(subinstr("`f'", "norace", "", 1), ".dta", "", 1)
	confirm integer number `b'

	use id sex age mi f_name l_name using `"`srcA'/`f'"', clear
	isid id
	rename (sex age) (sex_ans age_ans)
	save `ans', replace

	use id sex age mi_true_cleaned f_name l_name name_true_cleaned_exists using `"`srcT'/`f'"', clear
	isid id
	local n0 = _N
	quietly count if name_true_cleaned_exists==1
	local nml = `nml' + r(N)
	rename (f_name l_name) (namefrst_true_cleaned namelast_true_cleaned)
	merge 1:1 id using `ans', assert(3) nogen
	/*THE ORIGINAL TOOK age AND sex FROM THE _true_cleaned FILE; CHECK THEY  */
	/*AGREE WITH _ans_cleaned SO THE TWO SOURCES DESCRIBE THE SAME PEOPLE.   */
	assert sex==sex_ans & age==age_ans
	drop sex_ans age_ans
	merge 1:1 id using `"`flags'"', keep(1 3) keepusing(tgt)
	replace tgt = 0 if _merge==1
	drop _merge
	assert _N==`n0'

	replace namefrst_true_cleaned = f_name if !tgt
	replace namelast_true_cleaned = l_name if !tgt
	replace mi_true_cleaned = mi if !tgt
	replace name_true_cleaned_exists = 0 if !tgt

	quietly count if tgt
	local ntgt = `ntgt' + r(N)
	quietly count if tgt & name_true_cleaned_exists==1
	local ntgtml = `ntgtml' + r(N)
	local tot = `tot' + _N

	gen bpl = `b'
	rename (id f_name l_name) (histid namefrst namelast)
	keep histid age sex bpl namefrst namelast mi namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned name_true_cleaned_exists
	order histid age sex bpl namefrst namelast mi namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned name_true_cleaned_exists

	local ++k
	tempfile p`k'
	save `p`k''
}

/*APPEND ONCE AT THE END (A GROWING FILE RE-SAVED 144 TIMES IS SLOW).*/
use `p1', clear
forvalues i = 2/`k' {
	append using `p`i''
}
isid histid
assert _N==`tot'
quietly count if name_true_cleaned_exists==1
assert r(N)==`ntgtml'
compress
save `"`out'"'
display "for_mlp1940_tgt: `k' birthplace files, `tot' records, `ntgt' target records, `ntgtml' with model names (all records with model names: `nml')"
