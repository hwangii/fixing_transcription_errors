/*------------------------------------------------------------------------------
ABE matching (exact on cleaned names, race NOT used as a blocking variable)

RECONSTRUCTED. The script that produced
    data/links/link1930_1940_ans_cleaned_noraceblock0.dta   (16,946,362 rows)
    data/links/link1930_1940_true_cleaned_noraceblock0.dta  (18,198,099 rows)
does not exist on any drive here. This is a reconstruction whose parameters were
INFERRED from the surviving artifacts. Read the inference table before trusting
any output.

VALIDATED against the originals on Massachusetts (bpl 25), 2026-09-06:

    original links, bpl 25 only :  488,439
    reconstruction pairs        :  488,439
    in BOTH                     :  488,439   (100.0% both ways)
    reconstruction only         :        0
    original only               :        0
    f_name_A l_name_A f_name_B l_name_B fiveyr_band mi1930 mi1940 : all identical

Not merely equal totals -- the identical PAIR SET with identical field values.
Reproduce with linkage/validate_abe_reconstruction.do.

FULL COUNT, both vintages, 2026-09-06/07 (6.9 h, zero birthplace failures):

                        reconstruction      original     difference
    ans_cleaned (old)       16,944,747    16,946,362         -1,615
    true_cleaned (new)      18,197,078    18,198,099         -1,021

99.99% agreement, and a STRICT SUBSET both times: the reconstruction produces
ZERO pairs the original lacks. The matching rule is therefore right; the
difference is upstream, in which 1930 records reach the matcher.

Every one of those missing pairs -- 100% of them, both vintages -- is a ONE-NAME
JOIN. Diagnosed in three steps by linkage/diagnose_abe_shortfall*.do:

  1. strict subset, and every missing pair's A-side id is absent from the
     by_bpl inputs entirely;
  2. all of those ids ARE in clean_names_1930_old and are male with bpl and
     race, but have a blank first name (791/563) or blank last name (947/593).
     run_full_census_prep.do drops them: a record with no initial cannot be
     blocked;
  3. in the original link file those pairs are blank on the SAME field on BOTH
     sides -- "george <blank>" to "george <blank>", "<blank> smith" to
     "<blank> smith". ABE matches names exactly, so a blank could only ever
     have matched another blank.

So the reconstruction is not losing real links; it declines to make links that
rest on a single name field. Note that 845 (old) and 630 (new) of them carry
fiveyr_band == 1, meaning the ORIGINAL link files -- and the published table
built from them -- contain that many one-name links. Against 12.5M and 13.5M
fiveyr_band pairs that is 0.007%, far too small to move any published number,
but it is a property of the originals worth knowing.

Do NOT "fix" this by loosening the matcher. The gap is a deliberate prep-stage
exclusion, and reproducing it would mean re-introducing blank-name blocking.

bpl is a blocking variable, so the exact Massachusetts result was already strong
evidence for the parameter set; the full count now confirms it at scale.

One question remains open: whether f_name_A/f_name_B carry CLEANED or RAW names.
Both are str16, and on bpl 25 f_name_cleaned and raw f_name are identical on all
488,439 rows, so the test could not discriminate. It does not affect output here
-- both choices give the same answer -- but a bpl where cleaning actually bites
would settle it.

--------------------------------------------------------------------------------
PARAMETER                 VALUE            BASIS
--------------------------------------------------------------------------------
match variables           f_name_cleaned   The target files are named
                          l_name_cleaned   "*_cleaned_noraceblock*": matching is
                                           on the cleaned name fields, and race
                                           is NOT a blocking variable even though
                                           it is present in the input.
                                           bpl is omitted because the inputs are
                                           already split one file per bpl, so it
                                           is constant within a match.

timevar / timediff        age / 10         Census years 1930 -> 1940. Same as
                                           comparison/01_abe_exact_matching.do:101.

timeband                  2                abematch default. Iterates over age
                                           bands +/-0, +/-1, +/-2.

unique_m / unique_f       2 / 2            Same as
                                           comparison/01_abe_exact_matching.do:129.
                                           Creates unique_match1-2, unique_file1-2.

fiveyr_band               unique_match2    INFERRED. +/-2 years spans a FIVE-YEAR
                          & unique_file2   window (y-2..y+2), so "fiveyr_band"
                                           reads as the +/-2 uniqueness flag. This
                                           is also exactly the "conservative"
                                           criterion used by the mortality
                                           pipeline (03_match.do:65-66) and by
                                           comparison/01_abe_exact_matching.do:
                                           139-140. linkage_analysis.do filters
                                           ABE links on fiveyr_band == 1.

id_A / id_B               id               CORRECTED after a test run. abematch
                                           suffixes the SOURCE VARIABLE NAME, so
                                           id_A(histid) emits histid_A, not id_A.
                                           The target schema has id_A/id_B, so
                                           the original must have renamed
                                           histid -> id before matching. The
                                           by_bpl inputs carry histid; this
                                           script renames it in the prep step.

keep_A / keep_B           f_name l_name    Target schema has f_name_A, l_name_A,
                                           f_name_B, l_name_B -- i.e. keep_A() on
                                           variables named f_name / l_name.

mi1930 / mi1940           merged after     Not produced by abematch. Merged back
                                           from the clean_names files by histid.
                                           CONFIRMED by string width: mi is
                                           str13 in clean_names_1930_old and
                                           str14 in clean_names_1940_old, which
                                           are exactly the widths of mi1930 and
                                           mi1940 in BOTH target link files.
                                           That pins the source files and the
                                           old/new vintage mapping.

final variable list       9 vars           The target files carry ONLY the 9
                                           schema variables; abematch's working
                                           columns (unique_*, timediff_*, age,
                                           the match variables, bpl) are dropped.
                                           Kept in the per-bpl intermediates for
                                           diagnostics, dropped at the final save.
--------------------------------------------------------------------------------

NYSIIS: NOT USED, and this is deliberate, not an inference.

Classic ABE applies NYSIIS phonetic encoding to absorb spelling variation. This
project does not, because the names arriving here have ALREADY been cleaned by
our own transcription pipeline -- that cleaning is the very thing the three
linkages exist to evaluate. Running NYSIIS on top would collapse exactly the
distinctions the analysis is measuring, and would make old-vs-new transcription
differences partly invisible. The sibling script
comparison/01_abe_exact_matching.do disables it for the same reason (nonysiis),
and the target filenames say "_cleaned_", not "_nysiis_".

The `use_nysiis' setting below is retained at 0 for sensitivity checks only.
Setting it to 1 does not reproduce these links and changes match counts
materially. Do not flip it without a specific reason.

================================================================================
RUNNING THIS ON THE FULL COUNT
================================================================================

Set  vintage "both"  and  bpl_subset ""  and let it run. Expect roughly
2.7 hours per vintage, 5.5 hours for both, on one core.

That figure is MEASURED, not extrapolated. bpl 1 (Alabama, 3,148,159 records,
2.5% of the universe) took 243 s of match time, and the runner's own
records-weighted ETA settled at 2.68 h per vintage over the first two
birthplaces. Add ~4 min per vintage for the middle-initial merge, which is a
fixed cost: it reads two 5-6 GB name files whatever the run size.

An earlier estimate of 4-5 h per vintage was too pessimistic. It came from
Massachusetts' 5.4 min WALL time, which included Stata startup and file
loading; the per-bpl timer above measures matching alone.

The estimate is also insensitive to how matching cost scales with block size,
because the birthplace distribution is flat: the largest bpl is only 2.89x
Massachusetts and the top five hold 29% of all 128,090,207 records. So a bad
guess about the scaling exponent moves the answer by well under an hour.

Three things make a long run survivable, and all are on by default:

  overwrite 0     Per-bpl output already on disk is skipped, so an interrupted
                  run resumes where it stopped instead of restarting.
  stop_on_error 0 One birthplace failing is recorded and the run continues;
                  every failure is listed at the end and the combined file is
                  NOT written from a partial set unless allow_partial is set.
  progress        Per-bpl timing plus an ETA weighted by RECORDS remaining,
                  not birthplaces remaining -- birthplace count is a poor
                  progress measure when the largest is 2 million times the
                  smallest.

This runner is SERIAL. The JW runner beside it uses 12 parallel clusters, and
birthplaces are independent by construction, so the same treatment would cut
this to well under an hour per vintage. That is deliberately not done here: the
reconstruction was validated serially, and adding concurrency would put
unvalidated machinery between the inputs and a result we can currently prove is
exact. Parallelise it once a full serial run has been checked against the
originals.

Verify any full run against the known totals above before using the output.
------------------------------------------------------------------------------*/

drop _all
clear all
set more off

* ---- Path bootstrap: single source of truth ----
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
do "$ROOT/code/shared/paths.do"

*==============================================================================
* SETTINGS
*==============================================================================

* Which transcription. "old" reads data/by_bpl, "new" reads
* data/by_bpl_new_transcription, "both" runs each in turn.
local vintage "both"

* Birthplaces to process. "" (empty) = every bpl in bpl_list.dta.
* Otherwise a space-separated list, e.g. "25" for Massachusetts alone or
* "518 463 538" for a fast end-to-end smoke test on tiny birthplaces.
local bpl_subset ""

* 0 = skip birthplaces whose output already exists (resumable).
* 1 = redo everything.
local overwrite 0

* 0 = record a failing birthplace and carry on; 1 = abort the whole run.
local stop_on_error 0

* Write the combined file even if some birthplaces failed or are absent.
* Leave at 0: a silently partial link file is worse than no link file.
local allow_partial 0

* 1 = merge middle initials back on after matching.
local add_mi 1

* NYSIIS: leave at 0. Names are already cleaned upstream by our own pipeline,
* and that cleaning is what these linkages exist to evaluate. See header.
local use_nysiis 0

*==============================================================================
* SET UP
*==============================================================================

* abematch / abeclean ship with this package
adopath + "$C_ABEJW/reference"
adopath + "$C_ABEJW/ado"

capture which abematch
if _rc {
    di as error "abematch not found on the adopath."
    di as error "  expected at: $C_ABEJW/reference/abematch.ado"
    exit 111
}

if !inlist("`vintage'", "old", "new", "both") {
    di as error "vintage must be old, new or both -- got: `vintage'"
    exit 198
}
if "`vintage'" == "both" local vintages "old new"
else                     local vintages "`vintage'"

*==============================================================================
* PER-BPL WORKER
*==============================================================================
* A program, not inline code, so the whole per-birthplace unit can be wrapped
* in -capture- and a single failure cannot take down a multi-hour run.
* Results come back in globals because locals do not survive the call.

capture program drop abe_one_bpl
program define abe_one_bpl
    syntax , Bpl(integer) SRCdir(string) OUTfile(string) [NYSiis(integer 0)]

    foreach yr in 1930 1940 {
        capture confirm file "`srcdir'/clean_names_`yr'.dta"
        if _rc {
            di as error "  missing input: `srcdir'/clean_names_`yr'.dta"
            exit 601
        }
    }

    * ---- prepare both sides ----
    * abematch requires the match variables to be present and to compare
    * exactly. keep_A()/keep_B() need them named f_name / l_name so the output
    * lands as f_name_A / f_name_B, matching the target schema.
    tempfile ready30 ready40
    foreach yr in 1930 1940 {
        use "`srcdir'/clean_names_`yr'.dta", clear
        quietly count
        global ABE_N`yr' = r(N)

        * Match on f_name_cleaned / l_name_cleaned, but ALSO carry copies named
        * f_name / l_name so keep_A()/keep_B() emit f_name_A, f_name_B, ...
        * exactly as the target schema has them.
        quietly generate f_name = f_name_cleaned
        quietly generate l_name = l_name_cleaned

        * abematch names its output <idvar>_A / <idvar>_B -- it suffixes the
        * SOURCE variable name. The target schema has id_A/id_B, so the id
        * variable must literally be named id at match time. Rename exactly
        * (posof), not -confirm variable-, which accepts abbreviations and
        * would match some other id-prefixed variable.
        quietly ds
        local have `r(varlist)'
        local p : list posof "id" in have
        if `p' == 0 {
            local q : list posof "histid" in have
            if `q' == 0 {
                di as error "  no id variable in `srcdir'/clean_names_`yr'.dta"
                di as error "  looked for: id, histid"
                exit 111
            }
            rename histid id
        }

        if `nysiis' {
            capture confirm variable sex
            if _rc quietly generate byte sex = 1
            abeclean f_name_cleaned l_name_cleaned, sex(sex)
        }

        if `yr' == 1930 quietly save `ready30', replace
        else            quietly save `ready40', replace
    }

    * ---- match ----
    clear
    abematch f_name_cleaned l_name_cleaned,        ///
        file_A("`ready30'") file_B("`ready40'")    ///
        timevar(age) timediff(10) timeband(2)      ///
        id_A(id) id_B(id)                          ///
        unique_m(2) unique_f(2)                    ///
        keep_A(f_name l_name) keep_B(f_name l_name)

    quietly count
    global ABE_NRAW = r(N)

    * ---- fiveyr_band: unique within the +/-2 (five-year) window ----
    * float, not byte: the target files store fiveyr_band as float.
    quietly generate float fiveyr_band = (unique_match2 == 1 & unique_file2 == 1)
    quietly count if fiveyr_band == 1
    global ABE_NBAND = r(N)

    quietly generate int bpl = `bpl'
    quietly save "`outfile'", replace
end

*==============================================================================
* MAIN
*==============================================================================

foreach vint of local vintages {

if "`vint'" == "old" {
    local bpldir  "$ABEJW/data/by_bpl"
    local namedir "$D_NAMES"
    local name30  "clean_names_1930_old.dta"
    local name40  "clean_names_1940_old.dta"
    local tag     "ans_cleaned"
}
else {
    local bpldir  "$ABEJW/data/by_bpl_new_transcription"
    local namedir "$D_NAMES"
    local name30  "clean_names_1930_old.dta"
    local name40  "clean_names_1940_new.dta"
    local tag     "true_cleaned"
}

local outdir "$ABEJW/data/matched_abe_`vint'"
capture mkdir "`outdir'"

* ---- bpl values to process, with their sizes for a records-weighted ETA ----
capture confirm file "`bpldir'/bpl_list.dta"
if _rc {
    di as error "no bpl_list.dta in `bpldir'"
    exit 601
}
use "`bpldir'/bpl_list.dta", clear

if "`bpl_subset'" != "" {
    generate byte _want = 0
    foreach b of local bpl_subset {
        quietly replace _want = 1 if bpl == `b'
    }
    quietly keep if _want == 1
    drop _want
    if _N == 0 {
        di as error "none of the requested bpl values exist in `bpldir'/bpl_list.dta"
        di as error "  requested: `bpl_subset'"
        exit 111
    }
}
sort bpl
quietly levelsof bpl, local(bpl_values) clean
local n_bpl : word count `bpl_values'

* size lookup, and the total records this run must chew through
quietly summarize n_total, meanonly
local rows_total = r(sum)
forvalues i = 1/`=_N' {
    local bb = bpl[`i']
    local sz_`bb' = n_total[`i']
}

di as text _n "{hline 78}"
di as result "ABE matching  --  vintage: `vint'  --  `n_bpl' bpl value(s)"
di as text "{hline 78}"
di as text "  match vars : f_name_cleaned l_name_cleaned"
di as text "  nysiis     : `use_nysiis'"
di as text "  resume     : " cond(`overwrite', "no (overwrite)", "yes (skip existing)")
di as text "  on error   : " cond(`stop_on_error', "abort", "record and continue")
di as text "  input      : `bpldir'"
di as text "  output     : `outdir'"
di as text "  records    : " %14.0fc `rows_total'

*------------------------------------------------------------------
* MATCH, ONE BPL AT A TIME
*------------------------------------------------------------------
* bpl is a blocking variable, so matching never crosses a bpl boundary and
* each can be processed independently with identical results.

local idx        0
local n_ok       0
local n_skip     0
local n_fail     0
local failed     ""
local rows_done  0
local secs_done  0

timer clear 2
timer on 2

foreach b of local bpl_values {

    local ++idx
    local src "`bpldir'/bpl_`b'"
    local out "`outdir'/abe_matches_bpl_`b'.dta"
    local sz  = `sz_`b''

    * ---- resume ----
    if !`overwrite' {
        capture confirm file "`out'"
        if _rc == 0 {
            local ++n_skip
            local rows_done = `rows_done' + `sz'
            di as text "[`idx'/`n_bpl'] bpl `b' -- exists, skipping"
            continue
        }
    }

    di as text _n "{hline 78}"
    di as result "[`idx'/`n_bpl'] bpl `b'" as text "   (" %12.0fc `sz' " records)"
    di as text "{hline 78}"

    timer clear 1
    timer on 1
    capture noisily abe_one_bpl, bpl(`b') srcdir("`src'") outfile("`out'") ///
        nysiis(`use_nysiis')
    local rc = _rc
    timer off 1
    quietly timer list 1
    local secs = r(t1)

    if `rc' {
        local ++n_fail
        local failed "`failed' `b'"
        di as error "  FAILED on bpl `b' (rc = `rc') after " %6.1f `secs' "s"
        if `stop_on_error' {
            di as error "  stop_on_error is 1 -- aborting"
            exit `rc'
        }
    }
    else {
        local ++n_ok
        local secs_done = `secs_done' + `secs'
        local pct = cond($ABE_NRAW > 0, 100 * $ABE_NBAND / $ABE_NRAW, 0)
        di as text "  input rows : " %12.0fc $ABE_N1930 " (1930)  " ///
                                     %12.0fc $ABE_N1940 " (1940)"
        di as text "  matches    : " %12.0fc $ABE_NRAW ///
           "   fiveyr_band==1: " %12.0fc $ABE_NBAND "  (" %5.1f `pct' "%)"
        di as text "  time       : " %8.1f `secs' "s"
    }

    * ---- records-weighted ETA ----
    * Birthplace count is a poor progress measure here: the largest bpl holds
    * two million times the records of the smallest. Weight by records.
    local rows_done = `rows_done' + `sz'
    if `secs_done' > 0 & `rows_done' > 0 & `rows_done' < `rows_total' {
        local rate = `secs_done' / `rows_done'
        local eta  = `rate' * (`rows_total' - `rows_done')
        di as text "  progress   : " %5.1f (100 * `rows_done' / `rows_total') ///
           "% of records   ETA " %6.2f (`eta'/3600) " h"
    }
}

timer off 2
quietly timer list 2
local secs_match = r(t2)

di as text _n "{hline 78}"
di as result "MATCHING DONE  --  vintage `vint'"
di as text "{hline 78}"
di as text "  matched    : `n_ok'"
di as text "  skipped    : `n_skip'   (output already existed)"
di as text "  failed     : `n_fail'"
di as text "  wall time  : " %6.2f (`secs_match'/3600) " h"
if `n_fail' > 0 {
    di as error "  failed bpl values:`failed'"
}

*------------------------------------------------------------------
* COMPLETENESS CHECK
*------------------------------------------------------------------
* Never append a partial set silently -- a link file that is quietly missing
* three states looks exactly like a correct one downstream.

* A birthplace is incomplete if its output is absent OR it failed in THIS run.
* The second half matters: with overwrite 1, a birthplace that fails still has
* its output file from an earlier run sitting on disk, so an existence test
* alone would happily append a stale result next to fresh ones and report a
* complete combined file. Found by deliberately failing one bpl in a test.
local missing ""
local n_missing 0
foreach b of local bpl_values {
    local isfail : list posof "`b'" in failed
    capture confirm file "`outdir'/abe_matches_bpl_`b'.dta"
    local absent = _rc
    if `absent' | `isfail' > 0 {
        local missing "`missing' `b'"
        local ++n_missing
        if `absent' == 0 & `isfail' > 0 {
            di as error "  bpl `b' failed this run; the file on disk is STALE"
        }
    }
}

if `n_missing' > 0 {
    di as error _n "  `n_missing' of `n_bpl' birthplaces are missing or stale:`missing'"
    if !`allow_partial' {
        di as error "  NOT writing the combined file from a partial set."
        di as error "  Re-run to retry them (finished ones are skipped), or set"
        di as error "  allow_partial 1 if a partial file is genuinely wanted."
        continue
    }
    di as error "  allow_partial is 1 -- combining anyway. The output is PARTIAL."
}

*------------------------------------------------------------------
* APPEND + ATTACH MIDDLE INITIALS
*------------------------------------------------------------------

di as text _n "{hline 78}"
di as result "Appending `n_bpl' bpl file(s)"
di as text "{hline 78}"

clear
local first 1
foreach b of local bpl_values {
    capture confirm file "`outdir'/abe_matches_bpl_`b'.dta"
    if _rc continue
    if `first' {
        use "`outdir'/abe_matches_bpl_`b'.dta", clear
        local first 0
    }
    else {
        append using "`outdir'/abe_matches_bpl_`b'.dta"
    }
}
quietly count
local n_combined = r(N)
di as text "  combined rows: " %14.0fc `n_combined'

tempfile combined
quietly save `combined'

if `add_mi' {
    * mi is not carried in the per-bpl files; merge it back by histid.
    * Target schema names these mi1930 (A side) and mi1940 (B side).
    di as text "  merging middle initials ..."

    * Two-column loads: these files are 5-6 GB each, so never read them whole.
    * The id column is histid in the clean_names files but id in some of the
    * data/names/cleaned extracts, hence the fallback.
    tempfile mi30 mi40
    capture use histid mi using "`namedir'/`name30'", clear
    if _rc {
        use id mi using "`namedir'/`name30'", clear
        rename id histid
    }
    rename histid id_A
    rename mi mi1930
    quietly duplicates drop id_A, force
    quietly save `mi30'

    capture use histid mi using "`namedir'/`name40'", clear
    if _rc {
        use id mi using "`namedir'/`name40'", clear
        rename id histid
    }
    rename histid id_B
    rename mi mi1940
    quietly duplicates drop id_B, force
    quietly save `mi40'

    use `combined', clear
    quietly merge m:1 id_A using `mi30', keep(1 3) nogenerate
    quietly merge m:1 id_B using `mi40', keep(1 3) nogenerate

    quietly count if !missing(mi1930)
    local n_mi30 = r(N)
    quietly count if !missing(mi1940)
    local n_mi40 = r(N)
    di as text "    mi1930 present: " %14.0fc `n_mi30' ///
       "   mi1940 present: " %14.0fc `n_mi40'
}

* ---- match the target schema exactly ----
* The target link files carry ONLY these 9 variables. abematch's working
* columns (unique_match*, unique_file*, timediff_*, age, the match variables)
* and bpl are kept in the per-bpl intermediates for diagnostics, but dropped
* here so the final artifact is schema-identical to the originals.
local schema id_B f_name_B l_name_B id_A f_name_A l_name_A fiveyr_band
if `add_mi' local schema `schema' mi1930 mi1940

quietly ds
local have `r(varlist)'
local absent ""
foreach v of local schema {
    local p : list posof "`v'" in have
    if `p' == 0 local absent `absent' `v'
}
if "`absent'" != "" {
    di as error "  final schema is missing: `absent'"
    di as error "  have: `have'"
    exit 111
}
keep `schema'
order `schema'

* A full run writes the reconstruction next to the originals under a distinct
* name -- it never overwrites link1930_1940_*_noraceblock0.dta. A subset run
* stays in the working tree.
if "`bpl_subset'" == "" {
    local final "$D_LINKS/link1930_1940_`tag'_noraceblock0_RECONSTRUCTED.dta"
}
else {
    local ntag : subinstr local bpl_subset " " "_", all
    local final "`outdir'/link1930_1940_`tag'_noraceblock0_bpl`ntag'.dta"
}
label data "ABE links, `tag', race not blocked (RECONSTRUCTED - see run_abe_match.do)"
quietly save "`final'", replace

quietly count
local n_final = r(N)
quietly count if fiveyr_band == 1
local n_final_band = r(N)

di as text _n "{hline 78}"
di as result "DONE  --  vintage `vint'"
di as text "{hline 78}"
di as text "  rows            : " %14.0fc `n_final'
di as text "  fiveyr_band == 1: " %14.0fc `n_final_band'
di as text "  saved           : `final'"

if "`bpl_subset'" == "" {
    local expect = cond("`tag'" == "ans_cleaned", 16946362, 18198099)
    di as text "  original total  : " %14.0fc `expect'
    if `n_final' == `expect' {
        di as result "  EXACT MATCH to the original row count"
    }
    else {
        local d = `n_final' - `expect'
        di as error "  DIFFERS from the original by " %14.0fc `d' " rows"
        di as error "  Investigate before using this output."
    }
}
else {
    di as text _n "  SUBSET RUN (bpl `bpl_subset') -- not comparable to the"
    di as text "  full-census totals of 16,946,362 / 18,198,099."
}
describe, short

}   // end vintage loop

di as text _n "{hline 78}"
di as result "ALL VINTAGES COMPLETE"
di as text "{hline 78}"
