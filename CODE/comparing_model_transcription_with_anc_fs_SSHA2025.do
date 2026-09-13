clear

local original "D:\Dropbox\enum_date\DATA\ORIGINAL\"
local f_original "F:\enum_date\DATA\ORIGINAL\"

local intermediate "D:\Dropbox\enum_date\DATA\INTERMEDIATE\"
local f_intermediate "F:\enum_date\DATA\INTERMEDIATE\"

local correct_error_original "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\"
local christian_torben "D:\Dropbox\fixing_transcription_errors\DATA\TRANSCRIPTIONS\"	


#delimit;

local z=0;

cd `"`christian_torben'USCensus1940FullCount\output_and_output1_ssha2025"';

local denom=0;
local numer1=0;
local numer2=0;
local numer3=0;
local numer4=0;

foreach stabb in "al" "ar" "az" "ca" "co" "ct" "dc" "de" "fl" "ga" 
				 "hi" "ia" "id" "il" "in" "ks" "ky" "la" "ma" "md" 
				 "me" "mi" "mn" "mo" "ms" "mt" "nc" "nd" "ne" "nh" 
				 "nj" "nm" "nv" "ny" "oh" "ok" "or" "pa" "ri" "sc"
					"sd" "tn" "tx" "ut" "va" "vt" "wa" "wi" "wv" "wy" {;
	
	local z=`z'+1;

	cd `"`stabb'"';
	
	use namefrst fs_namefrst namefrst_ml
	    namelast fs_namelast namelast_ml_ditto
		using merged_data.dta, clear;
		
	count if (namefrst!=""|namelast!="") & (fs_namefrst!=""|fs_namelast!="");
	local denom=`r(N)'+`denom';
	
	/*AGREE WITH ANCESTRY ONLY*/
	count if (namefrst!=""|namelast!="") & (fs_namefrst!=""|fs_namelast!="") & namefrst==namefrst_ml & namelast==namelast_ml_ditto & !(fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto);
	local numer1=`r(N)'+`numer1';
	
	/*AGREE WITH FAMILYSEARCH ONLY*/
	count if (namefrst!=""|namelast!="") & (fs_namefrst!=""|fs_namelast!="") & fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto & !(namefrst==namefrst_ml & namelast==namelast_ml_ditto);	
	local numer2=`r(N)'+`numer2';
	
	/*AGREE WITH BOTH*/
	count if (namefrst!=""|namelast!="") & (fs_namefrst!=""|fs_namelast!="") & fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto & namefrst==namefrst_ml & namelast==namelast_ml_ditto;	
	local numer3=`r(N)'+`numer3';
	
	/*AGREE WITH NEITHER*/
	count if (namefrst!=""|namelast!="") & (fs_namefrst!=""|fs_namelast!="") & !(fs_namefrst==namefrst_ml & fs_namelast==namelast_ml_ditto) & !(namefrst==namefrst_ml & namelast==namelast_ml_ditto);	
	local numer4=`r(N)'+`numer4';	
	
	cd ..;
	
};

noisily di `denom', `numer1', `numer2', `numer3', `numer4';

#delimit cr
