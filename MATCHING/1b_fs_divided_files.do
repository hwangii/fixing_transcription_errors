/*FAMILYSEARCH-NAME DIVIDED FILES FOR ONE CENSUS YEAR (2026-11-06).          */
/*                                                                           */
/*Starts from the men-only Ancestry divided files that produced the paper's  */
/*ABE exact-name links (divided_file<yr>_ans_cleaned, one file per birthplace,*/
/*norace<bpl>.dta: id f_name l_name age mi), so the records are the same    */
/*by construction, and writes divided_file<yr>_fs_cleaned with the same      */
/*variables. For each record:                                                */
/*  f_name = FamilySearch's first name, cleaned, where FamilySearch has one; */
/*           otherwise the Ancestry first name already in the file           */
/*  l_name = the same for the last name (each field falls back separately,   */
/*           as the ML version does in 1_divide_and_clean)                   */
/*  mi     = the middle initial from FamilySearch's first name where that    */
/*           name is used, otherwise Ancestry's                              */
/*FamilySearch names are cleaned with the same abeclean options used for the */
/*ML names in 1_divide_and_clean (nicknames, nonysiis).                      */
/*                                                                           */
/*ARGUMENTS: the census year; optionally the output name type, default      */
/*"_fs_cleaned". "_fsplacebo_cleaned" IS THE PLACEBO: NO FAMILYSEARCH NAME   */
/*IS SWAPPED IN, SO THE FILES ARE THE ANCESTRY FILES AND THE LINKS MUST      */
/*REPRODUCE link1930_1940_ans_cleaned_noraceblock0.dta (check_placebo.do).   */
/*NEEDS fs_names<yr>.dta (0b_create_fs_names.do) EXCEPT FOR THE PLACEBO.     */

local yr `1'
local fstype `"`2'"'
if `"`fstype'"'=="" local fstype "_fs_cleaned"
local placebo = `"`fstype'"'=="_fsplacebo_cleaned"
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local f_intermediate "$REP_F/enum_date/DATA/INTERMEDIATE/"

local src `"`f_intermediate'divided_file`yr'_ans_cleaned"'
local dst `"`f_intermediate'divided_file`yr'`fstype'"'
capture mkdir `"`dst'"'

local files : dir `"`src'"' files "norace*.dta"
local nfiles : word count `files'
if `nfiles'==0 {
	display as error "no norace*.dta files in `src'"
	exit 601
}

local tot 0
local totfs 0
foreach f of local files {

	use `"`src'/`f'"', clear
	isid id
	local n0 = _N

	if `placebo' {
		gen fs_namefrst = ""
		gen fs_namelast = ""
	}
	else {
		rename id histid
		merge 1:1 histid using `"`f_intermediate'fs_names`yr'.dta"', keep(1 3)
		assert _N==`n0'
		drop _merge
		rename histid id
	}

	/*THESE FILES ARE MEN ONLY (1_divide_and_clean KEEPS sex==1) AND CARRY NO */
	/*sex VARIABLE; abeclean NEEDS ONE TO CHOOSE THE NICKNAME TABLE.          */
	capture confirm variable sex
	if _rc gen byte sex = 1
	abeclean fs_namefrst fs_namelast, sex(sex) initial(mi_fs) nicknames nonysiis
	gen byte fs_frst_used = fs_namefrst_cleaned!=""
	gen byte fs_last_used = fs_namelast_cleaned!=""
	replace f_name = fs_namefrst_cleaned if fs_frst_used
	replace l_name = fs_namelast_cleaned if fs_last_used
	replace mi     = mi_fs if fs_frst_used

	quietly count if fs_frst_used | fs_last_used
	local tot = `tot' + _N
	local totfs = `totfs' + r(N)

	keep id f_name l_name age mi fs_frst_used fs_last_used
	save `"`dst'/`f'"', replace
}
display "`yr': `nfiles' files, `tot' records, `totfs' with at least one FamilySearch name used"
