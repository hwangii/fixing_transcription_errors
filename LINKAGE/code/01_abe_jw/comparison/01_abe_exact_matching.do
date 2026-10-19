/*------------------------------------------------------------------------------
ABE Exact Matching (Original Algorithm - Exact Match on Cleaned Names)

Purpose: Run the original ABE matching algorithm using exact matches on cleaned names
This is the simpler version that requires perfect matches (no NYSIIS, no JW)

Comparison with current implementation:
- This version: Exact match on f_name_cleaned and l_name_cleaned
- Current version: JW distance ≤ 0.1 on f_name_cleaned and l_name_cleaned

Key difference: This uses abematch with exact matching, while current uses JW distances

Outputs:
- abe_comparison/output/ABE_exact_matches.dta (all matches)
- abe_comparison/output/ABE_exact_matches_unique2yr.dta (unique within ±2 years)
------------------------------------------------------------------------------*/

clear all
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
do "$ROOT/code/shared/paths.do"

** Check required packages **
cap which abematch
if _rc {
    di as error "abematch.ado not found - copying from abe_original_code"
    copy "$ABEJW/abe_original_code\abematch.ado" ///
         "$ABEJW/abe_comparison\abematch.ado", replace
}

** Set up directories **
cd "$ABEJW"

global outdir "$ABEJW/abe_comparison\output"
cap mkdir "$outdir"

** Prepare data files for abematch (needs abeclean format) **
* abematch expects files processed by abeclean, but we want to match on cleaned names
* not NYSIIS, so we'll use the nonysiis option

di as text _n "{hline 70}"
di as text "Preparing data for ABE exact matching..."
di as text "{hline 70}"

* Load abeclean if needed
cd "$ABEJW/abe_comparison"
cap which abeclean
if _rc {
    di "Copying abeclean.ado..."
    copy "$ABEJW/abe_original_code\abeclean.ado" ///
         "$ABEJW/abe_comparison\abeclean.ado", replace
}

* Prepare 1930 data
use "$ABEJW/data\clean_names\clean_names_1930.dta", clear

* Rename for abeclean
rename f_name_cleaned f_name
rename l_name_cleaned l_name

* Need sex variable for abeclean
cap confirm variable sex
if _rc {
    di as text "  sex variable not found - assuming all male (sex=1)"
    gen sex = 1
}

* Run abeclean with nonysiis option (keeps cleaned names as-is, no NYSIIS encoding)
di as text "  Processing 1930 data (without NYSIIS)..."
abeclean f_name l_name, sex(sex) nonysiis

* Save temporary file for matching
tempfile ready_1930
save `ready_1930', replace

* Prepare 1940 data
use "$ABEJW/data\clean_names\clean_names_1940.dta", clear

rename f_name_cleaned f_name
rename l_name_cleaned l_name

cap confirm variable sex
if _rc {
    gen sex = 1
}

di as text "  Processing 1940 data (without NYSIIS)..."
abeclean f_name l_name, sex(sex) nonysiis

tempfile ready_1940
save `ready_1940', replace

** Set up matching parameters **

* Match on cleaned names (not NYSIIS) and birthplace
global match_vars "f_name_cleaned l_name_cleaned bpl"

* Time difference between censuses
global timediff = 10

* ID variables
global id_var "histid"

* Output file
cd "$ABEJW"
global A "`ready_1930'"
global B "`ready_1940'"
global outputfile "$outdir\ABE_exact_matches"

** Run exact matching **
cd "$ABEJW/abe_comparison"

di as text _n "{hline 70}"
di as text "Running ABE Exact Matching Algorithm (No NYSIIS)"
di as text "{hline 70}"
di as text "Match variables: " as result "$match_vars"
di as text "Time difference: " as result "$timediff years"
di as text "Note: Matching on cleaned names EXACTLY (not NYSIIS codes, not JW distances)"
di as text ""

clear
abematch $match_vars, ///
    file_A($A) file_B($B) ///
    timevar(age) timediff($timediff) ///
    save($outputfile) replace ///
    id_A($id_var) id_B($id_var) ///
    unique_m(2) unique_f(2) ///
    keep_A(f_name_cleaned l_name_cleaned age bpl) ///
    keep_B(f_name_cleaned l_name_cleaned age bpl)

** Save initial results **
qui count
local n_matches = r(N)
di as text _n "Initial matches (before uniqueness filter): " as result %12.0fc `n_matches'

** Apply conservative uniqueness filter (±2 years) **
keep if unique_file2 == 1  // unique within ±2 years in own dataset
keep if unique_match2 == 1 // no other potential match within ±2 years

qui count
local n_unique = r(N)
local pct = 100 * `n_unique' / `n_matches'

save "${outputfile}_unique2yr", replace

di as text _n "{hline 70}"
di as text "ABE Exact Matching Complete (No NYSIIS)"
di as text "{hline 70}"
di as text "Method: Exact string match on cleaned names + exact birthplace"
di as text "No NYSIIS encoding, no JW distances - must match perfectly"
di as text ""
di as text "Matches before uniqueness: " as result %12.0fc `n_matches'
di as text "Matches after uniqueness:  " as result %12.0fc `n_unique' ///
    as text " (" as result %5.1f `pct' as text "%)"
di as text ""
di as text "Output files:"
di as text "  All matches:     " as result "$outputfile.dta"
di as text "  Unique matches:  " as result "${outputfile}_unique2yr.dta"
di as text "{hline 70}"
