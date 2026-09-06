local original "F:\updated_census_recvd_aug2021\ubc_1940_3-4\1940_3-4\"
local letters "F:\updated_census_recvd_aug2021\"
local trans_original "D:\Dropbox\fixing_transcription_errors\DATA\ORIGINAL\"
local enumdate_original "D:\Dropbox\enum_date\DATA\ORIGINAL\"
local trans_intermediate_f "F:\fixing_transcription_errors\DATA\INTERMEDIATE\"
local trans_code "D:\Dropbox\fixing_transcription_errors\CODE\"

#delimit;

local full_stlist `" "Alabama" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "District of Columbia" "Florida" "Georgia"
 "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" 
 "Missouri" "Montana" "Nebraska" "Nevada" "New Hampshire" "New Jersey" "New Mexico" "New York" "North Carolina" "North Dakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" 
 "Rhode Island" "South Carolina" "South Dakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" 
 "Washington" "West Virginia" "Wisconsin" "Wyoming" "';
 
#delimit cr

cd `"`original'"'

set linesize 255

set more off

/*
/****************/
/*HOUSEHOLD FILE*/
/****************/
clear
quietly infix                             ///
  str     rectype              1-1        ///
  double  serial               12-19      ///  
  byte    statefip             41-42      ///
  byte    urban                71-71      ///  
  byte    farm                 82-82      ///  
  int     countyicp            1139-1142  ///
  double  enumdist             1846-1854  ///
  using `"`original'us1940b_usa_res.dat"'
gen  _line_num = _n
drop if rectype != `"H"'
sort _line_num

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

keep serial statefip countyicp edist urban farm

save `"`trans_original'ancestry_all_hh.dta"',replace
*/


/************************/
/*INDIVIDUAL LEVEL FILES*/
/************************/
clear
quietly infix                             ///
  str     rectype              1-1        ///
  double  serialp              12-19      ///
  int     pernum               20-23      ///  
  int     relate               54-57      ///    
  int     age                  58-60      ///
  byte    sex                  61-61      ///  
  int     race                 62-64      ///    
  byte    marst                65-65      ///    
  long    bpl                  73-77      ///    
  byte    school               110-110    ///  
  int     higrade              111-113    ///  
  int     occ1950              119-121    ///  
  long    incwage              152-157    ///  
  str     namelast             1697-1712  ///
  str     namefrst             1713-1728  ///
  str     bplstr               1773-1822  ///  
  long    mbpl                 2086-2090  ///
  long    fbpl                 2091-2095  ///
  int     linep                2318-2320  ///      
  str     histid               2331-2366  ///  
  str     us1940b_1072         3518-3537  ///  
 using `"`original'us1940b_usa_res.dat"'
drop if rectype != `"P"'
drop rectype

rename (serialp linep) (serial linenumber)

split us1940b_1072,parse("-")
drop us1940b_10721 us1940b_10722
destring us1940b_10723 us1940b_10724,replace

rename (us1940b_10723 us1940b_10724) (nararollnumber imagenumber)

foreach var in nararollnumber imagenumber {
	capture drop if real(`var')==.
	capture destring `var',replace
}

rename race race_anc

bysort nararollnumber imagenumber linenumber: keep if _N==1

keep histid age sex race bpl namelast namefrst /*bplstr*/ nararollnumber imagenumber linenumber serial pernum higrade marst relate school occ1950 incwage fbpl mbpl

merge m:1 serial using `"`trans_original'ancestry_all_hh.dta"',keep(1 3) nogen

save `"`trans_intermediate_f'ancestry_all1940.dta"',replace


/******************/
/*DIVIDE THE FILES*/
/******************/
foreach st in `full_stlist' {

	qui do `"`trans_code'input_state_name_output_statefip.do"' `"`st'"'
	
	local cur_statefip=$cur_statefip

	#delimit;
	
		use serial pernum histid namelast namefrst 
		statefip countyicp urban farm edist 
		nararollnumber imagenumber linenumber 
		sex age race higrade school relate marst bpl occ1950 incwage 
		mbpl fbpl using `"`trans_intermediate_f'ancestry_all1940.dta"' if statefip==`cur_statefip',clear;
		
	#delimit cr
	
	local st_=lower(subinstr(`"`st'"'," ","_",.))
	
	save `"`trans_intermediate_f'ancestry_`st_'1940.dta"',replace

}
