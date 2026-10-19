****************************************************
* 2. SPLIT BUNMD BY HARMONIZED BPL
****************************************************
di "Loading BUNMD data..."
use "$clean_bunmd/bunmd_cleaned_names", clear

* Rename birthplace string to match crosswalk var name
rename bpl bpl_code_original 
rename bpl_string bpl

* Attach harmonized birthplace code
merge m:1 bpl using "$output_dir/bpl_crosswalk.dta", keep(match master) nogen

* Age at census date
gen census_age = cond(bmonth < 4, 1940 - byear, 1940 - byear - 1)

* Handle missing harmonized birthplace
replace bpl_h = "missing" if missing(bpl_h)

* Create output directory
cap mkdir "$split_bunmd"

* Create filename-safe version of bpl_h (vectorized = fast)
gen bpl_safe = bpl_h

foreach char in "/" "\" ":" "*" "?" "<" ">" "|" " "{
    replace bpl_safe = subinstr(bpl_safe, "`char'", "_", .)
}

replace bpl_safe = subinstr(bpl_safe, `"""', "_", .)
replace bpl_safe = strtrim(bpl_safe)

gsort bpl_safe

* Split by harmonized BPL
di "Splitting BUNMD by harmonized BPL..."
levelsof bpl_safe, local(bpl_list)
encode bpl_safe, gen(bpl_safe_code)
local bpl_code_val = 1

tempfile tosplit
save `tosplit'

foreach bpl_val of local bpl_list {
    use `tosplit' if bpl_safe_code == `bpl_code_val', clear
	save "$split_bunmd/bpl_`bpl_val'.dta", replace
	local bpl_code_val = `bpl_code_val' + 1
}
