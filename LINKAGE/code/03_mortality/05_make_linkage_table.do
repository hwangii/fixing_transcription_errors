*****************************************
* LaTeX table: 1940 Census-BUNMD linkage rates and the
* improvement delivered by the new name cleaning.
*
* Reads the four final matched files written by 04_post_match.do
* and overwrites $OUT_TABLES/linkage_table_mortality_bunmd.tex
*
* Runs standalone: the bootstrap below defines every path it
* needs, so it no longer depends on globals left behind by
* 00_master_run_all.do.
*****************************************

drop _all
clear all
set more off

if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
if "$LCODE" == "" global LCODE "F:/github_repos/fixing_transcription_errors/LINKAGE/code"
do "$LCODE/shared/paths.do"

* ---- Replication package (2026-10-19): the numbers the draft quotes ----
* Written by repnum to the tracked replication/results/linkage_mortality.tex.
* Adds output only; nothing that writes the table changes.
if `"$REP_REPO"' == "" do "F:/github_repos/fixing_transcription_errors/replication/config.do"
repnum open using "$REP_RESULTS/linkage_mortality.tex", script(LINKAGE/code/03_mortality/05_make_linkage_table.do)

global output_dir "$D_MORT/working"
global bunmd_raw  "$D_MORT/raw/bunmd_v2/bunmd_v2.csv"
global tables     "$OUT_TABLES"
cap mkdir "$tables"

*****************************************
* Denominator: BUNMD men with byear <= 1940
* 04_post_match.do leaves this in data/mortality/temp.dta;
* rebuild from the BUNMD csv if absent
*****************************************

capture confirm file "$D_MORT/temp.dta"
if _rc == 0 {
	use "$D_MORT/temp.dta", clear
}
else {
	import delimited using "$bunmd_raw", clear varnames(1)
	keep ssn byear sex
	keep if sex == 1 & byear <= 1940
}

qui count
global denom = r(N)
di "Denominator: $denom"
repnum mortDenom = $denom, format(%15.0fc)

* The denominator's people, so the numerator can be restricted to them.
* Fix 2026-10-19: the matched links were counted whatever the BUNMD
* record's sex or birth year, so the numerator was not a subset of the
* denominator. ssn is unique in the denominator (checked 2026-10-19).
keep ssn
isid ssn
tempfile denom_ssn
save `denom_ssn'

*****************************************
* Counts from each of the four final matched files
*****************************************

foreach spec in oldnames oldnames_conservative newnames newnames_conservative {

	if strpos("`spec'", "old") > 0 {
		local mi "mi_old_A"
	}
	else {
		local mi "mi_new_A"
	}

	use timediff_A timediff_B `mi' mname_B ssn_B using ///
		"$output_dir/censoc_bunmd_matched_`spec'.dta", clear
	drop if missing(timediff_A) | missing(timediff_B)

	* Numerator restricted to the denominator (BUNMD men, byear <= 1940).
	* ssn_B is the BUNMD SSN; the files' own ssn column is empty.
	rename ssn_B ssn
	qui count
	local pre = r(N)
	merge m:1 ssn using `denom_ssn', keep(3) nogenerate
	di "`spec': " `pre' - _N " of " `pre' " links dropped: BUNMD record outside the denominator"

	* linked records
	qui count
	global n_`spec' = r(N)

	* subset with a middle initial recorded in both sources
	qui keep if `mi' != "" & mname_B != ""
	qui count
	global v_`spec' = r(N)

	* of those, the ones whose initials agree
	qui keep if lower(`mi') == lower(mname_B)
	qui count
	global a_`spec' = r(N)

	di "`spec': N=${n_`spec'} validated=${v_`spec'} agree=${a_`spec'}"
}

*****************************************
* Derived quantities, one band at a time
* band e = exact, band c = conservative
*****************************************

foreach band in e c {

	if "`band'" == "e" {
		local o "oldnames"
		local n "newnames"
	}
	else {
		local o "oldnames_conservative"
		local n "newnames_conservative"
	}

	* Panel A: linked records and linkage rate
	local N_o_`band' = ${n_`o'}
	local N_n_`band' = ${n_`n'}
	local N_d_`band' = `N_n_`band'' - `N_o_`band''
	local N_p_`band' = 100 * `N_d_`band'' / `N_o_`band''

	local R_o_`band' = 100 * `N_o_`band'' / $denom
	local R_n_`band' = 100 * `N_n_`band'' / $denom
	local R_d_`band' = `R_n_`band'' - `R_o_`band''

	* Panel B: validation sample, its share of links, and initial agreement
	local V_o_`band' = ${v_`o'}
	local V_n_`band' = ${v_`n'}
	local V_d_`band' = `V_n_`band'' - `V_o_`band''
	local V_p_`band' = 100 * `V_d_`band'' / `V_o_`band''

	local S_o_`band' = 100 * `V_o_`band'' / `N_o_`band''
	local S_n_`band' = 100 * `V_n_`band'' / `N_n_`band''
	local S_d_`band' = `S_n_`band'' - `S_o_`band''

	local A_o_`band' = 100 * ${a_`o'} / `V_o_`band''
	local A_n_`band' = 100 * ${a_`n'} / `V_n_`band''
	local A_d_`band' = `A_n_`band'' - `A_o_`band''
}

*****************************************
* Formatting
* counts get thousands separators, percents 2dp,
* differences get an explicit LaTeX math sign
*****************************************

foreach band in e c {

	foreach v in N V {
		foreach w in o n {
			local `v'`w'`band'_f = strtrim(string(``v'_`w'_`band'', "%20.0fc"))
		}
		local s = cond(``v'_d_`band'' < 0, "\$-\$", "\$+\$")
		local `v'd`band'_f = "`s'" + strtrim(string(abs(``v'_d_`band''), "%20.0fc"))
		local s = cond(``v'_p_`band'' < 0, "\$-\$", "\$+\$")
		local `v'p`band'_f = "`s'" + string(abs(``v'_p_`band''), "%4.2f")
	}

	foreach v in R S A {
		foreach w in o n {
			local `v'`w'`band'_f = string(``v'_`w'_`band'', "%4.2f")
		}
		local s = cond(``v'_d_`band'' < 0, "\$-\$", "\$+\$")
		local `v'd`band'_f = "`s'" + string(abs(``v'_d_`band''), "%4.2f")
	}
}

local denom_f = strtrim(string($denom, "%20.0fc"))

*****************************************
* Write the table
*****************************************

capture file close tex
file open tex using "$tables/linkage_table_mortality_bunmd.tex", write replace

file write tex "% linkage_table_mortality_bunmd.tex" _n
file write tex "% 1940 Census-BUNMD linkage rates and old/new name-cleaning improvements." _n
file write tex "% Generated by code/05_make_linkage_table.do -- do not edit by hand." _n
file write tex "% Requires \usepackage{booktabs} in the preamble." _n
file write tex "" _n
file write tex "\begin{table}[htbp]" _n
file write tex "\centering" _n
file write tex "\caption{1940 Census--BUNMD linkage rates and match quality, by name-cleaning version}" _n
file write tex "\label{tab:linkage_rates}" _n
file write tex "\begin{tabular}{lrrrr}" _n
file write tex "\toprule" _n
file write tex " & Old names & New names & Difference & \% change \\" _n
file write tex "\midrule" _n
file write tex "\multicolumn{5}{l}{\textit{Panel A. Linked records}} \\" _n
file write tex "\addlinespace" _n
file write tex "Exact matches (N) & `Noe_f' & `Nne_f' & `Nde_f' & `Npe_f' \\" _n
file write tex "\quad Linkage rate (\%) & `Roe_f' & `Rne_f' & `Rde_f' & \\" _n
file write tex "\addlinespace" _n
file write tex "Conservative matches (N) & `Noc_f' & `Nnc_f' & `Ndc_f' & `Npc_f' \\" _n
file write tex "\quad Linkage rate (\%) & `Roc_f' & `Rnc_f' & `Rdc_f' & \\" _n
file write tex "\midrule" _n
file write tex "\multicolumn{5}{l}{\textit{Panel B. Middle-initial validation}} \\" _n
file write tex "\addlinespace" _n
file write tex "\textit{Exact matches} & & & & \\" _n
file write tex "\quad Validation sample (N) & `Voe_f' & `Vne_f' & `Vde_f' & `Vpe_f' \\" _n
file write tex "\quad Share of links (\%) & `Soe_f' & `Sne_f' & `Sde_f' & \\" _n
file write tex "\quad Initials agree (\%) & `Aoe_f' & `Ane_f' & `Ade_f' & \\" _n
file write tex "\addlinespace" _n
file write tex "\textit{Conservative matches} & & & & \\" _n
file write tex "\quad Validation sample (N) & `Voc_f' & `Vnc_f' & `Vdc_f' & `Vpc_f' \\" _n
file write tex "\quad Share of links (\%) & `Soc_f' & `Snc_f' & `Sdc_f' & \\" _n
file write tex "\quad Initials agree (\%) & `Aoc_f' & `Anc_f' & `Adc_f' & \\" _n
file write tex "\bottomrule" _n
file write tex "\end{tabular}" _n
file write tex "" _n
file write tex "\begin{minipage}{\textwidth}" _n
file write tex "\vspace{0.5em}" _n
file write tex "\footnotesize" _n
file write tex "\textit{Notes:} Links are ABE exact matches between the 1940 Census and BUNMD v2" _n
file write tex "on cleaned first name, cleaned last name, and harmonized birthplace, requiring" _n
file write tex "uniqueness within a \$\pm\$2-year birth-year window in both files. The conservative" _n
file write tex "variant additionally drops records with any competing potential match within" _n
file write tex "\$\pm\$2 years of birth. Old names and new names refer to the two cleaned name" _n
file write tex "variables carried through the pipeline (\texttt{f\_name\_old\_cleaned} and" _n
file write tex "\texttt{l\_name\_old\_cleaned} versus their \texttt{\_new\_} counterparts)." _n
file write tex "Linkage rates use a denominator of `denom_f' BUNMD men with birth year" _n
file write tex "\$\leq\$ 1940. The validation sample is the subset of links with a middle initial" _n
file write tex "observed in both sources; initials agree is the share of that subset whose" _n
file write tex "initials match. Middle initials are not used as a matching criterion, so this" _n
file write tex "serves as an out-of-sample check on match quality. Difference and \% change" _n
file write tex "columns compare new names to old names; for rows measured in percent, the" _n
file write tex "difference is in percentage points." _n
file write tex "\end{minipage}" _n
file write tex "\end{table}" _n

file close tex

di "Wrote $tables/linkage_table_mortality_bunmd.tex"

repnum close
