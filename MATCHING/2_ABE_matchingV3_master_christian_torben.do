local yr_list=`"`1'"'
local interval=`2'
local location=`3' 	

if `location'==1 {
	local code "D:\Dropbox\enum_date\CODE\\matching_and_intgen_est\"
}
else if `location'==2 {
	local code "C:\Users\ilmyo\Dropbox\enum_date\CODE\\matching_and_intgen_est\"
}
else if `location'==3 {
	local code "D:\Dropbox\enum_date\CODE\\matching_and_intgen_est\"
}

foreach yr in `yr_list' {

	local yr1=`yr'
	local yr2=`yr'+`interval'
	
	foreach name_type in "_ans_cleaned" "_true_cleaned" /*"_ans_nysiis" "_true_nysiis"*/ {
	
		do `"`code'2_ABE_matchingV3_christian_torben.do"' `yr1' `yr2' `"`name_type'"' `location'
	
	}
}
