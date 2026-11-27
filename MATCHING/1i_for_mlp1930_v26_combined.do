/*1930 FILE FOR IPUMS MLP LINKING WITH THE SAME THREE NAME VERSIONS AS        */
/*for_mlp1940_v26_combined.dta (2026-11-27). MACHINE A. Read only on its     */
/*input. In 1930 all three are Ancestry's names; the copies only let IPUMS    */
/*run MLP three times, pairing each 1930 set with the 1940 set of the same   */
/*name (author, 2026-11-27). Writes for_mlp1930_v26_combined.dta:            */
/*  histid age sex bpl                                                        */
/*  namefrst namelast mi                                   Old                */
/*  namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned  New          */
/*  namefrst_tgt_cleaned namelast_tgt_cleaned mi_tgt_cleaned     Target-only  */
/*(no exists flags: no 1930 record has model names). Refuses to overwrite.  */
/*                                                                            */
/*  powershell -File replication/Run-Stata.ps1 MATCHING/1i_for_mlp1930_v26_combined.do */

if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
local fi "$REP_F/enum_date/DATA/INTERMEDIATE/"
local out `"`fi'for_mlp1930_v26_combined.dta"'
capture confirm file `"`out'"'
if !_rc {
	display as error "`out' exists; move it aside first"
	exit 602
}
use `"`fi'for_mlp1930_v26.dta"', clear
isid histid
confirm variable histid age sex bpl namefrst namelast mi
local N = _N
foreach s in true tgt {
	gen namefrst_`s'_cleaned = namefrst
	gen namelast_`s'_cleaned = namelast
	gen mi_`s'_cleaned = mi
	assert namefrst_`s'_cleaned==namefrst & namelast_`s'_cleaned==namelast & mi_`s'_cleaned==mi
}
assert _N==`N'
order histid age sex bpl namefrst namelast mi namefrst_true_cleaned namelast_true_cleaned mi_true_cleaned namefrst_tgt_cleaned namelast_tgt_cleaned mi_tgt_cleaned
sort histid
compress
save `"`out'"'
display "records `N'"
display "COMBINED MLP 1930 FILE DONE"
