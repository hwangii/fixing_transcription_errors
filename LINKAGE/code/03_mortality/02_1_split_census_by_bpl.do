****************************************************
* 1. SPLIT 1940 CENSUS BY HARMONIZED BPL
****************************************************
di "Loading 1940 Census data..."
use "$clean_census/1940_census_cleaned_names", clear

capture confirm variable age
if _rc {
    gen age = 1940 - birthyr
}

decode bpl, gen(bpl_string)
rename (bpl bpl_string) (bpl_code bpl)

* Merge in harmonized birthplace code
merge m:1 bpl using "$output_dir/bpl_crosswalk.dta", keep(match master) nogen

* Keep only necessary columns (including bpl_h now)

keep  *name* mi_new mi_old birthyr bpl bpl_h sex serial id age race marst pernum

*keep marst -- important: add back later 

* Create output directory
cap mkdir "$split_census"

gen bpl_safe = bpl_h

foreach char in "/" "\" ":" "*" "?" "<" ">" "|" " "{
    replace bpl_safe = subinstr(bpl_safe, "`char'", "_", .)
}

replace bpl_safe = subinstr(bpl_safe, `"""', "_", .)
replace bpl_safe = strtrim(bpl_safe)

gsort bpl_safe

* Split by harmonized BPL
di "Splitting census by harmonized BPL..."
levelsof bpl_safe, local(bpl_list)
encode bpl_safe, gen(bpl_safe_code)
local bpl_code_val = 1

tempfile tosplit
save `tosplit'

foreach bpl_val of local bpl_list {
    use `tosplit' if bpl_safe_code == `bpl_code_val', clear
	save "$split_census/bpl_`bpl_val'.dta", replace
	local bpl_code_val = `bpl_code_val' + 1
}

