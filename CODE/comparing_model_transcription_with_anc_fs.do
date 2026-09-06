local transcription "D:\Dropbox\fixing_transcription_errors\DATA\TRANSCRIPTIONS\"
local intermediate "F:\fixing_transcription_errors\DATA\INTERMEDIATE\"

local file_type="rhode_island"

if `"`file_type'"'=="rhode_island" {
	local filename_frst="df_all_namefrst_archive_quality_tokens_round2"
	local filename_last="df_all_namelast_ditto_archive_quality_tokens_round2"
}

capture cd `"`transcription'"'

foreach name_type in frst last {

	use filename row name`name_type'_anc name`name_type'_fams name`name_type'_ml using `filename_`name_type''.dta,clear
	keep if name`name_type'_anc!="" & name`name_type'_fams!="" & name`name_type'_ml!=""
	
	bysort filename row: keep if _N==1
	
	save temp_`name_type'.dta,replace
	
}

use temp_frst.dta,clear
merge 1:1 filename row using temp_last,keepusing(namelast_anc namelast_fams namelast_ml) keep(3) nogen

local N=_N 

count if namefrst_anc!=namefrst_fams|namelast_anc!=namelast_fams
local denom=`r(N)'

di "Share of disagreements between ANC and FS:",`denom'/`N'

count if (namefrst_anc!=namefrst_fams|namelast_anc!=namelast_fams) & namefrst_anc==namefrst_ml & namelast_anc==namelast_ml
local numer_anc=`r(N)'

count if (namefrst_anc!=namefrst_fams|namelast_anc!=namelast_fams) & namefrst_fams==namefrst_ml & namelast_fams==namelast_ml
local numer_fams=`r(N)'

di "Share agreeing with Ancestry: ",`numer_anc'/`denom'
di "Share agreeing with FamilySearch: ",`numer_fams'/`denom'


foreach name_type in frst last {
	capture erase temp_`name_type'.dta
}
