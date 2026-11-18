/*WHERE DID THE NON-TARGET LINKS LOST UNDER TARGET-ONLY GO? (2026-11-18)     */
/*READ-ONLY EXCEPT FOR MATCHING/results/tgt_lost_links.md.                   */
/*                                                                           */
/*score_tgt_links.do: on 1940 non-target records, target-only ABE links       */
/*(link1930_1940_mltgt1940) number 10,238,786 against Old's (Ancestry names   */
/*everywhere) 10,363,116. A link "lost" here is an Old pair (1930 person A,   */
/*1940 non-target person B) absent from target-only. For each, what did       */
/*target-only do with A?                                                      */
/*  to_target   A linked to a 1940 target record                              */
/*  to_nontgt   A linked to a different 1940 non-target record                */
/*  to_outside  A linked to a 1940 record outside the 51.0M sample            */
/*  unlinked    A not linked at all (ABE dropped it: e.g. a tie between B and */
/*              a corrected record; this file cannot tell why)                */
/*and is B linked to someone else in target-only? Each Old pair and each new  */
/*pair is scored against the truth file as in score_tgt_links.do (two-sided   */
/*V/U/C). The reverse ("gained": target-only pairs on non-target records not  */
/*in Old) is classified the same way by A's Old partner.                      */
/*Same links, sample and truth as score_tgt_links.do; its non-target counts   */
/*are asserted.                                                               */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"

local links "$REP_SNU/enum_date/DATA/INTERMEDIATE"
local true_links "$REP_F/fixing_transcription_errors/DATA/INTERMEDIATE/mlp_training1930_1940.dta"
local sample_f   "$REP_SNU/fixing_transcription_errors/DATA/INTERMEDIATE/linkage_sample1940.dta"
local md "$REP_REPO/MATCHING/results/tgt_lost_links.md"
local f_old "`links'/link1930_1940_ans_cleaned_noraceblock0.dta"
local f_tgt "`links'/link1930_1940_mltgt1940_cleaned_noraceblock0.dta"

/*SAMPLE: histid -> target (1 target, 0 non-target); NOT IN FILE = OUTSIDE.*/
use histid target using `"`sample_f'"', clear
isid histid
tempfile samp
save `samp'

/*TRUTH, BOTH SIDES.*/
use `true_links', clear
keep histid1930 histid1940
duplicates drop histid1930 histid1940, force
assert _N==36690338
isid histid1930
isid histid1940
tempfile truth
save `truth'

/*PAIRS, AS score_tgt_links.do, WITH THE 1940 PERSON'S GROUP.*/
foreach v in old tgt {
	use id_A id_B fiveyr_band using `"`f_`v''"', clear
	keep if fiveyr_band == 1
	rename (id_A id_B) (histid1930 histid1940)
	keep histid1930 histid1940
	duplicates drop histid1930 histid1940, force
	rename histid1940 histid
	merge m:1 histid using `samp', keep(1 3) keepusing(target)
	gen byte grp = cond(_merge==1, 2, target)
	/*grp: 0 non-target, 1 target, 2 outside the sample*/
	drop _merge target
	rename histid histid1940
	/*TRUTH CLASS: 1 verified, 2 unverifiable, 3 contradicted (two-sided).*/
	rename histid1940 h40
	rename histid1930 h30
	preserve
		use `truth', clear
		rename (histid1930 histid1940) (h30 t40)
		tempfile by30
		save `by30'
		use `truth', clear
		rename (histid1930 histid1940) (t30 h40)
		tempfile by40
		save `by40'
	restore
	merge m:1 h30 using `by30', keep(1 3) gen(m30)
	merge m:1 h40 using `by40', keep(1 3) gen(m40)
	gen byte cls = 2 if m30==1 & m40==1
	replace cls = 1 if m40==3 & t30==h30
	replace cls = 3 if (m40==3 & t30!=h30) | (m40==1 & m30==3)
	assert !missing(cls)
	drop m30 m40 t30 t40
	rename (h30 h40) (histid1930 histid1940)
	quietly count if grp==0
	display "`v' pairs on non-target records: " r(N)
	if "`v'"=="old" assert r(N)==10363116
	if "`v'"=="tgt" assert r(N)==10238786
	tempfile p_`v'
	save `p_`v''
	/*ONE ROW PER 1930 PERSON AND PER 1940 PERSON (ABE LINKS ARE UNIQUE;   */
	/*ASSERTED).                                                           */
	isid histid1930
	isid histid1940
}

/*============================================================*/
/*LOST: OLD NON-TARGET PAIRS NOT IN TARGET-ONLY               */
/*============================================================*/
use `p_tgt', clear
rename (histid1940 grp cls) (n40 ngrp ncls)
tempfile tgt_by30
save `tgt_by30'
use `p_tgt', clear
keep histid1940
gen byte b_linked = 1
tempfile tgt_by40
save `tgt_by40'

use `p_old', clear
keep if grp==0
merge 1:1 histid1930 histid1940 using `p_tgt', keep(1 3) keepusing(histid1930) gen(still)
keep if still==1
drop still
local nlost = _N
merge 1:1 histid1930 using `tgt_by30', keep(1 3) gen(a_linked)
gen dest = "unlinked" if a_linked==1
replace dest = "to_target"  if a_linked==3 & ngrp==1
replace dest = "to_nontgt"  if a_linked==3 & ngrp==0
replace dest = "to_outside" if a_linked==3 & ngrp==2
assert dest!=""
merge 1:1 histid1940 using `tgt_by40', keep(1 3) nogen
replace b_linked = 0 if missing(b_linked)
tempfile lost
save `lost'

/*============================================================*/
/*GAINED: TARGET-ONLY NON-TARGET PAIRS NOT IN OLD             */
/*============================================================*/
use `p_old', clear
rename (histid1940 grp cls) (o40 ogrp ocls)
tempfile old_by30
save `old_by30'
use `p_tgt', clear
keep if grp==0
merge 1:1 histid1930 histid1940 using `p_old', keep(1 3) keepusing(histid1930) gen(was)
keep if was==1
drop was
local ngain = _N
merge 1:1 histid1930 using `old_by30', keep(1 3) gen(a_old)
gen src = "new_1930_person" if a_old==1
replace src = "from_target"  if a_old==3 & ogrp==1
replace src = "from_nontgt"  if a_old==3 & ogrp==0
replace src = "from_outside" if a_old==3 & ogrp==2
assert src!=""
tempfile gain
save `gain'
display "lost " `nlost' ", gained " `ngain' ", net " `ngain'-`nlost'
assert `ngain' - `nlost' == 10238786 - 10363116

/*============================================================*/
/*OUTPUT                                                      */
/*============================================================*/
file open md using `"`md'"', write replace text
file write md "# Non-target links lost and gained under target-only" _n _n
file write md "Written by MATCHING/tgt_lost_links.do. 1940 non-target records; ABE exact, fiveyr_band==1. Old = Ancestry names everywhere; target-only = model names on target records only. V/U/C two-sided against the FamilySearch-profile sample." _n _n
file write md "Lost (Old pair not in target-only): " %12.0fc (`nlost') "; gained (target-only pair not in Old): " %12.0fc (`ngain') "; net " %12.0fc (`ngain'-`nlost') "." _n _n

use `lost', clear
file write md "## Lost links, by what target-only did with the 1930 person" _n _n
file write md "| Where the 1930 person went | Links | Old link verified | Old link unverifiable | Old link contradicted | New link verified | New link unverifiable | New link contradicted | Old 1940 partner relinked |" _n
file write md "|---|---:|---:|---:|---:|---:|---:|---:|---:|" _n
foreach d in to_target to_nontgt to_outside unlinked {
	quietly count if dest=="`d'"
	file write md "| `d' | " %12.0fc (r(N))
	forvalues k=1/3 {
		quietly count if dest=="`d'" & cls==`k'
		file write md " | " %12.0fc (r(N))
	}
	forvalues k=1/3 {
		if "`d'"=="unlinked" file write md " | --"
		else {
			quietly count if dest=="`d'" & ncls==`k'
			file write md " | " %12.0fc (r(N))
		}
	}
	quietly count if dest=="`d'" & b_linked==1
	file write md " | " %12.0fc (r(N)) " |" _n
}
tab dest cls
tab dest ncls

use `gain', clear
file write md _n "## Gained links, by the 1930 person's Old partner" _n _n
file write md "| Old partner of the 1930 person | Links | New link verified | New link unverifiable | New link contradicted |" _n
file write md "|---|---:|---:|---:|---:|" _n
foreach d in new_1930_person from_target from_nontgt from_outside {
	quietly count if src=="`d'"
	file write md "| `d' | " %12.0fc (r(N))
	forvalues k=1/3 {
		quietly count if src=="`d'" & cls==`k'
		file write md " | " %12.0fc (r(N))
	}
	file write md " |" _n
}
tab src cls
file close md
display "wrote `md'"
