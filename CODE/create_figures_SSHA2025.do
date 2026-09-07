capture log close
set scheme s1mono 
set seed 1000

/**********************************************************************/
/*ROOT PATHS: THESE ARE THE ONLY THREE LINES TO CHANGE IF FOLDERS MOVE.*/
/*Dropbox moved to the SNU ECON team folder; the code and the Overleaf */
/*project are now git repos under D:\repos\.                           */
/**********************************************************************/
local dropbox "D:\SNU ECON Dropbox\sam hwang\"
local code "D:\repos\fixing_transcription_errors\CODE\"
local overleaf "D:\repos\6638fa0fd89fbec05130caeb\"

local original "`dropbox'fixing_transcription_errors\DATA\ORIGINAL\"
local intermediate "`dropbox'enum_date\DATA\INTERMEDIATE\"
local christian_torben "`dropbox'fixing_transcription_errors\DATA\TRANSCRIPTIONS\"
local intermediate_tr "`dropbox'fixing_transcription_errors\DATA\INTERMEDIATE\"
local original_ed "F:\enum_date\DATA\ORIGINAL\"
local intermediate_nondb "F:\enum_date\DATA\INTERMEDIATE\"
local figure "`overleaf'figures\"

/*SUFFIX ON THE 1930-1940 LINK FILES. The un-suffixed pair the older*/
/*do-files referenced no longer exists; the "0" pair (2026-02-15) is*/
/*the current one.                                                  */
local linksuf "0"

local beg_yr=1930
local label_size="2"
local label_position=12


/************************************************************************/
/*IMPORT THE SOCIO-DEMOGRAPHIC CHARACTERISTICS OF RHODE ISLAND RESIDENTS*/
/************************************************************************/
//do `"`code'usa00647_for_SSHA2025_socio_demo_char.do"'




/*********************************************************************/
/*FIGURE 1: PICK THE ENUMERATION DISTRICT WITH THE AVERAGE LEGIBILITY*/
/*********************************************************************/
use namefrst* namelast* state_folder_name county_folder_name eventdistrict histid using `"`original'census1940_all_labeled_data.dta"',clear /*CREATED IN D:\Dropbox\fixing_transcription_errors\CODE\clean_FS_and_combineV5_nber.do*/

rename (namefrst_fs namelast_fs) (fs_namefrst fs_namelast)

gen congruent=namefrst==fs_namefrst & namelast==fs_namelast

bysort state_folder_name county_folder_name eventdistrict: gen Nall=_N
bysort state_folder_name county_folder_name eventdistrict: egen Ninc=total(congruent)
gen sh_cong=Ninc/Nall

bysort state_folder_name county_folder_name eventdistrict: gen rep=_n==1

sum sh_cong,detail

gen diff_from_mean=abs(sh_cong-`r(mean)')

gsort diff_from_mean

merge 1:1 histid using `"`original_ed'all_states_socio_demo_char_for_SSHA2025.dta"',keep(1 3) nogen /*THIS IS CREATED IN `"`code'usa00647_for_SSHA2025_socio_demo_char.do"'*/

capture drop _merge
rename histid id_B
merge 1:1 id_B using `"`intermediate'link`beg_yr'_1940_ans_cleaned_noraceblock`linksuf'.dta"',keepusing(mi`beg_yr' mi1940 id_A fiveyr) keep(1 3)

gen linked_before=_merge==3 & fiveyr==1
gen validated_before=mi`beg_yr'==mi1940 if mi`beg_yr'!="" & mi1940!="" & linked_before==1

rename id_A id_A_before
drop mi`beg_yr' mi1940 fiveyr _merge


capture drop _merge
merge 1:1 id_B using `"`intermediate'link`beg_yr'_1940_true_cleaned_noraceblock`linksuf'.dta"',keepusing(mi`beg_yr' mi1940 id_A fiveyr) keep(1 3)

gen linked_after=_merge==3 & fiveyr==1
gen validated_after=mi`beg_yr'==mi1940 if mi`beg_yr'!="" & mi1940!="" & linked_after==1

rename id_A id_A_after
drop mi`beg_yr' mi1940 fiveyr _merge

numlabel,add

bysort state_folder_name county_folder_name eventdistrict: egen legibility=mean(congruent)

keep if sex==1 & age>=10

bysort state_folder_name county_folder_name eventdistrict: replace rep=_n==1

save `"`intermediate'temp.dta"',replace







/***********************************************************************************/
/*FIGURE 2: INCREASE IN LINKAGE RATES AND SHARE VALIDATED, BY ENUMERATION DISTRICTS*/
/***********************************************************************************/
use `"`intermediate'temp.dta"',clear

/*SAMPLE: all states. Minnesota, Mississippi and Missouri (and DC) were
  dropped for the SSHA2025 presentation because those extracts were not
  ready in time; they are now, so the drop below is retired. If DC should
  stay out for some other reason, restore just that one condition.*/
//drop if state_folder_name=="district-of-columbia"|state_folder_name=="minnesota"|state_folder_name=="mississippi"|state_folder_name=="missouri"

gen target=!(namefrst==fs_namefrst & namelast==fs_namelast)

/***********************************************************************/
/*TABLE: QUALITY OF LINKED SAMPLES BEFORE AND AFTER TRANSCRIPTIONS ARE */
/*IMPROVED (tab:avg_performance in the paper).                         */
/*                                                                     */
/*This used to be typed into the .tex by hand from the console output  */
/*below, which is how the RI draft ended up with N's that did not match */
/*the balance tables. It now writes itself to `figure'.                */
/*                                                                     */
/*Row definitions, matching the RI version of the table:               */
/*  Linkage rate    -- denominator is every record in the sample, so   */
/*                     the "# of records" column is identical before   */
/*                     and after; only the rate moves.                 */
/*  Share validated -- denominator is the linked records with a non-   */
/*                     missing middle initial in BOTH years, which is  */
/*                     itself larger after correction, so the "# of    */
/*                     records" column moves too.                      */
/***********************************************************************/
capture file close avgperf
file open avgperf using `"`figure'avg_performance_allstates.tex"', write replace text

file write avgperf "\begin{tabular}{@{\extracolsep{3pt}}ccccccc@{}}" _n
file write avgperf "  \hline\hline" _n
file write avgperf "  \multicolumn{2}{c}{} & \multicolumn{2}{c}{Before} & \multicolumn{2}{c}{After} & \multirow{2}{*}{\% change}\\" _n
file write avgperf "  \cline{3-4}  \cline{5-6}" _n
file write avgperf "  \multicolumn{2}{c}{} & \# of records & Rate (Share) & \# of records & Rate (Share) & \\" _n
file write avgperf "  \hline" _n

/*PANEL A: LINKAGE RATE*/
foreach grp in target all {

	if `"`grp'"'=="target" {
		local cond "if target==1"
		local rowlab "\multirow{2}{*}{Linkage rate} & Target"
	}
	else {
		local cond ""
		local rowlab " & All"
	}

	quietly count `cond'
	local n_before=`r(N)'
	local n_after=`r(N)'	/*SAME DENOMINATOR BEFORE AND AFTER*/

	quietly sum linked_before `cond'
	local lr_before=`r(mean)'

	quietly sum linked_after `cond'
	local lr_after=`r(mean)'

	local pct=100*((`lr_after'/`lr_before')-1)

	di "Linkage rate, `grp': `lr_before' -> `lr_after' (`pct'%)"

	local nb=trim(string(`n_before',"%15.0fc"))
	local na=trim(string(`n_after',"%15.0fc"))
	local rb=string(`lr_before',"%4.3f")
	local ra=string(`lr_after',"%4.3f")
	local pc=cond(`pct'>=0,"+","")+trim(string(round(`pct'),"%9.0f"))

	file write avgperf "  `rowlab' & `nb' & `rb' & `na' & `ra' & `pc'\%" "\\" _n

}

file write avgperf "  \hline" _n

/*PANEL B: SHARE VALIDATED*/
foreach grp in target all {

	if `"`grp'"'=="target" {
		local cond "if target==1"
		local rowlab "\multirow{2}{*}{Share validated} & Target"
	}
	else {
		local cond ""
		local rowlab " & All"
	}

	quietly sum validated_before `cond'
	local sv_before=`r(mean)'
	local n_before=`r(N)'		/*LINKED RECORDS WITH NON-MISSING MIDDLE INITIALS, BEFORE*/

	quietly sum validated_after `cond'
	local sv_after=`r(mean)'
	local n_after=`r(N)'		/*...AND AFTER*/

	local pct=100*((`sv_after'/`sv_before')-1)

	di "Share validated, `grp': `sv_before' -> `sv_after' (`pct'%)"

	local nb=trim(string(`n_before',"%15.0fc"))
	local na=trim(string(`n_after',"%15.0fc"))
	local rb=string(`sv_before',"%4.3f")
	local ra=string(`sv_after',"%4.3f")
	local pc=cond(`pct'>=0,"+","")+trim(string(round(`pct'),"%9.0f"))

	file write avgperf "  `rowlab' & `nb' & `rb' & `na' & `ra' & `pc'\%" "\\" _n

}

file write avgperf "  \hline\hline" _n
file write avgperf "\end{tabular}" _n

file close avgperf





/*SCATTER PLOT (HETEROGENEITY WITH RESPECT TO LEGIBILITY)*/
collapse (mean) linked_before linked_after validated_before validated_after legibility Nall (count) Nvalnonmiss_before=validated_before Nvalnonmiss_after=validated_after, by(state_folder_name county_folder_name eventdistrict)

rename (linked_before linked_after validated_before validated_after) (l1 l2 v1 v2)
reshape long v l,i(state_folder_name county_folder_name eventdistrict) j(j)

binsreg l legibility /*[fw=Nall]*/, by(j) xtitle("Legibility of census form") ytitle("Linkage rates") legend(order(1 "Before" 2 "After")) bysymbols(circle_hollow diamond_hollow) bycolors(red%50 blue%50) saving(1.gph,replace) /*plotxrange(0.4 1)*/
/*NB: these single-panel exports used to be written under the rhode_island_*
  names, which overwrote the Rhode-Island figures in the Overleaf folder with
  all-states content. Renamed to all_states_* so the two samples cannot
  clobber each other.*/
graph export `"`figure'all_states_linkage_rate_hetero.pdf"', as(pdf) replace

binsreg v legibility /*[fw=Nall]*/, by(j) xtitle("Legibility of census form") ytitle("Share validated") legend(order(1 "Before" 2 "After")) bysymbols(circle_hollow diamond_hollow) bycolors(red%50 blue%50) saving(2.gph,replace) /*plotxrange(0.4 1)*/
graph export `"`figure'all_states_sh_validated_hetero.pdf"', as(pdf) replace

grc1leg 1.gph 2.gph,xcommon

graph export `"`figure'all_states_hetero_combined.pdf"', as(pdf) replace		




/*SCATTER PLOT (HETEROGENEITY): MUNIR'S REQUEST*/
capture rename (linked_before linked_after validated_before validated_after) (l1 l2 v1 v2)
capture reshape long v l,i(state_folder_name county_folder_name eventdistrict) j(j)

binsreg l legibility /*[fw=Nall]*/, by(j) xtitle("Legibility of census form") ytitle("Linkage rates") legend(order(1 "Before" 2 "After")) bysymbols(circle_hollow plus) bycolors(red%50 blue%50) saving(1.gph,replace) /*plotxrange(0.4 1)*/

binsreg v legibility /*[fw=Nall]*/, by(j) xtitle("Legibility of census form") ytitle("Share validated") legend(order(1 "Before" 2 "After")) bysymbols(circle_hollow plus) bycolors(red%50 blue%50) saving(2.gph,replace) /*plotxrange(0.4 1)*/

grc1leg 1.gph 2.gph,xcommon

graph export `"`figure'all_states_hetero_combinedV2.pdf"', as(pdf) replace







/********************************************************************/
/*FIGURE 4: INCREASE IN QUALITY BY SOCIO-DEMOGRAPHIC CHARACTERISTICS*/
/********************************************************************/
use `"`intermediate'temp.dta"',clear


/*CLEAN VARIABLE*/
recode gq (1 2=0) (3 4=1) (6=.)
recode relate (1 2 3 5 7 9=1) (4 6 8 10=2) (11 12=3) (13=4)
recode marst (1 2 3 4 5=1) (6=2)
recode race (1=1) (2 3 4 5 6 7=2)
recode bpl (1/120=1) (150/900=2)
recode school (0 8 9=.)
recode higrade (1 3=1) (4/9=2) (10/12=3) (13/15=4) (16/19=5) (20/23=6) (99=.)
recode empstat (0=.)
recode labforce (0=.)
recode classwkr (0 9=.)

recode occ1950 (979/999=.)
replace occ1950=floor(occ1950/100)

recode ind1950 (0 946/999=.) (105/126=1) (206/239=2) (246=3) (306/499=4) (506/598=5) (606/699=6) (716/756=7) (806/817=8) (826/849=9) (856/859=10) (868/899=11) (906/946=12)

recode wkswork2 (0=.)
recode hrswork2 (0=.)


recode durunemp (998 999=.)
recode incwage (999998 999999 = .)

foreach var in durunemp incwage {

	sum `var',detail

	gen `var'_qrt=1 if `var'<=`r(p25)'
	replace `var'_qrt=2 if `var'>`r(p25)' & `var'<=`r(p50)'
	replace `var'_qrt=3 if `var'>`r(p50)' & `var'<=`r(p75)'
	replace `var'_qrt=4 if `var'>`r(p75)' & `var'!=.

}

recode incnonwg (1 9=.)
recode migrate5 (9=.)

qui {
	log using `"`intermediate_nondb'all_states_effect_socio_demo.log"',replace
	log off
}

qui foreach var in gq relate marst race bpl /*school*/ higrade empstat /*labforce*/ classwkr occ1950 ind1950 wkswork2 hrswork2 migrate5 /*durunemp_qrt incwage_qrt*/ incnonwg non_english_mtongue {

	levelsof `var', local(list_of_values) 

	foreach val in `list_of_values' {
	
		count if `var'==`val'
		local N=`r(N)'
	
		sum linked_before if `var'==`val'
		local lr_before=`r(mean)'
		sum linked_after if `var'==`val'	
		local lr_after=`r(mean)'
		
		sum validated_before if `var'==`val'
		local sv_before=`r(mean)'
		sum validated_after if `var'==`val'	
		local sv_after=`r(mean)'
		
		log on
		noisily di `"`var'|`val'|`N'|"',`lr_before',"|",`lr_after',"|",`sv_before',"|",`sv_after',"|",100*(`lr_after'/`lr_before'-1),"|",100*(`sv_after'/`sv_before'-1)
		log off

	}

}

qui {
	log close
}





import delimited `"`intermediate_nondb'all_states_effect_socio_demo.log"', delimiter("|") clear

do `"`code'label_socio_demo.do"'

drop if v1=="migrate5" & v2==4 /*DROP PEOPLE WHO LIVED ABROAD 5 YEARS AGO*/

gsort v4

/*MUNIR'S REVISION*/
tw (scatter v8 v4, mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position')), plotregion(lstyle(none)) xtitle("Pre-improvement linkage rate") ytitle("% increase in linkage rate") saving(1.gph,replace) /*aspectratio(1)*/ yline(0,lpatter(dash) lcolor(black%25)) legend(off)
graph export `"`figure'all_states_improvement_linkage_rate.pdf"', as(pdf) replace

tw (scatter v9 v6, mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position')), plotregion(lstyle(none)) xtitle("Pre-improvement Share validated") ytitle("% increase in share validated") /*xline(0,lpatter(dash) lcolor(black%25))*/ yline(0,lpatter(dash) lcolor(black%25)) saving(2.gph,replace) legend(off) /*aspectratio(1)*/
graph export `"`figure'all_states_improvement_sh_validated.pdf"', as(pdf) replace

graph combine 1.gph 2.gph, rows(2) cols(1) ysize(7)
graph export `"`figure'all_states_socio_demo_combinedV2.pdf"', as(pdf) replace 
