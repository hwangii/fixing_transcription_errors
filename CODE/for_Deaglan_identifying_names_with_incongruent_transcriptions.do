local original "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\"
local christian_torben "D:\Dropbox\fixing_transcription_errors\DATA\TRANSCRIPTIONS\"	

use namefrst* namelast* histid using `"`original'census1940_all_labeled_data.dta"',clear /*CREATED IN D:\Dropbox\fixing_transcription_errors\CODE\clean_FS_and_combineV5_nber.do*/

rename (namefrst_fs namelast_fs) (fs_namefrst fs_namelast)

gen congruent=namefrst==fs_namefrst & namelast==fs_namelast /*WE ALREADY KEPT THOSE WITH NON-MISSING NAMES WHEN WE CREATED THE FILE census1940_all_labeled_data.dta*/

keep congruent histid 

save `"`christian_torben'ipums_fs_names_for_Deaglan1940.dta"', replace
