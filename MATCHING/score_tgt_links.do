/*SCORE THE TARGET-ONLY ABE LINKS (2026-11-17). READ-ONLY EXCEPT FOR         */
/*MATCHING/results/tgt_linkage_abe.md.                                        */
/*                                                                           */
/*_tgt_only_run.do wrote two 1930-1940 ABE link files on machine A:          */
/*  mltgt  link1930_1940_mltgt1940_cleaned_noraceblock0.dta: model names on  */
/*         1940 target records only, Ancestry's elsewhere                    */
/*  ml     link1930_1940_ml1940_cleaned_noraceblock0.dta: model names on     */
/*         every 1940 record, rerun through the same code the same day       */
/*2026-11-22: _tgtns_run.do adds                                            */
/*  mltgtns link1930_1940_mltgtns1940_cleaned_noraceblock0.dta: as mltgt,    */
/*         with the "InvalidPred" sentinel replaced by Ancestry's field      */
/*         (1e_tgtns_divided_files.do)                                       */
/*They are scored here beside the paper's two:                               */
/*  ans    link1930_1940_ans_cleaned_noraceblock0.dta  (the paper's "Old")   */
/*  true   link1930_1940_true_cleaned_noraceblock0.dta (the paper's "New")   */
/*                                                                           */
/*DEFINITIONS: THOSE OF LINKAGE/code/01_abe_jw/linkage_analysis.do (machine  */
/*B, the slide tables), line for line where it can:                          */
/*  - sample: linkage_sample1940.dta (1940 men 10+ with both transcriptions);*/
/*    target = Ancestry and FamilySearch disagree; non-target = the rest     */
/*  - links: fiveyr_band==1, pairs deduplicated, 1940 person in the sample   */
/*  - truth: mlp_training1930_1940.dta, two-sided Verified / Unverifiable /  */
/*    Directly Contradicted; recall                                           */
/*  - share validated: 1930 and 1940 middle initials agree, among links where */
/*    both exist; 1930 Ancestry's, 1940 each version's own: Ancestry's (ans), */
/*    ours (true, ml), and for mltgt the initial the matcher used            */
/*    (divided_file1940_tgt_cleaned: ours on target records, Ancestry's      */
/*    elsewhere)                                                             */
/*CHECK: ans AND true MUST REPRODUCE THE MAIN TABLE (THE VALUES                */
/*linkage_analysis.do CHECKS AGAINST); IT STOPS OTHERWISE. ml IS ALSO        */
/*COMPARED PAIR BY PAIR WITH true (REPORTED, NOT A STOP).                    */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"

local links "$REP_SNU/enum_date/DATA/INTERMEDIATE"
local div   "$REP_F/enum_date/DATA/INTERMEDIATE"
local true_links "$REP_F/fixing_transcription_errors/DATA/INTERMEDIATE/mlp_training1930_1940.dta"
local sample_f   "$REP_SNU/fixing_transcription_errors/DATA/INTERMEDIATE/linkage_sample1940.dta"
local md "$REP_REPO/MATCHING/results/tgt_linkage_abe.md"

local f_ans   "`links'/link1930_1940_ans_cleaned_noraceblock0.dta"
local f_true  "`links'/link1930_1940_true_cleaned_noraceblock0.dta"
local f_ml    "`links'/link1930_1940_ml1940_cleaned_noraceblock0.dta"
local f_mltgt "`links'/link1930_1940_mltgt1940_cleaned_noraceblock0.dta"
local f_mltgtns "`links'/link1930_1940_mltgtns1940_cleaned_noraceblock0.dta"
local combos ans true ml mltgt mltgtns

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
/*1940 INITIAL THE TARGET-ONLY MATCHER USED.*/
clear
local files : dir `"`div'/divided_file1940_tgt_cleaned"' files "norace*.dta"
foreach f of local files {
	append using `"`div'/divided_file1940_tgt_cleaned/`f'"', keep(id mi_true_cleaned)
}
rename (id mi_true_cleaned) (histid mi_tgt)
isid histid
tempfile mi_tgt
save `mi_tgt'
/*AND THE ONE THE SENTINEL-FREE MATCHER USED.*/
clear
local files : dir `"`div'/divided_file1940_tgtns_cleaned"' files "norace*.dta"
foreach f of local files {
	append using `"`div'/divided_file1940_tgtns_cleaned/`f'"', keep(id mi_true_cleaned)
}
rename (id mi_true_cleaned) (histid mi_tgtns)
isid histid
tempfile mi_tgtns
save `mi_tgtns'

use histid target mi_anc mi_ml using `"`sample_f'"', clear
isid histid
merge 1:1 histid using `mi_tgt', keep(1 3) nogen
merge 1:1 histid using `mi_tgtns', keep(1 3) nogen
/*THE FOUR VERSIONS' 1940 INITIALS, NAMED BY VERSION.*/
gen mi_v_ans  = mi_anc
gen mi_v_true = mi_ml
gen mi_v_ml   = mi_ml
gen mi_v_mltgt = mi_tgt
gen mi_v_mltgtns = mi_tgtns
/*SANITY: mltgt's initial is ours on target records, Ancestry's elsewhere.*/
quietly count if target==1 & mi_tgt!=mi_ml
display "target records whose mltgt initial differs from ours: " r(N)
assert r(N)==0
quietly count if target==0 & mi_tgt!=mi_anc
display "non-target records whose mltgt initial differs from Ancestry's: " r(N)
assert r(N)==0
/*SANITY: THE SENTINEL FIX CAN CHANGE AN INITIAL ONLY WHERE mltgt'S WAS   */
/*EMPTY (A SENTINEL FIRST NAME; 1e_tgtns_divided_files.do EXPECTS NONE).   */
quietly count if mi_tgtns!=mi_tgt
scalar n_mi_changed = r(N)
display "records whose mltgtns initial differs from mltgt's: " r(N)
quietly count if mi_tgtns!=mi_tgt & mi_tgt!=""
assert r(N)==0
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
rename (id mi) (histid mi1930)
isid histid
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
		keep if mi1930 != "" & mi_anc != ""
		scalar nva_`s'_`c' = _N
		quietly count if mi1930 == mi_anc
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
/*ml (TODAY'S RERUN) AGAINST true (THE PAPER'S FILE), PAIRS:  */
/*ALL PAIRS (a) AND THOSE IN THE 51.0M SAMPLE (s)              */
/*============================================================*/
use `pairs_true', clear
merge 1:1 histid1930 histid1940 using `pairs_ml', gen(m)
foreach w in a s {
	if "`w'"=="s" {
		rename histid1940 histid
		merge m:1 histid using `den_full', keep(3) nogenerate
		rename histid histid1940
	}
	quietly count if m==3
	scalar mt_both_`w' = r(N)
	quietly count if m==1
	scalar mt_trueonly_`w' = r(N)
	quietly count if m==2
	scalar mt_mlonly_`w' = r(N)
	display "pairs (`w'): in both " mt_both_`w' ", paper's file only " mt_trueonly_`w' ", rerun only " mt_mlonly_`w'
}

/*============================================================*/
/*OUTPUT                                                      */
/*============================================================*/
file open md using `"`md'"', write replace text
file write md "# Target-only ABE links, 1930-1940 men" _n _n
file write md "Written by MATCHING/score_tgt_links.do (definitions of LINKAGE/code/01_abe_jw/linkage_analysis.do; ans and true checked against the main table)." _n _n
file write md "Columns: **Old** = Ancestry names; **New (paper)** = model names on every record, the paper's file; **New (rerun)** = the same, rerun 2026-11-17 by the code that made Target-only; **Target-only** = model names on target records only; **Target-only, no sentinel** = the same with the model's literal 'InvalidPred' replaced by Ancestry's field (2026-11-22), with the middle initial the pipeline's fallback gives; that changes the own 1940 initial of " %9.0fc (n_mi_changed) " sample records from Target-only's. Own initials of fallback records: where the model gave no first name, New (paper), New (rerun) and the target records of both Target-only columns have an empty initial (1_divide re-cleans Ancestry's already-cleaned first name), so those records enter the Ancestry-MI rows but not the own-MI rows; the non-target records of both Target-only columns carry Ancestry's initial. The Ancestry-MI rows hold the yardstick fixed across columns. Comparing Target-only with New (rerun) isolates the target-only restriction (both with the sentinel); comparing Target-only, no sentinel with Target-only isolates the sentinel fix on target records. New (paper) and New (rerun) still carry the sentinel on every record." _n _n
file write md "Share validated uses each version's own 1940 middle initial (Old: Ancestry's; New: ours; Target-only: ours on target records, Ancestry's elsewhere), as the paper does; the Ancestry-MI row uses Ancestry's 1940 initial for every version. Verified/contradicted are against the FamilySearch-profile sample and cover only links it reaches (unverifiable excluded)." _n _n
foreach w in a s {
	if "`w'"=="a" local lab "all pairs"
	if "`w'"=="s" local lab "pairs whose 1940 person is in the sample"
	file write md "Rerun vs paper's file, `lab' (fiveyr_band==1): in both " %12.0fc (mt_both_`w') ", paper's only " %12.0fc (mt_trueonly_`w') ", rerun only " %12.0fc (mt_mlonly_`w') "." _n _n
}
foreach s in full restr non {
	if "`s'"=="full"  file write md _n "## All records (N = " %12.0fc (N_full) ")" _n _n
	if "`s'"=="restr" file write md _n "## Target records (N = " %12.0fc (N_restr) ")" _n _n
	if "`s'"=="non"   file write md _n "## Non-target records (N = " %12.0fc (N_non) ")" _n _n
	file write md "| | Old | New (paper) | New (rerun) | Target-only | Target-only, no sentinel |" _n "|---|---:|---:|---:|---:|---:|" _n
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
