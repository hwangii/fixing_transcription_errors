/*SOCIO-DEMOGRAPHIC PROFILE BY LINK STATUS (2026-11-19).                     */
/*                                                                           */
/*1940 men aged 10+ (the sample of tab:avg_performance), split by whether    */
/*they are linked to 1930 (ABE exact, conservative, fiveyr_band==1) under    */
/*the Ancestry transcription ("before") and under ours on target records     */
/*only ("after", link1930_1940_mltgt1940):                                   */
/*  both      linked before and after                                        */
/*  afteronly linked after only (gained)                                      */
/*  neither   linked in neither                                              */
/*  beforeonly linked before only (lost; reported for completeness)          */
/*For each characteristic of the heterogeneity figure (same recodes as       */
/*CODE/create_figures_SSHA2025.do, Figure 4, and the labels of               */
/*CODE/label_socio_demo.do), the share of each group in each category, among */
/*the group's records with the characteristic non-missing. Also mean age,    */
/*share target, mean legibility.                                             */
/*                                                                           */
/*INPUT: temp_tgt.dta, saved by create_figures_SSHA2025.do under             */
/*MATCHING/_figs_tgt_run.do (2026-11-18). CHECK: its linkage rates equal     */
/*MATCHING/results/create_figures_SSHA2025_tgt.tex. READ-ONLY EXCEPT FOR     */
/*MATCHING/results/linked_groups_socio.md.                                   */
/*  powershell -File replication/Run-Stata.ps1 MATCHING/linked_groups_socio.do */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local temp "$REP_SNU/enum_date/DATA/INTERMEDIATE/temp_tgt.dta"
local md   "$REP_REPO/MATCHING/results/linked_groups_socio.md"
local vars gq relate marst race bpl higrade empstat classwkr occ1950 ind1950 wkswork2 hrswork2 migrate5 incnonwg non_english_mtongue

use linked_before linked_after age congruent legibility `vars' using `"`temp'"', clear

/*CHECK AGAINST create_figures_SSHA2025_tgt.tex (raw= VALUES).*/
assert _N==51036859
quietly sum linked_before
assert abs(100*r(mean) - 22.8142938812124) < 1e-9
quietly sum linked_after
assert abs(100*r(mean) - 25.5382957638518) < 1e-9
assert inlist(linked_before,0,1) & inlist(linked_after,0,1)
/*target IS NOT SAVED IN temp_tgt.dta (create_figures_SSHA2025.do MAKES IT  */
/*AFTER THE SAVE); congruent IS ITS COMPLEMENT (2026-11-19 REVIEW).          */
assert inlist(congruent,0,1)
gen byte target = 1 - congruent
drop congruent
quietly sum target
assert abs(100*r(mean) - 28.2473163170171) < 1e-9

/*SAME RECODES AS create_figures_SSHA2025.do, FIGURE 4.*/
recode gq (1 2=0) (3 4=1) (6=.)
recode relate (1 2 3 5 7 9=1) (4 6 8 10=2) (11 12=3) (13=4)
recode marst (1 2 3 4 5=1) (6=2)
recode race (1=1) (2 3 4 5 6 7=2)
recode bpl (1/120=1) (150/900=2)
recode higrade (1 3=1) (4/9=2) (10/12=3) (13/15=4) (16/19=5) (20/23=6) (99=.)
recode empstat (0=.)
recode classwkr (0 9=.)
recode occ1950 (979/999=.)
replace occ1950=floor(occ1950/100)
recode ind1950 (0 946/999=.) (105/126=1) (206/239=2) (246=3) (306/499=4) (506/598=5) (606/699=6) (716/756=7) (806/817=8) (826/849=9) (856/859=10) (868/899=11) (906/946=12)
recode wkswork2 (0=.)
recode hrswork2 (0=.)
/*FIGURE 4 DROPS incnonwg==1 BECAUSE IT RATES WITHIN CATEGORIES; A SHARE   */
/*NEEDS BOTH CATEGORIES, SO ONLY N/A (0) AND MISSING (9) GO (2026-11-19     */
/*REVIEW: (1 9=.) WOULD MAKE >$50 100% OF EVERY GROUP).                     */
recode incnonwg (0 9=.)
recode migrate5 (9=.)

gen byte grp = cond(linked_before & linked_after, 1, cond(!linked_before & linked_after, 2, cond(!linked_before & !linked_after, 3, 4)))
local gnames both afteronly neither beforeonly
forvalues g = 1/4 {
	quietly count if grp==`g'
	scalar N`g' = r(N)
	quietly sum age if grp==`g'
	scalar age`g' = r(mean)
	quietly sum target if grp==`g'
	scalar tgt`g' = 100*r(mean)
	quietly sum legibility if grp==`g'
	scalar leg`g' = r(mean)
}
assert N1+N2+N3+N4 == _N

/*SHARES: ONE ROW PER (variable, value), ONE COLUMN PER GROUP.*/
tempfile rows
tempname ph
postfile `ph' str24 v1 double v2 s1 s2 s3 s4 using `rows'
foreach v of local vars {
	quietly levelsof `v', local(vals)
	forvalues g = 1/4 {
		quietly count if grp==`g' & !missing(`v')
		local d`g' = r(N)
	}
	foreach val of local vals {
		forvalues g = 1/4 {
			quietly count if grp==`g' & `v'==`val'
			local s`g' = cond(`d`g''>0, 100*r(N)/`d`g'', .)
		}
		post `ph' ("`v'") (`val') (`s1') (`s2') (`s3') (`s4')
	}
}
postclose `ph'

use `rows', clear
do "$REP_REPO/CODE/label_socio_demo.do"
/*IPUMS incnonwg: 1 = LESS THAN $50, 2 = $50 OR MORE (REVIEW ROUND 2).*/
replace socio_demo_label = "Nonwage inc.<50" if v1=="incnonwg" & v2==1
replace socio_demo_label = "Nonwage inc.>=50" if v1=="incnonwg" & v2==2
replace socio_demo_label = v1 + "=" + string(v2) if socio_demo_label==""

capture file close md
file open md using `"`md'"', write replace text
file write md "# Socio-demographic profile by link status" _n _n
file write md "Generated by MATCHING/linked_groups_socio.do. Do not edit by hand." _n _n
file write md "1940 men aged 10+ with both an Ancestry and a FamilySearch transcription (51,036,859; the main table's sample; temp_tgt.dta from create_figures_SSHA2025.do, target-only run). Linked = ABE exact, conservative, fiveyr_band==1. Before = Ancestry names; after = our names on target records (Ancestry's where the model gave none), Ancestry's elsewhere (link1930_1940_mltgt1940). Shares (%) are within each group, among records with the characteristic non-missing; recodes and labels as in the heterogeneity figure." _n _n
file write md "| | Both | After only | Neither | Before only |" _n
file write md "|---|---:|---:|---:|---:|" _n
local r "| Records |"
forvalues g = 1/4 {
	local r "`r' `=strtrim(string(N`g', "%15.0fc"))' |"
}
file write md "`r'" _n
local r "| Mean age |"
forvalues g = 1/4 {
	local r "`r' `=strtrim(string(age`g', "%5.1f"))' |"
}
file write md "`r'" _n
local r "| Target (%) |"
forvalues g = 1/4 {
	local r "`r' `=strtrim(string(tgt`g', "%5.1f"))' |"
}
file write md "`r'" _n
local r "| Mean legibility |"
forvalues g = 1/4 {
	local r "`r' `=strtrim(string(leg`g', "%5.3f"))' |"
}
file write md "`r'" _n
local last ""
forvalues i = 1/`=_N' {
	if v1[`i'] != "`last'" {
		file write md "| *`=v1[`i']'* | | | | |" _n
		local last = v1[`i']
	}
	local r "| `=socio_demo_label[`i']' |"
	forvalues g = 1/4 {
		local r "`r' `=strtrim(string(s`g'[`i'], "%5.1f"))' |"
	}
	file write md "`r'" _n
}
file close md
display "wrote `md'"
