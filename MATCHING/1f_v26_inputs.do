/*ALL 1930/1940 LINKING INPUTS REBUILT WITH abeclean 0.26 (2026-11-24).     */
/*                                                                           */
/*WHY. marshall_diag.log: the stored Ancestry cleaned first names           */
/*(namefrst_ans_cleaned, made by 0_create_file_for_matching_intgenV4_       */
/*women_added.do:87 with an abeclean older than 0.25, "fixed issue with     */
/*marshall") turn ~285-290k men per year into "marshall" (raw lee, edgar,   */
/*dock, abram, ...); the February 2026 1940 model-name file has the same    */
/*defect. Surnames are unaffected. check_mlp_abe_same_input.log /           */
/*extract_diff_diag.log: the ABE inputs (1940 extract 00450) and the MLP    */
/*inputs (00656) also differ in age (1.9% of men) and birthplace (0.9%).   */
/*                                                                           */
/*WHAT. One source for every method: the women-added divided files          */
/*(divided_file<yr>_women_added: IPUMS 00655 for 1930, 00656 for 1940, both */
/*sexes, race 1|2, bpl<900, made by 0_create), which hold Ancestry's RAW    */
/*names (namefrst_ans, namelast_ans, from name_only<yr>.dta). Every name is */
/*cleaned here with the installed abeclean (0.26; `which` below). ABE       */
/*inputs are the men of these files; MLP inputs are all records. The men    */
/*in an ABE input and in the matching MLP input are therefore identical.    */
/*                                                                           */
/*CLEANING, as the pipeline does it:                                        */
/*  Ancestry (0_create:87): abeclean namefrst namelast, sex(sex)            */
/*      initial(mi) nickname   (nonysiis added: no nysiis is used)          */
/*  Model, 1940 (1_divide_and_clean_everyoneV5_women_addedV2.do:85-177):    */
/*      model table = 49 states' merged_data.dta (output_and_output1_       */
/*      ssha2025), rows identical on (filename,row,names,parsing_quality)   */
/*      collapsed, conflicting (filename,row) dropped, kept if a name is    */
/*      non-empty and parsing_quality is not missing; merged m:1 on         */
/*      (filename,row); census (filename,row) duplicates within a           */
/*      birthplace file get no model names; empty model fields fall back   */
/*      to Ancestry's raw field; abeclean ..., sex(sex)                     */
/*      initial(mi_true_cleaned) nickname nonysiis.                         */
/*  Two deliberate departures from 1_divide, both corrections:              */
/*   (1) the model's literal "InvalidPred" (any case) is blanked BEFORE the */
/*       non-empty screen, so it falls back to Ancestry like an empty field */
/*       (1e_tgtns_divided_files.do fixed this after the fact; here a      */
/*       record left with no usable model field also gets                  */
/*       name_true_cleaned_exists=0, which 1e could not do);                */
/*   (2) the fallback copies Ancestry's RAW name (what 1_divide:169 names,  */
/*       namefrst_ans; Stata's abbreviation made it read the stored        */
/*       cleaned name instead), so a fallback first name keeps Ancestry's   */
/*       middle initial rather than an empty one.                           */
/*  Target-only (1c_tgt_divided_files.do): model names on target records    */
/*      (tgt_flag1940.dta), Ancestry's names, initial and exists=0 on the   */
/*      others.                                                             */
/*                                                                           */
/*OUTPUTS (F:/enum_date/DATA/INTERMEDIATE/; refuses to run if any exists):  */
/*  ABE, men, norace<bpl>.dta per birthplace, layouts as the current files: */
/*    divided_file1930_v26_ans_cleaned    id age mi f_name l_name           */
/*    divided_file1940_v26_ans_cleaned    id age mi f_name l_name           */
/*    divided_file1940_v26_true_cleaned   id name_true_cleaned_exists age   */
/*                                        mi_true_cleaned f_name l_name     */
/*    divided_file1940_v26_tgt_cleaned    same, target-only                 */
/*  MLP, both sexes, layouts as for_mlp1940.dta / 1d_for_mlp_tgt.do:        */
/*    for_mlp1930_v26.dta       histid age sex bpl namefrst namelast mi     */
/*    for_mlp1940_v26.dta       histid age sex bpl namefrst namelast mi     */
/*                              namefrst_true_cleaned namelast_true_cleaned */
/*                              mi_true_cleaned name_true_cleaned_exists    */
/*    for_mlp1940_v26_tgt.dta   same, target-only                           */
/*Sources are read only.                                                    */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
which abeclean
/*THE OUTPUTS ARE LABELLED v26, SO THE RESOLVED abeclean MUST BE 0.26     */
/*(2026-11-24 REVIEW).                                                    */
findfile abeclean.ado
tempname fh
file open `fh' using `"`r(fn)'"', read text
local hit 0
forvalues i = 1/5 {
	file read `fh' line
	if strpos(`"`line'"', "version 0.26") local hit 1
}
file close `fh'
if !`hit' {
	display as error "abeclean.ado is not version 0.26"
	exit 459
}
local f_intermediate "$REP_F/enum_date/DATA/INTERMEDIATE/"
local root "$REP_SNU/fixing_transcription_errors/DATA/TRANSCRIPTIONS/USCensus1940FullCount/output_and_output1_ssha2025"
local flags `"`f_intermediate'tgt_flag1940.dta"'
confirm file `"`flags'"'

local dirs divided_file1930_v26_ans_cleaned divided_file1940_v26_ans_cleaned divided_file1940_v26_true_cleaned divided_file1940_v26_tgt_cleaned
foreach d of local dirs {
	mata: st_local("dex", strofreal(direxists(st_local("f_intermediate") + st_local("d"))))
	local dfl ""
	if `dex' local dfl : dir `"`f_intermediate'`d'"' files "*"
	if `"`dfl'"'!="" {
		display as error "`f_intermediate'`d' is not empty; move it aside first"
		exit 602
	}
}
foreach o in for_mlp1930_v26 for_mlp1940_v26 for_mlp1940_v26_tgt {
	capture confirm file `"`f_intermediate'`o'.dta"'
	if !_rc {
		display as error "`f_intermediate'`o'.dta exists; move it aside first"
		exit 602
	}
}

/*=========================================================*/
/*1. MODEL TABLE (1940), AS 1_divide:85-141                */
/*=========================================================*/
local states al ar az ca co ct dc de fl ga hi ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy
local z 0
foreach s of local states {
	local ++z
	if `z'==1 use filename row namefrst_ml namelast_ml_ditto parsing_quality using `"`root'/`s'/merged_data.dta"', clear
	else      append using `"`root'/`s'/merged_data.dta"', keep(filename row namefrst_ml namelast_ml_ditto parsing_quality)
}
display "model rows read: " %15.0fc _N " from `z' states"
/*DEPARTURE (1): THE SENTINEL IS BLANKED BEFORE ANY SCREEN.                 */
quietly count if lower(strtrim(namefrst_ml))=="invalidpred"
display "InvalidPred first names blanked: " %12.0fc r(N)
quietly count if lower(strtrim(namelast_ml_ditto))=="invalidpred"
display "InvalidPred surnames blanked: " %12.0fc r(N)
replace namefrst_ml = "" if lower(strtrim(namefrst_ml))=="invalidpred"
replace namelast_ml_ditto = "" if lower(strtrim(namelast_ml_ditto))=="invalidpred"
bysort filename row: gen long N1 = _N
bysort filename row namefrst_ml namelast_ml_ditto parsing_quality: gen long N2 = _N
keep if N1==N2
bysort filename row: keep if _n==1
keep if (namefrst_ml!="" | namelast_ml_ditto!="") & parsing_quality!=.
drop N1 N2 parsing_quality
display "model rows kept: " %15.0fc _N
tempfile model
save `model'

/*=========================================================*/
/*2. PER YEAR AND BIRTHPLACE FILE                          */
/*=========================================================*/
foreach d of local dirs {
	capture mkdir `"`f_intermediate'`d'"'
	mata: st_local("dex", strofreal(direxists(st_local("f_intermediate") + st_local("d"))))
	assert `dex'
}
foreach yr in 1930 1940 {
	local src `"`f_intermediate'divided_file`yr'_women_added"'
	local fl : dir `"`src'"' files "norace*.dta"
	local fl : list sort fl
	if `"`fl'"'=="" {
		display as error "no norace*.dta files in `src'"
		exit 601
	}
	local tot 0
	local nmen 0
	local nml 0
	local ntgt 0
	local ntgtml 0
	local nfb_f 0
	local nfb_l 0
	local nmar 0
	local nfb2_f 0
	local nfb2_l 0
	local nnomen 0
	local k 0
	foreach f of local fl {
		local b = subinstr(subinstr("`f'", "norace", "", 1), ".dta", "", 1)
		confirm integer number `b'
		local ++k
		if `yr'==1940 use histid sex age namefrst_ans namelast_ans filename row using `"`src'/`f'"', clear
		else          use histid sex age namefrst_ans namelast_ans using `"`src'/`f'"', clear
		isid histid
		assert inlist(sex,1,2)
		local n0 = _N
		local tot = `tot' + _N

		/*ANCESTRY, 0.26                                                    */
		gen a_f = namefrst_ans
		gen a_l = namelast_ans
		abeclean a_f a_l, sex(sex) initial(mi) nickname nonysiis
		rename (a_f_cleaned a_l_cleaned) (f_ans l_ans)
		drop a_f a_l
		quietly count if f_ans=="marshall" & !strpos(lower(namefrst_ans),"marsh")
		local nmar = `nmar' + r(N)

		if `yr'==1940 {
			/*MODEL NAMES, AS 1_divide:150-177 WITH DEPARTURES (1)-(2)       */
			replace filename = filename + ".jpg"
			merge m:1 filename row using `model', keep(1 3) keepusing(namefrst_ml namelast_ml_ditto)
			bysort filename row: gen long N = _N
			replace namefrst_ml = "" if N>1 & _merge==3
			replace namelast_ml_ditto = "" if N>1 & _merge==3
			gen byte name_true_cleaned_exists = _merge==3 & N==1
			drop _merge N
			assert _N==`n0'
			quietly count if name_true_cleaned_exists & namefrst_ml==""
			local nfb_f = `nfb_f' + r(N)
			quietly count if name_true_cleaned_exists & namelast_ml_ditto==""
			local nfb_l = `nfb_l' + r(N)
			replace namefrst_ml = namefrst_ans if namefrst_ml=="" & namefrst_ans!=""
			replace namelast_ml_ditto = namelast_ans if namelast_ml_ditto=="" & namelast_ans!=""
			abeclean namefrst_ml namelast_ml_ditto, sex(sex) initial(mi_true_cleaned) nickname nonysiis
			rename (namefrst_ml_cleaned namelast_ml_ditto_cleaned) (f_ml l_ml)
			drop namefrst_ml namelast_ml_ditto
			/*A NON-EMPTY MODEL STRING THAT abeclean STRIPS TO "" ALSO FALLS   */
			/*BACK TO ANCESTRY (2026-11-24 REVIEW), WITH ANCESTRY'S INITIAL.   */
			quietly count if f_ml=="" & f_ans!=""
			local nfb2_f = `nfb2_f' + r(N)
			quietly count if l_ml=="" & l_ans!=""
			local nfb2_l = `nfb2_l' + r(N)
			replace mi_true_cleaned = mi if f_ml=="" & f_ans!=""
			replace f_ml = f_ans if f_ml=="" & f_ans!=""
			replace l_ml = l_ans if l_ml=="" & l_ans!=""
			assert lower(f_ml)!="invalidpred" & lower(l_ml)!="invalidpred"
			quietly count if name_true_cleaned_exists
			local nml = `nml' + r(N)

			/*TARGET FLAG                                                   */
			rename histid id
			merge 1:1 id using `"`flags'"', keep(1 3) keepusing(tgt)
			replace tgt = 0 if _merge==1
			drop _merge
			rename id histid
			assert _N==`n0'
			quietly count if tgt
			local ntgt = `ntgt' + r(N)
			quietly count if tgt & name_true_cleaned_exists
			local ntgtml = `ntgtml' + r(N)
		}

		/*ABE FILES, MEN                                                    */
		preserve
		keep if sex==1
		local nmen = `nmen' + _N
		/*A BIRTHPLACE FILE WITH NO MEN (e.g. 1930 norace511) GETS NO ABE    */
		/*SHARD: 2_ABE WOULD ABORT ON AN EMPTY ONE (2026-11-24 REVIEW).      */
		if _N==0 local ++nnomen
		rename histid id
		if `yr'==1940 {
			/*STATA ALLOWS ONE preserve; THE MEN ARE HELD IN A TEMPFILE     */
			/*(r(621), 2026-11-24 RUN).                                      */
			tempfile men
			save `men'
			/*ALL RECORDS WITH MODEL NAMES                                   */
			keep id name_true_cleaned_exists age mi_true_cleaned f_ml l_ml
			rename (f_ml l_ml) (f_name l_name)
			order id name_true_cleaned_exists age mi_true_cleaned f_name l_name
			if _N save `"`f_intermediate'divided_file1940_v26_true_cleaned/`f'"'
			use `men', clear
			/*TARGET-ONLY                                                    */
			gen f_name = cond(tgt, f_ml, f_ans)
			gen l_name = cond(tgt, l_ml, l_ans)
			replace mi_true_cleaned = mi if !tgt
			replace name_true_cleaned_exists = 0 if !tgt
			keep id name_true_cleaned_exists age mi_true_cleaned f_name l_name
			order id name_true_cleaned_exists age mi_true_cleaned f_name l_name
			if _N save `"`f_intermediate'divided_file1940_v26_tgt_cleaned/`f'"'
			use `men', clear
		}
		keep id age mi f_ans l_ans
		rename (f_ans l_ans) (f_name l_name)
		order age id mi f_name l_name
		if _N save `"`f_intermediate'divided_file`yr'_v26_ans_cleaned/`f'"'
		restore

		/*MLP PIECES, BOTH SEXES                                            */
		gen int bpl = `b'
		rename (f_ans l_ans) (namefrst namelast)
		if `yr'==1940 {
			rename (f_ml l_ml) (namefrst_true_cleaned namelast_true_cleaned)
			keep histid age sex bpl namefrst namelast mi namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned name_true_cleaned_exists tgt
		}
		else keep histid age sex bpl namefrst namelast mi
		tempfile m`yr'_`k'
		save `m`yr'_`k''
	}
	display "`yr': `k' birthplace files, `tot' records, `nmen' men; first names 0.26 cleans to marshall from a raw name without 'marsh': `nmar'"
	if `yr'==1940 display "1940: `nml' records with model names, `ntgt' target, `ntgtml' target with model names; model first name empty -> Ancestry `nfb_f', model surname empty -> Ancestry `nfb_l'; model name cleaned to empty -> Ancestry: first `nfb2_f', surname `nfb2_l'"
	display "`yr': birthplace files with no men (no ABE shard): `nnomen'"
	local K`yr' `k'
	local T`yr' `tot'
}

/*=========================================================*/
/*3. MLP FILES                                             */
/*=========================================================*/
use `m1930_1', clear
forvalues i = 2/`K1930' {
	append using `m1930_`i''
}
isid histid
assert _N==`T1930'
order histid age sex bpl namefrst namelast mi
compress
save `"`f_intermediate'for_mlp1930_v26.dta"'

use `m1940_1', clear
forvalues i = 2/`K1940' {
	append using `m1940_`i''
}
isid histid
assert _N==`T1940'
order histid age sex bpl namefrst namelast mi namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned name_true_cleaned_exists
preserve
drop tgt
compress
save `"`f_intermediate'for_mlp1940_v26.dta"'
restore
replace namefrst_true_cleaned = namefrst if !tgt
replace namelast_true_cleaned = namelast if !tgt
replace mi_true_cleaned = mi if !tgt
replace name_true_cleaned_exists = 0 if !tgt
drop tgt
compress
save `"`f_intermediate'for_mlp1940_v26_tgt.dta"'
display "V26 INPUTS DONE"
