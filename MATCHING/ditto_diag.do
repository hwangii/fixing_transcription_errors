/*DITTO SURNAMES: DO THEY EXPLAIN (a) THE UNUSABLE MODEL OUTPUT ON TARGET      */
/*RECORDS AND (b) THE LOST GAIN WHEN NON-TARGET NAMES ARE REPLACED? (2026-11-22)*/
/*                                                                            */
/*FACTS FROM wy/merged_data.dta (scratch inspection, 2026-11-21): one filename  */
/*= one 40-line half sheet, filename "m-t0627-<roll>-<image>.jpg", row 1-40,  */
/*linep = row or row+40. The model's namelast_ml_ditto carries the surname of */
/*the nearest model non-ditto line above (the chain head) down a ditto chain, */
/*ACROSS image boundaries within a roll (wy: 1,919 of 2,013 row-1 dittos     */
/*carry the previous image's last resolved surname; the other 94 are empty   */
/*because that was empty). In wy, every empty ditto surname sits under a head */
/*whose own model surname is empty (4,575 heads), at every row of the image.  */
/*So the model's carry is not the problem; the head is unreadable. Carrying   */
/*the head's HUMAN surname, where Ancestry and FamilySearch agree on it, can  */
/*fill such rows (the head-human fill).                                       */
/*                                                                            */
/*THE LINKING BASELINE (1_divide_and_clean_everyoneV5_women_addedV2.do:169-  */
/*170): AN EMPTY MODEL FIELD FALLS BACK TO THE RECORD'S OWN ANCESTRY VALUE.   */
/*EVERY "FILL" BELOW IS SCORED AGAINST THAT BASELINE, NOT AGAINST BLANK       */
/*(2026-11-22 REVIEW). ON A NON-TARGET RECORD THE BASELINE ALREADY EQUALS THE */
/*AGREED HUMAN SURNAME, SO A FILL CAN ONLY MOVE IT OUT OF AGREEMENT.          */
/*                                                                            */
/*THE SENTINEL "InvalidPred" (2026-11-22 REVIEW): THE MODEL FILES CARRY THAT   */
/*LITERAL IN namefrst_ml AND, THROUGH THE HEAD, IN namelast_ml_ditto. IT IS   */
/*COUNTED RAW IN SECTION 4 AND TREATED AS EMPTY EVERYWHERE ELSE. THE PAPER'S */
/*NO-OUTPUT GATE IS ON THE RAW (==""), SENTINEL-BLIND DEFINITION, AS IN       */
/*compute_model_agreement_on_discordant.do; THE SENTINEL-AWARE SHARE IS ALSO  */
/*REPORTED. THE LINKING CODE IS SENTINEL-BLIND TOO (IT WOULD LINK ON          */
/*"invalidpred"), WHICH IS A SEPARATE BUG TO FIX THERE.                      */
/*                                                                            */
/*THIS SCRIPT MEASURES, ON THE 49 MODEL STATES:                               */
/*  0. Chain structure: why a ditto surname is empty (head with no model     */
/*     surname / on a later image than a head that has one, which the model  */
/*     is expected to have carried, so ~0 / other: link break, missing flag). */
/*  1. Target records with an empty model-ditto surname: whether the record's*/
/*     own humans agree on the surname (then the baseline fallback is         */
/*     uncontroversial), and where they differ, whether the head's agreed    */
/*     human surname sides with Ancestry (= baseline), FamilySearch (changes  */
/*     the linked name) or neither.                                           */
/*  2. The target-record "no usable output" share: raw, sentinel-aware, after */
/*     the head-human fill.                                                   */
/*  3. NON-TARGET records: how often the model name, where present, differs  */
/*     from the agreed name, by field and by model ditto flag (that is the   */
/*     erosion when non-target names are replaced); for differing ditto      */
/*     surnames, a proxy split: the row shares its chain head's human        */
/*     surname (the head was misread), the human surname changes at this row */
/*     (a surname change the model missed), or it is unchanged from the line */
/*     above but differs from the head's (below a missed change); and what a */
/*     household-consistency                                                  */
/*     rule (surname := the head's agreed human surname) would do relative   */
/*     to the baseline: rows moved into agreement, rows moved out.            */
/*  4. The literal "InvalidPred" in the raw fields.                           */
/*ALL LABELS ARE AGREEMENT WITH THE TWO HUMAN TRANSCRIPTIONS, NOT TRUTH. THE  */
/*EXTERNAL REFERENCE IS THE FAMILYSEARCH-PROFILE COMPARISON                   */
/*(profile_names_jw.do), ITSELF A SELECTED SAMPLE. NAMES ARE COMPARED AS RAW  */
/*STRINGS, BEFORE abeclean; A RAW DIFFERENCE NEED NOT SURVIVE CLEANING, SO    */
/*THE NON-TARGET "EROSION" HERE IS AN UPPER BOUND ON THE LINKED-NAME CHANGE.  */
/*THE LINKAGE-LEVEL TEST IS THE ABE RERUN (tgt_linkage_abe.md). THE BASELINE  */
/*BELOW IS THE SENTINEL-AWARE PIPELINE; THE ACTUAL PIPELINE LINKS ON          */
/*"invalidpred" FOR THE SENTINEL ROWS (COUNTED IN SECTION 2).                 */
/*                                                                            */
/*UNIVERSES (as compute_model_agreement_on_discordant.do, HUMAN-COMPLETE):    */
/*  HC: all four human name fields non-empty.                                 */
/*  TGT: HC and Ancestry != FamilySearch on first or last name (35,094,490).  */
/*  NT:  HC and Ancestry == FamilySearch on both.                             */
/*CHECK: TGT count and the raw no-output share reproduce                      */
/*replication/results/compute_model_agreement_on_discordant.tex.              */
/*READ-ONLY EXCEPT FOR MATCHING/results/ditto_diag.md.                        */
/*  powershell -File replication/Run-Stata.ps1 MATCHING/ditto_diag.do          */
/*SMOKE TEST: a scratch copy with local states "wy", k==1, the two paper      */
/*gates replaced by displays, and the output renamed *_SMOKE.md. Never commit */
/*that output.                                                                */

clear all
set more off
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local root "$REP_SNU/fixing_transcription_errors/DATA/TRANSCRIPTIONS/USCensus1940FullCount/output_and_output1_ssha2025"
local md   "$REP_REPO/MATCHING/results/ditto_diag.md"
local states "al ar az ca co ct dc de fl ga ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy"

/*THE COUNTERS. EACH IS A BYTE INDICATOR PER RECORD, SUMMED PER STATE INTO A   */
/*DOUBLE (summarize's r(sum)), THEN SUMMED ACROSS STATES. BYTES, BECAUSE NEW   */
/*YORK HAS ~13M ROWS AND DOUBLES WOULD NEED GIGABYTES.                        */
local vars "n parse_ok img40 dup link hc tgt nt d nd head head_le head_le_fe de de_headempty de_headempty_frst de_headcross de_headother dh tgt_de tgt_de_own_agree tgt_de_own_diff tgt_de_own_diff_h tgt_de_own_diff_h_anc tgt_de_own_diff_h_fs tgt_de_own_diff_h_nei tgt_de_own_agree_h tgt_de_own_agree_h_diff fail_raw fail_pre fail_h tgt_frst_e tgt_last_e_pre tgt_last_e_h nt_d nt_nd nt_dm nt_f_e nt_f_w nt_d_l_e nt_d_l_w nt_nd_l_e nt_nd_l_w nt_diff nt_dw_head nt_dw_chg nt_dw_below nt_dw_unk nt_d_hagree nt_d_in nt_d_out ip_f ip_l ip_ld nd_ip tgt_ip"

local k 0
foreach s of local states {
	use filename row non_ditto_ml namefrst fs_namefrst namefrst_ml namelast fs_namelast namelast_ml namelast_ml_ditto using `"`root'/`s'/merged_data.dta"', clear

	/*IMAGE ORDER. ROLL AND IMAGE FROM THE FILENAME; A FILENAME THAT DOES NOT  */
	/*PARSE (INCLUDING "") GETS MISSING AND CAN NEITHER GIVE NOR TAKE A CARRY. */
	/*regexs() MUST SIT IN THE SAME EXPRESSION AS ITS regexm().                */
	gen double roll  = real(regexs(1)) if regexm(filename, "^m-t0627-([0-9]+)-([0-9]+)\.jpg$")
	gen double image = real(regexs(2)) if regexm(filename, "^m-t0627-([0-9]+)-([0-9]+)\.jpg$")
	gen byte parse_ok = !missing(roll) & !missing(image)
	bysort roll image: gen long img_n = _N
	gen byte img40 = parse_ok & img_n==40
	bysort roll image row: gen byte dup = parse_ok & _N>1
	drop img_n
	sort roll image row, stable

	/*THE SENTINEL, COUNTED RAW, THEN TREATED AS EMPTY: namefrst_u, namelast_u */
	/*ARE THE USABLE MODEL FIELDS.                                             */
	gen byte ip_f  = namefrst_ml=="InvalidPred"
	gen byte ip_l  = namelast_ml=="InvalidPred"
	gen byte ip_ld = namelast_ml_ditto=="InvalidPred"
	gen byte nd_ip = non_ditto_ml==1 & ip_l
	gen namefrst_u = cond(ip_f, "", namefrst_ml)
	gen namelast_u = cond(ip_ld, "", namelast_ml_ditto)

	/*link = the previous observation is the line above on the schedule: same */
	/*image and the previous row, or row 40 of the previous image of the same */
	/*roll feeding row 1. A DUPLICATE filename-row (DROPPED BY THE LINKING     */
	/*CODE) NEITHER GIVES NOR TAKES A LINK (2026-11-22 REVIEW).               */
	gen byte link = parse_ok & !dup & !dup[_n-1] & roll==roll[_n-1] & ((image==image[_n-1] & row==row[_n-1]+1) | (image==image[_n-1]+1 & row==1 & row[_n-1]==40))
	gen byte d  = non_ditto_ml==0
	gen byte nd = non_ditto_ml==1
	gen byte de = d & namelast_u==""

	/*CHAINS. A ROW CONTINUES THE CHAIN ABOVE IF IT IS A MODEL DITTO AND LINKED;*/
	/*OTHERWISE IT HEADS A NEW CHAIN (A MODEL NON-DITTO, A ROW WITH A MISSING  */
	/*FLAG, OR A LINK BREAK). A ROW-1 MODEL DITTO CONTINUES THE PREVIOUS       */
	/*IMAGE'S CHAIN, AS THE MODEL'S OWN RESOLUTION DOES (wy CHECK, 2026-11-22). */
	/*THE HEAD'S VALUES ARE SPREAD DOWN ITS CHAIN. ROW ORDER IS PRESERVED:     */
	/*chain IS NONDECREASING AND THE SORT IS STABLE.                           */
	gen byte head = !(d & link)
	gen double chain = sum(head)
	sort chain, stable
	by chain: gen byte head_cross = image!=image[1]        /*THE ROW IS ON A LATER IMAGE THAN ITS HEAD*/
	by chain: gen head_ld  = namelast_u[1]
	by chain: gen head_anc = namelast[1]
	by chain: gen head_fs  = fs_namelast[1]
	by chain: gen byte head_nd = nd[1]
	by chain: gen byte head_fe = namefrst_u[1]==""
	gen byte head_agree = head_nd & head_anc!="" & head_anc==head_fs
	gen byte head_le = head & nd & namelast_u==""   /*A NON-DITTO HEAD WITH NO USABLE MODEL SURNAME*/
	gen byte head_le_fe = head_le & namefrst_u==""  /*... AND NO USABLE MODEL FIRST NAME EITHER*/

	/*0. WHY IS A DITTO SURNAME EMPTY? UNDER A NON-DITTO HEAD WITH AN EMPTY    */
	/*MODEL SURNAME; OR ON A LATER IMAGE THAN A HEAD THAT HAS ONE (THE MODEL  */
	/*CARRIES ACROSS IMAGES, SO THIS SHOULD BE ~0); OR OTHER (HEAD IS A LINK  */
	/*BREAK OR A MISSING FLAG).                                               */
	gen byte de_headempty = de & head_nd & head_ld==""
	gen byte de_headempty_frst = de_headempty & head_fe
	gen byte de_headcross = de & head_nd & head_ld!="" & head_cross
	gen byte de_headother = de & !de_headempty & !de_headcross

	/*THE HEAD-HUMAN FILL: THE HEAD'S AGREED HUMAN SURNAME.                   */
	gen namelast_h = namelast_u
	replace namelast_h = head_anc if de & head_agree
	gen byte dh = de & namelast_h!=""

	/*UNIVERSES.*/
	gen byte hc  = namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!=""
	gen byte tgt = hc & !(namefrst==fs_namefrst & namelast==fs_namelast)
	gen byte nt  = hc & namefrst==fs_namefrst & namelast==fs_namelast

	/*1. TARGET RECORDS WITH AN EMPTY MODEL-DITTO SURNAME, AGAINST THE LINKING */
	/*BASELINE (THE RECORD'S OWN ANCESTRY SURNAME). WHERE THE RECORD'S OWN     */
	/*HUMANS AGREE, THE BASELINE IS UNCONTROVERSIAL AND A FILL THAT DIFFERS    */
	/*FROM IT IS A LOSS; WHERE THEY DIFFER, THE HEAD-HUMAN FILL ARBITRATES:   */
	/*= ANCESTRY LEAVES THE LINKED NAME AS IT IS, = FAMILYSEARCH CHANGES IT.  */
	gen byte tgt_de = tgt & de
	gen byte tgt_de_own_agree = tgt_de & namelast==fs_namelast
	gen byte tgt_de_own_diff  = tgt_de & namelast!=fs_namelast
	gen byte tgt_de_own_diff_h     = tgt_de_own_diff & dh
	gen byte tgt_de_own_diff_h_anc = tgt_de_own_diff_h & namelast_h==namelast
	gen byte tgt_de_own_diff_h_fs  = tgt_de_own_diff_h & namelast_h==fs_namelast
	gen byte tgt_de_own_diff_h_nei = tgt_de_own_diff_h & namelast_h!=namelast & namelast_h!=fs_namelast
	gen byte tgt_de_own_agree_h      = tgt_de_own_agree & dh
	gen byte tgt_de_own_agree_h_diff = tgt_de_own_agree_h & namelast_h!=namelast

	/*2. NO USABLE OUTPUT ON TARGET RECORDS. fail_raw IS THE PAPER'S           */
	/*SENTINEL-BLIND DEFINITION (THE GATE); fail_pre IS SENTINEL-AWARE.       */
	gen byte fail_raw = tgt & !(namefrst_ml!="" & namelast_ml_ditto!="")
	gen byte fail_pre = tgt & !(namefrst_u!="" & namelast_u!="")
	gen byte fail_h   = tgt & !(namefrst_u!="" & namelast_h!="")
	gen byte tgt_frst_e = tgt & namefrst_u==""
	gen byte tgt_last_e_pre = tgt & namelast_u==""
	gen byte tgt_last_e_h   = tgt & namelast_h==""
	gen byte tgt_ip = tgt & (ip_f | ip_ld)

	/*3. NON-TARGET RECORDS: WHERE THE USABLE MODEL NAME DIFFERS FROM THE     */
	/*AGREED NAME. AN EMPTY FIELD FALLS BACK TO ANCESTRY = THE AGREED NAME,   */
	/*SO ONLY A PRESENT-AND-DIFFERENT FIELD CHANGES THE LINKED NAME.          */
	gen byte nt_d  = nt & d
	gen byte nt_nd = nt & nd
	gen byte nt_dm = nt & !d & !nd
	gen byte nt_f_e = nt & namefrst_u==""
	gen byte nt_f_w = nt & namefrst_u!="" & namefrst_u!=namefrst
	foreach x in d nd {
		gen byte nt_`x'_l_e = nt_`x' & namelast_u==""
		gen byte nt_`x'_l_w = nt_`x' & namelast_u!="" & namelast_u!=namelast
	}
	gen byte nt_diff = nt & ((namefrst_u!="" & namefrst_u!=namefrst) | (namelast_u!="" & namelast_u!=namelast))
	/*DIFFERING MODEL-DITTO SURNAME, A PROXY SPLIT (2026-11-22 REVIEW): head = */
	/*THE ROW'S ANCESTRY SURNAME EQUALS ITS CHAIN HEAD'S (THE DIFFERENCE      */
	/*ENTERS AT THE HEAD; NO HUMAN AGREEMENT AT THE HEAD IS REQUIRED);        */
	/*chg = THE HUMAN SURNAME CHANGES FROM THE LINE ABOVE (A SURNAME CHANGE   */
	/*THE MODEL FLAGGED AS A DITTO); below = UNCHANGED FROM THE LINE ABOVE BUT */
	/*NOT THE HEAD'S (A DITTO UNDER A MISSED CHANGE). UNKNOWN WHEN THE LINE   */
	/*ABOVE IS NOT LINKED OR HAS NO ANCESTRY SURNAME, OR THE HEAD HAS NONE.   */
	/*ROW ORDER IS THE SCHEDULE ORDER.                                        */
	gen prev_namelast = namelast[_n-1] if link
	gen byte nt_dw_head  = nt_d_l_w & head_anc!="" & namelast==head_anc
	gen byte nt_dw_chg   = nt_d_l_w & !nt_dw_head & prev_namelast!="" & namelast!=prev_namelast
	gen byte nt_dw_below = nt_d_l_w & !nt_dw_head & prev_namelast!="" & head_anc!="" & namelast==prev_namelast
	gen byte nt_dw_unk   = nt_d_l_w & !nt_dw_head & !nt_dw_chg & !nt_dw_below
	/*HOUSEHOLD-CONSISTENCY RULE ON NON-TARGET MODEL-DITTO ROWS: SURNAME :=   */
	/*THE HEAD'S AGREED HUMAN SURNAME WHEN THE HEAD HAS ONE, SCORED AGAINST   */
	/*THE BASELINE (MODEL SURNAME, OR ANCESTRY WHEN EMPTY). in = BASELINE     */
	/*DIFFERS FROM THE AGREED NAME, RULE AGREES; out = BASELINE AGREES, RULE  */
	/*DIFFERS.                                                                */
	gen namelast_base = cond(namelast_u=="", namelast, namelast_u)
	gen byte nt_d_hagree = nt_d & head_agree
	gen byte nt_d_in  = nt_d & head_agree & namelast_base!=namelast & head_anc==namelast
	gen byte nt_d_out = nt_d & head_agree & namelast_base==namelast & head_anc!=namelast

	gen byte n = 1

	/*ONE ROW OF DOUBLE TOTALS FOR THIS STATE.*/
	foreach v of local vars {
		quietly summarize `v'
		local S_`v' = r(sum)
	}
	clear
	set obs 1
	gen str2 st = "`s'"
	foreach v of local vars {
		gen double `v' = `S_`v''
	}
	local ++k
	tempfile p`k'
	save `p`k''
	display "DONE `s'"
}
assert `k'==49
use `p1', clear
forvalues i = 2/`k' {
	append using `p`i''
}

/*TOTALS INTO LOCALS. r(sum) IS DOUBLE.*/
foreach v of local vars {
	quietly summarize `v'
	local T_`v' = r(sum)
}

/*CHECK AGAINST THE PAPER'S NUMBERS.*/
assert `T_tgt'==35094490
assert abs(100*`T_fail_raw'/`T_tgt' - 9.61909120206619) < 1e-9
/*THE THREE REASONS PARTITION THE EMPTY DITTO SURNAMES; SO DOES THE PROXY     */
/*SPLIT OF THE DIFFERING NON-TARGET DITTO SURNAMES.                           */
assert `T_de_headempty'+`T_de_headcross'+`T_de_headother'==`T_de'
assert `T_nt_dw_head'+`T_nt_dw_chg'+`T_nt_dw_below'+`T_nt_dw_unk'==`T_nt_d_l_w'

/*FORMAT HELPERS.*/
capture program drop pct
program define pct, rclass
	args num den
	if `den'==0 return local s "n/a"
	else return local s = strtrim(string(100*`num'/`den', "%6.2f"))
end
capture program drop cnt
program define cnt, rclass
	args x
	return local s = strtrim(string(`x', "%15.0fc"))
end

capture file close md
file open md using `"`md'"', write replace text
file write md "# Ditto surnames: unusable output and the non-target loss" _n _n
file write md "Generated by MATCHING/ditto_diag.do. Do not edit by hand." _n _n
file write md "49 model states, 1940, all records in merged_data.dta. One filename is one 40-line half sheet. A chain is a head row (a model non-ditto, a missing flag, or a link break) and the model-ditto rows linked below it, following the schedule from row 40 of one image to row 1 of the next image of the same roll. The model's own ditto resolution (namelast_ml_ditto) carries the head's model surname down the chain, across images within a roll. Head-human fill = where the model surname is empty on a ditto row, use the head's surname when Ancestry and FamilySearch agree on the head. The literal 'InvalidPred' is treated as empty except in section 4. The fill is scored against the linking baseline: an empty model field falls back to the record's own Ancestry value (the actual pipeline is sentinel-blind and would link on 'invalidpred' for the sentinel rows). Names are compared as raw strings before abeclean, so a difference here is an upper bound on a change in the linked name; the linkage-level test is the ABE rerun. All labels are agreement with the two human transcriptions, not truth; the external reference is the FamilySearch-profile comparison, itself a selected sample. Universes as compute_model_agreement_on_discordant.do: HC = all four human name fields present; target = HC and Ancestry differs from FamilySearch on a name; non-target = HC and the humans agree on both names." _n _n

file write md "## 0. Structure" _n _n
file write md "| | Records |" _n "|---|---:|" _n
foreach v in n parse_ok img40 dup link hc tgt nt d nd head head_le head_le_fe de de_headempty de_headempty_frst de_headcross de_headother dh {
	if "`v'"=="n" local lab "All records"
	if "`v'"=="parse_ok" local lab "Filename parses as m-t0627-roll-image.jpg"
	if "`v'"=="img40" local lab "On an image with exactly 40 rows"
	if "`v'"=="dup" local lab "Duplicate filename-row (excluded from links)"
	if "`v'"=="link" local lab "Previous observation is the line above (linked)"
	if "`v'"=="hc" local lab "HC"
	if "`v'"=="tgt" local lab "Target"
	if "`v'"=="nt" local lab "Non-target"
	if "`v'"=="d" local lab "Model ditto (non_ditto_ml==0)"
	if "`v'"=="nd" local lab "Model non-ditto (non_ditto_ml==1)"
	if "`v'"=="head" local lab "Chain heads"
	if "`v'"=="head_le" local lab "Non-ditto heads with an empty model surname"
	if "`v'"=="head_le_fe" local lab "... and an empty model first name too"
	if "`v'"=="de" local lab "Model ditto with empty surname"
	if "`v'"=="de_headempty" local lab "... under a non-ditto head with an empty model surname"
	if "`v'"=="de_headempty_frst" local lab "... ... whose head also has an empty model first name"
	if "`v'"=="de_headcross" local lab "... on a later image than a head with a model surname (model carry gap, expected ~0)"
	if "`v'"=="de_headother" local lab "... other (head is a link break or a missing flag)"
	if "`v'"=="dh" local lab "Fillable by the head-human fill"
	cnt `T_`v''
	file write md "| `lab' | `r(s)' |" _n
}

file write md _n "## 1. Target records with an empty model-ditto surname, against the linking baseline" _n _n
file write md "The baseline for an empty model surname is the record's own Ancestry surname. Where the record's own humans agree on the surname, the baseline is uncontroversial; where they differ, the head-human fill arbitrates." _n _n
file write md "| | Records |" _n "|---|---:|" _n
cnt `T_tgt_de'
file write md "| Empty model-ditto surname | `r(s)' |" _n
cnt `T_tgt_de_own_agree'
file write md "| ... own humans agree on the surname (baseline uncontroversial) | `r(s)' |" _n
cnt `T_tgt_de_own_agree_h'
local a "`r(s)'"
cnt `T_tgt_de_own_agree_h_diff'
file write md "| ... ... head-human fill available / differs from the agreed surname (a loss) | `a' / `r(s)' |" _n
cnt `T_tgt_de_own_diff'
file write md "| ... own humans differ on the surname | `r(s)' |" _n
cnt `T_tgt_de_own_diff_h'
file write md "| ... ... head-human fill available | `r(s)' |" _n
foreach c in anc fs nei {
	if "`c'"=="anc" local lab "= Ancestry (no change to the linked name)"
	if "`c'"=="fs" local lab "= FamilySearch (changes the linked name)"
	if "`c'"=="nei" local lab "= neither"
	cnt `T_tgt_de_own_diff_h_`c''
	local a "`r(s)'"
	pct `T_tgt_de_own_diff_h_`c'' `T_tgt_de_own_diff_h'
	file write md "| ... ... ... fill `lab' | `a' (`r(s)'%) |" _n
}

file write md _n "## 2. Target records without usable output" _n _n
file write md "Raw = the paper's definition (empty string only). Sentinel-aware = 'InvalidPred' counted as empty. The fill applies to the sentinel-aware fields." _n _n
file write md "| | Raw | Sentinel-aware | + head-human fill |" _n "|---|---:|---:|---:|" _n
local r "| No usable output |"
foreach v in fail_raw fail_pre fail_h {
	cnt `T_`v''
	local r "`r' `r(s)' |"
}
file write md "`r'" _n
local r "| Share of target records (%) |"
foreach v in fail_raw fail_pre fail_h {
	pct `T_`v'' `T_tgt'
	local r "`r' `r(s)' |"
}
file write md "`r'" _n
pct `T_tgt_frst_e' `T_tgt'
file write md "| First name empty (%) | | `r(s)' | `r(s)' |" _n
local r "| Surname empty (%) | |"
foreach v in tgt_last_e_pre tgt_last_e_h {
	pct `T_`v'' `T_tgt'
	local r "`r' `r(s)' |"
}
file write md "`r'" _n
cnt `T_tgt_ip'
file write md "| Target records with the sentinel in a linking field | `r(s)' | | |" _n

file write md _n "## 3. Non-target records: where the usable model name differs from the agreed name" _n _n
cnt `T_nt'
file write md "Non-target records: `r(s)'. An empty model field falls back to Ancestry (= the agreed name), so only a present-and-different field changes the linked name. Shares in % of the column's records." _n _n
file write md "| | Model ditto | Model non-ditto | All non-target |" _n
file write md "|---|---:|---:|---:|" _n
cnt `T_nt_d'
local a "`r(s)'"
cnt `T_nt_nd'
local b "`r(s)'"
cnt `T_nt'
file write md "| Records | `a' | `b' | `r(s)' |" _n
pct `T_nt_d_l_e' `T_nt_d'
local a "`r(s)'"
pct `T_nt_nd_l_e' `T_nt_nd'
local b "`r(s)'"
pct `=`T_nt_d_l_e'+`T_nt_nd_l_e'' `T_nt'
file write md "| Model surname empty (%) | `a' | `b' | `r(s)' |" _n
pct `T_nt_d_l_w' `T_nt_d'
local a "`r(s)'"
pct `T_nt_nd_l_w' `T_nt_nd'
local b "`r(s)'"
pct `=`T_nt_d_l_w'+`T_nt_nd_l_w'' `T_nt'
file write md "| Model surname present and different (%) | `a' | `b' | `r(s)' |" _n
file write md _n "| | All non-target (%) |" _n "|---|---:|" _n
pct `T_nt_f_e' `T_nt'
file write md "| Model first name empty | `r(s)' |" _n
pct `T_nt_f_w' `T_nt'
file write md "| Model first name present and different | `r(s)' |" _n
pct `T_nt_diff' `T_nt'
file write md "| Linked name changes on either field (the erosion) | `r(s)' |" _n
pct `T_nt_dm' `T_nt'
file write md "| non_ditto_ml missing | `r(s)' |" _n
file write md _n "Differing model-ditto surnames on non-target records, proxy split (% of differing):" _n _n
file write md "| | Records | % |" _n "|---|---:|---:|" _n
foreach c in head chg below unk {
	if "`c'"=="head" local lab "Row's Ancestry surname equals its chain head's (the difference enters at the head)"
	if "`c'"=="chg" local lab "Human surname changes from the line above (a change the model flagged as a ditto)"
	if "`c'"=="below" local lab "Unchanged from the line above but not the head's (a ditto under a missed change)"
	if "`c'"=="unk" local lab "Unknown: line above not linked, or no Ancestry surname above or at the head"
	cnt `T_nt_dw_`c''
	local a "`r(s)'"
	pct `T_nt_dw_`c'' `T_nt_d_l_w'
	file write md "| `lab' | `a' | `r(s)' |" _n
}
file write md _n "Household-consistency rule on non-target model-ditto rows (surname := the head's agreed human surname), against the baseline:" _n _n
file write md "| | Records | % of model-ditto non-target |" _n "|---|---:|---:|" _n
foreach c in hagree in out {
	if "`c'"=="hagree" local lab "Head has an agreed human surname (rule applies)"
	if "`c'"=="in" local lab "Moved into agreement: baseline differed, rule agrees"
	if "`c'"=="out" local lab "Moved out of agreement: baseline agreed, rule differs"
	cnt `T_nt_d_`c''
	local a "`r(s)'"
	pct `T_nt_d_`c'' `T_nt_d'
	file write md "| `lab' | `a' | `r(s)' |" _n
}

file write md _n "## 4. The literal 'InvalidPred' (raw counts)" _n _n
file write md "| | Records |" _n "|---|---:|" _n
cnt `T_ip_f'
file write md "| namefrst_ml == InvalidPred | `r(s)' |" _n
cnt `T_ip_l'
file write md "| namelast_ml (raw) == InvalidPred | `r(s)' |" _n
cnt `T_ip_ld'
file write md "| namelast_ml_ditto == InvalidPred | `r(s)' |" _n
cnt `T_nd_ip'
file write md "| Model non-ditto with raw InvalidPred (heads that spread it) | `r(s)' |" _n
cnt `T_tgt_ip'
file write md "| Target records with it in namefrst_ml or namelast_ml_ditto | `r(s)' |" _n

file write md _n "## By state" _n _n
file write md "| state | target no-output, sentinel-aware (%) | + head-human fill (%) | non-target surname differs, ditto (%) | non-ditto (%) |" _n
file write md "|---|---:|---:|---:|---:|" _n
sort st
forvalues i = 1/`=_N' {
	local s = st[`i']
	pct `=fail_pre[`i']' `=tgt[`i']'
	local a "`r(s)'"
	pct `=fail_h[`i']' `=tgt[`i']'
	local b "`r(s)'"
	pct `=nt_d_l_w[`i']' `=nt_d[`i']'
	local c "`r(s)'"
	pct `=nt_nd_l_w[`i']' `=nt_nd[`i']'
	file write md "| `s' | `a' | `b' | `c' | `r(s)' |" _n
}
file close md
display "wrote `md'"
