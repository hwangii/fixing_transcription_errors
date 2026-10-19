*****************************************
* MASTER SCRIPT - CenSoc Data Creation
* Stata Translation of R Pipeline
* Runs all steps from 01 to 05
*****************************************

* IMPORTANT: Before running this script, you MUST:
* 1. Update all file paths in each individual .do file to match your system
* 2. Ensure you have the following input files:
*    - 1940 Census data
*    - BUNMD data (CSV format)
* 3. Have sufficient disk space for intermediate files
* 4. Have Stata 14 or higher (for Unicode string functions)

drop _all
clear all
set more off
set maxvar 10000
capture log close

set trace off


/*
capture ssc install statastates
capture ssc install gtools
capture ssc install ftools
capture gtools, upgrade
*/

*****************************************
* GLOBAL PATH CONFIGURATION
*****************************************
* All paths derive from code/shared/paths.do. Nothing here may
* hardcode a drive letter -- see that file for the history.

* Bootstrap. If a master runner has already set ROOT, keep it.
* This is the only path literal in the mortality pipeline.
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
if "$LCODE" == "" global LCODE "F:/github_repos/fixing_transcription_errors/LINKAGE/code"
do "$LCODE/shared/paths.do"

* ---- legacy global names, kept so steps 0-5 run unchanged ----
global base_path    "$ROOT"
global code         "$C_MORT"
global data         "$D_MORT"
global raw          "$D_MORT/raw"
global intermediate "$D_MORT/intermediate"

* INPUT FILES (raw data)
global census_raw   "$D_CENSUS/1940_census_for_merge_with_bunmd"
global bunmd_raw    "$raw/bunmd_v2/bunmd_v2.csv"

* OUTPUT DIRECTORIES
global output_dir   "$D_MORT/working"
cap mkdir "$output_dir"

* Log directory. NOTE: this block used to sit ABOVE output_dir,
* so $log_dir expanded to "/log" and Stata silently created
* F:\log outside the project. It must stay below output_dir.
global log_dir      "$OUT_LOGS"
cap mkdir "$log_dir"

* Tables land in the shared package output folder.
global tables       "$OUT_TABLES"
cap mkdir "$tables"

* Step 1: Split by birthplace
global split_census "$output_dir/1940-census-by-bpl"
global split_bunmd  "$output_dir/bunmd-by-bpl"

* Step 2: Clean names
global clean_census "$output_dir/cleaned-1940-census-by-bpl"
global clean_bunmd  "$output_dir/cleaned-bunmd-by-bpl"

* Step 3: Match records
global match_bunmd_old  "$output_dir/matched-census-bunmd-oldnames"
global match_bunmd_new  "$output_dir/matched-census-bunmd-newnames"



*****************************************
* LOCALS TO SKIP COMPLETED STEPS 
*****************************************

local step0_birthplace_crosswalk ""

*****************************************
* Set up abe matching algorithm
*****************************************

global match_vars fname_cleaned lname_cleaned bpl_h
global timediff = (0) // number of years between the age reported in data set A and age reported in data set B. 

*****************************************
* RUN CODE
*****************************************

di "=================================================="
di "STEP 0: create a harmonized birthplace crosswalk"
di "=================================================="

*if "`step0_birthplace_crosswalk'" != "complete"{
*		do "$code/0_create_birthplace_crosswalk.do"
*	}

*do "$code/0_merge_new_names.do"	
*do "$code/01_run_clean_names.do"
*do "$code/02_1_split_census_by_bpl.do"	
*do "$code/02_2_split_bunmd_by_bpl.do"
*do "$code/03_match.do"
do "$code/04_post_match.do"
do "$code/05_make_linkage_table.do"

capture log close

	
