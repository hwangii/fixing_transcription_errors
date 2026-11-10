/*SCORE THE FAMILYSEARCH-NAME ABE LINKS AS THE PAPER SCORES ITS ABE LINKS    */
/*(2026-11-07).                                                              */
/*                                                                           */
/*The paper's ABE exact-name columns (linkage_tables/linkage_table_abe_jw*.tex)*/
/*are written on machine B by LINKAGE/code/01_abe_jw/linkage_analysis.do.     */
/*This file repeats that file's ABE calculations on machine A, which holds    */
/*the FamilySearch-name link files, line for line where it can:              */
/*  - links: fiveyr_band==1, pairs deduplicated                               */
/*  - denominator: 1940 men aged 8+ in the ML-name 1940 divided files, which  */
/*    is what B's clean_names_1940_new.dta is (00_merge_names_to_census.do   */
/*    appends divided_file1940_true_cleaned; its merge to matching_intgen    */
/*    keeps every record)                                                     */
/*  - middle initials: 1930 from the Ancestry divided files, 1940 from the ML */
/*    divided files, the same for every column, as in the paper               */
/*  - truth: the FamilySearch-profile sample (mlp_training1930_1940.dta);    */
/*    Verified / Unverifiable / Directly                                      */
/*    Contradicted two-sided as fixed on 2026-10-19; recall                   */
/*  - restricted sample: 1940 records where Ancestry and FamilySearch         */
/*    disagree (congruent==0)                                                 */
/*Columns: Ancestry (the paper's "Old"), ML (the paper's "New"), and          */
/*FamilySearch names in 1930 and 1940, 1930 only, 1940 only. Panel B         */
/*compares every column with Ancestry.                                       */
/*                                                                           */
/*THE ANCESTRY AND ML COLUMNS MUST REPRODUCE THE PAPER'S TABLE; THE FILE      */
/*CHECKS THIS AND STOPS IF THEY DO NOT, SINCE THE FAMILYSEARCH COLUMNS ARE    */
/*THEN NOT COMPARABLE. READ-ONLY EXCEPT FOR THE TABLE IT WRITES:              */
/*MATCHING/results/fs_linkage_abe.tex                                         */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"

local links "$REP_SNU/enum_date/DATA/INTERMEDIATE"
local div   "$REP_F/enum_date/DATA/INTERMEDIATE"
local true_links "$REP_F/fixing_transcription_errors/DATA/INTERMEDIATE/mlp_training1930_1940.dta"
local congruent_f "$REP_SNU/fixing_transcription_errors/DATA/TRANSCRIPTIONS/ipums_fs_names_for_Deaglan1940.dta"

local f_ans   "`links'/link1930_1940_ans_cleaned_noraceblock0.dta"
local f_true  "`links'/link1930_1940_true_cleaned_noraceblock0.dta"
local f_fs12  "`links'/link1930_1940_fs1930_1940_cleaned_noraceblock0.dta"
local f_fs30  "`links'/link1930_1940_fs1930_cleaned_noraceblock0.dta"
local f_fs40  "`links'/link1930_1940_fs1940_cleaned_noraceblock0.dta"
local combos ans true fs12 fs30 fs40

/*THE PAPER'S NUMBERS (linkage_tables/linkage_table_abe_jw.tex AND _restricted,*/
/*ABE COLUMNS: Old = ans, New = true; PANEL B ADDED/REMOVED = true vs ans).    */
/*TRUTH-BASED VALUES UPDATED 2026-11-10: THE PAPER NOW SCORES AGAINST MACHINE  */
/*A'S COMPLETE TRUTH FILE (paper 3ca56d2; LINKAGE/notes/truth_file_provenance.md).*/
local p_full_ans_ver 6283801
local p_full_ans_unv 5883324
local p_full_ans_con 348279
local p_full_true_ver 6794104
local p_full_true_unv 6375502
local p_full_true_con 317830
local p_full_add_ver 1081009
local p_full_add_unv 1199711
local p_full_add_con 81640
local p_full_rem_ver 571902
local p_full_rem_unv 708243
local p_full_rem_con 110183
local p_restr_ans_ver 523399
local p_restr_ans_unv 694933
local p_restr_ans_con 65907
local p_restr_true_ver 1320314
local p_restr_true_unv 1411579
local p_restr_true_con 72769
local p_restr_add_ver 945322
local p_restr_add_unv 969084
local p_restr_add_con 50582
local p_restr_rem_ver 150060
local p_restr_rem_unv 253120
local p_restr_rem_con 41385
/*PERCENTAGES, AS PRINTED (TWO DECIMALS): MATCH RATE, MI MATCH RATE, RECALL.*/
local p_full_ans_rate 21.73
local p_full_true_rate 23.42
local p_full_ans_mi 86.27
local p_full_true_mi 87.00
local p_full_ans_recall 31.79
local p_full_true_recall 34.37
local p_restr_ans_rate 8.56
local p_restr_true_rate 18.69
local p_restr_ans_mi 76.81
local p_restr_true_mi 83.51
local p_restr_ans_recall 11.13
local p_restr_true_recall 28.07
local p_denom_full  57589273
local p_denom_restr 15003537

/*============================================================*/
/*PART 0: THE CLEAN-NAME FILES, REBUILT FROM THE DIVIDED FILES */
/*============================================================*/

/*1940: ML-name divided files (clean_names_1940_new), boys and men aged 8+.*/
clear
local files : dir `"`div'/divided_file1940_true_cleaned"' files "norace*.dta"
foreach f of local files {
	append using `"`div'/divided_file1940_true_cleaned/`f'"', keep(id age mi_true_cleaned)
}
rename (id mi_true_cleaned) (histid mi)
isid histid
keep if age >= 8 & !missing(age)
scalar N_men_1940_full = _N
keep histid mi
tempfile cn1940_full
save `cn1940_full'

use histid congruent using `"`congruent_f'"', clear
keep if congruent == 0
keep histid
tempfile restr1940
save `restr1940'

use `cn1940_full', clear
merge 1:1 histid using `restr1940', keep(3) nogenerate
scalar N_men_1940_restr = _N
tempfile cn1940_restr
save `cn1940_restr'

/*1930: Ancestry-name divided files (clean_names_1930_old).*/
clear
local files : dir `"`div'/divided_file1930_ans_cleaned"' files "norace*.dta"
foreach f of local files {
	append using `"`div'/divided_file1930_ans_cleaned/`f'"', keep(id mi)
}
rename id histid
isid histid
tempfile cn1930
save `cn1930'

use `cn1940_full', clear
keep histid
tempfile men1940
save `men1940'

/*TRUTH, AS IN linkage_analysis.do PART 0.*/
use `true_links', clear
keep histid1930 histid1940
duplicates drop histid1930 histid1940, force
rename histid1940 histid
merge m:1 histid using `men1940', keep(3) nogenerate
rename histid histid1940
tempfile true_pairs_full
save `true_pairs_full'

use `true_pairs_full', clear
rename histid1940 histid
merge m:1 histid using `restr1940', keep(3) nogenerate
rename histid histid1940
tempfile true_pairs_restr
save `true_pairs_restr'

use `true_pairs_full', clear
rename histid1930 true_histid1930
tempfile true_by1940
save `true_by1940'

use `true_links', clear
keep histid1930 histid1940
duplicates drop histid1930 histid1940, force
display "truth pairs after dropping duplicates: " _N " (paper, since 2026-11-10: 36,690,338)"
isid histid1930
rename histid1940 true_histid1940
tempfile true_by1930
save `true_by1930'

/*THE LINKS: ONE PAIR FILE PER COLUMN, AS linkage_analysis.do BUILDS THEM.*/
foreach c of local combos {
	/*THE FAMILYSEARCH FILES ALSO CARRY fs_used<yr>: THE RECORD'S NAME CAME */
	/*FROM FAMILYSEARCH IN AT LEAST ONE FIELD (Ancestry IN THE OTHER).       */
	local fsv ""
	if substr("`c'",1,2)=="fs" local fsv "fs_used*"
	use id_A id_B fiveyr_band `fsv' using `"`f_`c''"', clear
	keep if fiveyr_band == 1
	rename (id_A id_B) (histid1930 histid1940)
	keep histid1930 histid1940 `fsv'
	duplicates drop histid1930 histid1940, force
	tempfile pairs_`c'
	save `pairs_`c''
}

local bad 0
foreach samp in full restr {

	display _newline "================ SAMPLE: `samp' ================"
	if N_men_1940_`samp' != `p_denom_`samp'' {
		display as error "denominator `samp': " N_men_1940_`samp' ", paper `p_denom_`samp''"
		local bad 1
	}

	/*========================================================*/
	/*PARTS 1-2: RATE, VERIFIED / UNVERIFIABLE / CONTRADICTED, */
	/*RECALL, MIDDLE-INITIAL AGREEMENT                         */
	/*========================================================*/
	foreach c of local combos {

		use `pairs_`c'', clear
		if "`samp'" == "restr" {
			rename histid1940 histid
			merge m:1 histid using `restr1940', keep(3) nogenerate
			rename histid histid1940
		}
		scalar N_linked_`samp'_`c' = _N
		scalar rate_`samp'_`c' = N_linked_`samp'_`c' / N_men_1940_`samp'
		/*COVERAGE: SHARE OF LINKS WHOSE 1930 / 1940 NAME CAME FROM FAMILYSEARCH.*/
		foreach y in 1930 1940 {
			capture confirm variable fs_used`y'
			if _rc scalar fs`y'_`samp'_`c' = 0
			else {
				quietly count if fs_used`y' == 1
				scalar fs`y'_`samp'_`c' = r(N) / _N
			}
		}

		merge m:1 histid1940 using `true_by1940', keep(1 3) gen(person_merge)
		merge m:1 histid1930 using `true_by1930', keep(1 3) gen(merge30)
		quietly count if person_merge == 1 & merge30 == 1
		scalar unv_`samp'_`c' = r(N)
		quietly count if person_merge == 3 & histid1930 == true_histid1930
		scalar ver_`samp'_`c' = r(N)
		quietly count if (person_merge == 3 & histid1930 != true_histid1930) | (person_merge == 1 & merge30 == 3)
		scalar con_`samp'_`c' = r(N)
		drop merge30 true_histid1940

		preserve
			keep histid1930 histid1940
			merge 1:1 histid1930 histid1940 using `true_pairs_`samp'', keep(1 2 3) gen(pair_merge)
			quietly count if pair_merge == 2
			scalar FN_`samp'_`c' = r(N)
		restore
		scalar recall_`samp'_`c' = ver_`samp'_`c' / (ver_`samp'_`c' + FN_`samp'_`c')

		keep histid1930 histid1940
		rename histid1930 histid
		merge m:1 histid using `cn1930', keep(1 3) nogenerate
		rename (histid mi) (histid1930 mi1930)
		rename histid1940 histid
		merge m:1 histid using `cn1940_`samp'', keep(1 3) nogenerate
		rename (histid mi) (histid1940 mi1940)
		keep if mi1930 != "" & mi1940 != ""
		quietly count
		scalar mi_denom_`samp'_`c' = r(N)
		quietly count if mi1930 == mi1940
		scalar mi_rate_`samp'_`c' = r(N) / mi_denom_`samp'_`c'

		display "`c':  links=" N_linked_`samp'_`c' "  rate=" %6.4f rate_`samp'_`c' ///
			"  Verified=" ver_`samp'_`c' "  Unverifiable=" unv_`samp'_`c' ///
			"  Contradicted=" con_`samp'_`c' "  Recall=" %6.4f recall_`samp'_`c' ///
			"  MI=" %6.4f mi_rate_`samp'_`c'
	}

	foreach c in ans true {
		foreach k in ver unv con {
			if `k'_`samp'_`c' != `p_`samp'_`c'_`k'' {
				display as error "`samp' `c' `k': " `k'_`samp'_`c' ", paper `p_`samp'_`c'_`k''"
				local bad 1
			}
		}
		/*PERCENTAGES MUST ROUND TO THE PRINTED VALUE.*/
		foreach k in rate mi recall {
			local sc "`k'_`samp'_`c'"
			if "`k'"=="mi" local sc "mi_rate_`samp'_`c'"
			if abs(round(`sc'*100, .01) - `p_`samp'_`c'_`k'') > .001 {
				display as error "`samp' `c' `k': " %6.2f `sc'*100 ", paper `p_`samp'_`c'_`k''"
				local bad 1
			}
		}
	}

	/*========================================================*/
	/*PART 3: EACH COLUMN AGAINST ANCESTRY, ON histid1930      */
	/*========================================================*/
	use `pairs_ans', clear
	if "`samp'" == "restr" {
		rename histid1940 histid
		merge m:1 histid using `restr1940', keep(3) nogenerate
		rename histid histid1940
	}
	sort histid1930 histid1940
	duplicates drop histid1930, force
	rename histid1940 histid1940_old
	tempfile old_`samp'
	save `old_`samp''

	foreach c in true fs12 fs30 fs40 {

		use `pairs_`c'', clear
		if "`samp'" == "restr" {
			rename histid1940 histid
			merge m:1 histid using `restr1940', keep(3) nogenerate
			rename histid histid1940
		}
		sort histid1930 histid1940
		duplicates drop histid1930, force
		rename histid1940 histid1940_new
		tempfile new
		save `new'

		use `old_`samp'', clear
		merge 1:1 histid1930 using `new', gen(id_merge)
		gen status = ""
		replace status = "net_removed" if id_merge == 1
		replace status = "net_added"   if id_merge == 2
		replace status = "unchanged"   if id_merge == 3 & histid1940_old == histid1940_new
		replace status = "changed"     if id_merge == 3 & histid1940_old != histid1940_new

		merge m:1 histid1930 using `true_by1930', keep(1 3) gen(merge30)

		gen new_cat = .
		rename histid1940_new histid1940
		merge m:1 histid1940 using `true_by1940', keep(1 3) gen(merge_new)
		replace new_cat = 2 if inlist(status,"net_added","changed") & merge_new == 1 & merge30 == 1
		replace new_cat = 1 if inlist(status,"net_added","changed") & merge_new == 3 & histid1930 == true_histid1930
		replace new_cat = 3 if inlist(status,"net_added","changed") & ((merge_new == 3 & histid1930 != true_histid1930) | (merge_new == 1 & merge30 == 3))
		rename histid1940 histid1940_new
		drop true_histid1930 merge_new

		gen old_cat = .
		rename histid1940_old histid1940
		merge m:1 histid1940 using `true_by1940', keep(1 3) gen(merge_old)
		replace old_cat = 2 if inlist(status,"net_removed","changed") & merge_old == 1 & merge30 == 1
		replace old_cat = 1 if inlist(status,"net_removed","changed") & merge_old == 3 & histid1930 == true_histid1930
		replace old_cat = 3 if inlist(status,"net_removed","changed") & ((merge_old == 3 & histid1930 != true_histid1930) | (merge_old == 1 & merge30 == 3))
		rename histid1940 histid1940_old
		drop true_histid1930 merge_old merge30 true_histid1940

		local j 0
		foreach k in ver unv con {
			local ++j
			quietly count if status == "net_added" & new_cat == `j'
			scalar add_`k'_`samp'_`c' = r(N)
			quietly count if status == "net_removed" & old_cat == `j'
			scalar rem_`k'_`samp'_`c' = r(N)
		}
		/*PARTNER CHANGED: THE 1930 PERSON IS LINKED IN BOTH, TO DIFFERENT 1940 */
		/*PEOPLE. THE PAPER'S PANEL B LEAVES THESE OUT OF ADDED/REMOVED; THEY ARE*/
		/*REPORTED HERE SEPARATELY.                                             */
		quietly count if status == "changed"
		scalar chg_tot_`samp'_`c' = r(N)
		quietly count if status == "changed" & new_cat == 1
		scalar chg_newver_`samp'_`c' = r(N)
		quietly count if status == "changed" & old_cat == 1
		scalar chg_oldver_`samp'_`c' = r(N)
		quietly count if status == "net_added"
		scalar add_tot_`samp'_`c' = r(N)
		quietly count if status == "net_removed"
		scalar rem_tot_`samp'_`c' = r(N)
		display "`c' vs ans: added " add_tot_`samp'_`c' " (verified " add_ver_`samp'_`c' ", unverifiable " add_unv_`samp'_`c' ", contradicted " add_con_`samp'_`c' ")" ///
			"; removed " rem_tot_`samp'_`c' " (verified " rem_ver_`samp'_`c' ", unverifiable " rem_unv_`samp'_`c' ", contradicted " rem_con_`samp'_`c' ")"
		tab status
	}

	foreach d in add rem {
		foreach k in ver unv con {
			if `d'_`k'_`samp'_true != `p_`samp'_`d'_`k'' {
				display as error "`samp' Panel B `d' `k': " `d'_`k'_`samp'_true ", paper `p_`samp'_`d'_`k''"
				local bad 1
			}
		}
	}
}

if `bad' {
	display as error "REPLICATION FAILED: the Ancestry/ML columns do not reproduce the paper's ABE table; no table written"
	exit 9
}
display "REPLICATION PASSED: Ancestry and ML columns equal the paper's ABE exact-name columns"

/*============================================================*/
/*PART 4: TABLE                                               */
/*============================================================*/
capture mkdir "$REP_REPO/MATCHING/results"
local outtex "$REP_REPO/MATCHING/results/fs_linkage_abe.tex"
file open f using "`outtex'", write replace
file write f "% Written by MATCHING/score_fs_links.do; do not edit by hand." _n
file write f "% ABE exact-name links, conservative (+-2 year) band. FS = FamilySearch names where FamilySearch has them, Ancestry otherwise (field by field)." _n
file write f "% Net added/removed follow the paper's Panel B (1930 person newly linked / no longer linked); partner changes are the separate rows." _n
file write f "% Verified/Unverifiable/Contradicted are against the FamilySearch-profile linked sample, as in the paper." _n
file write f "\begin{tabular}{lccccc}" _n
file write f "\toprule" _n
file write f " & Ancestry & ML & FS 1930 \& 1940 & FS 1930 & FS 1940 \\" _n
foreach samp in full restr {
	file write f "\midrule" _n
	if "`samp'"=="full"  file write f "\multicolumn{6}{l}{\textit{Men aged 8+ in the 1940 census}} \\" _n
	if "`samp'"=="restr" file write f "\multicolumn{6}{l}{\textit{1940 records where Ancestry and FamilySearch disagree}} \\" _n
	foreach row in fs1930 fs1940 rate mi ver unv con recall add_ver add_unv add_con rem_ver rem_unv rem_con chg_tot chg_newver chg_oldver {
		if "`row'"=="fs1930"  local lab "Links with an FS name in 1930 (\%)"
		if "`row'"=="fs1940"  local lab "Links with an FS name in 1940 (\%)"
		if "`row'"=="chg_tot"    local lab "Partner changed vs.\ Ancestry"
		if "`row'"=="chg_newver" local lab "\quad new partner Verified"
		if "`row'"=="chg_oldver" local lab "\quad Ancestry partner Verified"
		if "`row'"=="rate"    local lab "Match Rate (\%)"
		if "`row'"=="mi"      local lab "MI Match Rate (\%)"
		if "`row'"=="ver"     local lab "Verified Correct"
		if "`row'"=="unv"     local lab "Unverifiable"
		if "`row'"=="con"     local lab "Directly Contradicted"
		if "`row'"=="recall"  local lab "Recall (\%)"
		if "`row'"=="add_ver" local lab "Net added vs.\ Ancestry: Verified"
		if "`row'"=="add_unv" local lab "Net added vs.\ Ancestry: Unverifiable"
		if "`row'"=="add_con" local lab "Net added vs.\ Ancestry: Contradicted"
		if "`row'"=="rem_ver" local lab "Net removed vs.\ Ancestry: Verified"
		if "`row'"=="rem_unv" local lab "Net removed vs.\ Ancestry: Unverifiable"
		if "`row'"=="rem_con" local lab "Net removed vs.\ Ancestry: Contradicted"
		local line "`lab'"
		foreach c of local combos {
			if "`row'"=="rate"   local v : di %5.2f (rate_`samp'_`c' * 100)
			if "`row'"=="mi"     local v : di %5.2f (mi_rate_`samp'_`c' * 100)
			if "`row'"=="recall" local v : di %5.2f (recall_`samp'_`c' * 100)
			if "`row'"=="fs1930" local v : di %5.2f (fs1930_`samp'_`c' * 100)
			if "`row'"=="fs1940" local v : di %5.2f (fs1940_`samp'_`c' * 100)
			if inlist("`row'","ver","unv","con") local v : di %12.0fc `row'_`samp'_`c'
			if inlist(substr("`row'",1,4),"add_","rem_","chg_") {
				/*row add_ver -> scalar add_ver_<samp>_<column>*/
				if "`c'"=="ans" local v "--"
				else local v : di %12.0fc `row'_`samp'_`c'
			}
			local line "`line' & `=strtrim("`v'")'"
		}
		file write f "`line' \\" _n
	}
}
file write f "\bottomrule" _n
file write f "\end{tabular}" _n
file close f
display "wrote `outtex'"
