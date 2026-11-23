/*TARGET-ONLY 1940 FILE FOR IPUMS MLP LINKING, WITHOUT THE "InvalidPred"      */
/*SENTINEL (2026-11-23). A copy of 1d_for_mlp_tgt.do (which is unchanged and */
/*whose output for_mlp1940_tgt.dta stays as it is) with one addition: on     */
/*target records, a model field equal to "invalidpred" is replaced by what   */
/*1_divide's fallback gives for an empty field, as 1e_tgtns_divided_files.do */
/*does for ABE: Ancestry's cleaned name passed again through                 */
/*abeclean ..., sex(sex) initial() nickname nonysiis, with the record's own  */
/*sex (these files hold both sexes; 1_divide:172 uses sex(sex)). The         */
/*initial on a sentinel first name is the one that pass gives. A record with */
/*BOTH fields sentinel gets name_true_cleaned_exists=0, as in 1e. A record   */
/*with ONE sentinel field and the other model field empty (~15,665 target    */
/*records, ditto_diag.md) also ends with no model name, but the source does  */
/*not record which field was empty, so its flag stays 1 (2026-11-23 REVIEW,  */
/*accepted): the flag means "had a model row", and the ntgtml count below    */
/*overstates records with a usable model name by at most that many.         */
/*Output: for_mlp1940_tgtns.dta, same variables and layout as below.         */
/*                                                                           */
/*ORIGINAL HEADER OF 1d_for_mlp_tgt.do:                                       */
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
/*READ-ONLY EXCEPT FOR for_mlp1940_tgtns.dta, WHICH MUST NOT EXIST YET.      */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local f_intermediate "$REP_F/enum_date/DATA/INTERMEDIATE/"
local srcT  `"`f_intermediate'divided_file1940_true_cleaned_women_added"'
local srcA  `"`f_intermediate'divided_file1940_ans_cleaned_women_added"'
local flags `"`f_intermediate'tgt_flag1940.dta"'
local out   `"`f_intermediate'for_mlp1940_tgtns.dta"'

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
local nf 0
local nl 0
local nboth 0
local nrc 0
local nmi 0
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

	/*SENTINEL FIX (TARGET RECORDS ONLY; NON-TARGETS NOW HOLD ANCESTRY'S).   */
	assert f_name!="invalidpred" & l_name!="invalidpred"
	gen byte sf = namefrst_true_cleaned=="invalidpred"
	gen byte sl = namelast_true_cleaned=="invalidpred"
	assert tgt & name_true_cleaned_exists==1 if sf | sl
	quietly count if sf
	local nf = `nf' + r(N)
	quietly count if sl
	local nl = `nl' + r(N)
	quietly count if sf & sl
	local nboth = `nboth' + r(N)
	quietly count if sf | sl
	if r(N) {
		preserve
		keep if sf | sl
		keep id sex f_name l_name
		rename (f_name l_name) (f_fb l_fb)
		abeclean f_fb l_fb, sex(sex) initial(mi_rc) nickname nonysiis
		keep id f_fb_cleaned l_fb_cleaned mi_rc f_fb l_fb
		tempfile rc
		save `rc'
		restore
		merge 1:1 id using `rc', assert(1 3) nogen
		quietly count if sf & mi_rc!=""
		local nmi = `nmi' + r(N)
		quietly count if (sf & f_fb_cleaned!=f_fb) | (sl & l_fb_cleaned!=l_fb)
		local nrc = `nrc' + r(N)
		replace namefrst_true_cleaned = f_fb_cleaned if sf
		replace mi_true_cleaned = mi_rc if sf
		replace namelast_true_cleaned = l_fb_cleaned if sl
		drop f_fb f_fb_cleaned l_fb l_fb_cleaned mi_rc
	}
	replace name_true_cleaned_exists = 0 if sf & sl
	assert namefrst_true_cleaned!="invalidpred" & namelast_true_cleaned!="invalidpred"
	drop sf sl

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
display "sentinel replaced: first name `nf', surname `nl', both `nboth'; re-clean differs from Ancestry's cleaned name `nrc'; non-empty fallback initial `nmi'"
display "for_mlp1940_tgtns: `k' birthplace files, `tot' records, `ntgt' target records, `ntgtml' with model names (all records with model names: `nml')"
