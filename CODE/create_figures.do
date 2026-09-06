set scheme s1mono 
set seed 1000

local code "D:\Dropbox\fixing_transcription_errors\CODE\"
local original_ed "F:\enum_date\DATA\ORIGINAL\"
local original "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\"
local intermediate_nondb "F:\enum_date\DATA\INTERMEDIATE\"
local intermediate "D:\Dropbox\enum_date\DATA\INTERMEDIATE\"
local figure "D:\Dropbox\Apps\Overleaf\error_correction\figures\"
local christian_torben "D:\Dropbox\fixing_transcription_errors\DATA\TRANSCRIPTIONS\"
local intermediate_tr "D:\Dropbox\fixing_transcription_errors\DATA\INTERMEDIATE\"

local beg_yr=1930
local label_size="2"
local label_position=12


/*
/************************************************************************/
/*IMPORT THE SOCIO-DEMOGRAPHIC CHARACTERISTICS OF RHODE ISLAND RESIDENTS*/
/************************************************************************/
do `"`code'usa00589_for_rhode_island_socio_demo_char.do"'


/*********************************************************************/
/*FIGURE 1: PICK THE ENUMERATION DISTRICT WITH THE AVERAGE LEGIBILITY*/
/*********************************************************************/
use `"`original'rhode_island_combined_with_nonditto_dummy.dta"',clear

merge 1:1 histid using `"`original'ancestry_rhode_island.dta"',keepusing(histid censuscounty eventdistrict sex) update

gen congruent=namefrst==fs_namefrst & namelast==fs_namelast if (_merge==3|_merge==4|_merge==5)
replace congruent=1 if _merge==2

bysort censuscounty eventdistrict: gen Nall=_N
bysort censuscounty eventdistrict: egen Ninc=total(congruent)
gen sh_cong=Ninc/Nall

bysort censuscounty eventdistrict: gen rep=_n==1

sum sh_cong,detail

gen diff_from_mean=abs(sh_cong-`r(mean)')

gsort diff_from_mean

tab eventdistrict if _n==1

merge 1:1 histid using `"`original_ed'rhode_island_socio_demo_char.dta"',keep(1 3) nogen /*THIS IS CREATED IN usa00587_for_rhode_island_socio_demo_char.do*/

capture drop _merge
rename histid id_B
merge 1:1 id_B using `"`intermediate'link`beg_yr'_1940_ans_cleaned_noraceblock.dta"',keepusing(mi`beg_yr' mi1940 id_A fiveyr) keep(1 3)

gen linked_before=_merge==3 & fiveyr==1
gen validated_before=mi`beg_yr'==mi1940 if mi`beg_yr'!="" & mi1940!="" & linked_before==1

rename id_A id_A_before
drop mi`beg_yr' mi1940 fiveyr _merge


capture drop _merge
merge 1:1 id_B using `"`intermediate'link`beg_yr'_1940_true_cleaned_noraceblock.dta"',keepusing(mi`beg_yr' mi1940 id_A fiveyr) keep(1 3)

gen linked_after=_merge==3 & fiveyr==1
gen validated_after=mi`beg_yr'==mi1940 if mi`beg_yr'!="" & mi1940!="" & linked_after==1

rename id_A id_A_after
drop mi`beg_yr' mi1940 fiveyr _merge

numlabel,add

//gen congruentlegibility=namefrst==fs_namefrst & namelast==fs_namelast

bysort censuscounty eventdistrict: egen legibility=mean(congruent)

keep if sex==1 & age>=10

bysort censuscounty eventdistrict: replace rep=_n==1

save `"`intermediate'temp.dta"',replace








use `"`intermediate'temp.dta"',clear


/***********************************************************************************/
/*FIGURE 2: INCREASE IN LINKAGE RATES AND SHARE VALIDATED, BY ENUMERATION DISTRICTS*/
/***********************************************************************************/

collapse (mean) linked_before linked_after validated_before validated_after legibility Nall (count) Nvalnonmiss_before=validated_before Nvalnonmiss_after=validated_after, by(censuscounty eventdistrict)


sum linked_before [fw=Nall]
local mean_before=`r(mean)'

sum linked_after [fw=Nall]
local mean_after=`r(mean)'

capture cd `"`figure'"'

tw (kdensity linked_before [fw=Nall],lcolor(black%35) xline(`mean_before',lcolor(black%35) lpattern(dash)))||(kdensity linked_after [fw=Nall], xline(`mean_after',lpatter(dash) lcolor(blue%30)) lcolor(blue%30)),legend(order(1 "Before correction" 2 "After correction")) xtitle("Linkage rate") ytitle("Density")
//tw (kdensity linked_before [fw=Nall],xline(`mean_before',lpattern(dash)))||(kdensity linked_after [fw=Nall],xline(`mean_after',lpatter(dash) lcolor(blue%30)) lcolor(blue%30)),legend(order(1 "Before correction" 2 "After correction"))
graph export `"`figure'rhode_island_linkage_rate.pdf"', as(pdf) replace

/*PERCENT INCREASE VERSION*/
gen lr_pct_inc=(linked_after-linked_before)/linked_before

sum lr_pct_inc [fw=Nall]
local mean_pct_inc=`r(mean)'

tw (kdensity lr_pct_inc [fw=Nall],lcolor(blue%30) xline(`mean_pct_inc',lcolor(black%35) lpattern(dash))), xtitle("% increase in linkage rate") ytitle("Density")
graph export `"`figure'rhode_island_linkage_rate_pct.pdf"', as(pdf) replace	

/*SCATTER PLOT*/
tw (scatter linked_after linked_before [fw=Nall],mcolor(blue%30) msymbol(smcircle_hollow))||(function y = x, ra(linked_after) clpat(dash) lcolor(black%65)),xtitle("Linkage rate before correction") ytitle("Linkage rate after correction") legend(off)
graph export `"`figure'rhode_island_linkage_rate_scatter.pdf"', as(pdf) replace

/***********************************************************************************/
/*FIGURE 3: INCREASE IN LINKAGE RATES AND SHARE VALIDATED, BY ENUMERATION DISTRICTS*/
/***********************************************************************************/
sum validated_before [fw=Nvalnonmiss_before]
local mean_before=`r(mean)'

sum validated_after [fw=Nvalnonmiss_before]
local mean_after=`r(mean)'

tw (kdensity validated_before [fw=Nvalnonmiss_before],lcolor(black%35) xline(`mean_before',lcolor(black%35) lpattern(dash)))||(kdensity validated_after [fw=Nvalnonmiss_after],lcolor(blue%30)), xline(`mean_after',lpatter(dash) lcolor(blue%30)) legend(order(1 "Before correction" 2 "After correction")) xtitle("Share validated") ytitle("Density")
graph export `"`figure'rhode_island_sh_validated.pdf"', as(pdf) replace

/*PERCENT INCREASE VERSION*/
gen sv_pct_inc=(validated_after-validated_before)/validated_before

sum sv_pct_inc [fw=Nall]
local mean_pct_inc=`r(mean)'

tw (kdensity sv_pct_inc [fw=Nvalnonmiss_before],lcolor(blue%30) xline(`mean_pct_inc',lcolor(black%35) lpattern(dash))), xtitle("% increase in share validated") ytitle("Density")
graph export `"`figure'rhode_island_sh_validated_pct.pdf"', as(pdf) replace	

/*SCATTER PLOT*/
tw (scatter validated_after validated_before [fw=Nvalnonmiss_before],mcolor(blue%30) msymbol(smcircle_hollow))||(function y = x, ra(linked_after) clpat(dash) lcolor(black%65)),xtitle("Share validated before correction") ytitle("Share validated after correction") legend(off)
graph export `"`figure'rhode_island_sh_validated_scatter.pdf"', as(pdf) replace	


/*
/*SCATTER PLOT (HETEROGENEITY)*/
rename (linked_before linked_after validated_before validated_after) (l1 l2 v1 v2)
reshape long v l,i(censuscounty eventdistrict) j(j)

binsreg l legibility /*[fw=Nall]*/, by(j) xtitle("Legibility of census form") ytitle("Linkage rates") legend(order(1 "Before" 2 "After")) bysymbols(circle_hollow diamond_hollow) bycolors(red%50 blue%50) saving(1.gph,replace) /*plotxrange(0.4 1)*/
graph export `"`figure'rhode_island_linkage_rate_hetero.pdf"', as(pdf) replace	

binsreg v legibility /*[fw=Nall]*/, by(j) xtitle("Legibility of census form") ytitle("Share validated") legend(order(1 "Before" 2 "After")) bysymbols(circle_hollow diamond_hollow) bycolors(red%50 blue%50) saving(2.gph,replace) /*plotxrange(0.4 1)*/
graph export `"`figure'rhode_island_sh_validated_hetero.pdf"', as(pdf) replace	

grc1leg 1.gph 2.gph,xcommon

graph export `"`figure'rhode_island_hetero_combined.pdf"', as(pdf) replace		
*/



/*SCATTER PLOT (HETEROGENEITY): MUNIR'S REQUEST*/
capture rename (linked_before linked_after validated_before validated_after) (l1 l2 v1 v2)
capture reshape long v l,i(censuscounty eventdistrict) j(j)

binsreg l legibility /*[fw=Nall]*/, by(j) xtitle("Legibility of census form") ytitle("Linkage rates") legend(order(1 "Before" 2 "After")) bysymbols(circle_hollow plus) bycolors(red%50 blue%50) saving(1.gph,replace) /*plotxrange(0.4 1)*/
graph export `"`figure'rhode_island_linkage_rate_hetero.pdf"', as(pdf) replace	

binsreg v legibility /*[fw=Nall]*/, by(j) xtitle("Legibility of census form") ytitle("Share validated") legend(order(1 "Before" 2 "After")) bysymbols(circle_hollow plus) bycolors(red%50 blue%50) saving(2.gph,replace) /*plotxrange(0.4 1)*/
graph export `"`figure'rhode_island_sh_validated_hetero.pdf"', as(pdf) replace	

grc1leg 1.gph 2.gph,xcommon

graph export `"`figure'rhode_island_hetero_combinedV2.pdf"', as(pdf) replace
*/







/********************************************************************/
/*FIGURE 4: INCREASE IN QUALITY BY SOCIO-DEMOGRAPHIC CHARACTERISTICS*/
/********************************************************************/
use `"`intermediate'temp.dta"',clear


/*CLEAN VARIABLE*/
recode gq (1 2=0) (3 4=1) (6=.)
recode relate (1 2 3 5 7 9=1) (4 6 8 10=2) (11 12=3) (13=4)
recode marst (1 2 3 4 5=1) (6=2)
recode race (1=1) (2 3 4 5 6=2)
recode bpl (1/115=1) (150/900=2)
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
	log using `"`intermediate_nondb'rhode_island_effect_socio_demo.log"',replace
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





import delimited `"`intermediate_nondb'rhode_island_effect_socio_demo.log"', delimiter("|") clear

do `"`code'label_socio_demo.do"'

drop if v1=="migrate5" & v2==4 /*DROP PEOPLE WHO LIVED ABROAD 5 YEARS AGO*/

gsort v4

/*
capture cd `"`figure'"'

scatter v9 v8 if _n<=16, plotregion(lstyle(none)) mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position') /*xtitle("% increase in linkage rate")*/ xtitle("") ytitle("% increase in share validated") xline(0,lpatter(dash) lcolor(black%25)) yline(0,lpatter(dash) lcolor(black%25)) saving(1.gph,replace) legend(off)

//graph export `"`figure'rhode_island_socio_demo.pdf"', as(pdf) replace

scatter v9 v8 if _n>16 & _n<=32, plotregion(lstyle(none)) mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position') /*xtitle("% increase in linkage rate")*/ /*ytitle("% increase in share validated")*/ xtitle("") ytitle("") xline(0,lpatter(dash) lcolor(black%25)) yline(0,lpatter(dash) lcolor(black%25)) saving(2.gph,replace) legend(off)

//graph export `"`figure'rhode_island_socio_demo_other.pdf"', as(pdf) replace

scatter v9 v8 if _n>32 & _n<=48, plotregion(lstyle(none)) mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position') xtitle("% increase in linkage rate") ytitle("% increase in share validated") xline(0,lpatter(dash) lcolor(black%25)) yline(0,lpatter(dash) lcolor(black%25)) saving(3.gph,replace) legend(off)

scatter v9 v8 if _n>48 & _n<=64, plotregion(lstyle(none)) mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position') xtitle("% increase in linkage rate") ytitle("") /*ytitle("% increase in share validated")*/ xline(0,lpatter(dash) lcolor(black%25)) yline(0,lpatter(dash) lcolor(black%25)) saving(4.gph,replace) legend(off)

graph combine 1.gph 2.gph 3.gph 4.gph,xcommon ycommon

graph export `"`figure'rhode_island_socio_demo_combined.pdf"', as(pdf) replace
*/

/*
tw (scatter v5 v4, mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position'))||(line v5 v5, sort clpat(--)),plotregion(lstyle(none)) legend(order(2 "45 degree line")) xtitle("Before") ytitle("After") title("Linkage rate") saving(1.gph,replace) aspectratio(1) legend(off)
tw (scatter v7 v6, mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position'))||(line v7 v7, sort clpat(--)),plotregion(lstyle(none)) legend(order(2 "45 degree line")) xtitle("Before") ytitle("After") title("Share validated") saving(2.gph,replace) aspectratio(1) legend(off)
graph combine 1.gph 2.gph
graph export `"`figure'rhode_island_socio_demo_combined.pdf"', as(pdf) replace
*/


/*
/*ORIGINAL*/
tw (scatter v6 v4, mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position')), plotregion(lstyle(none)) xtitle("Pre-improvement linkage rate") ytitle("Pre-improvement Share validated") saving(1.gph,replace) /*aspectratio(1)*/ legend(off)
tw (scatter v9 v8, mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position')), plotregion(lstyle(none)) xtitle("% increase in linkage rate") ytitle("% increase in share validated") xline(0,lpatter(dash) lcolor(black%25)) yline(0,lpatter(dash) lcolor(black%25)) saving(2.gph,replace) legend(off)
graph combine 1.gph 2.gph
graph export `"`figure'rhode_island_socio_demo_combined.pdf"', as(pdf) replace
*/

/*MUNIR'S REVISION*/
tw (scatter v8 v4, mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position')), plotregion(lstyle(none)) xtitle("Pre-improvement linkage rate") ytitle("% increase in linkage rate") saving(1.gph,replace) /*aspectratio(1)*/ yline(0,lpatter(dash) lcolor(black%25)) legend(off)
tw (scatter v9 v6, mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position')), plotregion(lstyle(none)) xtitle("Pre-improvement Share validated") ytitle("% increase in share validated") /*xline(0,lpatter(dash) lcolor(black%25))*/ yline(0,lpatter(dash) lcolor(black%25)) saving(2.gph,replace) legend(off) /*aspectratio(1)*/

graph combine 1.gph 2.gph, rows(2) cols(1) ysize(7)
graph export `"`figure'rhode_island_socio_demo_combinedV2.pdf"', as(pdf) replace 

/*
tw (scatter v7 v6, mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position'))||(line v7 v7, sort clpat(--)),plotregion(lstyle(none)) legend(order(2 "45 degree line")) xtitle("Before") ytitle("After") title("Share validated") saving(2.gph,replace) aspectratio(1) legend(off)
graph combine 1.gph 2.gph
graph export `"`figure'rhode_island_socio_demo_combined.pdf"', as(pdf) replace

//tw (scatter v7 v6, mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position'))||(function y = x, ra(v7) clpat(.-.))
*/


/*
/*******************************************************************************/
/*MUNIR'S REQUEST: VERTICAL PANELS + LINKAGE AND SHARE VALIDATED SEPARATE PANEL*/
/*******************************************************************************/
tw (scatter v6 v4, mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position')), plotregion(lstyle(none)) xtitle("Pre-improvement linkage rate") ytitle("Pre-improvement Share validated") saving(1.gph,replace) /*aspectratio(1)*/ legend(off)
tw (scatter v9 v8, mcolor(blue%30) mlabel(socio_demo_label) mlabsize(`label_size') mlabposition(`label_position')), plotregion(lstyle(none)) xtitle("% increase in linkage rate") ytitle("% increase in share validated") xline(0,lpatter(dash) lcolor(black%25)) yline(0,lpatter(dash) lcolor(black%25)) saving(2.gph,replace) legend(off)
graph combine 1.gph 2.gph
graph export `"`figure'rhode_island_socio_demo_combinedV2.pdf"', as(pdf) replace


/*
/**********************************************************************************************/
/*PERFORMANCE OF OUR MODEL, BY THE EQUALITY OF THE MODEL PREDICTION TO THE HUMAN TRANSCRIPTION*/
/**********************************************************************************************/
use `"`christian_torben'df_all_namefrst_archive_quality_tokens_round2.dta"',clear
bysort filename linep: keep if _N==1
save `"`christian_torben'temp1.dta"',replace

use `"`christian_torben'df_all_namelast_ditto_archive_quality_tokens_round2.dta"',clear
bysort filename linep: keep if _N==1
save `"`christian_torben'temp2.dta"',replace


use `"`intermediate'temp.dta"',clear

keep if imagenumber_combined!=""

replace imagenumber_combined=imagenumber_combined+".jpg"
			
tostring linep,replace
			
rename imagenumber_combined filename

merge 1:1 filename linep using `"`christian_torben'temp1.dta"',keepusing(namefrst_ml quality) keep(1 3) nogen
rename quality fqual

merge 1:1 filename linep using `"`christian_torben'temp2.dta"',keepusing(namelast_ml quality) keep(1 3) nogen
rename quality lqual


/****************************************/
/*INVESTIGATE WHY SOME LINKS ARE DROPPED*/
/****************************************/
keep if (linked_before==1 & linked_after==0)|(validated_before==1 & validated_after==0)

keep if (namefrst!=namefrst_ml|namelast!=namelast_ml) & (namefrst!=fs_namefrst|namelast!=fs_namelast)
keeporder censuscounty eventdistrict imagenumber sheet linep namefrst namefrst_ml fqual namelast namelast_ml lqual nonditto linked_before linked_after validated_before validated_after

sample 100,count

gsort censuscounty eventdistrict imagenumber

export excel using `"`intermediate_tr'examine_dropped_links.xls"', firstrow(variables) replace






//capture erase `"`intermediate'temp.dta"'
//capture erase `"`christian_torben'temp1.dta"'
//capture erase `"`christian_torben'temp2.dta"'
