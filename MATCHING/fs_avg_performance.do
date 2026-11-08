/*LINKAGE RATE AND SHARE VALIDATED FOR THE FAMILYSEARCH-NAME ABE LINKS        */
/*(2026-11-07).                                                              */
/*                                                                           */
/*Repeats the paper's main table (tab:avg_performance, written by            */
/*CODE/create_figures_SSHA2025.do) for five versions of the ABE exact-name   */
/*links: Ancestry ("before"), ML ("after"), and FamilySearch names in 1930   */
/*and 1940, 1930 only, 1940 only. Same sample (1940 men aged 10+ in the      */
/*socio-demographic extract), same target set (Ancestry and FamilySearch     */
/*disagree on the 1940 first or last name), same definitions:                */
/*  linkage rate    = linked (fiveyr_band==1) / all records                  */
/*  share validated = middle initials agree / linked with both initials,     */
/*                    each version scored against its own initials (mi1930,  */
/*                    mi1940 in its link file), as in the paper              */
/*A second share validated scores every version against the Ancestry         */
/*initials in both years, so that it moves only when the links move (the     */
/*decomposition in Section 5.1 holds the initial fixed in the same way).     */
/*                                                                           */
/*THE ANCESTRY AND ML COLUMNS MUST REPRODUCE THE PAPER                       */
/*(replication/results/create_figures_SSHA2025.tex); THE FILE STOPS IF THEY  */
/*DO NOT. READ-ONLY EXCEPT FOR MATCHING/results/fs_avg_performance.tex.      */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"

local original    "$REP_SNU/fixing_transcription_errors/DATA/ORIGINAL"
local original_ed "$REP_F/enum_date/DATA/ORIGINAL"
local links       "$REP_SNU/enum_date/DATA/INTERMEDIATE"
local div         "$REP_F/enum_date/DATA/INTERMEDIATE"

local f_ans  "`links'/link1930_1940_ans_cleaned_noraceblock0.dta"
local f_true "`links'/link1930_1940_true_cleaned_noraceblock0.dta"
local f_fs12 "`links'/link1930_1940_fs1930_1940_cleaned_noraceblock0.dta"
local f_fs30 "`links'/link1930_1940_fs1930_cleaned_noraceblock0.dta"
local f_fs40 "`links'/link1930_1940_fs1940_cleaned_noraceblock0.dta"
local combos ans true fs12 fs30 fs40

/*THE PAPER'S VALUES (raw= IN replication/results/create_figures_SSHA2025.tex).*/
local p_n_target 14416543
local p_n_all    51036859
local p_lr_target_ans  8.88273284378925
local p_lr_target_true 19.4149041139752
local p_lr_all_ans     22.8142938812124
local p_lr_all_true    24.6009379221398
local p_nv_target_ans  308513
local p_nv_target_true 618732
local p_nv_all_ans     2512418
local p_nv_all_true    2665324
local p_sv_target_ans  65.4053475866495
local p_sv_target_true 83.5985531700316
local p_sv_all_ans     85.9879207998032
local p_sv_all_true    87.137473718017

/*ANCESTRY MIDDLE INITIALS BY histid, BOTH YEARS (THE MEN-ONLY ANCESTRY      */
/*DIVIDED FILES THE ANCESTRY LINKS WERE MATCHED FROM).                       */
foreach y in 1930 1940 {
	clear
	local files : dir `"`div'/divided_file`y'_ans_cleaned"' files "norace*.dta"
	foreach f of local files {
		append using `"`div'/divided_file`y'_ans_cleaned/`f'"', keep(id mi)
	}
	isid id
	rename mi mianc`y'
	if `y'==1930 rename id id_A
	else rename id id_B
	tempfile mianc`y'
	save `mianc`y''
}

/*THE SAMPLE, AS IN create_figures_SSHA2025.do.*/
use namefrst namelast namefrst_fs namelast_fs histid using `"`original'/census1940_all_labeled_data.dta"', clear
gen byte target = !(namefrst==namefrst_fs & namelast==namelast_fs)
drop namefrst namelast namefrst_fs namelast_fs
merge 1:1 histid using `"`original_ed'/all_states_socio_demo_char_for_SSHA2025.dta"', keepusing(sex age) keep(1 3) nogen
keep if sex==1 & age>=10 & age<.
drop sex age
rename histid id_B
merge 1:1 id_B using `mianc1940', keep(1 3) nogen

foreach c of local combos {
	/*fs_used<yr>: THE NAME CAME FROM FAMILYSEARCH IN AT LEAST ONE FIELD.    */
	/*EACH FAMILYSEARCH FILE CARRIES IT ONLY FOR ITS FAMILYSEARCH YEAR(S).   */
	local fsv ""
	if "`c'"=="fs12" local fsv "fs_used1930 fs_used1940"
	if "`c'"=="fs30" local fsv "fs_used1930"
	if "`c'"=="fs40" local fsv "fs_used1940"
	merge 1:1 id_B using `"`f_`c''"', keepusing(id_A mi1930 mi1940 fiveyr_band `fsv') keep(1 3)
	gen byte linked_`c' = _merge==3 & fiveyr_band==1
	gen byte val_`c' = mi1930==mi1940 if mi1930!="" & mi1940!="" & linked_`c'==1
	foreach y in 1930 1940 {
		if strpos(" `fsv' ", " fs_used`y' ") gen byte fs`y'_`c' = fs_used`y'==1 if linked_`c'==1
		else gen byte fs`y'_`c' = 0 if linked_`c'==1
	}
	drop mi1930 mi1940 fiveyr_band _merge `fsv'
	merge m:1 id_A using `mianc1930', keep(1 3) nogen
	gen byte valanc_`c' = mianc1930==mianc1940 if mianc1930!="" & mianc1940!="" & linked_`c'==1
	drop id_A mianc1930
}

local bad 0
foreach grp in target all {
	local cond ""
	if "`grp'"=="target" local cond "if target==1"
	quietly count `cond'
	scalar n_`grp' = r(N)
	if n_`grp' != `p_n_`grp'' {
		display as error "`grp' records: " n_`grp' ", paper `p_n_`grp''"
		local bad 1
	}
	foreach c of local combos {
		quietly sum linked_`c' `cond'
		scalar lr_`grp'_`c' = 100*r(mean)
		quietly sum val_`c' `cond'
		scalar nv_`grp'_`c' = r(N)
		scalar sv_`grp'_`c' = 100*r(mean)
		quietly sum valanc_`c' `cond'
		scalar nva_`grp'_`c' = r(N)
		scalar sva_`grp'_`c' = 100*r(mean)
		foreach y in 1930 1940 {
			quietly sum fs`y'_`c' `cond'
			scalar fs`y'_`grp'_`c' = 100*r(mean)
		}
		display "`grp' `c': linkage rate " %6.3f lr_`grp'_`c' "  share validated " %6.3f sv_`grp'_`c' " (N=" nv_`grp'_`c' ")" ///
			"  with Ancestry initials " %6.3f sva_`grp'_`c' " (N=" nva_`grp'_`c' ")"
	}
	foreach c in ans true {
		foreach k in nv {
			if `k'_`grp'_`c' != `p_`k'_`grp'_`c'' {
				display as error "`grp' `c' `k': " `k'_`grp'_`c' ", paper `p_`k'_`grp'_`c''"
				local bad 1
			}
		}
		foreach k in lr sv {
			if abs(`k'_`grp'_`c' - `p_`k'_`grp'_`c'') > 1e-9 {
				display as error "`grp' `c' `k': " %18.0g `k'_`grp'_`c' ", paper `p_`k'_`grp'_`c''"
				local bad 1
			}
		}
	}
}
/*WITH ANCESTRY INITIALS, THE ANCESTRY COLUMN SHOULD EQUAL ITS OWN-INITIAL */
/*VALUE (ITS OWN INITIALS ARE ANCESTRY'S, FROM matching_intgen RATHER THAN */
/*THE DIVIDED FILES). REPORTED, NOT A STOP: THE PAPER DOES NOT USE THIS ROW.*/
foreach grp in target all {
	if nva_`grp'_ans != nv_`grp'_ans | abs(sva_`grp'_ans - sv_`grp'_ans) > 1e-9 {
		display as error "NOTE `grp': Ancestry column with divided-file Ancestry initials: " sva_`grp'_ans " (N=" nva_`grp'_ans "), own initials " sv_`grp'_ans " (N=" nv_`grp'_ans ")"
	}
}
if `bad' {
	display as error "REPLICATION FAILED: the Ancestry/ML columns do not reproduce the paper's main table; no table written"
	exit 9
}
display "REPLICATION PASSED: Ancestry and ML columns equal the paper's main table"

capture mkdir "$REP_REPO/MATCHING/results"
local outtex "$REP_REPO/MATCHING/results/fs_avg_performance.tex"
file open f using "`outtex'", write replace
file write f "% Written by MATCHING/fs_avg_performance.do; do not edit by hand." _n
file write f "% Sample and definitions as in tab:avg_performance. FS = FamilySearch names where FamilySearch has them, Ancestry otherwise (field by field)." _n
file write f "% Own initials: Ancestry column from matching_intgen; ML column 1930 Ancestry, 1940 ML; FS columns from each side's divided file (FS where the FS first name is used)." _n
file write f "% Ancestry initials: every column scored with the Ancestry initials from the men-only Ancestry divided files." _n
file write f "\begin{tabular}{llccccc}" _n
file write f "\toprule" _n
file write f " & & Ancestry & ML & FS 1930 \& 1940 & FS 1930 & FS 1940 \\" _n
file write f "\midrule" _n
foreach row in n lr sv nv sva nva fs1930 fs1940 {
	if "`row'"=="n"   local lab "Records"
	if "`row'"=="lr"  local lab "Linkage rate (\%)"
	if "`row'"=="sv"  local lab "Share validated (\%)"
	if "`row'"=="nv"  local lab "\quad links with both initials"
	if "`row'"=="sva" local lab "Share validated, Ancestry initials (\%)"
	if "`row'"=="nva" local lab "\quad links with both initials"
	if "`row'"=="fs1930" local lab "Links with an FS name in 1930 (\%)"
	if "`row'"=="fs1940" local lab "Links with an FS name in 1940 (\%)"
	foreach grp in target all {
		local g = cond("`grp'"=="target", "Target", "All")
		local line "`lab' & `g'"
		foreach c of local combos {
			if "`row'"=="n" local v : di %12.0fc n_`grp'
			else if inlist("`row'","nv","nva") local v : di %12.0fc `row'_`grp'_`c'
			else local v : di %5.1f `row'_`grp'_`c'
			local line "`line' & `=strtrim("`v'")'"
		}
		file write f "`line' \\" _n
		local lab ""
	}
}
file write f "\bottomrule" _n
file write f "\end{tabular}" _n
file close f
display "wrote `outtex'"
