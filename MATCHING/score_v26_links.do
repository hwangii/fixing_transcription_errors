/*SCORE THE v26 ABE EXACT LINKS (2026-11-25). READ-ONLY EXCEPT FOR          */
/*MATCHING/results/v26_linkage_abe.md. Adapted from score_tgt_links.do.     */
/*                                                                           */
/*_v26_run.do linked 1930-1940 men on the inputs 1f_v26_inputs.do rebuilt    */
/*from the 00655/00656 raw names with abeclean 0.26 (no "marshall" defect;   */
/*identical to the MLP's men, check_v26_same_input in _v26_run.log):         */
/*  v26     link1930_1940_v26_cleaned_noraceblock0.dta         Old           */
/*  v26ml   link1930_1940_v26_ml1940_cleaned_noraceblock0.dta  New           */
/*  v26tgt  link1930_1940_v26_mltgt1940_cleaned_noraceblock0.dta Target-only */
/*scored beside the paper's two (ans = Old, true = New), which must still     */
/*reproduce the main table (a check on this code; exit 9 otherwise).         */
/*DEFINITIONS AS score_tgt_links.do / linkage_analysis.do: SAME SAMPLE        */
/*(linkage_sample1940.dta: denominator and target flag), SAME TRUTH, links   */
/*fiveyr_band==1 deduplicated. Share validated: 1930 and 1940 middle         */
/*initials, each version's own on both sides: paper's columns as before;     */
/*v26 columns from the v26 divided files (1930 mi; 1940 mi for v26,         */
/*mi_true_cleaned for v26ml/v26tgt). The Ancestry-MI rows use the paper's    */
/*Ancestry initials (sample mi_anc, 1930 divided_file1930_ans_cleaned) for   */
/*every column as a fixed yardstick.                                         */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"

local links "$REP_SNU/enum_date/DATA/INTERMEDIATE"
local div   "$REP_F/enum_date/DATA/INTERMEDIATE"
local true_links "$REP_F/fixing_transcription_errors/DATA/INTERMEDIATE/mlp_training1930_1940.dta"
local sample_f   "$REP_SNU/fixing_transcription_errors/DATA/INTERMEDIATE/linkage_sample1940.dta"
local md "$REP_REPO/MATCHING/results/v26_linkage_abe.md"

local f_ans   "`links'/link1930_1940_ans_cleaned_noraceblock0.dta"
local f_true  "`links'/link1930_1940_true_cleaned_noraceblock0.dta"
local f_v26    "`links'/link1930_1940_v26_cleaned_noraceblock0.dta"
local f_v26ml  "`links'/link1930_1940_v26_ml1940_cleaned_noraceblock0.dta"
local f_v26tgt "`links'/link1930_1940_v26_mltgt1940_cleaned_noraceblock0.dta"
local combos ans true v26 v26ml v26tgt

/*THE MAIN TABLE'S VALUES, AS IN linkage_analysis.do (full = all, restr = target).*/
local p_n_full  51036859
local p_n_restr 14416543
local p_lr_restr_ans  8.88273284378925
local p_lr_restr_true 19.4149041139752
local p_lr_full_ans   22.8142938812124
local p_lr_full_true  24.6009379221398
local p_nv_restr_ans  308513
local p_nv_restr_true 618732
local p_nv_full_ans   2512418
local p_nv_full_true  2665324
local p_sv_restr_ans  65.4053475866495
local p_sv_restr_true 83.5985531700316
local p_sv_full_ans   85.9879207998032
local p_sv_full_true  87.137473718017
/*TRUTH-BASED ROWS, AS PRINTED IN THE SLIDE TABLES (paper repo              */
/*figures/deaglan_abe_jw.tex AND _restricted.tex, ABE Old/New COLUMNS;      */
/*2026-11-17 REVIEW: THE GATE CHECKED NO TRUTH-BASED ROW). RECALL TO 2 dp.  */
local p_ver_full_ans   5930641
local p_unv_full_ans   5394195
local p_con_full_ans   318863
local p_ver_full_true  6415946
local p_unv_full_true  5848625
local p_con_full_true  290975
local p_ver_restr_ans  523091
local p_unv_restr_ans  692355
local p_con_restr_ans  65137
local p_ver_restr_true 1319555
local p_unv_restr_true 1407741
local p_con_restr_true 71662
local p_recall_full_ans   31.69
local p_recall_full_true  34.28
local p_recall_restr_ans  11.13
local p_recall_restr_true 28.07

/*============================================================*/
/*PART 0: SAMPLE, INITIALS, TRUTH, PAIRS                      */
/*============================================================*/
/*1940 INITIALS OF THE v26 INPUTS, PER VERSION.                            */
foreach t in ans true tgt {
	clear
	local files : dir `"`div'/divided_file1940_v26_`t'_cleaned"' files "norace*.dta"
	if `"`files'"'=="" {
		display as error "no files in divided_file1940_v26_`t'_cleaned"
		exit 601
	}
	local m = cond("`t'"=="ans", "mi", "mi_true_cleaned")
	foreach f of local files {
		append using `"`div'/divided_file1940_v26_`t'_cleaned/`f'"', keep(id `m')
	}
	rename (id `m') (histid mi26_`t')
	isid histid
	tempfile mi26_`t'
	save `mi26_`t''
}

use histid target mi_anc mi_ml using `"`sample_f'"', clear
isid histid
foreach t in ans true tgt {
	merge 1:1 histid using `mi26_`t'', keep(1 3)
	quietly count if _merge==1
	display "sample men missing from v26 `t' inputs: " r(N)
	drop _merge
}
gen mi_v_ans    = mi_anc
gen mi_v_true   = mi_ml
gen mi_v_v26    = mi26_ans
gen mi_v_v26ml  = mi26_true
gen mi_v_v26tgt = mi26_tgt
/*REPORTED: v26tgt's initial is v26ml's on target records, v26's elsewhere  */
/*(the v26 target flag is tgt_flag1940; this uses the sample's).            */
quietly count if target==1 & mi26_tgt!=mi26_true
display "sample target records whose v26tgt initial differs from v26ml's: " r(N)
quietly count if target==0 & mi26_tgt!=mi26_ans
display "sample non-target records whose v26tgt initial differs from v26's: " r(N)
quietly count if mi26_ans!=mi_anc
display "sample records whose v26 Ancestry initial differs from the paper's: " r(N)
keep histid target mi_v_* mi_anc
tempfile cn1940_full
save `cn1940_full'
scalar N_full = _N
keep if target==1
scalar N_restr = _N
tempfile cn1940_restr
save `cn1940_restr'
use `cn1940_full', clear
keep if target==0
scalar N_non = _N
tempfile cn1940_non
save `cn1940_non'
foreach s in full restr non {
	use histid using `cn1940_`s'', clear
	tempfile den_`s'
	save `den_`s''
}

/*1930 INITIALS: ANCESTRY DIVIDED FILES.*/
clear
local files : dir `"`div'/divided_file1930_ans_cleaned"' files "norace*.dta"
foreach f of local files {
	append using `"`div'/divided_file1930_ans_cleaned/`f'"', keep(id mi)
}
rename (id mi) (histid mi1930_p)
isid histid
tempfile cn1930p
save `cn1930p'
clear
local files : dir `"`div'/divided_file1930_v26_ans_cleaned"' files "norace*.dta"
foreach f of local files {
	append using `"`div'/divided_file1930_v26_ans_cleaned/`f'"', keep(id mi)
}
rename (id mi) (histid mi1930_v26)
isid histid
merge 1:1 histid using `cn1930p', nogenerate
tempfile cn1930
save `cn1930'

/*TRUTH, AS IN linkage_analysis.do PART 0.*/
use `true_links', clear
keep histid1930 histid1940
duplicates drop histid1930 histid1940, force
display "truth pairs: " _N " (expected 36,690,338)"
assert _N==36690338
isid histid1930
isid histid1940
tempfile truth_all
save `truth_all'
rename histid1940 true_histid1940
tempfile true_by1930
save `true_by1930'
foreach s in full restr non {
	use `truth_all', clear
	rename histid1940 histid
	merge m:1 histid using `den_`s'', keep(3) nogenerate
	rename histid histid1940
	tempfile true_pairs_`s'
	save `true_pairs_`s''
}
use `true_pairs_full', clear
rename histid1930 true_histid1930
tempfile true_by1940
save `true_by1940'

foreach c of local combos {
	use id_A id_B fiveyr_band using `"`f_`c''"', clear
	keep if fiveyr_band == 1
	rename (id_A id_B) (histid1930 histid1940)
	keep histid1930 histid1940
	duplicates drop histid1930 histid1940, force
	tempfile pairs_`c'
	save `pairs_`c''
}

/*============================================================*/
/*PART 1: SCORES                                              */
/*============================================================*/
foreach s in full restr non {
	foreach c of local combos {
		use `pairs_`c'', clear
		rename histid1940 histid
		merge m:1 histid using `den_`s'', keep(3) nogenerate
		rename histid histid1940
		scalar L_`s'_`c' = _N
		scalar rate_`s'_`c' = L_`s'_`c' / N_`s'

		merge m:1 histid1940 using `true_by1940', keep(1 3) gen(person_merge)
		merge m:1 histid1930 using `true_by1930', keep(1 3) gen(merge30)
		quietly count if person_merge == 1 & merge30 == 1
		scalar unv_`s'_`c' = r(N)
		quietly count if person_merge == 3 & histid1930 == true_histid1930
		scalar ver_`s'_`c' = r(N)
		quietly count if (person_merge == 3 & histid1930 != true_histid1930) | (person_merge == 1 & merge30 == 3)
		scalar con_`s'_`c' = r(N)
		assert unv_`s'_`c' + ver_`s'_`c' + con_`s'_`c' == _N
		drop merge30 true_histid1940 person_merge true_histid1930

		preserve
			merge 1:1 histid1930 histid1940 using `true_pairs_`s'', keep(1 2 3) gen(pair_merge)
			quietly count if pair_merge == 2
			scalar FN_`s'_`c' = r(N)
		restore
		scalar recall_`s'_`c' = ver_`s'_`c' / (ver_`s'_`c' + FN_`s'_`c')

		rename histid1930 histid
		merge m:1 histid using `cn1930', keep(1 3) nogenerate
		rename histid histid1930
		/*OWN 1930 INITIAL; THE ANCESTRY-MI YARDSTICK USES THE PAPER'S.       */
		if inlist("`c'","ans","true") gen mi1930 = mi1930_p
		else gen mi1930 = mi1930_v26
		rename histid1940 histid
		preserve
		merge m:1 histid using `cn1940_`s'', keep(1 3) nogenerate keepusing(mi_v_`c')
		rename mi_v_`c' mi1940
		keep if mi1930 != "" & mi1940 != ""
		scalar nv_`s'_`c' = _N
		quietly count if mi1930 == mi1940
		scalar sv_`s'_`c' = r(N) / nv_`s'_`c'
		restore
		/*SAME, WITH ANCESTRY'S 1940 INITIAL FOR EVERY VERSION (2026-11-17   */
		/*REVIEW): A FIXED YARDSTICK, SO ONLY THE LINKS DIFFER.               */
		merge m:1 histid using `cn1940_`s'', keep(1 3) nogenerate keepusing(mi_anc)
		keep if mi1930_p != "" & mi_anc != ""
		scalar nva_`s'_`c' = _N
		quietly count if mi1930_p == mi_anc
		scalar sva_`s'_`c' = r(N) / nva_`s'_`c'

		display "`s' `c': links=" L_`s'_`c' " rate=" %7.4f 100*rate_`s'_`c' ///
			" V=" ver_`s'_`c' " U=" unv_`s'_`c' " C=" con_`s'_`c' ///
			" recall=" %6.3f 100*recall_`s'_`c' " MIlinks=" nv_`s'_`c' " SV=" %7.4f 100*sv_`s'_`c'
	}
}

/*============================================================*/
/*CHECK: ans AND true REPRODUCE THE MAIN TABLE                */
/*============================================================*/
local bad 0
foreach s in full restr {
	if N_`s' != `p_n_`s'' {
		display as error "`s' denominator: " N_`s' ", main table `p_n_`s''"
		local bad 1
	}
	foreach c in ans true {
		if nv_`s'_`c' != `p_nv_`s'_`c'' {
			display as error "`s' `c' links with both initials: " nv_`s'_`c' ", main table `p_nv_`s'_`c''"
			local bad 1
		}
		if abs(100*rate_`s'_`c' - `p_lr_`s'_`c'') > 1e-9 {
			display as error "`s' `c' linkage rate: " %18.0g 100*rate_`s'_`c' ", main table `p_lr_`s'_`c''"
			local bad 1
		}
		if abs(100*sv_`s'_`c' - `p_sv_`s'_`c'') > 1e-9 {
			display as error "`s' `c' share validated: " %18.0g 100*sv_`s'_`c' ", main table `p_sv_`s'_`c''"
			local bad 1
		}
		foreach k in ver unv con {
			if `k'_`s'_`c' != `p_`k'_`s'_`c'' {
				display as error "`s' `c' `k': " `k'_`s'_`c' ", slide table `p_`k'_`s'_`c''"
				local bad 1
			}
		}
		if abs(round(100*recall_`s'_`c', .01) - `p_recall_`s'_`c'') > .001 {
			display as error "`s' `c' recall: " %6.2f 100*recall_`s'_`c' ", slide table `p_recall_`s'_`c''"
			local bad 1
		}
	}
}
if `bad' {
	display as error "CHECK FAILED: ans/true do not reproduce the main table; nothing written"
	exit 9
}
display "CHECK PASSED: ans and true reproduce the main table"
assert N_restr + N_non == N_full

/*============================================================*/
/*OUTPUT                                                      */
/*============================================================*/
file open md using `"`md'"', write replace text
file write md "# ABE exact on the v26 inputs, 1930-1940 men" _n _n
file write md "Written by MATCHING/score_v26_links.do (definitions of LINKAGE/code/01_abe_jw/linkage_analysis.do; the paper's Old and New columns are checked against the main table)." _n _n
file write md "Columns: **Old (paper)** and **New (paper)** = the paper's files, on names whose stored cleaning carried the pre-0.25 abeclean 'marshall' defect, from the men-only extracts. **Old (v26)**, **New (v26)**, **Target-only (v26)** = rebuilt from the 00655/00656 raw names with abeclean 0.26 (1f_v26_inputs.do), the same men and names as the MLP input; New (v26) has model names on every 1940 record with a per-field Ancestry fallback where the model field is empty, Target-only (v26) the same on target records only and Ancestry's elsewhere; 'InvalidPred' is blanked before the fallback. Same sample, denominators and truth as the paper." _n _n
file write md "Share validated uses each version's own 1930 and 1940 middle initials; the Ancestry-MI rows use the paper's Ancestry initials for every column. Verified/contradicted are against the FamilySearch-profile sample and cover only links it reaches." _n _n
foreach s in full restr non {
	if "`s'"=="full"  file write md _n "## All records (N = " %12.0fc (N_full) ")" _n _n
	if "`s'"=="restr" file write md _n "## Target records (N = " %12.0fc (N_restr) ")" _n _n
	if "`s'"=="non"   file write md _n "## Non-target records (N = " %12.0fc (N_non) ")" _n _n
	file write md "| | Old (paper) | New (paper) | Old (v26) | New (v26) | Target-only (v26) |" _n "|---|---:|---:|---:|---:|---:|" _n
	foreach r in L rate sv nv sva nva ver unv con cshare recall {
		if "`r'"=="L"      local lab "Links"
		if "`r'"=="rate"   local lab "Match rate (%)"
		if "`r'"=="sv"     local lab "Share validated, MI (%)"
		if "`r'"=="nv"     local lab "Links with both initials"
		if "`r'"=="sva"    local lab "Share validated, Ancestry 1940 MI (%)"
		if "`r'"=="nva"    local lab "Links with both initials, Ancestry 1940 MI"
		if "`r'"=="ver"    local lab "Verified correct"
		if "`r'"=="unv"    local lab "Unverifiable"
		if "`r'"=="con"    local lab "Directly contradicted"
		if "`r'"=="cshare" local lab "Contradicted / (verified + contradicted) (%)"
		if "`r'"=="recall" local lab "Recall (%)"
		file write md "| `lab'"
		foreach c of local combos {
			if inlist("`r'","L","nv","nva","ver","unv","con") local v : di %13.0fc `r'_`s'_`c'
			if inlist("`r'","rate","sv","sva","recall")        local v : di %6.2f 100*`r'_`s'_`c'
			if "`r'"=="cshare" local v : di %6.2f 100*con_`s'_`c'/(ver_`s'_`c'+con_`s'_`c')
			file write md " | `=strtrim("`v'")'"
		}
		file write md " |" _n
	}
}
file close md
display "wrote `md'"
