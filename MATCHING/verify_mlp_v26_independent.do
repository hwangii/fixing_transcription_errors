/*INDEPENDENT CHECK OF THE FILES FOR IPUMS (2026-11-27). MACHINE A. READ ONLY.*/
/*Rebuilds, for three birthplaces (1930 and 1940), every column of           */
/*for_mlp1930_v26_combined.dta and for_mlp1940_v26_combined.dta from the raw sources */
/*with logic written afresh (not copied from 1f_v26_inputs.do / 1h), and     */
/*compares them cell by cell. Any difference: exit 9. Also tabulates, on the */
/*same records, how the combined file differs from the file IPUMS linked     */
/*before (for_mlp_original/for_mlp1940.dta).                                 */
/*Rules re-implemented (the specification, 1f header):                       */
/*  Ancestry = abeclean(raw Ancestry first, last), sex(sex) initial nickname */
/*  nonysiis. Model row: state merged_data, "InvalidPred" (any case, trimmed)*/
/*  blanked; (filename,row) keys whose rows disagree dropped; kept if a name */
/*  is non-empty and parsing_quality non-missing; a census (filename,row)    */
/*  occurring twice in a birthplace file gets no model row. Exists = has a   */
/*  model row. Empty model field -> raw Ancestry field, then abeclean; a     */
/*  model field cleaned to "" -> Ancestry's cleaned field (first name: with  */
/*  Ancestry's initial). Target-only = model columns if tgt, else Ancestry   */
/*  with exists 0.                                                           */
/*                                                                           */
/*  powershell -File replication/Run-Stata.ps1 MATCHING/verify_mlp_v26_independent.do */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
which abeclean
local fi "$REP_F/enum_date/DATA/INTERMEDIATE/"
local root "$REP_SNU/fixing_transcription_errors/DATA/TRANSCRIPTIONS/USCensus1940FullCount/output_and_output1_ssha2025"
local bpls 1 46 435
local bad 0

/*---------------- MODEL ROWS -------------------------------------------- */
local states al ar az ca co ct dc de fl ga hi ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy
/*ONLY THE KEYS THE SAMPLE NEEDS: KEEPS MEMORY SMALL.                       */
clear
foreach b of local bpls {
	append using `"`fi'divided_file1940_women_added/norace`b'.dta"', keep(filename row)
}
replace filename = filename + ".jpg"
duplicates drop
tempfile keys
save `keys'
clear
foreach s of local states {
	preserve
	use filename row namefrst_ml namelast_ml_ditto parsing_quality using `"`root'/`s'/merged_data.dta"', clear
	merge m:1 filename row using `keys', keep(3) nogenerate
	tempfile p`s'
	save `p`s''
	restore
	append using `p`s''
}
foreach v in namefrst_ml namelast_ml_ditto {
	replace `v' = "" if lower(strtrim(`v'))=="invalidpred"
}
duplicates drop
duplicates tag filename row, gen(conflict)
drop if conflict
drop conflict
drop if namefrst_ml=="" & namelast_ml_ditto==""
drop if missing(parsing_quality)
drop parsing_quality
isid filename row
tempfile model
save `model'

/*---------------- 1940 -------------------------------------------------- */
use `"`fi'for_mlp1940_v26_combined.dta"' if inlist(bpl, 1, 46, 435), clear
foreach v of varlist _all {
	if "`v'"!="histid" rename `v' C_`v'
}
tempfile comb
save `comb'
use `"`fi'for_mlp_original/for_mlp1940.dta"' if inlist(bpl, 1, 46, 435), clear
foreach v of varlist _all {
	if "`v'"!="histid" rename `v' O_`v'
}
tempfile orig
save `orig'

clear
foreach b of local bpls {
	preserve
	use histid sex age namefrst_ans namelast_ans filename row using `"`fi'divided_file1940_women_added/norace`b'.dta"', clear
	gen int bpl = `b'
	tempfile r`b'
	save `r`b''
	restore
	append using `r`b''
}
isid histid
local N40 = _N
replace filename = filename + ".jpg"
abeclean namefrst_ans namelast_ans, sex(sex) initial(mi) nickname nonysiis
rename (namefrst_ans_cleaned namelast_ans_cleaned) (namefrst namelast)
/*CENSUS KEY DUPLICATES ARE JUDGED WITHIN A BIRTHPLACE FILE.               */
duplicates tag bpl filename row, gen(cdup)
merge m:1 filename row using `model', keep(1 3)
gen byte exists = _merge==3 & cdup==0
drop _merge
gen mf = cond(exists, namefrst_ml, "")
gen ml = cond(exists, namelast_ml_ditto, "")
replace mf = namefrst_ans if mf==""
replace ml = namelast_ans if ml==""
abeclean mf ml, sex(sex) initial(mi_m) nickname nonysiis
replace mi_m = mi if mf_cleaned=="" & namefrst!=""
replace mf_cleaned = namefrst if mf_cleaned==""
replace ml_cleaned = namelast if ml_cleaned==""
rename histid id
merge 1:1 id using `"`fi'tgt_flag1940.dta"', keep(1 3) keepusing(tgt)
replace tgt = 0 if _merge==1
drop _merge
rename id histid

merge 1:1 histid using `comb', assert(3) nogenerate
local ck  age sex bpl namefrst namelast mi
foreach v of local ck {
	quietly count if `v' != C_`v'
	display "1940 `v' differs: " r(N)
	local bad = `bad' + r(N)
}
local nn f mf_cleaned namefrst_true_cleaned
local nn `nn' l ml_cleaned namelast_true_cleaned
local nn `nn' i mi_m mi_true_cleaned
local nn `nn' e exists name_true_cleaned_exists
while "`nn'"!="" {
	gettoken k nn : nn
	gettoken a nn : nn
	gettoken c nn : nn
	quietly count if `a' != C_`c'
	display "1940 New `c' differs: " r(N)
	local bad = `bad' + r(N)
	local t = subinstr("`c'","true","tgt",1)
	local o = cond("`k'"=="f","namefrst",cond("`k'"=="l","namelast",cond("`k'"=="i","mi","0")))
	quietly count if cond(tgt, `a', `o') != C_`t'
	display "1940 Target-only `t' differs: " r(N)
	local bad = `bad' + r(N)
}
quietly count
display "1940 records checked: " r(N) " (rebuilt `N40'); target " _continue
quietly count if tgt
display r(N) "; with model row " _continue
quietly count if exists
display r(N)

/*HOW THE COMBINED FILE DIFFERS FROM WHAT IPUMS LINKED BEFORE.             */
merge 1:1 histid using `orig'
/*_merge 2: IN THE ORIGINAL'S SAMPLE BIRTHPLACES BUT NOT IN v26'S (E.G. A    */
/*DIFFERENT bpl IN THE 00656 EXTRACT).                                      */
tab _merge
keep if _merge==3
foreach p in "namefrst namefrst" "namelast namelast" "mi mi" "namefrst_true_cleaned namefrst_true_cleaned" "namelast_true_cleaned namelast_true_cleaned" "mi_true_cleaned mi_true_cleaned" "name_true_cleaned_exists name_true_cleaned_exists" "age age" "sex sex" {
	tokenize `p'
	quietly count if C_`1' != O_`2'
	display "vs original: `1' differs on " r(N)
}
quietly count if C_namefrst!=O_namefrst & C_namefrst=="marshall"
display "vs original: Ancestry first name differs and v26 is marshall: " r(N)
quietly count if C_namefrst!=O_namefrst & O_namefrst=="marshall"
display "vs original: Ancestry first name differs and original is marshall: " r(N)
gen d = C_namefrst != O_namefrst
gen long seq = sum(d)
list histid O_namefrst C_namefrst if d & seq<=50, clean noobs
drop seq

/*---------------- 1930 -------------------------------------------------- */
use `"`fi'for_mlp1930_v26_combined.dta"' if inlist(bpl, 1, 46, 435), clear
foreach v of varlist _all {
	if "`v'"!="histid" rename `v' C_`v'
}
save `comb', replace
clear
foreach b of local bpls {
	preserve
	use histid sex age namefrst_ans namelast_ans using `"`fi'divided_file1930_women_added/norace`b'.dta"', clear
	gen int bpl = `b'
	save `r`b'', replace
	restore
	append using `r`b''
}
isid histid
abeclean namefrst_ans namelast_ans, sex(sex) initial(mi) nickname nonysiis
rename (namefrst_ans_cleaned namelast_ans_cleaned) (namefrst namelast)
merge 1:1 histid using `comb', assert(3) nogenerate
foreach v in age sex bpl namefrst namelast mi {
	quietly count if `v' != C_`v'
	display "1930 `v' differs: " r(N)
	local bad = `bad' + r(N)
}
foreach t in true tgt {
	foreach v in namefrst namelast mi {
		quietly count if `v' != C_`v'_`t'_cleaned
		display "1930 `v'_`t'_cleaned differs: " r(N)
		local bad = `bad' + r(N)
	}
}
display "1930 records checked: " _N

display "TOTAL DIFFERENCES: `bad'"
if `bad' {
	display as error "INDEPENDENT CHECK FAILED"
	exit 9
}
display "INDEPENDENT CHECK PASSED"
