set more off

/*
clear
quietly infix                             ///
  str     rectype              1-1        ///
  double  serial               12-19      ///
  byte    statefip             41-42      ///
  int     pageno               107-110    ///
  int     reel                 1806-1809  ///
  int     line                 1822-1824  ///
  double  enumdist             1846-1854  ///
  using "F:\updated_census_recvd_aug2021\ubc_1850_3-3\1850_3-3\us1850c_usa_res.dat"
gen  _line_num = _n
drop if rectype != `"H"'
sort _line_num

keep if statefip==44

save "F:\updated_census_recvd_aug2021\ubc_1850_3-3\1850_3-3\rhode_island_ancestry_hh1850.dta", replace
*/


clear
quietly infix                             ///
  str     rectype              1-1        ///
  double  serialp              12-19      ///
  int     pernum               20-23      ///
  int     age                  58-60      ///
  byte    sex                  61-61      ///
  str     namelast             1697-1712  ///
  str     namefrst             1713-1728  ///
  str     histid               2331-2366  ///
  str     pid                  2367-2415  ///
  str     us1850c_1000         2525-2528  ///
  str     us1850c_1001         2529-2531  ///
  using "F:\updated_census_recvd_aug2021\ubc_1850_3-3\1850_3-3\us1850c_usa_res.dat"
gen  _line_num = _n
drop if rectype != `"P"'
sort _line_num
drop _line_num

rename serialp serial

merge m:1 serial using "F:\updated_census_recvd_aug2021\ubc_1850_3-3\1850_3-3\rhode_island_ancestry_hh1850.dta",keep(3) nogen

save "F:\updated_census_recvd_aug2021\ubc_1850_3-3\1850_3-3\rhode_island_ancestry1850.dta", replace

/*
clear
use __temp_ipums_hier_H.dta
append using __temp_ipums_hier_P.dta
sort _line_num
drop _line_num
erase __temp_ipums_hier_H.dta
erase __temp_ipums_hier_P.dta

replace hhwt                = hhwt                / 100
replace presgl              = presgl              / 10
replace erscor50            = erscor50            / 10
replace edscor50            = edscor50            / 10
replace npboss50            = npboss50            / 10
replace slwt                = slwt                / 100
replace perwt               = perwt               / 100

format serial              %8.0g
format yrstcounty          %10.0g
format hhwt                %10.2f
format dwelling            %8.0g
format enumdist            %9.0g
format splithid            %8.0g
format serialp             %8.0g
format presgl              %3.1f
format erscor50            %4.1f
format edscor50            %4.1f
format npboss50            %4.1f
format slwt                %10.2f
format perwt               %10.2f

label var rectype             `"Record type"'
label var year                `"Census year"'
label var sample              `"IPUMS sample identifier"'
label var serial              `"Household serial number"'
label var numprec             `"Number of person records following"'
label var subsamp             `"Subsample number"'
label var dwsize              `"Dwelling size"'
label var region              `"Census region and division"'
label var stateicp            `"State (ICPSR code)"'
label var statefip            `"State (FIPS code)"'
label var sea                 `"State Economic Area"'
label var metro               `"Metropolitan status"'
label var metarea             `"Metropolitan area"'
label var metdist             `"Metropolitan district"'
label var city                `"City"'
label var citypop             `"City population"'
label var sizepl              `"Size of place"'
label var urban               `"Urban/rural status"'
label var urbarea             `"Urbanized area"'
label var gq                  `"Group quarters status"'
label var gqtype              `"Group quarters type"'
label var gqfunds             `"Group quarters funding"'
label var farm                `"Farm status"'
label var pageno              `"Microfilm page number"'
label var nfams               `"Number of families in household"'
label var ncouples            `"Number of couples in household"'
label var nmothers            `"Number of mothers in household"'
label var nfathers            `"Number of fathers in household"'
label var nengpop             `"New England population in minor civil division"'
label var urbpop              `"Population of urban places"'
label var hhtype              `"Household Type"'
label var cntry               `"Country"'
label var headloc             `"Location of household head"'
label var countynhg           `"County (NHGIS code)"'
label var yrstcounty          `"Year state county, used to make NHGISJOIN"'
label var stcounty            `"State/county, used to make APPAL"'
label var appal               `"Appalachian region"'
label var countyicp           `"County (ICPSR code)"'
label var hhwt                `"Household weight"'
label var stdcity             `"Standardized city, alphabetic string"'
label var gqstr               `"Group quarters, alphabetic string"'
label var dwelling            `"Dwelling serial number"'
label var mdstatus            `"Metropolitan district status"'
label var ward                `"Ward"'
label var reel                `"Microfilm reel number"'
label var numperhh            `"Number of persons in household"'
label var line                `"Line number"'
label var enumdist            `"Enumeration district"'
label var split               `"Large group quarters that was split up (100% datasets)"'
label var splithid            `"Household serial number, before large group quarters were split up (100% dataset"'
label var splitnum            `"Number of person records in household, before large group quarters were split up"'
label var rectypep            `"Record type"'
label var yearp               `"Census year"'
label var samplep             `"IPUMS sample identifier"'
label var serialp             `"Household serial number"'
label var pernum              `"Person number in sample unit"'
label var momloc              `"Mother's location in the household"'
label var stepmom             `"Probable step/adopted mother"'
label var momrule_hist        `"Rule for linking mother"'
label var poploc              `"Father's location in the household"'
label var steppop             `"Probable step/adopted father"'
label var poprule_hist        `"Rule for linking father"'
label var sploc               `"Spouse's location in household"'
label var sprule_hist         `"Rule for linking spouse"'
label var famsize             `"Number of own family members in household"'
label var nchild              `"Number of own children in the household"'
label var nchlt5              `"Number of own children under age 5 in household"'
label var famunit             `"Family unit membership"'
label var eldch               `"Age of eldest own child in household"'
label var yngch               `"Age of youngest own child in household"'
label var nsibs               `"Number of own siblings in household"'
label var relate              `"Relationship to household head"'
label var age                 `"Age"'
label var sex                 `"Sex"'
label var race                `"Race"'
label var marst               `"Marital status"'
label var marrinyr            `"Married within the past year"'
label var bpl                 `"Birthplace"'
label var hispan              `"Hispanic origin"'
label var spanname            `"Spanish surname"'
label var school              `"School attendance"'
label var lit                 `"Literacy"'
label var labforce            `"Labor force status"'
label var occ1950             `"Occupation, 1950 basis"'
label var occscore            `"Occupational income score"'
label var sei                 `"Duncan Socioeconomic Index "'
label var ind1950             `"Industry, 1950 basis"'
label var realprop            `"Real estate value"'
label var imppop              `"Imputed location of father"'
label var impsp               `"Imputed location of spouse"'
label var imprel              `"Imputed relationship to household head"'
label var qage                `"Flag for Age"'
label var qagemont            `"Flag for Agemonth"'
label var qbpl                `"Flag for Bpl, Nativity"'
label var qocc                `"Flag for Occ, Occ1950, SEI, Occscore, Occsoc, Labforce"'
label var qrace               `"Flag for Race, Racamind, Racasian, Racblk, Racpais, Racwht, Racoth, Racnum, Race"'
label var qschool             `"Flag for School, Schltype"'
label var qsex                `"Flag for Sex"'
label var racamind            `"Race: American Indian or Alaska Native"'
label var racasian            `"Race: Asian"'
label var racblk              `"Race: black or African American"'
label var racpacis            `"Race: Pacific Islander"'
label var racother            `"Race: some other race"'
label var racwht              `"Race: white"'
label var agediff             `"Temporary"'
label var racesing            `"Race: Single race identification"'
label var probwht             `"Probability of white race response"'
label var proboth             `"Probability of 'other race' race response"'
label var probblk             `"Probability of black race response"'
label var probapi             `"Probability of Asian/Pacific Islander race response"'
label var probai              `"Probability of American Indian race response"'
label var hisprule            `"Hispanic origin rule"'
label var relflag             `"[relate flag]"'
label var presgl              `"Occupational prestige score, Siegel"'
label var erscor50            `"Occupational earnings score, 1950 basis"'
label var edscor50            `"Occupational education score, 1950 basis"'
label var npboss50            `"Nam-Powers-Boyd occupational status score, 1950 basis"'
label var occstr              `"Occupation, alphabetic string"'
label var isrelate            `"[relate flag]"'
label var slwt                `"Sample-line weight"'
label var perwt               `"Person weight"'
label var birthyr             `"Year of birth"'
label var occ                 `"Occupation"'
label var namelast            `"Last name"'
label var namefrst            `"First name"'
label var bplstr              `"Birthplace, alphabetic string"'
label var agemonth            `"Age in months"'
label var blind               `"Blind"'
label var deaf                `"Deaf and dumb"'
label var idiotic             `"Idiotic"'
label var insane              `"Insane"'
label var crime               `"Crime"'
label var pauper              `"Pauper"'
label var sursim              `"Surname similarity"'
label var impmom              `"Imputed location of mother"'
label var qlit                `"Flag for Lit"'
label var qmarinyr            `"Flag for Marrinyr"'
label var histid              `"Consistent historical data person identifier"'
label var pid                 `"PID"'
label var versionhist         `"Release version for historical data  "'

label define year_lbl 1850 `"1850"'
label define year_lbl 1860 `"1860"', add
label define year_lbl 1870 `"1870"', add
label define year_lbl 1880 `"1880"', add
label define year_lbl 1900 `"1900"', add
label define year_lbl 1910 `"1910"', add
label define year_lbl 1920 `"1920"', add
label define year_lbl 1930 `"1930"', add
label define year_lbl 1940 `"1940"', add
label define year_lbl 1950 `"1950"', add
label define year_lbl 1960 `"1960"', add
label define year_lbl 1970 `"1970"', add
label define year_lbl 1980 `"1980"', add
label define year_lbl 1990 `"1990"', add
label define year_lbl 2000 `"2000"', add
label define year_lbl 2001 `"2001"', add
label define year_lbl 2002 `"2002"', add
label define year_lbl 2003 `"2003"', add
label define year_lbl 2004 `"2004"', add
label define year_lbl 2005 `"2005"', add
label define year_lbl 2006 `"2006"', add
label define year_lbl 2007 `"2007"', add
label define year_lbl 2008 `"2008"', add
label define year_lbl 2009 `"2009"', add
label define year_lbl 2010 `"2010"', add
label define year_lbl 2011 `"2011"', add
label define year_lbl 2012 `"2012"', add
label define year_lbl 2013 `"2013"', add
label define year_lbl 2014 `"2014"', add
label define year_lbl 2015 `"2015"', add
label define year_lbl 2016 `"2016"', add
label define year_lbl 2017 `"2017"', add
label define year_lbl 2018 `"2018"', add
label define year_lbl 2019 `"2019"', add
label values year year_lbl

label define sample_lbl 201904 `"2015-2019, PRCS 5-year"'
label define sample_lbl 201903 `"2015-2019, ACS 5-year"', add
label define sample_lbl 201902 `"2019 PRCS"', add
label define sample_lbl 201901 `"2019 ACS"', add
label define sample_lbl 201804 `"2014-2018, PRCS 5-year"', add
label define sample_lbl 201803 `"2014-2018, ACS 5-year"', add
label define sample_lbl 201802 `"2018 PRCS"', add
label define sample_lbl 201801 `"2018 ACS"', add
label define sample_lbl 201704 `"2013-2017, PRCS 5-year"', add
label define sample_lbl 201703 `"2013-2017, ACS 5-year"', add
label define sample_lbl 201702 `"2017 PRCS"', add
label define sample_lbl 201701 `"2017 ACS"', add
label define sample_lbl 201604 `"2012-2016, PRCS 5-year"', add
label define sample_lbl 201603 `"2012-2016, ACS 5-year"', add
label define sample_lbl 201602 `"2016 PRCS"', add
label define sample_lbl 201601 `"2016 ACS"', add
label define sample_lbl 201504 `"2011-2015, PRCS 5-year"', add
label define sample_lbl 201503 `"2011-2015, ACS 5-year"', add
label define sample_lbl 201502 `"2015 PRCS"', add
label define sample_lbl 201501 `"2015 ACS"', add
label define sample_lbl 201404 `"2010-2014, PRCS 5-year"', add
label define sample_lbl 201403 `"2010-2014, ACS 5-year"', add
label define sample_lbl 201402 `"2014 PRCS"', add
label define sample_lbl 201401 `"2014 ACS"', add
label define sample_lbl 201306 `"2009-2013, PRCS 5-year"', add
label define sample_lbl 201305 `"2009-2013, ACS 5-year"', add
label define sample_lbl 201304 `"2011-2013, PRCS 3-year"', add
label define sample_lbl 201303 `"2011-2013, ACS 3-year"', add
label define sample_lbl 201302 `"2013 PRCS"', add
label define sample_lbl 201301 `"2013 ACS"', add
label define sample_lbl 201206 `"2008-2012, PRCS 5-year"', add
label define sample_lbl 201205 `"2008-2012, ACS 5-year"', add
label define sample_lbl 201204 `"2010-2012, PRCS 3-year"', add
label define sample_lbl 201203 `"2010-2012, ACS 3-year"', add
label define sample_lbl 201202 `"2012 PRCS"', add
label define sample_lbl 201201 `"2012 ACS"', add
label define sample_lbl 201106 `"2007-2011, PRCS 5-year"', add
label define sample_lbl 201105 `"2007-2011, ACS 5-year"', add
label define sample_lbl 201104 `"2009-2011, PRCS 3-year"', add
label define sample_lbl 201103 `"2009-2011, ACS 3-year"', add
label define sample_lbl 201102 `"2011 PRCS"', add
label define sample_lbl 201101 `"2011 ACS"', add
label define sample_lbl 201008 `"2010 Puerto Rico 10%"', add
label define sample_lbl 201007 `"2010 10%"', add
label define sample_lbl 201006 `"2006-2010, PRCS 5-year"', add
label define sample_lbl 201005 `"2006-2010, ACS 5-year"', add
label define sample_lbl 201004 `"2008-2010, PRCS 3-year"', add
label define sample_lbl 201003 `"2008-2010, ACS 3-year"', add
label define sample_lbl 201002 `"2010 PRCS"', add
label define sample_lbl 201001 `"2010 ACS"', add
label define sample_lbl 200906 `"2005-2009, PRCS 5-year"', add
label define sample_lbl 200905 `"2005-2009, ACS 5-year"', add
label define sample_lbl 200904 `"2007-2009, PRCS 3-year"', add
label define sample_lbl 200903 `"2007-2009, ACS 3-year"', add
label define sample_lbl 200902 `"2009 PRCS"', add
label define sample_lbl 200901 `"2009 ACS"', add
label define sample_lbl 200804 `"2006-2008, PRCS 3-year"', add
label define sample_lbl 200803 `"2006-2008, ACS 3-year"', add
label define sample_lbl 200802 `"2008 PRCS"', add
label define sample_lbl 200801 `"2008 ACS"', add
label define sample_lbl 200704 `"2005-2007, PRCS 3-year"', add
label define sample_lbl 200703 `"2005-2007, ACS 3-year"', add
label define sample_lbl 200702 `"2007 PRCS"', add
label define sample_lbl 200701 `"2007 ACS"', add
label define sample_lbl 200602 `"2006 PRCS"', add
label define sample_lbl 200601 `"2006 ACS"', add
label define sample_lbl 200502 `"2005 PRCS"', add
label define sample_lbl 200501 `"2005 ACS"', add
label define sample_lbl 200401 `"2004 ACS"', add
label define sample_lbl 200301 `"2003 ACS"', add
label define sample_lbl 200201 `"2002 ACS"', add
label define sample_lbl 200101 `"2001 ACS"', add
label define sample_lbl 200008 `"2000 Puerto Rico 1%"', add
label define sample_lbl 200007 `"2000 1%"', add
label define sample_lbl 200006 `"2000 Puerto Rico 1% sample (old version)"', add
label define sample_lbl 200005 `"2000 Puerto Rico 5%"', add
label define sample_lbl 200004 `"2000 ACS"', add
label define sample_lbl 200003 `"2000 Unweighted 1%"', add
label define sample_lbl 200002 `"2000 1% sample (old version)"', add
label define sample_lbl 200001 `"2000 5%"', add
label define sample_lbl 199007 `"1990 Puerto Rico 1%"', add
label define sample_lbl 199006 `"1990 Puerto Rico 5%"', add
label define sample_lbl 199005 `"1990 Labor Market Area"', add
label define sample_lbl 199004 `"1990 Elderly"', add
label define sample_lbl 199003 `"1990 Unweighted 1%"', add
label define sample_lbl 199002 `"1990 1%"', add
label define sample_lbl 199001 `"1990 5%"', add
label define sample_lbl 198007 `"1980 Puerto Rico 1%"', add
label define sample_lbl 198006 `"1980 Puerto Rico 5%"', add
label define sample_lbl 198005 `"1980 Detailed metro/non-metro"', add
label define sample_lbl 198004 `"1980 Labor Market Area"', add
label define sample_lbl 198003 `"1980 Urban/Rural"', add
label define sample_lbl 198002 `"1980 1%"', add
label define sample_lbl 198001 `"1980 5%"', add
label define sample_lbl 197009 `"1970 Puerto Rico Neighborhood"', add
label define sample_lbl 197008 `"1970 Puerto Rico Municipio"', add
label define sample_lbl 197007 `"1970 Puerto Rico State"', add
label define sample_lbl 197006 `"1970 Form 2 Neighborhood"', add
label define sample_lbl 197005 `"1970 Form 1 Neighborhood"', add
label define sample_lbl 197004 `"1970 Form 2 Metro"', add
label define sample_lbl 197003 `"1970 Form 1 Metro"', add
label define sample_lbl 197002 `"1970 Form 2 State"', add
label define sample_lbl 197001 `"1970 Form 1 State"', add
label define sample_lbl 196002 `"1960 5%"', add
label define sample_lbl 196001 `"1960 1%"', add
label define sample_lbl 195001 `"1950 1%"', add
label define sample_lbl 194002 `"1940 100% database"', add
label define sample_lbl 194001 `"1940 1%"', add
label define sample_lbl 193004 `"1930 100% database"', add
label define sample_lbl 193003 `"1930 Puerto Rico"', add
label define sample_lbl 193002 `"1930 5%"', add
label define sample_lbl 193001 `"1930 1%"', add
label define sample_lbl 192003 `"1920 100% database"', add
label define sample_lbl 192002 `"1920 Puerto Rico sample"', add
label define sample_lbl 192001 `"1920 1%"', add
label define sample_lbl 191004 `"1910 100% database"', add
label define sample_lbl 191003 `"1910 1.4% sample with oversamples"', add
label define sample_lbl 191002 `"1910 1%"', add
label define sample_lbl 191001 `"1910 Puerto Rico"', add
label define sample_lbl 190004 `"1900 100% database"', add
label define sample_lbl 190003 `"1900 1% sample with oversamples"', add
label define sample_lbl 190002 `"1900 1%"', add
label define sample_lbl 190001 `"1900 5%"', add
label define sample_lbl 188003 `"1880 100% database"', add
label define sample_lbl 188002 `"1880 10%"', add
label define sample_lbl 188001 `"1880 1%"', add
label define sample_lbl 187003 `"1870 100% database"', add
label define sample_lbl 187002 `"1870 1% sample with black oversample"', add
label define sample_lbl 187001 `"1870 1%"', add
label define sample_lbl 186003 `"1860 100% database"', add
label define sample_lbl 186002 `"1860 1% sample with black oversample"', add
label define sample_lbl 186001 `"1860 1%"', add
label define sample_lbl 185002 `"1850 100% database"', add
label define sample_lbl 185001 `"1850 1%"', add
label values sample sample_lbl

label define subsamp_lbl 0  `"First 1% subsample"'
label define subsamp_lbl 1  `"2nd 1% subsample"', add
label define subsamp_lbl 2  `"2"', add
label define subsamp_lbl 3  `"3"', add
label define subsamp_lbl 4  `"4"', add
label define subsamp_lbl 5  `"5"', add
label define subsamp_lbl 6  `"6"', add
label define subsamp_lbl 7  `"7"', add
label define subsamp_lbl 8  `"8"', add
label define subsamp_lbl 9  `"9"', add
label define subsamp_lbl 10 `"10"', add
label define subsamp_lbl 11 `"11"', add
label define subsamp_lbl 12 `"12"', add
label define subsamp_lbl 13 `"13"', add
label define subsamp_lbl 14 `"14"', add
label define subsamp_lbl 15 `"15"', add
label define subsamp_lbl 16 `"16"', add
label define subsamp_lbl 17 `"17"', add
label define subsamp_lbl 18 `"18"', add
label define subsamp_lbl 19 `"19"', add
label define subsamp_lbl 20 `"20"', add
label define subsamp_lbl 21 `"21"', add
label define subsamp_lbl 22 `"22"', add
label define subsamp_lbl 23 `"23"', add
label define subsamp_lbl 24 `"24"', add
label define subsamp_lbl 25 `"25"', add
label define subsamp_lbl 26 `"26"', add
label define subsamp_lbl 27 `"27"', add
label define subsamp_lbl 28 `"28"', add
label define subsamp_lbl 29 `"29"', add
label define subsamp_lbl 30 `"30"', add
label define subsamp_lbl 31 `"31"', add
label define subsamp_lbl 32 `"32"', add
label define subsamp_lbl 33 `"33"', add
label define subsamp_lbl 34 `"34"', add
label define subsamp_lbl 35 `"35"', add
label define subsamp_lbl 36 `"36"', add
label define subsamp_lbl 37 `"37"', add
label define subsamp_lbl 38 `"38"', add
label define subsamp_lbl 39 `"39"', add
label define subsamp_lbl 40 `"40"', add
label define subsamp_lbl 41 `"41"', add
label define subsamp_lbl 42 `"42"', add
label define subsamp_lbl 43 `"43"', add
label define subsamp_lbl 44 `"44"', add
label define subsamp_lbl 45 `"45"', add
label define subsamp_lbl 46 `"46"', add
label define subsamp_lbl 47 `"47"', add
label define subsamp_lbl 48 `"48"', add
label define subsamp_lbl 49 `"49"', add
label define subsamp_lbl 50 `"50"', add
label define subsamp_lbl 51 `"51"', add
label define subsamp_lbl 52 `"52"', add
label define subsamp_lbl 53 `"53"', add
label define subsamp_lbl 54 `"54"', add
label define subsamp_lbl 55 `"55"', add
label define subsamp_lbl 56 `"56"', add
label define subsamp_lbl 57 `"57"', add
label define subsamp_lbl 58 `"58"', add
label define subsamp_lbl 59 `"59"', add
label define subsamp_lbl 60 `"60"', add
label define subsamp_lbl 61 `"61"', add
label define subsamp_lbl 62 `"62"', add
label define subsamp_lbl 63 `"63"', add
label define subsamp_lbl 64 `"64"', add
label define subsamp_lbl 65 `"65"', add
label define subsamp_lbl 66 `"66"', add
label define subsamp_lbl 67 `"67"', add
label define subsamp_lbl 68 `"68"', add
label define subsamp_lbl 69 `"69"', add
label define subsamp_lbl 70 `"70"', add
label define subsamp_lbl 71 `"71"', add
label define subsamp_lbl 72 `"72"', add
label define subsamp_lbl 73 `"73"', add
label define subsamp_lbl 74 `"74"', add
label define subsamp_lbl 75 `"75"', add
label define subsamp_lbl 76 `"76"', add
label define subsamp_lbl 77 `"77"', add
label define subsamp_lbl 78 `"78"', add
label define subsamp_lbl 79 `"79"', add
label define subsamp_lbl 80 `"80"', add
label define subsamp_lbl 81 `"81"', add
label define subsamp_lbl 82 `"82"', add
label define subsamp_lbl 83 `"83"', add
label define subsamp_lbl 84 `"84"', add
label define subsamp_lbl 85 `"85"', add
label define subsamp_lbl 86 `"86"', add
label define subsamp_lbl 87 `"87"', add
label define subsamp_lbl 88 `"88"', add
label define subsamp_lbl 89 `"89"', add
label define subsamp_lbl 90 `"90"', add
label define subsamp_lbl 91 `"91"', add
label define subsamp_lbl 92 `"92"', add
label define subsamp_lbl 93 `"93"', add
label define subsamp_lbl 94 `"94"', add
label define subsamp_lbl 95 `"95"', add
label define subsamp_lbl 96 `"96"', add
label define subsamp_lbl 97 `"97"', add
label define subsamp_lbl 98 `"98"', add
label define subsamp_lbl 99 `"99"', add
label values subsamp subsamp_lbl

label define dwsize_lbl 3 `"3"'
label define dwsize_lbl 5 `"5"', add
label define dwsize_lbl 7 `"7"', add
label values dwsize dwsize_lbl

label define region_lbl 11 `"New England Division"'
label define region_lbl 12 `"Middle Atlantic Division"', add
label define region_lbl 13 `"Mixed Northeast Divisions"', add
label define region_lbl 21 `"East North Central Division"', add
label define region_lbl 22 `"West North Central Division"', add
label define region_lbl 23 `"Mixed Midwestern Divisions"', add
label define region_lbl 31 `"South Atlantic Division"', add
label define region_lbl 32 `"East South Central Division"', add
label define region_lbl 33 `"West South Central Division"', add
label define region_lbl 34 `"Mixed Southern Divisions"', add
label define region_lbl 41 `"Mountain Division"', add
label define region_lbl 42 `"Pacific Division"', add
label define region_lbl 43 `"Mixed Western Divisions"', add
label define region_lbl 91 `"Overseas Military/Military Installations"', add
label define region_lbl 92 `"PUMA boundaries cross state lines - Metro sample"', add
label define region_lbl 97 `"State not identified"', add
label define region_lbl 99 `"Not identified"', add
label values region region_lbl

label define stateicp_lbl 1  `"Connecticut"'
label define stateicp_lbl 2  `"Maine"', add
label define stateicp_lbl 3  `"Massachusetts"', add
label define stateicp_lbl 4  `"New Hampshire"', add
label define stateicp_lbl 5  `"Rhode Island"', add
label define stateicp_lbl 6  `"Vermont"', add
label define stateicp_lbl 11 `"Delaware"', add
label define stateicp_lbl 12 `"New Jersey"', add
label define stateicp_lbl 13 `"New York"', add
label define stateicp_lbl 14 `"Pennsylvania"', add
label define stateicp_lbl 21 `"Illinois"', add
label define stateicp_lbl 22 `"Indiana"', add
label define stateicp_lbl 23 `"Michigan"', add
label define stateicp_lbl 24 `"Ohio"', add
label define stateicp_lbl 25 `"Wisconsin"', add
label define stateicp_lbl 31 `"Iowa"', add
label define stateicp_lbl 32 `"Kansas"', add
label define stateicp_lbl 33 `"Minnesota"', add
label define stateicp_lbl 34 `"Missouri"', add
label define stateicp_lbl 35 `"Nebraska"', add
label define stateicp_lbl 36 `"North Dakota"', add
label define stateicp_lbl 37 `"South Dakota"', add
label define stateicp_lbl 40 `"Virginia"', add
label define stateicp_lbl 41 `"Alabama"', add
label define stateicp_lbl 42 `"Arkansas"', add
label define stateicp_lbl 43 `"Florida"', add
label define stateicp_lbl 44 `"Georgia"', add
label define stateicp_lbl 45 `"Louisiana"', add
label define stateicp_lbl 46 `"Mississippi"', add
label define stateicp_lbl 47 `"North Carolina"', add
label define stateicp_lbl 48 `"South Carolina"', add
label define stateicp_lbl 49 `"Texas"', add
label define stateicp_lbl 51 `"Kentucky"', add
label define stateicp_lbl 52 `"Maryland"', add
label define stateicp_lbl 53 `"Oklahoma"', add
label define stateicp_lbl 54 `"Tennessee"', add
label define stateicp_lbl 56 `"West Virginia"', add
label define stateicp_lbl 61 `"Arizona"', add
label define stateicp_lbl 62 `"Colorado"', add
label define stateicp_lbl 63 `"Idaho"', add
label define stateicp_lbl 64 `"Montana"', add
label define stateicp_lbl 65 `"Nevada"', add
label define stateicp_lbl 66 `"New Mexico"', add
label define stateicp_lbl 67 `"Utah"', add
label define stateicp_lbl 68 `"Wyoming"', add
label define stateicp_lbl 71 `"California"', add
label define stateicp_lbl 72 `"Oregon"', add
label define stateicp_lbl 73 `"Washington"', add
label define stateicp_lbl 81 `"Alaska"', add
label define stateicp_lbl 82 `"Hawaii"', add
label define stateicp_lbl 83 `"Puerto Rico"', add
label define stateicp_lbl 91 `"Dakota Territory"', add
label define stateicp_lbl 92 `"Indian Territory"', add
label define stateicp_lbl 96 `"State groupings (1980 Urban/rural sample)"', add
label define stateicp_lbl 97 `"Overseas Military Installations"', add
label define stateicp_lbl 98 `"District of Columbia"', add
label define stateicp_lbl 99 `"State not identified"', add
label values stateicp stateicp_lbl

label define statefip_lbl 1  `"Alabama"'
label define statefip_lbl 2  `"Alaska"', add
label define statefip_lbl 4  `"Arizona"', add
label define statefip_lbl 5  `"Arkansas"', add
label define statefip_lbl 6  `"California"', add
label define statefip_lbl 8  `"Colorado"', add
label define statefip_lbl 9  `"Connecticut"', add
label define statefip_lbl 10 `"Delaware"', add
label define statefip_lbl 11 `"District of Columbia"', add
label define statefip_lbl 12 `"Florida"', add
label define statefip_lbl 13 `"Georgia"', add
label define statefip_lbl 15 `"Hawaii"', add
label define statefip_lbl 16 `"Idaho"', add
label define statefip_lbl 17 `"Illinois"', add
label define statefip_lbl 18 `"Indiana"', add
label define statefip_lbl 19 `"Iowa"', add
label define statefip_lbl 20 `"Kansas"', add
label define statefip_lbl 21 `"Kentucky"', add
label define statefip_lbl 22 `"Louisiana"', add
label define statefip_lbl 23 `"Maine"', add
label define statefip_lbl 24 `"Maryland"', add
label define statefip_lbl 25 `"Massachusetts"', add
label define statefip_lbl 26 `"Michigan"', add
label define statefip_lbl 27 `"Minnesota"', add
label define statefip_lbl 28 `"Mississippi"', add
label define statefip_lbl 29 `"Missouri"', add
label define statefip_lbl 30 `"Montana"', add
label define statefip_lbl 31 `"Nebraska"', add
label define statefip_lbl 32 `"Nevada"', add
label define statefip_lbl 33 `"New Hampshire"', add
label define statefip_lbl 34 `"New Jersey"', add
label define statefip_lbl 35 `"New Mexico"', add
label define statefip_lbl 36 `"New York"', add
label define statefip_lbl 37 `"North Carolina"', add
label define statefip_lbl 38 `"North Dakota"', add
label define statefip_lbl 39 `"Ohio"', add
label define statefip_lbl 40 `"Oklahoma"', add
label define statefip_lbl 41 `"Oregon"', add
label define statefip_lbl 42 `"Pennsylvania"', add
label define statefip_lbl 44 `"Rhode Island"', add
label define statefip_lbl 45 `"South Carolina"', add
label define statefip_lbl 46 `"South Dakota"', add
label define statefip_lbl 47 `"Tennessee"', add
label define statefip_lbl 48 `"Texas"', add
label define statefip_lbl 49 `"Utah"', add
label define statefip_lbl 50 `"Vermont"', add
label define statefip_lbl 51 `"Virginia"', add
label define statefip_lbl 53 `"Washington"', add
label define statefip_lbl 54 `"West Virginia"', add
label define statefip_lbl 55 `"Wisconsin"', add
label define statefip_lbl 56 `"Wyoming"', add
label define statefip_lbl 61 `"Maine-New Hampshire-Vermont"', add
label define statefip_lbl 62 `"Massachusetts-Rhode Island"', add
label define statefip_lbl 63 `"Minnesota-Iowa-Missouri-Kansas-Nebraska-S. Dakota-N. Dakota"', add
label define statefip_lbl 64 `"Maryland-Delaware"', add
label define statefip_lbl 65 `"Montana-Idaho-Wyoming"', add
label define statefip_lbl 66 `"Utah-Nevada"', add
label define statefip_lbl 67 `"Arizona-New Mexico"', add
label define statefip_lbl 68 `"Alaska-Hawaii"', add
label define statefip_lbl 72 `"Puerto Rico"', add
label define statefip_lbl 78 `"Virgin Islands (in 1990 internal census data)"', add
label define statefip_lbl 93 `"Dakota Territory"', add
label define statefip_lbl 94 `"Indian Territory"', add
label define statefip_lbl 97 `"Overseas Military Installations"', add
label define statefip_lbl 99 `"State not identified"', add
label values statefip statefip_lbl

label define sea_lbl 1   `"SEA 001, counties:"'
label define sea_lbl 2   `"SEA 002:"', add
label define sea_lbl 3   `"SEA 003:"', add
label define sea_lbl 4   `"SEA 004:"', add
label define sea_lbl 5   `"SEA 005:"', add
label define sea_lbl 7   `"SEA 007:"', add
label define sea_lbl 8   `"SEA 008:"', add
label define sea_lbl 9   `"SEA 009:"', add
label define sea_lbl 10  `"SEA 010:"', add
label define sea_lbl 11  `"SEA 011:"', add
label define sea_lbl 13  `"SEA 013:"', add
label define sea_lbl 14  `"SEA 014, counties:"', add
label define sea_lbl 15  `"SEA 015:"', add
label define sea_lbl 16  `"SEA 016:"', add
label define sea_lbl 17  `"SEA 017:"', add
label define sea_lbl 18  `"SEA 018, counties:"', add
label define sea_lbl 19  `"SEA 019:"', add
label define sea_lbl 20  `"SEA 020:"', add
label define sea_lbl 21  `"SEA 021:"', add
label define sea_lbl 22  `"SEA 022:"', add
label define sea_lbl 23  `"SEA 023:"', add
label define sea_lbl 24  `"SEA 024:"', add
label define sea_lbl 25  `"SEA 025:"', add
label define sea_lbl 26  `"SEA 026:"', add
label define sea_lbl 27  `"SEA 027:"', add
label define sea_lbl 29  `"SEA 029:"', add
label define sea_lbl 30  `"SEA 030, counties:"', add
label define sea_lbl 31  `"SEA 031:"', add
label define sea_lbl 32  `"SEA 032:"', add
label define sea_lbl 33  `"SEA 033:"', add
label define sea_lbl 34  `"SEA 034:"', add
label define sea_lbl 35  `"SEA 035:"', add
label define sea_lbl 36  `"SEA 036:"', add
label define sea_lbl 37  `"SEA 037:"', add
label define sea_lbl 38  `"SEA 038:"', add
label define sea_lbl 39  `"SEA 039:"', add
label define sea_lbl 40  `"SEA 040:"', add
label define sea_lbl 41  `"SEA 041:"', add
label define sea_lbl 42  `"SEA 042:"', add
label define sea_lbl 43  `"SEA 043:"', add
label define sea_lbl 44  `"SEA 044:"', add
label define sea_lbl 45  `"SEA 045:"', add
label define sea_lbl 46  `"SEA 046:"', add
label define sea_lbl 47  `"SEA 047, counties:"', add
label define sea_lbl 48  `"SEA 048:"', add
label define sea_lbl 50  `"SEA 050:"', add
label define sea_lbl 51  `"SEA 051:"', add
label define sea_lbl 52  `"SEA 052:"', add
label define sea_lbl 53  `"SEA 053:"', add
label define sea_lbl 54  `"SEA 054, counties:"', add
label define sea_lbl 55  `"SEA 055:"', add
label define sea_lbl 56  `"SEA 056:"', add
label define sea_lbl 57  `"SEA 057:"', add
label define sea_lbl 58  `"SEA 058:"', add
label define sea_lbl 59  `"SEA 059, counties:"', add
label define sea_lbl 60  `"SEA 060:"', add
label define sea_lbl 61  `"SEA 061"', add
label define sea_lbl 62  `"SEA 062, counties:"', add
label define sea_lbl 63  `"SEA 063:"', add
label define sea_lbl 64  `"SEA 064:"', add
label define sea_lbl 65  `"SEA 065:"', add
label define sea_lbl 66  `"SEA 066:"', add
label define sea_lbl 67  `"SEA 067:"', add
label define sea_lbl 68  `"SEA 068:"', add
label define sea_lbl 69  `"SEA 069:"', add
label define sea_lbl 70  `"SEA 070:"', add
label define sea_lbl 71  `"SEA 071, counties:"', add
label define sea_lbl 72  `"SEA 072:"', add
label define sea_lbl 73  `"SEA 073:"', add
label define sea_lbl 74  `"SEA 074:"', add
label define sea_lbl 75  `"SEA 075:"', add
label define sea_lbl 76  `"SEA 076:"', add
label define sea_lbl 77  `"SEA 077:"', add
label define sea_lbl 79  `"SEA 079:"', add
label define sea_lbl 80  `"SEA 080:"', add
label define sea_lbl 81  `"SEA 081:"', add
label define sea_lbl 83  `"SEA 083:"', add
label define sea_lbl 84  `"SEA 084:"', add
label define sea_lbl 85  `"SEA 085:"', add
label define sea_lbl 86  `"SEA 086:"', add
label define sea_lbl 87  `"SEA 087, counties:"', add
label define sea_lbl 88  `"SEA 088:"', add
label define sea_lbl 89  `"SEA 089:"', add
label define sea_lbl 90  `"SEA 090:"', add
label define sea_lbl 91  `"SEA 091:"', add
label define sea_lbl 92  `"SEA 092, counties:"', add
label define sea_lbl 93  `"SEA 093:"', add
label define sea_lbl 94  `"SEA 094:"', add
label define sea_lbl 95  `"SEA 095:"', add
label define sea_lbl 96  `"SEA 096:"', add
label define sea_lbl 97  `"SEA 097:"', add
label define sea_lbl 98  `"SEA 098:"', add
label define sea_lbl 99  `"SEA 099:"', add
label define sea_lbl 100 `"SEA 100:"', add
label define sea_lbl 101 `"SEA 101:"', add
label define sea_lbl 102 `"SEA 102:"', add
label define sea_lbl 103 `"SEA 103:"', add
label define sea_lbl 104 `"SEA 104:"', add
label define sea_lbl 105 `"SEA 105:"', add
label define sea_lbl 106 `"SEA 106:"', add
label define sea_lbl 107 `"SEA 107:"', add
label define sea_lbl 108 `"SEA 108:"', add
label define sea_lbl 109 `"SEA 109:"', add
label define sea_lbl 110 `"SEA 110, counties:"', add
label define sea_lbl 111 `"SEA 111:"', add
label define sea_lbl 112 `"SEA 112:"', add
label define sea_lbl 113 `"SEA 113:"', add
label define sea_lbl 114 `"SEA 114:"', add
label define sea_lbl 115 `"SEA 115:"', add
label define sea_lbl 116 `"SEA 116:"', add
label define sea_lbl 117 `"SEA 117:"', add
label define sea_lbl 118 `"SEA 118:"', add
label define sea_lbl 119 `"SEA 119:"', add
label define sea_lbl 120 `"SEA 120:"', add
label define sea_lbl 121 `"SEA 121:"', add
label define sea_lbl 122 `"SEA 122:"', add
label define sea_lbl 123 `"SEA 123:"', add
label define sea_lbl 124 `"SEA 124:"', add
label define sea_lbl 125 `"SEA 125, counties:"', add
label define sea_lbl 126 `"SEA 126:"', add
label define sea_lbl 127 `"SEA 127:"', add
label define sea_lbl 128 `"SEA 128:"', add
label define sea_lbl 129 `"SEA 129:"', add
label define sea_lbl 130 `"SEA 130:"', add
label define sea_lbl 131 `"SEA 131:"', add
label define sea_lbl 132 `"SEA 132:"', add
label define sea_lbl 133 `"SEA 133:"', add
label define sea_lbl 135 `"SEA 135:"', add
label define sea_lbl 136 `"SEA 136:"', add
label define sea_lbl 137 `"SEA 137:"', add
label define sea_lbl 138 `"SEA 138, counties:"', add
label define sea_lbl 139 `"SEA 139:"', add
label define sea_lbl 140 `"SEA 140:"', add
label define sea_lbl 141 `"SEA 141:"', add
label define sea_lbl 142 `"SEA 142:"', add
label define sea_lbl 143 `"SEA 143:"', add
label define sea_lbl 145 `"SEA 145:"', add
label define sea_lbl 146 `"SEA 146:"', add
label define sea_lbl 147 `"SEA 147:"', add
label define sea_lbl 148 `"SEA 148:"', add
label define sea_lbl 149 `"SEA 149:"', add
label define sea_lbl 150 `"SEA 150, counties:"', add
label define sea_lbl 151 `"SEA 151:"', add
label define sea_lbl 152 `"SEA 152:"', add
label define sea_lbl 153 `"SEA 153:"', add
label define sea_lbl 154 `"SEA 154:"', add
label define sea_lbl 155 `"SEA 155:"', add
label define sea_lbl 156 `"SEA 156:"', add
label define sea_lbl 157 `"SEA 157:"', add
label define sea_lbl 158 `"SEA 158:"', add
label define sea_lbl 159 `"SEA 159:"', add
label define sea_lbl 160 `"SEA 160:"', add
label define sea_lbl 162 `"SEA 162:"', add
label define sea_lbl 163 `"SEA 163, parishes:"', add
label define sea_lbl 164 `"SEA 164:"', add
label define sea_lbl 165 `"SEA 165:"', add
label define sea_lbl 166 `"SEA 166:"', add
label define sea_lbl 167 `"SEA 167:"', add
label define sea_lbl 168 `"SEA 168:"', add
label define sea_lbl 169 `"SEA 169:"', add
label define sea_lbl 170 `"SEA 170:"', add
label define sea_lbl 171 `"SEA 171:"', add
label define sea_lbl 172 `"SEA 172:"', add
label define sea_lbl 173 `"SEA 173, counties:"', add
label define sea_lbl 175 `"SEA 175:"', add
label define sea_lbl 176 `"SEA 176:"', add
label define sea_lbl 177 `"SEA 177:"', add
label define sea_lbl 178 `"SEA 178, counties:"', add
label define sea_lbl 179 `"SEA 179:"', add
label define sea_lbl 180 `"SEA 180:"', add
label define sea_lbl 181 `"SEA 181:"', add
label define sea_lbl 182 `"SEA 182:"', add
label define sea_lbl 183 `"SEA 183:"', add
label define sea_lbl 184 `"SEA 184:"', add
label define sea_lbl 185 `"SEA 185, counties:"', add
label define sea_lbl 186 `"SEA 186:"', add
label define sea_lbl 187 `"SEA 187:"', add
label define sea_lbl 188 `"SEA 188:"', add
label define sea_lbl 189 `"SEA 189:"', add
label define sea_lbl 190 `"SEA 190:"', add
label define sea_lbl 191 `"SEA 191:"', add
label define sea_lbl 192 `"SEA 192, counties:"', add
label define sea_lbl 193 `"SEA 193:"', add
label define sea_lbl 194 `"SEA 194:"', add
label define sea_lbl 195 `"SEA 195:"', add
label define sea_lbl 196 `"SEA 196:"', add
label define sea_lbl 197 `"SEA 197:"', add
label define sea_lbl 198 `"SEA 198:"', add
label define sea_lbl 199 `"SEA 199:"', add
label define sea_lbl 200 `"SEA 200:"', add
label define sea_lbl 201 `"SEA 201:"', add
label define sea_lbl 202 `"SEA 202:"', add
label define sea_lbl 203 `"SEA 203:"', add
label define sea_lbl 204 `"SEA 204:"', add
label define sea_lbl 205 `"SEA 205:"', add
label define sea_lbl 206 `"SEA 206:"', add
label define sea_lbl 207 `"SEA 207:"', add
label define sea_lbl 208 `"SEA 208:"', add
label define sea_lbl 209 `"SEA 209:"', add
label define sea_lbl 210 `"SEA 210:"', add
label define sea_lbl 211 `"SEA 211:"', add
label define sea_lbl 212 `"SEA 212, counties:"', add
label define sea_lbl 213 `"SEA 213:"', add
label define sea_lbl 214 `"SEA 214:"', add
label define sea_lbl 215 `"SEA 215:"', add
label define sea_lbl 216 `"SEA 216:"', add
label define sea_lbl 217 `"SEA 217:"', add
label define sea_lbl 218 `"SEA 218:"', add
label define sea_lbl 219 `"SEA 219:"', add
label define sea_lbl 220 `"SEA 220:"', add
label define sea_lbl 221 `"SEA 221:"', add
label define sea_lbl 222 `"SEA 222, counties:"', add
label define sea_lbl 223 `"SEA 223:"', add
label define sea_lbl 224 `"SEA 224:"', add
label define sea_lbl 225 `"SEA 225:"', add
label define sea_lbl 226 `"SEA 226:"', add
label define sea_lbl 227 `"SEA 227:"', add
label define sea_lbl 228 `"SEA 228:"', add
label define sea_lbl 229 `"SEA 229:"', add
label define sea_lbl 230 `"SEA 230:"', add
label define sea_lbl 231 `"SEA 231:"', add
label define sea_lbl 232 `"SEA 232, counties:"', add
label define sea_lbl 233 `"SEA 233:"', add
label define sea_lbl 234 `"SEA 234:"', add
label define sea_lbl 235 `"SEA 235:"', add
label define sea_lbl 236 `"SEA 236:"', add
label define sea_lbl 237 `"SEA 237:"', add
label define sea_lbl 238 `"SEA 238:"', add
label define sea_lbl 239 `"SEA 239:"', add
label define sea_lbl 240 `"SEA 240:"', add
label define sea_lbl 242 `"SEA 242:"', add
label define sea_lbl 243 `"SEA 243:"', add
label define sea_lbl 244 `"SEA 244:"', add
label define sea_lbl 245 `"SEA 245, counties:"', add
label define sea_lbl 246 `"SEA 246:"', add
label define sea_lbl 247 `"SEA 247:"', add
label define sea_lbl 248 `"SEA 248:"', add
label define sea_lbl 249 `"SEA 249:"', add
label define sea_lbl 251 `"SEA 251, counties:"', add
label define sea_lbl 253 `"SEA 253:"', add
label define sea_lbl 254 `"SEA 254:"', add
label define sea_lbl 256 `"SEA 256:"', add
label define sea_lbl 257 `"SEA 257:"', add
label define sea_lbl 258 `"SEA 258:"', add
label define sea_lbl 259 `"SEA 259:"', add
label define sea_lbl 260 `"SEA 260:"', add
label define sea_lbl 261 `"SEA 261, counties:"', add
label define sea_lbl 262 `"SEA 262, counties:"', add
label define sea_lbl 263 `"SEA 263:"', add
label define sea_lbl 264 `"SEA 264:"', add
label define sea_lbl 265 `"SEA 265, counties:"', add
label define sea_lbl 266 `"SEA 266:"', add
label define sea_lbl 267 `"SEA 267:"', add
label define sea_lbl 268 `"SEA 268:"', add
label define sea_lbl 269 `"SEA 269:"', add
label define sea_lbl 270 `"SEA 270:"', add
label define sea_lbl 271 `"SEA 271:"', add
label define sea_lbl 273 `"SEA 273, counties:"', add
label define sea_lbl 274 `"SEA 274:"', add
label define sea_lbl 275 `"SEA 275:"', add
label define sea_lbl 276 `"SEA 276:"', add
label define sea_lbl 277 `"SEA 277, counties:"', add
label define sea_lbl 278 `"SEA 278:"', add
label define sea_lbl 279 `"SEA 279:"', add
label define sea_lbl 280 `"SEA 280:"', add
label define sea_lbl 281 `"SEA 281:"', add
label define sea_lbl 282 `"SEA 282:"', add
label define sea_lbl 283 `"SEA 283:"', add
label define sea_lbl 284 `"SEA 284:"', add
label define sea_lbl 285 `"SEA 285:"', add
label define sea_lbl 286 `"SEA 286:"', add
label define sea_lbl 287 `"SEA 287:"', add
label define sea_lbl 288 `"SEA 288:"', add
label define sea_lbl 289 `"SEA 289:"', add
label define sea_lbl 290 `"SEA 290:"', add
label define sea_lbl 291 `"SEA 291:"', add
label define sea_lbl 292 `"SEA 292:"', add
label define sea_lbl 293 `"SEA 293:"', add
label define sea_lbl 294 `"SEA 294, counties:"', add
label define sea_lbl 295 `"SEA 295:"', add
label define sea_lbl 296 `"SEA 296:"', add
label define sea_lbl 298 `"SEA 298:"', add
label define sea_lbl 299 `"SEA 299:"', add
label define sea_lbl 300 `"SEA 300:"', add
label define sea_lbl 301 `"SEA 301:"', add
label define sea_lbl 302 `"SEA 302:"', add
label define sea_lbl 303 `"SEA 303:"', add
label define sea_lbl 304 `"SEA 304:"', add
label define sea_lbl 305 `"SEA 305:"', add
label define sea_lbl 306 `"SEA 306:"', add
label define sea_lbl 307 `"SEA 307:"', add
label define sea_lbl 308 `"SEA 308:"', add
label define sea_lbl 309 `"SEA 309:"', add
label define sea_lbl 310 `"SEA 310:"', add
label define sea_lbl 311 `"SEA 311, counties:"', add
label define sea_lbl 314 `"SEA 314:"', add
label define sea_lbl 315 `"SEA 315:"', add
label define sea_lbl 317 `"SEA 317:"', add
label define sea_lbl 318 `"SEA 318, counties:"', add
label define sea_lbl 319 `"SEA 319:"', add
label define sea_lbl 320 `"SEA 320:"', add
label define sea_lbl 321 `"SEA 321:"', add
label define sea_lbl 322 `"SEA 322:"', add
label define sea_lbl 323 `"SEA 323:"', add
label define sea_lbl 324 `"SEA 324:"', add
label define sea_lbl 325 `"SEA 325:"', add
label define sea_lbl 326 `"SEA 326:"', add
label define sea_lbl 327 `"SEA 327:"', add
label define sea_lbl 328 `"SEA 328:"', add
label define sea_lbl 329 `"SEA 329:"', add
label define sea_lbl 330 `"SEA 330:"', add
label define sea_lbl 331 `"SEA 331:"', add
label define sea_lbl 332 `"SEA 332:"', add
label define sea_lbl 333 `"SEA 333:"', add
label define sea_lbl 334 `"SEA 334:"', add
label define sea_lbl 335 `"SEA 335:"', add
label define sea_lbl 336 `"SEA 336:"', add
label define sea_lbl 337 `"SEA 337:"', add
label define sea_lbl 339 `"SEA 339:"', add
label define sea_lbl 340 `"SEA 340, counties:"', add
label define sea_lbl 341 `"SEA 341:"', add
label define sea_lbl 342 `"SEA 342:"', add
label define sea_lbl 343 `"SEA 343:"', add
label define sea_lbl 344 `"SEA 344:"', add
label define sea_lbl 345 `"SEA 345:"', add
label define sea_lbl 346 `"SEA 346:"', add
label define sea_lbl 347 `"SEA 347:"', add
label define sea_lbl 348 `"SEA 348:"', add
label define sea_lbl 349 `"SEA 349:"', add
label define sea_lbl 350 `"SEA 350:"', add
label define sea_lbl 352 `"SEA 352:"', add
label define sea_lbl 353 `"SEA 353, counties:"', add
label define sea_lbl 354 `"SEA 354:"', add
label define sea_lbl 355 `"SEA 355:"', add
label define sea_lbl 356 `"SEA 356:"', add
label define sea_lbl 357 `"SEA 357:"', add
label define sea_lbl 358 `"SEA 358:"', add
label define sea_lbl 360 `"SEA 360, counties:"', add
label define sea_lbl 361 `"SEA 361:"', add
label define sea_lbl 362 `"SEA 362:"', add
label define sea_lbl 363 `"SEA 363:"', add
label define sea_lbl 364 `"SEA 364:"', add
label define sea_lbl 365 `"SEA 365:"', add
label define sea_lbl 366 `"SEA 366:"', add
label define sea_lbl 367 `"SEA 367:"', add
label define sea_lbl 368 `"SEA 368:"', add
label define sea_lbl 369 `"SEA 369:"', add
label define sea_lbl 370 `"SEA 370:"', add
label define sea_lbl 371 `"SEA 371:"', add
label define sea_lbl 372 `"SEA 372:"', add
label define sea_lbl 373 `"SEA 373:"', add
label define sea_lbl 374 `"SEA 374:"', add
label define sea_lbl 375 `"SEA 375:"', add
label define sea_lbl 376 `"SEA 376:"', add
label define sea_lbl 377 `"SEA 377:"', add
label define sea_lbl 378 `"SEA 378:"', add
label define sea_lbl 379 `"SEA 379:"', add
label define sea_lbl 380 `"SEA 380:"', add
label define sea_lbl 381 `"SEA 381:"', add
label define sea_lbl 382 `"SEA 382, counties:"', add
label define sea_lbl 384 `"SEA 384, counties:"', add
label define sea_lbl 385 `"SEA 385:"', add
label define sea_lbl 386 `"SEA 386:"', add
label define sea_lbl 387 `"SEA 387:"', add
label define sea_lbl 388 `"SEA 388:"', add
label define sea_lbl 389 `"SEA 389:"', add
label define sea_lbl 390 `"SEA 390:"', add
label define sea_lbl 391 `"SEA 391:"', add
label define sea_lbl 392 `"SEA 392:"', add
label define sea_lbl 393 `"SEA 393:"', add
label define sea_lbl 394 `"SEA 394:"', add
label define sea_lbl 395 `"SEA 395, counties:"', add
label define sea_lbl 396 `"SEA 396:"', add
label define sea_lbl 398 `"SEA 398:"', add
label define sea_lbl 402 `"SEA 402, counties:"', add
label define sea_lbl 403 `"SEA 403:"', add
label define sea_lbl 404 `"SEA 404:"', add
label define sea_lbl 405 `"SEA 405:"', add
label define sea_lbl 406 `"SEA 406:"', add
label define sea_lbl 407 `"SEA 407:"', add
label define sea_lbl 408 `"SEA 408:"', add
label define sea_lbl 409 `"SEA 409:"', add
label define sea_lbl 410 `"SEA 410:"', add
label define sea_lbl 411 `"SEA 411:"', add
label define sea_lbl 412 `"SEA 412:"', add
label define sea_lbl 413 `"SEA 413:"', add
label define sea_lbl 414 `"SEA 414:"', add
label define sea_lbl 415 `"SEA 415, counties:"', add
label define sea_lbl 416 `"SEA 416:"', add
label define sea_lbl 418 `"SEA 418:"', add
label define sea_lbl 420 `"SEA 420:"', add
label define sea_lbl 421 `"SEA 421:"', add
label define sea_lbl 422 `"SEA 422:"', add
label define sea_lbl 425 `"SEA 425:"', add
label define sea_lbl 426 `"SEA 426:"', add
label define sea_lbl 427 `"SEA 427:"', add
label define sea_lbl 428 `"SEA 428:"', add
label define sea_lbl 429 `"SEA 429:"', add
label define sea_lbl 430 `"SEA 430:"', add
label define sea_lbl 431 `"SEA 431:"', add
label define sea_lbl 432 `"SEA 432:"', add
label define sea_lbl 433 `"SEA 433:"', add
label define sea_lbl 434 `"SEA 434:"', add
label define sea_lbl 435 `"SEA 435:"', add
label define sea_lbl 436 `"SEA 436:"', add
label define sea_lbl 437 `"SEA 437:"', add
label define sea_lbl 438 `"SEA 438:"', add
label define sea_lbl 439 `"SEA 439:"', add
label define sea_lbl 440 `"SEA 440:"', add
label define sea_lbl 441 `"SEA 441:"', add
label define sea_lbl 442 `"SEA 442:"', add
label define sea_lbl 443 `"SEA 443, counties:"', add
label define sea_lbl 444 `"SEA 444:"', add
label define sea_lbl 445 `"SEA 445:"', add
label define sea_lbl 446 `"SEA 446:"', add
label define sea_lbl 447 `"SEA 447, counties:"', add
label define sea_lbl 448 `"SEA 448:"', add
label define sea_lbl 449 `"SEA 449, counties:"', add
label define sea_lbl 450 `"SEA 450:"', add
label define sea_lbl 451 `"SEA 451:"', add
label define sea_lbl 452 `"SEA 452:"', add
label define sea_lbl 453 `"SEA 453:"', add
label define sea_lbl 454 `"SEA 454:"', add
label define sea_lbl 455 `"SEA 455:"', add
label define sea_lbl 456 `"SEA 456:"', add
label define sea_lbl 457 `"SEA 457:"', add
label define sea_lbl 458 `"SEA 458:"', add
label define sea_lbl 459 `"SEA 459:"', add
label define sea_lbl 460 `"SEA 460:"', add
label define sea_lbl 461 `"SEA 461:"', add
label define sea_lbl 462 `"SEA 462:"', add
label define sea_lbl 464 `"SEA 464, counties:"', add
label define sea_lbl 465 `"SEA 465:"', add
label define sea_lbl 466 `"SEA 466:"', add
label define sea_lbl 467 `"SEA 467:"', add
label define sea_lbl 468 `"SEA 468:"', add
label define sea_lbl 469 `"SEA 469:"', add
label define sea_lbl 470 `"SEA 470:"', add
label define sea_lbl 471 `"SEA 471:"', add
label define sea_lbl 473 `"SEA 473:"', add
label define sea_lbl 474 `"SEA 474:"', add
label define sea_lbl 475 `"SEA 475:"', add
label define sea_lbl 476 `"SEA 476:"', add
label define sea_lbl 477 `"SEA 477, counties:"', add
label define sea_lbl 478 `"SEA 478:"', add
label define sea_lbl 479 `"SEA 479:"', add
label define sea_lbl 480 `"SEA 480:"', add
label define sea_lbl 481 `"SEA 481:"', add
label define sea_lbl 482 `"SEA 482:"', add
label define sea_lbl 483 `"SEA 483:"', add
label define sea_lbl 484 `"SEA 484:"', add
label define sea_lbl 485 `"SEA 485:"', add
label define sea_lbl 487 `"SEA 487, counties:"', add
label define sea_lbl 488 `"SEA 488:"', add
label define sea_lbl 489 `"SEA 489:"', add
label define sea_lbl 490 `"SEA 490:"', add
label define sea_lbl 491 `"SEA 491:"', add
label define sea_lbl 492 `"SEA 492:"', add
label define sea_lbl 493 `"SEA 493:"', add
label define sea_lbl 494 `"SEA 494:"', add
label define sea_lbl 495 `"SEA 495:"', add
label define sea_lbl 496 `"SEA 496:"', add
label define sea_lbl 497 `"SEA 497:"', add
label define sea_lbl 498 `"SEA 498:"', add
label define sea_lbl 500 `"SEA 500, counties:"', add
label define sea_lbl 501 `"SEA 501:"', add
label define sea_lbl 502 `"SEA 502:"', add
label define sea_lbl 990 `"Alaska"', add
label define sea_lbl 991 `"Hawaii"', add
label define sea_lbl 992 `"Cherokee Nation"', add
label define sea_lbl 999 `"Military Reservations"', add
label values sea sea_lbl

label define metro_lbl 0 `"Metropolitan status indeterminable (mixed)"'
label define metro_lbl 1 `"Not in metropolitan area"', add
label define metro_lbl 2 `"In central/principal city"', add
label define metro_lbl 3 `"Not in central/principal city"', add
label define metro_lbl 4 `"Central/principal city status indeterminable (mixed)"', add
label values metro metro_lbl

label define metarea_lbl 0    `"Not identifiable or not in an MSA"'
label define metarea_lbl 40   `"Abilene, TX"', add
label define metarea_lbl 60   `"Aguadilla, PR"', add
label define metarea_lbl 80   `"Akron, OH"', add
label define metarea_lbl 120  `"Albany, GA"', add
label define metarea_lbl 160  `"Albany-Schenectady-Troy, NY"', add
label define metarea_lbl 200  `"Albuquerque, NM"', add
label define metarea_lbl 220  `"Alexandria, LA"', add
label define metarea_lbl 240  `"Allentown-Bethlehem-Easton, PA/NJ"', add
label define metarea_lbl 280  `"Altoona, PA"', add
label define metarea_lbl 320  `"Amarillo, TX"', add
label define metarea_lbl 380  `"Anchorage, AK"', add
label define metarea_lbl 400  `"Anderson, IN"', add
label define metarea_lbl 440  `"Ann Arbor, MI"', add
label define metarea_lbl 450  `"Anniston, AL"', add
label define metarea_lbl 460  `"Appleton-Oshkosh-Neenah, WI"', add
label define metarea_lbl 470  `"Arecibo, PR"', add
label define metarea_lbl 480  `"Asheville, NC"', add
label define metarea_lbl 500  `"Athens, GA"', add
label define metarea_lbl 520  `"Atlanta, GA"', add
label define metarea_lbl 560  `"Atlantic City, NJ"', add
label define metarea_lbl 580  `"Auburn-Opelika, AL"', add
label define metarea_lbl 600  `"Augusta-Aiken, GA/SC"', add
label define metarea_lbl 640  `"Austin, TX"', add
label define metarea_lbl 680  `"Bakersfield, CA"', add
label define metarea_lbl 720  `"Baltimore, MD"', add
label define metarea_lbl 730  `"Bangor, ME"', add
label define metarea_lbl 740  `"Barnstable-Yarmouth, MA"', add
label define metarea_lbl 760  `"Baton Rouge, LA"', add
label define metarea_lbl 780  `"Battle Creek, MI"', add
label define metarea_lbl 840  `"Beaumont-Port Arthur-Orange, TX"', add
label define metarea_lbl 860  `"Bellingham, WA"', add
label define metarea_lbl 870  `"Benton Harbor, MI"', add
label define metarea_lbl 880  `"Billings, MT"', add
label define metarea_lbl 920  `"Biloxi-Gulfport, MS"', add
label define metarea_lbl 960  `"Binghamton, NY"', add
label define metarea_lbl 1000 `"Birmingham, AL"', add
label define metarea_lbl 1010 `"Bismarck, ND"', add
label define metarea_lbl 1020 `"Bloomington, IN"', add
label define metarea_lbl 1040 `"Bloomington-Normal, IL"', add
label define metarea_lbl 1080 `"Boise City, ID"', add
label define metarea_lbl 1120 `"Boston, MA"', add
label define metarea_lbl 1121 `"Lawrence-Haverhill, MA/NH"', add
label define metarea_lbl 1122 `"Lowell, MA/NH"', add
label define metarea_lbl 1123 `"Salem-Gloucester, MA"', add
label define metarea_lbl 1140 `"Bradenton, FL"', add
label define metarea_lbl 1150 `"Bremerton, WA"', add
label define metarea_lbl 1160 `"Bridgeport, CT"', add
label define metarea_lbl 1200 `"Brockton, MA"', add
label define metarea_lbl 1240 `"Brownsville - Harlingen-San Benito, TX"', add
label define metarea_lbl 1260 `"Bryan-College Station, TX"', add
label define metarea_lbl 1280 `"Buffalo-Niagara Falls, NY"', add
label define metarea_lbl 1281 `"Niagara Falls, NY"', add
label define metarea_lbl 1300 `"Burlington, NC"', add
label define metarea_lbl 1310 `"Burlington, VT"', add
label define metarea_lbl 1320 `"Canton, OH"', add
label define metarea_lbl 1330 `"Caguas, PR"', add
label define metarea_lbl 1350 `"Casper, WY"', add
label define metarea_lbl 1360 `"Cedar Rapids, IA"', add
label define metarea_lbl 1400 `"Champaign-Urbana-Rantoul, IL"', add
label define metarea_lbl 1440 `"Charleston-N. Charleston, SC"', add
label define metarea_lbl 1480 `"Charleston, WV"', add
label define metarea_lbl 1520 `"Charlotte-Gastonia-Rock Hill, NC/SC"', add
label define metarea_lbl 1521 `"Rock Hill, SC"', add
label define metarea_lbl 1540 `"Charlottesville, VA"', add
label define metarea_lbl 1560 `"Chattanooga, TN/GA"', add
label define metarea_lbl 1580 `"Cheyenne, WY"', add
label define metarea_lbl 1600 `"Chicago-Gary-Lake IL"', add
label define metarea_lbl 1601 `"Aurora-Elgin, IL"', add
label define metarea_lbl 1602 `"Gary-Hammond-East Chicago, IN"', add
label define metarea_lbl 1603 `"Joliet, IL"', add
label define metarea_lbl 1604 `"Lake County, IL"', add
label define metarea_lbl 1620 `"Chico, CA"', add
label define metarea_lbl 1640 `"Cincinnati, OH/KY/IN"', add
label define metarea_lbl 1660 `"Clarksville- Hopkinsville, TN/KY"', add
label define metarea_lbl 1680 `"Cleveland, OH"', add
label define metarea_lbl 1720 `"Colorado Springs, CO"', add
label define metarea_lbl 1740 `"Columbia, MO"', add
label define metarea_lbl 1760 `"Columbia, SC"', add
label define metarea_lbl 1800 `"Columbus, GA/AL"', add
label define metarea_lbl 1840 `"Columbus, OH"', add
label define metarea_lbl 1880 `"Corpus Christi, TX"', add
label define metarea_lbl 1900 `"Cumberland, MD/WV"', add
label define metarea_lbl 1920 `"Dallas-Fort Worth, TX"', add
label define metarea_lbl 1921 `"Fort Worth-Arlington, TX"', add
label define metarea_lbl 1930 `"Danbury, CT"', add
label define metarea_lbl 1950 `"Danville, VA"', add
label define metarea_lbl 1960 `"Davenport, IA - Rock Island-Moline, IL"', add
label define metarea_lbl 2000 `"Dayton-Springfield, OH"', add
label define metarea_lbl 2001 `"Springfield, OH"', add
label define metarea_lbl 2020 `"Daytona Beach, FL"', add
label define metarea_lbl 2030 `"Decatur, AL"', add
label define metarea_lbl 2040 `"Decatur, IL"', add
label define metarea_lbl 2080 `"Denver-Boulder-Longmont, CO"', add
label define metarea_lbl 2081 `"Boulder-Longmont, CO"', add
label define metarea_lbl 2120 `"Des Moines, IA"', add
label define metarea_lbl 2121 `"Polk, IA"', add
label define metarea_lbl 2160 `"Detroit, MI"', add
label define metarea_lbl 2180 `"Dothan, AL"', add
label define metarea_lbl 2190 `"Dover, DE"', add
label define metarea_lbl 2200 `"Dubuque, IA"', add
label define metarea_lbl 2240 `"Duluth-Superior, MN/WI"', add
label define metarea_lbl 2281 `"Dutchess County, NY"', add
label define metarea_lbl 2290 `"Eau Claire, WI"', add
label define metarea_lbl 2310 `"El Paso, TX"', add
label define metarea_lbl 2320 `"Elkhart-Goshen, IN"', add
label define metarea_lbl 2330 `"Elmira, NY"', add
label define metarea_lbl 2340 `"Enid, OK"', add
label define metarea_lbl 2360 `"Erie, PA"', add
label define metarea_lbl 2400 `"Eugene-Springfield, OR"', add
label define metarea_lbl 2440 `"Evansville, IN/KY"', add
label define metarea_lbl 2520 `"Fargo-Moorhead, ND/MN"', add
label define metarea_lbl 2560 `"Fayetteville, NC"', add
label define metarea_lbl 2580 `"Fayetteville-Springdale, AR"', add
label define metarea_lbl 2600 `"Fitchburg-Leominster, MA"', add
label define metarea_lbl 2620 `"Flagstaff, AZ"', add
label define metarea_lbl 2640 `"Flint, MI"', add
label define metarea_lbl 2650 `"Florence, AL"', add
label define metarea_lbl 2660 `"Florence, SC"', add
label define metarea_lbl 2670 `"Fort Collins-Loveland, CO"', add
label define metarea_lbl 2680 `"Fort Lauderdale-Hollywood-Pompano Beach, FL"', add
label define metarea_lbl 2700 `"Fort Myers-Cape Coral, FL"', add
label define metarea_lbl 2710 `"Fort Pierce, FL"', add
label define metarea_lbl 2720 `"Fort Smith, AR/OK"', add
label define metarea_lbl 2750 `"Fort Walton Beach, FL"', add
label define metarea_lbl 2760 `"Fort Wayne, IN"', add
label define metarea_lbl 2840 `"Fresno, CA"', add
label define metarea_lbl 2880 `"Gadsden, AL"', add
label define metarea_lbl 2900 `"Gainesville, FL"', add
label define metarea_lbl 2920 `"Galveston-Texas City, TX"', add
label define metarea_lbl 2970 `"Glens Falls, NY"', add
label define metarea_lbl 2980 `"Goldsboro, NC"', add
label define metarea_lbl 2990 `"Grand Forks, ND/MN"', add
label define metarea_lbl 3000 `"Grand Rapids, MI"', add
label define metarea_lbl 3010 `"Grand Junction, CO"', add
label define metarea_lbl 3040 `"Great Falls, MT"', add
label define metarea_lbl 3060 `"Greeley, CO"', add
label define metarea_lbl 3080 `"Green Bay, WI"', add
label define metarea_lbl 3120 `"Greensboro-Winston Salem-High Point, NC"', add
label define metarea_lbl 3121 `"Winston-Salem, NC"', add
label define metarea_lbl 3150 `"Greenville, NC"', add
label define metarea_lbl 3160 `"Greenville-Spartenburg-Anderson, SC"', add
label define metarea_lbl 3161 `"Anderson, SC"', add
label define metarea_lbl 3180 `"Hagerstown, MD"', add
label define metarea_lbl 3200 `"Hamilton-Middleton, OH"', add
label define metarea_lbl 3240 `"Harrisburg-Lebanon-Carlisle, PA"', add
label define metarea_lbl 3280 `"Hartford-Bristol-Middletown-New Britian, CT"', add
label define metarea_lbl 3281 `"Bristol, CT"', add
label define metarea_lbl 3282 `"Middletown, CT"', add
label define metarea_lbl 3283 `"New Britain, CT"', add
label define metarea_lbl 3290 `"Hickory-Morganton, NC"', add
label define metarea_lbl 3300 `"Hattiesburg, MS"', add
label define metarea_lbl 3320 `"Honolulu, HI"', add
label define metarea_lbl 3350 `"Houma-Thibodoux, LA"', add
label define metarea_lbl 3360 `"Houston-Brazoria, TX"', add
label define metarea_lbl 3361 `"Brazoria, TX"', add
label define metarea_lbl 3400 `"Huntington-Ashland, WV/KY/OH"', add
label define metarea_lbl 3440 `"Huntsville, AL"', add
label define metarea_lbl 3480 `"Indianapolis, IN"', add
label define metarea_lbl 3500 `"Iowa City, IA"', add
label define metarea_lbl 3520 `"Jackson, MI"', add
label define metarea_lbl 3560 `"Jackson, MS"', add
label define metarea_lbl 3580 `"Jackson, TN"', add
label define metarea_lbl 3590 `"Jacksonville, FL"', add
label define metarea_lbl 3600 `"Jacksonville, NC"', add
label define metarea_lbl 3610 `"Jamestown-Dunkirk, NY"', add
label define metarea_lbl 3620 `"Janesville-Beloit, WI"', add
label define metarea_lbl 3660 `"Johnson City-Kingsport-Bristol, TN/VA"', add
label define metarea_lbl 3680 `"Johnstown, PA"', add
label define metarea_lbl 3710 `"Joplin, MO"', add
label define metarea_lbl 3720 `"Kalamazoo-Portage, MI"', add
label define metarea_lbl 3740 `"Kankakee, IL"', add
label define metarea_lbl 3760 `"Kansas City, MO/KS"', add
label define metarea_lbl 3800 `"Kenosha, WI"', add
label define metarea_lbl 3810 `"Killeen-Temple, TX"', add
label define metarea_lbl 3840 `"Knoxville, TN"', add
label define metarea_lbl 3850 `"Kokomo, IN"', add
label define metarea_lbl 3870 `"LaCrosse, WI"', add
label define metarea_lbl 3880 `"Lafayette, LA"', add
label define metarea_lbl 3920 `"Lafayette-W. Lafayette, IN"', add
label define metarea_lbl 3960 `"Lake Charles, LA"', add
label define metarea_lbl 3980 `"Lakeland-Winterhaven, FL"', add
label define metarea_lbl 4000 `"Lancaster, PA"', add
label define metarea_lbl 4040 `"Lansing-E. Lansing, MI"', add
label define metarea_lbl 4080 `"Laredo, TX"', add
label define metarea_lbl 4100 `"Las Cruces, NM"', add
label define metarea_lbl 4120 `"Las Vegas, NV"', add
label define metarea_lbl 4150 `"Lawrence, KS"', add
label define metarea_lbl 4200 `"Lawton, OK"', add
label define metarea_lbl 4240 `"Lewiston-Auburn, ME"', add
label define metarea_lbl 4280 `"Lexington-Fayette, KY"', add
label define metarea_lbl 4320 `"Lima, OH"', add
label define metarea_lbl 4360 `"Lincoln, NE"', add
label define metarea_lbl 4400 `"Little Rock-N. Little Rock, AR"', add
label define metarea_lbl 4410 `"Long Branch-Asbury Park, NJ"', add
label define metarea_lbl 4420 `"Longview-Marshall, TX"', add
label define metarea_lbl 4440 `"Lorain-Elyria, OH"', add
label define metarea_lbl 4480 `"Los Angeles-Long Beach, CA"', add
label define metarea_lbl 4481 `"Anaheim-Santa Ana-Garden Grove, CA"', add
label define metarea_lbl 4482 `"Orange County, CA"', add
label define metarea_lbl 4520 `"Louisville, KY/IN"', add
label define metarea_lbl 4600 `"Lubbock, TX"', add
label define metarea_lbl 4640 `"Lynchburg, VA"', add
label define metarea_lbl 4680 `"Macon-Warner Robins, GA"', add
label define metarea_lbl 4720 `"Madison, WI"', add
label define metarea_lbl 4760 `"Manchester, NH"', add
label define metarea_lbl 4800 `"Mansfield, OH"', add
label define metarea_lbl 4840 `"Mayaguez, PR"', add
label define metarea_lbl 4880 `"McAllen-Edinburg-Pharr-Mission, TX"', add
label define metarea_lbl 4890 `"Medford, OR"', add
label define metarea_lbl 4900 `"Melbourne-Titusville-Cocoa-Palm Bay, FL"', add
label define metarea_lbl 4920 `"Memphis, TN/AR/MS"', add
label define metarea_lbl 4940 `"Merced, CA"', add
label define metarea_lbl 5000 `"Miami-Hialeah, FL"', add
label define metarea_lbl 5040 `"Midland, TX"', add
label define metarea_lbl 5080 `"Milwaukee, WI"', add
label define metarea_lbl 5120 `"Minneapolis-St. Paul, MN"', add
label define metarea_lbl 5140 `"Missoula, MT"', add
label define metarea_lbl 5160 `"Mobile, AL"', add
label define metarea_lbl 5170 `"Modesto, CA"', add
label define metarea_lbl 5190 `"Monmouth-Ocean, NJ"', add
label define metarea_lbl 5200 `"Monroe, LA"', add
label define metarea_lbl 5240 `"Montgomery, AL"', add
label define metarea_lbl 5280 `"Muncie, IN"', add
label define metarea_lbl 5320 `"Muskegon-Norton Shores-Muskegon Heights, MI"', add
label define metarea_lbl 5330 `"Myrtle Beach, SC"', add
label define metarea_lbl 5340 `"Naples, FL"', add
label define metarea_lbl 5350 `"Nashua, NH"', add
label define metarea_lbl 5360 `"Nashville, TN"', add
label define metarea_lbl 5400 `"New Bedford, MA"', add
label define metarea_lbl 5460 `"New Brunswick-Perth Amboy-Sayreville, NJ"', add
label define metarea_lbl 5480 `"New Haven-Meriden, CT"', add
label define metarea_lbl 5481 `"Meriden"', add
label define metarea_lbl 5482 `"New Haven, CT"', add
label define metarea_lbl 5520 `"New London-Norwich, CT/RI"', add
label define metarea_lbl 5560 `"New Orleans, LA"', add
label define metarea_lbl 5600 `"New York, NY-Northeastern NJ"', add
label define metarea_lbl 5601 `"Nassau Co., NY"', add
label define metarea_lbl 5602 `"Bergen-Passaic, NJ"', add
label define metarea_lbl 5603 `"Jersey City, NJ"', add
label define metarea_lbl 5604 `"Middlesex-Somerset-Hunterdon, NJ"', add
label define metarea_lbl 5605 `"Newark, NJ"', add
label define metarea_lbl 5640 `"Newark, OH"', add
label define metarea_lbl 5660 `"Newburgh-Middletown, NY"', add
label define metarea_lbl 5720 `"Norfolk-VA Beach-Newport News, VA"', add
label define metarea_lbl 5721 `"Newport News-Hampton"', add
label define metarea_lbl 5722 `"Norfolk- VA Beach-Portsmouth"', add
label define metarea_lbl 5760 `"Norwalk, CT"', add
label define metarea_lbl 5790 `"Ocala, FL"', add
label define metarea_lbl 5800 `"Odessa, TX"', add
label define metarea_lbl 5880 `"Oklahoma City, OK"', add
label define metarea_lbl 5910 `"Olympia, WA"', add
label define metarea_lbl 5920 `"Omaha, NE/IA"', add
label define metarea_lbl 5950 `"Orange County, NY"', add
label define metarea_lbl 5960 `"Orlando, FL"', add
label define metarea_lbl 5990 `"Owensboro, KY"', add
label define metarea_lbl 6010 `"Panama City, FL"', add
label define metarea_lbl 6020 `"Parkersburg-Marietta,WV/OH"', add
label define metarea_lbl 6030 `"Pascagoula-Moss Point, MS"', add
label define metarea_lbl 6080 `"Pensacola, FL"', add
label define metarea_lbl 6120 `"Peoria, IL"', add
label define metarea_lbl 6160 `"Philadelphia, PA/NJ"', add
label define metarea_lbl 6200 `"Phoenix, AZ"', add
label define metarea_lbl 6240 `"Pine Bluff, AR"', add
label define metarea_lbl 6280 `"Pittsburgh-Beaver Valley, PA"', add
label define metarea_lbl 6281 `"Beaver County"', add
label define metarea_lbl 6320 `"Pittsfield, MA"', add
label define metarea_lbl 6360 `"Ponce, PR"', add
label define metarea_lbl 6400 `"Portland, ME"', add
label define metarea_lbl 6440 `"Portland-Vancouver, OR"', add
label define metarea_lbl 6441 `"Vancouver, WA"', add
label define metarea_lbl 6450 `"Portsmouth-Dover-Rochester, NH/ME"', add
label define metarea_lbl 6460 `"Poughkeepsie, NY"', add
label define metarea_lbl 6480 `"Providence-Fall River-Pawtuckett, MA"', add
label define metarea_lbl 6481 `"Fall River, MA/RI"', add
label define metarea_lbl 6482 `"Pawtucket-Woonsocket-Attleboro, RI-MA"', add
label define metarea_lbl 6520 `"Provo-Orem, UT"', add
label define metarea_lbl 6560 `"Pueblo, CO"', add
label define metarea_lbl 6580 `"Punta Gorda, FL"', add
label define metarea_lbl 6600 `"Racine, WI"', add
label define metarea_lbl 6640 `"Raleigh-Durham, NC"', add
label define metarea_lbl 6641 `"Durham, NC"', add
label define metarea_lbl 6660 `"Rapid City, SD"', add
label define metarea_lbl 6680 `"Reading, PA"', add
label define metarea_lbl 6690 `"Redding, CA"', add
label define metarea_lbl 6720 `"Reno, NV"', add
label define metarea_lbl 6740 `"Richland-Kennewick-Pasco, WA"', add
label define metarea_lbl 6760 `"Richmond-Petersburg, VA"', add
label define metarea_lbl 6761 `"Petersburg-Colonial He."', add
label define metarea_lbl 6780 `"Riverside-San Bernardino, CA"', add
label define metarea_lbl 6781 `"San Bernardino, CA (1950)"', add
label define metarea_lbl 6800 `"Roanoke, VA"', add
label define metarea_lbl 6820 `"Rochester, MN"', add
label define metarea_lbl 6840 `"Rochester, NY"', add
label define metarea_lbl 6880 `"Rockford, IL"', add
label define metarea_lbl 6895 `"Rocky Mount, NC"', add
label define metarea_lbl 6920 `"Sacramento, CA"', add
label define metarea_lbl 6960 `"Saginaw-Bay City-Midland, MI"', add
label define metarea_lbl 6961 `"Bay City, MI"', add
label define metarea_lbl 6980 `"St. Cloud, MN"', add
label define metarea_lbl 7000 `"St. Joseph, MO"', add
label define metarea_lbl 7040 `"St. Louis, MO/IL"', add
label define metarea_lbl 7080 `"Salem, OR"', add
label define metarea_lbl 7120 `"Salinas-Sea Side-Monterey, CA"', add
label define metarea_lbl 7140 `"Salisbury-Concord, NC"', add
label define metarea_lbl 7160 `"Salt Lake City-Ogden, UT"', add
label define metarea_lbl 7161 `"Ogden"', add
label define metarea_lbl 7200 `"San Angelo, TX"', add
label define metarea_lbl 7240 `"San Antonio, TX"', add
label define metarea_lbl 7320 `"San Diego, CA"', add
label define metarea_lbl 7360 `"San Francisco-Oakland-Vallejo, CA"', add
label define metarea_lbl 7361 `"Oakland, CA"', add
label define metarea_lbl 7362 `"Vallejo-Fairfield-Napa, CA"', add
label define metarea_lbl 7400 `"San Jose, CA"', add
label define metarea_lbl 7440 `"San Juan-Bayamon, PR"', add
label define metarea_lbl 7460 `"San Luis Obispo-Atascad-P Robles, CA"', add
label define metarea_lbl 7470 `"Santa Barbara-Santa Maria-Lompoc, CA"', add
label define metarea_lbl 7480 `"Santa Cruz, CA"', add
label define metarea_lbl 7490 `"Santa Fe, NM"', add
label define metarea_lbl 7500 `"Santa Rosa-Petaluma, CA"', add
label define metarea_lbl 7510 `"Sarasota, FL"', add
label define metarea_lbl 7520 `"Savannah, GA"', add
label define metarea_lbl 7560 `"Scranton-Wilkes-Barre, PA"', add
label define metarea_lbl 7561 `"Wilkes-Barre-Hazleton, PA"', add
label define metarea_lbl 7600 `"Seattle-Everett, WA"', add
label define metarea_lbl 7610 `"Sharon, PA"', add
label define metarea_lbl 7620 `"Sheboygan, WI"', add
label define metarea_lbl 7640 `"Sherman-Denison, TX"', add
label define metarea_lbl 7680 `"Shreveport, LA"', add
label define metarea_lbl 7720 `"Sioux City, IA/NE"', add
label define metarea_lbl 7760 `"Sioux Falls, SD"', add
label define metarea_lbl 7800 `"South Bend-Mishawaka, IN"', add
label define metarea_lbl 7840 `"Spokane, WA"', add
label define metarea_lbl 7880 `"Springfield, IL"', add
label define metarea_lbl 7920 `"Springfield, MO"', add
label define metarea_lbl 8000 `"Springfield-Holyoke-Chicopee, MA"', add
label define metarea_lbl 8040 `"Stamford, CT"', add
label define metarea_lbl 8050 `"State College, PA"', add
label define metarea_lbl 8080 `"Steubenville-Weirton,OH/WV"', add
label define metarea_lbl 8120 `"Stockton, CA"', add
label define metarea_lbl 8140 `"Sumter, SC"', add
label define metarea_lbl 8160 `"Syracuse, NY"', add
label define metarea_lbl 8200 `"Tacoma, WA"', add
label define metarea_lbl 8240 `"Tallahassee, FL"', add
label define metarea_lbl 8280 `"Tampa-St. Petersburg-Clearwater, FL"', add
label define metarea_lbl 8320 `"Terre Haute, IN"', add
label define metarea_lbl 8360 `"Texarkana, TX/AR"', add
label define metarea_lbl 8400 `"Toledo, OH/MI"', add
label define metarea_lbl 8440 `"Topeka, KS"', add
label define metarea_lbl 8480 `"Trenton, NJ"', add
label define metarea_lbl 8520 `"Tucson, AZ"', add
label define metarea_lbl 8560 `"Tulsa, OK"', add
label define metarea_lbl 8600 `"Tuscaloosa, AL"', add
label define metarea_lbl 8640 `"Tyler, TX"', add
label define metarea_lbl 8680 `"Utica-Rome, NY"', add
label define metarea_lbl 8730 `"Ventura-Oxnard-Simi Valley, CA"', add
label define metarea_lbl 8750 `"Victoria, TX"', add
label define metarea_lbl 8760 `"Vineland-Milville-Bridgetown, NJ"', add
label define metarea_lbl 8780 `"Visalia-Tulare -Porterville, CA"', add
label define metarea_lbl 8800 `"Waco, TX"', add
label define metarea_lbl 8840 `"Washington, DC/MD/VA"', add
label define metarea_lbl 8880 `"Waterbury, CT"', add
label define metarea_lbl 8920 `"Waterloo-Cedar Falls, IA"', add
label define metarea_lbl 8940 `"Wausau, WI"', add
label define metarea_lbl 8960 `"West Palm Beach-Boca Raton-Delray Beach, FL"', add
label define metarea_lbl 9000 `"Wheeling, WV/OH"', add
label define metarea_lbl 9040 `"Wichita, KS"', add
label define metarea_lbl 9080 `"Wichita Falls, TX"', add
label define metarea_lbl 9140 `"Williamsport, PA"', add
label define metarea_lbl 9160 `"Wilmington, DE/NJ/MD"', add
label define metarea_lbl 9200 `"Wilmington, NC"', add
label define metarea_lbl 9240 `"Worcester, MA"', add
label define metarea_lbl 9260 `"Yakima, WA"', add
label define metarea_lbl 9270 `"Yolo, CA"', add
label define metarea_lbl 9280 `"York, PA"', add
label define metarea_lbl 9320 `"Youngstown-Warren, OH/PA"', add
label define metarea_lbl 9340 `"Yuba City, CA"', add
label define metarea_lbl 9360 `"Yuma, AZ"', add
label values metarea metarea_lbl

label define metdist_lbl 0    `"Not in a Metropolitan District"'
label define metdist_lbl 80   `"Akron, OH"', add
label define metdist_lbl 160  `"Albany-Troy, NY"', add
label define metdist_lbl 180  `"Schenectady, NY"', add
label define metdist_lbl 240  `"Allentown-Bethlehem, PA"', add
label define metdist_lbl 280  `"Altoona, PA"', add
label define metdist_lbl 320  `"Amarillo, TX"', add
label define metdist_lbl 480  `"Asheville, NC"', add
label define metdist_lbl 520  `"Atlanta, GA"', add
label define metdist_lbl 560  `"Atlantic City, NJ"', add
label define metdist_lbl 600  `"Augusta, GA"', add
label define metdist_lbl 640  `"Austin, TX"', add
label define metdist_lbl 720  `"Baltimore, MD"', add
label define metdist_lbl 840  `"Beaumont, TX"', add
label define metdist_lbl 850  `"Port Arthur, TX"', add
label define metdist_lbl 960  `"Binghamton, NY"', add
label define metdist_lbl 1000 `"Birmingham, AL"', add
label define metdist_lbl 1120 `"Boston, MA"', add
label define metdist_lbl 1121 `"Lawrence-Haverhill, MA"', add
label define metdist_lbl 1122 `"Lowell, MA"', add
label define metdist_lbl 1160 `"Bridgeport, CT"', add
label define metdist_lbl 1200 `"Brockton, MA"', add
label define metdist_lbl 1280 `"Buffalo, NY"', add
label define metdist_lbl 1281 `"Niagara Falls, NY"', add
label define metdist_lbl 1320 `"Canton, OH"', add
label define metdist_lbl 1360 `"Cedar Rapids, IA"', add
label define metdist_lbl 1440 `"Charleston, SC"', add
label define metdist_lbl 1480 `"Charleston, WV"', add
label define metdist_lbl 1520 `"Charlotte, NC"', add
label define metdist_lbl 1560 `"Chattanooga, TN"', add
label define metdist_lbl 1600 `"Chicago, IL/IN"', add
label define metdist_lbl 1640 `"Cincinnati, OH/KY"', add
label define metdist_lbl 1680 `"Cleveland, OH"', add
label define metdist_lbl 1760 `"Columbia, SC"', add
label define metdist_lbl 1800 `"Columbus, GA"', add
label define metdist_lbl 1840 `"Columbus, OH"', add
label define metdist_lbl 1880 `"Corpus Christi, TX"', add
label define metdist_lbl 1920 `"Dallas, TX"', add
label define metdist_lbl 1921 `"Fort Worth, TX"', add
label define metdist_lbl 1960 `"Davenport-Rock Island-Moline, IA/IL"', add
label define metdist_lbl 2000 `"Dayton, OH"', add
label define metdist_lbl 2001 `"Springfield, OH"', add
label define metdist_lbl 2040 `"Decatur, IL"', add
label define metdist_lbl 2080 `"Denver, CO"', add
label define metdist_lbl 2120 `"Des Moines, IA"', add
label define metdist_lbl 2160 `"Detroit, MI"', add
label define metdist_lbl 2161 `"Pontiac, MI"', add
label define metdist_lbl 2240 `"Duluth-Superior, MN/WI"', add
label define metdist_lbl 2310 `"El Paso, TX"', add
label define metdist_lbl 2360 `"Erie, PA"', add
label define metdist_lbl 2440 `"Evansville, ID"', add
label define metdist_lbl 2640 `"Flint, MI"', add
label define metdist_lbl 2760 `"Fort Wayne, ID"', add
label define metdist_lbl 2840 `"Fresno, CA"', add
label define metdist_lbl 2920 `"Galveston, TX"', add
label define metdist_lbl 3000 `"Grand Rapids, MI"', add
label define metdist_lbl 3120 `"Greensboro, NC"', add
label define metdist_lbl 3121 `"Winston-Salem, NC"', add
label define metdist_lbl 3200 `"Hamilton, OH"', add
label define metdist_lbl 3240 `"Harrisburg, PA"', add
label define metdist_lbl 3280 `"Hartford, CT"', add
label define metdist_lbl 3283 `"New Britain, CT"', add
label define metdist_lbl 3360 `"Houston, TX"', add
label define metdist_lbl 3400 `"Huntington-Ashland, KY/OH"', add
label define metdist_lbl 3480 `"Indianapolis, ID"', add
label define metdist_lbl 3520 `"Jackson, MI"', add
label define metdist_lbl 3560 `"Jackson, MS"', add
label define metdist_lbl 3590 `"Jacksonville, FL"', add
label define metdist_lbl 3680 `"Johnstown, PA"', add
label define metdist_lbl 3720 `"Kalamazoo, MI"', add
label define metdist_lbl 3760 `"Kansas City, MO/KS"', add
label define metdist_lbl 3800 `"Kenosha, WI"', add
label define metdist_lbl 3840 `"Knoxville, TN"', add
label define metdist_lbl 4000 `"Lancaster, PA"', add
label define metdist_lbl 4040 `"Lansing, MI"', add
label define metdist_lbl 4360 `"Lincoln, NE"', add
label define metdist_lbl 4400 `"Little Rock, AR"', add
label define metdist_lbl 4480 `"Los Angeles, CA"', add
label define metdist_lbl 4520 `"Louisville, KY"', add
label define metdist_lbl 4680 `"Macon, GA"', add
label define metdist_lbl 4720 `"Madison, WI"', add
label define metdist_lbl 4760 `"Manchester, NH"', add
label define metdist_lbl 4920 `"Memphis, TN"', add
label define metdist_lbl 5000 `"Miami, FL"', add
label define metdist_lbl 5080 `"Milwaukee, WI"', add
label define metdist_lbl 5120 `"Minneapolis-St. Paul, MN"', add
label define metdist_lbl 5160 `"Mobile, AL"', add
label define metdist_lbl 5240 `"Montgomery, AL"', add
label define metdist_lbl 5320 `"Muskegon, MI"', add
label define metdist_lbl 5360 `"Nashville, TN"', add
label define metdist_lbl 5400 `"New Bedford, MA"', add
label define metdist_lbl 5480 `"New Haven, CT"', add
label define metdist_lbl 5560 `"New Orleans, LA"', add
label define metdist_lbl 5600 `"New York, NY-Northeastern NJ"', add
label define metdist_lbl 5720 `"Norfolk-Portsmouth, VA"', add
label define metdist_lbl 5880 `"Oklahoma City, OK"', add
label define metdist_lbl 5920 `"Omaha, NE/IA"', add
label define metdist_lbl 6120 `"Peoria, IL"', add
label define metdist_lbl 6160 `"Philadelphia, PA/NJ"', add
label define metdist_lbl 6200 `"Phoenix, AZ"', add
label define metdist_lbl 6280 `"Pittsburgh, PA"', add
label define metdist_lbl 6400 `"Portland, ME"', add
label define metdist_lbl 6440 `"Portland, OR/WA"', add
label define metdist_lbl 6480 `"Providence, RI/MA"', add
label define metdist_lbl 6481 `"Fall River, MA"', add
label define metdist_lbl 6560 `"Pueblo, CO"', add
label define metdist_lbl 6600 `"Racine, WI"', add
label define metdist_lbl 6641 `"Durham, NC"', add
label define metdist_lbl 6680 `"Reading, PA"', add
label define metdist_lbl 6760 `"Richmond, VA"', add
label define metdist_lbl 6781 `"San Bernardino, CA"', add
label define metdist_lbl 6800 `"Roanoke, VA"', add
label define metdist_lbl 6840 `"Rochester, NY"', add
label define metdist_lbl 6880 `"Rockford, IL"', add
label define metdist_lbl 6920 `"Sacramento, CA"', add
label define metdist_lbl 6960 `"Saginaw, MI"', add
label define metdist_lbl 6961 `"Bay City, MI"', add
label define metdist_lbl 7000 `"St. Joseph, MO"', add
label define metdist_lbl 7040 `"St. Louis, MO/IL"', add
label define metdist_lbl 7060 `"St. Petersburg, FL"', add
label define metdist_lbl 7160 `"Salt Lake City, UT"', add
label define metdist_lbl 7240 `"San Antonio, TX"', add
label define metdist_lbl 7320 `"San Diego, CA"', add
label define metdist_lbl 7360 `"San Francisco-Oakland, CA"', add
label define metdist_lbl 7400 `"San Jose, CA"', add
label define metdist_lbl 7520 `"Savannah, GA"', add
label define metdist_lbl 7560 `"Scranton, PA"', add
label define metdist_lbl 7561 `"Wilkes-Barre, PA"', add
label define metdist_lbl 7600 `"Seattle, WA"', add
label define metdist_lbl 7680 `"Shreveport, LA"', add
label define metdist_lbl 7720 `"Sioux City, IA"', add
label define metdist_lbl 7800 `"South Bend, ID"', add
label define metdist_lbl 7840 `"Spokane, WA"', add
label define metdist_lbl 7880 `"Springfield, IL"', add
label define metdist_lbl 7920 `"Springfield, MO"', add
label define metdist_lbl 8000 `"Springfield-Holyoke, MA"', add
label define metdist_lbl 8120 `"Stockton, CA"', add
label define metdist_lbl 8160 `"Syracuse, NY"', add
label define metdist_lbl 8200 `"Tacoma, WA"', add
label define metdist_lbl 8280 `"Tampa, FL"', add
label define metdist_lbl 8300 `"St. Petersburg, FL"', add
label define metdist_lbl 8320 `"Terre Haute, ID"', add
label define metdist_lbl 8400 `"Toledo, OH"', add
label define metdist_lbl 8440 `"Topeka, KS"', add
label define metdist_lbl 8480 `"Trenton, NJ"', add
label define metdist_lbl 8560 `"Tulsa, OK"', add
label define metdist_lbl 8680 `"Utica, NY"', add
label define metdist_lbl 8800 `"Waco, TX"', add
label define metdist_lbl 8840 `"Washington, DC/MD/VA"', add
label define metdist_lbl 8880 `"Waterbury, CT"', add
label define metdist_lbl 8920 `"Waterloo, IA"', add
label define metdist_lbl 9000 `"Wheeling, WV"', add
label define metdist_lbl 9040 `"Wichita, KS"', add
label define metdist_lbl 9160 `"Wilmington, DE"', add
label define metdist_lbl 9240 `"Worcester, MA"', add
label define metdist_lbl 9280 `"York, PA"', add
label define metdist_lbl 9320 `"Youngstown, OH"', add
label define metdist_lbl 9999 `"Not classified"', add
label values metdist metdist_lbl

label define city_lbl 0    `"Not in identifiable city (or size group)"'
label define city_lbl 1    `"Aberdeen, SD"', add
label define city_lbl 2    `"Aberdeen, WA"', add
label define city_lbl 3    `"Abilene, TX"', add
label define city_lbl 4    `"Ada, OK"', add
label define city_lbl 5    `"Adams, MA"', add
label define city_lbl 6    `"Adrian, MI"', add
label define city_lbl 7    `"Abington, PA"', add
label define city_lbl 10   `"Akron, OH"', add
label define city_lbl 30   `"Alameda, CA"', add
label define city_lbl 50   `"Albany, NY"', add
label define city_lbl 51   `"Albany, GA"', add
label define city_lbl 52   `"Albert Lea, MN"', add
label define city_lbl 70   `"Albuquerque, NM"', add
label define city_lbl 90   `"Alexandria, VA"', add
label define city_lbl 91   `"Alexandria, LA"', add
label define city_lbl 100  `"Alhambra, CA"', add
label define city_lbl 110  `"Allegheny, PA"', add
label define city_lbl 120  `"Aliquippa, PA"', add
label define city_lbl 130  `"Allentown, PA"', add
label define city_lbl 131  `"Alliance, OH"', add
label define city_lbl 132  `"Alpena, MI"', add
label define city_lbl 140  `"Alton, IL"', add
label define city_lbl 150  `"Altoona, PA"', add
label define city_lbl 160  `"Amarillo, TX"', add
label define city_lbl 161  `"Ambridge, PA"', add
label define city_lbl 162  `"Ames, IA"', add
label define city_lbl 163  `"Amesbury, MA"', add
label define city_lbl 170  `"Amsterdam, NY"', add
label define city_lbl 171  `"Anaconda, MT"', add
label define city_lbl 190  `"Anaheim, CA"', add
label define city_lbl 210  `"Anchorage, AK"', add
label define city_lbl 230  `"Anderson, IN"', add
label define city_lbl 231  `"Anderson, SC"', add
label define city_lbl 250  `"Andover, MA"', add
label define city_lbl 270  `"Ann Arbor, MI"', add
label define city_lbl 271  `"Annapolis, MD"', add
label define city_lbl 272  `"Anniston, AL"', add
label define city_lbl 273  `"Ansonia, CT"', add
label define city_lbl 275  `"Antioch, CA"', add
label define city_lbl 280  `"Appleton, WI"', add
label define city_lbl 281  `"Ardmore, OK"', add
label define city_lbl 282  `"Argenta, AR"', add
label define city_lbl 283  `"Arkansas, KS"', add
label define city_lbl 284  `"Arden-Arcade, CA"', add
label define city_lbl 290  `"Arlington, TX"', add
label define city_lbl 310  `"Arlington, VA"', add
label define city_lbl 311  `"Arlington, MA"', add
label define city_lbl 312  `"Arnold, PA"', add
label define city_lbl 313  `"Asbury Park, NJ"', add
label define city_lbl 330  `"Asheville, NC"', add
label define city_lbl 331  `"Ashland, OH"', add
label define city_lbl 340  `"Ashland, KY"', add
label define city_lbl 341  `"Ashland, WI"', add
label define city_lbl 342  `"Ashtabula, OH"', add
label define city_lbl 343  `"Astoria, OR"', add
label define city_lbl 344  `"Atchison, KS"', add
label define city_lbl 345  `"Athens, GA"', add
label define city_lbl 346  `"Athol, MA"', add
label define city_lbl 347  `"Athens-Clarke County, GA"', add
label define city_lbl 350  `"Atlanta, GA"', add
label define city_lbl 370  `"Atlantic City, NJ"', add
label define city_lbl 371  `"Attleboro, MA"', add
label define city_lbl 390  `"Auburn, NY"', add
label define city_lbl 391  `"Auburn, ME"', add
label define city_lbl 410  `"Augusta, GA"', add
label define city_lbl 411  `"Augusta-Richmond County, GA"', add
label define city_lbl 430  `"Augusta, ME"', add
label define city_lbl 450  `"Aurora, CO"', add
label define city_lbl 470  `"Aurora, IL"', add
label define city_lbl 490  `"Austin, TX"', add
label define city_lbl 491  `"Austin, MN"', add
label define city_lbl 510  `"Bakersfield, CA"', add
label define city_lbl 530  `"Baltimore, MD"', add
label define city_lbl 550  `"Bangor, ME"', add
label define city_lbl 551  `"Barberton, OH"', add
label define city_lbl 552  `"Barre, VT"', add
label define city_lbl 553  `"Bartlesville, OK"', add
label define city_lbl 554  `"Batavia, NY"', add
label define city_lbl 570  `"Bath, ME"', add
label define city_lbl 590  `"Baton Rouge, LA"', add
label define city_lbl 610  `"Battle Creek, MI"', add
label define city_lbl 630  `"Bay City, MI"', add
label define city_lbl 640  `"Bayamon, PR"', add
label define city_lbl 650  `"Bayonne, NJ"', add
label define city_lbl 651  `"Beacon, NY"', add
label define city_lbl 652  `"Beatrice, NE"', add
label define city_lbl 660  `"Belleville, IL"', add
label define city_lbl 670  `"Beaumont, TX"', add
label define city_lbl 671  `"Beaver Falls, PA"', add
label define city_lbl 672  `"Bedford, IN"', add
label define city_lbl 673  `"Bellaire, OH"', add
label define city_lbl 680  `"Bellevue, WA"', add
label define city_lbl 690  `"Bellingham, WA"', add
label define city_lbl 695  `"Belvedere, CA"', add
label define city_lbl 700  `"Belleville, NJ"', add
label define city_lbl 701  `"Bellevue, PA"', add
label define city_lbl 702  `"Belmont, OH"', add
label define city_lbl 703  `"Belmont, MA"', add
label define city_lbl 704  `"Beloit, WI"', add
label define city_lbl 705  `"Bennington, VT"', add
label define city_lbl 706  `"Benton Harbor, MI"', add
label define city_lbl 710  `"Berkeley, CA"', add
label define city_lbl 711  `"Berlin, NH"', add
label define city_lbl 712  `"Berwick, PA"', add
label define city_lbl 720  `"Berwyn, IL"', add
label define city_lbl 721  `"Bessemer, AL"', add
label define city_lbl 730  `"Bethlehem, PA"', add
label define city_lbl 740  `"Biddeford, ME"', add
label define city_lbl 741  `"Big Spring, TX"', add
label define city_lbl 742  `"Billings, MT"', add
label define city_lbl 743  `"Biloxi, MS"', add
label define city_lbl 750  `"Binghamton, NY"', add
label define city_lbl 760  `"Beverly, MA"', add
label define city_lbl 761  `"Beverly Hills, CA"', add
label define city_lbl 770  `"Birmingham, AL"', add
label define city_lbl 771  `"Birmingham, CT"', add
label define city_lbl 772  `"Bismarck, ND"', add
label define city_lbl 780  `"Bloomfield, NJ"', add
label define city_lbl 790  `"Bloomington, IL"', add
label define city_lbl 791  `"Bloomington, IN"', add
label define city_lbl 792  `"Blue Island, IL"', add
label define city_lbl 793  `"Bluefield, WV"', add
label define city_lbl 794  `"Blytheville, AR"', add
label define city_lbl 795  `"Bogalusa, LA"', add
label define city_lbl 800  `"Boise, ID"', add
label define city_lbl 801  `"Boone, IA"', add
label define city_lbl 810  `"Boston, MA"', add
label define city_lbl 811  `"Boulder, CO"', add
label define city_lbl 812  `"Bowling Green, KY"', add
label define city_lbl 813  `"Braddock, PA"', add
label define city_lbl 814  `"Braden, WA"', add
label define city_lbl 815  `"Bradford, PA"', add
label define city_lbl 816  `"Brainerd, MN"', add
label define city_lbl 817  `"Braintree, MA"', add
label define city_lbl 818  `"Brawley, CA"', add
label define city_lbl 819  `"Bremerton, WA"', add
label define city_lbl 830  `"Bridgeport, CT"', add
label define city_lbl 831  `"Bridgeton, NJ"', add
label define city_lbl 832  `"Bristol, CT"', add
label define city_lbl 833  `"Bristol, PA"', add
label define city_lbl 834  `"Bristol, VA"', add
label define city_lbl 835  `"Bristol, TN"', add
label define city_lbl 837  `"Bristol, RI"', add
label define city_lbl 850  `"Brockton, MA"', add
label define city_lbl 851  `"Brookfield, IL"', add
label define city_lbl 870  `"Brookline, MA"', add
label define city_lbl 880  `"Brownsville, TX"', add
label define city_lbl 881  `"Brownwood, TX"', add
label define city_lbl 882  `"Brunswick, GA"', add
label define city_lbl 883  `"Bucyrus, OH"', add
label define city_lbl 890  `"Buffalo, NY"', add
label define city_lbl 900  `"Burlington, IA"', add
label define city_lbl 905  `"Burlington, VT"', add
label define city_lbl 906  `"Burlington, NJ"', add
label define city_lbl 907  `"Bushkill, PA"', add
label define city_lbl 910  `"Butte, MT"', add
label define city_lbl 911  `"Butler, PA"', add
label define city_lbl 920  `"Burbank, CA"', add
label define city_lbl 921  `"Burlingame, CA"', add
label define city_lbl 926  `"Cairo, IL"', add
label define city_lbl 927  `"Calumet City, IL"', add
label define city_lbl 930  `"Cambridge, MA"', add
label define city_lbl 931  `"Cambridge, OH"', add
label define city_lbl 950  `"Camden, NJ"', add
label define city_lbl 951  `"Campbell, OH"', add
label define city_lbl 952  `"Canonsburg, PA"', add
label define city_lbl 970  `"Camden, NY"', add
label define city_lbl 990  `"Canton, OH"', add
label define city_lbl 991  `"Canton, IL"', add
label define city_lbl 992  `"Cape Girardeau, MO"', add
label define city_lbl 993  `"Carbondale, PA"', add
label define city_lbl 994  `"Carlisle, PA"', add
label define city_lbl 995  `"Carnegie, PA"', add
label define city_lbl 996  `"Carrick, PA"', add
label define city_lbl 997  `"Carteret, NJ"', add
label define city_lbl 998  `"Carthage, MO"', add
label define city_lbl 999  `"Casper, WY"', add
label define city_lbl 1000 `"Cape Coral, FL"', add
label define city_lbl 1010 `"Cedar Rapids, IA"', add
label define city_lbl 1020 `"Central Falls, RI"', add
label define city_lbl 1021 `"Centralia, IL"', add
label define city_lbl 1023 `"Chambersburg, PA"', add
label define city_lbl 1024 `"Champaign, IL"', add
label define city_lbl 1025 `"Chanute, KS"', add
label define city_lbl 1026 `"Charleroi, PA"', add
label define city_lbl 1027 `"Chandler, AZ"', add
label define city_lbl 1030 `"Charlestown, MA"', add
label define city_lbl 1050 `"Charleston, SC"', add
label define city_lbl 1060 `"Carolina, PR"', add
label define city_lbl 1070 `"Charleston, WV"', add
label define city_lbl 1090 `"Charlotte, NC"', add
label define city_lbl 1091 `"Charlottesville, VA"', add
label define city_lbl 1110 `"Chattanooga, TN"', add
label define city_lbl 1130 `"Chelsea, MA"', add
label define city_lbl 1140 `"Cheltenham, PA"', add
label define city_lbl 1150 `"Chesapeake, VA"', add
label define city_lbl 1170 `"Chester, PA"', add
label define city_lbl 1171 `"Cheyenne, WY"', add
label define city_lbl 1190 `"Chicago, IL"', add
label define city_lbl 1191 `"Chicago Heights, IL"', add
label define city_lbl 1192 `"Chickasha, OK"', add
label define city_lbl 1210 `"Chicopee, MA"', add
label define city_lbl 1230 `"Chillicothe, OH"', add
label define city_lbl 1250 `"Chula Vista, CA"', add
label define city_lbl 1270 `"Cicero, IL"', add
label define city_lbl 1290 `"Cincinnati, OH"', add
label define city_lbl 1291 `"Clairton, PA"', add
label define city_lbl 1292 `"Claremont, NH"', add
label define city_lbl 1310 `"Clarksburg, WV"', add
label define city_lbl 1311 `"Clarksdale, MS"', add
label define city_lbl 1312 `"Cleburne, TX"', add
label define city_lbl 1330 `"Cleveland, OH"', add
label define city_lbl 1340 `"Cleveland Heights, OH"', add
label define city_lbl 1341 `"Cliffside Park, NJ"', add
label define city_lbl 1350 `"Clifton, NJ"', add
label define city_lbl 1351 `"Clinton, IN"', add
label define city_lbl 1370 `"Clinton, IA"', add
label define city_lbl 1371 `"Clinton, MA"', add
label define city_lbl 1372 `"Coatesville, PA"', add
label define city_lbl 1373 `"Coffeyville, KS"', add
label define city_lbl 1374 `"Cohoes, NY"', add
label define city_lbl 1375 `"Collingswood, NJ"', add
label define city_lbl 1390 `"Colorado Springs, CO"', add
label define city_lbl 1400 `"Cohoes, NY"', add
label define city_lbl 1410 `"Columbia, SC"', add
label define city_lbl 1411 `"Columbia, PA"', add
label define city_lbl 1412 `"Columbia, MO"', add
label define city_lbl 1420 `"Columbia City, IN"', add
label define city_lbl 1430 `"Columbus, GA"', add
label define city_lbl 1450 `"Columbus, OH"', add
label define city_lbl 1451 `"Columbus, MS"', add
label define city_lbl 1452 `"Compton, CA"', add
label define city_lbl 1470 `"Concord, CA"', add
label define city_lbl 1490 `"Concord, NH"', add
label define city_lbl 1491 `"Concord, NC"', add
label define city_lbl 1492 `"Connellsville, PA"', add
label define city_lbl 1493 `"Connersville, IN"', add
label define city_lbl 1494 `"Conshohocken, PA"', add
label define city_lbl 1495 `"Coraopolis, PA"', add
label define city_lbl 1496 `"Corning, NY"', add
label define city_lbl 1500 `"Corona, CA"', add
label define city_lbl 1510 `"Council Bluffs, IA"', add
label define city_lbl 1520 `"Corpus Christi, TX"', add
label define city_lbl 1521 `"Corsicana, TX"', add
label define city_lbl 1522 `"Cortland, NY"', add
label define city_lbl 1523 `"Coshocton, OH"', add
label define city_lbl 1530 `"Covington, KY"', add
label define city_lbl 1540 `"Costa Mesa, CA"', add
label define city_lbl 1545 `"Cranford, NJ"', add
label define city_lbl 1550 `"Cranston, RI"', add
label define city_lbl 1551 `"Crawfordsville, IN"', add
label define city_lbl 1552 `"Cripple Creek, CO"', add
label define city_lbl 1553 `"Cudahy, WI"', add
label define city_lbl 1570 `"Cumberland, MD"', add
label define city_lbl 1571 `"Cumberland, RI"', add
label define city_lbl 1572 `"Cuyahoga Falls, OH"', add
label define city_lbl 1590 `"Dallas, TX"', add
label define city_lbl 1591 `"Danbury, CT"', add
label define city_lbl 1592 `"Daly City, CA"', add
label define city_lbl 1610 `"Danvers, MA"', add
label define city_lbl 1630 `"Danville, IL"', add
label define city_lbl 1631 `"Danville, VA"', add
label define city_lbl 1650 `"Davenport, IA"', add
label define city_lbl 1670 `"Dayton, OH"', add
label define city_lbl 1671 `"Daytona Beach, FL"', add
label define city_lbl 1680 `"Dearborn, MI"', add
label define city_lbl 1690 `"Decatur, IL"', add
label define city_lbl 1691 `"Decatur, AL"', add
label define city_lbl 1692 `"Decatur, GA"', add
label define city_lbl 1693 `"Dedham, MA"', add
label define city_lbl 1694 `"Del Rio, TX"', add
label define city_lbl 1695 `"Denison, TX"', add
label define city_lbl 1710 `"Denver, CO"', add
label define city_lbl 1711 `"Derby, CT"', add
label define city_lbl 1713 `"Derry, PA"', add
label define city_lbl 1730 `"Des Moines, IA"', add
label define city_lbl 1750 `"Detroit, MI"', add
label define city_lbl 1751 `"Dickson City, PA"', add
label define city_lbl 1752 `"Dodge, KS"', add
label define city_lbl 1753 `"Donora, PA"', add
label define city_lbl 1754 `"Dormont, PA"', add
label define city_lbl 1755 `"Dothan, AL"', add
label define city_lbl 1770 `"Dorchester, MA"', add
label define city_lbl 1790 `"Dover, NH"', add
label define city_lbl 1791 `"Dover, NJ"', add
label define city_lbl 1792 `"Du Bois, PA"', add
label define city_lbl 1800 `"Downey, CA"', add
label define city_lbl 1810 `"Dubuque, IA"', add
label define city_lbl 1830 `"Duluth, MN"', add
label define city_lbl 1831 `"Dunkirk, NY"', add
label define city_lbl 1832 `"Dunmore, PA"', add
label define city_lbl 1833 `"Duquesne, PA"', add
label define city_lbl 1834 `"Dundalk, MD"', add
label define city_lbl 1850 `"Durham, NC"', add
label define city_lbl 1870 `"East Chicago, IN"', add
label define city_lbl 1890 `"East Cleveland, OH"', add
label define city_lbl 1891 `"East Hartford, CT"', add
label define city_lbl 1892 `"East Liverpool, OH"', add
label define city_lbl 1893 `"East Moline, IL"', add
label define city_lbl 1910 `"East Los Angeles, CA"', add
label define city_lbl 1930 `"East Orange, NJ"', add
label define city_lbl 1931 `"East Providence, RI"', add
label define city_lbl 1940 `"East Saginaw, MI"', add
label define city_lbl 1950 `"East St. Louis, IL"', add
label define city_lbl 1951 `"East Youngstown, OH"', add
label define city_lbl 1952 `"Easthampton, MA"', add
label define city_lbl 1970 `"Easton, PA"', add
label define city_lbl 1971 `"Eau Claire, WI"', add
label define city_lbl 1972 `"Ecorse, MI"', add
label define city_lbl 1973 `"El Dorado, KS"', add
label define city_lbl 1974 `"El Dorado, AR"', add
label define city_lbl 1990 `"El Monte, CA"', add
label define city_lbl 2010 `"El Paso, TX"', add
label define city_lbl 2030 `"Elgin, IL"', add
label define city_lbl 2040 `"Elyria, OH"', add
label define city_lbl 2050 `"Elizabeth, NJ"', add
label define city_lbl 2051 `"Elizabeth City, NC"', add
label define city_lbl 2055 `"Elk Grove, CA"', add
label define city_lbl 2060 `"Elkhart, IN"', add
label define city_lbl 2061 `"Ellwood City, PA"', add
label define city_lbl 2062 `"Elmhurst, IL"', add
label define city_lbl 2070 `"Elmira, NY"', add
label define city_lbl 2071 `"Elmwood Park, IL"', add
label define city_lbl 2072 `"Elwood, IN"', add
label define city_lbl 2073 `"Emporia, KS"', add
label define city_lbl 2074 `"Endicott, NY"', add
label define city_lbl 2075 `"Enfield, CT"', add
label define city_lbl 2076 `"Englewood, NJ"', add
label define city_lbl 2080 `"Enid, OK"', add
label define city_lbl 2090 `"Erie, PA"', add
label define city_lbl 2091 `"Escanaba, MI"', add
label define city_lbl 2092 `"Euclid, OH"', add
label define city_lbl 2110 `"Escondido, CA"', add
label define city_lbl 2130 `"Eugene, OR"', add
label define city_lbl 2131 `"Eureka, CA"', add
label define city_lbl 2150 `"Evanston, IL"', add
label define city_lbl 2170 `"Evansville, IN"', add
label define city_lbl 2190 `"Everett, MA"', add
label define city_lbl 2210 `"Everett, WA"', add
label define city_lbl 2211 `"Fairfield, AL"', add
label define city_lbl 2212 `"Fairfield, CT"', add
label define city_lbl 2213 `"Fairhaven, MA"', add
label define city_lbl 2214 `"Fairmont, WV"', add
label define city_lbl 2220 `"Fargo, ND"', add
label define city_lbl 2221 `"Faribault, MN"', add
label define city_lbl 2222 `"Farrell, PA"', add
label define city_lbl 2230 `"Fall River, MA"', add
label define city_lbl 2240 `"Fayetteville, NC"', add
label define city_lbl 2241 `"Ferndale, MI"', add
label define city_lbl 2242 `"Findlay, OH"', add
label define city_lbl 2250 `"Fitchburg, MA"', add
label define city_lbl 2260 `"Fontana, CA"', add
label define city_lbl 2270 `"Flint, MI"', add
label define city_lbl 2271 `"Floral Park, NY"', add
label define city_lbl 2273 `"Florence, AL"', add
label define city_lbl 2274 `"Florence, SC"', add
label define city_lbl 2275 `"Flushing, NY"', add
label define city_lbl 2280 `"Fond du Lac, WI"', add
label define city_lbl 2281 `"Forest Park, IL"', add
label define city_lbl 2290 `"Fort Lauderdale, FL"', add
label define city_lbl 2300 `"Fort Collins, CO"', add
label define city_lbl 2301 `"Fort Dodge, IA"', add
label define city_lbl 2302 `"Fort Madison, IA"', add
label define city_lbl 2303 `"Fort Scott, KS"', add
label define city_lbl 2310 `"Fort Smith, AR"', add
label define city_lbl 2311 `"Fort Thomas, KY"', add
label define city_lbl 2330 `"Fort Wayne, IN"', add
label define city_lbl 2350 `"Fort Worth, TX"', add
label define city_lbl 2351 `"Fostoria, OH"', add
label define city_lbl 2352 `"Framingham, MA"', add
label define city_lbl 2353 `"Frankfort, IN"', add
label define city_lbl 2354 `"Frankfort, KY"', add
label define city_lbl 2355 `"Franklin, PA"', add
label define city_lbl 2356 `"Frederick, MD"', add
label define city_lbl 2357 `"Freeport, NY"', add
label define city_lbl 2358 `"Freeport, IL"', add
label define city_lbl 2359 `"Fremont, OH"', add
label define city_lbl 2360 `"Fremont, NE"', add
label define city_lbl 2370 `"Fresno, CA"', add
label define city_lbl 2390 `"Fullerton, CA"', add
label define city_lbl 2391 `"Fulton, NY"', add
label define city_lbl 2392 `"Gadsden, AL"', add
label define city_lbl 2393 `"Galena, KS"', add
label define city_lbl 2394 `"Gainesville, FL"', add
label define city_lbl 2400 `"Galesburg, IL"', add
label define city_lbl 2410 `"Galveston, TX"', add
label define city_lbl 2411 `"Gardner, MA"', add
label define city_lbl 2430 `"Garden Grove, CA"', add
label define city_lbl 2435 `"Gardena, CA"', add
label define city_lbl 2440 `"Garfield, NJ"', add
label define city_lbl 2441 `"Garfield Heights, OH"', add
label define city_lbl 2450 `"Garland, TX"', add
label define city_lbl 2470 `"Gary, IN"', add
label define city_lbl 2471 `"Gastonia, NC"', add
label define city_lbl 2472 `"Geneva, NY"', add
label define city_lbl 2473 `"Glen Cove, NY"', add
label define city_lbl 2489 `"Glendale, AZ"', add
label define city_lbl 2490 `"Glendale, CA"', add
label define city_lbl 2491 `"Glens Falls, NY"', add
label define city_lbl 2510 `"Gloucester, MA"', add
label define city_lbl 2511 `"Gloucester, NJ"', add
label define city_lbl 2512 `"Gloversville, NY"', add
label define city_lbl 2513 `"Goldsboro, NC"', add
label define city_lbl 2514 `"Goshen, IN"', add
label define city_lbl 2515 `"Grand Forks, ND"', add
label define city_lbl 2516 `"Grand Island, NE"', add
label define city_lbl 2517 `"Grand Junction, CO"', add
label define city_lbl 2520 `"Granite City, IL"', add
label define city_lbl 2530 `"Grand Rapids, MI"', add
label define city_lbl 2531 `"Grandville, MI"', add
label define city_lbl 2540 `"Great Falls, MT"', add
label define city_lbl 2541 `"Greeley, CO"', add
label define city_lbl 2550 `"Green Bay, WI"', add
label define city_lbl 2551 `"Greenfield, MA"', add
label define city_lbl 2570 `"Greensboro, NC"', add
label define city_lbl 2571 `"Greensburg, PA"', add
label define city_lbl 2572 `"Greenville, MS"', add
label define city_lbl 2573 `"Greenville, SC"', add
label define city_lbl 2574 `"Greenville, TX"', add
label define city_lbl 2575 `"Greenwich, CT"', add
label define city_lbl 2576 `"Greenwood, MS"', add
label define city_lbl 2577 `"Greenwood, SC"', add
label define city_lbl 2578 `"Griffin, GA"', add
label define city_lbl 2579 `"Grosse Pointe Park, MI"', add
label define city_lbl 2580 `"Guynabo, PR"', add
label define city_lbl 2581 `"Groton, CT"', add
label define city_lbl 2582 `"Gulfport, MS"', add
label define city_lbl 2583 `"Guthrie, OK"', add
label define city_lbl 2584 `"Hackensack, NJ"', add
label define city_lbl 2590 `"Hagerstown, MD"', add
label define city_lbl 2591 `"Hamden, CT"', add
label define city_lbl 2610 `"Hamilton, OH"', add
label define city_lbl 2630 `"Hammond, IN"', add
label define city_lbl 2650 `"Hampton, VA"', add
label define city_lbl 2670 `"Hamtramck village, MI"', add
label define city_lbl 2680 `"Hannibal, MO"', add
label define city_lbl 2681 `"Hanover, PA"', add
label define city_lbl 2682 `"Harlingen, TX"', add
label define city_lbl 2683 `"Hanover township, Luzerne county, PA"', add
label define city_lbl 2690 `"Harrisburg, PA"', add
label define city_lbl 2691 `"Harrisburg, IL"', add
label define city_lbl 2692 `"Harrison, NJ"', add
label define city_lbl 2693 `"Harrison, PA"', add
label define city_lbl 2710 `"Hartford, CT"', add
label define city_lbl 2711 `"Harvey, IL"', add
label define city_lbl 2712 `"Hastings, NE"', add
label define city_lbl 2713 `"Hattiesburg, MS"', add
label define city_lbl 2725 `"Haverford, PA"', add
label define city_lbl 2730 `"Haverhill, MA"', add
label define city_lbl 2731 `"Hawthorne, NJ"', add
label define city_lbl 2740 `"Hayward, CA"', add
label define city_lbl 2750 `"Hazleton, PA"', add
label define city_lbl 2751 `"Helena, MT"', add
label define city_lbl 2752 `"Hempstead, NY"', add
label define city_lbl 2753 `"Henderson, KY"', add
label define city_lbl 2754 `"Herkimer, NY"', add
label define city_lbl 2755 `"Herrin, IL"', add
label define city_lbl 2756 `"Hibbing, MN"', add
label define city_lbl 2757 `"Henderson, NV"', add
label define city_lbl 2770 `"Hialeah, FL"', add
label define city_lbl 2780 `"High Point, NC"', add
label define city_lbl 2781 `"Highland Park, IL"', add
label define city_lbl 2790 `"Highland Park, MI"', add
label define city_lbl 2791 `"Hilo, HI"', add
label define city_lbl 2792 `"Hillside, NJ"', add
label define city_lbl 2810 `"Hoboken, NJ"', add
label define city_lbl 2811 `"Holland, MI"', add
label define city_lbl 2830 `"Hollywood, FL"', add
label define city_lbl 2850 `"Holyoke, MA"', add
label define city_lbl 2851 `"Homestead, PA"', add
label define city_lbl 2870 `"Honolulu, HI"', add
label define city_lbl 2871 `"Hopewell, VA"', add
label define city_lbl 2872 `"Hopkinsville, KY"', add
label define city_lbl 2873 `"Hoquiam, WA"', add
label define city_lbl 2874 `"Hornell, NY"', add
label define city_lbl 2875 `"Hot Springs, AR"', add
label define city_lbl 2890 `"Houston, TX"', add
label define city_lbl 2891 `"Hudson, NY"', add
label define city_lbl 2892 `"Huntington, IN"', add
label define city_lbl 2910 `"Huntington, WV"', add
label define city_lbl 2930 `"Huntington Beach, CA"', add
label define city_lbl 2950 `"Huntsville, AL"', add
label define city_lbl 2951 `"Huron, SD"', add
label define city_lbl 2960 `"Hutchinson, KS"', add
label define city_lbl 2961 `"Hyde Park, MA"', add
label define city_lbl 2962 `"Ilion, NY"', add
label define city_lbl 2963 `"Independence, KS"', add
label define city_lbl 2970 `"Independence, MO"', add
label define city_lbl 2990 `"Indianapolis, IN"', add
label define city_lbl 3010 `"Inglewood, CA"', add
label define city_lbl 3011 `"Iowa City, IA"', add
label define city_lbl 3012 `"Iron Mountain, MI"', add
label define city_lbl 3013 `"Ironton, OH"', add
label define city_lbl 3014 `"Ironwood, MI"', add
label define city_lbl 3015 `"Irondequoit, NY"', add
label define city_lbl 3020 `"Irvine, CA"', add
label define city_lbl 3030 `"Irving, TX"', add
label define city_lbl 3050 `"Irvington, NJ"', add
label define city_lbl 3051 `"Ishpeming, MI"', add
label define city_lbl 3052 `"Ithaca, NY"', add
label define city_lbl 3070 `"Jackson, MI"', add
label define city_lbl 3071 `"Jackson, MN"', add
label define city_lbl 3090 `"Jackson, MS"', add
label define city_lbl 3091 `"Jackson, TN"', add
label define city_lbl 3110 `"Jacksonville, FL"', add
label define city_lbl 3111 `"Jacksonville, IL"', add
label define city_lbl 3130 `"Jamestown, NY"', add
label define city_lbl 3131 `"Janesville, WI"', add
label define city_lbl 3132 `"Jeannette, PA"', add
label define city_lbl 3133 `"Jefferson City, MO"', add
label define city_lbl 3134 `"Jeffersonville, IN"', add
label define city_lbl 3150 `"Jersey City, NJ"', add
label define city_lbl 3151 `"Johnson City, NY"', add
label define city_lbl 3160 `"Johnson City, TN"', add
label define city_lbl 3161 `"Johnstown, NY"', add
label define city_lbl 3170 `"Johnstown, PA"', add
label define city_lbl 3190 `"Joliet, IL"', add
label define city_lbl 3191 `"Jonesboro, AR"', add
label define city_lbl 3210 `"Joplin, MO"', add
label define city_lbl 3230 `"Kalamazoo, MI"', add
label define city_lbl 3231 `"Kankakee, IL"', add
label define city_lbl 3250 `"Kansas City, KS"', add
label define city_lbl 3260 `"Kansas City, MO"', add
label define city_lbl 3270 `"Kearney, NJ"', add
label define city_lbl 3271 `"Keene, NH"', add
label define city_lbl 3272 `"Kenmore, NY"', add
label define city_lbl 3273 `"Kenmore, OH"', add
label define city_lbl 3290 `"Kenosha, WI"', add
label define city_lbl 3291 `"Keokuk, IA"', add
label define city_lbl 3292 `"Kewanee, IL"', add
label define city_lbl 3293 `"Key West, FL"', add
label define city_lbl 3294 `"Kingsport, TN"', add
label define city_lbl 3310 `"Kingston, NY"', add
label define city_lbl 3311 `"Kingston, PA"', add
label define city_lbl 3312 `"Kinston, NC"', add
label define city_lbl 3313 `"Klamath Falls, OR"', add
label define city_lbl 3330 `"Knoxville, TN"', add
label define city_lbl 3350 `"Kokomo, IN"', add
label define city_lbl 3370 `"LaCrosse, WI"', add
label define city_lbl 3380 `"Lafayette, IN"', add
label define city_lbl 3390 `"Lafayette, LA"', add
label define city_lbl 3391 `"La Grange, IL"', add
label define city_lbl 3392 `"La Grange, GA"', add
label define city_lbl 3393 `"La Porte, IN"', add
label define city_lbl 3394 `"La Salle, IL"', add
label define city_lbl 3395 `"Lackawanna, NY"', add
label define city_lbl 3396 `"Laconia, NH"', add
label define city_lbl 3400 `"Lake Charles, LA"', add
label define city_lbl 3405 `"Lakeland, FL"', add
label define city_lbl 3410 `"Lakewood, CO"', add
label define city_lbl 3430 `"Lakewood, OH"', add
label define city_lbl 3440 `"Lancaster, CA"', add
label define city_lbl 3450 `"Lancaster, PA"', add
label define city_lbl 3451 `"Lancaster, OH"', add
label define city_lbl 3470 `"Lansing, MI"', add
label define city_lbl 3471 `"Lansingburgh, NY"', add
label define city_lbl 3480 `"Laredo, TX"', add
label define city_lbl 3481 `"Latrobe, PA"', add
label define city_lbl 3482 `"Laurel, MS"', add
label define city_lbl 3490 `"Las Vegas, NV"', add
label define city_lbl 3510 `"Lawrence, MA"', add
label define city_lbl 3511 `"Lawrence, KS"', add
label define city_lbl 3512 `"Lawton, OK"', add
label define city_lbl 3513 `"Leadville, CO"', add
label define city_lbl 3520 `"Leavenworth, KS"', add
label define city_lbl 3521 `"Lebanon, PA"', add
label define city_lbl 3522 `"Leominster, MA"', add
label define city_lbl 3530 `"Lehigh, PA"', add
label define city_lbl 3540 `"Lebanon, PA"', add
label define city_lbl 3550 `"Lewiston, ME"', add
label define city_lbl 3551 `"Lewistown, PA"', add
label define city_lbl 3560 `"Lewisville, TX"', add
label define city_lbl 3570 `"Lexington, KY"', add
label define city_lbl 3590 `"Lexington-Fayette, KY"', add
label define city_lbl 3610 `"Lima, OH"', add
label define city_lbl 3630 `"Lincoln, NE"', add
label define city_lbl 3631 `"Lincoln, IL"', add
label define city_lbl 3632 `"Lincoln Park, MI"', add
label define city_lbl 3633 `"Lincoln, RI"', add
label define city_lbl 3634 `"Linden, NJ"', add
label define city_lbl 3635 `"Little Falls, NY"', add
label define city_lbl 3638 `"Lodi, NJ"', add
label define city_lbl 3639 `"Logansport, IN"', add
label define city_lbl 3650 `"Little Rock, AR"', add
label define city_lbl 3670 `"Livonia, MI"', add
label define city_lbl 3680 `"Lockport, NY"', add
label define city_lbl 3690 `"Long Beach, CA"', add
label define city_lbl 3691 `"Long Branch, NJ"', add
label define city_lbl 3692 `"Long Island City, NY"', add
label define city_lbl 3693 `"Longview, WA"', add
label define city_lbl 3710 `"Lorain, OH"', add
label define city_lbl 3730 `"Los Angeles, CA"', add
label define city_lbl 3750 `"Louisville, KY"', add
label define city_lbl 3765 `"Lower Merion, PA"', add
label define city_lbl 3770 `"Lowell, MA"', add
label define city_lbl 3771 `"Lubbock, TX"', add
label define city_lbl 3772 `"Lynbrook, NY"', add
label define city_lbl 3790 `"Lynchburg, VA"', add
label define city_lbl 3800 `"Lyndhurst, NJ"', add
label define city_lbl 3810 `"Lynn, MA"', add
label define city_lbl 3830 `"Macon, GA"', add
label define city_lbl 3850 `"Madison, IN"', add
label define city_lbl 3870 `"Madison, WI"', add
label define city_lbl 3871 `"Mahanoy City, PA"', add
label define city_lbl 3890 `"Malden, MA"', add
label define city_lbl 3891 `"Mamaroneck, NY"', add
label define city_lbl 3910 `"Manchester, NH"', add
label define city_lbl 3911 `"Manchester, CT"', add
label define city_lbl 3912 `"Manhattan, KS"', add
label define city_lbl 3913 `"Manistee, MI"', add
label define city_lbl 3914 `"Manitowoc, WI"', add
label define city_lbl 3915 `"Mankato, MN"', add
label define city_lbl 3929 `"Maplewood, NJ"', add
label define city_lbl 3930 `"Mansfield, OH"', add
label define city_lbl 3931 `"Maplewood, MO"', add
label define city_lbl 3932 `"Marietta, OH"', add
label define city_lbl 3933 `"Marinette, WI"', add
label define city_lbl 3934 `"Marion, IN"', add
label define city_lbl 3940 `"Maywood, IL"', add
label define city_lbl 3950 `"Marion, OH"', add
label define city_lbl 3951 `"Marlborough, MA"', add
label define city_lbl 3952 `"Marquette, MI"', add
label define city_lbl 3953 `"Marshall, TX"', add
label define city_lbl 3954 `"Marshalltown, IA"', add
label define city_lbl 3955 `"Martins Ferry, OH"', add
label define city_lbl 3956 `"Martinsburg, WV"', add
label define city_lbl 3957 `"Mason City, IA"', add
label define city_lbl 3958 `"Massena, NY"', add
label define city_lbl 3959 `"Massillon, OH"', add
label define city_lbl 3960 `"McAllen, TX"', add
label define city_lbl 3961 `"Mattoon, IL"', add
label define city_lbl 3962 `"Mcalester, OK"', add
label define city_lbl 3963 `"Mccomb, MS"', add
label define city_lbl 3964 `"Mckees Rocks, PA"', add
label define city_lbl 3970 `"McKeesport, PA"', add
label define city_lbl 3971 `"Meadville, PA"', add
label define city_lbl 3990 `"Medford, MA"', add
label define city_lbl 3991 `"Medford, OR"', add
label define city_lbl 3992 `"Melrose, MA"', add
label define city_lbl 3993 `"Melrose Park, IL"', add
label define city_lbl 4010 `"Memphis, TN"', add
label define city_lbl 4011 `"Menominee, MI"', add
label define city_lbl 4030 `"Meriden, CT"', add
label define city_lbl 4040 `"Meridian, MS"', add
label define city_lbl 4041 `"Methuen, MA"', add
label define city_lbl 4050 `"Mesa, AZ"', add
label define city_lbl 4070 `"Mesquite, TX"', add
label define city_lbl 4090 `"Metairie, LA"', add
label define city_lbl 4110 `"Miami, FL"', add
label define city_lbl 4120 `"Michigan City, IN"', add
label define city_lbl 4121 `"Middlesboro, KY"', add
label define city_lbl 4122 `"Middletown, CT"', add
label define city_lbl 4123 `"Middletown, NY"', add
label define city_lbl 4124 `"Middletown, OH"', add
label define city_lbl 4125 `"Milford, CT"', add
label define city_lbl 4126 `"Milford, MA"', add
label define city_lbl 4127 `"Millville, NJ"', add
label define city_lbl 4128 `"Milton, MA"', add
label define city_lbl 4130 `"Milwaukee, WI"', add
label define city_lbl 4150 `"Minneapolis, MN"', add
label define city_lbl 4151 `"Minot, ND"', add
label define city_lbl 4160 `"Mishawaka, IN"', add
label define city_lbl 4161 `"Missoula, MT"', add
label define city_lbl 4162 `"Mitchell, SD"', add
label define city_lbl 4163 `"Moberly, MO"', add
label define city_lbl 4170 `"Mobile, AL"', add
label define city_lbl 4190 `"Modesto, CA"', add
label define city_lbl 4210 `"Moline, IL"', add
label define city_lbl 4211 `"Monessen, PA"', add
label define city_lbl 4212 `"Monroe, MI"', add
label define city_lbl 4213 `"Monroe, LA"', add
label define city_lbl 4214 `"Monrovia, CA"', add
label define city_lbl 4230 `"Montclair, NJ"', add
label define city_lbl 4250 `"Montgomery, AL"', add
label define city_lbl 4251 `"Morgantown, WV"', add
label define city_lbl 4252 `"Morristown, NJ"', add
label define city_lbl 4253 `"Moundsville, WV"', add
label define city_lbl 4254 `"Mount Arlington, NJ"', add
label define city_lbl 4255 `"Mount Carmel, PA"', add
label define city_lbl 4256 `"Mount Clemens, MI"', add
label define city_lbl 4260 `"Mount Lebanon, PA"', add
label define city_lbl 4270 `"Moreno Valley, CA"', add
label define city_lbl 4290 `"Mount Vernon, NY"', add
label define city_lbl 4291 `"Mount Vernon, IL"', add
label define city_lbl 4310 `"Muncie, IN"', add
label define city_lbl 4311 `"Munhall, PA"', add
label define city_lbl 4312 `"Murphysboro, IL"', add
label define city_lbl 4313 `"Muscatine, IA"', add
label define city_lbl 4330 `"Muskegon, MI"', add
label define city_lbl 4331 `"Muskegon Heights, MI"', add
label define city_lbl 4350 `"Muskogee, OK"', add
label define city_lbl 4351 `"Nanticoke, PA"', add
label define city_lbl 4370 `"Nantucket, MA"', add
label define city_lbl 4390 `"Nashua, NH"', add
label define city_lbl 4410 `"Nashville-Davidson, TN"', add
label define city_lbl 4411 `"Nashville, TN"', add
label define city_lbl 4413 `"Natchez, MS"', add
label define city_lbl 4414 `"Natick, MA"', add
label define city_lbl 4415 `"Naugatuck, CT"', add
label define city_lbl 4416 `"Needham, MA"', add
label define city_lbl 4420 `"Neptune, NJ"', add
label define city_lbl 4430 `"New Albany, IN"', add
label define city_lbl 4450 `"New Bedford, MA"', add
label define city_lbl 4451 `"New Bern, NC"', add
label define city_lbl 4452 `"New Brighton, NY"', add
label define city_lbl 4470 `"New Britain, CT"', add
label define city_lbl 4490 `"New Brunswick, NJ"', add
label define city_lbl 4510 `"New Castle, PA"', add
label define city_lbl 4511 `"New Castle, IN"', add
label define city_lbl 4530 `"New Haven, CT"', add
label define city_lbl 4550 `"New London, CT"', add
label define city_lbl 4570 `"New Orleans, LA"', add
label define city_lbl 4571 `"New Philadelphia, OH"', add
label define city_lbl 4590 `"New Rochelle, NY"', add
label define city_lbl 4610 `"New York, NY"', add
label define city_lbl 4611 `"Brooklyn, NY"', add
label define city_lbl 4630 `"Newark, NJ"', add
label define city_lbl 4650 `"Newark, OH"', add
label define city_lbl 4670 `"Newburgh, NY"', add
label define city_lbl 4690 `"Newburyport, MA"', add
label define city_lbl 4710 `"Newport, KY"', add
label define city_lbl 4730 `"Newport, RI"', add
label define city_lbl 4750 `"Newport News, VA"', add
label define city_lbl 4770 `"Newton, MA"', add
label define city_lbl 4771 `"Newton, IA"', add
label define city_lbl 4772 `"Newton, KS"', add
label define city_lbl 4790 `"Niagara Falls, NY"', add
label define city_lbl 4791 `"Niles, MI"', add
label define city_lbl 4792 `"Niles, OH"', add
label define city_lbl 4810 `"Norfolk, VA"', add
label define city_lbl 4811 `"Norfolk, NE"', add
label define city_lbl 4820 `"North Las Vegas, NV"', add
label define city_lbl 4830 `"Norristown Boro, PA"', add
label define city_lbl 4831 `"North Adams, MA"', add
label define city_lbl 4832 `"North Attleborough, MA"', add
label define city_lbl 4833 `"North Bennington, VT"', add
label define city_lbl 4834 `"North Braddock, PA"', add
label define city_lbl 4835 `"North Branford, CT"', add
label define city_lbl 4836 `"North Haven, CT"', add
label define city_lbl 4837 `"North Little Rock, AR"', add
label define city_lbl 4838 `"North Platte, NE"', add
label define city_lbl 4839 `"North Providence, RI"', add
label define city_lbl 4840 `"Northampton, MA"', add
label define city_lbl 4841 `"North Tonawanda, NY"', add
label define city_lbl 4842 `"North Yakima, WA"', add
label define city_lbl 4843 `"Northbridge, MA"', add
label define city_lbl 4845 `"North Bergen, NJ"', add
label define city_lbl 4850 `"North Providence, RI"', add
label define city_lbl 4860 `"Norwalk, CA"', add
label define city_lbl 4870 `"Norwalk, CT"', add
label define city_lbl 4890 `"Norwich, CT"', add
label define city_lbl 4900 `"Norwood, OH"', add
label define city_lbl 4901 `"Norwood, MA"', add
label define city_lbl 4902 `"Nutley, NJ"', add
label define city_lbl 4905 `"Oak Park, IL"', add
label define city_lbl 4910 `"Oak Park Village, IL"', add
label define city_lbl 4930 `"Oakland, CA"', add
label define city_lbl 4950 `"Oceanside, CA"', add
label define city_lbl 4970 `"Ogden, UT"', add
label define city_lbl 4971 `"Ogdensburg, NY"', add
label define city_lbl 4972 `"Oil City, PA"', add
label define city_lbl 4990 `"Oklahoma City, OK"', add
label define city_lbl 4991 `"Okmulgee, OK"', add
label define city_lbl 4992 `"Old Bennington, VT"', add
label define city_lbl 4993 `"Old Forge, PA"', add
label define city_lbl 4994 `"Olean, NY"', add
label define city_lbl 4995 `"Olympia, WA"', add
label define city_lbl 4996 `"Olyphant, PA"', add
label define city_lbl 5010 `"Omaha, NE"', add
label define city_lbl 5011 `"Oneida, NY"', add
label define city_lbl 5012 `"Oneonta, NY"', add
label define city_lbl 5030 `"Ontario, CA"', add
label define city_lbl 5040 `"Orange, CA"', add
label define city_lbl 5050 `"Orange, NJ"', add
label define city_lbl 5051 `"Orange, CT"', add
label define city_lbl 5070 `"Orlando, FL"', add
label define city_lbl 5090 `"Oshkosh, WI"', add
label define city_lbl 5091 `"Oskaloosa, IA"', add
label define city_lbl 5092 `"Ossining, NY"', add
label define city_lbl 5110 `"Oswego, NY"', add
label define city_lbl 5111 `"Ottawa, IL"', add
label define city_lbl 5112 `"Ottumwa, IA"', add
label define city_lbl 5113 `"Owensboro, KY"', add
label define city_lbl 5114 `"Owosso, MI"', add
label define city_lbl 5116 `"Painesville, OH"', add
label define city_lbl 5117 `"Palestine, TX"', add
label define city_lbl 5118 `"Palo Alto, CA"', add
label define city_lbl 5119 `"Pampa, TX"', add
label define city_lbl 5121 `"Paris, TX"', add
label define city_lbl 5122 `"Park Ridge, IL"', add
label define city_lbl 5123 `"Parkersburg, WV"', add
label define city_lbl 5124 `"Parma, OH"', add
label define city_lbl 5125 `"Parsons, KS"', add
label define city_lbl 5130 `"Oxnard, CA"', add
label define city_lbl 5140 `"Palmdale, CA"', add
label define city_lbl 5150 `"Pasadena, CA"', add
label define city_lbl 5170 `"Pasadena, TX"', add
label define city_lbl 5180 `"Paducah, KY"', add
label define city_lbl 5190 `"Passaic, NJ"', add
label define city_lbl 5210 `"Paterson, NJ"', add
label define city_lbl 5230 `"Pawtucket, RI"', add
label define city_lbl 5231 `"Peabody, MA"', add
label define city_lbl 5232 `"Peekskill, NY"', add
label define city_lbl 5233 `"Pekin, IL"', add
label define city_lbl 5240 `"Pembroke Pines, FL"', add
label define city_lbl 5250 `"Pensacola, FL"', add
label define city_lbl 5255 `"Pensauken, NJ"', add
label define city_lbl 5269 `"Peoria, AZ"', add
label define city_lbl 5270 `"Peoria, IL"', add
label define city_lbl 5271 `"Peoria Heights, IL"', add
label define city_lbl 5290 `"Perth Amboy, NJ"', add
label define city_lbl 5291 `"Peru, IN"', add
label define city_lbl 5310 `"Petersburg, VA"', add
label define city_lbl 5311 `"Phenix City, AL"', add
label define city_lbl 5330 `"Philadelphia, PA"', add
label define city_lbl 5331 `"Kensington"', add
label define city_lbl 5332 `"Moyamensing"', add
label define city_lbl 5333 `"Northern Liberties"', add
label define city_lbl 5334 `"Southwark"', add
label define city_lbl 5335 `"Spring Garden"', add
label define city_lbl 5341 `"Phillipsburg, NJ"', add
label define city_lbl 5350 `"Phoenix, AZ"', add
label define city_lbl 5351 `"Phoenixville, PA"', add
label define city_lbl 5352 `"Pine Bluff, AR"', add
label define city_lbl 5353 `"Piqua, OH"', add
label define city_lbl 5354 `"Pittsburg, KS"', add
label define city_lbl 5370 `"Pittsburgh, PA"', add
label define city_lbl 5390 `"Pittsfield, MA"', add
label define city_lbl 5391 `"Pittston, PA"', add
label define city_lbl 5409 `"Plains, PA"', add
label define city_lbl 5410 `"Plainfield, NJ"', add
label define city_lbl 5411 `"Plattsburg, NY"', add
label define city_lbl 5412 `"Pleasantville, NJ"', add
label define city_lbl 5413 `"Plymouth, PA"', add
label define city_lbl 5414 `"Plymouth, MA"', add
label define city_lbl 5415 `"Pocatello, ID"', add
label define city_lbl 5430 `"Plano, TX"', add
label define city_lbl 5450 `"Pomona, CA"', add
label define city_lbl 5451 `"Ponca City, OK"', add
label define city_lbl 5460 `"Ponce, PR"', add
label define city_lbl 5470 `"Pontiac, MI"', add
label define city_lbl 5471 `"Port Angeles, WA"', add
label define city_lbl 5480 `"Port Arthur, TX"', add
label define city_lbl 5481 `"Port Chester, NY"', add
label define city_lbl 5490 `"Port Huron, MI"', add
label define city_lbl 5491 `"Port Jervis, NY"', add
label define city_lbl 5500 `"Port St. Lucie, FL"', add
label define city_lbl 5510 `"Portland, ME"', add
label define city_lbl 5511 `"Portland, IL"', add
label define city_lbl 5530 `"Portland, OR"', add
label define city_lbl 5550 `"Portsmouth, NH"', add
label define city_lbl 5570 `"Portsmouth, OH"', add
label define city_lbl 5590 `"Portsmouth, VA"', add
label define city_lbl 5591 `"Pottstown, PA"', add
label define city_lbl 5610 `"Pottsville, PA"', add
label define city_lbl 5630 `"Poughkeepsie, NY"', add
label define city_lbl 5650 `"Providence, RI"', add
label define city_lbl 5660 `"Provo, UT"', add
label define city_lbl 5670 `"Pueblo, CO"', add
label define city_lbl 5671 `"Punxsutawney, PA"', add
label define city_lbl 5690 `"Quincy, IL"', add
label define city_lbl 5710 `"Quincy, MA"', add
label define city_lbl 5730 `"Racine, WI"', add
label define city_lbl 5731 `"Rahway, NJ"', add
label define city_lbl 5750 `"Raleigh, NC"', add
label define city_lbl 5751 `"Ranger, TX"', add
label define city_lbl 5752 `"Rapid City, SD"', add
label define city_lbl 5770 `"Rancho Cucamonga, CA"', add
label define city_lbl 5790 `"Reading, PA"', add
label define city_lbl 5791 `"Red Bank, NJ"', add
label define city_lbl 5792 `"Redlands, CA"', add
label define city_lbl 5810 `"Reno, NV"', add
label define city_lbl 5811 `"Rensselaer, NY"', add
label define city_lbl 5830 `"Revere, MA"', add
label define city_lbl 5850 `"Richmond, IN"', add
label define city_lbl 5870 `"Richmond, VA"', add
label define city_lbl 5871 `"Richmond, CA"', add
label define city_lbl 5872 `"Ridgefield Park, NJ"', add
label define city_lbl 5873 `"Ridgewood, NJ"', add
label define city_lbl 5874 `"River Rouge, MI"', add
label define city_lbl 5890 `"Riverside, CA"', add
label define city_lbl 5910 `"Roanoke, VA"', add
label define city_lbl 5930 `"Rochester, NY"', add
label define city_lbl 5931 `"Rochester, NH"', add
label define city_lbl 5932 `"Rochester, MN"', add
label define city_lbl 5933 `"Rock Hill, SC"', add
label define city_lbl 5950 `"Rock Island, IL"', add
label define city_lbl 5970 `"Rockford, IL"', add
label define city_lbl 5971 `"Rockland, ME"', add
label define city_lbl 5972 `"Rockton, IL"', add
label define city_lbl 5973 `"Rockville Centre, NY"', add
label define city_lbl 5974 `"Rocky Mount, NC"', add
label define city_lbl 5990 `"Rome, NY"', add
label define city_lbl 5991 `"Rome, GA"', add
label define city_lbl 5992 `"Roosevelt, NJ"', add
label define city_lbl 5993 `"Roselle, NJ"', add
label define city_lbl 5994 `"Roswell, NM"', add
label define city_lbl 5995 `"Roseville, CA"', add
label define city_lbl 6010 `"Roxbury, MA"', add
label define city_lbl 6011 `"Royal Oak, MI"', add
label define city_lbl 6012 `"Rumford Falls, ME"', add
label define city_lbl 6013 `"Rutherford, NJ"', add
label define city_lbl 6014 `"Rutland, VT"', add
label define city_lbl 6030 `"Sacramento, CA"', add
label define city_lbl 6050 `"Saginaw, MI"', add
label define city_lbl 6070 `"Saint Joseph, MO"', add
label define city_lbl 6090 `"Saint Louis, MO"', add
label define city_lbl 6110 `"Saint Paul, MN"', add
label define city_lbl 6130 `"Saint Petersburg, FL"', add
label define city_lbl 6150 `"Salem, MA"', add
label define city_lbl 6170 `"Salem, OR"', add
label define city_lbl 6171 `"Salem, OH"', add
label define city_lbl 6172 `"Salina, KS"', add
label define city_lbl 6190 `"Salinas, CA"', add
label define city_lbl 6191 `"Salisbury, NC"', add
label define city_lbl 6192 `"Salisbury, MD"', add
label define city_lbl 6210 `"Salt Lake City, UT"', add
label define city_lbl 6211 `"San Angelo, TX"', add
label define city_lbl 6220 `"San Angelo, TX"', add
label define city_lbl 6230 `"San Antonio, TX"', add
label define city_lbl 6231 `"San Benito, TX"', add
label define city_lbl 6250 `"San Bernardino, CA"', add
label define city_lbl 6260 `"San Buenaventura (Ventura), CA"', add
label define city_lbl 6270 `"San Diego, CA"', add
label define city_lbl 6280 `"Sandusky, OH"', add
label define city_lbl 6281 `"Sanford, FL"', add
label define city_lbl 6282 `"Sanford, ME"', add
label define city_lbl 6290 `"San Francisco, CA"', add
label define city_lbl 6300 `"San Juan, PR"', add
label define city_lbl 6310 `"San Jose, CA"', add
label define city_lbl 6311 `"San Leandro, CA"', add
label define city_lbl 6312 `"San Mateo, CA"', add
label define city_lbl 6320 `"Santa Barbara, CA"', add
label define city_lbl 6321 `"Santa Cruz, CA"', add
label define city_lbl 6322 `"Santa Fe, NM"', add
label define city_lbl 6330 `"Santa Ana, CA"', add
label define city_lbl 6335 `"Santa Clara, CA"', add
label define city_lbl 6340 `"Santa Clarita, CA"', add
label define city_lbl 6350 `"Santa Rosa, CA"', add
label define city_lbl 6351 `"Sapulpa, OK"', add
label define city_lbl 6352 `"Saratoga Springs, NY"', add
label define city_lbl 6353 `"Saugus, MA"', add
label define city_lbl 6354 `"Sault Ste. Marie, MI"', add
label define city_lbl 6360 `"Santa Monica, CA"', add
label define city_lbl 6370 `"Savannah, GA"', add
label define city_lbl 6390 `"Schenectady, NY"', add
label define city_lbl 6410 `"Scranton, PA"', add
label define city_lbl 6430 `"Seattle, WA"', add
label define city_lbl 6431 `"Sedalia, MO"', add
label define city_lbl 6432 `"Selma, AL"', add
label define city_lbl 6433 `"Seminole, OK"', add
label define city_lbl 6434 `"Shaker Heights, OH"', add
label define city_lbl 6435 `"Shamokin, PA"', add
label define city_lbl 6437 `"Sharpsville, PA"', add
label define city_lbl 6438 `"Shawnee, OK"', add
label define city_lbl 6440 `"Sharon, PA"', add
label define city_lbl 6450 `"Sheboygan, WI"', add
label define city_lbl 6451 `"Shelby, NC"', add
label define city_lbl 6452 `"Shelbyville, IN"', add
label define city_lbl 6453 `"Shelton, CT"', add
label define city_lbl 6470 `"Shenandoah Borough, PA"', add
label define city_lbl 6471 `"Sherman, TX"', add
label define city_lbl 6472 `"Shorewood, WI"', add
label define city_lbl 6490 `"Shreveport, LA"', add
label define city_lbl 6500 `"Simi Valley, CA"', add
label define city_lbl 6510 `"Sioux City, IA"', add
label define city_lbl 6530 `"Sioux Falls, SD"', add
label define city_lbl 6550 `"Smithfield, RI"', add
label define city_lbl 6570 `"Somerville, MA"', add
label define city_lbl 6590 `"South Bend, IN"', add
label define city_lbl 6591 `"South Bethlehem, PA"', add
label define city_lbl 6592 `"South Boise, ID"', add
label define city_lbl 6593 `"South Gate, CA"', add
label define city_lbl 6594 `"South Milwaukee, WI"', add
label define city_lbl 6595 `"South Norwalk, CT"', add
label define city_lbl 6610 `"South Omaha, NE"', add
label define city_lbl 6611 `"South Orange, NJ"', add
label define city_lbl 6612 `"South Pasadena, CA"', add
label define city_lbl 6613 `"South Pittsburgh, PA"', add
label define city_lbl 6614 `"South Portland, ME"', add
label define city_lbl 6615 `"South River, NJ"', add
label define city_lbl 6616 `"South St. Paul, MN"', add
label define city_lbl 6617 `"Southbridge, MA"', add
label define city_lbl 6620 `"Spartanburg, SC"', add
label define city_lbl 6630 `"Spokane, WA"', add
label define city_lbl 6640 `"Spring Valley, NV"', add
label define city_lbl 6650 `"Springfield, IL"', add
label define city_lbl 6670 `"Springfield, MA"', add
label define city_lbl 6690 `"Springfield, MO"', add
label define city_lbl 6691 `"St. Augustine, FL"', add
label define city_lbl 6692 `"St. Charles, MO"', add
label define city_lbl 6693 `"St. Cloud, MN"', add
label define city_lbl 6710 `"Springfield, OH"', add
label define city_lbl 6730 `"Stamford, CT"', add
label define city_lbl 6731 `"Statesville, NC"', add
label define city_lbl 6732 `"Staunton, VA"', add
label define city_lbl 6733 `"Steelton, PA"', add
label define city_lbl 6734 `"Sterling, IL"', add
label define city_lbl 6750 `"Sterling Heights, MI"', add
label define city_lbl 6770 `"Steubenville, OH"', add
label define city_lbl 6771 `"Stevens Point, WI"', add
label define city_lbl 6772 `"Stillwater, MN"', add
label define city_lbl 6789 `"Stowe, PA"', add
label define city_lbl 6790 `"Stockton, CA"', add
label define city_lbl 6791 `"Stoneham, MA"', add
label define city_lbl 6792 `"Stonington, CT"', add
label define city_lbl 6793 `"Stratford, CT"', add
label define city_lbl 6794 `"Streator, IL"', add
label define city_lbl 6795 `"Struthers, OH"', add
label define city_lbl 6796 `"Suffolk, VA"', add
label define city_lbl 6797 `"Summit, NJ"', add
label define city_lbl 6798 `"Sumter, SC"', add
label define city_lbl 6799 `"Sunbury, PA"', add
label define city_lbl 6810 `"Sunnyvale, CA"', add
label define city_lbl 6830 `"Superior, WI"', add
label define city_lbl 6831 `"Swampscott, MA"', add
label define city_lbl 6832 `"Sweetwater, TX"', add
label define city_lbl 6833 `"Swissvale, PA"', add
label define city_lbl 6850 `"Syracuse, NY"', add
label define city_lbl 6870 `"Tacoma, WA"', add
label define city_lbl 6871 `"Tallahassee, FL"', add
label define city_lbl 6872 `"Tamaqua, PA"', add
label define city_lbl 6890 `"Tampa, FL"', add
label define city_lbl 6910 `"Taunton, MA"', add
label define city_lbl 6911 `"Taylor, PA"', add
label define city_lbl 6912 `"Temple, TX"', add
label define city_lbl 6913 `"Teaneck, NJ"', add
label define city_lbl 6930 `"Tempe, AZ"', add
label define city_lbl 6950 `"Terre Haute, IN"', add
label define city_lbl 6951 `"Texarkana, TX"', add
label define city_lbl 6952 `"Thomasville, GA"', add
label define city_lbl 6953 `"Thomasville, NC"', add
label define city_lbl 6954 `"Tiffin, OH"', add
label define city_lbl 6960 `"Thousand Oaks, CA"', add
label define city_lbl 6970 `"Toledo, OH"', add
label define city_lbl 6971 `"Tonawanda, NY"', add
label define city_lbl 6990 `"Topeka, KS"', add
label define city_lbl 6991 `"Torrington, CT"', add
label define city_lbl 6992 `"Traverse City, MI"', add
label define city_lbl 7000 `"Torrance, CA"', add
label define city_lbl 7010 `"Trenton, NJ"', add
label define city_lbl 7011 `"Trinidad, CO"', add
label define city_lbl 7030 `"Troy, NY"', add
label define city_lbl 7050 `"Tucson, AZ"', add
label define city_lbl 7070 `"Tulsa, OK"', add
label define city_lbl 7071 `"Turtle Creek, PA"', add
label define city_lbl 7072 `"Tuscaloosa, AL"', add
label define city_lbl 7073 `"Two Rivers, WI"', add
label define city_lbl 7074 `"Tyler, TX"', add
label define city_lbl 7079 `"Union, NJ"', add
label define city_lbl 7080 `"Union City, NJ"', add
label define city_lbl 7081 `"Uniontown, PA"', add
label define city_lbl 7082 `"University City, MO"', add
label define city_lbl 7083 `"Urbana, IL"', add
label define city_lbl 7084 `"Upper Darby, PA"', add
label define city_lbl 7090 `"Utica, NY"', add
label define city_lbl 7091 `"Valdosta, GA"', add
label define city_lbl 7092 `"Vallejo, CA"', add
label define city_lbl 7093 `"Valley Stream, NY"', add
label define city_lbl 7100 `"Vancouver, WA"', add
label define city_lbl 7110 `"Vallejo, CA"', add
label define city_lbl 7111 `"Vandergrift, PA"', add
label define city_lbl 7112 `"Venice, CA"', add
label define city_lbl 7120 `"Vicksburg, MS"', add
label define city_lbl 7121 `"Vincennes, IN"', add
label define city_lbl 7122 `"Virginia, MN"', add
label define city_lbl 7123 `"Virginia City, NV"', add
label define city_lbl 7130 `"Virginia Beach, VA"', add
label define city_lbl 7140 `"Visalia, CA"', add
label define city_lbl 7150 `"Waco, TX"', add
label define city_lbl 7151 `"Wakefield, MA"', add
label define city_lbl 7152 `"Walla Walla, WA"', add
label define city_lbl 7153 `"Wallingford, CT"', add
label define city_lbl 7170 `"Waltham, MA"', add
label define city_lbl 7180 `"Warren, MI"', add
label define city_lbl 7190 `"Warren, OH"', add
label define city_lbl 7191 `"Warren, PA"', add
label define city_lbl 7210 `"Warwick Town, RI"', add
label define city_lbl 7230 `"Washington, DC"', add
label define city_lbl 7231 `"Georgetown, DC"', add
label define city_lbl 7241 `"Washington, PA"', add
label define city_lbl 7242 `"Washington, VA"', add
label define city_lbl 7250 `"Waterbury, CT"', add
label define city_lbl 7270 `"Waterloo, IA"', add
label define city_lbl 7290 `"Waterloo, NY"', add
label define city_lbl 7310 `"Watertown, NY"', add
label define city_lbl 7311 `"Watertown, WI"', add
label define city_lbl 7312 `"Watertown, SD"', add
label define city_lbl 7313 `"Watertown, MA"', add
label define city_lbl 7314 `"Waterville, ME"', add
label define city_lbl 7315 `"Watervliet, NY"', add
label define city_lbl 7316 `"Waukegan, IL"', add
label define city_lbl 7317 `"Waukesha, WI"', add
label define city_lbl 7318 `"Wausau, WI"', add
label define city_lbl 7319 `"Wauwatosa, WI"', add
label define city_lbl 7320 `"West Covina, CA"', add
label define city_lbl 7321 `"Waycross, GA"', add
label define city_lbl 7322 `"Waynesboro, PA"', add
label define city_lbl 7323 `"Webb City, MO"', add
label define city_lbl 7324 `"Webster Groves, MO"', add
label define city_lbl 7325 `"Webster, MA"', add
label define city_lbl 7326 `"Wellesley, MA"', add
label define city_lbl 7327 `"Wenatchee, WA"', add
label define city_lbl 7328 `"Weehawken, NJ"', add
label define city_lbl 7329 `"West Bay City, MI"', add
label define city_lbl 7330 `"West Hoboken, NJ"', add
label define city_lbl 7331 `"West Bethlehem, PA"', add
label define city_lbl 7332 `"West Chester, PA"', add
label define city_lbl 7333 `"West Frankfort, IL"', add
label define city_lbl 7334 `"West Hartford, CT"', add
label define city_lbl 7335 `"West Haven, CT"', add
label define city_lbl 7340 `"West Allis, WI"', add
label define city_lbl 7350 `"West New York, NJ"', add
label define city_lbl 7351 `"West Orange, NJ"', add
label define city_lbl 7352 `"West Palm Beach, FL"', add
label define city_lbl 7353 `"West Springfield, MA"', add
label define city_lbl 7370 `"West Troy, NY"', add
label define city_lbl 7371 `"West Warwick, RI"', add
label define city_lbl 7372 `"Westbrook, ME"', add
label define city_lbl 7373 `"Westerly, RI"', add
label define city_lbl 7374 `"Westfield, MA"', add
label define city_lbl 7375 `"Westfield, NJ"', add
label define city_lbl 7376 `"Wewoka, OK"', add
label define city_lbl 7377 `"Weymouth, MA"', add
label define city_lbl 7390 `"Wheeling, WV"', add
label define city_lbl 7400 `"White Plains, NY"', add
label define city_lbl 7401 `"Whiting, IN"', add
label define city_lbl 7402 `"Whittier, CA"', add
label define city_lbl 7410 `"Wichita, KS"', add
label define city_lbl 7430 `"Wichita Falls, TX"', add
label define city_lbl 7450 `"Wilkes-Barre, PA"', add
label define city_lbl 7451 `"Wilkinsburg, PA"', add
label define city_lbl 7460 `"Wilkinsburg, PA"', add
label define city_lbl 7470 `"Williamsport, PA"', add
label define city_lbl 7471 `"Willimantic, CT"', add
label define city_lbl 7472 `"Wilmette, IL"', add
label define city_lbl 7490 `"Wilmington, DE"', add
label define city_lbl 7510 `"Wilmington, NC"', add
label define city_lbl 7511 `"Wilson, NC"', add
label define city_lbl 7512 `"Winchester, VA"', add
label define city_lbl 7513 `"Winchester, MA"', add
label define city_lbl 7514 `"Windham, CT"', add
label define city_lbl 7515 `"Winnetka, IL"', add
label define city_lbl 7516 `"Winona, MN"', add
label define city_lbl 7530 `"Winston-Salem, NC"', add
label define city_lbl 7531 `"Winthrop, MA"', add
label define city_lbl 7532 `"Woburn, MA"', add
label define city_lbl 7533 `"Woodlawn, PA"', add
label define city_lbl 7534 `"Woodmont, CT"', add
label define city_lbl 7535 `"Woodbridge, NJ"', add
label define city_lbl 7550 `"Woonsocket, RI"', add
label define city_lbl 7551 `"Wooster, OH"', add
label define city_lbl 7570 `"Worcester, MA"', add
label define city_lbl 7571 `"Wyandotte, MI"', add
label define city_lbl 7572 `"Xenia, OH"', add
label define city_lbl 7573 `"Yakima, WA"', add
label define city_lbl 7590 `"Yonkers, NY"', add
label define city_lbl 7610 `"York, PA"', add
label define city_lbl 7630 `"Youngstown, OH"', add
label define city_lbl 7631 `"Ypsilanti, MI"', add
label define city_lbl 7650 `"Zanesville, OH"', add
label define city_lbl 9997 `"Illegible or Uninterpretable"', add
label define city_lbl 9998 `"Blank/illegible"', add
label define city_lbl 9999 `"Missing"', add
label values city city_lbl

label define citypop_lbl 0 `"0"'
label values citypop citypop_lbl

label define sizepl_lbl 0  `"Not identifiable"'
label define sizepl_lbl 1  `"Under 1,000 or unincorporated"', add
label define sizepl_lbl 2  `"1,000-2,499"', add
label define sizepl_lbl 3  `"2,500-3,999"', add
label define sizepl_lbl 4  `"4,000-4,999"', add
label define sizepl_lbl 5  `"5,000-9,999"', add
label define sizepl_lbl 6  `"10,000-24,999"', add
label define sizepl_lbl 7  `"25,000-49,999"', add
label define sizepl_lbl 8  `"50,000-74,999"', add
label define sizepl_lbl 9  `"75,000-99,999"', add
label define sizepl_lbl 10 `"100,000-199,999"', add
label define sizepl_lbl 20 `"200,000-299,999"', add
label define sizepl_lbl 30 `"300,000-399,999"', add
label define sizepl_lbl 40 `"400,000-499,999"', add
label define sizepl_lbl 50 `"500,000-599,999"', add
label define sizepl_lbl 60 `"600,000-749,999"', add
label define sizepl_lbl 70 `"750,000-999,999"', add
label define sizepl_lbl 80 `"1,000,000-1,999,999"', add
label define sizepl_lbl 90 `"2,000,000+"', add
label values sizepl sizepl_lbl

label define urban_lbl 0 `"N/A"'
label define urban_lbl 1 `"Rural"', add
label define urban_lbl 2 `"Urban"', add
label define urban_lbl 8 `"Illegible/Unknown"', add
label define urban_lbl 9 `"Missing"', add
label values urban urban_lbl

label define urbarea_lbl 0    `"N/A (household does not reside in an urbanized area)"'
label define urbarea_lbl 80   `"Akron, OH"', add
label define urbarea_lbl 160  `"Albany-Schenectady-Troy, NY"', add
label define urbarea_lbl 180  `"Schenectady, NY"', add
label define urbarea_lbl 240  `"Allentown-Bethlehem-Easton, PA/NJ"', add
label define urbarea_lbl 280  `"Altoona, PA"', add
label define urbarea_lbl 380  `"Anchorage, AK"', add
label define urbarea_lbl 440  `"Ann Arbor, MI"', add
label define urbarea_lbl 480  `"Asheville, NC"', add
label define urbarea_lbl 520  `"Atlanta, GA"', add
label define urbarea_lbl 560  `"Atlantic City, NJ"', add
label define urbarea_lbl 600  `"Augusta-Aiken, GA/SC"', add
label define urbarea_lbl 640  `"Austin, TX"', add
label define urbarea_lbl 680  `"Bakersfield, CA"', add
label define urbarea_lbl 720  `"Baltimore, MD"', add
label define urbarea_lbl 760  `"Baton Rouge, LA"', add
label define urbarea_lbl 840  `"Beaumont-Port Arthur-Orange,TX"', add
label define urbarea_lbl 850  `"Port Arthur, TX"', add
label define urbarea_lbl 960  `"Binghamton, NY"', add
label define urbarea_lbl 1000 `"Birmingham, AL"', add
label define urbarea_lbl 1120 `"Boston, MA"', add
label define urbarea_lbl 1121 `"Lawrence-Haverhill, MA/NH"', add
label define urbarea_lbl 1122 `"Lowell, MA/NH"', add
label define urbarea_lbl 1200 `"Brockton, MA"', add
label define urbarea_lbl 1160 `"Bridgeport, CT"', add
label define urbarea_lbl 1280 `"Buffalo, NY"', add
label define urbarea_lbl 1281 `"Niagara Falls, NY"', add
label define urbarea_lbl 1320 `"Canton, OH"', add
label define urbarea_lbl 1360 `"Cedar Rapids, IA"', add
label define urbarea_lbl 1440 `"Charleston-N.Charleston,SC"', add
label define urbarea_lbl 1480 `"Charleston, WV"', add
label define urbarea_lbl 1520 `"Charlotte-Gastonia-Rock Hill, SC"', add
label define urbarea_lbl 1560 `"Chattanooga, TN/GA"', add
label define urbarea_lbl 1600 `"Chicago-Gary-Lake, IL"', add
label define urbarea_lbl 1640 `"Cincinnati, OH/KY/IN"', add
label define urbarea_lbl 1680 `"Cleveland, OH"', add
label define urbarea_lbl 1760 `"Columbia, SC"', add
label define urbarea_lbl 1800 `"Columbus, GA/AL"', add
label define urbarea_lbl 1840 `"Columbus, OH"', add
label define urbarea_lbl 1920 `"Dallas-Fort Worth, TX"', add
label define urbarea_lbl 1921 `"Fort Worth-Arlington, TX"', add
label define urbarea_lbl 1960 `"Davenport, IA - Rock Island-Moline, IL"', add
label define urbarea_lbl 2000 `"Dayton-Springfield, OH"', add
label define urbarea_lbl 2001 `"Springfield, OH"', add
label define urbarea_lbl 2040 `"Decatur, IL"', add
label define urbarea_lbl 2080 `"Denver-Boulder-Longmont, CO"', add
label define urbarea_lbl 2120 `"Des Moines, IA"', add
label define urbarea_lbl 2160 `"Detroit, MI"', add
label define urbarea_lbl 2161 `"Pontiac, MI"', add
label define urbarea_lbl 2240 `"Duluth-Superior, MN/WI"', add
label define urbarea_lbl 2310 `"El Paso, TX"', add
label define urbarea_lbl 2360 `"Erie, PA"', add
label define urbarea_lbl 2440 `"Evansville, IN/KY"', add
label define urbarea_lbl 2540 `"Montgomery, AL"', add
label define urbarea_lbl 2640 `"Flint, MI"', add
label define urbarea_lbl 2680 `"Fort Lauderdale-Hollywood-Pompano Beach, FL"', add
label define urbarea_lbl 2760 `"Fort Wayne, IN"', add
label define urbarea_lbl 2840 `"Fresno, CA"', add
label define urbarea_lbl 2920 `"Galveston-Texas City, TX"', add
label define urbarea_lbl 3000 `"Grand Rapids, MI"', add
label define urbarea_lbl 3120 `"Greensboro-Winston Salem-High Point, NC"', add
label define urbarea_lbl 3121 `"Winston-Salem, NC"', add
label define urbarea_lbl 3200 `"Hamilton-Middleton, OH"', add
label define urbarea_lbl 3240 `"Harrisburg-Lebanon-Carlisle, PA"', add
label define urbarea_lbl 3280 `"Hartford-Bristol-Middleton, CT"', add
label define urbarea_lbl 3283 `"New Britain, CT"', add
label define urbarea_lbl 3360 `"Houston-Brazoria, TX"', add
label define urbarea_lbl 3400 `"Huntington-Ashland, WV/KY/OH"', add
label define urbarea_lbl 3480 `"Indianapolis, IN"', add
label define urbarea_lbl 3520 `"Jackson, MI"', add
label define urbarea_lbl 3590 `"Jacksonville, FL"', add
label define urbarea_lbl 3680 `"Johnstown, PA"', add
label define urbarea_lbl 3720 `"Kalamazoo-Portage, MI"', add
label define urbarea_lbl 3760 `"Kansas City, MO/KS"', add
label define urbarea_lbl 3800 `"Kenosha, WI"', add
label define urbarea_lbl 3840 `"Knoxville, TN"', add
label define urbarea_lbl 4000 `"Lancaster, PA"', add
label define urbarea_lbl 4040 `"Lansing-E. Lansing, MI"', add
label define urbarea_lbl 4120 `"Las Vegas, NV"', add
label define urbarea_lbl 4280 `"Lexington-Fayette, KY"', add
label define urbarea_lbl 4360 `"Lincoln, NE"', add
label define urbarea_lbl 4400 `"Little Rock-N. Little Rock, AR"', add
label define urbarea_lbl 4480 `"Los Angeles-Long Beach, CA"', add
label define urbarea_lbl 4520 `"Louisville, KY/IN"', add
label define urbarea_lbl 4680 `"Macon-Warner Robins, GA"', add
label define urbarea_lbl 4720 `"Madison, WI"', add
label define urbarea_lbl 4760 `"Manchester, NH"', add
label define urbarea_lbl 4920 `"Memphis, TN/AR/MS"', add
label define urbarea_lbl 5000 `"Miami-Hialeah, FL"', add
label define urbarea_lbl 5080 `"Milwaukee, WI"', add
label define urbarea_lbl 5120 `"Minneapolis-St. Paul, MN"', add
label define urbarea_lbl 5160 `"Mobile, AL"', add
label define urbarea_lbl 5320 `"Muskegon-Norton Shores-Muskegon Heights, MI"', add
label define urbarea_lbl 5360 `"Nashville, TN"', add
label define urbarea_lbl 5400 `"New Bedford, MA"', add
label define urbarea_lbl 5480 `"New Haven-Meriden, CT"', add
label define urbarea_lbl 5560 `"New Orleans, LA"', add
label define urbarea_lbl 5600 `"New York, NY-Northeastern NJ"', add
label define urbarea_lbl 5720 `"Norfolk-VA Beach-Newport News, VA"', add
label define urbarea_lbl 5880 `"Oklahoma City, OK"', add
label define urbarea_lbl 5920 `"Omaha, NE/IA"', add
label define urbarea_lbl 5960 `"Orlando, FL"', add
label define urbarea_lbl 6120 `"Peoria, IL"', add
label define urbarea_lbl 6160 `"Philadelphia, PA/NJ"', add
label define urbarea_lbl 6200 `"Phoenix, AZ"', add
label define urbarea_lbl 6280 `"Pittsburgh-Beaver Valley, PA"', add
label define urbarea_lbl 6400 `"Portland, ME"', add
label define urbarea_lbl 6440 `"Portland-Vancouver, OR"', add
label define urbarea_lbl 6480 `"Providence-Fall River-Pawtucket, MA/RI"', add
label define urbarea_lbl 6481 `"Fall River, MA/RI"', add
label define urbarea_lbl 6560 `"Pueblo, CO"', add
label define urbarea_lbl 6600 `"Racine, WI"', add
label define urbarea_lbl 6641 `"Durham, NC"', add
label define urbarea_lbl 6680 `"Reading, PA"', add
label define urbarea_lbl 6760 `"Richmond-Petersburg, VA"', add
label define urbarea_lbl 6780 `"Riverside-San Bernadino, CA"', add
label define urbarea_lbl 6800 `"Roanoke, VA"', add
label define urbarea_lbl 6840 `"Rochester, NY"', add
label define urbarea_lbl 6880 `"Rockford, IL"', add
label define urbarea_lbl 6920 `"Sacramento, CA"', add
label define urbarea_lbl 6960 `"Saginaw-Bay City-Midland, MI"', add
label define urbarea_lbl 7000 `"St. Joseph, MO"', add
label define urbarea_lbl 7040 `"St. Louis, MO/IL"', add
label define urbarea_lbl 7160 `"Salt Lake City-Ogden, UT"', add
label define urbarea_lbl 7240 `"San Antonio, TX"', add
label define urbarea_lbl 7320 `"San Diego, CA"', add
label define urbarea_lbl 7360 `"San Francisco-Oakland-Vallejo, CA"', add
label define urbarea_lbl 7400 `"San Jose, CA"', add
label define urbarea_lbl 7520 `"Savannah, GA"', add
label define urbarea_lbl 7560 `"Scranton-Wilkes-Barre, PA"', add
label define urbarea_lbl 7561 `"Wilkes-Barre-Hazelton, PA"', add
label define urbarea_lbl 7600 `"Seattle-Everett, WA"', add
label define urbarea_lbl 7680 `"Shreveport, LA"', add
label define urbarea_lbl 7720 `"Sioux City, IA/NE"', add
label define urbarea_lbl 7800 `"South Bend-Mishawaka, IN"', add
label define urbarea_lbl 7840 `"Spokane, WA"', add
label define urbarea_lbl 7880 `"Springfield, IL"', add
label define urbarea_lbl 7920 `"Springfield, MO"', add
label define urbarea_lbl 8000 `"Springfield-Holyoke-Chicopee, MA"', add
label define urbarea_lbl 8160 `"Syracuse, NY"', add
label define urbarea_lbl 8200 `"Tacoma, WA"', add
label define urbarea_lbl 8280 `"Tampa-St. Petersburg-Clearwater, FL"', add
label define urbarea_lbl 8281 `"Tampa, FL"', add
label define urbarea_lbl 8282 `"St. Petersberg, FL"', add
label define urbarea_lbl 8320 `"Terre Haute, IN"', add
label define urbarea_lbl 8400 `"Toledo, OH/MI"', add
label define urbarea_lbl 8440 `"Topeka, KS"', add
label define urbarea_lbl 8480 `"Trenton, NJ"', add
label define urbarea_lbl 8520 `"Tucson, AZ"', add
label define urbarea_lbl 8560 `"Tulsa, OK"', add
label define urbarea_lbl 8680 `"Utica-Rome, NY"', add
label define urbarea_lbl 8730 `"Ventura-Oxnard-Simi Valley, CA"', add
label define urbarea_lbl 8800 `"Waco, TX"', add
label define urbarea_lbl 8840 `"Washington, DC/MD/VA"', add
label define urbarea_lbl 8880 `"Waterbury, CT"', add
label define urbarea_lbl 9000 `"Wheeling, WV/OH"', add
label define urbarea_lbl 9040 `"Wichita, KS"', add
label define urbarea_lbl 9160 `"Wilmington, DE/NJ/MD"', add
label define urbarea_lbl 9240 `"Worcester, MA"', add
label define urbarea_lbl 9280 `"York, PA"', add
label define urbarea_lbl 9320 `"Youngstown-Warren, OH/PA"', add
label values urbarea urbarea_lbl

label define gq_lbl 0 `"Vacant unit"'
label define gq_lbl 1 `"Households under 1970 definition"', add
label define gq_lbl 2 `"Additional households under 1990 definition"', add
label define gq_lbl 3 `"Institutions"', add
label define gq_lbl 4 `"Other group quarters"', add
label define gq_lbl 5 `"Additional households under 2000 definition"', add
label define gq_lbl 6 `"Fragment"', add
label define gq_lbl 8 `"1960s missing cases to be allocated"', add
label values gq gq_lbl

label define gqtype_lbl 0   `"NA (non-group quarters households)"'
label define gqtype_lbl 10  `"Family group, someone related to head"', add
label define gqtype_lbl 20  `"Unrelated individuals, no one related to head"', add
label define gqtype_lbl 100 `"Institution"', add
label define gqtype_lbl 200 `"Correctional institution"', add
label define gqtype_lbl 210 `"Federal/state correctional"', add
label define gqtype_lbl 211 `"Prison"', add
label define gqtype_lbl 212 `"Penitentiary"', add
label define gqtype_lbl 213 `"Military prison"', add
label define gqtype_lbl 220 `"Local correctional"', add
label define gqtype_lbl 221 `"Jail"', add
label define gqtype_lbl 222 `"Police Lockup (1990 internal census)"', add
label define gqtype_lbl 223 `"Halfway House (1990 internal census)"', add
label define gqtype_lbl 230 `"School juvenile delinquents--public"', add
label define gqtype_lbl 240 `"Reformatory"', add
label define gqtype_lbl 250 `"Camp or chain gang"', add
label define gqtype_lbl 260 `"House of correction"', add
label define gqtype_lbl 300 `"Mental institutions"', add
label define gqtype_lbl 400 `"Institutions for the elderly, handicapped, and poor"', add
label define gqtype_lbl 410 `"Homes for elderly"', add
label define gqtype_lbl 411 `"Aged, dependent home"', add
label define gqtype_lbl 412 `"Nursing and convalescent home"', add
label define gqtype_lbl 413 `"Old soldiers' home"', add
label define gqtype_lbl 420 `"Other Institutions (not aged)"', add
label define gqtype_lbl 421 `"Other Institution nec"', add
label define gqtype_lbl 430 `"Homes neglected/depend children"', add
label define gqtype_lbl 431 `"Orphan school"', add
label define gqtype_lbl 432 `"Orphans' home, asylum"', add
label define gqtype_lbl 440 `"Other institutions for children"', add
label define gqtype_lbl 441 `"Children's home, asylum"', add
label define gqtype_lbl 450 `"Physically handicapped homes, schools and hospitals"', add
label define gqtype_lbl 451 `"Deaf, blind school"', add
label define gqtype_lbl 452 `"Deaf, blind, epilepsy"', add
label define gqtype_lbl 460 `"Mentally handicapped homes and schools"', add
label define gqtype_lbl 461 `"School for feeblemind"', add
label define gqtype_lbl 470 `"TB and other chronic disease hospital"', add
label define gqtype_lbl 471 `"Chronic hospitals"', add
label define gqtype_lbl 472 `"Sanatoria"', add
label define gqtype_lbl 480 `"Poor houses and farms"', add
label define gqtype_lbl 481 `"Poor house, almshouse"', add
label define gqtype_lbl 482 `"Poor farm, workhouse"', add
label define gqtype_lbl 491 `"Maternity homes for unmarried mothers"', add
label define gqtype_lbl 492 `"Homes for widows, single, fallen women"', add
label define gqtype_lbl 493 `"Detention homes"', add
label define gqtype_lbl 494 `"Misc asylums"', add
label define gqtype_lbl 495 `"Home, other dependent"', add
label define gqtype_lbl 496 `"Institution combination or unknown"', add
label define gqtype_lbl 500 `"Non-institutional group quarters"', add
label define gqtype_lbl 501 `"Household (including co-resident unrelated individuals) formerly in institutional group quarters"', add
label define gqtype_lbl 502 `"Employees (and their co-resident relatives) formerly in institutional group quarters"', add
label define gqtype_lbl 600 `"Military"', add
label define gqtype_lbl 601 `"U.S. army installation"', add
label define gqtype_lbl 602 `"Navy, marine intallation"', add
label define gqtype_lbl 603 `"Navy ships"', add
label define gqtype_lbl 604 `"Air service"', add
label define gqtype_lbl 605 `"Military hospital (1990 internal census)"', add
label define gqtype_lbl 700 `"College dormitory"', add
label define gqtype_lbl 701 `"Military service academies"', add
label define gqtype_lbl 800 `"Rooming house"', add
label define gqtype_lbl 801 `"Hotel"', add
label define gqtype_lbl 802 `"House, lodging apartments"', add
label define gqtype_lbl 803 `"YMCA, YWCA"', add
label define gqtype_lbl 804 `"Club"', add
label define gqtype_lbl 805 `"Emergency Shelter for the Homeless"', add
label define gqtype_lbl 806 `"Natural Disaster (1990 internal census)"', add
label define gqtype_lbl 900 `"Other Non-Instit GQ and unknown"', add
label define gqtype_lbl 901 `"Other Non-Instit GQ"', add
label define gqtype_lbl 910 `"Schools"', add
label define gqtype_lbl 911 `"Boarding schools"', add
label define gqtype_lbl 912 `"Academy, institute"', add
label define gqtype_lbl 913 `"Industrial training"', add
label define gqtype_lbl 914 `"Indian school"', add
label define gqtype_lbl 920 `"Hospitals"', add
label define gqtype_lbl 921 `"Hospital, charity"', add
label define gqtype_lbl 922 `"Infirmary"', add
label define gqtype_lbl 923 `"Maternity hospital"', add
label define gqtype_lbl 924 `"Children's hospital"', add
label define gqtype_lbl 930 `"Religious Group Quarters (1990 internal census)"', add
label define gqtype_lbl 931 `"Church, Abbey"', add
label define gqtype_lbl 932 `"Convent"', add
label define gqtype_lbl 933 `"Monastery"', add
label define gqtype_lbl 934 `"Mission"', add
label define gqtype_lbl 935 `"Seminary"', add
label define gqtype_lbl 936 `"Religious commune"', add
label define gqtype_lbl 937 `"Other religious"', add
label define gqtype_lbl 940 `"Work sites"', add
label define gqtype_lbl 941 `"Construction, except railroad"', add
label define gqtype_lbl 942 `"Lumber"', add
label define gqtype_lbl 943 `"Mining"', add
label define gqtype_lbl 944 `"Railroad"', add
label define gqtype_lbl 945 `"Farms, ranches"', add
label define gqtype_lbl 946 `"Ships, boats"', add
label define gqtype_lbl 947 `"Other industrial"', add
label define gqtype_lbl 948 `"Other worksites"', add
label define gqtype_lbl 950 `"Nurses home, dorm"', add
label define gqtype_lbl 955 `"Passenger ships"', add
label define gqtype_lbl 960 `"Other group quarters"', add
label define gqtype_lbl 961 `"Hospital or School for the Handicapped, Drug/Alcohol Abuse (1990 internal census)"', add
label define gqtype_lbl 962 `"Shelter for Abused Women (1990 internal census)"', add
label define gqtype_lbl 963 `"Group Home for Drug/Alchol Abuse (1990 internal census)"', add
label define gqtype_lbl 997 `"Unknown"', add
label define gqtype_lbl 998 `"Illegible"', add
label define gqtype_lbl 999 `"Fragment"', add
label values gqtype gqtype_lbl

label define gqfunds_lbl 0  `"N/A"'
label define gqfunds_lbl 11 `"Federal support"', add
label define gqfunds_lbl 12 `"Federal and state"', add
label define gqfunds_lbl 13 `"State support"', add
label define gqfunds_lbl 14 `"Local support"', add
label define gqfunds_lbl 15 `"State and local"', add
label define gqfunds_lbl 16 `"Government, not specified"', add
label define gqfunds_lbl 21 `"Private, nonprofit"', add
label define gqfunds_lbl 22 `"Private, commercial"', add
label define gqfunds_lbl 23 `"Religious"', add
label define gqfunds_lbl 24 `"Ethnic, fraternal"', add
label define gqfunds_lbl 25 `"Private, unknown"', add
label define gqfunds_lbl 99 `"Fragment or Unknown"', add
label values gqfunds gqfunds_lbl

label define farm_lbl 0 `"N/A"'
label define farm_lbl 1 `"Non-Farm"', add
label define farm_lbl 2 `"Farm"', add
label define farm_lbl 8 `"Illegible"', add
label define farm_lbl 9 `"Blank/missing"', add
label values farm farm_lbl

label define pageno_lbl 0 `"Missing or Illegible"'
label values pageno pageno_lbl

label define nfams_lbl 0  `"0 families (vacant unit)"'
label define nfams_lbl 1  `"1 family or N/A"', add
label define nfams_lbl 2  `"2 families"', add
label define nfams_lbl 3  `"3"', add
label define nfams_lbl 4  `"4"', add
label define nfams_lbl 5  `"5"', add
label define nfams_lbl 6  `"6"', add
label define nfams_lbl 7  `"7"', add
label define nfams_lbl 8  `"8"', add
label define nfams_lbl 9  `"9"', add
label define nfams_lbl 10 `"10"', add
label define nfams_lbl 11 `"11"', add
label define nfams_lbl 12 `"12"', add
label define nfams_lbl 13 `"13"', add
label define nfams_lbl 14 `"14"', add
label define nfams_lbl 15 `"15"', add
label define nfams_lbl 16 `"16"', add
label define nfams_lbl 17 `"17"', add
label define nfams_lbl 18 `"18"', add
label define nfams_lbl 19 `"19"', add
label define nfams_lbl 20 `"20"', add
label define nfams_lbl 21 `"21"', add
label define nfams_lbl 22 `"22"', add
label define nfams_lbl 23 `"23"', add
label define nfams_lbl 24 `"24"', add
label define nfams_lbl 25 `"25"', add
label define nfams_lbl 26 `"26"', add
label define nfams_lbl 27 `"27"', add
label define nfams_lbl 28 `"28"', add
label define nfams_lbl 29 `"29"', add
label define nfams_lbl 30 `"30"', add
label values nfams nfams_lbl

label define ncouples_lbl 0 `"0 couples or N/A"'
label define ncouples_lbl 1 `"1"', add
label define ncouples_lbl 2 `"2"', add
label define ncouples_lbl 3 `"3"', add
label define ncouples_lbl 4 `"4"', add
label define ncouples_lbl 5 `"5"', add
label define ncouples_lbl 6 `"6"', add
label define ncouples_lbl 7 `"7"', add
label define ncouples_lbl 8 `"8"', add
label define ncouples_lbl 9 `"9"', add
label values ncouples ncouples_lbl

label define nmothers_lbl 0 `"0 mothers or N/A"'
label define nmothers_lbl 1 `"1"', add
label define nmothers_lbl 2 `"2"', add
label define nmothers_lbl 3 `"3"', add
label define nmothers_lbl 4 `"4"', add
label define nmothers_lbl 5 `"5"', add
label define nmothers_lbl 6 `"6"', add
label define nmothers_lbl 7 `"7"', add
label define nmothers_lbl 8 `"8"', add
label values nmothers nmothers_lbl

label define nfathers_lbl 0 `"0 fathers or N/A"'
label define nfathers_lbl 1 `"1"', add
label define nfathers_lbl 2 `"2"', add
label define nfathers_lbl 3 `"3"', add
label define nfathers_lbl 4 `"4"', add
label define nfathers_lbl 5 `"5"', add
label define nfathers_lbl 6 `"6"', add
label values nfathers nfathers_lbl

label define hhtype_lbl 0 `"N/A"'
label define hhtype_lbl 1 `"Married-couple family household"', add
label define hhtype_lbl 2 `"Male householder, no wife present"', add
label define hhtype_lbl 3 `"Female householder, no husband present"', add
label define hhtype_lbl 4 `"Male householder, living alone"', add
label define hhtype_lbl 5 `"Male householder, not living alone"', add
label define hhtype_lbl 6 `"Female householder, living alone"', add
label define hhtype_lbl 7 `"Female householder, not living alone"', add
label define hhtype_lbl 9 `"HHTYPE could not be determined"', add
label values hhtype hhtype_lbl

label define cntry_lbl 630 `"Puerto Rico"'
label define cntry_lbl 840 `"United States"', add
label values cntry cntry_lbl

label define appal_lbl 0  `"Not in Appalachia"'
label define appal_lbl 10 `"Northern Appalachia"', add
label define appal_lbl 11 `"Northern Appalachia"', add
label define appal_lbl 12 `"North Central Appalachia"', add
label define appal_lbl 20 `"Central Appalachia"', add
label define appal_lbl 30 `"Southern Appalachia"', add
label define appal_lbl 31 `"South Central Appalachia"', add
label define appal_lbl 32 `"Southern Appalachia"', add
label values appal appal_lbl

label define mdstatus_lbl 1 `"Not Metropolitan District"'
label define mdstatus_lbl 2 `"Central City"', add
label define mdstatus_lbl 3 `"Urbanized Fringe"', add
label define mdstatus_lbl 4 `"Metropolitan Fringe"', add
label define mdstatus_lbl 9 `"Not Classified"', add
label values mdstatus mdstatus_lbl

label define numperhh_lbl 9999 `"9999"'
label values numperhh numperhh_lbl

label define line_lbl 100 `"100"'
label values line line_lbl

label define split_lbl 0 `"Person was not in a large group quarters that was split apart"'
label define split_lbl 1 `"Person was in a large group quarters that was split apart"', add
label values split split_lbl

label define yearp_lbl 1850 `"1850"'
label define yearp_lbl 1860 `"1860"', add
label define yearp_lbl 1870 `"1870"', add
label define yearp_lbl 1880 `"1880"', add
label define yearp_lbl 1900 `"1900"', add
label define yearp_lbl 1910 `"1910"', add
label define yearp_lbl 1920 `"1920"', add
label define yearp_lbl 1930 `"1930"', add
label define yearp_lbl 1940 `"1940"', add
label define yearp_lbl 1950 `"1950"', add
label define yearp_lbl 1960 `"1960"', add
label define yearp_lbl 1970 `"1970"', add
label define yearp_lbl 1980 `"1980"', add
label define yearp_lbl 1990 `"1990"', add
label define yearp_lbl 2000 `"2000"', add
label define yearp_lbl 2001 `"2001"', add
label define yearp_lbl 2002 `"2002"', add
label define yearp_lbl 2003 `"2003"', add
label define yearp_lbl 2004 `"2004"', add
label define yearp_lbl 2005 `"2005"', add
label define yearp_lbl 2006 `"2006"', add
label define yearp_lbl 2007 `"2007"', add
label define yearp_lbl 2008 `"2008"', add
label define yearp_lbl 2009 `"2009"', add
label define yearp_lbl 2010 `"2010"', add
label define yearp_lbl 2011 `"2011"', add
label define yearp_lbl 2012 `"2012"', add
label define yearp_lbl 2013 `"2013"', add
label define yearp_lbl 2014 `"2014"', add
label define yearp_lbl 2015 `"2015"', add
label define yearp_lbl 2016 `"2016"', add
label define yearp_lbl 2017 `"2017"', add
label define yearp_lbl 2018 `"2018"', add
label define yearp_lbl 2019 `"2019"', add
label values yearp yearp_lbl

label define samplep_lbl 201902 `"2019 PRCS"'
label define samplep_lbl 201901 `"2019 ACS"', add
label define samplep_lbl 201804 `"2014-2018, PRCS 5-year"', add
label define samplep_lbl 201803 `"2014-2018, ACS 5-year"', add
label define samplep_lbl 201802 `"2018 PRCS"', add
label define samplep_lbl 201801 `"2018 ACS"', add
label define samplep_lbl 201704 `"2013-2017, PRCS 5-year"', add
label define samplep_lbl 201703 `"2013-2017, ACS 5-year"', add
label define samplep_lbl 201702 `"2017 PRCS"', add
label define samplep_lbl 201701 `"2017 ACS"', add
label define samplep_lbl 201604 `"2012-2016, PRCS 5-year"', add
label define samplep_lbl 201603 `"2012-2016, ACS 5-year"', add
label define samplep_lbl 201602 `"2016 PRCS"', add
label define samplep_lbl 201601 `"2016 ACS"', add
label define samplep_lbl 201504 `"2011-2015, PRCS 5-year"', add
label define samplep_lbl 201503 `"2011-2015, ACS 5-year"', add
label define samplep_lbl 201502 `"2015 PRCS"', add
label define samplep_lbl 201501 `"2015 ACS"', add
label define samplep_lbl 201404 `"2010-2014, PRCS 5-year"', add
label define samplep_lbl 201403 `"2010-2014, ACS 5-year"', add
label define samplep_lbl 201402 `"2014 PRCS"', add
label define samplep_lbl 201401 `"2014 ACS"', add
label define samplep_lbl 201306 `"2009-2013, PRCS 5-year"', add
label define samplep_lbl 201305 `"2009-2013, ACS 5-year"', add
label define samplep_lbl 201304 `"2011-2013, PRCS 3-year"', add
label define samplep_lbl 201303 `"2011-2013, ACS 3-year"', add
label define samplep_lbl 201302 `"2013 PRCS"', add
label define samplep_lbl 201301 `"2013 ACS"', add
label define samplep_lbl 201206 `"2008-2012, PRCS 5-year"', add
label define samplep_lbl 201205 `"2008-2012, ACS 5-year"', add
label define samplep_lbl 201204 `"2010-2012, PRCS 3-year"', add
label define samplep_lbl 201203 `"2010-2012, ACS 3-year"', add
label define samplep_lbl 201202 `"2012 PRCS"', add
label define samplep_lbl 201201 `"2012 ACS"', add
label define samplep_lbl 201106 `"2007-2011, PRCS 5-year"', add
label define samplep_lbl 201105 `"2007-2011, ACS 5-year"', add
label define samplep_lbl 201104 `"2009-2011, PRCS 3-year"', add
label define samplep_lbl 201103 `"2009-2011, ACS 3-year"', add
label define samplep_lbl 201102 `"2011 PRCS"', add
label define samplep_lbl 201101 `"2011 ACS"', add
label define samplep_lbl 201008 `"2010 Puerto Rico 10%"', add
label define samplep_lbl 201007 `"2010 10%"', add
label define samplep_lbl 201006 `"2006-2010, PRCS 5-year"', add
label define samplep_lbl 201005 `"2006-2010, ACS 5-year"', add
label define samplep_lbl 201004 `"2008-2010, PRCS 3-year"', add
label define samplep_lbl 201003 `"2008-2010, ACS 3-year"', add
label define samplep_lbl 201002 `"2010 PRCS"', add
label define samplep_lbl 201001 `"2010 ACS"', add
label define samplep_lbl 200906 `"2005-2009, PRCS 5-year"', add
label define samplep_lbl 200905 `"2005-2009, ACS 5-year"', add
label define samplep_lbl 200904 `"2007-2009, PRCS 3-year"', add
label define samplep_lbl 200903 `"2007-2009, ACS 3-year"', add
label define samplep_lbl 200902 `"2009 PRCS"', add
label define samplep_lbl 200901 `"2009 ACS"', add
label define samplep_lbl 200804 `"2006-2008, PRCS 3-year"', add
label define samplep_lbl 200803 `"2006-2008, ACS 3-year"', add
label define samplep_lbl 200802 `"2008 PRCS"', add
label define samplep_lbl 200801 `"2008 ACS"', add
label define samplep_lbl 200704 `"2005-2007, PRCS 3-year"', add
label define samplep_lbl 200703 `"2005-2007, ACS 3-year"', add
label define samplep_lbl 200702 `"2007 PRCS"', add
label define samplep_lbl 200701 `"2007 ACS"', add
label define samplep_lbl 200602 `"2006 PRCS"', add
label define samplep_lbl 200601 `"2006 ACS"', add
label define samplep_lbl 200502 `"2005 PRCS"', add
label define samplep_lbl 200501 `"2005 ACS"', add
label define samplep_lbl 200401 `"2004 ACS"', add
label define samplep_lbl 200301 `"2003 ACS"', add
label define samplep_lbl 200201 `"2002 ACS"', add
label define samplep_lbl 200101 `"2001 ACS"', add
label define samplep_lbl 200008 `"2000 Puerto Rico 1%"', add
label define samplep_lbl 200007 `"2000 1%"', add
label define samplep_lbl 200006 `"2000 Puerto Rico 1% sample (old version)"', add
label define samplep_lbl 200005 `"2000 Puerto Rico 5%"', add
label define samplep_lbl 200004 `"2000 ACS"', add
label define samplep_lbl 200003 `"2000 Unweighted 1%"', add
label define samplep_lbl 200002 `"2000 1% sample (old version)"', add
label define samplep_lbl 200001 `"2000 5%"', add
label define samplep_lbl 199007 `"1990 Puerto Rico 1%"', add
label define samplep_lbl 199006 `"1990 Puerto Rico 5%"', add
label define samplep_lbl 199005 `"1990 Labor Market Area"', add
label define samplep_lbl 199004 `"1990 Elderly"', add
label define samplep_lbl 199003 `"1990 Unweighted 1%"', add
label define samplep_lbl 199002 `"1990 1%"', add
label define samplep_lbl 199001 `"1990 5%"', add
label define samplep_lbl 198007 `"1980 Puerto Rico 1%"', add
label define samplep_lbl 198006 `"1980 Puerto Rico 5%"', add
label define samplep_lbl 198005 `"1980 Detailed metro/non-metro"', add
label define samplep_lbl 198004 `"1980 Labor Market Area"', add
label define samplep_lbl 198003 `"1980 Urban/Rural"', add
label define samplep_lbl 198002 `"1980 1%"', add
label define samplep_lbl 198001 `"1980 5%"', add
label define samplep_lbl 197009 `"1970 Puerto Rico Neighborhood"', add
label define samplep_lbl 197008 `"1970 Puerto Rico Municipio"', add
label define samplep_lbl 197007 `"1970 Puerto Rico State"', add
label define samplep_lbl 197006 `"1970 Form 2 Neighborhood"', add
label define samplep_lbl 197005 `"1970 Form 1 Neighborhood"', add
label define samplep_lbl 197004 `"1970 Form 2 Metro"', add
label define samplep_lbl 197003 `"1970 Form 1 Metro"', add
label define samplep_lbl 197002 `"1970 Form 2 State"', add
label define samplep_lbl 197001 `"1970 Form 1 State"', add
label define samplep_lbl 196002 `"1960 5%"', add
label define samplep_lbl 196001 `"1960 1%"', add
label define samplep_lbl 195001 `"1950 1%"', add
label define samplep_lbl 194002 `"1940 100% database"', add
label define samplep_lbl 194001 `"1940 1%"', add
label define samplep_lbl 193004 `"1930 100% database"', add
label define samplep_lbl 193003 `"1930 Puerto Rico"', add
label define samplep_lbl 193002 `"1930 5%"', add
label define samplep_lbl 193001 `"1930 1%"', add
label define samplep_lbl 192003 `"1920 100% database"', add
label define samplep_lbl 192002 `"1920 Puerto Rico sample"', add
label define samplep_lbl 192001 `"1920 1%"', add
label define samplep_lbl 191004 `"1910 100% database"', add
label define samplep_lbl 191003 `"1910 1.4% sample with oversamples"', add
label define samplep_lbl 191002 `"1910 1%"', add
label define samplep_lbl 191001 `"1910 Puerto Rico"', add
label define samplep_lbl 190004 `"1900 100% database"', add
label define samplep_lbl 190003 `"1900 1% sample with oversamples"', add
label define samplep_lbl 190002 `"1900 1%"', add
label define samplep_lbl 190001 `"1900 5%"', add
label define samplep_lbl 188003 `"1880 100% database"', add
label define samplep_lbl 188002 `"1880 10%"', add
label define samplep_lbl 188001 `"1880 1%"', add
label define samplep_lbl 187003 `"1870 100% database"', add
label define samplep_lbl 187002 `"1870 1% sample with black oversample"', add
label define samplep_lbl 187001 `"1870 1%"', add
label define samplep_lbl 186003 `"1860 100% database"', add
label define samplep_lbl 186002 `"1860 1% sample with black oversample"', add
label define samplep_lbl 186001 `"1860 1%"', add
label define samplep_lbl 185002 `"1850 100% database"', add
label define samplep_lbl 185001 `"1850 1%"', add
label values samplep samplep_lbl

label define momloc_lbl 0  `"0"'
label define momloc_lbl 1  `"1"', add
label define momloc_lbl 2  `"2"', add
label define momloc_lbl 3  `"3"', add
label define momloc_lbl 4  `"4"', add
label define momloc_lbl 5  `"5"', add
label define momloc_lbl 6  `"6"', add
label define momloc_lbl 7  `"7"', add
label define momloc_lbl 8  `"8"', add
label define momloc_lbl 9  `"9"', add
label define momloc_lbl 10 `"10"', add
label define momloc_lbl 11 `"11"', add
label define momloc_lbl 12 `"12"', add
label define momloc_lbl 13 `"13"', add
label define momloc_lbl 14 `"14"', add
label define momloc_lbl 15 `"15"', add
label define momloc_lbl 16 `"16"', add
label define momloc_lbl 17 `"17"', add
label define momloc_lbl 18 `"18"', add
label define momloc_lbl 19 `"19"', add
label define momloc_lbl 20 `"20"', add
label define momloc_lbl 21 `"21"', add
label define momloc_lbl 22 `"22"', add
label define momloc_lbl 23 `"23"', add
label define momloc_lbl 24 `"24"', add
label define momloc_lbl 25 `"25"', add
label define momloc_lbl 26 `"26"', add
label define momloc_lbl 27 `"27"', add
label define momloc_lbl 28 `"28"', add
label define momloc_lbl 29 `"29"', add
label values momloc momloc_lbl

label define stepmom_lbl 0 `"No stepmother present"'
label define stepmom_lbl 1 `"Improbable age difference"', add
label define stepmom_lbl 2 `"Spouse of father"', add
label define stepmom_lbl 3 `"Identified stepmother"', add
label define stepmom_lbl 4 `"No surviving children"', add
label define stepmom_lbl 5 `"Identified as adopted"', add
label define stepmom_lbl 6 `"Birthplace/marriage duration mismatch"', add
label define stepmom_lbl 7 `"Number of children born/children surviving check"', add
label values stepmom stepmom_lbl

label define momrule_hist_lbl 0 `"No mother link"'
label define momrule_hist_lbl 1 `"Unambiguous mother link"', add
label define momrule_hist_lbl 2 `"Daughter/grandchild link"', add
label define momrule_hist_lbl 3 `"Preceding female (no intervening person)"', add
label define momrule_hist_lbl 4 `"Preceding female (surname similarity)"', add
label define momrule_hist_lbl 5 `"Daughter/grandchild (child surviving status)"', add
label define momrule_hist_lbl 6 `"Preceding female (child surviving status)"', add
label define momrule_hist_lbl 7 `"Spouse of father becomes stepmother"', add
label values momrule_hist momrule_hist_lbl

label define poploc_lbl 0  `"0"'
label define poploc_lbl 1  `"1"', add
label define poploc_lbl 2  `"2"', add
label define poploc_lbl 3  `"3"', add
label define poploc_lbl 4  `"4"', add
label define poploc_lbl 5  `"5"', add
label define poploc_lbl 6  `"6"', add
label define poploc_lbl 7  `"7"', add
label define poploc_lbl 8  `"8"', add
label define poploc_lbl 9  `"9"', add
label define poploc_lbl 10 `"10"', add
label define poploc_lbl 11 `"11"', add
label define poploc_lbl 12 `"12"', add
label define poploc_lbl 13 `"13"', add
label define poploc_lbl 14 `"14"', add
label define poploc_lbl 15 `"15"', add
label define poploc_lbl 16 `"16"', add
label define poploc_lbl 17 `"17"', add
label define poploc_lbl 18 `"18"', add
label define poploc_lbl 19 `"19"', add
label define poploc_lbl 20 `"20"', add
label define poploc_lbl 21 `"21"', add
label define poploc_lbl 22 `"22"', add
label define poploc_lbl 23 `"23"', add
label define poploc_lbl 24 `"24"', add
label define poploc_lbl 25 `"25"', add
label define poploc_lbl 26 `"26"', add
label define poploc_lbl 27 `"27"', add
label define poploc_lbl 28 `"28"', add
label define poploc_lbl 29 `"29"', add
label values poploc poploc_lbl

label define steppop_lbl 0 `"No stepfather present"'
label define steppop_lbl 1 `"Improbable age difference"', add
label define steppop_lbl 2 `"Spouse of mother"', add
label define steppop_lbl 3 `"Identified stepfather"', add
label define steppop_lbl 5 `"Identified as adopted"', add
label define steppop_lbl 6 `"Birthplace/marriage duration mismatch"', add
label define steppop_lbl 7 `"Surname difference -- male child or never-married female"', add
label values steppop steppop_lbl

label define poprule_hist_lbl 0 `"No father link"'
label define poprule_hist_lbl 1 `"Unambiguous father link"', add
label define poprule_hist_lbl 2 `"Son/granchild link"', add
label define poprule_hist_lbl 3 `"Preceding male (no intervening person)"', add
label define poprule_hist_lbl 4 `"Preceding male (surname similarity)"', add
label define poprule_hist_lbl 7 `"Husband of mother becomes stepfather"', add
label values poprule_hist poprule_hist_lbl

label define sploc_lbl 0  `"0"'
label define sploc_lbl 1  `"1"', add
label define sploc_lbl 2  `"2"', add
label define sploc_lbl 3  `"3"', add
label define sploc_lbl 4  `"4"', add
label define sploc_lbl 5  `"5"', add
label define sploc_lbl 6  `"6"', add
label define sploc_lbl 7  `"7"', add
label define sploc_lbl 8  `"8"', add
label define sploc_lbl 9  `"9"', add
label define sploc_lbl 10 `"10"', add
label define sploc_lbl 11 `"11"', add
label define sploc_lbl 12 `"12"', add
label define sploc_lbl 13 `"13"', add
label define sploc_lbl 14 `"14"', add
label define sploc_lbl 15 `"15"', add
label define sploc_lbl 16 `"16"', add
label define sploc_lbl 17 `"17"', add
label define sploc_lbl 18 `"18"', add
label define sploc_lbl 19 `"19"', add
label define sploc_lbl 20 `"20"', add
label define sploc_lbl 21 `"21"', add
label define sploc_lbl 22 `"22"', add
label define sploc_lbl 23 `"23"', add
label define sploc_lbl 24 `"24"', add
label define sploc_lbl 25 `"25"', add
label define sploc_lbl 26 `"26"', add
label define sploc_lbl 27 `"27"', add
label define sploc_lbl 28 `"28"', add
label define sploc_lbl 29 `"29"', add
label define sploc_lbl 30 `"30"', add
label values sploc sploc_lbl

label define sprule_hist_lbl 0 `"No spouse link"'
label define sprule_hist_lbl 1 `"Wife follows husband"', add
label define sprule_hist_lbl 2 `"Wife precedes husband"', add
label define sprule_hist_lbl 3 `"Non-adjacent links -- consistent relationship to head/age differences"', add
label define sprule_hist_lbl 4 `"Adjacent links (wife follows husband -- no age, other relative conflicts)"', add
label define sprule_hist_lbl 5 `"Adjacent links (wife precedes husband -- no age, other relative conflicts)"', add
label define sprule_hist_lbl 6 `"Non-adjacent links -- no age, other relative conflicts"', add
label define sprule_hist_lbl 7 `"Previously allocated marital status -- no age, other relative conflicts"', add
label values sprule_hist sprule_hist_lbl

label define famsize_lbl 1  `"1 family member present"'
label define famsize_lbl 2  `"2 family members present"', add
label define famsize_lbl 3  `"3 family members present"', add
label define famsize_lbl 4  `"4 family members present"', add
label define famsize_lbl 5  `"5 family members present"', add
label define famsize_lbl 6  `"6 family members present"', add
label define famsize_lbl 7  `"7 family members present"', add
label define famsize_lbl 8  `"8 family members present"', add
label define famsize_lbl 9  `"9 family members present"', add
label define famsize_lbl 10 `"10 family members present"', add
label define famsize_lbl 11 `"11 family members present"', add
label define famsize_lbl 12 `"12 family members present"', add
label define famsize_lbl 13 `"13 family members present"', add
label define famsize_lbl 14 `"14 family members present"', add
label define famsize_lbl 15 `"15 family members present"', add
label define famsize_lbl 16 `"16 family members present"', add
label define famsize_lbl 17 `"17 family members present"', add
label define famsize_lbl 18 `"18 family members present"', add
label define famsize_lbl 19 `"19 family members present"', add
label define famsize_lbl 20 `"20 family members present"', add
label define famsize_lbl 21 `"21 family members present"', add
label define famsize_lbl 22 `"22 family members present"', add
label define famsize_lbl 23 `"23 family members present"', add
label define famsize_lbl 24 `"24 family members present"', add
label define famsize_lbl 25 `"25 family members present"', add
label define famsize_lbl 26 `"26 family members present"', add
label define famsize_lbl 27 `"27 family members present"', add
label define famsize_lbl 28 `"28 family members present"', add
label define famsize_lbl 29 `"29 family members present"', add
label values famsize famsize_lbl

label define nchild_lbl 0 `"0 children present"'
label define nchild_lbl 1 `"1 child present"', add
label define nchild_lbl 2 `"2"', add
label define nchild_lbl 3 `"3"', add
label define nchild_lbl 4 `"4"', add
label define nchild_lbl 5 `"5"', add
label define nchild_lbl 6 `"6"', add
label define nchild_lbl 7 `"7"', add
label define nchild_lbl 8 `"8"', add
label define nchild_lbl 9 `"9+"', add
label values nchild nchild_lbl

label define nchlt5_lbl 0 `"No children under age 5"'
label define nchlt5_lbl 1 `"1 child under age 5"', add
label define nchlt5_lbl 2 `"2"', add
label define nchlt5_lbl 3 `"3"', add
label define nchlt5_lbl 4 `"4"', add
label define nchlt5_lbl 5 `"5"', add
label define nchlt5_lbl 6 `"6"', add
label define nchlt5_lbl 7 `"7"', add
label define nchlt5_lbl 8 `"8"', add
label define nchlt5_lbl 9 `"9+"', add
label values nchlt5 nchlt5_lbl

label define famunit_lbl 1  `"1st family in household or group quarters"'
label define famunit_lbl 2  `"2nd family in household or group quarters"', add
label define famunit_lbl 3  `"3rd"', add
label define famunit_lbl 4  `"4th"', add
label define famunit_lbl 5  `"5th"', add
label define famunit_lbl 6  `"6th"', add
label define famunit_lbl 7  `"7th"', add
label define famunit_lbl 8  `"8th"', add
label define famunit_lbl 9  `"9th"', add
label define famunit_lbl 10 `"10th"', add
label define famunit_lbl 11 `"11th"', add
label define famunit_lbl 12 `"12th"', add
label define famunit_lbl 13 `"13th"', add
label define famunit_lbl 14 `"14th"', add
label define famunit_lbl 15 `"15th"', add
label define famunit_lbl 16 `"16th"', add
label define famunit_lbl 17 `"17th"', add
label define famunit_lbl 18 `"18th"', add
label define famunit_lbl 19 `"19th"', add
label define famunit_lbl 20 `"20th"', add
label define famunit_lbl 21 `"21th"', add
label define famunit_lbl 22 `"22th"', add
label define famunit_lbl 23 `"23th"', add
label define famunit_lbl 24 `"24th"', add
label define famunit_lbl 25 `"25th"', add
label define famunit_lbl 26 `"26th"', add
label define famunit_lbl 27 `"27th"', add
label define famunit_lbl 28 `"28th"', add
label define famunit_lbl 29 `"29th"', add
label define famunit_lbl 30 `"30th"', add
label values famunit famunit_lbl

label define eldch_lbl 0  `"Less than 1 year old"'
label define eldch_lbl 1  `"1"', add
label define eldch_lbl 2  `"2"', add
label define eldch_lbl 3  `"3"', add
label define eldch_lbl 4  `"4"', add
label define eldch_lbl 5  `"5"', add
label define eldch_lbl 6  `"6"', add
label define eldch_lbl 7  `"7"', add
label define eldch_lbl 8  `"8"', add
label define eldch_lbl 9  `"9"', add
label define eldch_lbl 10 `"10"', add
label define eldch_lbl 11 `"11"', add
label define eldch_lbl 12 `"12"', add
label define eldch_lbl 13 `"13"', add
label define eldch_lbl 14 `"14"', add
label define eldch_lbl 15 `"15"', add
label define eldch_lbl 16 `"16"', add
label define eldch_lbl 17 `"17"', add
label define eldch_lbl 18 `"18"', add
label define eldch_lbl 19 `"19"', add
label define eldch_lbl 20 `"20"', add
label define eldch_lbl 21 `"21"', add
label define eldch_lbl 22 `"22"', add
label define eldch_lbl 23 `"23"', add
label define eldch_lbl 24 `"24"', add
label define eldch_lbl 25 `"25"', add
label define eldch_lbl 26 `"26"', add
label define eldch_lbl 27 `"27"', add
label define eldch_lbl 28 `"28"', add
label define eldch_lbl 29 `"29"', add
label define eldch_lbl 30 `"30"', add
label define eldch_lbl 31 `"31"', add
label define eldch_lbl 32 `"32"', add
label define eldch_lbl 33 `"33"', add
label define eldch_lbl 34 `"34"', add
label define eldch_lbl 35 `"35"', add
label define eldch_lbl 36 `"36"', add
label define eldch_lbl 37 `"37"', add
label define eldch_lbl 38 `"38"', add
label define eldch_lbl 39 `"39"', add
label define eldch_lbl 40 `"40"', add
label define eldch_lbl 41 `"41"', add
label define eldch_lbl 42 `"42"', add
label define eldch_lbl 43 `"43"', add
label define eldch_lbl 44 `"44"', add
label define eldch_lbl 45 `"45"', add
label define eldch_lbl 46 `"46"', add
label define eldch_lbl 47 `"47"', add
label define eldch_lbl 48 `"48"', add
label define eldch_lbl 49 `"49"', add
label define eldch_lbl 50 `"50"', add
label define eldch_lbl 51 `"51"', add
label define eldch_lbl 52 `"52"', add
label define eldch_lbl 53 `"53"', add
label define eldch_lbl 54 `"54"', add
label define eldch_lbl 55 `"55"', add
label define eldch_lbl 56 `"56"', add
label define eldch_lbl 57 `"57"', add
label define eldch_lbl 58 `"58"', add
label define eldch_lbl 59 `"59"', add
label define eldch_lbl 60 `"60"', add
label define eldch_lbl 61 `"61"', add
label define eldch_lbl 62 `"62"', add
label define eldch_lbl 63 `"63"', add
label define eldch_lbl 64 `"64"', add
label define eldch_lbl 65 `"65"', add
label define eldch_lbl 66 `"66"', add
label define eldch_lbl 67 `"67"', add
label define eldch_lbl 68 `"68"', add
label define eldch_lbl 69 `"69"', add
label define eldch_lbl 70 `"70"', add
label define eldch_lbl 71 `"71"', add
label define eldch_lbl 72 `"72"', add
label define eldch_lbl 73 `"73"', add
label define eldch_lbl 74 `"74"', add
label define eldch_lbl 75 `"75"', add
label define eldch_lbl 76 `"76"', add
label define eldch_lbl 77 `"77"', add
label define eldch_lbl 78 `"78"', add
label define eldch_lbl 79 `"79"', add
label define eldch_lbl 80 `"80"', add
label define eldch_lbl 81 `"81"', add
label define eldch_lbl 82 `"82"', add
label define eldch_lbl 83 `"83"', add
label define eldch_lbl 84 `"84"', add
label define eldch_lbl 85 `"85"', add
label define eldch_lbl 86 `"86"', add
label define eldch_lbl 87 `"87"', add
label define eldch_lbl 88 `"88"', add
label define eldch_lbl 89 `"89"', add
label define eldch_lbl 90 `"90"', add
label define eldch_lbl 91 `"91"', add
label define eldch_lbl 92 `"92"', add
label define eldch_lbl 93 `"93"', add
label define eldch_lbl 94 `"94"', add
label define eldch_lbl 95 `"95"', add
label define eldch_lbl 96 `"96"', add
label define eldch_lbl 97 `"97"', add
label define eldch_lbl 98 `"98"', add
label define eldch_lbl 99 `"N/A"', add
label values eldch eldch_lbl

label define yngch_lbl 0  `"Less than 1 year old"'
label define yngch_lbl 1  `"1"', add
label define yngch_lbl 2  `"2"', add
label define yngch_lbl 3  `"3"', add
label define yngch_lbl 4  `"4"', add
label define yngch_lbl 5  `"5"', add
label define yngch_lbl 6  `"6"', add
label define yngch_lbl 7  `"7"', add
label define yngch_lbl 8  `"8"', add
label define yngch_lbl 9  `"9"', add
label define yngch_lbl 10 `"10"', add
label define yngch_lbl 11 `"11"', add
label define yngch_lbl 12 `"12"', add
label define yngch_lbl 13 `"13"', add
label define yngch_lbl 14 `"14"', add
label define yngch_lbl 15 `"15"', add
label define yngch_lbl 16 `"16"', add
label define yngch_lbl 17 `"17"', add
label define yngch_lbl 18 `"18"', add
label define yngch_lbl 19 `"19"', add
label define yngch_lbl 20 `"20"', add
label define yngch_lbl 21 `"21"', add
label define yngch_lbl 22 `"22"', add
label define yngch_lbl 23 `"23"', add
label define yngch_lbl 24 `"24"', add
label define yngch_lbl 25 `"25"', add
label define yngch_lbl 26 `"26"', add
label define yngch_lbl 27 `"27"', add
label define yngch_lbl 28 `"28"', add
label define yngch_lbl 29 `"29"', add
label define yngch_lbl 30 `"30"', add
label define yngch_lbl 31 `"31"', add
label define yngch_lbl 32 `"32"', add
label define yngch_lbl 33 `"33"', add
label define yngch_lbl 34 `"34"', add
label define yngch_lbl 35 `"35"', add
label define yngch_lbl 36 `"36"', add
label define yngch_lbl 37 `"37"', add
label define yngch_lbl 38 `"38"', add
label define yngch_lbl 39 `"39"', add
label define yngch_lbl 40 `"40"', add
label define yngch_lbl 41 `"41"', add
label define yngch_lbl 42 `"42"', add
label define yngch_lbl 43 `"43"', add
label define yngch_lbl 44 `"44"', add
label define yngch_lbl 45 `"45"', add
label define yngch_lbl 46 `"46"', add
label define yngch_lbl 47 `"47"', add
label define yngch_lbl 48 `"48"', add
label define yngch_lbl 49 `"49"', add
label define yngch_lbl 50 `"50"', add
label define yngch_lbl 51 `"51"', add
label define yngch_lbl 52 `"52"', add
label define yngch_lbl 53 `"53"', add
label define yngch_lbl 54 `"54"', add
label define yngch_lbl 55 `"55"', add
label define yngch_lbl 56 `"56"', add
label define yngch_lbl 57 `"57"', add
label define yngch_lbl 58 `"58"', add
label define yngch_lbl 59 `"59"', add
label define yngch_lbl 60 `"60"', add
label define yngch_lbl 61 `"61"', add
label define yngch_lbl 62 `"62"', add
label define yngch_lbl 63 `"63"', add
label define yngch_lbl 64 `"64"', add
label define yngch_lbl 65 `"65"', add
label define yngch_lbl 66 `"66"', add
label define yngch_lbl 67 `"67"', add
label define yngch_lbl 68 `"68"', add
label define yngch_lbl 69 `"69"', add
label define yngch_lbl 70 `"70"', add
label define yngch_lbl 71 `"71"', add
label define yngch_lbl 72 `"72"', add
label define yngch_lbl 73 `"73"', add
label define yngch_lbl 74 `"74"', add
label define yngch_lbl 75 `"75"', add
label define yngch_lbl 76 `"76"', add
label define yngch_lbl 77 `"77"', add
label define yngch_lbl 78 `"78"', add
label define yngch_lbl 79 `"79"', add
label define yngch_lbl 80 `"80"', add
label define yngch_lbl 81 `"81"', add
label define yngch_lbl 82 `"82"', add
label define yngch_lbl 83 `"83"', add
label define yngch_lbl 84 `"84"', add
label define yngch_lbl 85 `"85"', add
label define yngch_lbl 86 `"86"', add
label define yngch_lbl 87 `"87"', add
label define yngch_lbl 88 `"88"', add
label define yngch_lbl 89 `"89"', add
label define yngch_lbl 90 `"90"', add
label define yngch_lbl 91 `"91"', add
label define yngch_lbl 92 `"92"', add
label define yngch_lbl 93 `"93"', add
label define yngch_lbl 94 `"94"', add
label define yngch_lbl 95 `"95"', add
label define yngch_lbl 96 `"96"', add
label define yngch_lbl 97 `"97"', add
label define yngch_lbl 98 `"98"', add
label define yngch_lbl 99 `"N/A"', add
label values yngch yngch_lbl

label define nsibs_lbl 0 `"0 siblings"'
label define nsibs_lbl 1 `"1 sibling"', add
label define nsibs_lbl 2 `"2 siblings"', add
label define nsibs_lbl 3 `"3 siblings"', add
label define nsibs_lbl 4 `"4 siblings"', add
label define nsibs_lbl 5 `"5 siblings"', add
label define nsibs_lbl 6 `"6 siblings"', add
label define nsibs_lbl 7 `"7 siblings"', add
label define nsibs_lbl 8 `"8 siblings"', add
label define nsibs_lbl 9 `"9 or more siblings"', add
label values nsibs nsibs_lbl

label define relate_lbl 101  `"Head/householder"'
label define relate_lbl 201  `"Spouse"', add
label define relate_lbl 202  `"2nd/3rd wife (polygamous)"', add
label define relate_lbl 301  `"Child"', add
label define relate_lbl 302  `"Adopted child"', add
label define relate_lbl 303  `"Stepchild"', add
label define relate_lbl 304  `"Adopted, n.s."', add
label define relate_lbl 401  `"Child-in-law"', add
label define relate_lbl 402  `"Step child-in-law"', add
label define relate_lbl 501  `"Parent"', add
label define relate_lbl 502  `"Step Parent"', add
label define relate_lbl 601  `"Parent-in-law"', add
label define relate_lbl 602  `"Step Parent-in-law"', add
label define relate_lbl 701  `"Sibling"', add
label define relate_lbl 702  `"Step/half/adopted sibling"', add
label define relate_lbl 801  `"Sibling-in-law"', add
label define relate_lbl 802  `"Step/half sibling-in-law"', add
label define relate_lbl 901  `"Grandchild"', add
label define relate_lbl 902  `"Adopted grandchild"', add
label define relate_lbl 903  `"Step grandchild"', add
label define relate_lbl 904  `"Grandchild-in-law"', add
label define relate_lbl 1000 `"Other relatives:"', add
label define relate_lbl 1001 `"Other relatives, n.s."', add
label define relate_lbl 1011 `"Grandparent"', add
label define relate_lbl 1012 `"Step grandparent"', add
label define relate_lbl 1013 `"Grandparent-in-law"', add
label define relate_lbl 1021 `"Aunt or uncle"', add
label define relate_lbl 1022 `"Aunt-/uncle-in-law"', add
label define relate_lbl 1031 `"Nephew, niece"', add
label define relate_lbl 1032 `"Nephew/niece-in-law"', add
label define relate_lbl 1033 `"Step/adopted nephew/niece"', add
label define relate_lbl 1034 `"Grand niece/nephew"', add
label define relate_lbl 1041 `"Cousin"', add
label define relate_lbl 1042 `"Cousin-in-law"', add
label define relate_lbl 1051 `"Great grandchild"', add
label define relate_lbl 1061 `"Other relatives, n.e.c."', add
label define relate_lbl 1100 `"Partner, friend, visitor"', add
label define relate_lbl 1110 `"Partner/friend"', add
label define relate_lbl 1111 `"Friend"', add
label define relate_lbl 1112 `"Partner"', add
label define relate_lbl 1113 `"Partner/roommate (1980 residual category for other non-relatives)"', add
label define relate_lbl 1114 `"Unmarried partner"', add
label define relate_lbl 1115 `"Housemate/roommate"', add
label define relate_lbl 1120 `"Relative of partner"', add
label define relate_lbl 1130 `"Concubine/mistress and children"', add
label define relate_lbl 1131 `"Visitor"', add
label define relate_lbl 1132 `"Companion and companion's family"', add
label define relate_lbl 1139 `"Allocated partner/friend/visitor"', add
label define relate_lbl 1200 `"Other non-relatives"', add
label define relate_lbl 1201 `"Roomers/boarders/lodgers"', add
label define relate_lbl 1202 `"Boarders"', add
label define relate_lbl 1203 `"Lodgers"', add
label define relate_lbl 1204 `"Roomer"', add
label define relate_lbl 1205 `"Tenant"', add
label define relate_lbl 1206 `"Foster child"', add
label define relate_lbl 1210 `"Employees:"', add
label define relate_lbl 1211 `"Servant"', add
label define relate_lbl 1212 `"Housekeeper"', add
label define relate_lbl 1213 `"Maid"', add
label define relate_lbl 1214 `"Cook"', add
label define relate_lbl 1215 `"Nurse"', add
label define relate_lbl 1216 `"Other probable domestic employee"', add
label define relate_lbl 1217 `"Other employees"', add
label define relate_lbl 1219 `"Relative of employee"', add
label define relate_lbl 1221 `"Military"', add
label define relate_lbl 1222 `"Students"', add
label define relate_lbl 1223 `"Members of religious orders"', add
label define relate_lbl 1230 `"Other non-relatives"', add
label define relate_lbl 1239 `"Allocated other non-relative"', add
label define relate_lbl 1240 `"Roomer/boarders/lodgers and foster children"', add
label define relate_lbl 1241 `"Roomer/boarders/lodgers"', add
label define relate_lbl 1242 `"Foster children"', add
label define relate_lbl 1250 `"Employees"', add
label define relate_lbl 1251 `"Domestic employees"', add
label define relate_lbl 1252 `"Non-domestic employees"', add
label define relate_lbl 1253 `"Relative of employee"', add
label define relate_lbl 1260 `"Other non-relatives (1990 includes employees)"', add
label define relate_lbl 1270 `"Non-inmate 1990 (includes military, students, employees, boarders)"', add
label define relate_lbl 1281 `"Head of group quarters"', add
label define relate_lbl 1282 `"Employee of group quarters"', add
label define relate_lbl 1283 `"Relative of head, staff, or employee group quarters"', add
label define relate_lbl 1284 `"Other non-inmate 1940-1950 (includes boarders, students, military)"', add
label define relate_lbl 1291 `"Military"', add
label define relate_lbl 1292 `"College dormitories"', add
label define relate_lbl 1293 `"Residents of rooming houses"', add
label define relate_lbl 1294 `"Other non-inmate 1980 (includes employees and non-inmates in institutions)"', add
label define relate_lbl 1295 `"Other non-inmates 1960-1970 (includes employees)"', add
label define relate_lbl 1296 `"Non-inmates in institutions"', add
label define relate_lbl 1301 `"Institutional inmates"', add
label define relate_lbl 8888 `"1960s cases to be allocated"', add
label define relate_lbl 9996 `"Unclassifiable"', add
label define relate_lbl 9997 `"Unknown"', add
label define relate_lbl 9998 `"Illegible"', add
label define relate_lbl 9999 `"Missing"', add
label values relate relate_lbl

label define age_lbl 0   `"Less than 1 year old"'
label define age_lbl 1   `"1"', add
label define age_lbl 2   `"2"', add
label define age_lbl 3   `"3"', add
label define age_lbl 4   `"4"', add
label define age_lbl 5   `"5"', add
label define age_lbl 6   `"6"', add
label define age_lbl 7   `"7"', add
label define age_lbl 8   `"8"', add
label define age_lbl 9   `"9"', add
label define age_lbl 10  `"10"', add
label define age_lbl 11  `"11"', add
label define age_lbl 12  `"12"', add
label define age_lbl 13  `"13"', add
label define age_lbl 14  `"14"', add
label define age_lbl 15  `"15"', add
label define age_lbl 16  `"16"', add
label define age_lbl 17  `"17"', add
label define age_lbl 18  `"18"', add
label define age_lbl 19  `"19"', add
label define age_lbl 20  `"20"', add
label define age_lbl 21  `"21"', add
label define age_lbl 22  `"22"', add
label define age_lbl 23  `"23"', add
label define age_lbl 24  `"24"', add
label define age_lbl 25  `"25"', add
label define age_lbl 26  `"26"', add
label define age_lbl 27  `"27"', add
label define age_lbl 28  `"28"', add
label define age_lbl 29  `"29"', add
label define age_lbl 30  `"30"', add
label define age_lbl 31  `"31"', add
label define age_lbl 32  `"32"', add
label define age_lbl 33  `"33"', add
label define age_lbl 34  `"34"', add
label define age_lbl 35  `"35"', add
label define age_lbl 36  `"36"', add
label define age_lbl 37  `"37"', add
label define age_lbl 38  `"38"', add
label define age_lbl 39  `"39"', add
label define age_lbl 40  `"40"', add
label define age_lbl 41  `"41"', add
label define age_lbl 42  `"42"', add
label define age_lbl 43  `"43"', add
label define age_lbl 44  `"44"', add
label define age_lbl 45  `"45"', add
label define age_lbl 46  `"46"', add
label define age_lbl 47  `"47"', add
label define age_lbl 48  `"48"', add
label define age_lbl 49  `"49"', add
label define age_lbl 50  `"50"', add
label define age_lbl 51  `"51"', add
label define age_lbl 52  `"52"', add
label define age_lbl 53  `"53"', add
label define age_lbl 54  `"54"', add
label define age_lbl 55  `"55"', add
label define age_lbl 56  `"56"', add
label define age_lbl 57  `"57"', add
label define age_lbl 58  `"58"', add
label define age_lbl 59  `"59"', add
label define age_lbl 60  `"60"', add
label define age_lbl 61  `"61"', add
label define age_lbl 62  `"62"', add
label define age_lbl 63  `"63"', add
label define age_lbl 64  `"64"', add
label define age_lbl 65  `"65"', add
label define age_lbl 66  `"66"', add
label define age_lbl 67  `"67"', add
label define age_lbl 68  `"68"', add
label define age_lbl 69  `"69"', add
label define age_lbl 70  `"70"', add
label define age_lbl 71  `"71"', add
label define age_lbl 72  `"72"', add
label define age_lbl 73  `"73"', add
label define age_lbl 74  `"74"', add
label define age_lbl 75  `"75"', add
label define age_lbl 76  `"76"', add
label define age_lbl 77  `"77"', add
label define age_lbl 78  `"78"', add
label define age_lbl 79  `"79"', add
label define age_lbl 80  `"80"', add
label define age_lbl 81  `"81"', add
label define age_lbl 82  `"82"', add
label define age_lbl 83  `"83"', add
label define age_lbl 84  `"84"', add
label define age_lbl 85  `"85"', add
label define age_lbl 86  `"86"', add
label define age_lbl 87  `"87"', add
label define age_lbl 88  `"88"', add
label define age_lbl 89  `"89"', add
label define age_lbl 90  `"90 (90+ in 1980 and 1990)"', add
label define age_lbl 91  `"91"', add
label define age_lbl 92  `"92"', add
label define age_lbl 93  `"93"', add
label define age_lbl 94  `"94"', add
label define age_lbl 95  `"95"', add
label define age_lbl 96  `"96"', add
label define age_lbl 97  `"97"', add
label define age_lbl 98  `"98"', add
label define age_lbl 99  `"99"', add
label define age_lbl 100 `"100 (100+ in 1960-1970)"', add
label define age_lbl 101 `"101"', add
label define age_lbl 102 `"102"', add
label define age_lbl 103 `"103"', add
label define age_lbl 104 `"104"', add
label define age_lbl 105 `"105"', add
label define age_lbl 106 `"106"', add
label define age_lbl 107 `"107"', add
label define age_lbl 108 `"108"', add
label define age_lbl 109 `"109"', add
label define age_lbl 110 `"110"', add
label define age_lbl 111 `"111"', add
label define age_lbl 112 `"112 (112+ in the 1980 internal data)"', add
label define age_lbl 113 `"113"', add
label define age_lbl 114 `"114"', add
label define age_lbl 115 `"115 (115+ in the 1990 internal data)"', add
label define age_lbl 116 `"116"', add
label define age_lbl 117 `"117"', add
label define age_lbl 118 `"118"', add
label define age_lbl 119 `"119"', add
label define age_lbl 120 `"120"', add
label define age_lbl 121 `"121"', add
label define age_lbl 122 `"122"', add
label define age_lbl 123 `"123"', add
label define age_lbl 124 `"124"', add
label define age_lbl 125 `"125"', add
label define age_lbl 126 `"126"', add
label define age_lbl 129 `"129"', add
label define age_lbl 130 `"130"', add
label define age_lbl 135 `"135"', add
label define age_lbl 998 `"Illegible"', add
label define age_lbl 999 `"Missing"', add
label define age_lbl 888 `"1960s cases to be allocated"', add
label values age age_lbl

label define sex_lbl 1 `"Male"'
label define sex_lbl 2 `"Female"', add
label define sex_lbl 8 `"Illegible"', add
label define sex_lbl 9 `"Missing/blank"', add
label values sex sex_lbl

label define race_lbl 100 `"White"'
label define race_lbl 110 `"Spanish write_in"', add
label define race_lbl 120 `"Blank (white)"', add
label define race_lbl 130 `"Portuguese"', add
label define race_lbl 140 `"Mexican (1930)"', add
label define race_lbl 150 `"Puerto Rican"', add
label define race_lbl 200 `"Black/African American/Negro"', add
label define race_lbl 210 `"Mulatto"', add
label define race_lbl 300 `"American Indian/Alaska Native (AIAN)"', add
label define race_lbl 302 `"Apache"', add
label define race_lbl 303 `"Blackfoot"', add
label define race_lbl 304 `"Cherokee"', add
label define race_lbl 305 `"Cheyenne"', add
label define race_lbl 306 `"Chickasaw"', add
label define race_lbl 307 `"Chippewa"', add
label define race_lbl 308 `"Choctaw"', add
label define race_lbl 309 `"Comanche"', add
label define race_lbl 310 `"Creek"', add
label define race_lbl 311 `"Crow"', add
label define race_lbl 312 `"Iroquois"', add
label define race_lbl 313 `"Kiowa"', add
label define race_lbl 314 `"Lumbee"', add
label define race_lbl 315 `"Navajo"', add
label define race_lbl 316 `"Osage"', add
label define race_lbl 317 `"Paiute"', add
label define race_lbl 318 `"Pima"', add
label define race_lbl 319 `"Potawatomi"', add
label define race_lbl 320 `"Pueblo"', add
label define race_lbl 321 `"Seminole"', add
label define race_lbl 322 `"Shoshone"', add
label define race_lbl 323 `"Sioux"', add
label define race_lbl 324 `"Tlingit (Tlingit_Haida, 2000, ACS)"', add
label define race_lbl 325 `"Tohono O'Odham"', add
label define race_lbl 326 `"All other tribes (1990)"', add
label define race_lbl 328 `"Hopi"', add
label define race_lbl 329 `"Central American Indian"', add
label define race_lbl 330 `"Spanish American Indian"', add
label define race_lbl 350 `"Delaware"', add
label define race_lbl 351 `"Latin American Indian"', add
label define race_lbl 352 `"Puget Sound Salish"', add
label define race_lbl 353 `"Yakama"', add
label define race_lbl 354 `"Yaqui"', add
label define race_lbl 355 `"Colville"', add
label define race_lbl 356 `"Houma"', add
label define race_lbl 357 `"Menominee"', add
label define race_lbl 358 `"Yuman"', add
label define race_lbl 359 `"South American Indian"', add
label define race_lbl 360 `"Mexican American Indian"', add
label define race_lbl 361 `"Other Specified AI tribe (2000,ACS)"', add
label define race_lbl 362 `"Two or more AI tribes (2000,ACS)"', add
label define race_lbl 370 `"Alaskan Athabaskan"', add
label define race_lbl 371 `"Aleut"', add
label define race_lbl 372 `"Eskimo"', add
label define race_lbl 373 `"Alaskan mixed"', add
label define race_lbl 374 `"Inupiat"', add
label define race_lbl 375 `"Yup'ik"', add
label define race_lbl 379 `"Other AN tribe(s) (2000,ACS)"', add
label define race_lbl 398 `"Both AI and AN (2000,ACS)"', add
label define race_lbl 399 `"AIAN, tribe not specified"', add
label define race_lbl 400 `"Chinese"', add
label define race_lbl 410 `"Taiwanese"', add
label define race_lbl 420 `"Chinese and Taiwanese"', add
label define race_lbl 500 `"Japanese"', add
label define race_lbl 600 `"Filipino"', add
label define race_lbl 610 `"Asian Indian (Hindu 1920_1940)"', add
label define race_lbl 620 `"Korean"', add
label define race_lbl 630 `"Native Hawaiian"', add
label define race_lbl 631 `"Asiatic Hawaiian (1920)"', add
label define race_lbl 632 `"Caucasian Hawaiian (1920)"', add
label define race_lbl 634 `"Hawaiian mixed"', add
label define race_lbl 640 `"Vietnamese"', add
label define race_lbl 641 `"Bhutanese"', add
label define race_lbl 642 `"Mongolian"', add
label define race_lbl 643 `"Nepalese"', add
label define race_lbl 650 `"Other Asian or Pacific Islander (1980)"', add
label define race_lbl 651 `"Asian only (CPS)"', add
label define race_lbl 652 `"Pacific Islander only (CPS)"', add
label define race_lbl 653 `"Asian or Pacific Islander, n.s. (1990 Internal Census files)"', add
label define race_lbl 660 `"Cambodian"', add
label define race_lbl 661 `"Hmong"', add
label define race_lbl 662 `"Laotian"', add
label define race_lbl 663 `"Thai"', add
label define race_lbl 664 `"Bangladeshi"', add
label define race_lbl 665 `"Burmese"', add
label define race_lbl 666 `"Indonesian"', add
label define race_lbl 667 `"Malaysian"', add
label define race_lbl 668 `"Okinawan"', add
label define race_lbl 669 `"Pakistani"', add
label define race_lbl 670 `"Sri Lankan"', add
label define race_lbl 671 `"All other Asian, n.e.c."', add
label define race_lbl 672 `"Asian, not specified"', add
label define race_lbl 673 `"Chinese and Japanese"', add
label define race_lbl 674 `"Chinese and Filipino"', add
label define race_lbl 675 `"Chinese and Vietnamese"', add
label define race_lbl 676 `"Chinese and Asian write_in; Chinese and Other Asian"', add
label define race_lbl 677 `"Japanese and Filipino"', add
label define race_lbl 678 `"Asian Indian and Asian write_in"', add
label define race_lbl 679 `"Other Asian race combinations"', add
label define race_lbl 680 `"Samoan"', add
label define race_lbl 681 `"Tahitian"', add
label define race_lbl 682 `"Tongan"', add
label define race_lbl 683 `"Other Polynesian (1990)"', add
label define race_lbl 684 `"One or more other Polynesian races (2000,ACS)"', add
label define race_lbl 685 `"Guamanian/Chamorro"', add
label define race_lbl 686 `"Northern Mariana Islander"', add
label define race_lbl 687 `"Palauan"', add
label define race_lbl 688 `"Other Micronesian (1990)"', add
label define race_lbl 689 `"One or more other Micronesian races (2000,ACS)"', add
label define race_lbl 690 `"Fijian"', add
label define race_lbl 691 `"Other Melanesian (1990)"', add
label define race_lbl 692 `"One or more Melanesian races (2000,ACS)"', add
label define race_lbl 698 `"Two or more PI races from multiple regions"', add
label define race_lbl 699 `"Pacific Islander (PI), n.s."', add
label define race_lbl 700 `"Other race, n.e.c."', add
label define race_lbl 801 `"White and Black"', add
label define race_lbl 802 `"White and AIAN"', add
label define race_lbl 810 `"White and Asian"', add
label define race_lbl 811 `"White and Chinese"', add
label define race_lbl 812 `"White and Japanese"', add
label define race_lbl 813 `"White and Filipino"', add
label define race_lbl 814 `"White and Asian Indian"', add
label define race_lbl 815 `"White and Korean"', add
label define race_lbl 816 `"White and Vietnamese"', add
label define race_lbl 817 `"White and Asian write_in"', add
label define race_lbl 818 `"White and other Asian race(s)"', add
label define race_lbl 819 `"White and two or more Asian groups"', add
label define race_lbl 820 `"White and PI:"', add
label define race_lbl 821 `"White and Native Hawaiian"', add
label define race_lbl 822 `"White and Samoan"', add
label define race_lbl 823 `"White and Guamanian/Chamorro"', add
label define race_lbl 824 `"White and PI write_in"', add
label define race_lbl 825 `"White and other PI race(s)"', add
label define race_lbl 826 `"White and 'other race' write_in"', add
label define race_lbl 827 `"White and one or more major race groups, n.e.c."', add
label define race_lbl 830 `"Black and AIAN"', add
label define race_lbl 831 `"Black and Asian"', add
label define race_lbl 832 `"Black and Chinese"', add
label define race_lbl 833 `"Black and Japanese"', add
label define race_lbl 834 `"Black and Filipino"', add
label define race_lbl 835 `"Black and Asian Indian"', add
label define race_lbl 836 `"Black and Korean"', add
label define race_lbl 837 `"Black and Asian write_in"', add
label define race_lbl 838 `"Black and other Asian race(s)"', add
label define race_lbl 840 `"Black and Pacific Islander"', add
label define race_lbl 841 `"Black and Pacific Islander write_in"', add
label define race_lbl 842 `"Black and other PI race(s)"', add
label define race_lbl 845 `"Black and 'other race' write_in"', add
label define race_lbl 850 `"AIAN and Asian"', add
label define race_lbl 851 `"AIAN and Filipino (2000 1%)"', add
label define race_lbl 852 `"AIAN and Asian Indian"', add
label define race_lbl 853 `"AIAN and Asian write_in (2000 1%)"', add
label define race_lbl 854 `"AIAN and other Asian race(s)"', add
label define race_lbl 855 `"AIAN and Pacific Islander"', add
label define race_lbl 856 `"AIAN and 'other race' write_in"', add
label define race_lbl 860 `"Asian and Pacific Islander"', add
label define race_lbl 861 `"Chinese and Native Hawaiian"', add
label define race_lbl 862 `"Chinese, Filipino, and Native Hawaiian (2000 1%)"', add
label define race_lbl 863 `"Japanese and Native Hawaiian (2000 1%)"', add
label define race_lbl 864 `"Filipino and Native Hawaiian"', add
label define race_lbl 865 `"Filipino and PI write_in"', add
label define race_lbl 866 `"Asian Indian and PI write_in (2000 1%)"', add
label define race_lbl 867 `"Asian write_in and PI write_in"', add
label define race_lbl 868 `"Other Asian race(s) and PI race(s)"', add
label define race_lbl 869 `"Japanese and Korean (ACS)"', add
label define race_lbl 880 `"Asian and 'other race' write_in"', add
label define race_lbl 881 `"Chinese and 'other race' write_in"', add
label define race_lbl 882 `"Japanese and 'other race' write_in (2000 1%)"', add
label define race_lbl 883 `"Filipino and 'other race' write_in"', add
label define race_lbl 884 `"Asian Indian and 'other race' write_in"', add
label define race_lbl 885 `"Asian write_in and 'other race' write_in"', add
label define race_lbl 886 `"Other Asian race(s) and 'other race' write_in"', add
label define race_lbl 887 `"Chinese and Korean"', add
label define race_lbl 890 `"PI and 'other race' write_in"', add
label define race_lbl 891 `"PI write_in and 'other race' write_in"', add
label define race_lbl 892 `"Other PI race(s) and 'other race' write_in"', add
label define race_lbl 893 `"Native Hawaiian or PI other race(s)"', add
label define race_lbl 899 `"Asian/Pacific Islander and 'other race' write_in"', add
label define race_lbl 901 `"White, Black, and AIAN"', add
label define race_lbl 902 `"White and Black and Asian"', add
label define race_lbl 903 `"White and Black and Pacific Islander"', add
label define race_lbl 904 `"White and Black and 'other race' write_in"', add
label define race_lbl 905 `"White and American Indian/Alaska Native and Asian"', add
label define race_lbl 906 `"White and American Indian/Alaska Native and Pacific Islander"', add
label define race_lbl 907 `"White and American Indian/Alaska Native and 'other race' write_in"', add
label define race_lbl 910 `"White and Asian and Pacific Islander:"', add
label define race_lbl 911 `"White and Chinese and Native Hawaiian"', add
label define race_lbl 912 `"White and Chinese and Filipino and Native Hawaiian (2000 1%, 2012 ACS)"', add
label define race_lbl 913 `"White and Japanese and Native Hawaiian (2000 1%)"', add
label define race_lbl 914 `"White and Filipino and Native Hawaiian"', add
label define race_lbl 915 `"Other White and Asian race(s) and Pacific Islander race(s)"', add
label define race_lbl 916 `"White, AIAN and Filipino"', add
label define race_lbl 917 `"White, Black, and Filipino"', add
label define race_lbl 920 `"White and Asian and 'other race' write_in:"', add
label define race_lbl 921 `"White and Filipino and 'other race' write_in (2000 1%)"', add
label define race_lbl 922 `"White and Asian write_in and 'other race' write_in (2000 1%)"', add
label define race_lbl 923 `"Other White and Asian race(s) and 'other race' write_in (2000 1%)"', add
label define race_lbl 925 `"White and Pacific Islander and 'other race' write_in"', add
label define race_lbl 930 `"Black and American Indian/Alaska Native and Asian"', add
label define race_lbl 931 `"Black and American Indian/Alaska Native and Pacific Islander"', add
label define race_lbl 932 `"Black and American Indian/Alaska Native and 'other race' write_in"', add
label define race_lbl 933 `"Black and Asian and Pacific Islander"', add
label define race_lbl 934 `"Black and Asian and 'other race' write_in"', add
label define race_lbl 935 `"Black and Pacific Islander and 'other race' write_in"', add
label define race_lbl 940 `"American Indian/Alaska Native and Asian and Pacific Islander"', add
label define race_lbl 941 `"American Indian/Alaska Native and Asian and 'other race' write_in"', add
label define race_lbl 942 `"American Indian/Alaska Native and Pacific Islander and 'other race' write_in"', add
label define race_lbl 943 `"Asian and Pacific Islander and 'other race' write_in"', add
label define race_lbl 944 `"Asian (Chinese, Japanese, Korean, Vietnamese); and Native Hawaiian or PI; and Other"', add
label define race_lbl 949 `"Two or three major race groups, unspecified (CPS)"', add
label define race_lbl 950 `"White and Black and American Indian/Alaska Native and Asian"', add
label define race_lbl 951 `"White and Black and American Indian/Alaska Native and Pacific Islander"', add
label define race_lbl 952 `"White and Black and American Indian/Alaska Native and 'other race' write_in"', add
label define race_lbl 953 `"White and Black and Asian and Pacific Islander"', add
label define race_lbl 954 `"White and Black and Asian and 'other race' write_in"', add
label define race_lbl 955 `"White and Black and Pacific Islander and 'other race' write_in"', add
label define race_lbl 960 `"White and American Indian/Alaska Native and Asian and Pacific Islander"', add
label define race_lbl 961 `"White and American Indian/Alaska Native and Asian and 'other race' write_in"', add
label define race_lbl 962 `"White and American Indian/Alaska Native and Pacific Islander and 'other race' write_in"', add
label define race_lbl 963 `"White and Asian and Pacific Islander and 'other race' write_in"', add
label define race_lbl 964 `"White, Chinese, Japanese, Native Hawaiian"', add
label define race_lbl 970 `"Black and American Indian/Alaska Native and Asian and Pacific Islander"', add
label define race_lbl 971 `"Black and American Indian/Alaska Native and Asian and 'other race' write_in"', add
label define race_lbl 972 `"Black and American Indian/Alaska Native and Pacific Islander and 'other race' write_in"', add
label define race_lbl 973 `"Black and Asian and Pacific Islander and 'other race' write_in"', add
label define race_lbl 974 `"American Indian/Alaska Native and Asian and Pacific Islander and 'other race' write_in"', add
label define race_lbl 975 `"American Indian and Alaska Native race; Asian groups and/or Native Hawaiian and Other Pacific Islander groups and/or Some other race"', add
label define race_lbl 976 `"Two specified Asian (Chinese and other Asian, Chinese and Japanese, Japanese and other Asian, Korean and other Asian); Native Hawaiian/PI; and Other Race"', add
label define race_lbl 980 `"White and Black and American Indian/Alaska Native and Asian and Pacific Islander"', add
label define race_lbl 981 `"White and Black and American Indian/Alaska Native and Asian and 'other race' write_in"', add
label define race_lbl 982 `"White and Black and American Indian/Alaska Native and Pacific Islander and 'other race' write_in"', add
label define race_lbl 983 `"White and Black and Asian and Pacific Islander and 'other race' write_in"', add
label define race_lbl 984 `"White and American Indian/Alaska Native and Asian and Pacific Islander and 'other race' write_in"', add
label define race_lbl 985 `"Black and American Indian/Alaska Native and Asian and Pacific Islander and 'other race' write_in"', add
label define race_lbl 986 `"Black or African American race; American Indian and Alaska Native race; Asian groups and/or Native Hawaiian and Other Pacific Islander groups and/or Some other race"', add
label define race_lbl 989 `"Four or five major race groups, unspecified (CPS)"', add
label define race_lbl 990 `"White and Black and American Indian/Alaska Native and Asian and Pacific Islander and 'other race' write_in"', add
label define race_lbl 991 `"White race; Some other race; Black or African American race and/or American Indian and Alaska Native race and/or Asian groups and/or Native Hawaiian and Other Pacific Islander groups"', add
label define race_lbl 996 `"Two or more major race groups, n.e.c. (CPS)"', add
label define race_lbl 997 `"Unknown"', add
label define race_lbl 998 `"Illegible"', add
label define race_lbl 999 `"Missing"', add
label values race race_lbl

label define marst_lbl 1 `"Married, spouse present"'
label define marst_lbl 2 `"Married, spouse absent"', add
label define marst_lbl 3 `"Separated"', add
label define marst_lbl 4 `"Divorced"', add
label define marst_lbl 5 `"Widowed"', add
label define marst_lbl 6 `"Never married/single"', add
label define marst_lbl 7 `"Indeterminate/unknown"', add
label define marst_lbl 8 `"Illegible"', add
label define marst_lbl 9 `"Blank, missing"', add
label values marst marst_lbl

label define marrinyr_lbl 0 `"N/A"'
label define marrinyr_lbl 1 `"Blank (No)"', add
label define marrinyr_lbl 2 `"Yes"', add
label values marrinyr marrinyr_lbl

label define bpl_lbl 100   `"Alabama"'
label define bpl_lbl 200   `"Alaska"', add
label define bpl_lbl 400   `"Arizona"', add
label define bpl_lbl 500   `"Arkansas"', add
label define bpl_lbl 600   `"California"', add
label define bpl_lbl 800   `"Colorado"', add
label define bpl_lbl 900   `"Connecticut"', add
label define bpl_lbl 1000  `"Delaware"', add
label define bpl_lbl 1100  `"District of Columbia"', add
label define bpl_lbl 1200  `"Florida"', add
label define bpl_lbl 1300  `"Georgia"', add
label define bpl_lbl 1500  `"Hawaii"', add
label define bpl_lbl 1600  `"Idaho"', add
label define bpl_lbl 1610  `"Idaho Territory"', add
label define bpl_lbl 1700  `"Illinois"', add
label define bpl_lbl 1800  `"Indiana"', add
label define bpl_lbl 1900  `"Iowa"', add
label define bpl_lbl 2000  `"Kansas"', add
label define bpl_lbl 2100  `"Kentucky"', add
label define bpl_lbl 2200  `"Louisiana"', add
label define bpl_lbl 2300  `"Maine"', add
label define bpl_lbl 2400  `"Maryland"', add
label define bpl_lbl 2500  `"Massachusetts"', add
label define bpl_lbl 2600  `"Michigan"', add
label define bpl_lbl 2700  `"Minnesota"', add
label define bpl_lbl 2800  `"Mississippi"', add
label define bpl_lbl 2900  `"Missouri"', add
label define bpl_lbl 3000  `"Montana"', add
label define bpl_lbl 3100  `"Nebraska"', add
label define bpl_lbl 3200  `"Nevada"', add
label define bpl_lbl 3300  `"New Hampshire"', add
label define bpl_lbl 3400  `"New Jersey"', add
label define bpl_lbl 3500  `"New Mexico"', add
label define bpl_lbl 3510  `"New Mexico Territory"', add
label define bpl_lbl 3600  `"New York"', add
label define bpl_lbl 3700  `"North Carolina"', add
label define bpl_lbl 3800  `"North Dakota"', add
label define bpl_lbl 3900  `"Ohio"', add
label define bpl_lbl 4000  `"Oklahoma"', add
label define bpl_lbl 4010  `"Indian Territory"', add
label define bpl_lbl 4100  `"Oregon"', add
label define bpl_lbl 4200  `"Pennsylvania"', add
label define bpl_lbl 4400  `"Rhode Island"', add
label define bpl_lbl 4500  `"South Carolina"', add
label define bpl_lbl 4600  `"South Dakota"', add
label define bpl_lbl 4610  `"Dakota Territory"', add
label define bpl_lbl 4700  `"Tennessee"', add
label define bpl_lbl 4800  `"Texas"', add
label define bpl_lbl 4900  `"Utah"', add
label define bpl_lbl 4910  `"Utah Territory"', add
label define bpl_lbl 5000  `"Vermont"', add
label define bpl_lbl 5100  `"Virginia"', add
label define bpl_lbl 5300  `"Washington"', add
label define bpl_lbl 5400  `"West Virginia"', add
label define bpl_lbl 5500  `"Wisconsin"', add
label define bpl_lbl 5600  `"Wyoming"', add
label define bpl_lbl 5610  `"Wyoming Territory"', add
label define bpl_lbl 9000  `"Native American"', add
label define bpl_lbl 9900  `"United States, n.s."', add
label define bpl_lbl 10000 `"American Samoa"', add
label define bpl_lbl 10010 `"Samoa, 1940-1950"', add
label define bpl_lbl 10500 `"Guam"', add
label define bpl_lbl 11000 `"Puerto Rico"', add
label define bpl_lbl 11500 `"U.S. Virgin Islands"', add
label define bpl_lbl 11510 `"St. Croix"', add
label define bpl_lbl 11520 `"St. John"', add
label define bpl_lbl 11530 `"St. Thomas"', add
label define bpl_lbl 12000 `"Other US Possessions"', add
label define bpl_lbl 12010 `"Johnston Atoll"', add
label define bpl_lbl 12020 `"Midway Islands"', add
label define bpl_lbl 12030 `"Wake Island"', add
label define bpl_lbl 12040 `"Other US Caribbean Is."', add
label define bpl_lbl 12041 `"Navassa Island"', add
label define bpl_lbl 12050 `"Other US Pacific Is."', add
label define bpl_lbl 12051 `"Baker Island"', add
label define bpl_lbl 12052 `"Howland Island"', add
label define bpl_lbl 12053 `"Jarvis Island"', add
label define bpl_lbl 12054 `"Kingman Reef"', add
label define bpl_lbl 12055 `"Palmyra Atoll"', add
label define bpl_lbl 12056 `"Canton and Enderbury Island"', add
label define bpl_lbl 12090 `"US outlying areas, n.s."', add
label define bpl_lbl 12091 `"US possessions, n.s."', add
label define bpl_lbl 12092 `"US territory, n.s."', add
label define bpl_lbl 15000 `"Canada"', add
label define bpl_lbl 15010 `"English Canada"', add
label define bpl_lbl 15011 `"British Columbia"', add
label define bpl_lbl 15013 `"Alberta"', add
label define bpl_lbl 15015 `"Saskatchewan"', add
label define bpl_lbl 15017 `"Northwest"', add
label define bpl_lbl 15019 `"Rupert's Land"', add
label define bpl_lbl 15020 `"Manitoba"', add
label define bpl_lbl 15021 `"Red River"', add
label define bpl_lbl 15030 `"Ontario/Upper Canada"', add
label define bpl_lbl 15031 `"Upper Canada"', add
label define bpl_lbl 15032 `"Canada West"', add
label define bpl_lbl 15040 `"New Brunswick"', add
label define bpl_lbl 15050 `"Nova Scotia"', add
label define bpl_lbl 15051 `"Cape Breton"', add
label define bpl_lbl 15052 `"Halifax"', add
label define bpl_lbl 15060 `"Prince Edward Island"', add
label define bpl_lbl 15070 `"Newfoundland"', add
label define bpl_lbl 15080 `"French Canada"', add
label define bpl_lbl 15081 `"Quebec"', add
label define bpl_lbl 15082 `"Lower Canada"', add
label define bpl_lbl 15083 `"Canada East"', add
label define bpl_lbl 15500 `"St. Pierre and Miquelon"', add
label define bpl_lbl 16000 `"Atlantic Islands"', add
label define bpl_lbl 16010 `"Bermuda"', add
label define bpl_lbl 16020 `"Cape Verde"', add
label define bpl_lbl 16030 `"Falkland Islands"', add
label define bpl_lbl 16040 `"Greenland"', add
label define bpl_lbl 16050 `"St. Helena and Ascension"', add
label define bpl_lbl 16060 `"Canary Islands"', add
label define bpl_lbl 19900 `"North America, n.s./n.e.c."', add
label define bpl_lbl 20000 `"Mexico"', add
label define bpl_lbl 21000 `"Central America"', add
label define bpl_lbl 21010 `"Belize/British Honduras"', add
label define bpl_lbl 21020 `"Costa Rica"', add
label define bpl_lbl 21030 `"El Salvador"', add
label define bpl_lbl 21040 `"Guatemala"', add
label define bpl_lbl 21050 `"Honduras"', add
label define bpl_lbl 21060 `"Nicaragua"', add
label define bpl_lbl 21070 `"Panama"', add
label define bpl_lbl 21071 `"Canal Zone"', add
label define bpl_lbl 21090 `"Central America, n.s."', add
label define bpl_lbl 25000 `"Cuba"', add
label define bpl_lbl 26000 `"West Indies"', add
label define bpl_lbl 26010 `"Dominican Republic"', add
label define bpl_lbl 26020 `"Haiti"', add
label define bpl_lbl 26030 `"Jamaica"', add
label define bpl_lbl 26040 `"British West Indies"', add
label define bpl_lbl 26041 `"Anguilla"', add
label define bpl_lbl 26042 `"Antigua-Barbuda"', add
label define bpl_lbl 26043 `"Bahamas"', add
label define bpl_lbl 26044 `"Barbados"', add
label define bpl_lbl 26045 `"British Virgin Islands"', add
label define bpl_lbl 26046 `"Anegada"', add
label define bpl_lbl 26047 `"Cooper"', add
label define bpl_lbl 26048 `"Jost Van Dyke"', add
label define bpl_lbl 26049 `"Peter"', add
label define bpl_lbl 26050 `"Tortola"', add
label define bpl_lbl 26051 `"Virgin Gorda"', add
label define bpl_lbl 26052 `"British Virgin Islands, n.s./ n.e.c."', add
label define bpl_lbl 26053 `"Cayman Isles"', add
label define bpl_lbl 26054 `"Dominica"', add
label define bpl_lbl 26055 `"Grenada"', add
label define bpl_lbl 26056 `"Montserrat"', add
label define bpl_lbl 26057 `"St. Kitts-Nevis"', add
label define bpl_lbl 26058 `"St. Lucia"', add
label define bpl_lbl 26059 `"St. Vincent"', add
label define bpl_lbl 26060 `"Trinidad and Tobago"', add
label define bpl_lbl 26061 `"Turks and Caicos"', add
label define bpl_lbl 26069 `"British Virgin Islands, n.s./n.e.c."', add
label define bpl_lbl 26070 `"Other West Indies"', add
label define bpl_lbl 26071 `"Aruba"', add
label define bpl_lbl 26072 `"Netherlands Antilles"', add
label define bpl_lbl 26073 `"Bonaire"', add
label define bpl_lbl 26074 `"Curacao"', add
label define bpl_lbl 26075 `"Dutch St. Maarten"', add
label define bpl_lbl 26076 `"Saba"', add
label define bpl_lbl 26077 `"St. Eustatius"', add
label define bpl_lbl 26079 `"Dutch Caribbean, n.s./n.e.c."', add
label define bpl_lbl 26080 `"French St. Maarten"', add
label define bpl_lbl 26081 `"Guadeloupe"', add
label define bpl_lbl 26082 `"Martinique"', add
label define bpl_lbl 26083 `"St. Barthelemy"', add
label define bpl_lbl 26089 `"French Caribbean, n.s."', add
label define bpl_lbl 26090 `"Antilles, n.s."', add
label define bpl_lbl 26091 `"Caribbean, n.s. / n.e.c."', add
label define bpl_lbl 26092 `"Latin America, n.s."', add
label define bpl_lbl 26093 `"Leeward Islands, n.s."', add
label define bpl_lbl 26094 `"West Indies, n.s."', add
label define bpl_lbl 26095 `"Windward Islands, n.s."', add
label define bpl_lbl 29900 `"Americas, n.s."', add
label define bpl_lbl 30000 `"SOUTH AMERICA"', add
label define bpl_lbl 30005 `"Argentina"', add
label define bpl_lbl 30010 `"Bolivia"', add
label define bpl_lbl 30015 `"Brazil"', add
label define bpl_lbl 30020 `"Chile"', add
label define bpl_lbl 30025 `"Colombia"', add
label define bpl_lbl 30030 `"Ecuador"', add
label define bpl_lbl 30035 `"French Guiana"', add
label define bpl_lbl 30040 `"Guyana/British Guiana"', add
label define bpl_lbl 30045 `"Paraguay"', add
label define bpl_lbl 30050 `"Peru"', add
label define bpl_lbl 30055 `"Suriname"', add
label define bpl_lbl 30060 `"Uruguay"', add
label define bpl_lbl 30065 `"Venezuela"', add
label define bpl_lbl 30090 `"South America, n.s."', add
label define bpl_lbl 30091 `"South and Central America, n.s."', add
label define bpl_lbl 40000 `"Denmark"', add
label define bpl_lbl 40010 `"Faroe Islands"', add
label define bpl_lbl 40100 `"Finland"', add
label define bpl_lbl 40200 `"Iceland"', add
label define bpl_lbl 40300 `"Lapland, n.s."', add
label define bpl_lbl 40400 `"Norway"', add
label define bpl_lbl 40410 `"Svalbard and Jan Meyen"', add
label define bpl_lbl 40411 `"Svalbard"', add
label define bpl_lbl 40412 `"Jan Meyen"', add
label define bpl_lbl 40500 `"Sweden"', add
label define bpl_lbl 41000 `"England"', add
label define bpl_lbl 41010 `"Channel Islands"', add
label define bpl_lbl 41011 `"Guernsey"', add
label define bpl_lbl 41012 `"Jersey"', add
label define bpl_lbl 41020 `"Isle of Man"', add
label define bpl_lbl 41100 `"Scotland"', add
label define bpl_lbl 41200 `"Wales"', add
label define bpl_lbl 41300 `"United Kingdom, n.s./n.e.c."', add
label define bpl_lbl 41400 `"Ireland"', add
label define bpl_lbl 41410 `"Northern Ireland"', add
label define bpl_lbl 41900 `"Northern Europe, n.s."', add
label define bpl_lbl 42000 `"Belgium"', add
label define bpl_lbl 42100 `"France"', add
label define bpl_lbl 42110 `"Alsace-Lorraine"', add
label define bpl_lbl 42111 `"Alsace"', add
label define bpl_lbl 42112 `"Lorraine"', add
label define bpl_lbl 42200 `"Liechtenstein"', add
label define bpl_lbl 42300 `"Luxembourg"', add
label define bpl_lbl 42400 `"Monaco"', add
label define bpl_lbl 42500 `"Netherlands"', add
label define bpl_lbl 42600 `"Switzerland"', add
label define bpl_lbl 42900 `"Western Europe, n.s."', add
label define bpl_lbl 43000 `"Albania"', add
label define bpl_lbl 43100 `"Andorra"', add
label define bpl_lbl 43200 `"Gibraltar"', add
label define bpl_lbl 43300 `"Greece"', add
label define bpl_lbl 43310 `"Dodecanese Islands"', add
label define bpl_lbl 43320 `"Turkey Greece"', add
label define bpl_lbl 43330 `"Macedonia"', add
label define bpl_lbl 43400 `"Italy"', add
label define bpl_lbl 43500 `"Malta"', add
label define bpl_lbl 43600 `"Portugal"', add
label define bpl_lbl 43610 `"Azores"', add
label define bpl_lbl 43620 `"Madeira Islands"', add
label define bpl_lbl 43630 `"Cape Verde Islands"', add
label define bpl_lbl 43640 `"St. Miguel"', add
label define bpl_lbl 43700 `"San Marino"', add
label define bpl_lbl 43800 `"Spain"', add
label define bpl_lbl 43900 `"Vatican City"', add
label define bpl_lbl 44000 `"Southern Europe, n.s."', add
label define bpl_lbl 45000 `"Austria"', add
label define bpl_lbl 45010 `"Austria-Hungary"', add
label define bpl_lbl 45020 `"Austria-Graz"', add
label define bpl_lbl 45030 `"Austria-Linz"', add
label define bpl_lbl 45040 `"Austria-Salzburg"', add
label define bpl_lbl 45050 `"Austria-Tyrol"', add
label define bpl_lbl 45060 `"Austria-Vienna"', add
label define bpl_lbl 45070 `"Austria-Kaernten"', add
label define bpl_lbl 45080 `"Austria-Neustadt"', add
label define bpl_lbl 45100 `"Bulgaria"', add
label define bpl_lbl 45200 `"Czechoslovakia"', add
label define bpl_lbl 45210 `"Bohemia"', add
label define bpl_lbl 45211 `"Bohemia-Moravia"', add
label define bpl_lbl 45212 `"Slovakia"', add
label define bpl_lbl 45213 `"Czech Republic"', add
label define bpl_lbl 45300 `"Germany"', add
label define bpl_lbl 45301 `"Berlin"', add
label define bpl_lbl 45302 `"West Berlin"', add
label define bpl_lbl 45303 `"East Berlin"', add
label define bpl_lbl 45310 `"West Germany, n.e.c."', add
label define bpl_lbl 45311 `"Baden"', add
label define bpl_lbl 45312 `"Bavaria"', add
label define bpl_lbl 45313 `"Braunschweig"', add
label define bpl_lbl 45314 `"Bremen"', add
label define bpl_lbl 45315 `"Hamburg"', add
label define bpl_lbl 45316 `"Hanover"', add
label define bpl_lbl 45317 `"Hessen"', add
label define bpl_lbl 45318 `"Hesse-Nassau"', add
label define bpl_lbl 45319 `"Lippe"', add
label define bpl_lbl 45320 `"Lubeck"', add
label define bpl_lbl 45321 `"Oldenburg"', add
label define bpl_lbl 45322 `"Rheinland"', add
label define bpl_lbl 45323 `"Schaumburg-Lippe"', add
label define bpl_lbl 45324 `"Schleswig"', add
label define bpl_lbl 45325 `"Sigmaringen"', add
label define bpl_lbl 45326 `"Schwarzburg"', add
label define bpl_lbl 45327 `"Westphalia"', add
label define bpl_lbl 45328 `"Wurttemberg"', add
label define bpl_lbl 45329 `"Waldeck"', add
label define bpl_lbl 45330 `"Wittenberg"', add
label define bpl_lbl 45331 `"Frankfurt"', add
label define bpl_lbl 45332 `"Saarland"', add
label define bpl_lbl 45333 `"Nordrhein-Westfalen"', add
label define bpl_lbl 45340 `"East Germany, n.e.c."', add
label define bpl_lbl 45341 `"Anhalt"', add
label define bpl_lbl 45342 `"Brandenburg"', add
label define bpl_lbl 45344 `"Kingdom of Saxony"', add
label define bpl_lbl 45345 `"Mecklenburg"', add
label define bpl_lbl 45346 `"Saxony"', add
label define bpl_lbl 45347 `"Thuringian States"', add
label define bpl_lbl 45348 `"Sachsen-Meiningen"', add
label define bpl_lbl 45349 `"Sachsen-Weimar-Eisenach"', add
label define bpl_lbl 45350 `"Probable Saxony"', add
label define bpl_lbl 45351 `"Schwerin"', add
label define bpl_lbl 45352 `"Strelitz"', add
label define bpl_lbl 45353 `"Probably Thuringian States"', add
label define bpl_lbl 45360 `"Prussia, n.e.c."', add
label define bpl_lbl 45361 `"Hohenzollern"', add
label define bpl_lbl 45362 `"Niedersachsen"', add
label define bpl_lbl 45400 `"Hungary"', add
label define bpl_lbl 45500 `"Poland"', add
label define bpl_lbl 45510 `"Austrian Poland"', add
label define bpl_lbl 45511 `"Galicia"', add
label define bpl_lbl 45520 `"German Poland"', add
label define bpl_lbl 45521 `"East Prussia"', add
label define bpl_lbl 45522 `"Pomerania"', add
label define bpl_lbl 45523 `"Posen"', add
label define bpl_lbl 45524 `"Prussian Poland"', add
label define bpl_lbl 45525 `"Silesia"', add
label define bpl_lbl 45526 `"West Prussia"', add
label define bpl_lbl 45530 `"Russian Poland"', add
label define bpl_lbl 45600 `"Romania"', add
label define bpl_lbl 45610 `"Transylvania"', add
label define bpl_lbl 45700 `"Yugoslavia"', add
label define bpl_lbl 45710 `"Croatia"', add
label define bpl_lbl 45720 `"Montenegro"', add
label define bpl_lbl 45730 `"Serbia"', add
label define bpl_lbl 45740 `"Bosnia"', add
label define bpl_lbl 45750 `"Dalmatia"', add
label define bpl_lbl 45760 `"Slovonia"', add
label define bpl_lbl 45770 `"Carniola"', add
label define bpl_lbl 45780 `"Slovenia"', add
label define bpl_lbl 45790 `"Kosovo"', add
label define bpl_lbl 45800 `"Central Europe, n.s."', add
label define bpl_lbl 45900 `"Eastern Europe, n.s."', add
label define bpl_lbl 46000 `"Estonia"', add
label define bpl_lbl 46100 `"Latvia"', add
label define bpl_lbl 46200 `"Lithuania"', add
label define bpl_lbl 46300 `"Baltic States, n.s."', add
label define bpl_lbl 46500 `"Other USSR/"Russi""', add
label define bpl_lbl 46510 `"Byelorussia"', add
label define bpl_lbl 46520 `"Moldavia"', add
label define bpl_lbl 46521 `"Bessarabia"', add
label define bpl_lbl 46530 `"Ukraine"', add
label define bpl_lbl 46540 `"Armenia"', add
label define bpl_lbl 46541 `"Azerbaijan"', add
label define bpl_lbl 46542 `"Republic of Georgia"', add
label define bpl_lbl 46543 `"Kazakhstan"', add
label define bpl_lbl 46544 `"Kirghizia"', add
label define bpl_lbl 46545 `"Tadzhik"', add
label define bpl_lbl 46546 `"Turkmenistan"', add
label define bpl_lbl 46547 `"Uzbekistan"', add
label define bpl_lbl 46548 `"Siberia"', add
label define bpl_lbl 46590 `"USSR, n.s./n.e.c."', add
label define bpl_lbl 49900 `"Europe, n.s."', add
label define bpl_lbl 50000 `"China"', add
label define bpl_lbl 50010 `"Hong Kong"', add
label define bpl_lbl 50020 `"Macau"', add
label define bpl_lbl 50030 `"Mongolia"', add
label define bpl_lbl 50040 `"Taiwan"', add
label define bpl_lbl 50100 `"Japan"', add
label define bpl_lbl 50200 `"Korea"', add
label define bpl_lbl 50210 `"North Korea"', add
label define bpl_lbl 50220 `"South Korea"', add
label define bpl_lbl 50900 `"East Asia, n.s."', add
label define bpl_lbl 51000 `"Brunei"', add
label define bpl_lbl 51100 `"Cambodia (Kampuchea)"', add
label define bpl_lbl 51200 `"Indonesia"', add
label define bpl_lbl 51210 `"East Indies"', add
label define bpl_lbl 51220 `"East Timor"', add
label define bpl_lbl 51300 `"Laos"', add
label define bpl_lbl 51400 `"Malaysia"', add
label define bpl_lbl 51500 `"Philippines"', add
label define bpl_lbl 51600 `"Singapore"', add
label define bpl_lbl 51700 `"Thailand"', add
label define bpl_lbl 51800 `"Vietnam"', add
label define bpl_lbl 51900 `"Southeast Asia, n.s."', add
label define bpl_lbl 51910 `"Indochina, n.s."', add
label define bpl_lbl 52000 `"Afghanistan"', add
label define bpl_lbl 52100 `"India"', add
label define bpl_lbl 52110 `"Bangladesh"', add
label define bpl_lbl 52120 `"Bhutan"', add
label define bpl_lbl 52130 `"Burma (Myanmar)"', add
label define bpl_lbl 52140 `"Pakistan"', add
label define bpl_lbl 52150 `"Sri Lanka (Ceylon)"', add
label define bpl_lbl 52200 `"Iran"', add
label define bpl_lbl 52300 `"Maldives"', add
label define bpl_lbl 52400 `"Nepal"', add
label define bpl_lbl 53000 `"Bahrain"', add
label define bpl_lbl 53100 `"Cyprus"', add
label define bpl_lbl 53200 `"Iraq"', add
label define bpl_lbl 53210 `"Mesopotamia"', add
label define bpl_lbl 53300 `"Iraq/Saudi Arabia"', add
label define bpl_lbl 53400 `"Israel/Palestine"', add
label define bpl_lbl 53410 `"Gaza Strip"', add
label define bpl_lbl 53420 `"Palestine"', add
label define bpl_lbl 53430 `"West Bank"', add
label define bpl_lbl 53440 `"Israel"', add
label define bpl_lbl 53500 `"Jordan"', add
label define bpl_lbl 53600 `"Kuwait"', add
label define bpl_lbl 53700 `"Lebanon"', add
label define bpl_lbl 53800 `"Oman"', add
label define bpl_lbl 53900 `"Qatar"', add
label define bpl_lbl 54000 `"Saudi Arabia"', add
label define bpl_lbl 54100 `"Syria"', add
label define bpl_lbl 54200 `"Turkey"', add
label define bpl_lbl 54210 `"European Turkey"', add
label define bpl_lbl 54220 `"Asian Turkey"', add
label define bpl_lbl 54300 `"United Arab Emirates"', add
label define bpl_lbl 54400 `"Yemen Arab Republic (North)"', add
label define bpl_lbl 54500 `"Yemen, PDR (South)"', add
label define bpl_lbl 54600 `"Persian Gulf States, n.s."', add
label define bpl_lbl 54700 `"Middle East, n.s."', add
label define bpl_lbl 54800 `"Southwest Asia, n.e.c./n.s."', add
label define bpl_lbl 54900 `"Asia Minor, n.s."', add
label define bpl_lbl 55000 `"South Asia, n.e.c."', add
label define bpl_lbl 59900 `"Asia, n.e.c./n.s."', add
label define bpl_lbl 60000 `"AFRICA"', add
label define bpl_lbl 60010 `"Northern Africa"', add
label define bpl_lbl 60011 `"Algeria"', add
label define bpl_lbl 60012 `"Egypt/United Arab Rep."', add
label define bpl_lbl 60013 `"Libya"', add
label define bpl_lbl 60014 `"Morocco"', add
label define bpl_lbl 60015 `"Sudan"', add
label define bpl_lbl 60016 `"Tunisia"', add
label define bpl_lbl 60017 `"Western Sahara"', add
label define bpl_lbl 60019 `"North Africa, n.s."', add
label define bpl_lbl 60020 `"Benin"', add
label define bpl_lbl 60021 `"Burkina Faso"', add
label define bpl_lbl 60022 `"Gambia"', add
label define bpl_lbl 60023 `"Ghana"', add
label define bpl_lbl 60024 `"Guinea"', add
label define bpl_lbl 60025 `"Guinea-Bissau"', add
label define bpl_lbl 60026 `"Ivory Coast"', add
label define bpl_lbl 60027 `"Liberia"', add
label define bpl_lbl 60028 `"Mali"', add
label define bpl_lbl 60029 `"Mauritania"', add
label define bpl_lbl 60030 `"Niger"', add
label define bpl_lbl 60031 `"Nigeria"', add
label define bpl_lbl 60032 `"Senegal"', add
label define bpl_lbl 60033 `"Sierra Leone"', add
label define bpl_lbl 60034 `"Togo"', add
label define bpl_lbl 60038 `"Western Africa, n.s."', add
label define bpl_lbl 60039 `"French West Africa, n.s."', add
label define bpl_lbl 60040 `"British Indian Ocean Territory"', add
label define bpl_lbl 60041 `"Burundi"', add
label define bpl_lbl 60042 `"Comoros"', add
label define bpl_lbl 60043 `"Djibouti"', add
label define bpl_lbl 60044 `"Ethiopia"', add
label define bpl_lbl 60045 `"Kenya"', add
label define bpl_lbl 60046 `"Madagascar"', add
label define bpl_lbl 60047 `"Malawi"', add
label define bpl_lbl 60048 `"Mauritius"', add
label define bpl_lbl 60049 `"Mozambique"', add
label define bpl_lbl 60050 `"Reunion"', add
label define bpl_lbl 60051 `"Rwanda"', add
label define bpl_lbl 60052 `"Seychelles"', add
label define bpl_lbl 60053 `"Somalia"', add
label define bpl_lbl 60054 `"Tanzania"', add
label define bpl_lbl 60055 `"Uganda"', add
label define bpl_lbl 60056 `"Zambia"', add
label define bpl_lbl 60057 `"Zimbabwe"', add
label define bpl_lbl 60058 `"Bassas da India"', add
label define bpl_lbl 60059 `"Europa"', add
label define bpl_lbl 60060 `"Gloriosos"', add
label define bpl_lbl 60061 `"Juan de Nova"', add
label define bpl_lbl 60062 `"Mayotte"', add
label define bpl_lbl 60063 `"Tromelin"', add
label define bpl_lbl 60064 `"Eastern Africa, n.e.c./n.s."', add
label define bpl_lbl 60065 `"Eritrea"', add
label define bpl_lbl 60066 `"South Sudan"', add
label define bpl_lbl 60070 `"Central Africa"', add
label define bpl_lbl 60071 `"Angola"', add
label define bpl_lbl 60072 `"Cameroon"', add
label define bpl_lbl 60073 `"Central African Republic"', add
label define bpl_lbl 60074 `"Chad"', add
label define bpl_lbl 60075 `"Congo"', add
label define bpl_lbl 60076 `"Equatorial Guinea"', add
label define bpl_lbl 60077 `"Gabon"', add
label define bpl_lbl 60078 `"Sao Tome and Principe"', add
label define bpl_lbl 60079 `"Zaire"', add
label define bpl_lbl 60080 `"Central Africa, n.s."', add
label define bpl_lbl 60081 `"Equatorial Africa, n.s."', add
label define bpl_lbl 60082 `"French Equatorial Africa, n.s."', add
label define bpl_lbl 60090 `"Southern Africa"', add
label define bpl_lbl 60091 `"Botswana"', add
label define bpl_lbl 60092 `"Lesotho"', add
label define bpl_lbl 60093 `"Namibia"', add
label define bpl_lbl 60094 `"South Africa (Union of)"', add
label define bpl_lbl 60095 `"Swaziland"', add
label define bpl_lbl 60096 `"Southern Africa, n.s."', add
label define bpl_lbl 60099 `"Africa, n.s./n.e.c."', add
label define bpl_lbl 70000 `"Australia and New Zealand"', add
label define bpl_lbl 70010 `"Australia"', add
label define bpl_lbl 70011 `"Ashmore and Cartier Islands"', add
label define bpl_lbl 70012 `"Coral Sea Islands Territory"', add
label define bpl_lbl 70013 `"Christmas Island"', add
label define bpl_lbl 70014 `"Cocos Islands"', add
label define bpl_lbl 70020 `"New Zealand"', add
label define bpl_lbl 71000 `"Pacific Islands"', add
label define bpl_lbl 71010 `"New Caledonia"', add
label define bpl_lbl 71012 `"Papua New Guinea"', add
label define bpl_lbl 71013 `"Solomon Islands"', add
label define bpl_lbl 71014 `"Vanuatu (New Hebrides)"', add
label define bpl_lbl 71015 `"Fiji"', add
label define bpl_lbl 71016 `"Melanesia, n.s."', add
label define bpl_lbl 71017 `"Norfolk Islands"', add
label define bpl_lbl 71018 `"Niue"', add
label define bpl_lbl 71020 `"Cook Islands"', add
label define bpl_lbl 71022 `"French Polynesia"', add
label define bpl_lbl 71023 `"Tonga"', add
label define bpl_lbl 71024 `"Wallis and Futuna Islands"', add
label define bpl_lbl 71025 `"Western Samoa"', add
label define bpl_lbl 71026 `"Pitcairn Island"', add
label define bpl_lbl 71027 `"Tokelau"', add
label define bpl_lbl 71028 `"Tuvalu"', add
label define bpl_lbl 71029 `"Polynesia, n.s."', add
label define bpl_lbl 71032 `"Kiribati"', add
label define bpl_lbl 71033 `"Canton and Enderbury"', add
label define bpl_lbl 71034 `"Nauru"', add
label define bpl_lbl 71039 `"Micronesia, n.s."', add
label define bpl_lbl 71040 `"US Pacific Trust Territories"', add
label define bpl_lbl 71041 `"Marshall Islands"', add
label define bpl_lbl 71042 `"Micronesia"', add
label define bpl_lbl 71043 `"Kosrae"', add
label define bpl_lbl 71044 `"Pohnpei"', add
label define bpl_lbl 71045 `"Truk"', add
label define bpl_lbl 71046 `"Yap"', add
label define bpl_lbl 71047 `"Northern Mariana Islands"', add
label define bpl_lbl 71048 `"Palau"', add
label define bpl_lbl 71049 `"Pacific Trust Territories, n.s."', add
label define bpl_lbl 71050 `"Clipperton Island"', add
label define bpl_lbl 71090 `"Oceania, n.s./n.e.c."', add
label define bpl_lbl 80000 `"ANTARTICA, n.s./n.e.c."', add
label define bpl_lbl 80010 `"Bouvet Islands"', add
label define bpl_lbl 80020 `"British Antarctic Terr."', add
label define bpl_lbl 80030 `"Dronning Maud Land"', add
label define bpl_lbl 80040 `"French Southern and Antartic Lands"', add
label define bpl_lbl 80050 `"Heard and McDonald Islands"', add
label define bpl_lbl 90000 `"ABROAD (unknown) or at sea"', add
label define bpl_lbl 90010 `"Abroad, n.s."', add
label define bpl_lbl 90011 `"Abroad (US citizen)"', add
label define bpl_lbl 90020 `"At sea"', add
label define bpl_lbl 90021 `"At sea (US citizen)"', add
label define bpl_lbl 90022 `"At sea or abroad (U.S. citizen)"', add
label define bpl_lbl 95000 `"Other n.e.c."', add
label define bpl_lbl 99700 `"Unknown"', add
label define bpl_lbl 99800 `"Illegible"', add
label define bpl_lbl 99900 `"Missing/blank"', add
label values bpl bpl_lbl

label define hispan_lbl 0   `"Not Hispanic"'
label define hispan_lbl 100 `"Mexican"', add
label define hispan_lbl 102 `"Mexican American"', add
label define hispan_lbl 103 `"Mexicano/Mexicana"', add
label define hispan_lbl 104 `"Chicano/Chicana"', add
label define hispan_lbl 105 `"La Raza"', add
label define hispan_lbl 106 `"Mexican American Indian"', add
label define hispan_lbl 107 `"Mexico"', add
label define hispan_lbl 200 `"Puerto Rican"', add
label define hispan_lbl 300 `"Cuban"', add
label define hispan_lbl 401 `"Central American Indian"', add
label define hispan_lbl 402 `"Canal Zone"', add
label define hispan_lbl 411 `"Costa Rican"', add
label define hispan_lbl 412 `"Guatemalan"', add
label define hispan_lbl 413 `"Honduran"', add
label define hispan_lbl 414 `"Nicaraguan"', add
label define hispan_lbl 415 `"Panamanian"', add
label define hispan_lbl 416 `"Salvadoran"', add
label define hispan_lbl 417 `"Central American, n.e.c."', add
label define hispan_lbl 420 `"Argentinean"', add
label define hispan_lbl 421 `"Bolivian"', add
label define hispan_lbl 422 `"Chilean"', add
label define hispan_lbl 423 `"Colombian"', add
label define hispan_lbl 424 `"Ecuadorian"', add
label define hispan_lbl 425 `"Paraguayan"', add
label define hispan_lbl 426 `"Peruvian"', add
label define hispan_lbl 427 `"Uruguayan"', add
label define hispan_lbl 428 `"Venezuelan"', add
label define hispan_lbl 429 `"South American Indian"', add
label define hispan_lbl 430 `"Criollo"', add
label define hispan_lbl 431 `"South American, n.e.c."', add
label define hispan_lbl 450 `"Spaniard"', add
label define hispan_lbl 451 `"Andalusian"', add
label define hispan_lbl 452 `"Asturian"', add
label define hispan_lbl 453 `"Castillian"', add
label define hispan_lbl 454 `"Catalonian"', add
label define hispan_lbl 455 `"Balearic Islander"', add
label define hispan_lbl 456 `"Gallego"', add
label define hispan_lbl 457 `"Valencian"', add
label define hispan_lbl 458 `"Canarian"', add
label define hispan_lbl 459 `"Spanish Basque"', add
label define hispan_lbl 460 `"Dominican"', add
label define hispan_lbl 465 `"Latin American"', add
label define hispan_lbl 470 `"Hispanic"', add
label define hispan_lbl 480 `"Spanish"', add
label define hispan_lbl 490 `"Californio"', add
label define hispan_lbl 491 `"Tejano"', add
label define hispan_lbl 492 `"Nuevo Mexicano"', add
label define hispan_lbl 493 `"Spanish American"', add
label define hispan_lbl 494 `"Spanish American Indian"', add
label define hispan_lbl 495 `"Meso American Indian"', add
label define hispan_lbl 496 `"Mestizo"', add
label define hispan_lbl 498 `"Other, not specified"', add
label define hispan_lbl 499 `"Other, not elsewhere classified"', add
label define hispan_lbl 900 `"Not Reported"', add
label values hispan hispan_lbl

label define spanname_lbl 0 `"N/A"'
label define spanname_lbl 1 `"No, not Spanish surname"', add
label define spanname_lbl 2 `"Yes, Spanish surname"', add
label define spanname_lbl 9 `"Not reported"', add
label values spanname spanname_lbl

label define school_lbl 0 `"N/A"'
label define school_lbl 1 `"No, not in school"', add
label define school_lbl 2 `"Yes, in school"', add
label define school_lbl 7 `"Illegible"', add
label define school_lbl 8 `"Unknown"', add
label define school_lbl 9 `"Missing"', add
label values school school_lbl

label define lit_lbl 0 `"N/A"'
label define lit_lbl 1 `"No, illiterate (cannot read nor write)"', add
label define lit_lbl 2 `"Can't read, can write"', add
label define lit_lbl 3 `"Can't write, can read"', add
label define lit_lbl 4 `"Yes, literate (reads and writes)"', add
label define lit_lbl 9 `"Unknown, illegible or blank"', add
label values lit lit_lbl

label define labforce_lbl 0 `"N/A"'
label define labforce_lbl 1 `"No, not in the labor force"', add
label define labforce_lbl 2 `"Yes, in the labor force"', add
label define labforce_lbl 9 `"Unclassifiable (employment status unknown)"', add
label values labforce labforce_lbl

label define occ1950_lbl 0   `"Accountants and auditors"'
label define occ1950_lbl 1   `"Actors and actresses"', add
label define occ1950_lbl 2   `"Airplane pilots and navigators"', add
label define occ1950_lbl 3   `"Architects"', add
label define occ1950_lbl 4   `"Artists and art teachers"', add
label define occ1950_lbl 5   `"Athletes"', add
label define occ1950_lbl 6   `"Authors"', add
label define occ1950_lbl 7   `"Chemists"', add
label define occ1950_lbl 8   `"Chiropractors"', add
label define occ1950_lbl 9   `"Clergymen"', add
label define occ1950_lbl 10  `"College presidents and deans"', add
label define occ1950_lbl 12  `"Agricultural sciences"', add
label define occ1950_lbl 13  `"Biological sciences"', add
label define occ1950_lbl 14  `"Chemistry"', add
label define occ1950_lbl 15  `"Economics"', add
label define occ1950_lbl 16  `"Engineering"', add
label define occ1950_lbl 17  `"Geology and geophysics"', add
label define occ1950_lbl 18  `"Mathematics"', add
label define occ1950_lbl 19  `"Medical sciences"', add
label define occ1950_lbl 23  `"Physics"', add
label define occ1950_lbl 24  `"Psychology"', add
label define occ1950_lbl 25  `"Statistics"', add
label define occ1950_lbl 26  `"Natural science (n.e.c.)"', add
label define occ1950_lbl 27  `"Social sciences (n.e.c.)"', add
label define occ1950_lbl 28  `"Non-scientific subjects"', add
label define occ1950_lbl 29  `"Subject not specified"', add
label define occ1950_lbl 31  `"Dancers and dancing teachers"', add
label define occ1950_lbl 32  `"Dentists"', add
label define occ1950_lbl 33  `"Designers"', add
label define occ1950_lbl 34  `"Dietitians and nutritionists"', add
label define occ1950_lbl 35  `"Draftsmen"', add
label define occ1950_lbl 36  `"Editors and reporters"', add
label define occ1950_lbl 41  `"Engineers, aeronautical"', add
label define occ1950_lbl 42  `"Engineers, chemical"', add
label define occ1950_lbl 43  `"Engineers, civil"', add
label define occ1950_lbl 44  `"Engineers, electrical"', add
label define occ1950_lbl 45  `"Engineers, industrial"', add
label define occ1950_lbl 46  `"Engineers, mechanical"', add
label define occ1950_lbl 47  `"Engineers, metallurgical, metallurgists"', add
label define occ1950_lbl 48  `"Engineers, mining"', add
label define occ1950_lbl 49  `"Engineers (n.e.c.)"', add
label define occ1950_lbl 51  `"Entertainers (n.e.c.)"', add
label define occ1950_lbl 52  `"Farm and home management advisors"', add
label define occ1950_lbl 53  `"Foresters and conservationists"', add
label define occ1950_lbl 54  `"Funeral directors and embalmers"', add
label define occ1950_lbl 55  `"Lawyers and judges"', add
label define occ1950_lbl 56  `"Librarians"', add
label define occ1950_lbl 57  `"Musicians and music teachers"', add
label define occ1950_lbl 58  `"Nurses, professional"', add
label define occ1950_lbl 59  `"Nurses, student professional"', add
label define occ1950_lbl 61  `"Agricultural scientists"', add
label define occ1950_lbl 62  `"Biological scientists"', add
label define occ1950_lbl 63  `"Geologists and geophysicists"', add
label define occ1950_lbl 67  `"Mathematicians"', add
label define occ1950_lbl 68  `"Physicists"', add
label define occ1950_lbl 69  `"Miscellaneous natural scientists"', add
label define occ1950_lbl 70  `"Optometrists"', add
label define occ1950_lbl 71  `"Osteopaths"', add
label define occ1950_lbl 72  `"Personnel and labor relations workers"', add
label define occ1950_lbl 73  `"Pharmacists"', add
label define occ1950_lbl 74  `"Photographers"', add
label define occ1950_lbl 75  `"Physicians and surgeons"', add
label define occ1950_lbl 76  `"Radio operators"', add
label define occ1950_lbl 77  `"Recreation and group workers"', add
label define occ1950_lbl 78  `"Religious workers"', add
label define occ1950_lbl 79  `"Social and welfare workers, except group"', add
label define occ1950_lbl 81  `"Economists"', add
label define occ1950_lbl 82  `"Psychologists"', add
label define occ1950_lbl 83  `"Statisticians and actuaries"', add
label define occ1950_lbl 84  `"Miscellaneous social scientists"', add
label define occ1950_lbl 91  `"Sports instructors and officials"', add
label define occ1950_lbl 92  `"Surveyors"', add
label define occ1950_lbl 93  `"Teachers (n.e.c.)"', add
label define occ1950_lbl 94  `"Technicians, medical and dental"', add
label define occ1950_lbl 95  `"Technicians, testing"', add
label define occ1950_lbl 96  `"Technicians (n.e.c.)"', add
label define occ1950_lbl 97  `"Therapists and healers (n.e.c.)"', add
label define occ1950_lbl 98  `"Veterinarians"', add
label define occ1950_lbl 99  `"Professional, technical and kindred workers (n.e.c.)"', add
label define occ1950_lbl 100 `"Farmers (owners and tenants)"', add
label define occ1950_lbl 123 `"Farm managers"', add
label define occ1950_lbl 200 `"Buyers and department heads, store"', add
label define occ1950_lbl 201 `"Buyers and shippers, farm products"', add
label define occ1950_lbl 203 `"Conductors, railroad"', add
label define occ1950_lbl 204 `"Credit men"', add
label define occ1950_lbl 205 `"Floormen and floor managers, store"', add
label define occ1950_lbl 210 `"Inspectors, public administration"', add
label define occ1950_lbl 230 `"Managers and superintendents, building"', add
label define occ1950_lbl 240 `"Officers, pilots, pursers and engineers, ship"', add
label define occ1950_lbl 250 `"Officials and administrators (n.e.c.), public administration"', add
label define occ1950_lbl 260 `"Officials, lodge, society, union, etc."', add
label define occ1950_lbl 270 `"Postmasters"', add
label define occ1950_lbl 280 `"Purchasing agents and buyers (n.e.c.)"', add
label define occ1950_lbl 290 `"Managers, officials, and proprietors (n.e.c.)"', add
label define occ1950_lbl 300 `"Agents (n.e.c.)"', add
label define occ1950_lbl 301 `"Attendants and assistants, library"', add
label define occ1950_lbl 302 `"Attendants, physician's and dentist's office"', add
label define occ1950_lbl 304 `"Baggagemen, transportation"', add
label define occ1950_lbl 305 `"Bank tellers"', add
label define occ1950_lbl 310 `"Bookkeepers"', add
label define occ1950_lbl 320 `"Cashiers"', add
label define occ1950_lbl 321 `"Collectors, bill and account"', add
label define occ1950_lbl 322 `"Dispatchers and starters, vehicle"', add
label define occ1950_lbl 325 `"Express messengers and railway mail clerks"', add
label define occ1950_lbl 335 `"Mail carriers"', add
label define occ1950_lbl 340 `"Messengers and office boys"', add
label define occ1950_lbl 341 `"Office machine operators"', add
label define occ1950_lbl 342 `"Shipping and receiving clerks"', add
label define occ1950_lbl 350 `"Stenographers, typists, and secretaries"', add
label define occ1950_lbl 360 `"Telegraph messengers"', add
label define occ1950_lbl 365 `"Telegraph operators"', add
label define occ1950_lbl 370 `"Telephone operators"', add
label define occ1950_lbl 380 `"Ticket, station, and express agents"', add
label define occ1950_lbl 390 `"Clerical and kindred workers (n.e.c.)"', add
label define occ1950_lbl 400 `"Advertising agents and salesmen"', add
label define occ1950_lbl 410 `"Auctioneers"', add
label define occ1950_lbl 420 `"Demonstrators"', add
label define occ1950_lbl 430 `"Hucksters and peddlers"', add
label define occ1950_lbl 450 `"Insurance agents and brokers"', add
label define occ1950_lbl 460 `"Newsboys"', add
label define occ1950_lbl 470 `"Real estate agents and brokers"', add
label define occ1950_lbl 480 `"Stock and bond salesmen"', add
label define occ1950_lbl 490 `"Salesmen and sales clerks (n.e.c.)"', add
label define occ1950_lbl 500 `"Bakers"', add
label define occ1950_lbl 501 `"Blacksmiths"', add
label define occ1950_lbl 502 `"Bookbinders"', add
label define occ1950_lbl 503 `"Boilermakers"', add
label define occ1950_lbl 504 `"Brickmasons, stonemasons, and tile setters"', add
label define occ1950_lbl 505 `"Cabinetmakers"', add
label define occ1950_lbl 510 `"Carpenters"', add
label define occ1950_lbl 511 `"Cement and concrete finishers"', add
label define occ1950_lbl 512 `"Compositors and typesetters"', add
label define occ1950_lbl 513 `"Cranemen, derrickmen, and hoistmen"', add
label define occ1950_lbl 514 `"Decorators and window dressers"', add
label define occ1950_lbl 515 `"Electricians"', add
label define occ1950_lbl 520 `"Electrotypers and stereotypers"', add
label define occ1950_lbl 521 `"Engravers, except photoengravers"', add
label define occ1950_lbl 522 `"Excavating, grading, and road machinery operators"', add
label define occ1950_lbl 523 `"Foremen (n.e.c.)"', add
label define occ1950_lbl 524 `"Forgemen and hammermen"', add
label define occ1950_lbl 525 `"Furriers"', add
label define occ1950_lbl 530 `"Glaziers"', add
label define occ1950_lbl 531 `"Heat treaters, annealers, temperers"', add
label define occ1950_lbl 532 `"Inspectors, scalers, and graders, log and lumber"', add
label define occ1950_lbl 533 `"Inspectors (n.e.c.)"', add
label define occ1950_lbl 534 `"Jewelers, watchmakers, goldsmiths, and silversmiths"', add
label define occ1950_lbl 535 `"Job setters, metal"', add
label define occ1950_lbl 540 `"Linemen and servicemen, telegraph, telephone, and power"', add
label define occ1950_lbl 541 `"Locomotive engineers"', add
label define occ1950_lbl 542 `"Locomotive firemen"', add
label define occ1950_lbl 543 `"Loom fixers"', add
label define occ1950_lbl 544 `"Machinists"', add
label define occ1950_lbl 545 `"Mechanics and repairmen, airplane"', add
label define occ1950_lbl 550 `"Mechanics and repairmen, automobile"', add
label define occ1950_lbl 551 `"Mechanics and repairmen, office machine"', add
label define occ1950_lbl 552 `"Mechanics and repairmen, radio and television"', add
label define occ1950_lbl 553 `"Mechanics and repairmen, railroad and car shop"', add
label define occ1950_lbl 554 `"Mechanics and repairmen (n.e.c.)"', add
label define occ1950_lbl 555 `"Millers, grain, flour, feed, etc."', add
label define occ1950_lbl 560 `"Millwrights"', add
label define occ1950_lbl 561 `"Molders, metal"', add
label define occ1950_lbl 562 `"Motion picture projectionists"', add
label define occ1950_lbl 563 `"Opticians and lens grinders and polishers"', add
label define occ1950_lbl 564 `"Painters, construction and maintenance"', add
label define occ1950_lbl 565 `"Paperhangers"', add
label define occ1950_lbl 570 `"Pattern and model makers, except paper"', add
label define occ1950_lbl 571 `"Photoengravers and lithographers"', add
label define occ1950_lbl 572 `"Piano and organ tuners and repairmen"', add
label define occ1950_lbl 573 `"Plasterers"', add
label define occ1950_lbl 574 `"Plumbers and pipe fitters"', add
label define occ1950_lbl 575 `"Pressmen and plate printers, printing"', add
label define occ1950_lbl 580 `"Rollers and roll hands, metal"', add
label define occ1950_lbl 581 `"Roofers and slaters"', add
label define occ1950_lbl 582 `"Shoemakers and repairers, except factory"', add
label define occ1950_lbl 583 `"Stationary engineers"', add
label define occ1950_lbl 584 `"Stone cutters and stone carvers"', add
label define occ1950_lbl 585 `"Structural metal workers"', add
label define occ1950_lbl 590 `"Tailors and tailoresses"', add
label define occ1950_lbl 591 `"Tinsmiths, coppersmiths, and sheet metal workers"', add
label define occ1950_lbl 592 `"Tool makers, and die makers and setters"', add
label define occ1950_lbl 593 `"Upholsterers"', add
label define occ1950_lbl 594 `"Craftsmen and kindred workers (n.e.c.)"', add
label define occ1950_lbl 595 `"Members of the armed services"', add
label define occ1950_lbl 600 `"Apprentice auto mechanics"', add
label define occ1950_lbl 601 `"Apprentice bricklayers and masons"', add
label define occ1950_lbl 602 `"Apprentice carpenters"', add
label define occ1950_lbl 603 `"Apprentice electricians"', add
label define occ1950_lbl 604 `"Apprentice machinists and toolmakers"', add
label define occ1950_lbl 605 `"Apprentice mechanics, except auto"', add
label define occ1950_lbl 610 `"Apprentice plumbers and pipe fitters"', add
label define occ1950_lbl 611 `"Apprentices, building trades (n.e.c.)"', add
label define occ1950_lbl 612 `"Apprentices, metalworking trades (n.e.c.)"', add
label define occ1950_lbl 613 `"Apprentices, printing trades"', add
label define occ1950_lbl 614 `"Apprentices, other specified trades"', add
label define occ1950_lbl 615 `"Apprentices, trade not specified"', add
label define occ1950_lbl 620 `"Asbestos and insulation workers"', add
label define occ1950_lbl 621 `"Attendants, auto service and parking"', add
label define occ1950_lbl 622 `"Blasters and powdermen"', add
label define occ1950_lbl 623 `"Boatmen, canalmen, and lock keepers"', add
label define occ1950_lbl 624 `"Brakemen, railroad"', add
label define occ1950_lbl 625 `"Bus drivers"', add
label define occ1950_lbl 630 `"Chainmen, rodmen, and axmen, surveying"', add
label define occ1950_lbl 631 `"Conductors, bus and street railway"', add
label define occ1950_lbl 632 `"Deliverymen and routemen"', add
label define occ1950_lbl 633 `"Dressmakers and seamstresses, except factory"', add
label define occ1950_lbl 634 `"Dyers"', add
label define occ1950_lbl 635 `"Filers, grinders, and polishers, metal"', add
label define occ1950_lbl 640 `"Fruit, nut, and vegetable graders, and packers, except factory"', add
label define occ1950_lbl 641 `"Furnacemen, smeltermen and pourers"', add
label define occ1950_lbl 642 `"Heaters, metal"', add
label define occ1950_lbl 643 `"Laundry and dry cleaning operatives"', add
label define occ1950_lbl 644 `"Meat cutters, except slaughter and packing house"', add
label define occ1950_lbl 645 `"Milliners"', add
label define occ1950_lbl 650 `"Mine operatives and laborers"', add
label define occ1950_lbl 660 `"Motormen, mine, factory, logging camp, etc."', add
label define occ1950_lbl 661 `"Motormen, street, subway, and elevated railway"', add
label define occ1950_lbl 662 `"Oilers and greaser, except auto"', add
label define occ1950_lbl 670 `"Painters, except construction or maintenance"', add
label define occ1950_lbl 671 `"Photographic process workers"', add
label define occ1950_lbl 672 `"Power station operators"', add
label define occ1950_lbl 673 `"Sailors and deck hands"', add
label define occ1950_lbl 674 `"Sawyers"', add
label define occ1950_lbl 675 `"Spinners, textile"', add
label define occ1950_lbl 680 `"Stationary firemen"', add
label define occ1950_lbl 681 `"Switchmen, railroad"', add
label define occ1950_lbl 682 `"Taxicab drivers and chauffers"', add
label define occ1950_lbl 683 `"Truck and tractor drivers"', add
label define occ1950_lbl 684 `"Weavers, textile"', add
label define occ1950_lbl 685 `"Welders and flame cutters"', add
label define occ1950_lbl 690 `"Operative and kindred workers (n.e.c.)"', add
label define occ1950_lbl 700 `"Housekeepers, private household"', add
label define occ1950_lbl 710 `"Laundresses, private household"', add
label define occ1950_lbl 720 `"Private household workers (n.e.c.)"', add
label define occ1950_lbl 725 `"[holding category for 1860/70 "domestic"]"', add
label define occ1950_lbl 730 `"Attendants, hospital and other institution"', add
label define occ1950_lbl 731 `"Attendants, professional and personal service (n.e.c.)"', add
label define occ1950_lbl 732 `"Attendants, recreation and amusement"', add
label define occ1950_lbl 740 `"Barbers, beauticians, and manicurists"', add
label define occ1950_lbl 750 `"Bartenders"', add
label define occ1950_lbl 751 `"Bootblacks"', add
label define occ1950_lbl 752 `"Boarding and lodging house keepers"', add
label define occ1950_lbl 753 `"Charwomen and cleaners"', add
label define occ1950_lbl 754 `"Cooks, except private household"', add
label define occ1950_lbl 760 `"Counter and fountain workers"', add
label define occ1950_lbl 761 `"Elevator operators"', add
label define occ1950_lbl 762 `"Firemen, fire protection"', add
label define occ1950_lbl 763 `"Guards, watchmen, and doorkeepers"', add
label define occ1950_lbl 764 `"Housekeepers and stewards, except private household"', add
label define occ1950_lbl 770 `"Janitors and sextons"', add
label define occ1950_lbl 771 `"Marshals and constables"', add
label define occ1950_lbl 772 `"Midwives"', add
label define occ1950_lbl 773 `"Policemen and detectives"', add
label define occ1950_lbl 780 `"Porters"', add
label define occ1950_lbl 781 `"Practical nurses"', add
label define occ1950_lbl 782 `"Sheriffs and bailiffs"', add
label define occ1950_lbl 783 `"Ushers, recreation and amusement"', add
label define occ1950_lbl 784 `"Waiters and waitresses"', add
label define occ1950_lbl 785 `"Watchmen (crossing) and bridge tenders"', add
label define occ1950_lbl 790 `"Service workers, except private household (n.e.c.)"', add
label define occ1950_lbl 810 `"Farm foremen"', add
label define occ1950_lbl 820 `"Farm laborers, wage workers"', add
label define occ1950_lbl 830 `"Farm laborers, unpaid family workers"', add
label define occ1950_lbl 840 `"Farm service laborers, self-employed"', add
label define occ1950_lbl 910 `"Fishermen and oystermen"', add
label define occ1950_lbl 920 `"Garage laborers and car washers and greasers"', add
label define occ1950_lbl 930 `"Gardeners, except farm and groundskeepers"', add
label define occ1950_lbl 940 `"Longshoremen and stevedores"', add
label define occ1950_lbl 950 `"Lumbermen, raftsmen, and woodchoppers"', add
label define occ1950_lbl 960 `"Teamsters"', add
label define occ1950_lbl 970 `"Laborers (n.e.c.)"', add
label define occ1950_lbl 975 `"Works, occupation undetermined"', add
label define occ1950_lbl 979 `"Not yet classified"', add
label define occ1950_lbl 980 `"Keeps house/housekeeping at home/housewife"', add
label define occ1950_lbl 981 `"Imputed keeping house (1850-1900)"', add
label define occ1950_lbl 982 `"Helping at home/helps parents/housework"', add
label define occ1950_lbl 983 `"At school/student"', add
label define occ1950_lbl 984 `"Retired"', add
label define occ1950_lbl 985 `"Unemployed/without occupation"', add
label define occ1950_lbl 986 `"Invalid/disabled w/ no occupation reported"', add
label define occ1950_lbl 987 `"Inmate"', add
label define occ1950_lbl 990 `"New Worker"', add
label define occ1950_lbl 991 `"Gentleman/lady/at leisure"', add
label define occ1950_lbl 995 `"Other non-occupational response"', add
label define occ1950_lbl 996 `"Illegible"', add
label define occ1950_lbl 997 `"Occupation missing/unknown"', add
label define occ1950_lbl 998 `"Illegible"', add
label define occ1950_lbl 999 `"N/A (blank)"', add
label values occ1950 occ1950_lbl

label define sei_lbl 78 `"Accountants and auditors"'
label define sei_lbl 60 `"Actors and actresses"', add
label define sei_lbl 79 `"Airplane pilots and navigators"', add
label define sei_lbl 90 `"Architects"', add
label define sei_lbl 67 `"Artists and art teachers"', add
label define sei_lbl 52 `"Athletes"', add
label define sei_lbl 76 `"Authors"', add
label define sei_lbl 75 `"Chiropractors"', add
label define sei_lbl 84 `"College presidents and deans"', add
label define sei_lbl 45 `"Dancers and dancing teachers"', add
label define sei_lbl 96 `"Dentists"', add
label define sei_lbl 73 `"Designers"', add
label define sei_lbl 39 `"Dieticians and nutritionists"', add
label define sei_lbl 82 `"Editors and reporters"', add
label define sei_lbl 87 `"Engineers, aeronautical"', add
label define sei_lbl 86 `"Engineers, industrial"', add
label define sei_lbl 85 `"Engineers, mining"', add
label define sei_lbl 31 `"Entertainers (n.e.c.)"', add
label define sei_lbl 83 `"Farm and home management advisors"', add
label define sei_lbl 48 `"Foresters and conservationists"', add
label define sei_lbl 59 `"Funeral directors and embalmers"', add
label define sei_lbl 93 `"Lawyers and judges"', add
label define sei_lbl 46 `"Nurses, professional"', add
label define sei_lbl 51 `"Nurses, student professional"', add
label define sei_lbl 80 `"Agricultural scientists"', add
label define sei_lbl 50 `"Photographers"', add
label define sei_lbl 92 `"Physicians and surgeons"', add
label define sei_lbl 69 `"Radio operators"', add
label define sei_lbl 56 `"Religious workers"', add
label define sei_lbl 64 `"Social and welfare workers, except group"', add
label define sei_lbl 81 `"Economists"', add
label define sei_lbl 72 `"Teachers (n.e.c.)"', add
label define sei_lbl 53 `"Technicians, testing"', add
label define sei_lbl 62 `"Technicians (n.e.c.)"', add
label define sei_lbl 58 `"Therapists and healers (n.e.c.)"', add
label define sei_lbl 65 `"Professional, technical and kindred workers (n.e.c.)"', add
label define sei_lbl 14 `"Farmers (owners and tenants)"', add
label define sei_lbl 36 `"Farm managers"', add
label define sei_lbl 33 `"Buyers and shippers, farm products"', add
label define sei_lbl 74 `"Credit men"', add
label define sei_lbl 63 `"Inspectors, public administration"', add
label define sei_lbl 32 `"Managers and superintendents, building"', add
label define sei_lbl 54 `"Officers, pilots, pursers and engineers, ship"', add
label define sei_lbl 66 `"Officials and administrators (n.e.c.), public administration"', add
label define sei_lbl 77 `"Purchasing agents and buyers (n.e.c.)"', add
label define sei_lbl 68 `"Managers, officials, and proprietors (n.e.c.)"', add
label define sei_lbl 44 `"Attendants and assistants, library"', add
label define sei_lbl 38 `"Attendants, physician's and dentist's office"', add
label define sei_lbl 25 `"Baggagemen, transportation"', add
label define sei_lbl 40 `"Dispatchers and starters, vehicle"', add
label define sei_lbl 28 `"Messengers and office boys"', add
label define sei_lbl 22 `"Shipping and receiving clerks"', add
label define sei_lbl 61 `"Stenographers, typists, and secretaries"', add
label define sei_lbl 47 `"Telegraph operators"', add
label define sei_lbl 35 `"Demonstrators"', add
label define sei_lbl 8  `"Hucksters and peddlers"', add
label define sei_lbl 27 `"Newsboys"', add
label define sei_lbl 16 `"Blacksmiths"', add
label define sei_lbl 23 `"Cabinetmakers"', add
label define sei_lbl 19 `"Carpenters"', add
label define sei_lbl 21 `"Cranemen, derrickmen, and hoistmen"', add
label define sei_lbl 55 `"Electrotypers and stereotypers"', add
label define sei_lbl 24 `"Excavating, grading, and road machinery operators"', add
label define sei_lbl 49 `"Foremen (n.e.c.)"', add
label define sei_lbl 26 `"Glaziers"', add
label define sei_lbl 41 `"Inspectors (n.e.c.)"', add
label define sei_lbl 10 `"Loom fixers"', add
label define sei_lbl 12 `"Molders, metal"', add
label define sei_lbl 43 `"Motion picture projectionists"', add
label define sei_lbl 34 `"Plumbers and pipe fitters"', add
label define sei_lbl 15 `"Roofers and slaters"', add
label define sei_lbl 18 `"Members of the armed services"', add
label define sei_lbl 37 `"Apprentice electricians"', add
label define sei_lbl 29 `"Apprentices, building trades (n.e.c.)"', add
label define sei_lbl 11 `"Blasters and powdermen"', add
label define sei_lbl 42 `"Brakemen, railroad"', add
label define sei_lbl 30 `"Conductors, bus and street railway"', add
label define sei_lbl 3  `"Motormen, mine, factory, logging camp, etc."', add
label define sei_lbl 5  `"Sawyers"', add
label define sei_lbl 17 `"Stationary firemen"', add
label define sei_lbl 6  `"Weavers, textile"', add
label define sei_lbl 7  `"Private household workers (n.e.c.)"', add
label define sei_lbl 13 `"Attendants, hospital and other institution"', add
label define sei_lbl 9  `"Janitors and sextons"', add
label define sei_lbl 4  `"Porters"', add
label define sei_lbl 20 `"Farm foremen"', add
label define sei_lbl 0  `"No occupation or unclassifiable:"', add
label values sei sei_lbl

label define ind1950_lbl 0   `"N/A or none reported"'
label define ind1950_lbl 105 `"Agriculture"', add
label define ind1950_lbl 116 `"Forestry"', add
label define ind1950_lbl 126 `"Fisheries"', add
label define ind1950_lbl 206 `"Metal mining"', add
label define ind1950_lbl 216 `"Coal mining"', add
label define ind1950_lbl 226 `"Crude petroleum and natural gas extraction"', add
label define ind1950_lbl 236 `"Nonmetallic mining and quarrying, except fuel"', add
label define ind1950_lbl 239 `"Mining, not specified"', add
label define ind1950_lbl 246 `"Construction"', add
label define ind1950_lbl 306 `"Logging"', add
label define ind1950_lbl 307 `"Sawmills, planing mills, and mill work"', add
label define ind1950_lbl 308 `"Miscellaneous wood products"', add
label define ind1950_lbl 309 `"Furniture and fixtures"', add
label define ind1950_lbl 316 `"Glass and glass products"', add
label define ind1950_lbl 317 `"Cement, concrete, gypsum and plaster products"', add
label define ind1950_lbl 318 `"Structural clay products"', add
label define ind1950_lbl 319 `"Pottery and related products"', add
label define ind1950_lbl 326 `"Miscellaneous nonmetallic mineral and stone products"', add
label define ind1950_lbl 336 `"Blast furnaces, steel works, and rolling mills"', add
label define ind1950_lbl 337 `"Other primary iron and steel industries"', add
label define ind1950_lbl 338 `"Primary nonferrous industries"', add
label define ind1950_lbl 346 `"Fabricated steel products"', add
label define ind1950_lbl 347 `"Fabricated nonferrous metal products"', add
label define ind1950_lbl 348 `"Not specified metal industries"', add
label define ind1950_lbl 356 `"Agricultural machinery and tractors"', add
label define ind1950_lbl 357 `"Office and store machines and devices"', add
label define ind1950_lbl 358 `"Miscellaneous machinery"', add
label define ind1950_lbl 367 `"Electrical machinery, equipment, and supplies"', add
label define ind1950_lbl 376 `"Motor vehicles and motor vehicle equipment"', add
label define ind1950_lbl 377 `"Aircraft and parts"', add
label define ind1950_lbl 378 `"Ship and boat building and repairing"', add
label define ind1950_lbl 379 `"Railroad and miscellaneous transportation equipment"', add
label define ind1950_lbl 386 `"Professional equipment and supplies"', add
label define ind1950_lbl 387 `"Photographic equipment and supplies"', add
label define ind1950_lbl 388 `"Watches, clocks, and clockwork-operated devices"', add
label define ind1950_lbl 399 `"Miscellaneous manufacturing industries"', add
label define ind1950_lbl 406 `"Meat products"', add
label define ind1950_lbl 407 `"Dairy products"', add
label define ind1950_lbl 408 `"Canning and preserving fruits, vegetables, and seafoods"', add
label define ind1950_lbl 409 `"Grain-mill products"', add
label define ind1950_lbl 416 `"Bakery products"', add
label define ind1950_lbl 417 `"Confectionery and related products"', add
label define ind1950_lbl 418 `"Beverage industries"', add
label define ind1950_lbl 419 `"Miscellaneous food preparations and kindred products"', add
label define ind1950_lbl 426 `"Not specified food industries"', add
label define ind1950_lbl 429 `"Tobacco manufactures"', add
label define ind1950_lbl 436 `"Knitting mills"', add
label define ind1950_lbl 437 `"Dyeing and finishing textiles, except knit goods"', add
label define ind1950_lbl 438 `"Carpets, rugs, and other floor coverings"', add
label define ind1950_lbl 439 `"Yarn, thread, and fabric mills"', add
label define ind1950_lbl 446 `"Miscellaneous textile mill products"', add
label define ind1950_lbl 448 `"Apparel and accessories"', add
label define ind1950_lbl 449 `"Miscellaneous fabricated textile products"', add
label define ind1950_lbl 456 `"Pulp, paper, and paperboard mills"', add
label define ind1950_lbl 457 `"Paperboard containers and boxes"', add
label define ind1950_lbl 458 `"Miscellaneous paper and pulp products"', add
label define ind1950_lbl 459 `"Printing, publishing, and allied industries"', add
label define ind1950_lbl 466 `"Synthetic fibers"', add
label define ind1950_lbl 467 `"Drugs and medicines"', add
label define ind1950_lbl 468 `"Paints, varnishes, and related products"', add
label define ind1950_lbl 469 `"Miscellaneous chemicals and allied products"', add
label define ind1950_lbl 476 `"Petroleum refining"', add
label define ind1950_lbl 477 `"Miscellaneous petroleum and coal products"', add
label define ind1950_lbl 478 `"Rubber products"', add
label define ind1950_lbl 487 `"Leather: tanned, curried, and finished"', add
label define ind1950_lbl 488 `"Footwear, except rubber"', add
label define ind1950_lbl 489 `"Leather products, except footwear"', add
label define ind1950_lbl 499 `"Not specified manufacturing industries"', add
label define ind1950_lbl 506 `"Railroads and railway express service"', add
label define ind1950_lbl 516 `"Street railways and bus lines"', add
label define ind1950_lbl 526 `"Trucking service"', add
label define ind1950_lbl 527 `"Warehousing and storage"', add
label define ind1950_lbl 536 `"Taxicab service"', add
label define ind1950_lbl 546 `"Water transportation"', add
label define ind1950_lbl 556 `"Air transportation"', add
label define ind1950_lbl 567 `"Petroleum and gasoline pipe lines"', add
label define ind1950_lbl 568 `"Services incidental to transportation"', add
label define ind1950_lbl 578 `"Telephone"', add
label define ind1950_lbl 579 `"Telegraph"', add
label define ind1950_lbl 586 `"Electric light and power"', add
label define ind1950_lbl 587 `"Gas and steam supply systems"', add
label define ind1950_lbl 588 `"Electric-gas utilities"', add
label define ind1950_lbl 596 `"Water supply"', add
label define ind1950_lbl 597 `"Sanitary services"', add
label define ind1950_lbl 598 `"Other and not specified utilities"', add
label define ind1950_lbl 606 `"Motor vehicles and equipment"', add
label define ind1950_lbl 607 `"Drugs, chemicals, and allied products"', add
label define ind1950_lbl 608 `"Dry goods apparel"', add
label define ind1950_lbl 609 `"Food and related products"', add
label define ind1950_lbl 616 `"Electrical goods, hardware, and plumbing equipment"', add
label define ind1950_lbl 617 `"Machinery, equipment, and supplies"', add
label define ind1950_lbl 618 `"Petroleum products"', add
label define ind1950_lbl 619 `"Farm products--raw materials"', add
label define ind1950_lbl 626 `"Miscellaneous wholesale trade"', add
label define ind1950_lbl 627 `"Not specified wholesale trade"', add
label define ind1950_lbl 636 `"Food stores, except dairy products"', add
label define ind1950_lbl 637 `"Dairy products stores and milk retailing"', add
label define ind1950_lbl 646 `"General merchandise stores"', add
label define ind1950_lbl 647 `"Five and ten cent stores"', add
label define ind1950_lbl 656 `"Apparel and accessories stores, except shoe"', add
label define ind1950_lbl 657 `"Shoe stores"', add
label define ind1950_lbl 658 `"Furniture and house furnishing stores"', add
label define ind1950_lbl 659 `"Household appliance and radio stores"', add
label define ind1950_lbl 667 `"Motor vehicles and accessories retailing"', add
label define ind1950_lbl 668 `"Gasoline service stations"', add
label define ind1950_lbl 669 `"Drug stores"', add
label define ind1950_lbl 679 `"Eating and drinking places"', add
label define ind1950_lbl 686 `"Hardware and farm implement stores"', add
label define ind1950_lbl 687 `"Lumber and building material retailing"', add
label define ind1950_lbl 688 `"Liquor stores"', add
label define ind1950_lbl 689 `"Retail florists"', add
label define ind1950_lbl 696 `"Jewelry stores"', add
label define ind1950_lbl 697 `"Fuel and ice retailing"', add
label define ind1950_lbl 698 `"Miscellaneous retail stores"', add
label define ind1950_lbl 699 `"Not specified retail trade"', add
label define ind1950_lbl 716 `"Banking and credit agencies"', add
label define ind1950_lbl 726 `"Security and commodity brokerage and investment companies"', add
label define ind1950_lbl 736 `"Insurance"', add
label define ind1950_lbl 746 `"Real estate"', add
label define ind1950_lbl 756 `"Real estate-insurance-law offices"', add
label define ind1950_lbl 806 `"Advertising"', add
label define ind1950_lbl 807 `"Accounting, auditing, and bookkeeping services"', add
label define ind1950_lbl 808 `"Miscellaneous business services"', add
label define ind1950_lbl 816 `"Auto repair services and garages"', add
label define ind1950_lbl 817 `"Miscellaneous repair services"', add
label define ind1950_lbl 826 `"Private households"', add
label define ind1950_lbl 836 `"Hotels and lodging places"', add
label define ind1950_lbl 846 `"Laundering, cleaning, and dyeing services"', add
label define ind1950_lbl 847 `"Dressmaking shops"', add
label define ind1950_lbl 848 `"Shoe repair shops"', add
label define ind1950_lbl 849 `"Miscellaneous personal services"', add
label define ind1950_lbl 856 `"Radio broadcasting and television"', add
label define ind1950_lbl 857 `"Theaters and motion pictures"', add
label define ind1950_lbl 858 `"Bowling alleys, and billiard and pool parlors"', add
label define ind1950_lbl 859 `"Miscellaneous entertainment and recreation services"', add
label define ind1950_lbl 868 `"Medical and other health services, except hospitals"', add
label define ind1950_lbl 869 `"Hospitals"', add
label define ind1950_lbl 879 `"Legal services"', add
label define ind1950_lbl 888 `"Educational services"', add
label define ind1950_lbl 896 `"Welfare and religious services"', add
label define ind1950_lbl 897 `"Nonprofit membership organizations"', add
label define ind1950_lbl 898 `"Engineering and architectural services"', add
label define ind1950_lbl 899 `"Miscellaneous professional and related services"', add
label define ind1950_lbl 906 `"Postal service"', add
label define ind1950_lbl 916 `"Federal public administration"', add
label define ind1950_lbl 926 `"State public administration"', add
label define ind1950_lbl 936 `"Local public administration"', add
label define ind1950_lbl 946 `"Public Administration, level not specified"', add
label define ind1950_lbl 976 `"Common or general laborer"', add
label define ind1950_lbl 979 `"Not yet specified"', add
label define ind1950_lbl 980 `"Unpaid domestic work"', add
label define ind1950_lbl 982 `"Housework at home"', add
label define ind1950_lbl 983 `"School response (students, etc.)"', add
label define ind1950_lbl 984 `"Retired"', add
label define ind1950_lbl 986 `"Sick/disabled"', add
label define ind1950_lbl 987 `"Institution response"', add
label define ind1950_lbl 991 `"Lady/Man of leisure"', add
label define ind1950_lbl 995 `"Non-industrial response"', add
label define ind1950_lbl 997 `"Nonclassifiable"', add
label define ind1950_lbl 998 `"Industry not reported"', add
label define ind1950_lbl 999 `"Blank or blank equivalent"', add
label values ind1950 ind1950_lbl

label define realprop_lbl 999997 `"Topcode"'
label define realprop_lbl 999998 `"Unknown / Illegible"', add
label values realprop realprop_lbl

label define imppop_lbl 0  `"0"'
label define imppop_lbl 1  `"1"', add
label define imppop_lbl 2  `"2"', add
label define imppop_lbl 3  `"3"', add
label define imppop_lbl 4  `"4"', add
label define imppop_lbl 5  `"5"', add
label define imppop_lbl 6  `"6"', add
label define imppop_lbl 7  `"7"', add
label define imppop_lbl 8  `"8"', add
label define imppop_lbl 9  `"9"', add
label define imppop_lbl 10 `"10"', add
label define imppop_lbl 11 `"11"', add
label define imppop_lbl 12 `"12"', add
label define imppop_lbl 13 `"13"', add
label define imppop_lbl 14 `"14"', add
label define imppop_lbl 15 `"15"', add
label define imppop_lbl 16 `"16"', add
label define imppop_lbl 17 `"17"', add
label define imppop_lbl 18 `"18"', add
label define imppop_lbl 19 `"19"', add
label define imppop_lbl 20 `"20"', add
label define imppop_lbl 21 `"21"', add
label define imppop_lbl 22 `"22"', add
label define imppop_lbl 23 `"23"', add
label define imppop_lbl 24 `"24"', add
label define imppop_lbl 25 `"25"', add
label define imppop_lbl 26 `"26"', add
label define imppop_lbl 27 `"27"', add
label define imppop_lbl 28 `"28"', add
label define imppop_lbl 29 `"29"', add
label values imppop imppop_lbl

label define impsp_lbl 0  `"0"'
label define impsp_lbl 1  `"1"', add
label define impsp_lbl 2  `"2"', add
label define impsp_lbl 3  `"3"', add
label define impsp_lbl 4  `"4"', add
label define impsp_lbl 5  `"5"', add
label define impsp_lbl 6  `"6"', add
label define impsp_lbl 7  `"7"', add
label define impsp_lbl 8  `"8"', add
label define impsp_lbl 9  `"9"', add
label define impsp_lbl 10 `"10"', add
label define impsp_lbl 11 `"11"', add
label define impsp_lbl 12 `"12"', add
label define impsp_lbl 13 `"13"', add
label define impsp_lbl 14 `"14"', add
label define impsp_lbl 15 `"15"', add
label define impsp_lbl 16 `"16"', add
label define impsp_lbl 17 `"17"', add
label define impsp_lbl 18 `"18"', add
label define impsp_lbl 19 `"19"', add
label define impsp_lbl 20 `"20"', add
label define impsp_lbl 21 `"21"', add
label define impsp_lbl 22 `"22"', add
label define impsp_lbl 23 `"23"', add
label define impsp_lbl 24 `"24"', add
label define impsp_lbl 25 `"25"', add
label define impsp_lbl 26 `"26"', add
label define impsp_lbl 27 `"27"', add
label define impsp_lbl 28 `"28"', add
label define impsp_lbl 29 `"29"', add
label values impsp impsp_lbl

label define imprel_lbl 0  `"Not applicable (oversamples in 1900-1910)"'
label define imprel_lbl 1  `"Head/householder"', add
label define imprel_lbl 2  `"Spouse"', add
label define imprel_lbl 3  `"Child"', add
label define imprel_lbl 4  `"Child-in-law"', add
label define imprel_lbl 5  `"Parent"', add
label define imprel_lbl 6  `"Parent-in-law"', add
label define imprel_lbl 7  `"Sibling"', add
label define imprel_lbl 8  `"Sibling-in-law"', add
label define imprel_lbl 9  `"Grandchild"', add
label define imprel_lbl 10 `"Other relatives"', add
label define imprel_lbl 11 `"Partner, friend, visitor"', add
label define imprel_lbl 12 `"Other non-relatives"', add
label define imprel_lbl 13 `"Institutional inmates"', add
label values imprel imprel_lbl

label define qage_lbl 0 `"Entered as written"'
label define qage_lbl 1 `"Failed edit"', add
label define qage_lbl 2 `"Illegible"', add
label define qage_lbl 3 `"Missing"', add
label define qage_lbl 4 `"Allocated"', add
label define qage_lbl 5 `"Illegible"', add
label define qage_lbl 6 `"Missing"', add
label define qage_lbl 7 `"Original entry illegible"', add
label define qage_lbl 8 `"Original entry missing or failed edit"', add
label values qage qage_lbl

label define qagemont_lbl 0 `"Entered as written"'
label define qagemont_lbl 1 `"Failed edit"', add
label define qagemont_lbl 2 `"Illegible"', add
label define qagemont_lbl 3 `"Missing"', add
label define qagemont_lbl 4 `"Failed edit"', add
label define qagemont_lbl 5 `"Illegible"', add
label define qagemont_lbl 6 `"Missing"', add
label define qagemont_lbl 7 `"Original entry illegible"', add
label define qagemont_lbl 8 `"Original entry missing or failed edit"', add
label values qagemont qagemont_lbl

label define qbpl_lbl 0 `"Entered as written"'
label define qbpl_lbl 1 `"Specific U.S. state or foreign country of birth pre-edited or not reported (1980 Puerto Rico)"', add
label define qbpl_lbl 2 `"Failed edit/illegible"', add
label define qbpl_lbl 3 `"Consistency edit"', add
label define qbpl_lbl 4 `"Allocated"', add
label define qbpl_lbl 5 `"Both general and specific response allocated (1980 Puerto Rico)"', add
label define qbpl_lbl 6 `"Failed edit/missing"', add
label define qbpl_lbl 7 `"Illegible"', add
label define qbpl_lbl 8 `"Illegible/missing or failed edit"', add
label values qbpl qbpl_lbl

label define qocc_lbl 0 `"Entered as written"'
label define qocc_lbl 1 `"Failed edit"', add
label define qocc_lbl 2 `"Illegible"', add
label define qocc_lbl 3 `"Missing"', add
label define qocc_lbl 4 `"Allocated"', add
label define qocc_lbl 5 `"Illegible"', add
label define qocc_lbl 6 `"Missing"', add
label define qocc_lbl 7 `"Original entry illegible"', add
label define qocc_lbl 8 `"Original entry missing or failed edit"', add
label values qocc qocc_lbl

label define qrace_lbl 0 `"Entered as written"'
label define qrace_lbl 1 `"Failed edit"', add
label define qrace_lbl 2 `"Illegible"', add
label define qrace_lbl 3 `"Missing"', add
label define qrace_lbl 4 `"Allocated"', add
label define qrace_lbl 5 `"Allocated, hot deck"', add
label define qrace_lbl 6 `"Missing"', add
label define qrace_lbl 7 `"Original entry illegible"', add
label define qrace_lbl 8 `"Original entry missing or failed edit"', add
label values qrace qrace_lbl

label define qschool_lbl 0 `"Original entry or Inapplicable (not in universe)"'
label define qschool_lbl 1 `"Failed edit"', add
label define qschool_lbl 2 `"Illegible"', add
label define qschool_lbl 3 `"Missing"', add
label define qschool_lbl 4 `"Allocated"', add
label define qschool_lbl 5 `"Illegible"', add
label define qschool_lbl 6 `"Missing"', add
label define qschool_lbl 7 `"Original entry illegible"', add
label define qschool_lbl 8 `"Original entry missing or failed edit"', add
label values qschool qschool_lbl

label define qsex_lbl 0 `"Entered as written"'
label define qsex_lbl 1 `"Failed edit"', add
label define qsex_lbl 2 `"Illegible"', add
label define qsex_lbl 3 `"Missing"', add
label define qsex_lbl 4 `"Allocated"', add
label define qsex_lbl 5 `"Illegible"', add
label define qsex_lbl 6 `"Missing"', add
label define qsex_lbl 7 `"Original entry illegible"', add
label define qsex_lbl 8 `"Original entry missing or failed edit"', add
label values qsex qsex_lbl

label define racamind_lbl 1 `"No"'
label define racamind_lbl 2 `"Yes"', add
label values racamind racamind_lbl

label define racasian_lbl 1 `"No"'
label define racasian_lbl 2 `"Yes"', add
label values racasian racasian_lbl

label define racblk_lbl 1 `"No"'
label define racblk_lbl 2 `"Yes"', add
label values racblk racblk_lbl

label define racpacis_lbl 1 `"No"'
label define racpacis_lbl 2 `"Yes"', add
label values racpacis racpacis_lbl

label define racother_lbl 1 `"No"'
label define racother_lbl 2 `"Yes"', add
label values racother racother_lbl

label define racwht_lbl 1 `"No"'
label define racwht_lbl 2 `"Yes"', add
label values racwht racwht_lbl

label define agediff_lbl 85 `"1850"'
label define agediff_lbl 86 `"1860"', add
label define agediff_lbl 87 `"1870"', add
label define agediff_lbl 88 `"1880"', add
label define agediff_lbl 90 `"1900"', add
label define agediff_lbl 91 `"1910"', add
label define agediff_lbl 92 `"1920"', add
label define agediff_lbl 93 `"1930"', add
label define agediff_lbl 94 `"1940"', add
label define agediff_lbl 95 `"1950"', add
label define agediff_lbl 96 `"1960"', add
label define agediff_lbl 97 `"1970"', add
label define agediff_lbl 98 `"1980"', add
label define agediff_lbl 99 `"1990"', add
label define agediff_lbl 0  `"2000"', add
label values agediff agediff_lbl

label define racesing_lbl 10 `"White"'
label define racesing_lbl 12 `""Other rac", Hispanic"', add
label define racesing_lbl 20 `"Black"', add
label define racesing_lbl 21 `"Mulatto"', add
label define racesing_lbl 30 `"AI (American Indian)"', add
label define racesing_lbl 31 `"AN (Alaskan Native)"', add
label define racesing_lbl 32 `"AI/AN (American Indian/Alaskan Native)"', add
label define racesing_lbl 40 `"Asian Indian"', add
label define racesing_lbl 41 `"Chinese"', add
label define racesing_lbl 42 `"Filipino"', add
label define racesing_lbl 43 `"Japanese"', add
label define racesing_lbl 44 `"Korean"', add
label define racesing_lbl 45 `"Other Asian"', add
label define racesing_lbl 46 `"Hawaiian"', add
label define racesing_lbl 47 `"Other PI (Pacific Islander)"', add
label define racesing_lbl 48 `"Asian and PI (Pacific Islander)"', add
label define racesing_lbl 50 `"Other race, non-Hispanic"', add
label define racesing_lbl 8  `"1960s cases to be allocated"', add
label define racesing_lbl 51 `"Other race"', add
label values racesing racesing_lbl

label define hisprule_lbl 0 `"Not assigned as Hispanic"'
label define hisprule_lbl 1 `"Birthplace is Hispanic"', add
label define hisprule_lbl 2 `"Parental birthplace is Hispanic"', add
label define hisprule_lbl 3 `"Grandparental birthplace is Hispanic"', add
label define hisprule_lbl 4 `"Spouse is Hispanic"', add
label define hisprule_lbl 5 `"Related HH head is Hispanic"', add
label define hisprule_lbl 6 `"Spanish surname"', add
label define hisprule_lbl 7 `"Spouse has Spanish surname"', add
label define hisprule_lbl 8 `"Related HH head has Spanish surname"', add
label values hisprule hisprule_lbl

label define presgl_lbl 0   `"N/A"'
label define presgl_lbl 93  `"Bootblacks"', add
label define presgl_lbl 122 `"Teamsters"', add
label define presgl_lbl 124 `"Charwomen and cleaners"', add
label define presgl_lbl 141 `"Attendants, professional and personal service (n.e.c.)"', add
label define presgl_lbl 147 `"Attendants, recreation and amusement"', add
label define presgl_lbl 149 `"Ushers, recreation and amusement"', add
label define presgl_lbl 153 `"Counter and fountain workers"', add
label define presgl_lbl 154 `"Newsboys"', add
label define presgl_lbl 161 `"Janitors and sextons"', add
label define presgl_lbl 163 `"Garage laborers and car washers and greasers"', add
label define presgl_lbl 175 `"Laborers (n.e.c.)"', add
label define presgl_lbl 176 `"Laundressses, private household"', add
label define presgl_lbl 182 `"Laundry and dry cleaning operatives"', add
label define presgl_lbl 183 `"Hucksters and peddlers"', add
label define presgl_lbl 184 `"Farm laborers, wage workers"', add
label define presgl_lbl 187 `"Filers, grinders, and polishers, metal"', add
label define presgl_lbl 189 `"Private household workers (n.e.c.)"', add
label define presgl_lbl 191 `"Messengers and office boys"', add
label define presgl_lbl 199 `"Bartenders"', add
label define presgl_lbl 202 `"Porters"', add
label define presgl_lbl 203 `"Waiters and waitresses"', add
label define presgl_lbl 209 `"Elevator operators"', add
label define presgl_lbl 215 `"Fruit, nut, and vegetable graders, and packers, except factory"', add
label define presgl_lbl 216 `"Attendants, auto service and parking"', add
label define presgl_lbl 219 `"Guards, watchmen, and doorkeepers"', add
label define presgl_lbl 220 `"Taxicab drivers and chauffers"', add
label define presgl_lbl 221 `"Boarding and lodging house keepers"', add
label define presgl_lbl 225 `"Gardeners, except farm, and groundskeepers"', add
label define presgl_lbl 232 `"Baggagemen, transportation"', add
label define presgl_lbl 233 `"Midwives"', add
label define presgl_lbl 235 `"Watchmen (crossing) and bridge tenders"', add
label define presgl_lbl 242 `"Oilers and greaser, except auto"', add
label define presgl_lbl 243 `"Paperhangers"', add
label define presgl_lbl 244 `"Longshoremen and stevedores"', add
label define presgl_lbl 249 `"Spinners, textile"', add
label define presgl_lbl 250 `"Dyers"', add
label define presgl_lbl 252 `"Millers, grain, flour, feed, etc."', add
label define presgl_lbl 255 `"Glaziers"', add
label define presgl_lbl 259 `"Collectors, bill and account"', add
label define presgl_lbl 263 `"Mine operatives and laborers"', add
label define presgl_lbl 264 `"Cooks, except private household"', add
label define presgl_lbl 268 `"Farm service laborers, self-employed"', add
label define presgl_lbl 272 `"Motormen, mine, factory, logging camp, etc."', add
label define presgl_lbl 274 `"Floormen and floor managers, store"', add
label define presgl_lbl 277 `"Sawyers"', add
label define presgl_lbl 280 `"Conductors, bus and street railway"', add
label define presgl_lbl 283 `"Demonstrators"', add
label define presgl_lbl 284 `"Asbestos and insulation workers"', add
label define presgl_lbl 290 `"Painters, except construction or maintenance"', add
label define presgl_lbl 292 `"Shipping and receiving clerks"', add
label define presgl_lbl 298 `"Telegraph messengers"', add
label define presgl_lbl 302 `"Fishermen and oystermen"', add
label define presgl_lbl 303 `"Upholsterers"', add
label define presgl_lbl 304 `"Loom fixers"', add
label define presgl_lbl 307 `"Boilermakers"', add
label define presgl_lbl 309 `"Cashiers"', add
label define presgl_lbl 312 `"Roofers and slaters"', add
label define presgl_lbl 313 `"Bookbinders"', add
label define presgl_lbl 316 `"Cement and concrete finishers"', add
label define presgl_lbl 317 `"Dressmakers and seamstresses, except factory"', add
label define presgl_lbl 319 `"Auctioneers"', add
label define presgl_lbl 320 `"Piano and organ tuners and repairmen"', add
label define presgl_lbl 321 `"Blasters and powdermen"', add
label define presgl_lbl 324 `"Bus drivers"', add
label define presgl_lbl 325 `"Stationary firemen"', add
label define presgl_lbl 326 `"Excavating, grading, and road machinery operators"', add
label define presgl_lbl 328 `"Salesmen and sales clerks (n.e.c.)"', add
label define presgl_lbl 329 `"Furnacemen, smeltermen and pourers"', add
label define presgl_lbl 332 `"Plasterers"', add
label define presgl_lbl 334 `"Milliners"', add
label define presgl_lbl 335 `"Dispatchers and starters, vehicle"', add
label define presgl_lbl 337 `"Sailors and deck hands"', add
label define presgl_lbl 339 `"Mechanics and repairmen, office machine"', add
label define presgl_lbl 342 `"Entertainers (n.e.c.)"', add
label define presgl_lbl 347 `"Furriers"', add
label define presgl_lbl 350 `"Mechanics and repairmen, radio and television"', add
label define presgl_lbl 354 `"Ticket, station, and express agents"', add
label define presgl_lbl 355 `"Clerical and kindred workers (n.e.c.)"', add
label define presgl_lbl 357 `"Brickmasons, stonemasons, and tile setters"', add
label define presgl_lbl 359 `"Photographic process workers"', add
label define presgl_lbl 360 `"Rollers and roll hands, metal"', add
label define presgl_lbl 362 `"Locomotive firemen"', add
label define presgl_lbl 363 `"Attendants, hospital and other institution"', add
label define presgl_lbl 364 `"Housekeepers and stewards, except private household"', add
label define presgl_lbl 367 `"Therapists and healers (n.e.c.)"', add
label define presgl_lbl 368 `"Tinsmiths, coppersmiths, and sheet metal workers"', add
label define presgl_lbl 372 `"Mechanics and repairmen, railroad and car shop"', add
label define presgl_lbl 373 `"Jewelers, watchmakers, goldsmiths, and silversmiths"', add
label define presgl_lbl 374 `"Decorators and window dressers"', add
label define presgl_lbl 376 `"Dancers and dancing teachers"', add
label define presgl_lbl 380 `"Compositors and typesetters"', add
label define presgl_lbl 383 `"Managers and superintendents, building"', add
label define presgl_lbl 386 `"Cabinetmakers"', add
label define presgl_lbl 388 `"Cranemen, derrickmen, and hoistmen"', add
label define presgl_lbl 391 `"Molders, metal"', add
label define presgl_lbl 392 `"Linemen and servicemen, telegraph, telephone, and power"', add
label define presgl_lbl 394 `"Chainmen, rodmen, and axmen, surveying"', add
label define presgl_lbl 399 `"Carpenters"', add
label define presgl_lbl 401 `"Welders and flame cutters"', add
label define presgl_lbl 402 `"Pressmen and plate printers, printing"', add
label define presgl_lbl 403 `"Millwrights"', add
label define presgl_lbl 404 `"Telephone operators"', add
label define presgl_lbl 405 `"Photographers"', add
label define presgl_lbl 406 `"Inspectors, public administration"', add
label define presgl_lbl 407 `"Farmers (owners and tenants)"', add
label define presgl_lbl 408 `"Apprentice auto mechanics"', add
label define presgl_lbl 409 `"Buyers and shippers, farm products"', add
label define presgl_lbl 412 `"Engravers, except photoengravers"', add
label define presgl_lbl 413 `"Attendants and assistants, library"', add
label define presgl_lbl 419 `"Practical nurses"', add
label define presgl_lbl 420 `"Tool makers, and die makers and setters"', add
label define presgl_lbl 422 `"Advertising agents and salesmen"', add
label define presgl_lbl 423 `"Mail carriers"', add
label define presgl_lbl 425 `"Agents (n.e.c.)"', add
label define presgl_lbl 428 `"Radio operators"', add
label define presgl_lbl 435 `"Telegraph operators"', add
label define presgl_lbl 437 `"Farm managers"', add
label define presgl_lbl 438 `"Firemen, fire protection"', add
label define presgl_lbl 440 `"Real estate agents and brokers"', add
label define presgl_lbl 445 `"Stenographers, typists, and secretaries"', add
label define presgl_lbl 449 `"Office machine operators"', add
label define presgl_lbl 451 `"Nurses, student professional"', add
label define presgl_lbl 453 `"Foremen (n.e.c.)"', add
label define presgl_lbl 458 `"Marshals and constables"', add
label define presgl_lbl 460 `"Musicians and music teachers"', add
label define presgl_lbl 466 `"Craftsmen and kindred workers (n.e.c.)"', add
label define presgl_lbl 469 `"Insurance agents and brokers"', add
label define presgl_lbl 470 `"Technicians, testing"', add
label define presgl_lbl 476 `"Bookkeepers"', add
label define presgl_lbl 478 `"Attendants, physician's and dentist's office"', add
label define presgl_lbl 479 `"Purchasing agents and buyers (n.e.c.)"', add
label define presgl_lbl 482 `"Mechanics and repairmen, airplane"', add
label define presgl_lbl 483 `"Officials, lodge, society, union, etc."', add
label define presgl_lbl 486 `"Recreation and group workers"', add
label define presgl_lbl 488 `"Credit men"', add
label define presgl_lbl 492 `"Electricians"', add
label define presgl_lbl 495 `"Bank tellers"', add
label define presgl_lbl 500 `"Buyers and department heads, store"', add
label define presgl_lbl 502 `"Technicians (n.e.c.)"', add
label define presgl_lbl 503 `"Managers, officials, and proprietors (n.e.c.)"', add
label define presgl_lbl 506 `"Professional, technical and kindred workers (n.e.c.)"', add
label define presgl_lbl 508 `"Locomotive engineers"', add
label define presgl_lbl 514 `"Athletes"', add
label define presgl_lbl 521 `"Dieticians and nutritionists"', add
label define presgl_lbl 522 `"Funeral directors and embalmers"', add
label define presgl_lbl 524 `"Social and welfare workers, except group"', add
label define presgl_lbl 525 `"Editors and reporters"', add
label define presgl_lbl 532 `"Sports instructors and officials"', add
label define presgl_lbl 533 `"Surveyors"', add
label define presgl_lbl 539 `"Farm and home management advisors"', add
label define presgl_lbl 544 `"Engineers, industrial"', add
label define presgl_lbl 546 `"Librarians"', add
label define presgl_lbl 550 `"Actors and actresses"', add
label define presgl_lbl 554 `"Statisticians and actuaries"', add
label define presgl_lbl 555 `"Religious workers"', add
label define presgl_lbl 558 `"Engineers, metallurgical, metallurgists"', add
label define presgl_lbl 560 `"Personnel and labor relations workers"', add
label define presgl_lbl 561 `"Draftsmen"', add
label define presgl_lbl 562 `"Artists and art teachers"', add
label define presgl_lbl 567 `"Accountants and auditors"', add
label define presgl_lbl 568 `"Economists"', add
label define presgl_lbl 581 `"Postmasters"', add
label define presgl_lbl 582 `"Designers"', add
label define presgl_lbl 596 `"Teachers (n.e.c.)"', add
label define presgl_lbl 597 `"Veterinarians"', add
label define presgl_lbl 598 `"Authors"', add
label define presgl_lbl 599 `"Officers, pilots, pursers and engineers, ship"', add
label define presgl_lbl 600 `"Chiropractors"', add
label define presgl_lbl 604 `"Engineers (n.e.c.)"', add
label define presgl_lbl 606 `"Officials and administrators (n.e.c.), public administration"', add
label define presgl_lbl 607 `"Pharmacists"', add
label define presgl_lbl 610 `"Technicians, medical and dental"', add
label define presgl_lbl 615 `"Nurses, professional"', add
label define presgl_lbl 616 `"Engineers, mining"', add
label define presgl_lbl 619 `"Osteopaths"', add
label define presgl_lbl 620 `"Optometrists"', add
label define presgl_lbl 623 `"Engineers, mechanical"', add
label define presgl_lbl 650 `"Mathematicians"', add
label define presgl_lbl 656 `"Miscellaneous social scientists"', add
label define presgl_lbl 672 `"Geologists and geophysicists"', add
label define presgl_lbl 673 `"Engineers, chemical"', add
label define presgl_lbl 677 `"Biological scientists"', add
label define presgl_lbl 678 `"Engineers, civil"', add
label define presgl_lbl 681 `"Miscellaneous natural scientists"', add
label define presgl_lbl 688 `"Chemists"', add
label define presgl_lbl 690 `"Clergymen"', add
label define presgl_lbl 694 `"Engineers, electrical"', add
label define presgl_lbl 701 `"Airplane pilots and navigators"', add
label define presgl_lbl 705 `"Architects"', add
label define presgl_lbl 711 `"Engineers, aeronautical"', add
label define presgl_lbl 714 `"Psychologists"', add
label define presgl_lbl 736 `"Dentists"', add
label define presgl_lbl 738 `"Physicists"', add
label define presgl_lbl 757 `"Lawyers and judges"', add
label define presgl_lbl 783 `"College presidents and deans"', add
label define presgl_lbl 815 `"Physicians and surgeons"', add
label values presgl presgl_lbl

label define erscor50_lbl 0    `"0"'
label define erscor50_lbl 1    `"0.1"', add
label define erscor50_lbl 2    `"0.2"', add
label define erscor50_lbl 3    `"0.3"', add
label define erscor50_lbl 4    `"0.4"', add
label define erscor50_lbl 5    `"0.5"', add
label define erscor50_lbl 6    `"0.6"', add
label define erscor50_lbl 7    `"0.7"', add
label define erscor50_lbl 8    `"0.8"', add
label define erscor50_lbl 9    `"0.9"', add
label define erscor50_lbl 10   `"1"', add
label define erscor50_lbl 11   `"1.1"', add
label define erscor50_lbl 12   `"1.2"', add
label define erscor50_lbl 13   `"1.3"', add
label define erscor50_lbl 14   `"1.4"', add
label define erscor50_lbl 15   `"1.5"', add
label define erscor50_lbl 16   `"1.6"', add
label define erscor50_lbl 17   `"1.7"', add
label define erscor50_lbl 18   `"1.8"', add
label define erscor50_lbl 19   `"1.9"', add
label define erscor50_lbl 20   `"2"', add
label define erscor50_lbl 21   `"2.1"', add
label define erscor50_lbl 22   `"2.2"', add
label define erscor50_lbl 23   `"2.3"', add
label define erscor50_lbl 24   `"2.4"', add
label define erscor50_lbl 25   `"2.5"', add
label define erscor50_lbl 26   `"2.6"', add
label define erscor50_lbl 27   `"2.7"', add
label define erscor50_lbl 28   `"2.8"', add
label define erscor50_lbl 29   `"2.9"', add
label define erscor50_lbl 30   `"3"', add
label define erscor50_lbl 31   `"3.1"', add
label define erscor50_lbl 32   `"3.2"', add
label define erscor50_lbl 33   `"3.3"', add
label define erscor50_lbl 34   `"3.4"', add
label define erscor50_lbl 35   `"3.5"', add
label define erscor50_lbl 36   `"3.6"', add
label define erscor50_lbl 37   `"3.7"', add
label define erscor50_lbl 38   `"3.8"', add
label define erscor50_lbl 39   `"3.9"', add
label define erscor50_lbl 40   `"4"', add
label define erscor50_lbl 41   `"4.1"', add
label define erscor50_lbl 42   `"4.2"', add
label define erscor50_lbl 43   `"4.3"', add
label define erscor50_lbl 44   `"4.4"', add
label define erscor50_lbl 45   `"4.5"', add
label define erscor50_lbl 46   `"4.6"', add
label define erscor50_lbl 47   `"4.7"', add
label define erscor50_lbl 48   `"4.8"', add
label define erscor50_lbl 49   `"4.9"', add
label define erscor50_lbl 50   `"5"', add
label define erscor50_lbl 51   `"5.1"', add
label define erscor50_lbl 52   `"5.2"', add
label define erscor50_lbl 53   `"5.3"', add
label define erscor50_lbl 54   `"5.4"', add
label define erscor50_lbl 55   `"5.5"', add
label define erscor50_lbl 56   `"5.6"', add
label define erscor50_lbl 57   `"5.7"', add
label define erscor50_lbl 58   `"5.8"', add
label define erscor50_lbl 59   `"5.9"', add
label define erscor50_lbl 60   `"6"', add
label define erscor50_lbl 61   `"6.1"', add
label define erscor50_lbl 62   `"6.2"', add
label define erscor50_lbl 63   `"6.3"', add
label define erscor50_lbl 64   `"6.4"', add
label define erscor50_lbl 65   `"6.5"', add
label define erscor50_lbl 66   `"6.6"', add
label define erscor50_lbl 67   `"6.7"', add
label define erscor50_lbl 68   `"6.8"', add
label define erscor50_lbl 69   `"6.9"', add
label define erscor50_lbl 70   `"7"', add
label define erscor50_lbl 71   `"7.1"', add
label define erscor50_lbl 72   `"7.2"', add
label define erscor50_lbl 73   `"7.3"', add
label define erscor50_lbl 74   `"7.4"', add
label define erscor50_lbl 75   `"7.5"', add
label define erscor50_lbl 76   `"7.6"', add
label define erscor50_lbl 77   `"7.7"', add
label define erscor50_lbl 78   `"7.8"', add
label define erscor50_lbl 79   `"7.9"', add
label define erscor50_lbl 80   `"8"', add
label define erscor50_lbl 81   `"8.1"', add
label define erscor50_lbl 82   `"8.2"', add
label define erscor50_lbl 83   `"8.3"', add
label define erscor50_lbl 84   `"8.4"', add
label define erscor50_lbl 85   `"8.5"', add
label define erscor50_lbl 86   `"8.6"', add
label define erscor50_lbl 87   `"8.7"', add
label define erscor50_lbl 88   `"8.8"', add
label define erscor50_lbl 89   `"8.9"', add
label define erscor50_lbl 90   `"9"', add
label define erscor50_lbl 91   `"9.1"', add
label define erscor50_lbl 92   `"9.2"', add
label define erscor50_lbl 93   `"9.3"', add
label define erscor50_lbl 94   `"9.4"', add
label define erscor50_lbl 95   `"9.5"', add
label define erscor50_lbl 96   `"9.6"', add
label define erscor50_lbl 97   `"9.7"', add
label define erscor50_lbl 98   `"9.8"', add
label define erscor50_lbl 99   `"9.9"', add
label define erscor50_lbl 100  `"10"', add
label define erscor50_lbl 101  `"10.1"', add
label define erscor50_lbl 102  `"10.2"', add
label define erscor50_lbl 103  `"10.3"', add
label define erscor50_lbl 104  `"10.4"', add
label define erscor50_lbl 105  `"10.5"', add
label define erscor50_lbl 106  `"10.6"', add
label define erscor50_lbl 107  `"10.7"', add
label define erscor50_lbl 108  `"10.8"', add
label define erscor50_lbl 109  `"10.9"', add
label define erscor50_lbl 110  `"11"', add
label define erscor50_lbl 111  `"11.1"', add
label define erscor50_lbl 112  `"11.2"', add
label define erscor50_lbl 113  `"11.3"', add
label define erscor50_lbl 114  `"11.4"', add
label define erscor50_lbl 115  `"11.5"', add
label define erscor50_lbl 116  `"11.6"', add
label define erscor50_lbl 117  `"11.7"', add
label define erscor50_lbl 118  `"11.8"', add
label define erscor50_lbl 119  `"11.9"', add
label define erscor50_lbl 120  `"12"', add
label define erscor50_lbl 121  `"12.1"', add
label define erscor50_lbl 122  `"12.2"', add
label define erscor50_lbl 123  `"12.3"', add
label define erscor50_lbl 124  `"12.4"', add
label define erscor50_lbl 125  `"12.5"', add
label define erscor50_lbl 126  `"12.6"', add
label define erscor50_lbl 127  `"12.7"', add
label define erscor50_lbl 128  `"12.8"', add
label define erscor50_lbl 129  `"12.9"', add
label define erscor50_lbl 130  `"13"', add
label define erscor50_lbl 131  `"13.1"', add
label define erscor50_lbl 132  `"13.2"', add
label define erscor50_lbl 133  `"13.3"', add
label define erscor50_lbl 134  `"13.4"', add
label define erscor50_lbl 135  `"13.5"', add
label define erscor50_lbl 136  `"13.6"', add
label define erscor50_lbl 137  `"13.7"', add
label define erscor50_lbl 138  `"13.8"', add
label define erscor50_lbl 139  `"13.9"', add
label define erscor50_lbl 140  `"14"', add
label define erscor50_lbl 141  `"14.1"', add
label define erscor50_lbl 142  `"14.2"', add
label define erscor50_lbl 143  `"14.3"', add
label define erscor50_lbl 144  `"14.4"', add
label define erscor50_lbl 145  `"14.5"', add
label define erscor50_lbl 146  `"14.6"', add
label define erscor50_lbl 147  `"14.7"', add
label define erscor50_lbl 148  `"14.8"', add
label define erscor50_lbl 149  `"14.9"', add
label define erscor50_lbl 150  `"15"', add
label define erscor50_lbl 151  `"15.1"', add
label define erscor50_lbl 152  `"15.2"', add
label define erscor50_lbl 153  `"15.3"', add
label define erscor50_lbl 154  `"15.4"', add
label define erscor50_lbl 155  `"15.5"', add
label define erscor50_lbl 156  `"15.6"', add
label define erscor50_lbl 157  `"15.7"', add
label define erscor50_lbl 158  `"15.8"', add
label define erscor50_lbl 159  `"15.9"', add
label define erscor50_lbl 160  `"16"', add
label define erscor50_lbl 161  `"16.1"', add
label define erscor50_lbl 162  `"16.2"', add
label define erscor50_lbl 163  `"16.3"', add
label define erscor50_lbl 164  `"16.4"', add
label define erscor50_lbl 165  `"16.5"', add
label define erscor50_lbl 166  `"16.6"', add
label define erscor50_lbl 167  `"16.7"', add
label define erscor50_lbl 168  `"16.8"', add
label define erscor50_lbl 169  `"16.9"', add
label define erscor50_lbl 170  `"17"', add
label define erscor50_lbl 171  `"17.1"', add
label define erscor50_lbl 172  `"17.2"', add
label define erscor50_lbl 173  `"17.3"', add
label define erscor50_lbl 174  `"17.4"', add
label define erscor50_lbl 175  `"17.5"', add
label define erscor50_lbl 176  `"17.6"', add
label define erscor50_lbl 177  `"17.7"', add
label define erscor50_lbl 178  `"17.8"', add
label define erscor50_lbl 179  `"17.9"', add
label define erscor50_lbl 180  `"18"', add
label define erscor50_lbl 181  `"18.1"', add
label define erscor50_lbl 182  `"18.2"', add
label define erscor50_lbl 183  `"18.3"', add
label define erscor50_lbl 184  `"18.4"', add
label define erscor50_lbl 185  `"18.5"', add
label define erscor50_lbl 186  `"18.6"', add
label define erscor50_lbl 187  `"18.7"', add
label define erscor50_lbl 188  `"18.8"', add
label define erscor50_lbl 189  `"18.9"', add
label define erscor50_lbl 190  `"19"', add
label define erscor50_lbl 191  `"19.1"', add
label define erscor50_lbl 192  `"19.2"', add
label define erscor50_lbl 193  `"19.3"', add
label define erscor50_lbl 194  `"19.4"', add
label define erscor50_lbl 195  `"19.5"', add
label define erscor50_lbl 196  `"19.6"', add
label define erscor50_lbl 197  `"19.7"', add
label define erscor50_lbl 198  `"19.8"', add
label define erscor50_lbl 199  `"19.9"', add
label define erscor50_lbl 200  `"20"', add
label define erscor50_lbl 201  `"20.1"', add
label define erscor50_lbl 202  `"20.2"', add
label define erscor50_lbl 203  `"20.3"', add
label define erscor50_lbl 204  `"20.4"', add
label define erscor50_lbl 205  `"20.5"', add
label define erscor50_lbl 206  `"20.6"', add
label define erscor50_lbl 207  `"20.7"', add
label define erscor50_lbl 208  `"20.8"', add
label define erscor50_lbl 209  `"20.9"', add
label define erscor50_lbl 210  `"21"', add
label define erscor50_lbl 211  `"21.1"', add
label define erscor50_lbl 212  `"21.2"', add
label define erscor50_lbl 213  `"21.3"', add
label define erscor50_lbl 214  `"21.4"', add
label define erscor50_lbl 215  `"21.5"', add
label define erscor50_lbl 216  `"21.6"', add
label define erscor50_lbl 217  `"21.7"', add
label define erscor50_lbl 218  `"21.8"', add
label define erscor50_lbl 219  `"21.9"', add
label define erscor50_lbl 220  `"22"', add
label define erscor50_lbl 221  `"22.1"', add
label define erscor50_lbl 222  `"22.2"', add
label define erscor50_lbl 223  `"22.3"', add
label define erscor50_lbl 224  `"22.4"', add
label define erscor50_lbl 225  `"22.5"', add
label define erscor50_lbl 226  `"22.6"', add
label define erscor50_lbl 227  `"22.7"', add
label define erscor50_lbl 228  `"22.8"', add
label define erscor50_lbl 229  `"22.9"', add
label define erscor50_lbl 230  `"23"', add
label define erscor50_lbl 231  `"23.1"', add
label define erscor50_lbl 232  `"23.2"', add
label define erscor50_lbl 233  `"23.3"', add
label define erscor50_lbl 234  `"23.4"', add
label define erscor50_lbl 235  `"23.5"', add
label define erscor50_lbl 236  `"23.6"', add
label define erscor50_lbl 237  `"23.7"', add
label define erscor50_lbl 238  `"23.8"', add
label define erscor50_lbl 239  `"23.9"', add
label define erscor50_lbl 240  `"24"', add
label define erscor50_lbl 241  `"24.1"', add
label define erscor50_lbl 242  `"24.2"', add
label define erscor50_lbl 243  `"24.3"', add
label define erscor50_lbl 244  `"24.4"', add
label define erscor50_lbl 245  `"24.5"', add
label define erscor50_lbl 246  `"24.6"', add
label define erscor50_lbl 247  `"24.7"', add
label define erscor50_lbl 248  `"24.8"', add
label define erscor50_lbl 249  `"24.9"', add
label define erscor50_lbl 250  `"25"', add
label define erscor50_lbl 251  `"25.1"', add
label define erscor50_lbl 252  `"25.2"', add
label define erscor50_lbl 253  `"25.3"', add
label define erscor50_lbl 254  `"25.4"', add
label define erscor50_lbl 255  `"25.5"', add
label define erscor50_lbl 256  `"25.6"', add
label define erscor50_lbl 257  `"25.7"', add
label define erscor50_lbl 258  `"25.8"', add
label define erscor50_lbl 259  `"25.9"', add
label define erscor50_lbl 260  `"26"', add
label define erscor50_lbl 261  `"26.1"', add
label define erscor50_lbl 262  `"26.2"', add
label define erscor50_lbl 263  `"26.3"', add
label define erscor50_lbl 264  `"26.4"', add
label define erscor50_lbl 265  `"26.5"', add
label define erscor50_lbl 266  `"26.6"', add
label define erscor50_lbl 267  `"26.7"', add
label define erscor50_lbl 268  `"26.8"', add
label define erscor50_lbl 269  `"26.9"', add
label define erscor50_lbl 270  `"27"', add
label define erscor50_lbl 271  `"27.1"', add
label define erscor50_lbl 272  `"27.2"', add
label define erscor50_lbl 273  `"27.3"', add
label define erscor50_lbl 274  `"27.4"', add
label define erscor50_lbl 275  `"27.5"', add
label define erscor50_lbl 276  `"27.6"', add
label define erscor50_lbl 277  `"27.7"', add
label define erscor50_lbl 278  `"27.8"', add
label define erscor50_lbl 279  `"27.9"', add
label define erscor50_lbl 280  `"28"', add
label define erscor50_lbl 281  `"28.1"', add
label define erscor50_lbl 282  `"28.2"', add
label define erscor50_lbl 283  `"28.3"', add
label define erscor50_lbl 284  `"28.4"', add
label define erscor50_lbl 285  `"28.5"', add
label define erscor50_lbl 286  `"28.6"', add
label define erscor50_lbl 287  `"28.7"', add
label define erscor50_lbl 288  `"28.8"', add
label define erscor50_lbl 289  `"28.9"', add
label define erscor50_lbl 290  `"29"', add
label define erscor50_lbl 291  `"29.1"', add
label define erscor50_lbl 292  `"29.2"', add
label define erscor50_lbl 293  `"29.3"', add
label define erscor50_lbl 294  `"29.4"', add
label define erscor50_lbl 295  `"29.5"', add
label define erscor50_lbl 296  `"29.6"', add
label define erscor50_lbl 297  `"29.7"', add
label define erscor50_lbl 298  `"29.8"', add
label define erscor50_lbl 299  `"29.9"', add
label define erscor50_lbl 300  `"30"', add
label define erscor50_lbl 301  `"30.1"', add
label define erscor50_lbl 302  `"30.2"', add
label define erscor50_lbl 303  `"30.3"', add
label define erscor50_lbl 304  `"30.4"', add
label define erscor50_lbl 305  `"30.5"', add
label define erscor50_lbl 306  `"30.6"', add
label define erscor50_lbl 307  `"30.7"', add
label define erscor50_lbl 308  `"30.8"', add
label define erscor50_lbl 309  `"30.9"', add
label define erscor50_lbl 310  `"31"', add
label define erscor50_lbl 311  `"31.1"', add
label define erscor50_lbl 312  `"31.2"', add
label define erscor50_lbl 313  `"31.3"', add
label define erscor50_lbl 314  `"31.4"', add
label define erscor50_lbl 315  `"31.5"', add
label define erscor50_lbl 316  `"31.6"', add
label define erscor50_lbl 317  `"31.7"', add
label define erscor50_lbl 318  `"31.8"', add
label define erscor50_lbl 319  `"31.9"', add
label define erscor50_lbl 320  `"32"', add
label define erscor50_lbl 321  `"32.1"', add
label define erscor50_lbl 322  `"32.2"', add
label define erscor50_lbl 323  `"32.3"', add
label define erscor50_lbl 324  `"32.4"', add
label define erscor50_lbl 325  `"32.5"', add
label define erscor50_lbl 326  `"32.6"', add
label define erscor50_lbl 327  `"32.7"', add
label define erscor50_lbl 328  `"32.8"', add
label define erscor50_lbl 329  `"32.9"', add
label define erscor50_lbl 330  `"33"', add
label define erscor50_lbl 331  `"33.1"', add
label define erscor50_lbl 332  `"33.2"', add
label define erscor50_lbl 333  `"33.3"', add
label define erscor50_lbl 334  `"33.4"', add
label define erscor50_lbl 335  `"33.5"', add
label define erscor50_lbl 336  `"33.6"', add
label define erscor50_lbl 337  `"33.7"', add
label define erscor50_lbl 338  `"33.8"', add
label define erscor50_lbl 339  `"33.9"', add
label define erscor50_lbl 340  `"34"', add
label define erscor50_lbl 341  `"34.1"', add
label define erscor50_lbl 342  `"34.2"', add
label define erscor50_lbl 343  `"34.3"', add
label define erscor50_lbl 344  `"34.4"', add
label define erscor50_lbl 345  `"34.5"', add
label define erscor50_lbl 346  `"34.6"', add
label define erscor50_lbl 347  `"34.7"', add
label define erscor50_lbl 348  `"34.8"', add
label define erscor50_lbl 349  `"34.9"', add
label define erscor50_lbl 350  `"35"', add
label define erscor50_lbl 351  `"35.1"', add
label define erscor50_lbl 352  `"35.2"', add
label define erscor50_lbl 353  `"35.3"', add
label define erscor50_lbl 354  `"35.4"', add
label define erscor50_lbl 355  `"35.5"', add
label define erscor50_lbl 356  `"35.6"', add
label define erscor50_lbl 357  `"35.7"', add
label define erscor50_lbl 358  `"35.8"', add
label define erscor50_lbl 359  `"35.9"', add
label define erscor50_lbl 360  `"36"', add
label define erscor50_lbl 361  `"36.1"', add
label define erscor50_lbl 362  `"36.2"', add
label define erscor50_lbl 363  `"36.3"', add
label define erscor50_lbl 364  `"36.4"', add
label define erscor50_lbl 365  `"36.5"', add
label define erscor50_lbl 366  `"36.6"', add
label define erscor50_lbl 367  `"36.7"', add
label define erscor50_lbl 368  `"36.8"', add
label define erscor50_lbl 369  `"36.9"', add
label define erscor50_lbl 370  `"37"', add
label define erscor50_lbl 371  `"37.1"', add
label define erscor50_lbl 372  `"37.2"', add
label define erscor50_lbl 373  `"37.3"', add
label define erscor50_lbl 374  `"37.4"', add
label define erscor50_lbl 375  `"37.5"', add
label define erscor50_lbl 376  `"37.6"', add
label define erscor50_lbl 377  `"37.7"', add
label define erscor50_lbl 378  `"37.8"', add
label define erscor50_lbl 379  `"37.9"', add
label define erscor50_lbl 380  `"38"', add
label define erscor50_lbl 381  `"38.1"', add
label define erscor50_lbl 382  `"38.2"', add
label define erscor50_lbl 383  `"38.3"', add
label define erscor50_lbl 384  `"38.4"', add
label define erscor50_lbl 385  `"38.5"', add
label define erscor50_lbl 386  `"38.6"', add
label define erscor50_lbl 387  `"38.7"', add
label define erscor50_lbl 388  `"38.8"', add
label define erscor50_lbl 389  `"38.9"', add
label define erscor50_lbl 390  `"39"', add
label define erscor50_lbl 391  `"39.1"', add
label define erscor50_lbl 392  `"39.2"', add
label define erscor50_lbl 393  `"39.3"', add
label define erscor50_lbl 394  `"39.4"', add
label define erscor50_lbl 395  `"39.5"', add
label define erscor50_lbl 396  `"39.6"', add
label define erscor50_lbl 397  `"39.7"', add
label define erscor50_lbl 398  `"39.8"', add
label define erscor50_lbl 399  `"39.9"', add
label define erscor50_lbl 400  `"40"', add
label define erscor50_lbl 401  `"40.1"', add
label define erscor50_lbl 402  `"40.2"', add
label define erscor50_lbl 403  `"40.3"', add
label define erscor50_lbl 404  `"40.4"', add
label define erscor50_lbl 405  `"40.5"', add
label define erscor50_lbl 406  `"40.6"', add
label define erscor50_lbl 407  `"40.7"', add
label define erscor50_lbl 408  `"40.8"', add
label define erscor50_lbl 409  `"40.9"', add
label define erscor50_lbl 410  `"41"', add
label define erscor50_lbl 411  `"41.1"', add
label define erscor50_lbl 412  `"41.2"', add
label define erscor50_lbl 413  `"41.3"', add
label define erscor50_lbl 414  `"41.4"', add
label define erscor50_lbl 415  `"41.5"', add
label define erscor50_lbl 416  `"41.6"', add
label define erscor50_lbl 417  `"41.7"', add
label define erscor50_lbl 418  `"41.8"', add
label define erscor50_lbl 419  `"41.9"', add
label define erscor50_lbl 420  `"42"', add
label define erscor50_lbl 421  `"42.1"', add
label define erscor50_lbl 422  `"42.2"', add
label define erscor50_lbl 423  `"42.3"', add
label define erscor50_lbl 424  `"42.4"', add
label define erscor50_lbl 425  `"42.5"', add
label define erscor50_lbl 426  `"42.6"', add
label define erscor50_lbl 427  `"42.7"', add
label define erscor50_lbl 428  `"42.8"', add
label define erscor50_lbl 429  `"42.9"', add
label define erscor50_lbl 430  `"43"', add
label define erscor50_lbl 431  `"43.1"', add
label define erscor50_lbl 432  `"43.2"', add
label define erscor50_lbl 433  `"43.3"', add
label define erscor50_lbl 434  `"43.4"', add
label define erscor50_lbl 435  `"43.5"', add
label define erscor50_lbl 436  `"43.6"', add
label define erscor50_lbl 437  `"43.7"', add
label define erscor50_lbl 438  `"43.8"', add
label define erscor50_lbl 439  `"43.9"', add
label define erscor50_lbl 440  `"44"', add
label define erscor50_lbl 441  `"44.1"', add
label define erscor50_lbl 442  `"44.2"', add
label define erscor50_lbl 443  `"44.3"', add
label define erscor50_lbl 444  `"44.4"', add
label define erscor50_lbl 445  `"44.5"', add
label define erscor50_lbl 446  `"44.6"', add
label define erscor50_lbl 447  `"44.7"', add
label define erscor50_lbl 448  `"44.8"', add
label define erscor50_lbl 449  `"44.9"', add
label define erscor50_lbl 450  `"45"', add
label define erscor50_lbl 451  `"45.1"', add
label define erscor50_lbl 452  `"45.2"', add
label define erscor50_lbl 453  `"45.3"', add
label define erscor50_lbl 454  `"45.4"', add
label define erscor50_lbl 455  `"45.5"', add
label define erscor50_lbl 456  `"45.6"', add
label define erscor50_lbl 457  `"45.7"', add
label define erscor50_lbl 458  `"45.8"', add
label define erscor50_lbl 459  `"45.9"', add
label define erscor50_lbl 460  `"46"', add
label define erscor50_lbl 461  `"46.1"', add
label define erscor50_lbl 462  `"46.2"', add
label define erscor50_lbl 463  `"46.3"', add
label define erscor50_lbl 464  `"46.4"', add
label define erscor50_lbl 465  `"46.5"', add
label define erscor50_lbl 466  `"46.6"', add
label define erscor50_lbl 467  `"46.7"', add
label define erscor50_lbl 468  `"46.8"', add
label define erscor50_lbl 469  `"46.9"', add
label define erscor50_lbl 470  `"47"', add
label define erscor50_lbl 471  `"47.1"', add
label define erscor50_lbl 472  `"47.2"', add
label define erscor50_lbl 473  `"47.3"', add
label define erscor50_lbl 474  `"47.4"', add
label define erscor50_lbl 475  `"47.5"', add
label define erscor50_lbl 476  `"47.6"', add
label define erscor50_lbl 477  `"47.7"', add
label define erscor50_lbl 478  `"47.8"', add
label define erscor50_lbl 479  `"47.9"', add
label define erscor50_lbl 480  `"48"', add
label define erscor50_lbl 481  `"48.1"', add
label define erscor50_lbl 482  `"48.2"', add
label define erscor50_lbl 483  `"48.3"', add
label define erscor50_lbl 484  `"48.4"', add
label define erscor50_lbl 485  `"48.5"', add
label define erscor50_lbl 486  `"48.6"', add
label define erscor50_lbl 487  `"48.7"', add
label define erscor50_lbl 488  `"48.8"', add
label define erscor50_lbl 489  `"48.9"', add
label define erscor50_lbl 490  `"49"', add
label define erscor50_lbl 491  `"49.1"', add
label define erscor50_lbl 492  `"49.2"', add
label define erscor50_lbl 493  `"49.3"', add
label define erscor50_lbl 494  `"49.4"', add
label define erscor50_lbl 495  `"49.5"', add
label define erscor50_lbl 496  `"49.6"', add
label define erscor50_lbl 497  `"49.7"', add
label define erscor50_lbl 498  `"49.8"', add
label define erscor50_lbl 499  `"49.9"', add
label define erscor50_lbl 500  `"50"', add
label define erscor50_lbl 501  `"50.1"', add
label define erscor50_lbl 502  `"50.2"', add
label define erscor50_lbl 503  `"50.3"', add
label define erscor50_lbl 504  `"50.4"', add
label define erscor50_lbl 505  `"50.5"', add
label define erscor50_lbl 506  `"50.6"', add
label define erscor50_lbl 507  `"50.7"', add
label define erscor50_lbl 508  `"50.8"', add
label define erscor50_lbl 509  `"50.9"', add
label define erscor50_lbl 510  `"51"', add
label define erscor50_lbl 511  `"51.1"', add
label define erscor50_lbl 512  `"51.2"', add
label define erscor50_lbl 513  `"51.3"', add
label define erscor50_lbl 514  `"51.4"', add
label define erscor50_lbl 515  `"51.5"', add
label define erscor50_lbl 516  `"51.6"', add
label define erscor50_lbl 517  `"51.7"', add
label define erscor50_lbl 518  `"51.8"', add
label define erscor50_lbl 519  `"51.9"', add
label define erscor50_lbl 520  `"52"', add
label define erscor50_lbl 521  `"52.1"', add
label define erscor50_lbl 522  `"52.2"', add
label define erscor50_lbl 523  `"52.3"', add
label define erscor50_lbl 524  `"52.4"', add
label define erscor50_lbl 525  `"52.5"', add
label define erscor50_lbl 526  `"52.6"', add
label define erscor50_lbl 527  `"52.7"', add
label define erscor50_lbl 528  `"52.8"', add
label define erscor50_lbl 529  `"52.9"', add
label define erscor50_lbl 530  `"53"', add
label define erscor50_lbl 531  `"53.1"', add
label define erscor50_lbl 532  `"53.2"', add
label define erscor50_lbl 533  `"53.3"', add
label define erscor50_lbl 534  `"53.4"', add
label define erscor50_lbl 535  `"53.5"', add
label define erscor50_lbl 536  `"53.6"', add
label define erscor50_lbl 537  `"53.7"', add
label define erscor50_lbl 538  `"53.8"', add
label define erscor50_lbl 539  `"53.9"', add
label define erscor50_lbl 540  `"54"', add
label define erscor50_lbl 541  `"54.1"', add
label define erscor50_lbl 542  `"54.2"', add
label define erscor50_lbl 543  `"54.3"', add
label define erscor50_lbl 544  `"54.4"', add
label define erscor50_lbl 545  `"54.5"', add
label define erscor50_lbl 546  `"54.6"', add
label define erscor50_lbl 547  `"54.7"', add
label define erscor50_lbl 548  `"54.8"', add
label define erscor50_lbl 549  `"54.9"', add
label define erscor50_lbl 550  `"55"', add
label define erscor50_lbl 551  `"55.1"', add
label define erscor50_lbl 552  `"55.2"', add
label define erscor50_lbl 553  `"55.3"', add
label define erscor50_lbl 554  `"55.4"', add
label define erscor50_lbl 555  `"55.5"', add
label define erscor50_lbl 556  `"55.6"', add
label define erscor50_lbl 557  `"55.7"', add
label define erscor50_lbl 558  `"55.8"', add
label define erscor50_lbl 559  `"55.9"', add
label define erscor50_lbl 560  `"56"', add
label define erscor50_lbl 561  `"56.1"', add
label define erscor50_lbl 562  `"56.2"', add
label define erscor50_lbl 563  `"56.3"', add
label define erscor50_lbl 564  `"56.4"', add
label define erscor50_lbl 565  `"56.5"', add
label define erscor50_lbl 566  `"56.6"', add
label define erscor50_lbl 567  `"56.7"', add
label define erscor50_lbl 568  `"56.8"', add
label define erscor50_lbl 569  `"56.9"', add
label define erscor50_lbl 570  `"57"', add
label define erscor50_lbl 571  `"57.1"', add
label define erscor50_lbl 572  `"57.2"', add
label define erscor50_lbl 573  `"57.3"', add
label define erscor50_lbl 574  `"57.4"', add
label define erscor50_lbl 575  `"57.5"', add
label define erscor50_lbl 576  `"57.6"', add
label define erscor50_lbl 577  `"57.7"', add
label define erscor50_lbl 578  `"57.8"', add
label define erscor50_lbl 579  `"57.9"', add
label define erscor50_lbl 580  `"58"', add
label define erscor50_lbl 581  `"58.1"', add
label define erscor50_lbl 582  `"58.2"', add
label define erscor50_lbl 583  `"58.3"', add
label define erscor50_lbl 584  `"58.4"', add
label define erscor50_lbl 585  `"58.5"', add
label define erscor50_lbl 586  `"58.6"', add
label define erscor50_lbl 587  `"58.7"', add
label define erscor50_lbl 588  `"58.8"', add
label define erscor50_lbl 589  `"58.9"', add
label define erscor50_lbl 590  `"59"', add
label define erscor50_lbl 591  `"59.1"', add
label define erscor50_lbl 592  `"59.2"', add
label define erscor50_lbl 593  `"59.3"', add
label define erscor50_lbl 594  `"59.4"', add
label define erscor50_lbl 595  `"59.5"', add
label define erscor50_lbl 596  `"59.6"', add
label define erscor50_lbl 597  `"59.7"', add
label define erscor50_lbl 598  `"59.8"', add
label define erscor50_lbl 599  `"59.9"', add
label define erscor50_lbl 600  `"60"', add
label define erscor50_lbl 601  `"60.1"', add
label define erscor50_lbl 602  `"60.2"', add
label define erscor50_lbl 603  `"60.3"', add
label define erscor50_lbl 604  `"60.4"', add
label define erscor50_lbl 605  `"60.5"', add
label define erscor50_lbl 606  `"60.6"', add
label define erscor50_lbl 607  `"60.7"', add
label define erscor50_lbl 608  `"60.8"', add
label define erscor50_lbl 609  `"60.9"', add
label define erscor50_lbl 610  `"61"', add
label define erscor50_lbl 611  `"61.1"', add
label define erscor50_lbl 612  `"61.2"', add
label define erscor50_lbl 613  `"61.3"', add
label define erscor50_lbl 614  `"61.4"', add
label define erscor50_lbl 615  `"61.5"', add
label define erscor50_lbl 616  `"61.6"', add
label define erscor50_lbl 617  `"61.7"', add
label define erscor50_lbl 618  `"61.8"', add
label define erscor50_lbl 619  `"61.9"', add
label define erscor50_lbl 620  `"62"', add
label define erscor50_lbl 621  `"62.1"', add
label define erscor50_lbl 622  `"62.2"', add
label define erscor50_lbl 623  `"62.3"', add
label define erscor50_lbl 624  `"62.4"', add
label define erscor50_lbl 625  `"62.5"', add
label define erscor50_lbl 626  `"62.6"', add
label define erscor50_lbl 627  `"62.7"', add
label define erscor50_lbl 628  `"62.8"', add
label define erscor50_lbl 629  `"62.9"', add
label define erscor50_lbl 630  `"63"', add
label define erscor50_lbl 631  `"63.1"', add
label define erscor50_lbl 632  `"63.2"', add
label define erscor50_lbl 633  `"63.3"', add
label define erscor50_lbl 634  `"63.4"', add
label define erscor50_lbl 635  `"63.5"', add
label define erscor50_lbl 636  `"63.6"', add
label define erscor50_lbl 637  `"63.7"', add
label define erscor50_lbl 638  `"63.8"', add
label define erscor50_lbl 639  `"63.9"', add
label define erscor50_lbl 640  `"64"', add
label define erscor50_lbl 641  `"64.1"', add
label define erscor50_lbl 642  `"64.2"', add
label define erscor50_lbl 643  `"64.3"', add
label define erscor50_lbl 644  `"64.4"', add
label define erscor50_lbl 645  `"64.5"', add
label define erscor50_lbl 646  `"64.6"', add
label define erscor50_lbl 647  `"64.7"', add
label define erscor50_lbl 648  `"64.8"', add
label define erscor50_lbl 649  `"64.9"', add
label define erscor50_lbl 650  `"65"', add
label define erscor50_lbl 651  `"65.1"', add
label define erscor50_lbl 652  `"65.2"', add
label define erscor50_lbl 653  `"65.3"', add
label define erscor50_lbl 654  `"65.4"', add
label define erscor50_lbl 655  `"65.5"', add
label define erscor50_lbl 656  `"65.6"', add
label define erscor50_lbl 657  `"65.7"', add
label define erscor50_lbl 658  `"65.8"', add
label define erscor50_lbl 659  `"65.9"', add
label define erscor50_lbl 660  `"66"', add
label define erscor50_lbl 661  `"66.1"', add
label define erscor50_lbl 662  `"66.2"', add
label define erscor50_lbl 663  `"66.3"', add
label define erscor50_lbl 664  `"66.4"', add
label define erscor50_lbl 665  `"66.5"', add
label define erscor50_lbl 666  `"66.6"', add
label define erscor50_lbl 667  `"66.7"', add
label define erscor50_lbl 668  `"66.8"', add
label define erscor50_lbl 669  `"66.9"', add
label define erscor50_lbl 670  `"67"', add
label define erscor50_lbl 671  `"67.1"', add
label define erscor50_lbl 672  `"67.2"', add
label define erscor50_lbl 673  `"67.3"', add
label define erscor50_lbl 674  `"67.4"', add
label define erscor50_lbl 675  `"67.5"', add
label define erscor50_lbl 676  `"67.6"', add
label define erscor50_lbl 677  `"67.7"', add
label define erscor50_lbl 678  `"67.8"', add
label define erscor50_lbl 679  `"67.9"', add
label define erscor50_lbl 680  `"68"', add
label define erscor50_lbl 681  `"68.1"', add
label define erscor50_lbl 682  `"68.2"', add
label define erscor50_lbl 683  `"68.3"', add
label define erscor50_lbl 684  `"68.4"', add
label define erscor50_lbl 685  `"68.5"', add
label define erscor50_lbl 686  `"68.6"', add
label define erscor50_lbl 687  `"68.7"', add
label define erscor50_lbl 688  `"68.8"', add
label define erscor50_lbl 689  `"68.9"', add
label define erscor50_lbl 690  `"69"', add
label define erscor50_lbl 691  `"69.1"', add
label define erscor50_lbl 692  `"69.2"', add
label define erscor50_lbl 693  `"69.3"', add
label define erscor50_lbl 694  `"69.4"', add
label define erscor50_lbl 695  `"69.5"', add
label define erscor50_lbl 696  `"69.6"', add
label define erscor50_lbl 697  `"69.7"', add
label define erscor50_lbl 698  `"69.8"', add
label define erscor50_lbl 699  `"69.9"', add
label define erscor50_lbl 700  `"70"', add
label define erscor50_lbl 701  `"70.1"', add
label define erscor50_lbl 702  `"70.2"', add
label define erscor50_lbl 703  `"70.3"', add
label define erscor50_lbl 704  `"70.4"', add
label define erscor50_lbl 705  `"70.5"', add
label define erscor50_lbl 706  `"70.6"', add
label define erscor50_lbl 707  `"70.7"', add
label define erscor50_lbl 708  `"70.8"', add
label define erscor50_lbl 709  `"70.9"', add
label define erscor50_lbl 710  `"71"', add
label define erscor50_lbl 711  `"71.1"', add
label define erscor50_lbl 712  `"71.2"', add
label define erscor50_lbl 713  `"71.3"', add
label define erscor50_lbl 714  `"71.4"', add
label define erscor50_lbl 715  `"71.5"', add
label define erscor50_lbl 716  `"71.6"', add
label define erscor50_lbl 717  `"71.7"', add
label define erscor50_lbl 718  `"71.8"', add
label define erscor50_lbl 719  `"71.9"', add
label define erscor50_lbl 720  `"72"', add
label define erscor50_lbl 721  `"72.1"', add
label define erscor50_lbl 722  `"72.2"', add
label define erscor50_lbl 723  `"72.3"', add
label define erscor50_lbl 724  `"72.4"', add
label define erscor50_lbl 725  `"72.5"', add
label define erscor50_lbl 726  `"72.6"', add
label define erscor50_lbl 727  `"72.7"', add
label define erscor50_lbl 728  `"72.8"', add
label define erscor50_lbl 729  `"72.9"', add
label define erscor50_lbl 730  `"73"', add
label define erscor50_lbl 731  `"73.1"', add
label define erscor50_lbl 732  `"73.2"', add
label define erscor50_lbl 733  `"73.3"', add
label define erscor50_lbl 734  `"73.4"', add
label define erscor50_lbl 735  `"73.5"', add
label define erscor50_lbl 736  `"73.6"', add
label define erscor50_lbl 737  `"73.7"', add
label define erscor50_lbl 738  `"73.8"', add
label define erscor50_lbl 739  `"73.9"', add
label define erscor50_lbl 740  `"74"', add
label define erscor50_lbl 741  `"74.1"', add
label define erscor50_lbl 742  `"74.2"', add
label define erscor50_lbl 743  `"74.3"', add
label define erscor50_lbl 744  `"74.4"', add
label define erscor50_lbl 745  `"74.5"', add
label define erscor50_lbl 746  `"74.6"', add
label define erscor50_lbl 747  `"74.7"', add
label define erscor50_lbl 748  `"74.8"', add
label define erscor50_lbl 749  `"74.9"', add
label define erscor50_lbl 750  `"75"', add
label define erscor50_lbl 751  `"75.1"', add
label define erscor50_lbl 752  `"75.2"', add
label define erscor50_lbl 753  `"75.3"', add
label define erscor50_lbl 754  `"75.4"', add
label define erscor50_lbl 755  `"75.5"', add
label define erscor50_lbl 756  `"75.6"', add
label define erscor50_lbl 757  `"75.7"', add
label define erscor50_lbl 758  `"75.8"', add
label define erscor50_lbl 759  `"75.9"', add
label define erscor50_lbl 760  `"76"', add
label define erscor50_lbl 761  `"76.1"', add
label define erscor50_lbl 762  `"76.2"', add
label define erscor50_lbl 763  `"76.3"', add
label define erscor50_lbl 764  `"76.4"', add
label define erscor50_lbl 765  `"76.5"', add
label define erscor50_lbl 766  `"76.6"', add
label define erscor50_lbl 767  `"76.7"', add
label define erscor50_lbl 768  `"76.8"', add
label define erscor50_lbl 769  `"76.9"', add
label define erscor50_lbl 770  `"77"', add
label define erscor50_lbl 771  `"77.1"', add
label define erscor50_lbl 772  `"77.2"', add
label define erscor50_lbl 773  `"77.3"', add
label define erscor50_lbl 774  `"77.4"', add
label define erscor50_lbl 775  `"77.5"', add
label define erscor50_lbl 776  `"77.6"', add
label define erscor50_lbl 777  `"77.7"', add
label define erscor50_lbl 778  `"77.8"', add
label define erscor50_lbl 779  `"77.9"', add
label define erscor50_lbl 780  `"78"', add
label define erscor50_lbl 781  `"78.1"', add
label define erscor50_lbl 782  `"78.2"', add
label define erscor50_lbl 783  `"78.3"', add
label define erscor50_lbl 784  `"78.4"', add
label define erscor50_lbl 785  `"78.5"', add
label define erscor50_lbl 786  `"78.6"', add
label define erscor50_lbl 787  `"78.7"', add
label define erscor50_lbl 788  `"78.8"', add
label define erscor50_lbl 789  `"78.9"', add
label define erscor50_lbl 790  `"79"', add
label define erscor50_lbl 791  `"79.1"', add
label define erscor50_lbl 792  `"79.2"', add
label define erscor50_lbl 793  `"79.3"', add
label define erscor50_lbl 794  `"79.4"', add
label define erscor50_lbl 795  `"79.5"', add
label define erscor50_lbl 796  `"79.6"', add
label define erscor50_lbl 797  `"79.7"', add
label define erscor50_lbl 798  `"79.8"', add
label define erscor50_lbl 799  `"79.9"', add
label define erscor50_lbl 800  `"80"', add
label define erscor50_lbl 801  `"80.1"', add
label define erscor50_lbl 802  `"80.2"', add
label define erscor50_lbl 803  `"80.3"', add
label define erscor50_lbl 804  `"80.4"', add
label define erscor50_lbl 805  `"80.5"', add
label define erscor50_lbl 806  `"80.6"', add
label define erscor50_lbl 807  `"80.7"', add
label define erscor50_lbl 808  `"80.8"', add
label define erscor50_lbl 809  `"80.9"', add
label define erscor50_lbl 810  `"81"', add
label define erscor50_lbl 811  `"81.1"', add
label define erscor50_lbl 812  `"81.2"', add
label define erscor50_lbl 813  `"81.3"', add
label define erscor50_lbl 814  `"81.4"', add
label define erscor50_lbl 815  `"81.5"', add
label define erscor50_lbl 816  `"81.6"', add
label define erscor50_lbl 817  `"81.7"', add
label define erscor50_lbl 818  `"81.8"', add
label define erscor50_lbl 819  `"81.9"', add
label define erscor50_lbl 820  `"82"', add
label define erscor50_lbl 821  `"82.1"', add
label define erscor50_lbl 822  `"82.2"', add
label define erscor50_lbl 823  `"82.3"', add
label define erscor50_lbl 824  `"82.4"', add
label define erscor50_lbl 825  `"82.5"', add
label define erscor50_lbl 826  `"82.6"', add
label define erscor50_lbl 827  `"82.7"', add
label define erscor50_lbl 828  `"82.8"', add
label define erscor50_lbl 829  `"82.9"', add
label define erscor50_lbl 830  `"83"', add
label define erscor50_lbl 831  `"83.1"', add
label define erscor50_lbl 832  `"83.2"', add
label define erscor50_lbl 833  `"83.3"', add
label define erscor50_lbl 834  `"83.4"', add
label define erscor50_lbl 835  `"83.5"', add
label define erscor50_lbl 836  `"83.6"', add
label define erscor50_lbl 837  `"83.7"', add
label define erscor50_lbl 838  `"83.8"', add
label define erscor50_lbl 839  `"83.9"', add
label define erscor50_lbl 840  `"84"', add
label define erscor50_lbl 841  `"84.1"', add
label define erscor50_lbl 842  `"84.2"', add
label define erscor50_lbl 843  `"84.3"', add
label define erscor50_lbl 844  `"84.4"', add
label define erscor50_lbl 845  `"84.5"', add
label define erscor50_lbl 846  `"84.6"', add
label define erscor50_lbl 847  `"84.7"', add
label define erscor50_lbl 848  `"84.8"', add
label define erscor50_lbl 849  `"84.9"', add
label define erscor50_lbl 850  `"85"', add
label define erscor50_lbl 851  `"85.1"', add
label define erscor50_lbl 852  `"85.2"', add
label define erscor50_lbl 853  `"85.3"', add
label define erscor50_lbl 854  `"85.4"', add
label define erscor50_lbl 855  `"85.5"', add
label define erscor50_lbl 856  `"85.6"', add
label define erscor50_lbl 857  `"85.7"', add
label define erscor50_lbl 858  `"85.8"', add
label define erscor50_lbl 859  `"85.9"', add
label define erscor50_lbl 860  `"86"', add
label define erscor50_lbl 861  `"86.1"', add
label define erscor50_lbl 862  `"86.2"', add
label define erscor50_lbl 863  `"86.3"', add
label define erscor50_lbl 864  `"86.4"', add
label define erscor50_lbl 865  `"86.5"', add
label define erscor50_lbl 866  `"86.6"', add
label define erscor50_lbl 867  `"86.7"', add
label define erscor50_lbl 868  `"86.8"', add
label define erscor50_lbl 869  `"86.9"', add
label define erscor50_lbl 870  `"87"', add
label define erscor50_lbl 871  `"87.1"', add
label define erscor50_lbl 872  `"87.2"', add
label define erscor50_lbl 873  `"87.3"', add
label define erscor50_lbl 874  `"87.4"', add
label define erscor50_lbl 875  `"87.5"', add
label define erscor50_lbl 876  `"87.6"', add
label define erscor50_lbl 877  `"87.7"', add
label define erscor50_lbl 878  `"87.8"', add
label define erscor50_lbl 879  `"87.9"', add
label define erscor50_lbl 880  `"88"', add
label define erscor50_lbl 881  `"88.1"', add
label define erscor50_lbl 882  `"88.2"', add
label define erscor50_lbl 883  `"88.3"', add
label define erscor50_lbl 884  `"88.4"', add
label define erscor50_lbl 885  `"88.5"', add
label define erscor50_lbl 886  `"88.6"', add
label define erscor50_lbl 887  `"88.7"', add
label define erscor50_lbl 888  `"88.8"', add
label define erscor50_lbl 889  `"88.9"', add
label define erscor50_lbl 890  `"89"', add
label define erscor50_lbl 891  `"89.1"', add
label define erscor50_lbl 892  `"89.2"', add
label define erscor50_lbl 893  `"89.3"', add
label define erscor50_lbl 894  `"89.4"', add
label define erscor50_lbl 895  `"89.5"', add
label define erscor50_lbl 896  `"89.6"', add
label define erscor50_lbl 897  `"89.7"', add
label define erscor50_lbl 898  `"89.8"', add
label define erscor50_lbl 899  `"89.9"', add
label define erscor50_lbl 900  `"90"', add
label define erscor50_lbl 901  `"90.1"', add
label define erscor50_lbl 902  `"90.2"', add
label define erscor50_lbl 903  `"90.3"', add
label define erscor50_lbl 904  `"90.4"', add
label define erscor50_lbl 905  `"90.5"', add
label define erscor50_lbl 906  `"90.6"', add
label define erscor50_lbl 907  `"90.7"', add
label define erscor50_lbl 908  `"90.8"', add
label define erscor50_lbl 909  `"90.9"', add
label define erscor50_lbl 910  `"91"', add
label define erscor50_lbl 911  `"91.1"', add
label define erscor50_lbl 912  `"91.2"', add
label define erscor50_lbl 913  `"91.3"', add
label define erscor50_lbl 914  `"91.4"', add
label define erscor50_lbl 915  `"91.5"', add
label define erscor50_lbl 916  `"91.6"', add
label define erscor50_lbl 917  `"91.7"', add
label define erscor50_lbl 918  `"91.8"', add
label define erscor50_lbl 919  `"91.9"', add
label define erscor50_lbl 920  `"92"', add
label define erscor50_lbl 921  `"92.1"', add
label define erscor50_lbl 922  `"92.2"', add
label define erscor50_lbl 923  `"92.3"', add
label define erscor50_lbl 924  `"92.4"', add
label define erscor50_lbl 925  `"92.5"', add
label define erscor50_lbl 926  `"92.6"', add
label define erscor50_lbl 927  `"92.7"', add
label define erscor50_lbl 928  `"92.8"', add
label define erscor50_lbl 929  `"92.9"', add
label define erscor50_lbl 930  `"93"', add
label define erscor50_lbl 931  `"93.1"', add
label define erscor50_lbl 932  `"93.2"', add
label define erscor50_lbl 933  `"93.3"', add
label define erscor50_lbl 934  `"93.4"', add
label define erscor50_lbl 935  `"93.5"', add
label define erscor50_lbl 936  `"93.6"', add
label define erscor50_lbl 937  `"93.7"', add
label define erscor50_lbl 938  `"93.8"', add
label define erscor50_lbl 939  `"93.9"', add
label define erscor50_lbl 940  `"94"', add
label define erscor50_lbl 941  `"94.1"', add
label define erscor50_lbl 942  `"94.2"', add
label define erscor50_lbl 943  `"94.3"', add
label define erscor50_lbl 944  `"94.4"', add
label define erscor50_lbl 945  `"94.5"', add
label define erscor50_lbl 946  `"94.6"', add
label define erscor50_lbl 947  `"94.7"', add
label define erscor50_lbl 948  `"94.8"', add
label define erscor50_lbl 949  `"94.9"', add
label define erscor50_lbl 950  `"95"', add
label define erscor50_lbl 951  `"95.1"', add
label define erscor50_lbl 952  `"95.2"', add
label define erscor50_lbl 953  `"95.3"', add
label define erscor50_lbl 954  `"95.4"', add
label define erscor50_lbl 955  `"95.5"', add
label define erscor50_lbl 956  `"95.6"', add
label define erscor50_lbl 957  `"95.7"', add
label define erscor50_lbl 958  `"95.8"', add
label define erscor50_lbl 959  `"95.9"', add
label define erscor50_lbl 960  `"96"', add
label define erscor50_lbl 961  `"96.1"', add
label define erscor50_lbl 962  `"96.2"', add
label define erscor50_lbl 963  `"96.3"', add
label define erscor50_lbl 964  `"96.4"', add
label define erscor50_lbl 965  `"96.5"', add
label define erscor50_lbl 966  `"96.6"', add
label define erscor50_lbl 967  `"96.7"', add
label define erscor50_lbl 968  `"96.8"', add
label define erscor50_lbl 969  `"96.9"', add
label define erscor50_lbl 970  `"97"', add
label define erscor50_lbl 971  `"97.1"', add
label define erscor50_lbl 972  `"97.2"', add
label define erscor50_lbl 973  `"97.3"', add
label define erscor50_lbl 974  `"97.4"', add
label define erscor50_lbl 975  `"97.5"', add
label define erscor50_lbl 976  `"97.6"', add
label define erscor50_lbl 977  `"97.7"', add
label define erscor50_lbl 978  `"97.8"', add
label define erscor50_lbl 979  `"97.9"', add
label define erscor50_lbl 980  `"98"', add
label define erscor50_lbl 981  `"98.1"', add
label define erscor50_lbl 982  `"98.2"', add
label define erscor50_lbl 983  `"98.3"', add
label define erscor50_lbl 984  `"98.4"', add
label define erscor50_lbl 985  `"98.5"', add
label define erscor50_lbl 986  `"98.6"', add
label define erscor50_lbl 987  `"98.7"', add
label define erscor50_lbl 988  `"98.8"', add
label define erscor50_lbl 989  `"98.9"', add
label define erscor50_lbl 990  `"99"', add
label define erscor50_lbl 991  `"99.1"', add
label define erscor50_lbl 992  `"99.2"', add
label define erscor50_lbl 993  `"99.3"', add
label define erscor50_lbl 994  `"99.4"', add
label define erscor50_lbl 995  `"99.5"', add
label define erscor50_lbl 996  `"99.6"', add
label define erscor50_lbl 997  `"99.7"', add
label define erscor50_lbl 998  `"99.8"', add
label define erscor50_lbl 999  `"99.9"', add
label define erscor50_lbl 1000 `"100"', add
label define erscor50_lbl 9999 `"N/A"', add
label values erscor50 erscor50_lbl

label define edscor50_lbl 0    `"0"'
label define edscor50_lbl 1    `"0.1"', add
label define edscor50_lbl 2    `"0.2"', add
label define edscor50_lbl 3    `"0.3"', add
label define edscor50_lbl 4    `"0.4"', add
label define edscor50_lbl 5    `"0.5"', add
label define edscor50_lbl 6    `"0.6"', add
label define edscor50_lbl 7    `"0.7"', add
label define edscor50_lbl 8    `"0.8"', add
label define edscor50_lbl 9    `"0.9"', add
label define edscor50_lbl 10   `"1"', add
label define edscor50_lbl 11   `"1.1"', add
label define edscor50_lbl 12   `"1.2"', add
label define edscor50_lbl 13   `"1.3"', add
label define edscor50_lbl 14   `"1.4"', add
label define edscor50_lbl 15   `"1.5"', add
label define edscor50_lbl 16   `"1.6"', add
label define edscor50_lbl 17   `"1.7"', add
label define edscor50_lbl 18   `"1.8"', add
label define edscor50_lbl 19   `"1.9"', add
label define edscor50_lbl 20   `"2"', add
label define edscor50_lbl 21   `"2.1"', add
label define edscor50_lbl 22   `"2.2"', add
label define edscor50_lbl 23   `"2.3"', add
label define edscor50_lbl 24   `"2.4"', add
label define edscor50_lbl 25   `"2.5"', add
label define edscor50_lbl 26   `"2.6"', add
label define edscor50_lbl 27   `"2.7"', add
label define edscor50_lbl 28   `"2.8"', add
label define edscor50_lbl 29   `"2.9"', add
label define edscor50_lbl 30   `"3"', add
label define edscor50_lbl 31   `"3.1"', add
label define edscor50_lbl 32   `"3.2"', add
label define edscor50_lbl 33   `"3.3"', add
label define edscor50_lbl 34   `"3.4"', add
label define edscor50_lbl 35   `"3.5"', add
label define edscor50_lbl 36   `"3.6"', add
label define edscor50_lbl 37   `"3.7"', add
label define edscor50_lbl 38   `"3.8"', add
label define edscor50_lbl 39   `"3.9"', add
label define edscor50_lbl 40   `"4"', add
label define edscor50_lbl 41   `"4.1"', add
label define edscor50_lbl 42   `"4.2"', add
label define edscor50_lbl 43   `"4.3"', add
label define edscor50_lbl 44   `"4.4"', add
label define edscor50_lbl 45   `"4.5"', add
label define edscor50_lbl 46   `"4.6"', add
label define edscor50_lbl 47   `"4.7"', add
label define edscor50_lbl 48   `"4.8"', add
label define edscor50_lbl 49   `"4.9"', add
label define edscor50_lbl 50   `"5"', add
label define edscor50_lbl 51   `"5.1"', add
label define edscor50_lbl 52   `"5.2"', add
label define edscor50_lbl 53   `"5.3"', add
label define edscor50_lbl 54   `"5.4"', add
label define edscor50_lbl 55   `"5.5"', add
label define edscor50_lbl 56   `"5.6"', add
label define edscor50_lbl 57   `"5.7"', add
label define edscor50_lbl 58   `"5.8"', add
label define edscor50_lbl 59   `"5.9"', add
label define edscor50_lbl 60   `"6"', add
label define edscor50_lbl 61   `"6.1"', add
label define edscor50_lbl 62   `"6.2"', add
label define edscor50_lbl 63   `"6.3"', add
label define edscor50_lbl 64   `"6.4"', add
label define edscor50_lbl 65   `"6.5"', add
label define edscor50_lbl 66   `"6.6"', add
label define edscor50_lbl 67   `"6.7"', add
label define edscor50_lbl 68   `"6.8"', add
label define edscor50_lbl 69   `"6.9"', add
label define edscor50_lbl 70   `"7"', add
label define edscor50_lbl 71   `"7.1"', add
label define edscor50_lbl 72   `"7.2"', add
label define edscor50_lbl 73   `"7.3"', add
label define edscor50_lbl 74   `"7.4"', add
label define edscor50_lbl 75   `"7.5"', add
label define edscor50_lbl 76   `"7.6"', add
label define edscor50_lbl 77   `"7.7"', add
label define edscor50_lbl 78   `"7.8"', add
label define edscor50_lbl 79   `"7.9"', add
label define edscor50_lbl 80   `"8"', add
label define edscor50_lbl 81   `"8.1"', add
label define edscor50_lbl 82   `"8.2"', add
label define edscor50_lbl 83   `"8.3"', add
label define edscor50_lbl 84   `"8.4"', add
label define edscor50_lbl 85   `"8.5"', add
label define edscor50_lbl 86   `"8.6"', add
label define edscor50_lbl 87   `"8.7"', add
label define edscor50_lbl 88   `"8.8"', add
label define edscor50_lbl 89   `"8.9"', add
label define edscor50_lbl 90   `"9"', add
label define edscor50_lbl 91   `"9.1"', add
label define edscor50_lbl 92   `"9.2"', add
label define edscor50_lbl 93   `"9.3"', add
label define edscor50_lbl 94   `"9.4"', add
label define edscor50_lbl 95   `"9.5"', add
label define edscor50_lbl 96   `"9.6"', add
label define edscor50_lbl 97   `"9.7"', add
label define edscor50_lbl 98   `"9.8"', add
label define edscor50_lbl 99   `"9.9"', add
label define edscor50_lbl 100  `"10"', add
label define edscor50_lbl 101  `"10.1"', add
label define edscor50_lbl 102  `"10.2"', add
label define edscor50_lbl 103  `"10.3"', add
label define edscor50_lbl 104  `"10.4"', add
label define edscor50_lbl 105  `"10.5"', add
label define edscor50_lbl 106  `"10.6"', add
label define edscor50_lbl 107  `"10.7"', add
label define edscor50_lbl 108  `"10.8"', add
label define edscor50_lbl 109  `"10.9"', add
label define edscor50_lbl 110  `"11"', add
label define edscor50_lbl 111  `"11.1"', add
label define edscor50_lbl 112  `"11.2"', add
label define edscor50_lbl 113  `"11.3"', add
label define edscor50_lbl 114  `"11.4"', add
label define edscor50_lbl 115  `"11.5"', add
label define edscor50_lbl 116  `"11.6"', add
label define edscor50_lbl 117  `"11.7"', add
label define edscor50_lbl 118  `"11.8"', add
label define edscor50_lbl 119  `"11.9"', add
label define edscor50_lbl 120  `"12"', add
label define edscor50_lbl 121  `"12.1"', add
label define edscor50_lbl 122  `"12.2"', add
label define edscor50_lbl 123  `"12.3"', add
label define edscor50_lbl 124  `"12.4"', add
label define edscor50_lbl 125  `"12.5"', add
label define edscor50_lbl 126  `"12.6"', add
label define edscor50_lbl 127  `"12.7"', add
label define edscor50_lbl 128  `"12.8"', add
label define edscor50_lbl 129  `"12.9"', add
label define edscor50_lbl 130  `"13"', add
label define edscor50_lbl 131  `"13.1"', add
label define edscor50_lbl 132  `"13.2"', add
label define edscor50_lbl 133  `"13.3"', add
label define edscor50_lbl 134  `"13.4"', add
label define edscor50_lbl 135  `"13.5"', add
label define edscor50_lbl 136  `"13.6"', add
label define edscor50_lbl 137  `"13.7"', add
label define edscor50_lbl 138  `"13.8"', add
label define edscor50_lbl 139  `"13.9"', add
label define edscor50_lbl 140  `"14"', add
label define edscor50_lbl 141  `"14.1"', add
label define edscor50_lbl 142  `"14.2"', add
label define edscor50_lbl 143  `"14.3"', add
label define edscor50_lbl 144  `"14.4"', add
label define edscor50_lbl 145  `"14.5"', add
label define edscor50_lbl 146  `"14.6"', add
label define edscor50_lbl 147  `"14.7"', add
label define edscor50_lbl 148  `"14.8"', add
label define edscor50_lbl 149  `"14.9"', add
label define edscor50_lbl 150  `"15"', add
label define edscor50_lbl 151  `"15.1"', add
label define edscor50_lbl 152  `"15.2"', add
label define edscor50_lbl 153  `"15.3"', add
label define edscor50_lbl 154  `"15.4"', add
label define edscor50_lbl 155  `"15.5"', add
label define edscor50_lbl 156  `"15.6"', add
label define edscor50_lbl 157  `"15.7"', add
label define edscor50_lbl 158  `"15.8"', add
label define edscor50_lbl 159  `"15.9"', add
label define edscor50_lbl 160  `"16"', add
label define edscor50_lbl 161  `"16.1"', add
label define edscor50_lbl 162  `"16.2"', add
label define edscor50_lbl 163  `"16.3"', add
label define edscor50_lbl 164  `"16.4"', add
label define edscor50_lbl 165  `"16.5"', add
label define edscor50_lbl 166  `"16.6"', add
label define edscor50_lbl 167  `"16.7"', add
label define edscor50_lbl 168  `"16.8"', add
label define edscor50_lbl 169  `"16.9"', add
label define edscor50_lbl 170  `"17"', add
label define edscor50_lbl 171  `"17.1"', add
label define edscor50_lbl 172  `"17.2"', add
label define edscor50_lbl 173  `"17.3"', add
label define edscor50_lbl 174  `"17.4"', add
label define edscor50_lbl 175  `"17.5"', add
label define edscor50_lbl 176  `"17.6"', add
label define edscor50_lbl 177  `"17.7"', add
label define edscor50_lbl 178  `"17.8"', add
label define edscor50_lbl 179  `"17.9"', add
label define edscor50_lbl 180  `"18"', add
label define edscor50_lbl 181  `"18.1"', add
label define edscor50_lbl 182  `"18.2"', add
label define edscor50_lbl 183  `"18.3"', add
label define edscor50_lbl 184  `"18.4"', add
label define edscor50_lbl 185  `"18.5"', add
label define edscor50_lbl 186  `"18.6"', add
label define edscor50_lbl 187  `"18.7"', add
label define edscor50_lbl 188  `"18.8"', add
label define edscor50_lbl 189  `"18.9"', add
label define edscor50_lbl 190  `"19"', add
label define edscor50_lbl 191  `"19.1"', add
label define edscor50_lbl 192  `"19.2"', add
label define edscor50_lbl 193  `"19.3"', add
label define edscor50_lbl 194  `"19.4"', add
label define edscor50_lbl 195  `"19.5"', add
label define edscor50_lbl 196  `"19.6"', add
label define edscor50_lbl 197  `"19.7"', add
label define edscor50_lbl 198  `"19.8"', add
label define edscor50_lbl 199  `"19.9"', add
label define edscor50_lbl 200  `"20"', add
label define edscor50_lbl 201  `"20.1"', add
label define edscor50_lbl 202  `"20.2"', add
label define edscor50_lbl 203  `"20.3"', add
label define edscor50_lbl 204  `"20.4"', add
label define edscor50_lbl 205  `"20.5"', add
label define edscor50_lbl 206  `"20.6"', add
label define edscor50_lbl 207  `"20.7"', add
label define edscor50_lbl 208  `"20.8"', add
label define edscor50_lbl 209  `"20.9"', add
label define edscor50_lbl 210  `"21"', add
label define edscor50_lbl 211  `"21.1"', add
label define edscor50_lbl 212  `"21.2"', add
label define edscor50_lbl 213  `"21.3"', add
label define edscor50_lbl 214  `"21.4"', add
label define edscor50_lbl 215  `"21.5"', add
label define edscor50_lbl 216  `"21.6"', add
label define edscor50_lbl 217  `"21.7"', add
label define edscor50_lbl 218  `"21.8"', add
label define edscor50_lbl 219  `"21.9"', add
label define edscor50_lbl 220  `"22"', add
label define edscor50_lbl 221  `"22.1"', add
label define edscor50_lbl 222  `"22.2"', add
label define edscor50_lbl 223  `"22.3"', add
label define edscor50_lbl 224  `"22.4"', add
label define edscor50_lbl 225  `"22.5"', add
label define edscor50_lbl 226  `"22.6"', add
label define edscor50_lbl 227  `"22.7"', add
label define edscor50_lbl 228  `"22.8"', add
label define edscor50_lbl 229  `"22.9"', add
label define edscor50_lbl 230  `"23"', add
label define edscor50_lbl 231  `"23.1"', add
label define edscor50_lbl 232  `"23.2"', add
label define edscor50_lbl 233  `"23.3"', add
label define edscor50_lbl 234  `"23.4"', add
label define edscor50_lbl 235  `"23.5"', add
label define edscor50_lbl 236  `"23.6"', add
label define edscor50_lbl 237  `"23.7"', add
label define edscor50_lbl 238  `"23.8"', add
label define edscor50_lbl 239  `"23.9"', add
label define edscor50_lbl 240  `"24"', add
label define edscor50_lbl 241  `"24.1"', add
label define edscor50_lbl 242  `"24.2"', add
label define edscor50_lbl 243  `"24.3"', add
label define edscor50_lbl 244  `"24.4"', add
label define edscor50_lbl 245  `"24.5"', add
label define edscor50_lbl 246  `"24.6"', add
label define edscor50_lbl 247  `"24.7"', add
label define edscor50_lbl 248  `"24.8"', add
label define edscor50_lbl 249  `"24.9"', add
label define edscor50_lbl 250  `"25"', add
label define edscor50_lbl 251  `"25.1"', add
label define edscor50_lbl 252  `"25.2"', add
label define edscor50_lbl 253  `"25.3"', add
label define edscor50_lbl 254  `"25.4"', add
label define edscor50_lbl 255  `"25.5"', add
label define edscor50_lbl 256  `"25.6"', add
label define edscor50_lbl 257  `"25.7"', add
label define edscor50_lbl 258  `"25.8"', add
label define edscor50_lbl 259  `"25.9"', add
label define edscor50_lbl 260  `"26"', add
label define edscor50_lbl 261  `"26.1"', add
label define edscor50_lbl 262  `"26.2"', add
label define edscor50_lbl 263  `"26.3"', add
label define edscor50_lbl 264  `"26.4"', add
label define edscor50_lbl 265  `"26.5"', add
label define edscor50_lbl 266  `"26.6"', add
label define edscor50_lbl 267  `"26.7"', add
label define edscor50_lbl 268  `"26.8"', add
label define edscor50_lbl 269  `"26.9"', add
label define edscor50_lbl 270  `"27"', add
label define edscor50_lbl 271  `"27.1"', add
label define edscor50_lbl 272  `"27.2"', add
label define edscor50_lbl 273  `"27.3"', add
label define edscor50_lbl 274  `"27.4"', add
label define edscor50_lbl 275  `"27.5"', add
label define edscor50_lbl 276  `"27.6"', add
label define edscor50_lbl 277  `"27.7"', add
label define edscor50_lbl 278  `"27.8"', add
label define edscor50_lbl 279  `"27.9"', add
label define edscor50_lbl 280  `"28"', add
label define edscor50_lbl 281  `"28.1"', add
label define edscor50_lbl 282  `"28.2"', add
label define edscor50_lbl 283  `"28.3"', add
label define edscor50_lbl 284  `"28.4"', add
label define edscor50_lbl 285  `"28.5"', add
label define edscor50_lbl 286  `"28.6"', add
label define edscor50_lbl 287  `"28.7"', add
label define edscor50_lbl 288  `"28.8"', add
label define edscor50_lbl 289  `"28.9"', add
label define edscor50_lbl 290  `"29"', add
label define edscor50_lbl 291  `"29.1"', add
label define edscor50_lbl 292  `"29.2"', add
label define edscor50_lbl 293  `"29.3"', add
label define edscor50_lbl 294  `"29.4"', add
label define edscor50_lbl 295  `"29.5"', add
label define edscor50_lbl 296  `"29.6"', add
label define edscor50_lbl 297  `"29.7"', add
label define edscor50_lbl 298  `"29.8"', add
label define edscor50_lbl 299  `"29.9"', add
label define edscor50_lbl 300  `"30"', add
label define edscor50_lbl 301  `"30.1"', add
label define edscor50_lbl 302  `"30.2"', add
label define edscor50_lbl 303  `"30.3"', add
label define edscor50_lbl 304  `"30.4"', add
label define edscor50_lbl 305  `"30.5"', add
label define edscor50_lbl 306  `"30.6"', add
label define edscor50_lbl 307  `"30.7"', add
label define edscor50_lbl 308  `"30.8"', add
label define edscor50_lbl 309  `"30.9"', add
label define edscor50_lbl 310  `"31"', add
label define edscor50_lbl 311  `"31.1"', add
label define edscor50_lbl 312  `"31.2"', add
label define edscor50_lbl 313  `"31.3"', add
label define edscor50_lbl 314  `"31.4"', add
label define edscor50_lbl 315  `"31.5"', add
label define edscor50_lbl 316  `"31.6"', add
label define edscor50_lbl 317  `"31.7"', add
label define edscor50_lbl 318  `"31.8"', add
label define edscor50_lbl 319  `"31.9"', add
label define edscor50_lbl 320  `"32"', add
label define edscor50_lbl 321  `"32.1"', add
label define edscor50_lbl 322  `"32.2"', add
label define edscor50_lbl 323  `"32.3"', add
label define edscor50_lbl 324  `"32.4"', add
label define edscor50_lbl 325  `"32.5"', add
label define edscor50_lbl 326  `"32.6"', add
label define edscor50_lbl 327  `"32.7"', add
label define edscor50_lbl 328  `"32.8"', add
label define edscor50_lbl 329  `"32.9"', add
label define edscor50_lbl 330  `"33"', add
label define edscor50_lbl 331  `"33.1"', add
label define edscor50_lbl 332  `"33.2"', add
label define edscor50_lbl 333  `"33.3"', add
label define edscor50_lbl 334  `"33.4"', add
label define edscor50_lbl 335  `"33.5"', add
label define edscor50_lbl 336  `"33.6"', add
label define edscor50_lbl 337  `"33.7"', add
label define edscor50_lbl 338  `"33.8"', add
label define edscor50_lbl 339  `"33.9"', add
label define edscor50_lbl 340  `"34"', add
label define edscor50_lbl 341  `"34.1"', add
label define edscor50_lbl 342  `"34.2"', add
label define edscor50_lbl 343  `"34.3"', add
label define edscor50_lbl 344  `"34.4"', add
label define edscor50_lbl 345  `"34.5"', add
label define edscor50_lbl 346  `"34.6"', add
label define edscor50_lbl 347  `"34.7"', add
label define edscor50_lbl 348  `"34.8"', add
label define edscor50_lbl 349  `"34.9"', add
label define edscor50_lbl 350  `"35"', add
label define edscor50_lbl 351  `"35.1"', add
label define edscor50_lbl 352  `"35.2"', add
label define edscor50_lbl 353  `"35.3"', add
label define edscor50_lbl 354  `"35.4"', add
label define edscor50_lbl 355  `"35.5"', add
label define edscor50_lbl 356  `"35.6"', add
label define edscor50_lbl 357  `"35.7"', add
label define edscor50_lbl 358  `"35.8"', add
label define edscor50_lbl 359  `"35.9"', add
label define edscor50_lbl 360  `"36"', add
label define edscor50_lbl 361  `"36.1"', add
label define edscor50_lbl 362  `"36.2"', add
label define edscor50_lbl 363  `"36.3"', add
label define edscor50_lbl 364  `"36.4"', add
label define edscor50_lbl 365  `"36.5"', add
label define edscor50_lbl 366  `"36.6"', add
label define edscor50_lbl 367  `"36.7"', add
label define edscor50_lbl 368  `"36.8"', add
label define edscor50_lbl 369  `"36.9"', add
label define edscor50_lbl 370  `"37"', add
label define edscor50_lbl 371  `"37.1"', add
label define edscor50_lbl 372  `"37.2"', add
label define edscor50_lbl 373  `"37.3"', add
label define edscor50_lbl 374  `"37.4"', add
label define edscor50_lbl 375  `"37.5"', add
label define edscor50_lbl 376  `"37.6"', add
label define edscor50_lbl 377  `"37.7"', add
label define edscor50_lbl 378  `"37.8"', add
label define edscor50_lbl 379  `"37.9"', add
label define edscor50_lbl 380  `"38"', add
label define edscor50_lbl 381  `"38.1"', add
label define edscor50_lbl 382  `"38.2"', add
label define edscor50_lbl 383  `"38.3"', add
label define edscor50_lbl 384  `"38.4"', add
label define edscor50_lbl 385  `"38.5"', add
label define edscor50_lbl 386  `"38.6"', add
label define edscor50_lbl 387  `"38.7"', add
label define edscor50_lbl 388  `"38.8"', add
label define edscor50_lbl 389  `"38.9"', add
label define edscor50_lbl 390  `"39"', add
label define edscor50_lbl 391  `"39.1"', add
label define edscor50_lbl 392  `"39.2"', add
label define edscor50_lbl 393  `"39.3"', add
label define edscor50_lbl 394  `"39.4"', add
label define edscor50_lbl 395  `"39.5"', add
label define edscor50_lbl 396  `"39.6"', add
label define edscor50_lbl 397  `"39.7"', add
label define edscor50_lbl 398  `"39.8"', add
label define edscor50_lbl 399  `"39.9"', add
label define edscor50_lbl 400  `"40"', add
label define edscor50_lbl 401  `"40.1"', add
label define edscor50_lbl 402  `"40.2"', add
label define edscor50_lbl 403  `"40.3"', add
label define edscor50_lbl 404  `"40.4"', add
label define edscor50_lbl 405  `"40.5"', add
label define edscor50_lbl 406  `"40.6"', add
label define edscor50_lbl 407  `"40.7"', add
label define edscor50_lbl 408  `"40.8"', add
label define edscor50_lbl 409  `"40.9"', add
label define edscor50_lbl 410  `"41"', add
label define edscor50_lbl 411  `"41.1"', add
label define edscor50_lbl 412  `"41.2"', add
label define edscor50_lbl 413  `"41.3"', add
label define edscor50_lbl 414  `"41.4"', add
label define edscor50_lbl 415  `"41.5"', add
label define edscor50_lbl 416  `"41.6"', add
label define edscor50_lbl 417  `"41.7"', add
label define edscor50_lbl 418  `"41.8"', add
label define edscor50_lbl 419  `"41.9"', add
label define edscor50_lbl 420  `"42"', add
label define edscor50_lbl 421  `"42.1"', add
label define edscor50_lbl 422  `"42.2"', add
label define edscor50_lbl 423  `"42.3"', add
label define edscor50_lbl 424  `"42.4"', add
label define edscor50_lbl 425  `"42.5"', add
label define edscor50_lbl 426  `"42.6"', add
label define edscor50_lbl 427  `"42.7"', add
label define edscor50_lbl 428  `"42.8"', add
label define edscor50_lbl 429  `"42.9"', add
label define edscor50_lbl 430  `"43"', add
label define edscor50_lbl 431  `"43.1"', add
label define edscor50_lbl 432  `"43.2"', add
label define edscor50_lbl 433  `"43.3"', add
label define edscor50_lbl 434  `"43.4"', add
label define edscor50_lbl 435  `"43.5"', add
label define edscor50_lbl 436  `"43.6"', add
label define edscor50_lbl 437  `"43.7"', add
label define edscor50_lbl 438  `"43.8"', add
label define edscor50_lbl 439  `"43.9"', add
label define edscor50_lbl 440  `"44"', add
label define edscor50_lbl 441  `"44.1"', add
label define edscor50_lbl 442  `"44.2"', add
label define edscor50_lbl 443  `"44.3"', add
label define edscor50_lbl 444  `"44.4"', add
label define edscor50_lbl 445  `"44.5"', add
label define edscor50_lbl 446  `"44.6"', add
label define edscor50_lbl 447  `"44.7"', add
label define edscor50_lbl 448  `"44.8"', add
label define edscor50_lbl 449  `"44.9"', add
label define edscor50_lbl 450  `"45"', add
label define edscor50_lbl 451  `"45.1"', add
label define edscor50_lbl 452  `"45.2"', add
label define edscor50_lbl 453  `"45.3"', add
label define edscor50_lbl 454  `"45.4"', add
label define edscor50_lbl 455  `"45.5"', add
label define edscor50_lbl 456  `"45.6"', add
label define edscor50_lbl 457  `"45.7"', add
label define edscor50_lbl 458  `"45.8"', add
label define edscor50_lbl 459  `"45.9"', add
label define edscor50_lbl 460  `"46"', add
label define edscor50_lbl 461  `"46.1"', add
label define edscor50_lbl 462  `"46.2"', add
label define edscor50_lbl 463  `"46.3"', add
label define edscor50_lbl 464  `"46.4"', add
label define edscor50_lbl 465  `"46.5"', add
label define edscor50_lbl 466  `"46.6"', add
label define edscor50_lbl 467  `"46.7"', add
label define edscor50_lbl 468  `"46.8"', add
label define edscor50_lbl 469  `"46.9"', add
label define edscor50_lbl 470  `"47"', add
label define edscor50_lbl 471  `"47.1"', add
label define edscor50_lbl 472  `"47.2"', add
label define edscor50_lbl 473  `"47.3"', add
label define edscor50_lbl 474  `"47.4"', add
label define edscor50_lbl 475  `"47.5"', add
label define edscor50_lbl 476  `"47.6"', add
label define edscor50_lbl 477  `"47.7"', add
label define edscor50_lbl 478  `"47.8"', add
label define edscor50_lbl 479  `"47.9"', add
label define edscor50_lbl 480  `"48"', add
label define edscor50_lbl 481  `"48.1"', add
label define edscor50_lbl 482  `"48.2"', add
label define edscor50_lbl 483  `"48.3"', add
label define edscor50_lbl 484  `"48.4"', add
label define edscor50_lbl 485  `"48.5"', add
label define edscor50_lbl 486  `"48.6"', add
label define edscor50_lbl 487  `"48.7"', add
label define edscor50_lbl 488  `"48.8"', add
label define edscor50_lbl 489  `"48.9"', add
label define edscor50_lbl 490  `"49"', add
label define edscor50_lbl 491  `"49.1"', add
label define edscor50_lbl 492  `"49.2"', add
label define edscor50_lbl 493  `"49.3"', add
label define edscor50_lbl 494  `"49.4"', add
label define edscor50_lbl 495  `"49.5"', add
label define edscor50_lbl 496  `"49.6"', add
label define edscor50_lbl 497  `"49.7"', add
label define edscor50_lbl 498  `"49.8"', add
label define edscor50_lbl 499  `"49.9"', add
label define edscor50_lbl 500  `"50"', add
label define edscor50_lbl 501  `"50.1"', add
label define edscor50_lbl 502  `"50.2"', add
label define edscor50_lbl 503  `"50.3"', add
label define edscor50_lbl 504  `"50.4"', add
label define edscor50_lbl 505  `"50.5"', add
label define edscor50_lbl 506  `"50.6"', add
label define edscor50_lbl 507  `"50.7"', add
label define edscor50_lbl 508  `"50.8"', add
label define edscor50_lbl 509  `"50.9"', add
label define edscor50_lbl 510  `"51"', add
label define edscor50_lbl 511  `"51.1"', add
label define edscor50_lbl 512  `"51.2"', add
label define edscor50_lbl 513  `"51.3"', add
label define edscor50_lbl 514  `"51.4"', add
label define edscor50_lbl 515  `"51.5"', add
label define edscor50_lbl 516  `"51.6"', add
label define edscor50_lbl 517  `"51.7"', add
label define edscor50_lbl 518  `"51.8"', add
label define edscor50_lbl 519  `"51.9"', add
label define edscor50_lbl 520  `"52"', add
label define edscor50_lbl 521  `"52.1"', add
label define edscor50_lbl 522  `"52.2"', add
label define edscor50_lbl 523  `"52.3"', add
label define edscor50_lbl 524  `"52.4"', add
label define edscor50_lbl 525  `"52.5"', add
label define edscor50_lbl 526  `"52.6"', add
label define edscor50_lbl 527  `"52.7"', add
label define edscor50_lbl 528  `"52.8"', add
label define edscor50_lbl 529  `"52.9"', add
label define edscor50_lbl 530  `"53"', add
label define edscor50_lbl 531  `"53.1"', add
label define edscor50_lbl 532  `"53.2"', add
label define edscor50_lbl 533  `"53.3"', add
label define edscor50_lbl 534  `"53.4"', add
label define edscor50_lbl 535  `"53.5"', add
label define edscor50_lbl 536  `"53.6"', add
label define edscor50_lbl 537  `"53.7"', add
label define edscor50_lbl 538  `"53.8"', add
label define edscor50_lbl 539  `"53.9"', add
label define edscor50_lbl 540  `"54"', add
label define edscor50_lbl 541  `"54.1"', add
label define edscor50_lbl 542  `"54.2"', add
label define edscor50_lbl 543  `"54.3"', add
label define edscor50_lbl 544  `"54.4"', add
label define edscor50_lbl 545  `"54.5"', add
label define edscor50_lbl 546  `"54.6"', add
label define edscor50_lbl 547  `"54.7"', add
label define edscor50_lbl 548  `"54.8"', add
label define edscor50_lbl 549  `"54.9"', add
label define edscor50_lbl 550  `"55"', add
label define edscor50_lbl 551  `"55.1"', add
label define edscor50_lbl 552  `"55.2"', add
label define edscor50_lbl 553  `"55.3"', add
label define edscor50_lbl 554  `"55.4"', add
label define edscor50_lbl 555  `"55.5"', add
label define edscor50_lbl 556  `"55.6"', add
label define edscor50_lbl 557  `"55.7"', add
label define edscor50_lbl 558  `"55.8"', add
label define edscor50_lbl 559  `"55.9"', add
label define edscor50_lbl 560  `"56"', add
label define edscor50_lbl 561  `"56.1"', add
label define edscor50_lbl 562  `"56.2"', add
label define edscor50_lbl 563  `"56.3"', add
label define edscor50_lbl 564  `"56.4"', add
label define edscor50_lbl 565  `"56.5"', add
label define edscor50_lbl 566  `"56.6"', add
label define edscor50_lbl 567  `"56.7"', add
label define edscor50_lbl 568  `"56.8"', add
label define edscor50_lbl 569  `"56.9"', add
label define edscor50_lbl 570  `"57"', add
label define edscor50_lbl 571  `"57.1"', add
label define edscor50_lbl 572  `"57.2"', add
label define edscor50_lbl 573  `"57.3"', add
label define edscor50_lbl 574  `"57.4"', add
label define edscor50_lbl 575  `"57.5"', add
label define edscor50_lbl 576  `"57.6"', add
label define edscor50_lbl 577  `"57.7"', add
label define edscor50_lbl 578  `"57.8"', add
label define edscor50_lbl 579  `"57.9"', add
label define edscor50_lbl 580  `"58"', add
label define edscor50_lbl 581  `"58.1"', add
label define edscor50_lbl 582  `"58.2"', add
label define edscor50_lbl 583  `"58.3"', add
label define edscor50_lbl 584  `"58.4"', add
label define edscor50_lbl 585  `"58.5"', add
label define edscor50_lbl 586  `"58.6"', add
label define edscor50_lbl 587  `"58.7"', add
label define edscor50_lbl 588  `"58.8"', add
label define edscor50_lbl 589  `"58.9"', add
label define edscor50_lbl 590  `"59"', add
label define edscor50_lbl 591  `"59.1"', add
label define edscor50_lbl 592  `"59.2"', add
label define edscor50_lbl 593  `"59.3"', add
label define edscor50_lbl 594  `"59.4"', add
label define edscor50_lbl 595  `"59.5"', add
label define edscor50_lbl 596  `"59.6"', add
label define edscor50_lbl 597  `"59.7"', add
label define edscor50_lbl 598  `"59.8"', add
label define edscor50_lbl 599  `"59.9"', add
label define edscor50_lbl 600  `"60"', add
label define edscor50_lbl 601  `"60.1"', add
label define edscor50_lbl 602  `"60.2"', add
label define edscor50_lbl 603  `"60.3"', add
label define edscor50_lbl 604  `"60.4"', add
label define edscor50_lbl 605  `"60.5"', add
label define edscor50_lbl 606  `"60.6"', add
label define edscor50_lbl 607  `"60.7"', add
label define edscor50_lbl 608  `"60.8"', add
label define edscor50_lbl 609  `"60.9"', add
label define edscor50_lbl 610  `"61"', add
label define edscor50_lbl 611  `"61.1"', add
label define edscor50_lbl 612  `"61.2"', add
label define edscor50_lbl 613  `"61.3"', add
label define edscor50_lbl 614  `"61.4"', add
label define edscor50_lbl 615  `"61.5"', add
label define edscor50_lbl 616  `"61.6"', add
label define edscor50_lbl 617  `"61.7"', add
label define edscor50_lbl 618  `"61.8"', add
label define edscor50_lbl 619  `"61.9"', add
label define edscor50_lbl 620  `"62"', add
label define edscor50_lbl 621  `"62.1"', add
label define edscor50_lbl 622  `"62.2"', add
label define edscor50_lbl 623  `"62.3"', add
label define edscor50_lbl 624  `"62.4"', add
label define edscor50_lbl 625  `"62.5"', add
label define edscor50_lbl 626  `"62.6"', add
label define edscor50_lbl 627  `"62.7"', add
label define edscor50_lbl 628  `"62.8"', add
label define edscor50_lbl 629  `"62.9"', add
label define edscor50_lbl 630  `"63"', add
label define edscor50_lbl 631  `"63.1"', add
label define edscor50_lbl 632  `"63.2"', add
label define edscor50_lbl 633  `"63.3"', add
label define edscor50_lbl 634  `"63.4"', add
label define edscor50_lbl 635  `"63.5"', add
label define edscor50_lbl 636  `"63.6"', add
label define edscor50_lbl 637  `"63.7"', add
label define edscor50_lbl 638  `"63.8"', add
label define edscor50_lbl 639  `"63.9"', add
label define edscor50_lbl 640  `"64"', add
label define edscor50_lbl 641  `"64.1"', add
label define edscor50_lbl 642  `"64.2"', add
label define edscor50_lbl 643  `"64.3"', add
label define edscor50_lbl 644  `"64.4"', add
label define edscor50_lbl 645  `"64.5"', add
label define edscor50_lbl 646  `"64.6"', add
label define edscor50_lbl 647  `"64.7"', add
label define edscor50_lbl 648  `"64.8"', add
label define edscor50_lbl 649  `"64.9"', add
label define edscor50_lbl 650  `"65"', add
label define edscor50_lbl 651  `"65.1"', add
label define edscor50_lbl 652  `"65.2"', add
label define edscor50_lbl 653  `"65.3"', add
label define edscor50_lbl 654  `"65.4"', add
label define edscor50_lbl 655  `"65.5"', add
label define edscor50_lbl 656  `"65.6"', add
label define edscor50_lbl 657  `"65.7"', add
label define edscor50_lbl 658  `"65.8"', add
label define edscor50_lbl 659  `"65.9"', add
label define edscor50_lbl 660  `"66"', add
label define edscor50_lbl 661  `"66.1"', add
label define edscor50_lbl 662  `"66.2"', add
label define edscor50_lbl 663  `"66.3"', add
label define edscor50_lbl 664  `"66.4"', add
label define edscor50_lbl 665  `"66.5"', add
label define edscor50_lbl 666  `"66.6"', add
label define edscor50_lbl 667  `"66.7"', add
label define edscor50_lbl 668  `"66.8"', add
label define edscor50_lbl 669  `"66.9"', add
label define edscor50_lbl 670  `"67"', add
label define edscor50_lbl 671  `"67.1"', add
label define edscor50_lbl 672  `"67.2"', add
label define edscor50_lbl 673  `"67.3"', add
label define edscor50_lbl 674  `"67.4"', add
label define edscor50_lbl 675  `"67.5"', add
label define edscor50_lbl 676  `"67.6"', add
label define edscor50_lbl 677  `"67.7"', add
label define edscor50_lbl 678  `"67.8"', add
label define edscor50_lbl 679  `"67.9"', add
label define edscor50_lbl 680  `"68"', add
label define edscor50_lbl 681  `"68.1"', add
label define edscor50_lbl 682  `"68.2"', add
label define edscor50_lbl 683  `"68.3"', add
label define edscor50_lbl 684  `"68.4"', add
label define edscor50_lbl 685  `"68.5"', add
label define edscor50_lbl 686  `"68.6"', add
label define edscor50_lbl 687  `"68.7"', add
label define edscor50_lbl 688  `"68.8"', add
label define edscor50_lbl 689  `"68.9"', add
label define edscor50_lbl 690  `"69"', add
label define edscor50_lbl 691  `"69.1"', add
label define edscor50_lbl 692  `"69.2"', add
label define edscor50_lbl 693  `"69.3"', add
label define edscor50_lbl 694  `"69.4"', add
label define edscor50_lbl 695  `"69.5"', add
label define edscor50_lbl 696  `"69.6"', add
label define edscor50_lbl 697  `"69.7"', add
label define edscor50_lbl 698  `"69.8"', add
label define edscor50_lbl 699  `"69.9"', add
label define edscor50_lbl 700  `"70"', add
label define edscor50_lbl 701  `"70.1"', add
label define edscor50_lbl 702  `"70.2"', add
label define edscor50_lbl 703  `"70.3"', add
label define edscor50_lbl 704  `"70.4"', add
label define edscor50_lbl 705  `"70.5"', add
label define edscor50_lbl 706  `"70.6"', add
label define edscor50_lbl 707  `"70.7"', add
label define edscor50_lbl 708  `"70.8"', add
label define edscor50_lbl 709  `"70.9"', add
label define edscor50_lbl 710  `"71"', add
label define edscor50_lbl 711  `"71.1"', add
label define edscor50_lbl 712  `"71.2"', add
label define edscor50_lbl 713  `"71.3"', add
label define edscor50_lbl 714  `"71.4"', add
label define edscor50_lbl 715  `"71.5"', add
label define edscor50_lbl 716  `"71.6"', add
label define edscor50_lbl 717  `"71.7"', add
label define edscor50_lbl 718  `"71.8"', add
label define edscor50_lbl 719  `"71.9"', add
label define edscor50_lbl 720  `"72"', add
label define edscor50_lbl 721  `"72.1"', add
label define edscor50_lbl 722  `"72.2"', add
label define edscor50_lbl 723  `"72.3"', add
label define edscor50_lbl 724  `"72.4"', add
label define edscor50_lbl 725  `"72.5"', add
label define edscor50_lbl 726  `"72.6"', add
label define edscor50_lbl 727  `"72.7"', add
label define edscor50_lbl 728  `"72.8"', add
label define edscor50_lbl 729  `"72.9"', add
label define edscor50_lbl 730  `"73"', add
label define edscor50_lbl 731  `"73.1"', add
label define edscor50_lbl 732  `"73.2"', add
label define edscor50_lbl 733  `"73.3"', add
label define edscor50_lbl 734  `"73.4"', add
label define edscor50_lbl 735  `"73.5"', add
label define edscor50_lbl 736  `"73.6"', add
label define edscor50_lbl 737  `"73.7"', add
label define edscor50_lbl 738  `"73.8"', add
label define edscor50_lbl 739  `"73.9"', add
label define edscor50_lbl 740  `"74"', add
label define edscor50_lbl 741  `"74.1"', add
label define edscor50_lbl 742  `"74.2"', add
label define edscor50_lbl 743  `"74.3"', add
label define edscor50_lbl 744  `"74.4"', add
label define edscor50_lbl 745  `"74.5"', add
label define edscor50_lbl 746  `"74.6"', add
label define edscor50_lbl 747  `"74.7"', add
label define edscor50_lbl 748  `"74.8"', add
label define edscor50_lbl 749  `"74.9"', add
label define edscor50_lbl 750  `"75"', add
label define edscor50_lbl 751  `"75.1"', add
label define edscor50_lbl 752  `"75.2"', add
label define edscor50_lbl 753  `"75.3"', add
label define edscor50_lbl 754  `"75.4"', add
label define edscor50_lbl 755  `"75.5"', add
label define edscor50_lbl 756  `"75.6"', add
label define edscor50_lbl 757  `"75.7"', add
label define edscor50_lbl 758  `"75.8"', add
label define edscor50_lbl 759  `"75.9"', add
label define edscor50_lbl 760  `"76"', add
label define edscor50_lbl 761  `"76.1"', add
label define edscor50_lbl 762  `"76.2"', add
label define edscor50_lbl 763  `"76.3"', add
label define edscor50_lbl 764  `"76.4"', add
label define edscor50_lbl 765  `"76.5"', add
label define edscor50_lbl 766  `"76.6"', add
label define edscor50_lbl 767  `"76.7"', add
label define edscor50_lbl 768  `"76.8"', add
label define edscor50_lbl 769  `"76.9"', add
label define edscor50_lbl 770  `"77"', add
label define edscor50_lbl 771  `"77.1"', add
label define edscor50_lbl 772  `"77.2"', add
label define edscor50_lbl 773  `"77.3"', add
label define edscor50_lbl 774  `"77.4"', add
label define edscor50_lbl 775  `"77.5"', add
label define edscor50_lbl 776  `"77.6"', add
label define edscor50_lbl 777  `"77.7"', add
label define edscor50_lbl 778  `"77.8"', add
label define edscor50_lbl 779  `"77.9"', add
label define edscor50_lbl 780  `"78"', add
label define edscor50_lbl 781  `"78.1"', add
label define edscor50_lbl 782  `"78.2"', add
label define edscor50_lbl 783  `"78.3"', add
label define edscor50_lbl 784  `"78.4"', add
label define edscor50_lbl 785  `"78.5"', add
label define edscor50_lbl 786  `"78.6"', add
label define edscor50_lbl 787  `"78.7"', add
label define edscor50_lbl 788  `"78.8"', add
label define edscor50_lbl 789  `"78.9"', add
label define edscor50_lbl 790  `"79"', add
label define edscor50_lbl 791  `"79.1"', add
label define edscor50_lbl 792  `"79.2"', add
label define edscor50_lbl 793  `"79.3"', add
label define edscor50_lbl 794  `"79.4"', add
label define edscor50_lbl 795  `"79.5"', add
label define edscor50_lbl 796  `"79.6"', add
label define edscor50_lbl 797  `"79.7"', add
label define edscor50_lbl 798  `"79.8"', add
label define edscor50_lbl 799  `"79.9"', add
label define edscor50_lbl 800  `"80"', add
label define edscor50_lbl 801  `"80.1"', add
label define edscor50_lbl 802  `"80.2"', add
label define edscor50_lbl 803  `"80.3"', add
label define edscor50_lbl 804  `"80.4"', add
label define edscor50_lbl 805  `"80.5"', add
label define edscor50_lbl 806  `"80.6"', add
label define edscor50_lbl 807  `"80.7"', add
label define edscor50_lbl 808  `"80.8"', add
label define edscor50_lbl 809  `"80.9"', add
label define edscor50_lbl 810  `"81"', add
label define edscor50_lbl 811  `"81.1"', add
label define edscor50_lbl 812  `"81.2"', add
label define edscor50_lbl 813  `"81.3"', add
label define edscor50_lbl 814  `"81.4"', add
label define edscor50_lbl 815  `"81.5"', add
label define edscor50_lbl 816  `"81.6"', add
label define edscor50_lbl 817  `"81.7"', add
label define edscor50_lbl 818  `"81.8"', add
label define edscor50_lbl 819  `"81.9"', add
label define edscor50_lbl 820  `"82"', add
label define edscor50_lbl 821  `"82.1"', add
label define edscor50_lbl 822  `"82.2"', add
label define edscor50_lbl 823  `"82.3"', add
label define edscor50_lbl 824  `"82.4"', add
label define edscor50_lbl 825  `"82.5"', add
label define edscor50_lbl 826  `"82.6"', add
label define edscor50_lbl 827  `"82.7"', add
label define edscor50_lbl 828  `"82.8"', add
label define edscor50_lbl 829  `"82.9"', add
label define edscor50_lbl 830  `"83"', add
label define edscor50_lbl 831  `"83.1"', add
label define edscor50_lbl 832  `"83.2"', add
label define edscor50_lbl 833  `"83.3"', add
label define edscor50_lbl 834  `"83.4"', add
label define edscor50_lbl 835  `"83.5"', add
label define edscor50_lbl 836  `"83.6"', add
label define edscor50_lbl 837  `"83.7"', add
label define edscor50_lbl 838  `"83.8"', add
label define edscor50_lbl 839  `"83.9"', add
label define edscor50_lbl 840  `"84"', add
label define edscor50_lbl 841  `"84.1"', add
label define edscor50_lbl 842  `"84.2"', add
label define edscor50_lbl 843  `"84.3"', add
label define edscor50_lbl 844  `"84.4"', add
label define edscor50_lbl 845  `"84.5"', add
label define edscor50_lbl 846  `"84.6"', add
label define edscor50_lbl 847  `"84.7"', add
label define edscor50_lbl 848  `"84.8"', add
label define edscor50_lbl 849  `"84.9"', add
label define edscor50_lbl 850  `"85"', add
label define edscor50_lbl 851  `"85.1"', add
label define edscor50_lbl 852  `"85.2"', add
label define edscor50_lbl 853  `"85.3"', add
label define edscor50_lbl 854  `"85.4"', add
label define edscor50_lbl 855  `"85.5"', add
label define edscor50_lbl 856  `"85.6"', add
label define edscor50_lbl 857  `"85.7"', add
label define edscor50_lbl 858  `"85.8"', add
label define edscor50_lbl 859  `"85.9"', add
label define edscor50_lbl 860  `"86"', add
label define edscor50_lbl 861  `"86.1"', add
label define edscor50_lbl 862  `"86.2"', add
label define edscor50_lbl 863  `"86.3"', add
label define edscor50_lbl 864  `"86.4"', add
label define edscor50_lbl 865  `"86.5"', add
label define edscor50_lbl 866  `"86.6"', add
label define edscor50_lbl 867  `"86.7"', add
label define edscor50_lbl 868  `"86.8"', add
label define edscor50_lbl 869  `"86.9"', add
label define edscor50_lbl 870  `"87"', add
label define edscor50_lbl 871  `"87.1"', add
label define edscor50_lbl 872  `"87.2"', add
label define edscor50_lbl 873  `"87.3"', add
label define edscor50_lbl 874  `"87.4"', add
label define edscor50_lbl 875  `"87.5"', add
label define edscor50_lbl 876  `"87.6"', add
label define edscor50_lbl 877  `"87.7"', add
label define edscor50_lbl 878  `"87.8"', add
label define edscor50_lbl 879  `"87.9"', add
label define edscor50_lbl 880  `"88"', add
label define edscor50_lbl 881  `"88.1"', add
label define edscor50_lbl 882  `"88.2"', add
label define edscor50_lbl 883  `"88.3"', add
label define edscor50_lbl 884  `"88.4"', add
label define edscor50_lbl 885  `"88.5"', add
label define edscor50_lbl 886  `"88.6"', add
label define edscor50_lbl 887  `"88.7"', add
label define edscor50_lbl 888  `"88.8"', add
label define edscor50_lbl 889  `"88.9"', add
label define edscor50_lbl 890  `"89"', add
label define edscor50_lbl 891  `"89.1"', add
label define edscor50_lbl 892  `"89.2"', add
label define edscor50_lbl 893  `"89.3"', add
label define edscor50_lbl 894  `"89.4"', add
label define edscor50_lbl 895  `"89.5"', add
label define edscor50_lbl 896  `"89.6"', add
label define edscor50_lbl 897  `"89.7"', add
label define edscor50_lbl 898  `"89.8"', add
label define edscor50_lbl 899  `"89.9"', add
label define edscor50_lbl 900  `"90"', add
label define edscor50_lbl 901  `"90.1"', add
label define edscor50_lbl 902  `"90.2"', add
label define edscor50_lbl 903  `"90.3"', add
label define edscor50_lbl 904  `"90.4"', add
label define edscor50_lbl 905  `"90.5"', add
label define edscor50_lbl 906  `"90.6"', add
label define edscor50_lbl 907  `"90.7"', add
label define edscor50_lbl 908  `"90.8"', add
label define edscor50_lbl 909  `"90.9"', add
label define edscor50_lbl 910  `"91"', add
label define edscor50_lbl 911  `"91.1"', add
label define edscor50_lbl 912  `"91.2"', add
label define edscor50_lbl 913  `"91.3"', add
label define edscor50_lbl 914  `"91.4"', add
label define edscor50_lbl 915  `"91.5"', add
label define edscor50_lbl 916  `"91.6"', add
label define edscor50_lbl 917  `"91.7"', add
label define edscor50_lbl 918  `"91.8"', add
label define edscor50_lbl 919  `"91.9"', add
label define edscor50_lbl 920  `"92"', add
label define edscor50_lbl 921  `"92.1"', add
label define edscor50_lbl 922  `"92.2"', add
label define edscor50_lbl 923  `"92.3"', add
label define edscor50_lbl 924  `"92.4"', add
label define edscor50_lbl 925  `"92.5"', add
label define edscor50_lbl 926  `"92.6"', add
label define edscor50_lbl 927  `"92.7"', add
label define edscor50_lbl 928  `"92.8"', add
label define edscor50_lbl 929  `"92.9"', add
label define edscor50_lbl 930  `"93"', add
label define edscor50_lbl 931  `"93.1"', add
label define edscor50_lbl 932  `"93.2"', add
label define edscor50_lbl 933  `"93.3"', add
label define edscor50_lbl 934  `"93.4"', add
label define edscor50_lbl 935  `"93.5"', add
label define edscor50_lbl 936  `"93.6"', add
label define edscor50_lbl 937  `"93.7"', add
label define edscor50_lbl 938  `"93.8"', add
label define edscor50_lbl 939  `"93.9"', add
label define edscor50_lbl 940  `"94"', add
label define edscor50_lbl 941  `"94.1"', add
label define edscor50_lbl 942  `"94.2"', add
label define edscor50_lbl 943  `"94.3"', add
label define edscor50_lbl 944  `"94.4"', add
label define edscor50_lbl 945  `"94.5"', add
label define edscor50_lbl 946  `"94.6"', add
label define edscor50_lbl 947  `"94.7"', add
label define edscor50_lbl 948  `"94.8"', add
label define edscor50_lbl 949  `"94.9"', add
label define edscor50_lbl 950  `"95"', add
label define edscor50_lbl 951  `"95.1"', add
label define edscor50_lbl 952  `"95.2"', add
label define edscor50_lbl 953  `"95.3"', add
label define edscor50_lbl 954  `"95.4"', add
label define edscor50_lbl 955  `"95.5"', add
label define edscor50_lbl 956  `"95.6"', add
label define edscor50_lbl 957  `"95.7"', add
label define edscor50_lbl 958  `"95.8"', add
label define edscor50_lbl 959  `"95.9"', add
label define edscor50_lbl 960  `"96"', add
label define edscor50_lbl 961  `"96.1"', add
label define edscor50_lbl 962  `"96.2"', add
label define edscor50_lbl 963  `"96.3"', add
label define edscor50_lbl 964  `"96.4"', add
label define edscor50_lbl 965  `"96.5"', add
label define edscor50_lbl 966  `"96.6"', add
label define edscor50_lbl 967  `"96.7"', add
label define edscor50_lbl 968  `"96.8"', add
label define edscor50_lbl 969  `"96.9"', add
label define edscor50_lbl 970  `"97"', add
label define edscor50_lbl 971  `"97.1"', add
label define edscor50_lbl 972  `"97.2"', add
label define edscor50_lbl 973  `"97.3"', add
label define edscor50_lbl 974  `"97.4"', add
label define edscor50_lbl 975  `"97.5"', add
label define edscor50_lbl 976  `"97.6"', add
label define edscor50_lbl 977  `"97.7"', add
label define edscor50_lbl 978  `"97.8"', add
label define edscor50_lbl 979  `"97.9"', add
label define edscor50_lbl 980  `"98"', add
label define edscor50_lbl 981  `"98.1"', add
label define edscor50_lbl 982  `"98.2"', add
label define edscor50_lbl 983  `"98.3"', add
label define edscor50_lbl 984  `"98.4"', add
label define edscor50_lbl 985  `"98.5"', add
label define edscor50_lbl 986  `"98.6"', add
label define edscor50_lbl 987  `"98.7"', add
label define edscor50_lbl 988  `"98.8"', add
label define edscor50_lbl 989  `"98.9"', add
label define edscor50_lbl 990  `"99"', add
label define edscor50_lbl 991  `"99.1"', add
label define edscor50_lbl 992  `"99.2"', add
label define edscor50_lbl 993  `"99.3"', add
label define edscor50_lbl 994  `"99.4"', add
label define edscor50_lbl 995  `"99.5"', add
label define edscor50_lbl 996  `"99.6"', add
label define edscor50_lbl 997  `"99.7"', add
label define edscor50_lbl 998  `"99.8"', add
label define edscor50_lbl 999  `"99.9"', add
label define edscor50_lbl 1000 `"100"', add
label define edscor50_lbl 9999 `"N/A"', add
label values edscor50 edscor50_lbl

label define npboss50_lbl 9999 `"N/A"'
label values npboss50 npboss50_lbl

label define agemonth_lbl 0  `"0 months old"'
label define agemonth_lbl 1  `"1 month old"', add
label define agemonth_lbl 2  `"2"', add
label define agemonth_lbl 3  `"3"', add
label define agemonth_lbl 4  `"4"', add
label define agemonth_lbl 5  `"5"', add
label define agemonth_lbl 6  `"6"', add
label define agemonth_lbl 7  `"7"', add
label define agemonth_lbl 8  `"8"', add
label define agemonth_lbl 9  `"9"', add
label define agemonth_lbl 10 `"10"', add
label define agemonth_lbl 11 `"11"', add
label define agemonth_lbl 12 `"12"', add
label define agemonth_lbl 98 `"Unknown/illegible"', add
label define agemonth_lbl 99 `"N/A or blank"', add
label values agemonth agemonth_lbl

label define blind_lbl 0 `"N/A"'
label define blind_lbl 1 `"No (blank)"', add
label define blind_lbl 2 `"Yes"', add
label define blind_lbl 8 `"Illegible"', add
label define blind_lbl 9 `"Unknown"', add
label values blind blind_lbl

label define deaf_lbl 0 `"N/A"'
label define deaf_lbl 1 `"No (blank)"', add
label define deaf_lbl 2 `"Yes"', add
label define deaf_lbl 3 `"Dumb only"', add
label define deaf_lbl 4 `"Deaf only"', add
label define deaf_lbl 8 `"Illegible"', add
label define deaf_lbl 9 `"Unknown"', add
label values deaf deaf_lbl

label define idiotic_lbl 1 `"No (blank)"'
label define idiotic_lbl 2 `"Yes"', add
label define idiotic_lbl 9 `"Unknown"', add
label values idiotic idiotic_lbl

label define insane_lbl 1 `"No (blank)"'
label define insane_lbl 2 `"Yes"', add
label define insane_lbl 9 `"Unknown"', add
label values insane insane_lbl

label define crime_lbl 1 `"Drunk or disorderly"'
label define crime_lbl 2 `"Theft, burglary, larceny"', add
label define crime_lbl 3 `"Assault"', add
label define crime_lbl 4 `"Rape"', add
label define crime_lbl 5 `"Murder, manslaughter"', add
label define crime_lbl 6 `"Miscellaneous"', add
label define crime_lbl 7 `"Convict/in jail"', add
label define crime_lbl 8 `"Unknown"', add
label define crime_lbl 9 `"Blank"', add
label values crime crime_lbl

label define pauper_lbl 1 `"No (blank)"'
label define pauper_lbl 2 `"Yes"', add
label define pauper_lbl 9 `"Unknown"', add
label values pauper pauper_lbl

label define sursim_lbl 0  `"N/A (sampled at the individual level)"'
label define sursim_lbl 1  `"1st surname in household"', add
label define sursim_lbl 2  `"2"', add
label define sursim_lbl 3  `"3"', add
label define sursim_lbl 4  `"4"', add
label define sursim_lbl 5  `"5"', add
label define sursim_lbl 6  `"6"', add
label define sursim_lbl 7  `"7"', add
label define sursim_lbl 8  `"8"', add
label define sursim_lbl 9  `"9"', add
label define sursim_lbl 10 `"10"', add
label define sursim_lbl 11 `"11"', add
label define sursim_lbl 12 `"12"', add
label define sursim_lbl 13 `"13"', add
label define sursim_lbl 14 `"14"', add
label define sursim_lbl 15 `"15"', add
label define sursim_lbl 16 `"16"', add
label define sursim_lbl 17 `"17"', add
label define sursim_lbl 18 `"18"', add
label define sursim_lbl 19 `"19"', add
label define sursim_lbl 20 `"20"', add
label define sursim_lbl 21 `"21"', add
label define sursim_lbl 22 `"22"', add
label define sursim_lbl 23 `"23"', add
label define sursim_lbl 24 `"24"', add
label define sursim_lbl 25 `"25"', add
label define sursim_lbl 26 `"26"', add
label define sursim_lbl 27 `"27"', add
label define sursim_lbl 28 `"28"', add
label define sursim_lbl 29 `"29"', add
label define sursim_lbl 30 `"30"', add
label define sursim_lbl 99 `"Unknown"', add
label values sursim sursim_lbl

label define impmom_lbl 0  `"0"'
label define impmom_lbl 1  `"1"', add
label define impmom_lbl 2  `"2"', add
label define impmom_lbl 3  `"3"', add
label define impmom_lbl 4  `"4"', add
label define impmom_lbl 5  `"5"', add
label define impmom_lbl 6  `"6"', add
label define impmom_lbl 7  `"7"', add
label define impmom_lbl 8  `"8"', add
label define impmom_lbl 9  `"9"', add
label define impmom_lbl 10 `"10"', add
label define impmom_lbl 11 `"11"', add
label define impmom_lbl 12 `"12"', add
label define impmom_lbl 13 `"13"', add
label define impmom_lbl 14 `"14"', add
label define impmom_lbl 15 `"15"', add
label define impmom_lbl 16 `"16"', add
label define impmom_lbl 17 `"17"', add
label define impmom_lbl 18 `"18"', add
label define impmom_lbl 19 `"19"', add
label define impmom_lbl 20 `"20"', add
label define impmom_lbl 21 `"21"', add
label define impmom_lbl 22 `"22"', add
label define impmom_lbl 23 `"23"', add
label define impmom_lbl 24 `"24"', add
label define impmom_lbl 25 `"25"', add
label define impmom_lbl 26 `"26"', add
label define impmom_lbl 27 `"27"', add
label define impmom_lbl 28 `"28"', add
label define impmom_lbl 29 `"29"', add
label values impmom impmom_lbl

label define qlit_lbl 0 `"Entered as written"'
label define qlit_lbl 2 `"Logical hand edit by Census Office or by census sample research staff"', add
label define qlit_lbl 4 `"Allocated, hot deck"', add
label values qlit qlit_lbl

label define qmarinyr_lbl 0 `"Entered as written"'
label define qmarinyr_lbl 2 `"Edited by hand"', add
label define qmarinyr_lbl 3 `"Computer edit (1850-1870 samples)"', add
label define qmarinyr_lbl 4 `"Allocated"', add
label values qmarinyr qmarinyr_lbl

label define versionhist_lbl 1 `"Public release version 1"'
label define versionhist_lbl 2 `"Public release version 2"', add
label values versionhist versionhist_lbl


