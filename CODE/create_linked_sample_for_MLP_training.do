global md_original "F:\marital_distance\DATA\ORIGINAL\"

global transcription "F:\fixing_transcription_errors\DATA\INTERMEDIATE\"

use $md_original\unique_ID_to_census_crosswalk1930.dta, clear

merge 1:1 unique_ID using $md_original\unique_ID_to_census_crosswalk1940.dta, keep(3) nogen

merge 1:1 unique_ID using $md_original\all_profiles.dta, keepusing(anon_id) keep(1 3) nogen

merge 1:1 anon_id using $md_original\anon_id_vital_dates.dta, keep(1 3)

keep if birthyr!=. & deathyr!=. & birthmon!=. & deathmon!=. & _merge==3 & ( birthyr < deathyr | (birthyr == deathyr & birthmo <= deathmo) )

keep histid1930 histid1940

save $transcription\mlp_training1930_1940.dta, replace
