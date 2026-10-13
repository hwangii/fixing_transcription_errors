/*REPLACEMENT FOR DHTS-2026-10-12.tex LINES 281-285, COVERING THE 48          */
/*CONTIGUOUS STATES AND DC -- 49 JURISDICTIONS, NOT 50 STATES. SEE THE NOTE   */
/*ON COVERAGE BELOW; DO NOT DESCRIBE THIS OUTPUT AS "ALL STATES".             */
/*  "For records where human transcribers disagree, our model's transcription */
/*   matches one of the two human transcriptions in 58% of cases... agrees    */
/*   with Ancestry in 11%... FamilySearch in 47%... neither in 42%."          */
/*                                                                            */
/*THOSE ARE RHODE-ISLAND-ERA AND CONDITIONAL ON DISAGREEMENT, WHICH THE       */
/*EARLIER ALL-STATES PASS DID NOT COMPUTE (IT WAS UNCONDITIONAL).             */
/*                                                                            */
/*READ-ONLY. TOUCHES NO PROJECT FILE AND WRITES NO .dta.                      */
/*                                                                            */
/*COMPUTES THREE VARIANTS. THE PAPER USES HUMAN-COMPLETE; THE OTHER TWO ARE   */
/*KEPT SO THE DIFFERENCE BETWEEN THEM STAYS VISIBLE AND AUDITABLE.            */
/*                                                                            */
/*  AS-CODED -- matches comparing_model_transcription_with_anc_fs_SSHA2025.do */
/*              exactly. WRONG IN TWO WAYS: it counts a blank-to-blank field  */
/*              comparison as agreement (Stata scores ""=="" as true, about   */
/*              0.004% of the denominator), and it files records with no model */
/*              output under "matches neither", which misdescribes them.      */
/*  STRICT   -- all six fields non-empty. FIXES THE BLANK ISSUE BUT INTRODUCES */
/*              A WORSE ONE: requiring the model fields to be non-empty        */
/*              conditions the denominator on the model having succeeded, so   */
/*              it scores the model only on records it managed to transcribe.  */
/*              That is survivorship selection and overstates performance.     */
/*  HUMAN-COMPLETE -- all four HUMAN fields non-empty, model output NOT        */
/*              required. "Incomplete model output" becomes its own category,  */
/*              so the four cells partition the denominator exactly and        */
/*              nothing is silently dropped in either direction. THIS IS THE   */
/*              ONE THE DRAFT QUOTES.                                          */
/*                                                                            */
/*THE AS-CODED/STRICT DISTINCTION CAME FROM A CODEX REVIEW AND THE SELECTION   */
/*PROBLEM IN STRICT FROM AN ANTIGRAVITY REVIEW; THE TWO BRACKETED THE RIGHT    */
/*ANSWER FROM OPPOSITE SIDES. SEE review/reports/2026-10-12_*.                 */
/*                                                                            */
/*FORWARD SLASHES THROUGHOUT: A LOCAL ENDING IN "\" FOLLOWED BY A MACRO       */
/*REFERENCE SILENTLY FAILS, BECAUSE STATA READS \` AS "DO NOT EXPAND".        */
/*FULL PATHS RATHER THAN cd, SO A BAD STATE CANNOT SHIFT THE WORKING DIR.     */

clear all
set more off

local christian_torben "D:/SNU ECON Dropbox/sam hwang/fixing_transcription_errors/DATA/TRANSCRIPTIONS"
local root "`christian_torben'/USCensus1940FullCount/output_and_output1_ssha2025"
local out  "D:/SNU ECON Dropbox/sam hwang/fixing_transcription_errors/DATA/INTERMEDIATE"

/*hi IS EXCLUDED: ITS merged_data.dta HAS NO ANCESTRY/FAMILYSEARCH COLUMNS.  */
/*ak IS EXCLUDED TO MATCH THE PRODUCTION SCRIPT'S 49-STATE UNIVERSE.          */
local states "al ar az ca co ct dc de fl ga ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy"

foreach v in disc anc fs nei disc_s anc_s fs_s nei_s both both_s disc_h anc_h fs_h nei_h nom_h {
	local T`v'=0
}
local nok=0

capture file close csv
file open csv using `"`out'/model_vs_human_discordant.csv"', write replace text
file write csv "state,disc_ascoded,anc_ascoded,fs_ascoded,both_ascoded,nei_ascoded,disc_strict,anc_strict,fs_strict,both_strict,nei_strict,disc_hcomplete,anc_hcomplete,fs_hcomplete,nei_hcomplete,nomodel_hcomplete" _n

foreach s in `states' {

	capture use namefrst fs_namefrst namefrst_ml namelast fs_namelast namelast_ml_ditto using `"`root'/`s'/merged_data.dta"', clear
	if _rc {
		display as error "COULD NOT READ `s' (rc=" _rc ")"
		continue
	}
	local nok=`nok'+1

	/*THE DISCORDANT UNIVERSE, ON THE SAME DENOMINATOR THE SCRIPT USES AND   */
	/*WITH THE SAME NAME-BASED CONGRUENCY DEFINITION AS THE PAPER'S EXHIBITS */
	/*(BOTH NAME FIELDS EQUAL). NOTE THE DRAFT'S PROSE ALSO MENTIONS age;    */
	/*THE EXHIBITS DO NOT USE IT, SO NEITHER DOES THIS.                      */
	quietly count if (namefrst!=""|namelast!="") & (fs_namefrst!=""|fs_namelast!="") & !(namefrst==fs_namefrst & namelast==fs_namelast)
	local disc=r(N)

	quietly count if (namefrst!=""|namelast!="") & (fs_namefrst!=""|fs_namelast!="") & !(namefrst==fs_namefrst & namelast==fs_namelast) & namefrst==namefrst_ml & namelast==namelast_ml_ditto & !(fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto)
	local anc=r(N)

	quietly count if (namefrst!=""|namelast!="") & (fs_namefrst!=""|fs_namelast!="") & !(namefrst==fs_namefrst & namelast==fs_namelast) & fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto & !(namefrst==namefrst_ml & namelast==namelast_ml_ditto)
	local fs=r(N)

	/*SHOULD BE ~0 BY CONSTRUCTION: IF THE HUMANS DIFFER ON A FIELD THE MODEL*/
	/*CANNOT EQUAL BOTH ON EVERY FIELD. ANY NON-ZERO COUNT HERE IS A VACUOUS */
	/*""=="" MATCH, SO IT IS WORTH REPORTING RATHER THAN ASSUMING.           */
	quietly count if (namefrst!=""|namelast!="") & (fs_namefrst!=""|fs_namelast!="") & !(namefrst==fs_namefrst & namelast==fs_namelast) & fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto & namefrst==namefrst_ml & namelast==namelast_ml_ditto
	local both=r(N)

	quietly count if (namefrst!=""|namelast!="") & (fs_namefrst!=""|fs_namelast!="") & !(namefrst==fs_namefrst & namelast==fs_namelast) & !(fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto) & !(namefrst==namefrst_ml & namelast==namelast_ml_ditto)
	local nei=r(N)

	/*STRICT: ALL SIX FIELDS NON-EMPTY*/
	local S "namefrst!=\"\" & namelast!=\"\" & fs_namefrst!=\"\" & fs_namelast!=\"\" & namefrst_ml!=\"\" & namelast_ml_ditto!=\"\""

	quietly count if namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="" & namefrst_ml!="" & namelast_ml_ditto!="" & !(namefrst==fs_namefrst & namelast==fs_namelast)
	local disc_s=r(N)

	quietly count if namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="" & namefrst_ml!="" & namelast_ml_ditto!="" & !(namefrst==fs_namefrst & namelast==fs_namelast) & namefrst==namefrst_ml & namelast==namelast_ml_ditto & !(fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto)
	local anc_s=r(N)

	quietly count if namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="" & namefrst_ml!="" & namelast_ml_ditto!="" & !(namefrst==fs_namefrst & namelast==fs_namelast) & fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto & !(namefrst==namefrst_ml & namelast==namelast_ml_ditto)
	local fs_s=r(N)

	quietly count if namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="" & namefrst_ml!="" & namelast_ml_ditto!="" & !(namefrst==fs_namefrst & namelast==fs_namelast) & fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto & namefrst==namefrst_ml & namelast==namelast_ml_ditto
	local both_s=r(N)

	quietly count if namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="" & namefrst_ml!="" & namelast_ml_ditto!="" & !(namefrst==fs_namefrst & namelast==fs_namelast) & !(fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto) & !(namefrst==namefrst_ml & namelast==namelast_ml_ditto)
	local nei_s=r(N)

	/*HUMAN-COMPLETE: THE VARIANT THE PAPER SHOULD USE.                      */
	/*DENOMINATOR IS EVERY DISCORDANT RECORD WITH ALL FOUR HUMAN NAME FIELDS */
	/*PRESENT. IT DOES *NOT* REQUIRE THE MODEL TO HAVE PRODUCED ANYTHING --  */
	/*CONDITIONING ON THAT WOULD EVALUATE THE MODEL ONLY ON RECORDS IT       */
	/*MANAGED TO TRANSCRIBE, WHICH IS SURVIVORSHIP SELECTION AND OVERSTATES  */
	/*PERFORMANCE. INSTEAD "INCOMPLETE MODEL OUTPUT" IS ITS OWN CATEGORY, SO */
	/*THE FOUR CELLS PARTITION THE DENOMINATOR EXACTLY.                      */
	quietly count if namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="" & !(namefrst==fs_namefrst & namelast==fs_namelast)
	local disc_h=r(N)

	quietly count if namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="" & !(namefrst==fs_namefrst & namelast==fs_namelast) & namefrst_ml!="" & namelast_ml_ditto!="" & namefrst==namefrst_ml & namelast==namelast_ml_ditto & !(fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto)
	local anc_h=r(N)

	quietly count if namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="" & !(namefrst==fs_namefrst & namelast==fs_namelast) & namefrst_ml!="" & namelast_ml_ditto!="" & fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto & !(namefrst==namefrst_ml & namelast==namelast_ml_ditto)
	local fs_h=r(N)

	quietly count if namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="" & !(namefrst==fs_namefrst & namelast==fs_namelast) & namefrst_ml!="" & namelast_ml_ditto!="" & !(fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto) & !(namefrst==namefrst_ml & namelast==namelast_ml_ditto)
	local nei_h=r(N)

	/*MODEL RETURNED NOTHING, OR ONLY ONE OF THE TWO NAME FIELDS.*/
	quietly count if namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="" & !(namefrst==fs_namefrst & namelast==fs_namelast) & !(namefrst_ml!="" & namelast_ml_ditto!="")
	local nom_h=r(N)

	/*THE PARTITION MUST BE EXACT. IF IT IS NOT, A CATEGORY DEFINITION IS    */
	/*WRONG AND NO NUMBER FROM THIS RUN SHOULD REACH THE PAPER.              */
	if `anc_h'+`fs_h'+`nei_h'+`nom_h'!=`disc_h' {
		display as error "PARTITION FAILED in `s': `anc_h'+`fs_h'+`nei_h'+`nom_h' != `disc_h'"
		exit 459
	}

	file write csv "`s',`disc',`anc',`fs',`both',`nei',`disc_s',`anc_s',`fs_s',`both_s',`nei_s',`disc_h',`anc_h',`fs_h',`nei_h',`nom_h'" _n

	foreach v in disc anc fs nei both disc_s anc_s fs_s nei_s both_s disc_h anc_h fs_h nei_h nom_h {
		local T`v'=`T`v''+``v''
	}

	display "DONE `s': discordant=`disc'  anc=`anc' fs=`fs' nei=`nei'"
}

/*COMPLETENESS ASSERTION. THE capture ABOVE KEEPS ONE BAD STATE FROM KILLING  */
/*THE RUN, BUT WITHOUT THIS THE TOTALS AND THE CSV WOULD STILL BE WRITTEN AND */
/*WOULD LOOK LIKE A FULL PASS. FAIL LOUDLY INSTEAD: A PARTIAL AGGREGATE THAT  */
/*REACHES THE PAPER IS EXACTLY THE FAILURE THE HAWAII BUG ALREADY CAUSED ONCE.*/
local nexpected : word count `states'
if `nok'!=`nexpected' {
	file close csv
	capture erase `"`out'/model_vs_human_discordant.csv"'
	display as error "INCOMPLETE RUN: `nok' of `nexpected' states contributed."
	display as error "No totals written. Fix the failing state(s) and rerun."
	exit 459
}

file write csv "TOTAL,`Tdisc',`Tanc',`Tfs',`Tboth',`Tnei',`Tdisc_s',`Tanc_s',`Tfs_s',`Tboth_s',`Tnei_s',`Tdisc_h',`Tanc_h',`Tfs_h',`Tnei_h',`Tnom_h'" _n
file close csv

display ""
display "================ `nok' STATES ================"
display ""
display "---- AS-CODED (no-model-output counts as 'neither') ----"
display "discordant records      : `Tdisc'"
if `Tdisc'>0 {
	display "matches Ancestry only   : `Tanc'  (" %4.1f 100*`Tanc'/`Tdisc' "%)"
	display "matches FamilySearch only: `Tfs'  (" %4.1f 100*`Tfs'/`Tdisc' "%)"
	display "matches both (vacuous)  : `Tboth'  (" %4.1f 100*`Tboth'/`Tdisc' "%)"
	display "matches neither         : `Tnei'  (" %4.1f 100*`Tnei'/`Tdisc' "%)"
	display "matches ONE OF THE TWO  : " %4.1f 100*(`Tanc'+`Tfs')/`Tdisc' "%"
}
display ""
display "---- STRICT (all six name fields non-empty) ----"
display "discordant records      : `Tdisc_s'"
if `Tdisc_s'>0 {
	display "matches Ancestry only   : `Tanc_s'  (" %4.1f 100*`Tanc_s'/`Tdisc_s' "%)"
	display "matches FamilySearch only: `Tfs_s'  (" %4.1f 100*`Tfs_s'/`Tdisc_s' "%)"
	display "matches both (vacuous)  : `Tboth_s'  (" %4.1f 100*`Tboth_s'/`Tdisc_s' "%)"
	display "matches neither         : `Tnei_s'  (" %4.1f 100*`Tnei_s'/`Tdisc_s' "%)"
	display "matches ONE OF THE TWO  : " %4.1f 100*(`Tanc_s'+`Tfs_s')/`Tdisc_s' "%"
}
display "=============================================="
