/*FAMILYSEARCH NAME FILES FOR LINKING WITH FAMILYSEARCH'S TRANSCRIPTION      */
/*(2026-11-06). ONE FILE PER CENSUS YEAR, ONE ROW PER histid:               */
/*    $REP_F/enum_date/DATA/INTERMEDIATE/fs_names<yr>.dta                    */
/*    histid fs_namefrst fs_namelast  (raw FamilySearch strings, lower case) */
/*1b_fs_divided_files.do SWAPS THESE INTO THE ANCESTRY DIVIDED FILES.        */
/*                                                                           */
/*SOURCES                                                                    */
/*  1940  census1940_all_labeled_data.dta: namefrst_fs namelast_fs, the same */
/*        FamilySearch strings the paper uses for transcription congruency.  */
/*  1930  the 126 FamilySearch person files p<k>.dta, names built exactly as */
/*        CODE/make_training_data_for_1930V2.do does (FamilySearch's original*/
/*        transcription "_orig", blanks filled from its edited version),     */
/*        linked to histid through final1930.dta.                            */
/*                                                                           */
/*ARGUMENT: the years to build, e.g. "1930 1940".                            */
/*A histid WITH MORE THAN ONE DISTINCT FAMILYSEARCH NAME IS DROPPED (IT THEN */
/*KEEPS ITS ANCESTRY NAME); THE COUNT IS DISPLAYED.                          */

local yr_list `"`1'"'
if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"

local trans_original "$REP_SNU/fixing_transcription_errors/DATA/ORIGINAL/"
local cenorig "$REP_F/sshrc_idg_mortality/DATA/ORIGINAL/familysearch_census1930/"
local f_intermediate "$REP_F/enum_date/DATA/INTERMEDIATE/"

foreach yr of local yr_list {

	if `yr'==1940 {

		use histid namefrst_fs namelast_fs using `"`trans_original'census1940_all_labeled_data.dta"', clear
		rename (namefrst_fs namelast_fs) (fs_namefrst fs_namelast)
		replace fs_namefrst=lower(strtrim(fs_namefrst))
		replace fs_namelast=lower(strtrim(fs_namelast))

	}
	else if `yr'==1930 {

		tempfile fs1930
		forvalues k=1/126 {

			use image_ark_id person_ark_id pr_name_pre_1 pr_name_pre_orig_1 pr_name_gn_1 pr_name_gn_orig_1 pr_name_surn_1 pr_name_surn_orig_1 pr_name_suf_1 pr_name_suf_orig_1 using `"`cenorig'p`k'.dta"', clear

			/*FROM make_training_data_for_1930V2.do: BOTH VERSIONS OF THE NAME, */
			/*LOWER CASE, REPEATED PREFIXES/SUFFIXES COLLAPSED, THEN           */
			/*FIRST = PREFIX + GIVEN + SUFFIX, LAST = SURNAME.                 */
			foreach type in "" "_orig" {

				foreach nt in pre gn surn suf {
					replace pr_name_`nt'`type'_1=lower(pr_name_`nt'`type'_1)
				}

				foreach rep in "dr" "miss" "mr" "mrs" "mrs." "rev" "doctor" "dr." "madame" "master" "mistress" "mme" "mr." "ms" "ms." "rev." "reverend" {
					replace pr_name_pre`type'_1=`"`rep'"' if pr_name_pre`type'_1==`"`rep', `rep'"'|pr_name_pre`type'_1==`"`rep'., `rep'"'|pr_name_pre`type'_1==`"`rep', `rep'."'
				}

				#delimit;
				foreach rep in "2nd" "3rd" "4th" "i" "ii" "iii" "jr" "jr." "junior" "md" "no name as yet" "nun" "son-in-law"
				"sr" "sr." "twin" "2d" "3d" "third" "sn" "second" "lll" "jr 111" "jr 3rd" "american citizen" "adopted daughter" "twins"
				"companion" {;
					replace pr_name_suf`type'_1=`"`rep'"' if pr_name_suf`type'_1==`"`rep', `rep'"'|pr_name_suf`type'_1==`"`rep'., `rep'"'|pr_name_suf`type'_1==`"`rep', `rep'."';
				};
				#delimit cr

				gen fs_namefrst`type'=pr_name_gn`type'_1 if pr_name_pre`type'_1=="" & pr_name_gn`type'_1!=""
				replace fs_namefrst`type'=pr_name_pre`type'_1+" "+pr_name_gn`type'_1 if pr_name_pre`type'_1!="" & pr_name_gn`type'_1!=""
				replace fs_namefrst`type'=fs_namefrst`type'+" "+pr_name_suf`type'_1 if pr_name_suf`type'_1!=""
				gen fs_namelast`type'=pr_name_surn`type'_1 if pr_name_surn`type'_1!=""

				foreach comm in ustrtrim ustrltrim stritrim ustrrtrim {
					replace fs_namefrst`type'=`comm'(fs_namefrst`type')
					replace fs_namelast`type'=`comm'(fs_namelast`type')
				}
			}

			/*FAMILYSEARCH'S ORIGINAL TRANSCRIPTION, BLANKS FILLED FROM ITS     */
			/*EDITED VERSION (make_training_data_for_1930V2.do, "FILL IN THE    */
			/*BLANKS"; census1930_all_labeled_data.dta's fs_namefrst IS THIS).  */
			replace fs_namefrst_orig=fs_namefrst if fs_namefrst_orig=="" & fs_namefrst!=""
			replace fs_namelast_orig=fs_namelast if fs_namelast_orig=="" & fs_namelast!=""
			keep image_ark_id person_ark_id fs_namefrst_orig fs_namelast_orig
			rename (fs_namefrst_orig fs_namelast_orig) (fs_namefrst fs_namelast)

			if `k'>1 append using `fs1930'
			save `fs1930', replace
		}

		display "FamilySearch 1930 person records: " _N
		isid image_ark_id person_ark_id
		/*1:m -- final1930.dta IS NOT GUARANTEED TO HAVE ONE histid PER PERSON;*/
		/*A histid REACHED TWICE WITH DIFFERENT NAMES IS DROPPED BELOW.        */
		merge 1:m image_ark_id person_ark_id using `"`cenorig'final1930.dta"', keepusing(histid) keep(3)
		tab _merge
		drop _merge image_ark_id person_ark_id

	}
	else {
		display as error "0b_create_fs_names.do: no FamilySearch source coded for `yr'"
		exit 198
	}

	keep if histid!="" & (fs_namefrst!="" | fs_namelast!="")
	duplicates drop
	bysort histid: gen byte _dup = _N>1
	quietly count if _dup
	display "`yr': histids with more than one distinct FamilySearch name, dropped: " r(N)
	drop if _dup
	drop _dup
	isid histid
	display "`yr': histids with a FamilySearch name: " _N
	compress
	save `"`f_intermediate'fs_names`yr'.dta"', replace
}
