/*MIDDLE-INITIAL VALIDATION WITH ONE FIXED 1940 MIDDLE INITIAL (2026-11-01). */
/*                                                                           */
/*The draft's share validated compares mi1930 with mi1940, but each version's */
/*link file carries its own mi1940 (middle_initial_sources.do: mi1930 is the  */
/*same in both files; mi1940 differs for 324,768 same-pair links). So the     */
/*validator changes with the transcription being evaluated. This rescores    */
/*BOTH versions against ONE 1940 middle initial, taken in turn from each human */
/*transcription, so only the links differ:                                    */
/*  anc: second word of the Ancestry first-name field (namefrst)              */
/*  fs : second word of the FamilySearch first-name field (fs_namefrst)       */
/*Step 1 checks which source each link file's mi1940 matches. Step 2 rescores.*/
/*READ-ONLY.                                                                  */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
repnum open using "$REP_RESULTS/validation_fixed_initials.tex", script(replication/diagnostics/validation_fixed_initials.do)
local intermediate "$REP_SNU/enum_date/DATA/INTERMEDIATE/"

use id_B namefrst fs_namefrst congruent linked_before linked_after id_A_before id_A_after validated_before validated_after using `"`intermediate'temp.dta"', clear

/*MIDDLE INITIAL = FIRST LETTER OF THE SECOND WORD, LOWER CASE, LETTERS ONLY.*/
foreach src in anc fs {
	local v = cond("`src'"=="anc", "namefrst", "fs_namefrst")
	gen mi_`src' = lower(substr(word(strtrim(`v'), 2), 1, 1))
	replace mi_`src' = "" if !regexm(mi_`src', "^[a-z]$")
	/*A GENERATIONAL SUFFIX IN SECOND POSITION ("JOHN JR") IS NOT AN INITIAL.*/
	replace mi_`src' = "" if inlist(lower(subinstr(word(strtrim(`v'), 2), ".", "", .)), "jr", "sr", "ii", "iii", "iv")
}

/*EACH LINK FILE'S OWN mi1930 AND mi1940.*/
merge 1:1 id_B using `"`intermediate'link1930_1940_ans_cleaned_noraceblock0.dta"', keepusing(mi1930 mi1940) keep(1 3) nogen
rename (mi1930 mi1940) (mi1930_old mi1940_old)
merge 1:1 id_B using `"`intermediate'link1930_1940_true_cleaned_noraceblock0.dta"', keepusing(mi1930 mi1940) keep(1 3) nogen
rename (mi1930 mi1940) (mi1930_new mi1940_new)

/*THE MOVING-VALIDATOR RATES THE DRAFT QUOTED UNTIL 2026-11-01, KEPT FOR    */
/*COMPARISON: EACH VERSION SCORED AGAINST ITS OWN FILE'S mi1940.             */
gen byte vb_own = mi1930_old==mi1940_old if mi1930_old!="" & mi1940_old!="" & linked_before==1
gen byte va_own = mi1930_new==mi1940_new if mi1930_new!="" & mi1940_new!="" & linked_after==1

/*STEP 1: WHICH SOURCE DOES EACH FILE'S mi1940 MATCH? (WHERE BOTH ARE NON-EMPTY)*/
foreach f in old new {
	foreach src in anc fs {
		quietly count if mi1940_`f'!="" & mi_`src'!=""
		local n = r(N)
		quietly count if mi1940_`f'!="" & mi_`src'!="" & mi1940_`f'==mi_`src'
		local k = r(N)
		display "mi1940_`f' vs mi_`src': agree " %6.4f `k'/`n' "  (N=`n')"
		local Src = proper("`src'")
		local F = proper("`f'")
		repnum agree`F'`Src' = 100*`k'/`n', format(%4.1f)
	}
}

/*STEP 2: RESCORE BOTH VERSIONS AGAINST ONE FIXED 1940 MIDDLE INITIAL.       */
/*mi1930 IS THE SAME IN BOTH FILES FOR THE SAME PARTNER, SO EACH VERSION USES */
/*ITS OWN FILE'S mi1930 (THE PARTNER'S) AND THE FIXED mi_src.                 */
gen byte status = 1 if linked_before==1 & linked_after==1 & id_A_before==id_A_after
replace status = 2 if linked_before==1 & linked_after==1 & id_A_before!=id_A_after
replace status = 3 if linked_before==0 & linked_after==1
replace status = 4 if linked_before==1 & linked_after==0

foreach smp in All Target {
	local c = cond("`smp'"=="Target", "& congruent==0", "")
	quietly summarize vb_own if 1 `c'
	local b = r(mean)
	quietly summarize va_own if 1 `c'
	local a = r(mean)
	display "own-file initials, `smp': before " %6.4f `b' "  after " %6.4f `a' "  change " %5.1f 100*(`a'/`b'-1) "%"
	repnum valGainOwn`smp' = 100*(`a'/`b'-1), format(%4.1f)
}

foreach src in anc fs {
	local Src = proper("`src'")
	gen byte vb_`src' = mi1930_old==mi_`src' if mi1930_old!="" & mi_`src'!="" & linked_before==1
	gen byte va_`src' = mi1930_new==mi_`src' if mi1930_new!="" & mi_`src'!="" & linked_after==1
	/*A KEPT LINK NOW HAS ONE VALIDATOR, SO IT CANNOT CHANGE.*/
	assert vb_`src'==va_`src' if status==1
	/*SINCE 2026-11-01 create_figures_SSHA2025.do SCORES BOTH VERSIONS WITH THE */
	/*ANCESTRY INITIAL, SO ITS STORED FLAGS MUST EQUAL THE anc RESCORE.         */
	/*A temp.dta BUILT BEFORE THAT CHANGE (E.G. UNDER -SkipRebuild) FAILS HERE */
	/*WITH A MESSAGE, NOT A BARE r(9).                                        */
	if "`src'"=="anc" {
		quietly count if vb_anc!=validated_before | va_anc!=validated_after
		if r(N) > 0 {
			display as error "temp.dta's validated_* flags are not the fixed-Ancestry-initial ones (" r(N) " records differ)."
			display as error "It predates the 2026-11-01 change to create_figures_SSHA2025.do: run a full rebuild, not -SkipRebuild."
			exit 9
		}
	}
	foreach smp in All Target {
		local c = cond("`smp'"=="Target", "& congruent==0", "")
		quietly summarize vb_`src' if 1 `c'
		local b = r(mean)
		local nb = r(N)
		quietly summarize va_`src' if 1 `c'
		local a = r(mean)
		local na = r(N)
		display "`src' `smp': before " %6.4f `b' " (N=`nb')  after " %6.4f `a' " (N=`na')  change " %5.1f 100*(`a'/`b'-1) "%"
		repnum valBefore`Src'`smp' = 100*`b', format(%4.1f)
		repnum valAfter`Src'`smp'  = 100*`a', format(%4.1f)
		repnum valGain`Src'`smp'   = 100*(`a'/`b'-1), format(%4.1f)
		repnum nMiBefore`Src'`smp' = `nb', format(%15.0fc)
		repnum nMiAfter`Src'`smp'  = `na', format(%15.0fc)
		/*BY LINK STATUS. A KEPT LINK HAS ONE VALUE (ASSERTED ABOVE).          */
		foreach spec in "1 Kept va" "2 SwitchedOld vb" "2 SwitchedNew va" "3 Added va" "4 Dropped vb" {
			tokenize `spec'
			quietly count if status==`1' `c'
			local nl = r(N)
			quietly summarize `3'_`src' if status==`1' `c'
			local m = r(mean)
			local nn = r(N)
			display "   `2': " %6.4f `m' " (with initials `nn' of `nl' links)"
			repnum val`2'`Src'`smp'   = 100*`m', format(%4.1f)
			repnum nMi`2'`Src'`smp'   = `nn', format(%15.0fc)
			repnum pctMi`2'`Src'`smp' = 100*`nn'/`nl', format(%4.1f)
		}
	}
}
repnum close
