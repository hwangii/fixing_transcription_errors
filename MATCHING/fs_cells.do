/*LINKAGE RATE AND SHARE VALIDATED BY MODEL-AGREEMENT CELL (2026-11-07).      */
/*                                                                           */
/*The referees' four-cell split (p. 9 of the draft): on records where the    */
/*Ancestry and FamilySearch transcriptions disagree, the model's name        */
/*  1 matches Ancestry's only                                                */
/*  2 matches FamilySearch's only                                            */
/*  3 is complete and matches neither                                        */
/*  4 is missing (no model output in one or both name fields)                */
/*with exactly the definitions of CODE/compute_model_agreement_on_discordant.do*/
/*(raw strings namefrst, fs_namefrst, namefrst_ml, namelast_ml_ditto from the */
/*per-state merged_data.dta; human-complete denominator). Two residual cells  */
/*keep the partition exact for the linkage sample:                           */
/*  5 discordant, but one of the four human fields is empty                  */
/*  0 not discordant in merged_data, or not in merged_data at all            */
/*                                                                           */
/*For each cell, on the main table's target set (1940 men aged 10+ whose     */
/*Ancestry and FamilySearch names differ, as in tab:avg_performance), it     */
/*reports the linkage rate and share validated of the five ABE exact-name    */
/*link versions of MATCHING/fs_avg_performance.do. Summed over cells the    */
/*Ancestry and ML numbers must equal the paper's target row; the file stops  */
/*if they do not.                                                            */
/*READ-ONLY EXCEPT FOR MATCHING/results/fs_cells.tex.                         */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"

local original    "$REP_SNU/fixing_transcription_errors/DATA/ORIGINAL"
local original_ed "$REP_F/enum_date/DATA/ORIGINAL"
local links       "$REP_SNU/enum_date/DATA/INTERMEDIATE"
local div         "$REP_F/enum_date/DATA/INTERMEDIATE"
local root        "$REP_SNU/fixing_transcription_errors/DATA/TRANSCRIPTIONS/USCensus1940FullCount/output_and_output1_ssha2025"

local f_ans  "`links'/link1930_1940_ans_cleaned_noraceblock0.dta"
local f_true "`links'/link1930_1940_true_cleaned_noraceblock0.dta"
local f_fs12 "`links'/link1930_1940_fs1930_1940_cleaned_noraceblock0.dta"
local f_fs30 "`links'/link1930_1940_fs1930_cleaned_noraceblock0.dta"
local f_fs40 "`links'/link1930_1940_fs1940_cleaned_noraceblock0.dta"
local combos ans true fs12 fs30 fs40

/*THE PAPER'S TARGET ROW (raw= IN replication/results/create_figures_SSHA2025.tex).*/
local p_n_target 14416543
local p_lr_ans  8.88273284378925
local p_lr_true 19.4149041139752
local p_nv_ans  308513
local p_nv_true 618732
local p_sv_ans  65.4053475866495
local p_sv_true 83.5985531700316

/*=========================================================*/
/*1. CELL BY histid, STATE BY STATE                        */
/*=========================================================*/
/*THE 50 STATE FOLDERS 1_divide_and_clean READS FOR THE ML NAMES. ak IS NOT  */
/*AMONG THEM; ITS RECORDS FALL IN CELL 0.                                    */
local states "al ar az ca co ct dc de fl ga hi ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy"
tempfile cells
local z 0
foreach s of local states {
	capture describe namefrst fs_namefrst namefrst_ml namelast fs_namelast namelast_ml_ditto histid using `"`root'/`s'/merged_data.dta"'
	if _rc {
		/*hi'S merged_data HAS NO ANCESTRY/FAMILYSEARCH COLUMNS (SEE         */
		/*compute_model_agreement_on_discordant.do); ITS RECORDS FALL IN 0.  */
		/*ANY OTHER STATE THAT CANNOT BE READ STOPS THE RUN.                 */
		if "`s'"!="hi" {
			display as error "`s': cannot read the name columns of merged_data.dta (rc=" _rc ")"
			exit 601
		}
		display "`s': no human name columns, skipped (expected)"
		continue
	}
	use namefrst fs_namefrst namefrst_ml namelast fs_namelast namelast_ml_ditto histid using `"`root'/`s'/merged_data.dta"', clear
	keep if histid!=""
	gen byte disc = namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="" & !(namefrst==fs_namefrst & namelast==fs_namelast)
	gen byte ml_ok = namefrst_ml!="" & namelast_ml_ditto!=""
	gen byte cell = 0
	replace cell = 1 if disc & ml_ok & namefrst==namefrst_ml & namelast==namelast_ml_ditto & !(fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto)
	replace cell = 2 if disc & ml_ok & fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto & !(namefrst==namefrst_ml & namelast==namelast_ml_ditto)
	replace cell = 3 if disc & ml_ok & !(fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto) & !(namefrst==namefrst_ml & namelast==namelast_ml_ditto)
	replace cell = 4 if disc & !ml_ok
	/*THE FOUR HUMAN-COMPLETE CELLS MUST PARTITION THE DISCORDANT RECORDS.*/
	assert inrange(cell,1,4) if disc
	replace cell = 5 if cell==0 & !(namefrst==fs_namefrst & namelast==fs_namelast)
	keep histid cell
	local ++z
	if `z'>1 append using `cells'
	save `cells', replace
}
use `cells', clear
/*A histid IN MORE THAN ONE ROW WITH DIFFERENT CELLS IS NOT CLASSIFIABLE.*/
bysort histid (cell): gen byte _conf = cell[1]!=cell[_N]
quietly count if _conf
display "histids in more than one merged_data row with conflicting cells: " r(N)
by histid: keep if _n==1
replace cell = 0 if _conf
drop _conf
rename histid id_B
save `cells', replace

/*=========================================================*/
/*2. THE MAIN TABLE'S TARGET SET AND THE FIVE LINK VERSIONS */
/*=========================================================*/
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

use namefrst namelast namefrst_fs namelast_fs histid using `"`original'/census1940_all_labeled_data.dta"', clear
keep if !(namefrst==namefrst_fs & namelast==namelast_fs)
drop namefrst namelast namefrst_fs namelast_fs
merge 1:1 histid using `"`original_ed'/all_states_socio_demo_char_for_SSHA2025.dta"', keepusing(sex age) keep(1 3) nogen
keep if sex==1 & age>=10 & age<.
drop sex age
rename histid id_B
merge 1:1 id_B using `cells', keep(1 3)
replace cell = 0 if _merge==1
drop _merge
merge 1:1 id_B using `mianc1940', keep(1 3) nogen

foreach c of local combos {
	merge 1:1 id_B using `"`f_`c''"', keepusing(id_A mi1930 mi1940 fiveyr_band) keep(1 3)
	gen byte linked_`c' = _merge==3 & fiveyr_band==1
	gen byte val_`c' = mi1930==mi1940 if mi1930!="" & mi1940!="" & linked_`c'==1
	drop mi1930 mi1940 fiveyr_band _merge
	merge m:1 id_A using `mianc1930', keep(1 3) nogen
	gen byte valanc_`c' = mianc1930==mianc1940 if mianc1930!="" & mianc1940!="" & linked_`c'==1
	drop id_A mianc1930
}

/*=========================================================*/
/*3. GATE: THE TARGET SET AND ITS ANCESTRY/ML ROW          */
/*=========================================================*/
local bad 0
if _N != `p_n_target' {
	display as error "target records: " _N ", paper `p_n_target'"
	local bad 1
}
foreach c in ans true {
	quietly sum linked_`c'
	if abs(100*r(mean) - `p_lr_`c'') > 1e-9 {
		display as error "target `c' linkage rate " 100*r(mean) ", paper `p_lr_`c''"
		local bad 1
	}
	quietly sum val_`c'
	if r(N) != `p_nv_`c'' | abs(100*r(mean) - `p_sv_`c'') > 1e-9 {
		display as error "target `c' share validated " 100*r(mean) " (N=" r(N) "), paper `p_sv_`c'' (N=`p_nv_`c'')"
		local bad 1
	}
}
if `bad' {
	display as error "REPLICATION FAILED: the target row does not reproduce the paper; no table written"
	exit 9
}
display "REPLICATION PASSED: target set and its Ancestry/ML row equal the paper"

/*=========================================================*/
/*4. BY CELL                                               */
/*=========================================================*/
tab cell
local cells_list 1 2 3 4 5 0
foreach c of local combos {
	scalar tl_`c' = 0
	scalar tv_`c' = 0
}
scalar tn = 0
foreach k of local cells_list {
	quietly count if cell==`k'
	scalar n_`k' = r(N)
	scalar sh_`k' = 100*r(N)/_N
	foreach c of local combos {
		quietly sum linked_`c' if cell==`k'
		scalar lr_`k'_`c' = 100*r(mean)
		quietly sum val_`c' if cell==`k'
		scalar nv_`k'_`c' = r(N)
		scalar sv_`k'_`c' = 100*r(mean)
		quietly sum valanc_`c' if cell==`k'
		scalar nva_`k'_`c' = r(N)
		scalar sva_`k'_`c' = 100*r(mean)
		if n_`k' > 0 scalar tl_`c' = tl_`c' + lr_`k'_`c'*n_`k'/100
		scalar tv_`c' = tv_`c' + nv_`k'_`c'
		display "cell `k' `c': N=" n_`k' "  linkage rate " %6.3f lr_`k'_`c' ///
			"  share validated " %6.3f sv_`k'_`c' " (N=" nv_`k'_`c' ")" ///
			"  with Ancestry initials " %6.3f sva_`k'_`c' " (N=" nva_`k'_`c' ")"
	}
	scalar tn = tn + n_`k'
}
/*THE CELLS MUST ADD BACK TO THE TARGET ROW (AN EMPTY CELL ADDS NOTHING; A     */
/*NON-EMPTY CELL ALWAYS HAS A NON-MISSING linked MEAN).                    */
if tn != `p_n_target' {
	display as error "cells sum to " tn " records, target `p_n_target'"
	exit 9
}
foreach c in ans true {
	if abs(100*tl_`c'/tn - `p_lr_`c'') > 1e-6 | tv_`c' != `p_nv_`c'' {
		display as error "`c': cells give linkage rate " 100*tl_`c'/tn " and " tv_`c' " validated-denominator links; paper `p_lr_`c'' and `p_nv_`c''"
		exit 9
	}
}
display "CELLS ADD UP: records, Ancestry/ML linkage and validation denominators equal the target row"

capture mkdir "$REP_REPO/MATCHING/results"
local outtex "$REP_REPO/MATCHING/results/fs_cells.tex"
file open f using "`outtex'", write replace
file write f "% Written by MATCHING/fs_cells.do; do not edit by hand." _n
file write f "% Target set of tab:avg_performance, split by whether the model's name matches Ancestry's, FamilySearch's, neither, or is missing (definitions of compute_model_agreement_on_discordant.do)." _n
file write f "% Own initials as in the paper; Ancestry initials hold the 1930 and 1940 initial fixed for every version." _n
file write f "\begin{tabular}{llccccc}" _n
file write f "\toprule" _n
file write f " & & Ancestry & ML & FS 1930 \& 1940 & FS 1930 & FS 1940 \\" _n
foreach k of local cells_list {
	if `k'==1 local lab "Model = Ancestry only"
	if `k'==2 local lab "Model = FamilySearch only"
	if `k'==3 local lab "Model = neither"
	if `k'==4 local lab "No model output"
	if `k'==5 local lab "A human field empty"
	if `k'==0 local lab "Not classified"
	local nn : di %12.0fc n_`k'
	local ss : di %4.1f sh_`k'
	file write f "\midrule" _n
	file write f "\multicolumn{7}{l}{\textit{`lab': `=strtrim("`nn'")' records (`=strtrim("`ss'")'\% of target)}} \\" _n
	foreach row in lr sv nv sva nva {
		if "`row'"=="lr"  local rl "Linkage rate (\%)"
		if "`row'"=="sv"  local rl "Share validated (\%)"
		if "`row'"=="nv"  local rl "\quad links with both initials"
		if "`row'"=="sva" local rl "Share validated, Ancestry initials (\%)"
		if "`row'"=="nva" local rl "\quad links with both initials"
		local line "`rl' &"
		foreach c of local combos {
			if inlist("`row'","nv","nva") local v : di %12.0fc `row'_`k'_`c'
			else local v : di %5.1f `row'_`k'_`c'
			local line "`line' & `=strtrim("`v'")'"
		}
		file write f "`line' \\" _n
	}
}
file write f "\bottomrule" _n
file write f "\end{tabular}" _n
file close f
display "wrote `outtex'"
