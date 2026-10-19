* ============================================================
* 00_run_all_tables.do -- rebuild every output table
* ============================================================
* Runs the three table scripts, one per linkage. These read
* already-linked data and do nothing but aggregate and write
* LaTeX. NO linkage or matching is re-run here: nothing below
* calls abematch or abeclean, and none of it touches the raw
* match CSVs.
*
* Produces, in output/tables/:
*     linkage_table_abe_jw.tex             ABE + Jaro-Winkler
*     linkage_table_abe_jw_restricted.tex    "   (congruent == 0)
*     linkage_table_hlink.tex              HLINK
*     linkage_table_hlink_restricted.tex     "   (congruent == 0)
*     linkage_table_mortality_bunmd.tex    1940 census x BUNMD mortality
*
* Runtime: ~4h 10m end to end, measured 2026-09-06 on
* StataMP-64 15.1 (~3 cores, 12.6 GB peak):
*     1/3  ABE + Jaro-Winkler    88 min
*     2/3  HLINK                159 min   <- the long pole
*     3/3  Mortality              minutes
* The two census-to-census tables read 5-12 GB inputs
* repeatedly and classify 13-68M pairs against ground truth.
* Stata writes its tempfiles outside the project (E:\temp
* here), so the scratch drive needs headroom too.
*
* RELOCATING THE PACKAGE
* Each entry-point script carries one bootstrap literal, because
* Stata cannot resolve a path relative to the running do-file and
* -clear all- inside each script wipes globals set by this one.
* To move the project, update every occurrence of ROOT:
*     grep -rl "global ROOT" code/
* ============================================================

clear all
set more off

if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
if "$LCODE" == "" global LCODE "F:/github_repos/fixing_transcription_errors/LINKAGE/code"
do "$LCODE/shared/paths.do"

di as result _newline(2) "=== 1/3  ABE + Jaro-Winkler ==="
do "$C_ABEJW/linkage_analysis.do"

di as result _newline(2) "=== 2/3  HLINK ==="
do "$C_HLINK/linkage_analysis_newlinks.do"

di as result _newline(2) "=== 3/3  Census-BUNMD mortality ==="
do "$C_MORT/05_make_linkage_table.do"

di as result _newline(2) "=== all tables rebuilt into output/tables/ ==="
