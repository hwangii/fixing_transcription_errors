/*MIDDLE-INITIAL VALIDATION BY LINK STATUS (2026-11-01).                     */
/*                                                                           */
/*The draft's "share validated rises from 65% to 84%" (lines 98, 548) compares*/
/*all links made with the old names with all links made with ours. Codex     */
/*(review 2026-11-01_180159, finding 2) noted that this does not show the     */
/*links our transcriptions ADD are good ones. This splits every record in the */
/*analysis file by what happened to its link:                                 */
/*  kept     linked before and after, to the same 1930 record                 */
/*  switched linked before and after, to a different 1930 record              */
/*  added    linked only after                                                */
/*  dropped  linked only before                                               */
/*and reports the share whose middle initials agree, among links with an     */
/*initial in both censuses, for each group: all records and the target group */
/*(incongruent transcriptions).                                               */
/*                                                                           */
/*READ-ONLY on temp.dta, the analysis file create_figures_SSHA2025.do writes. */

clear all
set more off

if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
repnum open using "$REP_RESULTS/validation_by_link_status.tex", script(replication/diagnostics/validation_by_link_status.do)

use congruent linked_before linked_after id_A_before id_A_after validated_before validated_after using `"$REP_SNU/enum_date/DATA/INTERMEDIATE/temp.dta"', clear
display "records: " _N

gen byte status = .
replace status = 1 if linked_before==1 & linked_after==1 & id_A_before==id_A_after
replace status = 2 if linked_before==1 & linked_after==1 & id_A_before!=id_A_after
replace status = 3 if linked_before==0 & linked_after==1
replace status = 4 if linked_before==1 & linked_after==0
label define status 1 "kept" 2 "switched" 3 "added" 4 "dropped"
label values status status

/*A KEPT LINK PAIRS THE SAME TWO RECORDS, BUT EACH LINK FILE CARRIES ITS OWN */
/*mi1930/mi1940, SO ITS VALIDATION CAN STILL DIFFER BEFORE AND AFTER. COUNT IT.*/
quietly count if status==1
local nk = r(N)
quietly count if status==1 & validated_before!=validated_after
local nkd = r(N)
quietly count if status==1 & validated_before==. & validated_after<.
local nkgain = r(N)
quietly count if status==1 & validated_before<. & validated_after==.
local nkloss = r(N)
quietly count if status==1 & validated_before<. & validated_after<. & validated_before!=validated_after
local nkflip = r(N)
display "kept links: `nk'; validation differs: `nkd' (MI newly available `nkgain', no longer available `nkloss', agreement flips `nkflip')"
repnum nKeptTotal = `nk', format(%15.0fc)
repnum nKeptValDiffers = `nkd', format(%15.0fc)
repnum nKeptMiGained = `nkgain', format(%15.0fc)
repnum nKeptMiLost = `nkloss', format(%15.0fc)
repnum nKeptValFlips = `nkflip', format(%15.0fc)

tab status, missing
tab status if congruent==0, missing

/*THE VALIDATION OF A GROUP IS THAT OF THE LINK IT HAS: THE NEW ONE FOR KEPT, */
/*SWITCHED (AFTER) AND ADDED; THE OLD ONE FOR DROPPED AND SWITCHED (BEFORE).  */
foreach smp in All Target {
	local c = cond("`smp'"=="Target", "& congruent==0", "")
	foreach spec in "1 KeptOld validated_before" "1 Kept validated_after" "2 SwitchedNew validated_after" "2 SwitchedOld validated_before" "3 Added validated_after" "4 Dropped validated_before" {
		tokenize `spec'
		quietly count if status==`1' `c'
		local nlinks = r(N)
		quietly summarize `3' if status==`1' `c'
		local m = r(mean)
		local nmi = r(N)
		display "`smp' `2': links " %12.0fc `nlinks' "  with MI " %12.0fc `nmi' "  validated " %6.4f `m'
		/*THE SHARE IS OVER LINKS WITH A MIDDLE INITIAL IN BOTH CENSUSES ONLY, */
		/*SO THAT COUNT AND ITS SHARE OF ALL LINKS ARE WRITTEN TOO.            */
		repnum val`2'`smp'    = 100*`m', format(%4.1f)
		repnum n`2'`smp'      = `nlinks', format(%15.0fc)
		repnum nMi`2'`smp'    = `nmi', format(%15.0fc)
		repnum pctMi`2'`smp'  = 100*`nmi'/`nlinks', format(%4.1f)
	}
	/*THE TWO OVERALL SHARES THE DRAFT QUOTES, FOR RECONCILIATION.*/
	quietly summarize validated_before if 1 `c'
	local vb = r(mean)
	quietly summarize validated_after if 1 `c'
	local va = r(mean)
	repnum valBefore`smp' = 100*`vb', format(%4.1f)
	repnum valAfter`smp'  = 100*`va', format(%4.1f)
}
repnum close
