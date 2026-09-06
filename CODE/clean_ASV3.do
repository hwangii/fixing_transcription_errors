local original "F:\updated_census_recvd_aug2021\ubc_1940_3-4\1940_3-4\"
local letters "F:\updated_census_recvd_aug2021\"
local trans_original "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\"
local enumdate_original "D:\Dropbox\enum_date\DATA\ORIGINAL\"
cd `"`original'"'

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

keep if statefip==44
//keep if statefip==1

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

egen image_id_sam=group(county supdist ed alphabet us1940b_0015 us1940b_0017),missing

rename (county_str edist us1940b_0015 us1940b_0017 us1940b_0018) (censuscounty eventdistrict nararollnumber imagenumber lineh)

keep censuscounty eventdistrict nararollnumber imagenumber serial image_id_sam enumdist lineh us1940b_0083 us1940b_0084

destring lineh,replace

save `"`trans_original'ancestry_rhode_island_hh.dta"',replace
//save `"`trans_original'ancestry_alabama_hh.dta"',replace



/*
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
  str     namelast             1697-1712  ///
  str     namefrst             1713-1728  ///
  int     linep                2318-2320  ///      
  str     histid               2331-2366  ///
 using `"`original'us1940b_usa_res.dat"'
drop if rectype != `"P"'
drop rectype

rename serialp serial

merge m:1 serial using `"`trans_original'ancestry_rhode_island_hh.dta"',keep(3) nogen
//merge m:1 serial using `"`trans_original'ancestry_alabama_hh.dta"',keep(3) nogen

merge 1:1 histid using `"`letters'1940_letter.dta"',keep(1 3) nogen

rename general_sheetnumber sheetnumberletter

save `"`trans_original'ancestry_rhode_island.dta"',replace
//save `"`trans_original'ancestry_alabama.dta"',replace
