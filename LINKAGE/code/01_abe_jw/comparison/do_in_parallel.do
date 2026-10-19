
* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
if "$LCODE" == "" global LCODE "F:/github_repos/fixing_transcription_errors/LINKAGE/code"
do "$LCODE/shared/paths.do"
qui local matsize = 11000
qui cap set matsize `matsize'
if _rc {
local matsize = 800
qui set matsize `matsize'
}
local N_blocks = _N
local length = `matsize'/5
forval m=1/`=ceil(`N_blocks'/`length')' {
local first = (`m'-1)*`length'+1
local last = min(`m'*`length',`N_blocks')
qui cap drop __0*
mkmat block_number a_start a_end b_start b_end in `first'/`last', matrix(Cutoffs`m')
}
local pairs_list
forval i=1/`N_blocks' {
parallel break
local m = ceil(`i'/`length')
qui matrix slice = Cutoffs`m'[mod(`i'-1,`length')+1,1..5]
local block = slice[1,1]
qui use histid age f_name_cleaned l_name_cleaned bpl race first_initial last_initial initial_frst initial_last  using __b_cleaned in `=slice[1,4]'/`=slice[1,5]', clear
qui keep histid age f_name_cleaned l_name_cleaned bpl race first_initial last_initial initial_frst initial_last
qui ren * B*
qui tempfile B_obs`block'
qui save `B_obs`block''
qui use histid age f_name_cleaned l_name_cleaned bpl race first_initial last_initial initial_frst initial_last  using __a_cleaned in `=slice[1,2]'/`=slice[1,3]', clear
qui keep histid age f_name_cleaned l_name_cleaned bpl race first_initial last_initial initial_frst initial_last 
qui ren * A*
qui cross using `B_obs`block''
qui rm `B_obs`block''
if ""=="example_block" & `block'==1 {
qui save `"$ABEJW/abe_comparison\output\BlocksAtoA/Block`block'_precommands"', replace
}
qui do filtering.do

qui keep Ahistid Bhistid age_diff jw_f_name_cleaned jw_l_name_cleaned
if "save_blocks"!="save_blocks" {
if _N>0 {
qui tempfile Pairs`block'
qui save `"`Pairs`block''"'
}
if ""=="example_block" & `block'==1 {
qui save `"$ABEJW/abe_comparison\output\BlocksAtoA/Block`block'"'
}
}
else {
if _N==0 drop _all
qui save `"$ABEJW/abe_comparison\output\BlocksAtoA/Block`block'"', emptyok
local Pairs`block' = `"$ABEJW/abe_comparison\output\BlocksAtoA/Block`block'"'
}
if `"noappend"'!="noappend" & _N>0 {
qui cap local pairs_list = `"`pairs_list' `"`Pairs`block''"'"'
local rc = _rc
qui assert(inlist(`rc',0,920))
if `rc'==920 {
qui clear
qui append using `pairs_list' `Pairs`block''
foreach file of local pairs_list {
qui rm `file'
}
qui tempfile combined_at`block'
qui save `combined_at`block''
local pairs_list = `"`combined_at`block''"'
}
}
}
qui clear
if `"noappend"'!="noappend" {
if `"`pairs_list'"'!="" {
qui append using `pairs_list'
if "save_blocks"!="save_blocks" {
foreach file of local pairs_list {
rm `file'
}
}
}
}
if _N==0 {
set obs 1
gen var_to_drop_later=1
keep var_to_drop_later
}