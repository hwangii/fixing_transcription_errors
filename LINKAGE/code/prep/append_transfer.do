*==============================================================================
* append_transfer.do
*
* Appends every .dta file inside each unzipped folder in data/Transfer into a
* single .dta file per folder, written to data/Transfer_appended/.
*
*   data/Transfer/divided_file1930_ans_cleaned_women_added/  (144 .dta files)
*       -> data/Transfer_appended/divided_file1930_ans_cleaned_women_added.dta
*   ... and likewise for the other three folders.
*
* Each folder is ~10-11 GB on disk, so expect this to run for a while and to
* hold ~11 GB in memory at peak (machine has 128 GB, so it fits).
*==============================================================================

version 15
clear all
set more off


* ---- Path bootstrap ----
* NOTE: outdir writes straight into data/transcriptions/appended, beside the
* shards it reads. Previously it wrote to data/Transfer_appended and the four
* results were moved by hand -- an undocumented manual step that broke
* replication.
if "$ROOT" == "" global ROOT "F:/Deaglan/Census_Transcriptions"
do "$ROOT/code/shared/paths.do"
*------------------------------------------------------------------ settings --
local root    "$D_TRANSCRIPT"
local outdir  "$D_APPENDED"
local logfile "$OUT_LOGS/append_transfer.log"

* 1 = add a numeric `part' variable recording which noraceN.dta each row came
*     from.  Set to 0 for a pure append with no schema change.
local add_part 1

* 1 = run -compress- before saving (smaller files on disk, but slower and it
*     can narrow variable storage types).  0 = save as-is.
local do_compress 0

* 1 = skip a folder whose output file already exists, so an interrupted run can
*     be resumed.  0 = always rebuild.
local skip_existing 1

*------------------------------------------------------------------- set up ---
capture set max_memory 100g
capture mkdir "`outdir'"

capture log close _all
log using "`logfile'", replace text

display as text _n "{hline 78}"
display as text "append_transfer.do  --  started $S_DATE $S_TIME"
display as text "{hline 78}"

* Discover the unzipped folders.
local folders : dir "`root'" dirs "*"
local folders : list sort folders

if `"`folders'"' == "" {
    display as error "No subfolders found in `root'"
    exit 601
}

*--------------------------------------------------------- loop over folders --
foreach folder of local folders {

    local src "`root'/`folder'"
    local out "`outdir'/`folder'.dta"

    display as text _n "{hline 78}"
    display as result "FOLDER: `folder'"
    display as text "{hline 78}"

    if `skip_existing' {
        capture confirm file "`out'"
        if _rc == 0 {
            display as text "  output already exists, skipping: `out'"
            continue
        }
    }

    * Filenames in this folder.
    local files : dir "`src'" files "*.dta"
    if `"`files'"' == "" {
        display as error "  no .dta files found, skipping"
        continue
    }

    *-- Sort filenames naturally (norace1, norace2, ... norace144) rather than
    *-- alphabetically (norace1, norace10, norace100, ...) so the append order
    *-- and the `part' variable are reproducible and readable.
    clear
    local nfiles : word count `files'
    set obs `nfiles'
    quietly generate str244 fname = ""
    forvalues i = 1/`nfiles' {
        local f : word `i' of `files'
        quietly replace fname = "`f'" in `i'
    }
    quietly generate long fnum = .
    quietly replace fnum = real(regexs(1)) if regexm(fname, "([0-9]+)\.dta$")
    quietly replace fnum = 99999999 if missing(fnum)
    sort fnum fname

    local ordered ""
    forvalues i = 1/`nfiles' {
        local f = fname[`i']
        local ordered `"`ordered' "`f'""'
    }
    clear

    display as text "  `nfiles' file(s) to append"

    *-- Append them one at a time, tracking obs so `part' can be filled in on
    *-- just the newly added rows (rather than rescanning the whole dataset).
    local i 0
    foreach f of local ordered {

        local ++i

        * Part number carried by this filename.
        local pnum .
        if regexm("`f'", "([0-9]+)\.dta$") local pnum = real(regexs(1))

        if `i' == 1 {
            capture noisily use "`src'/`f'", clear
            if _rc {
                display as error "  FAILED to load `f' (rc = " _rc ")"
                exit _rc
            }
            if `add_part' quietly generate long part = `pnum'
        }
        else {
            local before = _N
            capture noisily append using "`src'/`f'"
            if _rc {
                display as error "  FAILED to append `f' (rc = " _rc ")"
                display as error "  Usually a variable-type clash between files."
                display as error "  Inspect with: describe using \"`src'/`f'\""
                exit _rc
            }
            local after = _N
            if `add_part' & `after' > `before' {
                quietly replace part = `pnum' in `=`before' + 1'/`after'
            }
        }

        display as text "  [" %3.0f `i' "/" %3.0f `nfiles' "] " ///
            %-24s "`f'" "  running N = " %15.0fc _N
    }

    *-- Save.
    if `do_compress' {
        display as text "  compressing..."
        quietly compress
    }

    display as text "  saving `out' ..."
    capture noisily save "`out'", replace
    if _rc {
        display as error "  FAILED to save (rc = " _rc ")"
        exit _rc
    }

    display as result "  DONE: `folder'  --  " %15.0fc _N " obs, " ///
        %5.0f c(k) " vars"
    clear
}

display as text _n "{hline 78}"
display as text "append_transfer.do  --  finished $S_DATE $S_TIME"
display as text "Output written to: `outdir'"
display as text "{hline 78}"

log close
