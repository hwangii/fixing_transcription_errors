* ============================================================
* prep_census.do -- census denominators by sex
* ============================================================
* Standalone check: counts the 1940 census population aged 8+
* by sex. Nothing downstream reads its output; the linkage
* scripts recompute their own denominators live. Kept because it
* is where the "all men in the 1940 census" figures quoted in the
* table captions came from.
* ------------------------------------------------------------

if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
do "$ROOT/code/shared/paths.do"

use year sex age race bpl histid using "$D_CENSUS/1930_1940_full_w_women.dta" ///
    if year == 1940 & age >= 8, clear
collapse (count) nobs = year, by(sex)
list

** Denominator for match rates (1940, age 8+) **
* Men:   57,578,737
* Women: 57,455,249

use year sex age race bpl histid using "$D_CENSUS/1930_1940_full_w_women.dta" ///
    if age >= 8, clear
collapse (count) nobs = year, by(year sex)
list
