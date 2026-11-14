/*BUILD: 1940 TRANSCRIPTIONS BESIDE FAMILYSEARCH PROFILE NAMES (2026-11-13).  */
/*                                                                           */
/*For the appendix (tab:transcription_accuracy): AGREEMENT, NOT ACCURACY --  */
/*how often each 1940 transcription -- Ancestry, FamilySearch's census index, */
/*and ours -- agrees with the name on the FamilySearch profile attached to    */
/*the record. Profiles draw on many sources, so they are a reference, not a   */
/*ground truth; see profile_names_score.do for the comparison and its biases.*/
/*                                                                           */
/*One row per 1940 record (histid) attached to exactly one profile, with:    */
/*  - the six name fields and the Sec 4.3 cell, exactly as MATCHING/fs_cells.do*/
/*  - sex, age and marital status (marst) from the 1940 IPUMS extract         */
/*  - the profile's fullname, gender and birth/death dates                    */
/*  - for never-married women only, the profile's father's name, three ways  */
/*    (preferred parent set; parent_no==1; number of distinct fathers), as   */
/*    the reference for a maiden surname.                                    */
/*Writes only `out'/profile_names.dta (and its intermediates). Slow: it reads */
/*all 133 profile scrapes (~200 GB) and the 37 GB IPUMS extract.             */

clear all
set more off
set linesize 255
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"

local root    "$REP_SNU/fixing_transcription_errors/DATA/TRANSCRIPTIONS/USCensus1940FullCount/output_and_output1_ssha2025"
local xwalk   "$REP_F/marital_distance/DATA/ORIGINAL/unique_ID_to_census_crosswalk1940.dta"
local ipums   "$REP_F/enum_date/DATA/INTERMEDIATE/to_link_hist_to_sample1940.dta"
local prof    "E:/multigen_CM/DATA/INTERMEDIATE"
local out     "$REP_F/fixing_transcription_errors/DATA/INTERMEDIATE/profile_names"
capture mkdir "`out'"

/*THE 49-STATE UNIVERSE OF compute_model_agreement_on_discordant.do: hi HAS  */
/*NO HUMAN NAME COLUMNS IN merged_data, AND ak IS NOT AMONG THE MODEL'S STATES.*/
local states "al ar az ca co ct dc de fl ga ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy"

/*=========================================================*/
/*1. CENSUS SIDE: NAMES AND SEC 4.3 CELL, BY histid         */
/*=========================================================*/
tempfile census
local z 0
foreach s of local states {
	use histid namefrst fs_namefrst namefrst_ml namelast fs_namelast namelast_ml_ditto using `"`root'/`s'/merged_data.dta"', clear
	keep if histid!=""
	/*HUMAN-COMPLETE: ALL FOUR HUMAN NAME FIELDS PRESENT, SO ""=="" CANNOT    */
	/*COUNT AS AGREEMENT. THE SAME DENOMINATOR AS THE PAPER'S 14%/52%.        */
	keep if namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!=""
	gen byte disc  = !(namefrst==fs_namefrst & namelast==fs_namelast)
	gen byte ml_ok = namefrst_ml!="" & namelast_ml_ditto!=""
	/*CELLS AS MATCHING/fs_cells.do:75-79; 0 = CONCORDANT.                    */
	gen byte cell = 0
	replace cell = 1 if disc & ml_ok & namefrst==namefrst_ml & namelast==namelast_ml_ditto & !(fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto)
	replace cell = 2 if disc & ml_ok & fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto & !(namefrst==namefrst_ml & namelast==namelast_ml_ditto)
	replace cell = 3 if disc & ml_ok & !(fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto) & !(namefrst==namefrst_ml & namelast==namelast_ml_ditto)
	replace cell = 4 if disc & !ml_ok
	assert inrange(cell,1,4) if disc
	assert cell==0 if !disc
	drop disc ml_ok
	gen str2 st = "`s'"
	local ++z
	if `z'>1 append using `census'
	save `census', replace
}
display "states read: `z'"
assert `z'==49

use `census', clear
/*A histid IN MORE THAN ONE merged_data ROW: KEEP IT ONLY IF ALL ITS ROWS    */
/*CARRY THE SAME SIX NAMES; OTHERWISE IT IS NOT CLASSIFIABLE AND IS DROPPED. */
bysort histid: gen int _n_rows = _N
quietly count if _n_rows>1
display "census rows sharing a histid: " r(N)
duplicates drop histid namefrst fs_namefrst namefrst_ml namelast fs_namelast namelast_ml_ditto, force
bysort histid: gen byte _conf = _N>1
quietly count if _conf
display "histids dropped for conflicting duplicate rows: " r(N)
drop if _conf
drop _conf _n_rows
isid histid
display "census records, human-complete: " _N
local n_census = _N
save `census', replace

/*=========================================================*/
/*2. ATTACH PROFILES: histid <-> unique_ID, ONE-TO-ONE ONLY  */
/*=========================================================*/
use histid1940 unique_ID using `"`xwalk'"', clear
rename histid1940 histid
drop if histid=="" | unique_ID==""
duplicates drop
/*A RECORD ATTACHED TO TWO PROFILES, OR A PROFILE ATTACHED TO TWO 1940       */
/*RECORDS, HAS NO SINGLE REFERENCE NAME: DROP BOTH KINDS, AND SAY HOW MANY.  */
bysort histid: gen byte _mh = _N>1
bysort unique_ID: gen byte _mu = _N>1
local n_xwalk = _N
quietly count if _mh
local n_xmh = r(N)
display "crosswalk rows whose histid has >1 profile: " r(N)
quietly count if _mu
local n_xmu = r(N)
display "crosswalk rows whose profile has >1 histid: " r(N)
drop if _mh | _mu
drop _mh _mu
isid histid
isid unique_ID

merge 1:1 histid using `census', keep(3) nogen
display "human-complete records with exactly one profile: " _N
local n_linked = _N
tab cell

/*=========================================================*/
/*3. SEX, AGE, MARITAL STATUS FROM THE 1940 IPUMS EXTRACT   */
/*=========================================================*/
tempfile linked
save `linked'
use histid sex age marst using `"`ipums'"', clear
drop if histid==""
duplicates drop
/*ONE ROW PER histid OR THE MERGE BELOW WOULD DUPLICATE RECORDS.*/
bysort histid: gen byte _d = _N>1
quietly count if _d
display "IPUMS histids with conflicting sex/age/marst rows (dropped): " r(N)
drop if _d
drop _d
merge 1:1 histid using `linked', keep(2 3)
display "linked records without an IPUMS row (sex/marst missing, kept): "
count if _merge==2
local n_noipums = r(N)
drop _merge
save `linked', replace

/*=========================================================*/
/*4. PROFILE NAMES: ONE COPY PER PROFILE, FROM ITS LATEST   */
/*   SCRAPE (all_profiles.dta: max_scrape_type)             */
/*=========================================================*/
keep unique_ID
merge 1:1 unique_ID using `"`prof'/all_profiles.dta"', keepusing(max_scrape_type) keep(1 3)
display "profiles not in all_profiles.dta (max_scrape_type missing): "
count if _merge==1
drop _merge
tempfile ids
save `ids'

/*EACH SCRAPE'S MATCHES GO TO THEIR OWN FILE AND ARE APPENDED ONCE AT THE    */
/*END: APPENDING INTO ONE GROWING FILE WOULD REWRITE IT 133 TIMES.           */
local infofiles ""
forvalues k = 1/133 {
	capture confirm file `"`prof'/all_individual_info`k'.dta"'
	if _rc {
		display as error "all_individual_info`k'.dta: missing"
		exit 601
	}
	use unique_ID fullname gender birthdate deathdate scrape_type using `"`prof'/all_individual_info`k'.dta"', clear
	merge m:1 unique_ID using `ids', keep(3) nogen
	compress
	save `"`out'/_info`k'.dta"', replace
	local infofiles `"`infofiles' "`out'/_info`k'.dta""'
	display "info `k': " _N " rows"
}
clear
append using `infofiles'
/*PREFER THE COPY FROM THE PROFILE'S LATEST SCRAPE; WITHOUT ONE, THE LATEST  */
/*SCRAPE THAT HAS IT.                                                        */
gen byte _is_max = scrape_type==max_scrape_type
bysort unique_ID: egen byte _has_max = max(_is_max)
drop if _has_max & !_is_max
bysort unique_ID: egen float _last = max(scrape_type)
drop if !_has_max & scrape_type!=_last
duplicates drop unique_ID fullname gender birthdate deathdate, force
/*SAME SCRAPE, DIFFERENT CONTENT: NO SINGLE REFERENCE, DROP.*/
bysort unique_ID: gen byte _conf = _N>1
quietly count if _conf
display "profiles with conflicting rows within one scrape (dropped): " r(N)
drop if _conf
drop _is_max _has_max _last _conf
rename scrape_type info_scrape
isid unique_ID
tempfile infoone
save `infoone'

/*=========================================================*/
/*5. FATHERS OF NEVER-MARRIED WOMEN (marst==6, sex==2)      */
/*=========================================================*/
use `linked', clear
keep if sex==2 & marst==6
keep unique_ID
merge 1:1 unique_ID using `ids', keep(3) nogen
tempfile nmw
save `nmw'
display "never-married women with a profile: " _N

/*all_parents24.dta DOES NOT EXIST BY DESIGN: THE FEW PROFILES SCRAPED IN    */
/*SCRAPE 24 HAD NO PARENTS (SAM, 2026-11-13). ANY OTHER MISSING FILE STOPS.  */
local parfiles ""
forvalues k = 1/133 {
	capture confirm file `"`prof'/all_parents`k'.dta"'
	if _rc {
		if `k'==24 continue
		display as error "all_parents`k'.dta: missing"
		exit 601
	}
	use unique_ID parent_no parent_preferred father_ID father_name scrape_type using `"`prof'/all_parents`k'.dta"', clear
	merge m:1 unique_ID using `nmw', keep(3) nogen
	compress
	save `"`out'/_par`k'.dta"', replace
	local parfiles `"`parfiles' "`out'/_par`k'.dta""'
}
clear
append using `parfiles'
gen byte _is_max = scrape_type==max_scrape_type
bysort unique_ID: egen byte _has_max = max(_is_max)
drop if _has_max & !_is_max
bysort unique_ID: egen float _last = max(scrape_type)
drop if !_has_max & scrape_type!=_last
drop _is_max _has_max _last
/*COPIES OF ONE FATHER ROW MAY DISAGREE ON parent_preferred: THE ROW IS     */
/*PREFERRED IF ANY COPY SAYS SO, AND THE CONFLICTS ARE COUNTED.             */
gen byte _pref = lower(parent_preferred)=="true"
bysort unique_ID parent_no father_ID father_name: egen byte _pmin = min(_pref)
by unique_ID parent_no father_ID father_name: egen byte _pmax = max(_pref)
quietly count if _pmin!=_pmax
display "father rows whose copies disagree on parent_preferred: " r(N)
replace _pref = _pmax
drop _pmin _pmax
duplicates drop unique_ID parent_no father_ID father_name, force
drop if father_name=="" & father_ID==""

/*NUMBER OF DISTINCT FATHERS (BY ID, OR BY NAME WHEN THE ID IS EMPTY).*/
gen _fkey = cond(father_ID!="", father_ID, "name:" + father_name)
bysort unique_ID _fkey: gen byte _first = _n==1
bysort unique_ID: egen int n_fathers = total(_first)

/*PREFERRED PARENT SET; IF SEVERAL ARE FLAGGED, THE LOWEST parent_no.*/
/*TIES BROKEN BY father_ID, THEN father_name, SO THE CHOICE IS DETERMINISTIC.*/
gsort unique_ID -_pref parent_no father_ID father_name
by unique_ID: gen str father_pref = father_name[1] if _pref[1]==1
/*parent_no==1 (USUALLY, NOT ALWAYS, THE BIRTH FATHER).*/
gen _p1name = father_name if parent_no==1
bysort unique_ID (_p1name): gen str father_p1 = _p1name[_N]
bysort unique_ID: keep if _n==1
keep unique_ID father_pref father_p1 n_fathers
tempfile fathers
save `fathers'

/*=========================================================*/
/*6. ASSEMBLE                                               */
/*=========================================================*/
use `linked', clear
merge 1:1 unique_ID using `infoone', keep(1 3)
display "records whose profile has no info row (fullname missing): "
count if _merge==1
local n_noinfo = r(N)
drop _merge
merge 1:1 unique_ID using `fathers', keep(1 3) nogen
/*THE SELECTION FLOW TRAVELS WITH THE FILE, FOR profile_names_score.do TO  */
/*PRINT BESIDE THE RESULTS.                                                 */
foreach c in n_census n_xwalk n_xmh n_xmu n_linked n_noipums n_noinfo {
	char _dta[`c'] ``c''
}
compress
save `"`out'/profile_names.dta"', replace
describe
tab cell sex, missing
