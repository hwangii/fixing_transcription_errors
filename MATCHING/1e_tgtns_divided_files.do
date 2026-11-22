/*TARGET-ONLY ML DIVIDED FILES FOR 1940, WITHOUT THE "InvalidPred" SENTINEL   */
/*(2026-11-22).                                                               */
/*                                                                           */
/*The model files carry the literal string "InvalidPred" in namefrst_ml and,  */
/*through ditto resolution, in namelast_ml_ditto (MATCHING/results/          */
/*ditto_diag.md section 4: 336,679 first names, 271,055 surnames). The       */
/*linking code (1_divide_and_clean_everyoneV5_women_addedV2.do:169-170)      */
/*falls back to Ancestry only when a model field is EMPTY, so the sentinel   */
/*passes through abeclean as "invalidpred" and is matched as a name.         */
/*                                                                           */
/*This builds divided_file1940_tgtns_cleaned from divided_file1940_tgt_cleaned*/
/*(1c_tgt_divided_files.do: model names on target records, Ancestry's        */
/*elsewhere), replacing each "invalidpred" field by what 1_divide's fallback */
/*would have produced had the field been blank:                              */
/*  - the fallback is per field: it copies Ancestry's name                   */
/*    (namefrst_ans_cleaned, i.e. _ans_cleaned's f_name / l_name) and runs   */
/*    abeclean ..., sex(sex) initial() nickname nonysiis on it again. That   */
/*    pass is RUN HERE on the sentinel rows (2026-11-22 REVIEW: abeclean is  */
/*    not exactly idempotent, 1c's 436 cases), with sex=1 because the       */
/*    1940 divided files are men only; how often it differs from a plain    */
/*    copy of _ans_cleaned is reported;                                      */
/*  - the middle initial on a sentinel first name is the one that same pass  */
/*    gives. 1_divide's fallback re-cleans Ancestry's already-cleaned first  */
/*    name, which yields an EMPTY initial (2026-11-22 REVIEW), and the       */
/*    sentinel rows already have an empty one (asserted), so it is expected  */
/*    to stay ""; any exception is counted;                                  */
/*  - a record with BOTH fields "invalidpred" would have had no model name   */
/*    at all (1_divide keeps a model row only if a field is non-empty), so   */
/*    its name_true_cleaned_exists becomes 0. A record with ONE sentinel     */
/*    field and the other model field empty (~15,665 target records, both   */
/*    sexes, ditto_diag.md) also has no model name after the fix, but the    */
/*    source does not record which field was empty, so its flag stays 1.    */
/*    No matcher, append or scorer reads the flag.                           */
/*Non-target records already carry Ancestry's names and are not touched.     */
/*Variables, records and birthplace files are those of the source.           */
/*Neither source is modified. Refuses to run if the output folder exists.    */
/*                                                                           */
/*  Run by MATCHING/_tgtns_run.do.                                            */

if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local f_intermediate "$REP_F/enum_date/DATA/INTERMEDIATE/"

local srcG `"`f_intermediate'divided_file1940_tgt_cleaned"'
local srcA `"`f_intermediate'divided_file1940_ans_cleaned"'
local dst  `"`f_intermediate'divided_file1940_tgtns_cleaned"'
mata: st_local("dex", strofreal(direxists(st_local("dst"))))
if `dex' {
	display as error "`dst' exists; move it aside first"
	exit 602
}

local fG : dir `"`srcG'"' files "norace*.dta"
local fA : dir `"`srcA'"' files "norace*.dta"
local fG : list sort fG
local fA : list sort fA
if !`: list fG === fA' {
	display as error "_tgt_cleaned and _ans_cleaned hold different birthplace files"
	exit 459
}
if `"`fG'"'=="" {
	display as error "no norace*.dta files in `srcG'"
	exit 601
}
capture mkdir `"`dst'"'

local flags `"`f_intermediate'tgt_flag1940.dta"'
confirm file `"`flags'"'
tempfile ans
local tot 0
local nf 0
local nl 0
local nboth 0
local nchk 0
local nbad 0
local nrc 0
local nmi 0
foreach f of local fG {
	use id f_name l_name mi using `"`srcA'/`f'"', clear
	isid id
	rename (f_name l_name mi) (f_ans l_ans mi_ans)
	/*ANCESTRY NEVER CARRIES THE SENTINEL, SO THE REPLACEMENT CANNOT REINTRODUCE IT.*/
	assert f_ans!="invalidpred" & l_ans!="invalidpred"
	save `ans', replace

	use `"`srcG'/`f'"', clear
	isid id
	local n0 = _N
	merge 1:1 id using `ans', assert(3) nogen
	merge 1:1 id using `"`flags'"', keep(1 3) keepusing(tgt)
	replace tgt = 0 if _merge==1
	drop _merge
	assert _N==`n0'

	/*CHECK, AS IN 1c (NAMES ONLY, TARGET RECORDS WITHOUT MODEL NAMES; 1c SET */
	/*EVERY NON-TARGET RECORD TO ANCESTRY, SO THOSE ARE NOT COUNTED).         */
	quietly count if tgt & name_true_cleaned_exists==0
	local nchk = `nchk' + r(N)
	quietly count if tgt & name_true_cleaned_exists==0 & !(f_name==f_ans & l_name==l_ans)
	local nbad = `nbad' + r(N)

	gen byte sf = f_name=="invalidpred"
	gen byte sl = l_name=="invalidpred"
	/*ONLY TARGET RECORDS WITH MODEL NAMES CAN CARRY IT, AND A SENTINEL FIRST */
	/*NAME ALREADY HAS AN EMPTY INITIAL (SEE HEADER).                         */
	assert name_true_cleaned_exists==1 & tgt if sf | sl
	assert mi_true_cleaned=="" if sf
	quietly count if sf
	local nf = `nf' + r(N)
	quietly count if sl
	local nl = `nl' + r(N)
	quietly count if sf & sl
	local nboth = `nboth' + r(N)

	/*THE FALLBACK'S SECOND abeclean PASS ON ANCESTRY'S NAMES, SENTINEL ROWS ONLY.*/
	quietly count if sf | sl
	if r(N) {
		preserve
		keep if sf | sl
		keep id f_ans l_ans
		gen byte sex = 1
		abeclean f_ans l_ans, sex(sex) initial(mi_rc) nickname nonysiis
		keep id f_ans_cleaned l_ans_cleaned mi_rc
		tempfile rc
		save `rc'
		restore
		merge 1:1 id using `rc', assert(1 3) nogen
		/*THE INITIAL ALSO FOLLOWS THE FALLBACK (EXPECTED EMPTY; COUNTED).    */
		quietly count if sf & mi_rc!=""
		local nmi = `nmi' + r(N)
		quietly count if (sf & f_ans_cleaned!=f_ans) | (sl & l_ans_cleaned!=l_ans)
		local nrc = `nrc' + r(N)
		replace f_name = f_ans_cleaned if sf
		replace mi_true_cleaned = mi_rc if sf
		replace l_name = l_ans_cleaned if sl
		drop f_ans_cleaned l_ans_cleaned mi_rc
	}
	replace name_true_cleaned_exists = 0 if sf & sl
	assert f_name!="invalidpred" & l_name!="invalidpred"
	local tot = `tot' + _N

	keep id name_true_cleaned_exists age mi_true_cleaned f_name l_name
	order id name_true_cleaned_exists age mi_true_cleaned f_name l_name
	save `"`dst'/`f'"', replace
}
display "1940: " `: word count `fG'' " files, `tot' records; sentinel replaced by Ancestry: first name `nf', surname `nl', both `nboth'"
display "CHECK: `nbad' of `nchk' records without model names differ from _ans_cleaned"
display "sentinel records where the fallback's abeclean pass differs from a plain copy of _ans_cleaned: `nrc'"
display "sentinel first names whose fallback initial is non-empty: `nmi'"
/*SAME TEST AS 1c, ON TARGET RECORDS ONLY (1c SET THE OTHERS TO ANCESTRY). */
/*1c FOUND 436 SUCH RECORDS OVER ALL RECORDS (tgt_fallback_diag.do), SO   */
/*THE TARGET SUBSET CANNOT EXCEED 436 UNLESS SOMETHING ELSE CHANGED        */
/*(2026-11-22 REVIEW: A 0.1% TOLERANCE ON THE SMALLER DENOMINATOR COULD    */
/*STOP A CORRECT RUN). TESTED AFTER THE LOOP: A FAILURE LEAVES THE OUTPUT  */
/*FOLDER BEHIND, TO BE MOVED ASIDE BEFORE A RERUN.                         */
if `nbad'>0 {
	display as error "NOTE: `nbad' records without model names differ from _ans_cleaned"
	if `nbad' > 436 exit 459
}
