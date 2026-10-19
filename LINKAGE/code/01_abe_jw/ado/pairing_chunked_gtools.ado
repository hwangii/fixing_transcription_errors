*! version 2.4.0  04feb2026
*  Based on pairing.ado by Jacob Conway, jcconway@stanford.edu
*  Modified for memory-efficient chunked cross-joins on large datasets
*  Optimized with gtools for faster by-group operations

/* Changes from original:
   - Assumes input files are already cleaned with blocking variables prepared
   - Removed preprocessing options (apreprocessing, bpreprocessing, etc.)
   - Added chunked cross-join to reduce peak memory usage
   - Added chunk_size() and max_pairs() options
   - Added id_type option to ensure ID precision
   - Added block size diagnostics
   - Added load balancing across parallel clusters
   - Added batch_small_blocks option to reduce overhead for tiny blocks
   - Uses gtools (gegen, gisid, hashsort) for 10-50x faster operations

   v2.3.0 Task-based architecture:
   - Large blocks are now split into tasks at assignment time (not runtime)
   - Each task is ~max_pairs size for better load balancing
   - Split block outputs: Block{N}_{chunk}.dta (e.g., Block5_1.dta, Block5_2.dta)
   - Unsplit block outputs: Block{N}.dta (unchanged)
   - Resume correctly handles both split and unsplit block file patterns
   - Fixes resume bug where completed blocks were not detected (quoting issue)

   v2.4.0 Merged small blocks:
   - Small blocks are now merged into combined tasks for parallel processing
   - Source files are re-sorted to make merged blocks contiguous
   - Merged tasks use joinby (with blocking vars restored) instead of cross
   - Merged block outputs: Block{N}_merged.dta
   - batch_small_blocks option now creates unified parallel tasks instead of
     processing in main Stata instance
*/

program define pairing_chunked_gtools, rclass
    version 14
    syntax , ID_vars(string) BLocking_vars(string)                              ///
        AFile(string) BFile(string)                                             ///
        Distances(string)                                                       ///
        [output(string) Keep_vars(string) clean_pairs(string)                   ///
         do_name(string) CLUsters(integer 1) PROCessors(integer 0)              ///
         parallel_passthru(string)                                              ///
         save_blocks example_block block_dir(string) block_prefix(string)       ///
         noAPPEND resume                                                        ///
         chunk_size(integer 1000) max_pairs(integer 5000000)                    ///
         id_type(string) diagnose_blocks                                        ///
         batch_small_blocks batch_threshold(integer 10000)                      ///
         batch_size(integer 1000000)]

****************************Check for gtools***********************************

cap which gegen
if _rc {
    di as error "gtools package required for pairing_chunked_gtools"
    di as error "Install with: ssc install gtools"
    di as error "Then run: gtools, upgrade"
    error 199
}

****************************Error Checking**************************************

* Check that input files exist
confirm file `"`afile'"'
confirm file `"`bfile'"'

* Block saving requires block_dir
assert (`"`save_blocks'"'=="" & `"`example_block'"'=="") | `"`block_dir'"'!=""
if `"`append'"'=="noappend" assert `"`save_blocks'"'=="save_blocks"

* output is required unless noappend is specified
if `"`append'"'!="noappend" & `"`output'"'=="" {
    di as error "output() is required unless noappend is specified"
    error 198
}

* Set defaults
if `"`block_prefix'"'=="" local block_prefix = "Block"
if `"`do_name'"'=="" local do_name = "do_in_parallel"
if regexm(`"`do_name'"',"(^.*)(\.do$)") local do_name = regexs(1)

* Default id_type to double if not specified
if `"`id_type'"'=="" local id_type = "double"
assert inlist(`"`id_type'"', "double", "long", "string")

* Store current working directory
local cwd = `"`c(pwd)'"'

* Check necessary files exist if resuming
if `"`resume'"'=="resume" {
    assert `"`save_blocks'"'=="save_blocks"
    foreach file in `"`block_dir'/`block_prefix'_key.dta"' `"`do_name'.do"' {
        confirm file `"`file'"'
    }
}

**************************Create Useful Locals**********************************

* Specify variables to keep in block files
* Note: empty keep_vars means load all variables (no varlist in use command)
if `"`keep_vars'"'!="" {
    local keep_vars: list keep_vars | id_vars
    local keep_vars: list keep_vars | blocking_vars
    local use_varlist = "`keep_vars'"
}
else {
    local keep_vars = ""
    local use_varlist = ""  // Empty means load all variables
}

* Create version of ID variables with source (A and B) prefixes
local id_w_src
foreach id of local id_vars {
    local to_add = "A`id' B`id'"
    local id_w_src: list id_w_src | to_add
}

**************************Block Saving Preparation******************************

if `"`resume'"'=="" {

if `"`save_blocks'"'!="" | `"`example_block'"'!="" {
    mata: st_local("exists", strofreal(direxists(`"`block_dir'"')))
    if `exists' {
        mata: _to_remove = dir(`"`block_dir'"', "files", `"`block_prefix'*.dta"')
        mata: st_local("n_to_remove", strofreal(rows(_to_remove)))
        forval _fi = 1/`n_to_remove' {
            mata: st_local("_rfile", _to_remove[`_fi'])
            rm `"`block_dir'/`_rfile'"'
        }
        mata: mata drop _to_remove
    }
    else mkdir `"`block_dir'"'
    qui cd `"`cwd'"'
}

**************************Process Source Files**********************************

* Store cleaned file paths (we save working copies with correct sort order)
tempfile a_cleaned_file b_cleaned_file
local a_cleaned `"`a_cleaned_file'"'
local b_cleaned `"`b_cleaned_file'"'

foreach src in "a" "b" {

    * Load cleaned source file
    use `"``src'file'"', clear

    * Validate ID variables uniquely identify observations (gisid is faster)
    gisid `id_vars'

    * Convert ID variables to specified type for precision
    foreach idvar of local id_vars {
        cap confirm numeric variable `idvar'
        if !_rc & "`id_type'"!="string" {
            qui recast `id_type' `idvar', force
        }
    }

    * Check for missing blocking variables using gegen (faster than egen rowmiss)
    tempvar blocking_miss
    gegen `blocking_miss' = rowmiss(`blocking_vars')
    qui count if `blocking_miss'!=0
    if `r(N)'!=0 {
        di as error "Warning: `r(N)' observations in source `src' have missing blocking variables and will be excluded"
        qui drop if `blocking_miss'!=0
    }
    drop `blocking_miss'

    * Sort by blocking variables using hashsort (faster than sort for large data)
    hashsort `blocking_vars'
    qui compress

    * Save working copy - use persistent temp location for parallel access
    local `src'_cleaned_path = `"``src'_cleaned'"'
    qui save `"``src'_cleaned_path'"', replace

    * Get unique blocking variable combinations with row indices
    keep `blocking_vars'
    tempvar n
    gen long `n' = _n

    * Use gegen for faster by-group operations
    gegen long `src'_start = min(`n'), by(`blocking_vars')
    gegen long `src'_end = max(`n'), by(`blocking_vars')
    gegen long `src'_count = count(`n'), by(`blocking_vars')

    * Keep unique blocking var combinations using gtools
    gegen long _seq = seq(), by(`blocking_vars')
    qui keep if _seq == 1
    drop _seq `n'

    if "`src'"=="a" {
        tempfile ablocks
        qui save `ablocks'
    }
    else {
        * Merge to find blocks present in both sources
        qui merge 1:1 `blocking_vars' using `ablocks', nogen keep(3)
        cap rm `ablocks'
    }
}

* Number blocks and compute sizes
gen long block_number = _n
gen long block_pairs = a_count * b_count
local N_blocks_orig = _N

* Early exit: no common blocking groups means no pairs possible
if `N_blocks_orig' == 0 {
    di as text "  No common blocking groups between sources - 0 pairs"
    clear
    foreach v of local id_w_src {
        if "`id_type'"=="string" qui gen str `v' = ""
        else qui gen `id_type' `v' = .
    }
    foreach v of local distances {
        qui gen float `v' = .
    }
    return scalar N_blocks = 0
    return scalar N_tasks  = 0
    return scalar N_pairs  = 0
    qui cd `"`cwd'"'
    if `"`append'"'!="noappend" {
        qui save `"`output'"', emptyok replace
        di as text "Output saved: 0 pairs"
    }
    exit
}

******************Merge Small Blocks*********************************************

* Initialize merge tracking variables
gen int _merge_group = 0
gen byte _is_merged = 0
local n_merged_blocks = 0
local n_merge_groups = 0

if `"`batch_small_blocks'"'=="batch_small_blocks" {
    * Identify small blocks
    gen byte _is_small_block = (block_pairs <= `batch_threshold')
    qui count if _is_small_block
    local n_small_blocks = `r(N)'

    if `n_small_blocks' > 1 {
        * Assign merge groups to small blocks
        preserve
        qui keep if _is_small_block
        hashsort -block_pairs  // Largest small blocks first
        gen long _cumul = sum(block_pairs)
        replace _merge_group = ceil(_cumul / `batch_size')
        keep block_number _merge_group
        tempfile merge_assignments
        qui save `merge_assignments'
        restore

        * Merge back
        merge 1:1 block_number using `merge_assignments', nogen update replace

        * Count merge groups
        qui sum _merge_group
        local n_merge_groups = `r(max)'
        local n_merged_blocks = `n_small_blocks'

        di as text _n "Small Block Merging:"
        di as text "  Small blocks found:  " as result `n_small_blocks'
        di as text "  Merge groups:        " as result `n_merge_groups'

        * Save block key with merge assignments for re-sorting source files
        tempfile block_key_with_merge
        qui save `block_key_with_merge'

        * Re-sort A source file by merge group
        use `"`a_cleaned_path'"', clear
        * Join with block key to get merge_group (via blocking vars)
        qui merge m:1 `blocking_vars' using `block_key_with_merge', keep(1 3) nogen keepusing(_merge_group _is_small_block)
        replace _merge_group = 0 if _merge_group == .
        replace _is_small_block = 0 if _is_small_block == .
        * Sort: large blocks first (merge_group=0), then by merge_group, then by blocking vars
        hashsort _merge_group `blocking_vars'
        drop _merge_group _is_small_block
        qui save `"`a_cleaned_path'"', replace

        * Re-sort B source file by merge group
        use `"`b_cleaned_path'"', clear
        qui merge m:1 `blocking_vars' using `block_key_with_merge', keep(1 3) nogen keepusing(_merge_group _is_small_block)
        replace _merge_group = 0 if _merge_group == .
        replace _is_small_block = 0 if _is_small_block == .
        hashsort _merge_group `blocking_vars'
        drop _merge_group _is_small_block
        qui save `"`b_cleaned_path'"', replace

        * Reload block key and recompute row positions
        use `block_key_with_merge', clear

        * Recompute A positions from re-sorted file
        preserve
        use `"`a_cleaned_path'"', clear
        gen long _row = _n
        gegen long _a_start_new = min(_row), by(`blocking_vars')
        gegen long _a_end_new = max(_row), by(`blocking_vars')
        gegen long _seq = seq(), by(`blocking_vars')
        qui keep if _seq == 1
        keep `blocking_vars' _a_start_new _a_end_new
        tempfile a_new_positions
        qui save `a_new_positions'
        restore

        * Recompute B positions from re-sorted file
        preserve
        use `"`b_cleaned_path'"', clear
        gen long _row = _n
        gegen long _b_start_new = min(_row), by(`blocking_vars')
        gegen long _b_end_new = max(_row), by(`blocking_vars')
        gegen long _seq = seq(), by(`blocking_vars')
        qui keep if _seq == 1
        keep `blocking_vars' _b_start_new _b_end_new
        tempfile b_new_positions
        qui save `b_new_positions'
        restore

        * Update block key with new positions
        drop a_start a_end b_start b_end
        qui merge 1:1 `blocking_vars' using `a_new_positions', keep(1 3) nogen
        qui merge 1:1 `blocking_vars' using `b_new_positions', keep(1 3) nogen
        rename _a_start_new a_start
        rename _a_end_new a_end
        rename _b_start_new b_start
        rename _b_end_new b_end

        * Now create merged task rows
        * For each merge group, collapse to single row with combined range
        replace _is_merged = (_merge_group > 0)

        * Save non-merged blocks
        preserve
        qui keep if !_is_merged
        tempfile non_merged_blocks
        qui save `non_merged_blocks'
        restore

        * Create merged task rows
        preserve
        qui keep if _is_merged
        if _N > 0 {
            * For merged tasks: use min a_start, max a_end, min b_start, max b_end
            * Sum the block_pairs for total pairs
            * Keep first block_number as representative
            collapse (min) a_start b_start (max) a_end b_end ///
                     (sum) block_pairs (first) block_number, by(_merge_group)
            * Recompute counts from ranges
            gen long a_count = a_end - a_start + 1
            gen long b_count = b_end - b_start + 1
            gen byte _is_merged = 1
            * Note: block_pairs from collapse is the sum of individual pairs
            * which is correct - joinby will only create valid pairs
            tempfile merged_tasks
            qui save `merged_tasks'
        }
        restore

        * Combine non-merged blocks with merged tasks
        use `non_merged_blocks', clear
        cap append using `merged_tasks'

        * Renumber blocks
        sort _merge_group block_number
        drop block_number
        gen long block_number = _n

        di as text "  Blocks after merge:  " as result _N
    }
    drop _is_small_block
}

******************Expand Large Blocks into Tasks*********************************

* Preserve original values before expansion
gen long _orig_a_start = a_start
gen long _orig_a_end = a_end
gen long _orig_a_count = a_count

* Calculate effective chunk size for A records to keep pairs under max_pairs
* eff_chunk_a = floor(max_pairs / b_count), but at least 1
* For merged blocks, don't split - they use joinby, not cross
gen long _eff_chunk_a = floor(`max_pairs' / b_count)
replace _eff_chunk_a = max(_eff_chunk_a, 1)

* Calculate number of chunks needed for each block
* Merged blocks: always 1 chunk (no splitting)
gen int _n_chunks = cond(_is_merged, 1, ceil(a_count / _eff_chunk_a))

* Count blocks that will be split (excluding merged)
qui count if _n_chunks > 1 & !_is_merged
local n_split_blocks = `r(N)'
qui sum _n_chunks if !_is_merged
local total_tasks_from_splits = `r(sum)'

* Expand blocks into tasks
expand _n_chunks

* Number chunks within each block
bysort block_number: gen int chunk_num = _n

* Calculate A range for each chunk (only for non-merged tasks)
* Merged tasks keep their collapsed ranges (min a_start, max a_end)
* since they use joinby and need all records in the merge group
replace a_start = _orig_a_start + (chunk_num - 1) * _eff_chunk_a if !_is_merged
replace a_end = min(a_start + _eff_chunk_a - 1, _orig_a_end) if !_is_merged

* Recalculate counts and pairs for this task
replace a_count = a_end - a_start + 1
rename block_pairs task_pairs
* For merged tasks, keep the sum of individual block_pairs (from collapse)
* For regular tasks, recalculate since a_count may have changed due to chunking
replace task_pairs = a_count * b_count if !_is_merged

* Track max chunks per block for file naming
* Guard: gtools gegen fails on 0-obs datasets
if _N > 0 {
    gegen int _max_chunk = max(chunk_num), by(block_number)
}
else {
    gen int _max_chunk = .
}
gen byte _is_split = (_max_chunk > 1)

* Clean up temp vars
drop _orig_a_start _orig_a_end _orig_a_count _eff_chunk_a _n_chunks

* Create task_id
sort block_number chunk_num
gen long task_id = _n
local N_tasks = _N

* Report task expansion
if `n_split_blocks' > 0 {
    di as text _n "Task Expansion:"
    di as text "  Original blocks:     " as result `N_blocks_orig'
    di as text "  Blocks split:        " as result `n_split_blocks'
    di as text "  Total tasks:         " as result `N_tasks'
}

******************Load Balancing*************************************************

* Load-balance: interleave large and small tasks across clusters
* Sort by size descending, then assign round-robin to clusters
hashsort -task_pairs
gen int _cluster_assign = mod(_n - 1, `clusters')
gen double _rand = runiform()
hashsort _cluster_assign _rand  // Within each cluster assignment, randomize
drop _cluster_assign _rand

* Task size diagnostics
if `"`diagnose_blocks'"'=="diagnose_blocks" {
    di as text _n "Task Size Diagnostics:"
    di as text "======================"
    qui sum task_pairs, detail
    di as text "Original blocks:       " as result `N_blocks_orig'
    di as text "Total tasks:           " as result `N_tasks'
    di as text "Total potential pairs: " as result %15.0fc `r(sum)'
    di as text "Mean pairs/task:       " as result %12.1fc `r(mean)'
    di as text "Median pairs/task:     " as result %12.0fc `r(p50)'
    di as text "Max pairs in task:     " as result %12.0fc `r(max)'
    di as text "P99 pairs/task:        " as result %12.0fc `r(p99)'

    * Small blocks info
    if `"`batch_small_blocks'"'=="batch_small_blocks" {
        qui count if task_pairs <= `batch_threshold' & chunk_num == 1
        local n_small = `r(N)'
        qui sum task_pairs if task_pairs <= `batch_threshold' & chunk_num == 1
        local small_pairs = cond(`r(N)'>0, `r(sum)', 0)
        di as text _n "Small block batching enabled (threshold: `batch_threshold'):"
        di as text "  Small blocks:        " as result `n_small'
        di as text "  Pairs in small:      " as result %15.0fc `small_pairs'
    }

    * Show largest tasks
    di as text _n "Largest 10 tasks:"
    hashsort -task_pairs
    list task_id block_number chunk_num a_count b_count task_pairs in 1/`=min(10,_N)', noobs
    hashsort task_id
}

di as text _n "Task Summary:"
di as text "  Original blocks:       " as result `N_blocks_orig'
di as text "  Total tasks:           " as result `N_tasks'
qui sum task_pairs
local total_pairs = `r(sum)'
di as text "  Total potential pairs: " as result %15.0fc `total_pairs'

* Preview merged vs regular task split if batching enabled
if `"`batch_small_blocks'"'=="batch_small_blocks" {
    * Count merged tasks (created from small blocks)
    qui count if _is_merged == 1
    local n_merged = `r(N)'
    qui count if _is_merged == 0
    local n_regular = `r(N)'
    qui sum task_pairs if _is_merged == 1
    local merged_pairs = cond(`r(N)'>0, `r(sum)', 0)
    qui sum task_pairs if _is_merged == 0
    local regular_pairs = cond(`r(N)'>0, `r(sum)', 0)
    di as text _n "Processing strategy (all parallel):"
    di as text "  Merged tasks (small blocks): " as result `n_merged' as text " tasks, " as result %12.0fc `merged_pairs' as text " pairs"
    di as text "  Regular tasks:               " as result `n_regular' as text " tasks, " as result %12.0fc `regular_pairs' as text " pairs"
}

* Save task key (formerly block key)
if `"`save_blocks'"'!="" {
    order task_id block_number chunk_num a_start a_end b_start b_end a_count b_count task_pairs _is_split _max_chunk _is_merged _merge_group
    qui save "`block_dir'/`block_prefix'_key", replace
}

* For parallel access, save cleaned files to accessible location
* (tempfiles may not be accessible across parallel instances)
if `"`save_blocks'"'!="" | `"`example_block'"'!="" {
    local a_cleaned_parallel = `"`block_dir'/__a_cleaned_temp.dta"'
    local b_cleaned_parallel = `"`block_dir'/__b_cleaned_temp.dta"'
}
else {
    * Create temp directory for cleaned files
    local a_cleaned_parallel = `"`cwd'/__a_cleaned_temp.dta"'
    local b_cleaned_parallel = `"`cwd'/__b_cleaned_temp.dta"'
}
copy `"`a_cleaned_path'"' `"`a_cleaned_parallel'"', replace
copy `"`b_cleaned_path'"' `"`b_cleaned_parallel'"', replace

******************Parse List of Commands to Run on Block Pairs******************

* Save original clean_pairs before consuming it
local clean_pairs_orig = `"`clean_pairs'"'

local parsed_commands
while `"`clean_pairs'"'!="" {
    gettoken command clean_pairs: clean_pairs
    if regexm(`"`command'"',"\.do$") {
        local parsed_commands = `"`parsed_commands' `"qui do `command'"' _n"'
    }
    else {
        local parsed_commands = `"`parsed_commands' `"qui `command'"' _n"'
    }
}

******************All Tasks Go Through Parallel Processing***********************

* With merged small blocks, all tasks now go through parallel processing
* (The old batch_small_blocks main-instance processing is replaced by merged tasks)

******************Write .do File for Parallel Execution*************************

cap file close parallel_do
file open parallel_do using `"`do_name'.do"', write text replace

file write parallel_do                                                          ///
`"* Auto-generated do file for parallel block processing"'                   _n ///
`"* Generated by pairing_chunked_gtools.ado"'                                _n ///
`"* Uses gtools for optimized operations"'                                   _n ///
`""'                                                                         _n ///
`"* Check gtools availability"'                                              _n ///
`"cap which gegen"'                                                          _n ///
`"if _rc {"'                                                                 _n ///
`"    di as error \"gtools required - install with: ssc install gtools\""'   _n ///
`"    error 199"'                                                            _n ///
`"}"'                                                                        _n ///
`""'                                                                         _n ///
`"qui local matsize = 11000"'                                                _n ///
`"qui cap set matsize \`matsize'"'                                           _n ///
`"if _rc {"'                                                                 _n ///
`"    local matsize = 800"'                                                  _n ///
`"    qui set matsize \`matsize'"'                                           _n ///
`"}"'                                                                        _n ///
`""'                                                                         _n ///
`"* Set globals needed by filtering.do"'                                     _n ///
`"global timediff = $timediff"'                                              _n ///
`"global age_band = $age_band"'                                              _n ///
`""'                                                                         _n ///
`"local N_tasks = _N"'                                                       _n ///
`"if \`N_tasks'==0 {"'                                                       _n ///
`"    clear"'                                                                _n ///
`"    set obs 1"'                                                            _n ///
`"    gen byte var_to_drop_later = 1"'                                       _n ///
`"    exit"'                                                                 _n ///
`"}"'                                                                        _n ///
`""'                                                                         _n ///
`"* Store task info in matrices (9 columns: task_id, block_number, chunk_num, a_start, a_end, b_start, b_end, _is_split, _is_merged)"' _n ///
`"local length = floor(\`matsize'/9)"'                                       _n ///
`"forval m = 1/\`=ceil(\`N_tasks'/\`length')' {"'                            _n ///
`"    local first = (\`m'-1)*\`length' + 1"'                                 _n ///
`"    local last = min(\`m'*\`length', \`N_tasks')"'                         _n ///
`"    qui cap drop __0*"'                                                    _n ///
`"    mkmat task_id block_number chunk_num a_start a_end b_start b_end _is_split _is_merged in \`first'/\`last', matrix(Cutoffs\`m')"' _n ///
`"}"'                                                                        _n ///
`""'                                                                         _n ///
`"* File paths for cleaned sources"'                                         _n ///
`"local a_cleaned = "`a_cleaned_parallel'""'                                 _n ///
`"local b_cleaned = "`b_cleaned_parallel'""'                                 _n ///
`""'                                                                         _n ///
`"* Blocking variables for joinby (used by merged tasks)"'                   _n ///
`"local blocking_vars "`blocking_vars'""'                                    _n ///
`""'                                                                         _n ///
`"* Process each task"'                                                      _n ///
`"local pairs_list"'                                                         _n ///
`"forval i = 1/\`N_tasks' {"'                                                _n ///
`"    parallel break"'                                                       _n ///
`""'                                                                         _n ///
`"    * Get task metadata from matrix"'                                      _n ///
`"    local m = ceil(\`i'/\`length')"'                                       _n ///
`"    qui matrix slice = Cutoffs\`m'[mod(\`i'-1,\`length')+1, 1..9]"'        _n ///
`"    local task_id = slice[1,1]"'                                           _n ///
`"    local block = slice[1,2]"'                                             _n ///
`"    local chunk = slice[1,3]"'                                             _n ///
`"    local a_start = slice[1,4]"'                                           _n ///
`"    local a_end = slice[1,5]"'                                             _n ///
`"    local b_start = slice[1,6]"'                                           _n ///
`"    local b_end = slice[1,7]"'                                             _n ///
`"    local is_split = slice[1,8]"'                                          _n ///
`"    local is_merged = slice[1,9]"'                                         _n ///
`""'                                                                         _n ///
`"    * Determine output filename based on task type"'                       _n ///
`"    if \`is_merged' {"'                                                    _n ///
`"        local outfile = "`block_dir'/`block_prefix'\`block'_merged""'      _n ///
`"    }"'                                                                    _n ///
`"    else if \`is_split' {"'                                                _n ///
`"        local outfile = "`block_dir'/`block_prefix'\`block'_\`chunk'""'    _n ///
`"    }"'                                                                    _n ///
`"    else {"'                                                               _n ///
`"        local outfile = "`block_dir'/`block_prefix'\`block'""'             _n ///
`"    }"'                                                                    _n ///
`""'                                                                         _n ///
`"    * Load B observations for this task"'                                  _n ///
`"    qui use `=cond("`use_varlist'"!="", "`use_varlist' using ", "")'\`"\`b_cleaned'"' in \`b_start'/\`b_end', clear"' _n ///
`"    qui ren * B*"'                                                         _n ///
`"    * For merged tasks, restore blocking var names for joinby"'            _n ///
`"    if \`is_merged' {"'                                                    _n ///
`"        foreach bvar of local blocking_vars {"'                            _n ///
`"            cap ren B\`bvar' \`bvar'"'                                     _n ///
`"        }"'                                                                _n ///
`"    }"'                                                                    _n ///
`"    qui tempfile B_obs"'                                                   _n ///
`"    qui save \`B_obs'"'                                                    _n ///
`""'                                                                         _n ///
`"    * Load A observations for this task"'                                  _n ///
`"    qui use `=cond("`use_varlist'"!="", "`use_varlist' using ", "")'\`"\`a_cleaned'"' in \`a_start'/\`a_end', clear"' _n ///
`"    qui ren * A*"'                                                         _n ///
`"    * For merged tasks, restore blocking var names for joinby"'            _n ///
`"    if \`is_merged' {"'                                                    _n ///
`"        foreach bvar of local blocking_vars {"'                            _n ///
`"            cap ren A\`bvar' \`bvar'"'                                     _n ///
`"        }"'                                                                _n ///
`"    }"'                                                                    _n ///
`""'                                                                         _n ///
`"    * Join A with B: cross for regular tasks, joinby for merged tasks"'    _n ///
`"    if \`is_merged' {"'                                                    _n ///
`"        qui joinby \`blocking_vars' using \`B_obs'"'                       _n ///
`"    }"'                                                                    _n ///
`"    else {"'                                                               _n ///
`"        qui cross using \`B_obs'"'                                         _n ///
`"    }"'                                                                    _n ///
`"    qui compress"'                                                         _n ///
`""'                                                                         _n ///
`"    * Clean up B tempfile"'                                                _n ///
`"    cap rm \`B_obs'"'                                                      _n ///
`""'                                                                         _n ///
`"    * Save example block before processing (first task of block 1)"'       _n ///
`"    if "`example_block'"=="example_block" & \`block'==1 & \`chunk'==1 {"'  _n ///
`"        qui save "`block_dir'/`block_prefix'\`block'_precommands", replace"' _n ///
`"    }"'                                                                    _n ///
`""'                                                                         _n

* Add parsed commands (user's filtering/distance code)
if `"`parsed_commands'"'!="" {
    file write parallel_do                                                      ///
`"        * Apply user-specified processing"'                                _n ///
`parsed_commands'                                                               ///
`""'                                                                         _n
}

file write parallel_do                                                          ///
`"    * Keep only ID and distance variables"'                                _n ///
`"    qui keep `id_w_src' `distances'"'                                      _n ///
`""'                                                                         _n ///
`"    * Save or accumulate task results"'                                    _n ///
`"    if "`save_blocks'" == "save_blocks" {"'                                _n ///
`"        qui save \`"\`outfile'"', emptyok replace"'                        _n ///
`"        local Pairs\`task_id' = \`"\`outfile'"'"'                          _n ///
`"        if "`example_block'"=="example_block" & \`block'==1 & \`chunk'==1 {"' _n ///
`"            qui save "`block_dir'/`block_prefix'\`block'_processed", replace"' _n ///
`"        }"'                                                                _n ///
`"    }"'                                                                    _n ///
`"    else {"'                                                               _n ///
`"        if _N > 0 {"'                                                      _n ///
`"            qui tempfile Pairs\`task_id'"'                                 _n ///
`"            qui save \`Pairs\`task_id''"'                                  _n ///
`"        }"'                                                                _n ///
`"        if "`example_block'"=="example_block" & \`block'==1 & \`chunk'==1 {"' _n ///
`"            qui save "`block_dir'/`block_prefix'\`block'", replace"'       _n ///
`"        }"'                                                                _n ///
`"    }"'                                                                    _n ///
`""'                                                                         _n ///
`"    * Add to pairs list for final append"'                                 _n ///
`"    if "`append'" != "noappend" & _N > 0 {"'                               _n ///
`"        qui cap local pairs_list = \`"\`pairs_list' \`"\`Pairs\`task_id''"'"'"' _n ///
`"        local rc = _rc"'                                                   _n ///
`"        qui assert inlist(\`rc', 0, 920)"'                                 _n ///
`"        if \`rc' == 920 {"'                                                _n ///
`"            * Pairs list too long - combine files"'                        _n ///
`"            qui clear"'                                                    _n ///
`"            qui append using \`pairs_list' \`Pairs\`task_id''"'            _n ///
`"            foreach file of local pairs_list {"'                           _n ///
`"                cap rm \`file'"'                                           _n ///
`"            }"'                                                            _n ///
`"            qui tempfile combined_at\`task_id'"'                           _n ///
`"            qui save \`combined_at\`task_id''"'                            _n ///
`"            local pairs_list = \`"\`combined_at\`task_id''"'"'             _n ///
`"        }"'                                                                _n ///
`"    }"'                                                                    _n ///
`"}"'                                                                        _n ///
`""'                                                                         _n ///
`"* Final append of all tasks"'                                              _n ///
`"qui clear"'                                                                _n ///
`"if "`append'" != "noappend" {"'                                            _n ///
`"    if \`"\`pairs_list'"' != \`""' {"'                                     _n ///
`"        qui append using \`pairs_list'"'                                   _n ///
`"        if "`save_blocks'" != "save_blocks" {"'                            _n ///
`"            foreach file of local pairs_list {"'                           _n ///
`"                cap rm \`file'"'                                           _n ///
`"            }"'                                                            _n ///
`"        }"'                                                                _n ///
`"    }"'                                                                    _n ///
`"}"'                                                                        _n ///
`""'                                                                         _n ///
`"* Handle empty results"'                                                   _n ///
`"if _N == 0 {"'                                                             _n ///
`"    set obs 1"'                                                            _n ///
`"    gen byte var_to_drop_later = 1"'                                       _n ///
`"    keep var_to_drop_later"'                                               _n ///
`"}"'                                                                        _n

file close parallel_do

******************Resume: Load Existing Task Key, Skip Completed*****************
}
else {
    * Resume from partially completed run
    use `"`block_dir'/`block_prefix'_key.dta"', clear

    * Get existing files via Mata to avoid Stata's "too many filenames" r(134) limit
    mata: _existing_files = dir(`"`block_dir'"', "files", `"`block_prefix'*.dta"')
    mata: st_local("n_existing_files", strofreal(rows(_existing_files)))

    * Remove already-completed tasks from to-do list
    local n_completed = 0
    forval _fi = 1/`n_existing_files' {
        mata: st_local("file", _existing_files[`_fi'])

        * Skip special files (key, precommands, processed)
        if "`file'" == "`block_prefix'_key.dta" continue
        if "`file'" == "`block_prefix'1_precommands.dta" continue
        if "`file'" == "`block_prefix'1_processed.dta" continue

        * Try to match merged block pattern: Block{N}_merged.dta
        if regexm("`file'", "^`block_prefix'([0-9]+)_merged\.dta$") {
            local bnum = regexs(1)
            qui count if block_number == `bnum' & _is_merged == 1
            if `r(N)' > 0 {
                qui drop if block_number == `bnum' & _is_merged == 1
                local n_completed = `n_completed' + 1
            }
        }
        * Try to match split block pattern: Block{N}_{C}.dta
        else if regexm("`file'", "^`block_prefix'([0-9]+)_([0-9]+)\.dta$") {
            local bnum = regexs(1)
            local cnum = regexs(2)
            qui count if block_number == `bnum' & chunk_num == `cnum' & _is_merged == 0
            if `r(N)' > 0 {
                qui drop if block_number == `bnum' & chunk_num == `cnum' & _is_merged == 0
                local n_completed = `n_completed' + 1
            }
        }
        * Try to match unsplit block pattern: Block{N}.dta
        else if regexm("`file'", "^`block_prefix'([0-9]+)\.dta$") {
            local bnum = regexs(1)
            * For unsplit blocks, chunk_num is 1 and not merged
            qui count if block_number == `bnum' & chunk_num == 1 & _is_merged == 0
            if `r(N)' > 0 {
                qui drop if block_number == `bnum' & chunk_num == 1 & _is_merged == 0
                local n_completed = `n_completed' + 1
            }
        }
    }
    mata: mata drop _existing_files
    local N_tasks = _N
    di as text "Resuming: found `n_completed' completed tasks, `N_tasks' tasks remaining"

    * Get cleaned file paths from existing do file
    * (they should still exist from prior run)
    local a_cleaned_parallel = `"`block_dir'/__a_cleaned_temp.dta"'
    local b_cleaned_parallel = `"`block_dir'/__b_cleaned_temp.dta"'
}

******************Run .do File in Parallel**************************************

qui cd `"`cwd'"'

if _N != 0 {
    * Set up parallel processing
    parallel setclusters `clusters'

    * Run parallel do file
    cap parallel do `do_name'.do, processors(`processors') `parallel_passthru'
    local _pll_rc = _rc

    * Remove dummy observations created for empty clusters
    cap confirm variable var_to_drop_later
    if !_rc {
        qui drop if var_to_drop_later == 1
        drop var_to_drop_later
    }

    * Handle case where parallel returned no dataset (r(3)) or all tasks produced 0 pairs
    cap qui count
    if _rc | `_pll_rc' {
        clear
    }
}
else {
    clear
}

* Append all task results if resuming (both old and new)
* Use `use` for the first file (not clear+append) to ensure a valid dataset state.
* In Stata 15 inside a program, `clear` may leave no dataset in use, causing
* the first `append using` to give r(3). Using `use` avoids this.
if "`resume'"=="resume" {
    qui cd `"`block_dir'"'
    * Build list of all completed task files to append
    * Use Mata to list files (avoids "too many filenames" r(134) limit)
    mata: _all_files = dir(`"`block_dir'"', "files", `"`block_prefix'*.dta"')
    mata: st_local("n_all_files", strofreal(rows(_all_files)))
    local _resume_loaded = 0
    forval _fi = 1/`n_all_files' {
        mata: st_local("file", _all_files[`_fi'])
        * Skip special files
        if "`file'" == "`block_prefix'_key.dta" continue
        if "`file'" == "`block_prefix'1_precommands.dta" continue
        if "`file'" == "`block_prefix'1_processed.dta" continue
        * Use `use` for the first file to establish a valid dataset state,
        * then `append` for subsequent files
        if !`_resume_loaded' {
            qui use `"`block_dir'/`file'"', clear
            local _resume_loaded = 1
        }
        else {
            cap qui append using `"`block_dir'/`file'"'
        }
    }
    mata: mata drop _all_files
    if !`_resume_loaded' {
        * No block files found at all - ensure clean state
        clear
    }
}

* Note: With merged small blocks, all tasks go through parallel processing
* Individual task files are appended above, no separate small_block_results needed

******************************Save Results**************************************

* Ensure output has proper variable schema even when all tasks produced 0 pairs.
* If block files were saved as 0-var (e.g. from a previous run with a bug), the
* output would be 0-var 0-obs, which causes errors when `use`d downstream.
if c(k) == 0 {
    foreach v of local id_w_src {
        if "`id_type'"=="string" qui gen str `v' = ""
        else qui gen `id_type' `v' = .
    }
    foreach v of local distances {
        qui gen float `v' = .
    }
}

if "`resume'"!="resume" {
    return scalar N_blocks = `N_blocks_orig'
    return scalar N_tasks = `N_tasks'
}
return scalar N_pairs = _N

qui cd `"`cwd'"'

if `"`append'"'!="noappend" {
    qui compress
    qui save `"`output'"', emptyok replace
    di as text _n "Output saved:"
    di as text "  File:        " as result `"`output'"'
    di as text "  Total pairs: " as result %12.0fc `=_N'
}
else {
    clear
}

********************************Cleanup*****************************************

* Remove temporary cleaned files
cap rm `"`a_cleaned_parallel'"'
cap rm `"`b_cleaned_parallel'"'

* Remove do file if using default name
if `"`do_name'"'=="do_in_parallel" {
    cap rm `"`do_name'.do"'
}

end
