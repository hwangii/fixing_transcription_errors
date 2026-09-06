local original "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\"
local original_enumdate "D:\Dropbox\enum_date\DATA\ORIGINAL\"
local intermediate_enumdate "D:\Dropbox\enum_date\DATA\INTERMEDIATE\"
local intermediate "D:\Dropbox\fixing_transcription_errors\DATA\INTERMEDIATE\"
local transcription "D:\Dropbox\fixing_transcription_errors\DATA\TRANSCRIPTIONS\"

use histid namefrst namelast fs_namefrst fs_namelast imagenumber_combined linep using `"`original'rhode_island_combined.dta"',clear

/*MERGE SEX*/
merge 1:1 histid using `"`original_enumdate'matching_intgen1940.dta"',keepusing(sex) keep(1 3) nogen

/*KEEP ONLY MEN*/
keep if sex==1

/*MERGE CORRECTED NAMES*/
rename imagenumber_combined filename
replace filename=filename+".jpg"

tostring linep,replace

merge 1:1 filename linep using `"`transcription'df_all_namefrst_archive.dta"',keepusing(namefrst_ml bad_segmentation row) keep(3) nogen
rename bad_segmentation bad_segmentation_frst
replace namefrst_ml="" if bad_segmentation_frst==1

merge 1:1 filename linep using `"`transcription'df_all_namelast_archive.dta"',keepusing(namelast_ml bad_segmentation row) keep(3) nogen
rename bad_segmentation bad_segmentation_last
replace namelast_ml="" if bad_segmentation_last==1

foreach yr in 1910 1930 {

	preserve

		/****************/
		/*MERGE LINKAGES*/
		/****************/
		/*ANCESTRY*/
		rename histid id_B

		merge 1:1 id_B using `"`intermediate_enumdate'link`yr'_1940_ans_cleaned_noraceblock.dta"',keepusing(id_A) keep(1 3)

		gen ancestry_linked=id_A!="" & _merge==3

		rename id_A ancestry_link`yr'_1940

		drop _merge



		/*ML*/
		merge 1:1 id_B using `"`intermediate_enumdate'link`yr'_1940_true_cleaned_noraceblock.dta"',keepusing(id_A) keep(1 3)

		gen ml_linked=id_A!="" & _merge==3

		rename id_A ml_link`yr'_1940

		drop _merge



		/*FAMILYSEARCH*/
		merge 1:1 id_B using `"`intermediate_enumdate'link`yr'_1940_true_cleaned_noraceblock_fs.dta"',keepusing(id_A) keep(1 3)

		gen familysearch_linked=id_A!="" & _merge==3

		rename id_A familysearch_link`yr'_1940

		drop _merge


		keep filename linep row namefrst fs_namefrst namefrst_ml namelast fs_namelast namelast_ml ancestry_linked ml_linked familysearch_linked
		order filename linep row namefrst fs_namefrst namefrst_ml namelast fs_namelast namelast_ml ancestry_linked ml_linked familysearch_linked

		export delimited using `"`intermediate'template_for_analysis`yr'_1940.csv"', replace

	restore

}
