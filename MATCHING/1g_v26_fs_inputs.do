/*FAMILYSEARCH-NAME ABE INPUTS ON THE v26 BASE (2026-11-25). MACHINE A.      */
/*                                                                           */
/*The paper's FamilySearch comparison, four versions (author, 2026-11-25),  */
/*1930 -> 1940, men, ABE exact:                                              */
/*  (a) 1930 Ancestry; 1940 FamilySearch on target records, Ancestry else    */
/*  (b) 1930 Ancestry; 1940 FamilySearch wherever it exists                  */
/*  (c) 1930 and 1940 FamilySearch wherever it exists                        */
/*  (d) as (c), and on 1940 target records our model's names; a model field */
/*      that is empty (or blanked "InvalidPred", or cleans to empty) falls   */
/*      back to FamilySearch, then Ancestry (author's choice, 2026-11-25)    */
/*"Wherever it exists" is per field: a field FamilySearch lacks keeps        */
/*Ancestry's (as 1b_fs_divided_files.do). The middle initial is that of the */
/*first name used (FamilySearch's, the model's, or Ancestry's).              */
/*                                                                           */
/*BASE: the v26 Ancestry inputs (1f_v26_inputs.do; 00655/00656 men, abeclean */
/*0.26), so every version has exactly the same men as Old/New/Target-only   */
/*(v26) and the MLP. FamilySearch names: fs_names<yr>.dta                    */
/*(0b_create_fs_names.do; raw FamilySearch strings, lower case, never        */
/*abecleaned), cleaned here with 0.26 as the model names are (nickname,      */
/*nonysiis, record's sex = 1). Target flag: tgt_flag1940.dta (on id).       */
/*Model names (1940): the model table rebuilt exactly as 1f_v26_inputs.do    */
/*part 1, merged through the source's filename/row as there (duplicates of  */
/*a filename/row across both sexes blank it), cleaned alone so an empty     */
/*model field is known.                                                      */
/*                                                                           */
/*CHECK: on target records, where the model gave a field, (d)'s field must  */
/*equal Target-only (v26)'s (divided_file1940_v26_tgt_cleaned); off target  */
/*(d) must equal (b). Exit 9 otherwise.                                     */
/*                                                                           */
/*OUTPUTS ($REP_F/enum_date/DATA/INTERMEDIATE/, norace<bpl>.dta, vars id     */
/*f_name l_name age mi fs_frst_used fs_last_used):                          */
/*  divided_file1930_v26_fs_cleaned       (c),(d) 1930                       */
/*  divided_file1940_v26_fs_cleaned       (b),(c) 1940                       */
/*  divided_file1940_v26_fstgt_cleaned    (a) 1940                           */
/*  divided_file1940_v26_fsmltgt_cleaned  (d) 1940                           */
/*Refuses to start if any output folder is non-empty.                        */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
which abeclean
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
local fi "$REP_F/enum_date/DATA/INTERMEDIATE/"
local root "$REP_SNU/fixing_transcription_errors/DATA/TRANSCRIPTIONS/USCensus1940FullCount/output_and_output1_ssha2025"
local flags `"`fi'tgt_flag1940.dta"'
foreach f in `"`flags'"' `"`fi'fs_names1930.dta"' `"`fi'fs_names1940.dta"' {
	confirm file `"`f'"'
}
/*INPUT FOLDERS, BEFORE ANYTHING IS WRITTEN (2026-11-25 REVIEW): THE 1940   */
/*v26 ANS, v26 TGT AND RAW SOURCE HOLD THE SAME BIRTHPLACE FILES (THE RAW   */
/*SOURCE MAY HAVE MORE: A WOMEN-ONLY FILE HAS NO v26 SHARD).               */
local fa30 : dir `"`fi'divided_file1930_v26_ans_cleaned"' files "norace*.dta"
local fa : dir `"`fi'divided_file1940_v26_ans_cleaned"' files "norace*.dta"
local ft : dir `"`fi'divided_file1940_v26_tgt_cleaned"' files "norace*.dta"
local fr : dir `"`fi'divided_file1940_women_added"' files "norace*.dta"
local fa : list sort fa
local ft : list sort ft
local miss : list fa - fr
if `"`fa30'"'=="" | `"`fa'"'=="" | !`: list fa === ft' | `"`miss'"'!="" {
	display as error "v26 input folders missing or inconsistent"
	exit 459
}

local dirs divided_file1930_v26_fs_cleaned divided_file1940_v26_fs_cleaned divided_file1940_v26_fstgt_cleaned divided_file1940_v26_fsmltgt_cleaned
foreach d of local dirs {
	mata: st_local("dex", strofreal(direxists(st_local("fi") + st_local("d"))))
	local dfl ""
	if `dex' local dfl : dir `"`fi'`d'"' files "*"
	if `"`dfl'"'!="" {
		display as error "`fi'`d' is not empty; move it aside first"
		exit 602
	}
	capture mkdir `"`fi'`d'"'
	mata: st_local("dex", strofreal(direxists(st_local("fi") + st_local("d"))))
	assert `dex'
}

/*abeclean STOPS WITH r(2000) WHEN A FIELD HAS NO LETTERS IN ANY RECORD; A   */
/*PLACEHOLDER ROW IS ADDED FOR THE CALL AND DROPPED (1b_fs_divided_files.do).*/
capture program drop clean2
program define clean2
	args f l mi
	local n0 = _N
	gen byte _ph = 0
	set obs `=_N+1'
	replace _ph = 1 in l
	replace `f' = "john" in l
	replace `l' = "smith" in l
	replace sex = 1 in l
	abeclean `f' `l', sex(sex) initial(`mi') nickname nonysiis
	drop if _ph
	drop _ph
	assert _N==`n0'
end

/*=========================================================*/
/*1. MODEL TABLE (1940), EXACTLY AS 1f_v26_inputs.do PART 1 */
/*=========================================================*/
local states al ar az ca co ct dc de fl ga hi ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy
local z 0
foreach s of local states {
	local ++z
	if `z'==1 use filename row namefrst_ml namelast_ml_ditto parsing_quality using `"`root'/`s'/merged_data.dta"', clear
	else      append using `"`root'/`s'/merged_data.dta"', keep(filename row namefrst_ml namelast_ml_ditto parsing_quality)
}
display "model rows read: " %15.0fc _N " from `z' states"
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
/*2. 1930: FAMILYSEARCH WHEREVER IT EXISTS                 */
/*=========================================================*/
local src `"`fi'divided_file1930_v26_ans_cleaned"'
local fl : dir `"`src'"' files "norace*.dta"
if `"`fl'"'=="" {
	display as error "no files in `src'"
	exit 601
}
local tot 0
local nf 0
local nl 0
local nm30 0
foreach f of local fl {
	use `"`src'/`f'"', clear
	isid id
	local n0 = _N
	rename id histid
	merge 1:1 histid using `"`fi'fs_names1930.dta"', keep(1 3)
	quietly count if _merge==3
	local nm30 = `nm30' + r(N)
	drop _merge
	rename histid id
	assert _N==`n0'
	replace fs_namefrst = "" if missing(fs_namefrst)
	replace fs_namelast = "" if missing(fs_namelast)
	gen byte sex = 1
	clean2 fs_namefrst fs_namelast mi_fs
	gen byte fs_frst_used = fs_namefrst_cleaned!=""
	gen byte fs_last_used = fs_namelast_cleaned!=""
	replace f_name = fs_namefrst_cleaned if fs_frst_used
	replace l_name = fs_namelast_cleaned if fs_last_used
	replace mi     = mi_fs if fs_frst_used
	local tot = `tot' + _N
	quietly count if fs_frst_used
	local nf = `nf' + r(N)
	quietly count if fs_last_used
	local nl = `nl' + r(N)
	keep id f_name l_name age mi fs_frst_used fs_last_used
	order id f_name l_name age mi fs_frst_used fs_last_used
	save `"`fi'divided_file1930_v26_fs_cleaned/`f'"'
}
display "1930: `tot' men; with a FamilySearch record `nm30'; FamilySearch first name used `nf', surname used `nl'"
assert `nf'>0 & `nl'>0

/*=========================================================*/
/*3. 1940: (a), (b)/(c), (d)                               */
/*=========================================================*/
local src `"`fi'divided_file1940_v26_ans_cleaned"'
local raw `"`fi'divided_file1940_women_added"'
local fl : dir `"`src'"' files "norace*.dta"
if `"`fl'"'=="" {
	display as error "no files in `src'"
	exit 601
}
local tot 0
local ntgt 0
local nf 0
local nl 0
local nfa 0
local nmf 0
local nml 0
local nbad 0
foreach f of local fl {
	/*MODEL NAMES FOR THIS BIRTHPLACE, AS 1f (BOTH SEXES FOR THE DUPLICATE  */
	/*filename/row RULE, THEN MEN).                                         */
	use histid sex filename row using `"`raw'/`f'"', clear
	replace filename = filename + ".jpg"
	merge m:1 filename row using `model', keep(1 3) keepusing(namefrst_ml namelast_ml_ditto)
	bysort filename row: gen long N = _N
	replace namefrst_ml = "" if N>1 | _merge!=3
	replace namelast_ml_ditto = "" if N>1 | _merge!=3
	replace namefrst_ml = "" if missing(namefrst_ml)
	replace namelast_ml_ditto = "" if missing(namelast_ml_ditto)
	keep if sex==1
	keep histid namefrst_ml namelast_ml_ditto
	rename histid id
	isid id
	tempfile mod
	save `mod'

	use `"`src'/`f'"', clear
	isid id
	local n0 = _N
	merge 1:1 id using `mod', keep(1 3) nogen
	merge 1:1 id using `"`flags'"', keep(1 3) keepusing(tgt)
	replace tgt = 0 if _merge==1
	drop _merge
	rename id histid
	merge 1:1 histid using `"`fi'fs_names1940.dta"', keep(1 3) nogen
	rename histid id
	assert _N==`n0'
	foreach v in namefrst_ml namelast_ml_ditto fs_namefrst fs_namelast {
		replace `v' = "" if missing(`v')
	}
	gen byte sex = 1
	clean2 fs_namefrst fs_namelast mi_fs
	clean2 namefrst_ml namelast_ml_ditto mi_ml
	gen byte fs_frst_used = fs_namefrst_cleaned!=""
	gen byte fs_last_used = fs_namelast_cleaned!=""
	gen byte ml_f = tgt & namefrst_ml_cleaned!=""
	gen byte ml_l = tgt & namelast_ml_ditto_cleaned!=""
	rename (f_name l_name mi) (a_f a_l a_mi)

	/*(b)/(c): FAMILYSEARCH WHEREVER IT EXISTS                             */
	gen f_b  = cond(fs_frst_used, fs_namefrst_cleaned, a_f)
	gen l_b  = cond(fs_last_used, fs_namelast_cleaned, a_l)
	gen mi_b = cond(fs_frst_used, mi_fs, a_mi)
	/*(a): FAMILYSEARCH ON TARGET RECORDS ONLY                             */
	gen f_a  = cond(tgt, f_b, a_f)
	gen l_a  = cond(tgt, l_b, a_l)
	gen mi_a = cond(tgt, mi_b, a_mi)
	/*(d): (b), WITH THE MODEL'S FIELDS ON TARGET RECORDS WHERE IT GAVE ONE */
	gen f_d  = cond(ml_f, namefrst_ml_cleaned, f_b)
	gen l_d  = cond(ml_l, namelast_ml_ditto_cleaned, l_b)
	gen mi_d = cond(ml_f, mi_ml, mi_b)

	/*CHECK AGAINST TARGET-ONLY (v26) AND (b)                              */
	merge 1:1 id using `"`fi'divided_file1940_v26_tgt_cleaned/`f'"', keep(1 3) keepusing(f_name l_name mi_true_cleaned name_true_cleaned_exists)
	assert _merge==3
	drop _merge
	quietly count if (ml_f & (f_d!=f_name | mi_d!=mi_true_cleaned)) | (ml_l & l_d!=l_name) | (!tgt & (f_d!=f_b | l_d!=l_b | mi_d!=mi_b)) | ((ml_f | ml_l) & !name_true_cleaned_exists)
	local nbad = `nbad' + r(N)
	drop f_name l_name mi_true_cleaned name_true_cleaned_exists

	local tot = `tot' + _N
	quietly count if tgt
	local ntgt = `ntgt' + r(N)
	quietly count if fs_frst_used
	local nf = `nf' + r(N)
	quietly count if fs_last_used
	local nl = `nl' + r(N)
	quietly count if tgt & fs_frst_used
	local nfa = `nfa' + r(N)
	quietly count if ml_f
	local nmf = `nmf' + r(N)
	quietly count if ml_l
	local nml = `nml' + r(N)

	foreach v in a b d {
		preserve
		/*fs_*_used: WHETHER THIS VERSION'S FIELD IS FAMILYSEARCH'S.         */
		if "`v'"=="a" {
			replace fs_frst_used = fs_frst_used & tgt
			replace fs_last_used = fs_last_used & tgt
		}
		if "`v'"=="d" {
			replace fs_frst_used = fs_frst_used & !ml_f
			replace fs_last_used = fs_last_used & !ml_l
		}
		rename (f_`v' l_`v' mi_`v') (f_name l_name mi)
		keep id f_name l_name age mi fs_frst_used fs_last_used
		order id f_name l_name age mi fs_frst_used fs_last_used
		local out = cond("`v'"=="a", "fstgt", cond("`v'"=="b", "fs", "fsmltgt"))
		save `"`fi'divided_file1940_v26_`out'_cleaned/`f'"'
		restore
	}
}
display "1940: `tot' men, `ntgt' target; FamilySearch first name used `nf' (on target `nfa'), surname `nl'; model first name on target `nmf', surname `nml'"
display "1940: records where (d) disagrees with Target-only (v26) or (b): `nbad'"
/*NON-VACUOUS (2026-11-25 REVIEW): EVERY SOURCE MUST HAVE BEEN USED.        */
assert `ntgt'>0 & `nf'>0 & `nl'>0 & `nfa'>0 & `nmf'>0 & `nml'>0
if `nbad' {
	display as error "CHECK FAILED"
	exit 9
}
display "V26 FS INPUTS DONE"
