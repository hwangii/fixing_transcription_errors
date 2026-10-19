drop _all
clear all 
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
if "$LCODE" == "" global LCODE "F:/github_repos/fixing_transcription_errors/LINKAGE/code"
do "$LCODE/shared/paths.do"

cd "$ABEJW"
do "$C_ABEJW/ado/pairing_chunked_gtools.ado"

** This command expects each blocking variable to have already been cleaned **

local a_census_yr 1930
local b_census_yr 1940
local resume ""

local chunking_vars bpl first_initial last_initial race
local afile "data\clean_names\clean_names_`a_census_yr'"
local bfile "data\clean_names\clean_names_`b_census_yr'"

global timediff = `b_census_yr' - `a_census_yr'
global age_band = 2

if "`resume'" != "resume"{
	 shell rmdir "data\BlocksAtoB" /s
	 shell rmdir "data\candidate_pairs" /s
}

cap mkdir "data\candidate_pairs"
cap mkdir "data\BlocksAtoB"

** Pairing **

local mp 1000000 // Maximum number of potential pairs before blocks are split
local bt 200000 // Minimum number of potential pairs before blocks are combined 
local bs 2000000 // Target number of pairs for combined blocks

local t0 = clock(c(current_time), "hms")

pairing_chunked_gtools, afile("`afile'.dta") ///
	bfile("`bfile'.dta") ///
	id_vars(histid) ///
	id_type(string) ///
	blocking_vars("`chunking_vars'") ///
	clean_pairs("$C_ABEJW/ado/filtering.do") ///
	distances(jw_f_name_cleaned jw_l_name_cleaned age_diff) ///
	diagnose_blocks ///
	clusters(12) ///
	output("temp_check") ///
	processors(2) ///
	batch_small_blocks ///
	max_pairs(`mp') ///
    batch_threshold(`bt') ///
	batch_size(`bs') ///
	save_blocks block_dir("data\BlocksAtoB") ///
	`resume'
	


local t1 = clock(c(current_time), "hms")
local elapsed = (`t1' - `t0') / 1000
di `elapsed'

*noappend ///
