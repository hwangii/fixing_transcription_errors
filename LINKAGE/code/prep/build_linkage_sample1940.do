/*THE 1940 SAMPLE FOR THE LINKAGE-QUALITY TABLES (2026-11-15). RUNS ON       */
/*MACHINE A (IT NEEDS THE LABELLED CENSUS FILE AND THE SOCIO-DEMOGRAPHIC      */
/*EXTRACT); THE OUTPUT IS CARRIED TO MACHINE B BY DROPBOX.                    */
/*                                                                           */
/*The ABE/JW and HLINK tables (LINKAGE/code/01_abe_jw/linkage_analysis.do,   */
/*LINKAGE/code/02_hlink/linkage_analysis_newlinks.do) used their own sample:  */
/*men aged 8+ (men and women for HLINK), target = a separate congruence flag, */
/*and our 1940 middle initials for the Old links too. They now use the main   */
/*table's (tab:avg_performance, CODE/create_figures_SSHA2025.do):             */
/*  sample  = 1940 men aged 10+ with both an Ancestry and a FamilySearch      */
/*            transcription (census1940_all_labeled_data x socio-demo extract)*/
/*  target  = Ancestry and FamilySearch disagree on the first or last name    */
/*  initials: each version its own -- Ancestry's for Old, ours for New        */
/*            (1940; 1930 is Ancestry in both)                                */
/*                                                                           */
/*Writes linkage_sample1940.dta: histid target mi_anc mi_ml, one row per      */
/*person. Stops unless the sample and target counts equal the main table's.   */
/*Copy it to machine B's $D_FLAGS (data/names/flags/).                        */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"

local original    "$REP_SNU/fixing_transcription_errors/DATA/ORIGINAL"
local original_ed "$REP_F/enum_date/DATA/ORIGINAL"
local div         "$REP_F/enum_date/DATA/INTERMEDIATE"
local out         "$REP_SNU/fixing_transcription_errors/DATA/INTERMEDIATE/linkage_sample1940.dta"

/*THE MAIN TABLE'S COUNTS (replication/results/create_figures_SSHA2025.tex).*/
local p_n_all    51036859
local p_n_target 14416543

/*1940 MIDDLE INITIALS, FROM THE MEN-ONLY DIVIDED FILES THE ABE LINKS WERE   */
/*MATCHED FROM: Ancestry (_ans_cleaned, mi) AND OURS (_true_cleaned,         */
/*mi_true_cleaned). THE ANCESTRY ONES REPRODUCE THE MAIN TABLE'S OWN-INITIAL */
/*SHARE VALIDATED (MATCHING/fs_avg_performance.do, 2026-11-14).              */
foreach t in ans true {
	local miv = cond("`t'"=="ans", "mi", "mi_true_cleaned")
	clear
	local files : dir `"`div'/divided_file1940_`t'_cleaned"' files "norace*.dta"
	foreach f of local files {
		append using `"`div'/divided_file1940_`t'_cleaned/`f'"', keep(id `miv')
	}
	isid id
	rename (id `miv') (histid mi_`t')
	tempfile mi_`t'
	save `mi_`t''
}

/*THE SAMPLE, EXACTLY AS IN create_figures_SSHA2025.do.*/
use namefrst namelast namefrst_fs namelast_fs histid using `"`original'/census1940_all_labeled_data.dta"', clear
gen byte target = !(namefrst==namefrst_fs & namelast==namelast_fs)
drop namefrst namelast namefrst_fs namelast_fs
merge 1:1 histid using `"`original_ed'/all_states_socio_demo_char_for_SSHA2025.dta"', keepusing(sex age) keep(1 3) nogen
keep if sex==1 & age>=10 & age<.
drop sex age

quietly count
if r(N)!=`p_n_all' {
	display as error "sample: " r(N) " records, main table `p_n_all'"
	exit 9
}
quietly count if target==1
if r(N)!=`p_n_target' {
	display as error "target: " r(N) " records, main table `p_n_target'"
	exit 9
}

merge 1:1 histid using `mi_ans', keep(1 3) nogen
merge 1:1 histid using `mi_true', keep(1 3) nogen
rename (mi_ans mi_true) (mi_anc mi_ml)
isid histid
compress
label variable target "Ancestry and FamilySearch disagree on the 1940 first or last name"
label variable mi_anc "1940 middle initial, Ancestry (divided_file1940_ans_cleaned)"
label variable mi_ml  "1940 middle initial, ours (divided_file1940_true_cleaned)"
label data "1940 men 10+ with Ancestry and FamilySearch names; build_linkage_sample1940.do"
count if mi_anc!=""
count if mi_ml!=""
save `"`out'"', replace
display "wrote `out': " _N " records, `p_n_target' target"
