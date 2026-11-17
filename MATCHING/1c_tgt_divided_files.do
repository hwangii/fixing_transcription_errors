/*TARGET-ONLY ML DIVIDED FILES FOR 1940 (2026-11-17).                        */
/*                                                                           */
/*The paper's "New" links (link1930_1940_true_cleaned_noraceblock0.dta) use  */
/*the model's names for every 1940 record that has them. The slides say we   */
/*replace names only on target records. This builds the 1940 divided files   */
/*for that claim, divided_file1940_tgt_cleaned, one file per birthplace:     */
/*  target record (Ancestry and FamilySearch names not both identical, as   */
/*      in fs_avg_performance.do): the record from                           */
/*      divided_file1940_true_cleaned (model names, Ancestry's where the     */
/*      model gave none)                                                     */
/*  any other record: the record from divided_file1940_ans_cleaned (Ancestry)*/
/*Variables are those of the _true_cleaned files (id f_name l_name age       */
/*mi_true_cleaned name_true_cleaned_exists), so the matcher and the append   */
/*treat _tgt_cleaned exactly as _true_cleaned. Records and birthplace files  */
/*are those of both sources, which must agree (asserted).                    */
/*                                                                           */
/*Target flag by histid from census1940_all_labeled_data.dta, the paper's   */
/*definition (section 1). A divided-file record not in that file is not a  */
/*target and keeps Ancestry's names.                                         */
/*                                                                           */
/*CHECK: in _true_cleaned, a record with name_true_cleaned_exists==0 took    */
/*Ancestry's names, so its f_name and l_name must equal _ans_cleaned's. If   */
/*they do, the two sources are cleaned the same way and mixing them is fair. */

if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local f_intermediate "$REP_F/enum_date/DATA/INTERMEDIATE/"

local srcT `"`f_intermediate'divided_file1940_true_cleaned"'
local srcA `"`f_intermediate'divided_file1940_ans_cleaned"'
local dst  `"`f_intermediate'divided_file1940_tgt_cleaned"'
local flags `"`f_intermediate'tgt_flag1940.dta"'
/*NEVER REUSE OR OVERWRITE: dst AND THE FLAG FILE MUST NOT EXIST YET.*/
mata: st_local("dex", strofreal(direxists(st_local("dst"))))
if `dex' {
	display as error "`dst' exists; move it aside first"
	exit 602
}
capture confirm file `"`flags'"'
if !_rc {
	display as error "`flags' exists; move it aside first"
	exit 602
}

/*=========================================================*/
/*1. TARGET FLAG BY histid                                 */
/*=========================================================*/
/*THE PAPER'S TARGET, EXACTLY AS fs_avg_performance.do AND                 */
/*create_figures_SSHA2025.do: ANCESTRY AND FAMILYSEARCH NAMES NOT BOTH      */
/*IDENTICAL, FROM census1940_all_labeled_data.dta (2026-11-17 REVIEW: AN    */
/*EARLIER DRAFT USED fs_cells.do's HUMAN-COMPLETE SUBSET).                  */
local original "$REP_SNU/fixing_transcription_errors/DATA/ORIGINAL"
use namefrst namelast namefrst_fs namelast_fs histid using `"`original'/census1940_all_labeled_data.dta"', clear
isid histid
gen byte tgt = !(namefrst==namefrst_fs & namelast==namelast_fs)
keep histid tgt
quietly count if tgt
display "target histids: " r(N) " of " _N
/*SPEED (2026-11-17): THE FILE IS MERGED ONCE PER BIRTHPLACE FILE (139    */
/*TIMES). KEEPING ONLY TARGET ids MAKES IT ABOUT A THIRD THE SIZE; A       */
/*RECORD NOT IN IT IS NOT A TARGET, WHICH IS WHAT SECTION 2 ALREADY DOES    */
/*WITH UNMATCHED RECORDS. nnomatch BELOW THEN COUNTS NON-TARGETS TOO, SO    */
/*IT IS NO LONGER REPORTED.                                                */
keep if tgt
rename histid id
save `"`flags'"', replace

/*=========================================================*/
/*2. DIVIDED FILES                                         */
/*=========================================================*/
capture mkdir `"`dst'"'
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
local nchk 0
local nbad 0
foreach f of local fT {
	use id f_name l_name mi using `"`srcA'/`f'"', clear
	isid id
	rename (f_name l_name mi) (f_ans l_ans mi_ans)
	save `ans', replace

	use `"`srcT'/`f'"', clear
	isid id
	local n0 = _N
	merge 1:1 id using `ans', assert(3) nogen
	merge 1:1 id using `"`flags'"', keep(1 3) keepusing(tgt)
	replace tgt = 0 if _merge==1
	drop _merge
	assert _N==`n0'

	/*CHECK: ANCESTRY FALLBACK IN _true_cleaned EQUALS _ans_cleaned*/
	quietly count if name_true_cleaned_exists==0
	local nchk = `nchk' + r(N)
	quietly count if name_true_cleaned_exists==0 & !(f_name==f_ans & l_name==l_ans)
	local nbad = `nbad' + r(N)

	replace f_name = f_ans  if !tgt
	replace l_name = l_ans  if !tgt
	replace mi_true_cleaned = mi_ans if !tgt
	replace name_true_cleaned_exists = 0 if !tgt

	quietly count if tgt
	local ntgt = `ntgt' + r(N)
	quietly count if tgt & name_true_cleaned_exists==1
	local ntgtml = `ntgtml' + r(N)
	local tot = `tot' + _N

	keep id name_true_cleaned_exists age mi_true_cleaned f_name l_name
	order id name_true_cleaned_exists age mi_true_cleaned f_name l_name
	save `"`dst'/`f'"', replace
}
display "1940: " `: word count `fT'' " files, `tot' records, `ntgt' target records, of which `ntgtml' have model names (the rest keep Ancestry's)"
display "CHECK: `nbad' of `nchk' records without model names differ from _ans_cleaned"
/*2026-11-17: REPORTED, NOT A STOP (AUTHOR'S DECISION). THE FIRST RUN FOUND */
/*436 OF 1,031,654; TO BE RECONCILED LATER (tgt_fallback_diag.do). A NON-   */
/*TARGET RECORD TAKES _ans_cleaned'S NAME EITHER WAY; ONLY THE all-RECORDS  */
/*BASELINE (_true_cleaned) CARRIES THE OTHER VERSION. A LARGER COUNT THAN   */
/*0.1% STILL STOPS, AS A SIGN SOMETHING ELSE IS WRONG.                      */
if `nbad'>0 {
	display as error "NOTE: the Ancestry fallback in _true_cleaned differs from _ans_cleaned on `nbad' records"
	if `nbad' > 0.001*`nchk' exit 459
}
