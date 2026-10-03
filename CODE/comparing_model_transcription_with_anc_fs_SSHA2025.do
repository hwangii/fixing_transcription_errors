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
local nok=0;
local nskip=0;

/*WHY HAWAII IS COMMENTED OUT -- DO NOT "RESTORE" IT AGAIN.                   */
/*hi\merged_data.dta HOLDS ONLY THE MODEL COLUMNS (filename, row,            */
/*parsing_quality, non_ditto*, namefrst_ml, namelast_ml, namelast_ml_ditto).  */
/*IT WAS NEVER MERGED AGAINST THE ANCESTRY AND FAMILYSEARCH TRANSCRIPTIONS,   */
/*so namefrst, namelast, fs_namefrst and fs_namelast DO NOT EXIST IN IT and   */
/*the use below cannot succeed. VERIFIED AGAINST THE DATA 2026-10-02.         */
/*                                                                            */
/*THIS IS NOT ABOUT HAWAII BEING A TERRITORY IN 1940. ALASKA'S FILE IS        */
/*COMPLETE (ALL SIX FIELDS), SO ak COULD LEGITIMATELY BE ADDED; HAWAII        */
/*CANNOT, UNTIL ITS MERGE IS BUILT.                                           */
/*                                                                            */
/*hi WAS UNCOMMENTED IN d90cd93 FROM A MACHINE WITHOUT THE DATA. BECAUSE IT   */
/*SITS 11TH OF 50 AND THE use HAD NO capture, THE WHOLE RUN DIED THERE WITH   */
/*r(111) -- AND IN BATCH MODE THE LOG SIMPLY STOPS, RECORDING NO ERROR, SO    */
/*THE TOTALS BELOW NEVER PRINTED AT ALL.                                      */

foreach stabb in "al" "ar" "az" "ca" "co" "ct" "dc" "de" "fl" "ga" 
				 /*"hi"*/ "ia" "id" "il" "in" "ks" "ky" "la" "ma" "md" 
				 "me" "mi" "mn" "mo" "ms" "mt" "nc" "nd" "ne" "nh" 
				 "nj" "nm" "nv" "ny" "oh" "ok" "or" "pa" "ri" "sc"
					"sd" "tn" "tx" "ut" "va" "vt" "wa" "wi" "wv" "wy" {;
	
	local z=`z'+1;

	/*GUARD 1: THE STATE DIRECTORY. WITHOUT capture, A MISSING DIRECTORY     */
	/*LEAVES cd .. UNREACHED AND EVERY LATER STATE RESOLVES FROM THE WRONG   */
	/*PLACE, CORRUPTING THE WHOLE RUN RATHER THAN JUST ONE STATE.            */
	capture cd `"`stabb'"';
	if _rc {;
		display as error "SKIPPING `stabb': no such state directory";
		local nskip=`nskip'+1;
		continue;
	};

	/*GUARD 2: THE COLUMNS. A DIRECTORY CAN EXIST AND STILL HOLD A FILE      */
	/*WITHOUT THE ANCESTRY/FAMILYSEARCH FIELDS -- THAT IS EXACTLY HAWAII.    */
	/*GUARDING cd ALONE DOES NOT CATCH IT, SO GUARD THE use TOO, AND cd BACK */
	/*BEFORE SKIPPING OR THE NEXT STATE INHERITS THIS DIRECTORY.             */
	capture use namefrst fs_namefrst namefrst_ml
	    namelast fs_namelast namelast_ml_ditto
		using merged_data.dta, clear;
	if _rc {;
		display as error "SKIPPING `stabb': cannot read the six name fields from merged_data.dta (rc=" _rc ")";
		local nskip=`nskip'+1;
		cd ..;
		continue;
	};

	local nok=`nok'+1;

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

/*REPORT THE COVERAGE ALONGSIDE THE TOTALS. WITHOUT THIS, A SKIPPED STATE IS  */
/*INVISIBLE AND THE NUMBERS BELOW LOOK LIKE A COMPLETE RUN.                   */
display "states attempted: `z'   contributed: `nok'   skipped: `nskip'";

noisily di `denom', `numer1', `numer2', `numer3', `numer4';

#delimit cr
