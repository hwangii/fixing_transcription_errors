local original "F:\updated_census_recvd_aug2021\ubc_1940_3-4\1940_3-4\"
local letters "F:\updated_census_recvd_aug2021\"
local trans_original "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\"
local enumdate_original "D:\Dropbox\enum_date\DATA\ORIGINAL\"
cd `"`original'"'

set linesize 255


set more off

/****************/
/*HOUSEHOLD FILE*/
/****************/
clear
quietly infix                             ///
  str     rectype              1-1        ///
  double  serial               12-19      ///  
  byte    statefip             41-42      ///
  int     countyicp            1139-1142  ///
  double  enumdist             1846-1854  ///
  str     us1940b_0015         2154-2157  ///
  str     us1940b_0017         2158-2161  ///
  str     us1940b_0018         2162-2164  ///  
  str     us1940b_0083         3009-3017  ///
  str     us1940b_0084         3018-3026  ///
  using `"`original'us1940b_usa_res.dat"'
gen  _line_num = _n
drop if rectype != `"H"'
sort _line_num

/*MERGE COUNTY NAME*/
rename countyicp county
merge m:1 statefip county using `"`original'county_code_icpsr1850_1930.dta"',keep(1 3) nogen

/*CONVERT THE ENUM DIST NAME*/
gen supdist=floor(enumdist/100000)
gen ed=floor((enumdist-supdist*100000)/10)
gen alphabet=enumdist-supdist*100000-ed*10
tostring supdist ed alphabet,replace

replace alphabet="" if alphabet=="0"
replace alphabet="A" if alphabet=="1"
replace alphabet="B" if alphabet=="2"
replace alphabet="C" if alphabet=="3"
replace alphabet="D" if alphabet=="4"
replace alphabet="E" if alphabet=="5"
replace alphabet="F" if alphabet=="6"
replace alphabet="G" if alphabet=="7"
replace alphabet="H" if alphabet=="8"
replace alphabet="I" if alphabet=="9"

gen edist=supdist+"-"+ed+alphabet

destring us1940b_0015 us1940b_0017 , replace

gsort county supdist ed alphabet us1940b_0015 us1940b_0017

rename (county county_str edist us1940b_0015 us1940b_0017 us1940b_0018) (countyicp censuscounty eventdistrict nararollnumber imagenumber lineh)

egen image_id_sam=group(statefip countyicp eventdistrict nararollnumber imagenumber),missing

keep statefip countyicp censuscounty eventdistrict nararollnumber imagenumber serial image_id_sam enumdist /*lineh*/ us1940b_0083 us1940b_0084

/*destring lineh,replace*/

save `"`trans_original'ancestry_all_hh.dta"',replace




/*****************/
/*INDIVIDUAL FILE*/
/*****************/
clear
quietly infix                             ///
  str     rectype              1-1        ///
  double  serialp              12-19      ///
  int     pernum               20-23      ///  
  int     age                  58-60      ///
  byte    sex                  61-61      ///  
  int     race                 62-64      ///    
  long    bpl                  73-77      ///    
  str     namelast             1697-1712  ///
  str     namefrst             1713-1728  ///
  str     bplstr               1773-1822  ///  
  int     linep                2318-2320  ///      
  str     histid               2331-2366  ///  
 using `"`original'us1940b_usa_res.dat"'
drop if rectype != `"P"'
drop rectype

rename serialp serial

merge 1:1 histid using `"`letters'1940_letter.dta"',keep(1 3) nogen

rename general_sheetnumber sheetnumberletter

drop histid

merge m:1 serial using `"`trans_original'ancestry_all_hh.dta"',keep(3) nogen

gsort eventdistrict us1940b_0083 us1940b_0084

save `"`trans_original'ancestry_all.dta"',replace





/******************************************************************/
/*FIND ENUMERATION DISTRICTS/COUNTIES WITH THE HIGHEST SHARE BLACK*/
/******************************************************************/
use `"`trans_original'ancestry_all.dta"',clear

gen black=race==200

bysort statefip countyicp eventdistrict: gen N=_N

bysort statefip countyicp eventdistrict: egen Nblack=total(black)

keep if black==1 & censuscounty!=""

set seed 1000

sample 101, count

keep statefip countyicp censuscounty eventdistrict N Nblack nararollnumber imagenumber

bysort eventdistrict: keep if _n==1

/*ADD STATE ABBREVIATION*/
gen state_abbr = ""

replace state_abbr = "al" if statefip == 1
replace state_abbr = "ak" if statefip == 2
replace state_abbr = "az" if statefip == 4
replace state_abbr = "ar" if statefip == 5
replace state_abbr = "ca" if statefip == 6
replace state_abbr = "co" if statefip == 8
replace state_abbr = "ct" if statefip == 9
replace state_abbr = "de" if statefip == 10
replace state_abbr = "dc" if statefip == 11
replace state_abbr = "fl" if statefip == 12
replace state_abbr = "ga" if statefip == 13
replace state_abbr = "hi" if statefip == 15
replace state_abbr = "id" if statefip == 16
replace state_abbr = "il" if statefip == 17
replace state_abbr = "in" if statefip == 18
replace state_abbr = "ia" if statefip == 19
replace state_abbr = "ks" if statefip == 20
replace state_abbr = "ky" if statefip == 21
replace state_abbr = "la" if statefip == 22
replace state_abbr = "me" if statefip == 23
replace state_abbr = "md" if statefip == 24
replace state_abbr = "ma" if statefip == 25
replace state_abbr = "mi" if statefip == 26
replace state_abbr = "mn" if statefip == 27
replace state_abbr = "ms" if statefip == 28
replace state_abbr = "mo" if statefip == 29
replace state_abbr = "mt" if statefip == 30
replace state_abbr = "ne" if statefip == 31
replace state_abbr = "nv" if statefip == 32
replace state_abbr = "nh" if statefip == 33
replace state_abbr = "nj" if statefip == 34
replace state_abbr = "nm" if statefip == 35
replace state_abbr = "ny" if statefip == 36
replace state_abbr = "nc" if statefip == 37
replace state_abbr = "nd" if statefip == 38
replace state_abbr = "oh" if statefip == 39
replace state_abbr = "ok" if statefip == 40
replace state_abbr = "or" if statefip == 41
replace state_abbr = "pa" if statefip == 42
replace state_abbr = "pr" if statefip == 72
replace state_abbr = "ri" if statefip == 44
replace state_abbr = "sc" if statefip == 45
replace state_abbr = "sd" if statefip == 46
replace state_abbr = "tn" if statefip == 47
replace state_abbr = "tx" if statefip == 48
replace state_abbr = "ut" if statefip == 49
replace state_abbr = "vt" if statefip == 50
replace state_abbr = "va" if statefip == 51
replace state_abbr = "vi" if statefip == 52
replace state_abbr = "wa" if statefip == 53
replace state_abbr = "wv" if statefip == 54
replace state_abbr = "wi" if statefip == 55
replace state_abbr = "wy" if statefip == 56

/*************************************/
/*ALSO ADD NON-ABBREVIATED STATE NAME*/
/*************************************/
gen state_name="" 

replace state_name = "alabama" if statefip == 1
replace state_name = "alaska" if statefip == 2
replace state_name = "arizona" if statefip == 4
replace state_name = "arkansas" if statefip == 5
replace state_name = "california" if statefip == 6
replace state_name = "colorado" if statefip == 8
replace state_name = "connecticut" if statefip == 9
replace state_name = "delaware" if statefip == 10
replace state_name = "district-of-columbia" if statefip == 11
replace state_name = "florida" if statefip == 12
replace state_name = "georgia" if statefip == 13
replace state_name = "hawaii" if statefip == 15
replace state_name = "idaho" if statefip == 16
replace state_name = "illinois" if statefip == 17
replace state_name = "indiana" if statefip == 18
replace state_name = "iowa" if statefip == 19
replace state_name = "kansas" if statefip == 20
replace state_name = "kentucky" if statefip == 21
replace state_name = "louisiana" if statefip == 22
replace state_name = "maine" if statefip == 23
replace state_name = "maryland" if statefip == 24
replace state_name = "massachusetts" if statefip == 25
replace state_name = "michigan" if statefip == 26
replace state_name = "minnesota" if statefip == 27
replace state_name = "mississippi" if statefip == 28
replace state_name = "missouri" if statefip == 29
replace state_name = "montana" if statefip == 30
replace state_name = "nebraska" if statefip == 31
replace state_name = "nevada" if statefip == 32
replace state_name = "new-hampshire" if statefip == 33
replace state_name = "new-jersey" if statefip == 34
replace state_name = "new-mexico" if statefip == 35
replace state_name = "new-york" if statefip == 36
replace state_name = "north-carolina" if statefip == 37
replace state_name = "north-dakota" if statefip == 38
replace state_name = "ohio" if statefip == 39
replace state_name = "oklahoma" if statefip == 40
replace state_name = "oregon" if statefip == 41
replace state_name = "pennsylvania" if statefip == 42
replace state_name = "puerto-rico" if statefip == 72
replace state_name = "rhode-island" if statefip == 44
replace state_name = "south-carolina" if statefip == 45
replace state_name = "south-dakota" if statefip == 46
replace state_name = "tennessee" if statefip == 47
replace state_name = "texas" if statefip == 48
replace state_name = "utah" if statefip == 49
replace state_name = "vermont" if statefip == 50
replace state_name = "virginia" if statefip == 51
replace state_name = "virgin-islands" if statefip == 52
replace state_name = "washington" if statefip == 53
replace state_name = "west-virginia" if statefip == 54
replace state_name = "wisconsin" if statefip == 55
replace state_name = "wyoming" if statefip == 56

save `"`trans_original'sampled_edist_for_nber_0929_2024.dta"',replace
*/





/***************************************************/
/*PRINT OUT COMMANDS TO DOWNLOAD IMAGES FROM AMAZON*/
/*WHEN RUNNING THIS CODE, STOP THE DROPBOX SYNCING */
/***************************************************/
use `"`trans_original'sampled_edist_for_nber_0929_2024.dta"',clear

local N=_N

qui forvalues n=1/`N' {
//foreach n in 8 /*14 19 59 63 85*/ {

	local cur_st=state_abbr[`n']
	local cur_st_name=state_name[`n']
	local cur_county=subinstr(lower(censuscounty[`n'])," ","-",.)
	
	/******************************/
	/*FIX THE NAME OF THE COUNTIES*/
	/******************************/	
	if substr(`"`cur_county'"',1,3)=="st-" {
		local cur_county="st.-"+substr(`"`cur_county'"',4,strlen(`"`cur_county'"')-3)
	}
	if `"`cur_st'"'=="ar" & `"`cur_county'"'=="cleveland/dorsey" {
		local cur_county="cleveland"
	}
	if `"`cur_st'"'=="al" & `"`cur_county'"'=="morgan/cotaco" {
		local cur_county="morgan"	
	}
	if `"`cur_st'"'=="md" & `"`cur_county'"'=="queen-annes" {
		local cur_county="queen-anne's"	
	}	
	if `"`cur_st'"'=="va" & `"`cur_county'"'=="newport-news" {
		local cur_county="newport-news-city"
	}
	
	
	local cur_ed=eventdistrict[`n']
	local cur_target_folder=`"D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\black_sample_nber_0929_2024\\`cur_st_name'\\`cur_county'-county\ed\\`cur_ed'\"'
	
	local cur_command=`"shell aws s3 sync s3://nara-1940-census/population-schedules/`cur_st'/`cur_county'-county/ed/`cur_ed'/ `cur_target_folder' --no-sign-request"'
	
	capture mkdir `"`cur_target_folder'"'
	noisily di `"`cur_command'"'
	
	`cur_command'
	
}
