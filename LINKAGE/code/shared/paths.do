* ============================================================
* paths.do -- single source of truth for every path
* ============================================================
* Every script in this package derives its paths from ROOT.
* If the project moves, change ROOT here and nowhere else.
*
* This file exists because the package previously carried
* absolute paths on three different drive letters (D:, E:, F:)
* that silently went stale whenever a folder was moved. Nothing
* below this file should ever hardcode a drive letter again.
*
* To relocate the project, either edit ROOT below, or define it
* before calling this file:
*     global ROOT "X:/somewhere/Census_Transcriptions"
*     do "X:/somewhere/Census_Transcriptions/code/shared/paths.do"
* ------------------------------------------------------------

if "$ROOT" == "" {
    global ROOT "F:/Deaglan/Census_Transcriptions"
}

capture confirm file "$ROOT/code/shared/paths.do"
if _rc {
    di as error "paths.do: ROOT does not look like the project root:"
    di as error "  $ROOT"
    exit 601
}

* ---- code ----
global CODE         "$ROOT/code"
global C_ABEJW      "$CODE/01_abe_jw"
global C_HLINK      "$CODE/02_hlink"
global C_MORT       "$CODE/03_mortality"

* ---- data ----
* data/ is organised by ROLE, not by which pipeline happens to read a file.
* Where a folder was split, the global keeps pointing at whatever the majority
* of scripts wanted, so the split cost almost no edits:
*
*   data/
*   |- census/                 source census extracts
*   |- names/
*   |  |- cleaned/             clean_names_*        <- D_NAMES
*   |  \- flags/               ipums_fs congruence  <- D_FLAGS
*   |- transcriptions/
*   |  |- shards/              144 x 4 raw shards   <- D_TRANSCRIPT
*   |  \- appended/            one file per vintage <- D_APPENDED
*   |- links/
*   |  |- raw_hlink/           third-party CSVs     <- D_LINKS_RAW
*   |  \- derived/             linked pairs we made <- D_LINKS
*   |- truth/                  ground truth + source crosswalk
*   \- mortality/
*      |- raw/  intermediate/
*      \- working/             splits, shards, matched output
*
global DATA         "$ROOT/data"
global D_CENSUS     "$DATA/census"

* Cleaned name extracts are what nearly every script means by "names", so
* D_NAMES points at them; the congruence flags are a different kind of thing.
global D_NAMES      "$DATA/names/cleaned"
global D_FLAGS      "$DATA/names/flags"

* The raw shards and their appended one-file-per-vintage versions are the same
* data at two stages, so they live together under transcriptions/.
global D_TRANSCRIPT "$DATA/transcriptions/shards"
global D_APPENDED   "$DATA/transcriptions/appended"

* Links we derived vs the third-party HLINK CSVs they came from. D_LINKS is the
* derived set because that is what every table script reads.
global D_LINKS      "$DATA/links/derived"
global D_LINKS_RAW  "$DATA/links/raw_hlink"

global D_TRUTH      "$DATA/truth"
global D_MORT       "$DATA/mortality"

* ---- output ----
global OUT          "$ROOT/output"
global OUT_TABLES   "$OUT/tables"
global OUT_LOGS     "$OUT/logs"
capture mkdir "$OUT"
capture mkdir "$OUT_TABLES"
capture mkdir "$OUT_LOGS"

* ============================================================
* LINKAGE-STEP PATHS (not needed to rebuild tables)
* ============================================================
* The ABE/JW matching pipeline keeps its own working tree of
* per-birthplace splits, blocks and intermediates. It used to
* live outside the package at F:/Deaglan/abe_jw; it is now
* inside it, so the package is self-contained.
*
* It sits at the project root rather than under data/ because
* it is a working tree with its own internal conventions -- its
* scripts do cd "$ABEJW" and then use relative paths like
* "data\matched\...". Preserving that layout means this one
* global relocates the whole tree; flattening it into data/
* would mean rewriting 60+ path literals across 15 files.
if "$ABEJW" == "" {
    global ABEJW "$ROOT/abe_jw"
}

* Source census extracts the ABE/JW prep reads (step 0 only --
* everything downstream of clean_names is already built).
* Copied in from D:/ABE_JW/DATA/ORIGINAL, which also holds
* 1850/1880 extracts belonging to other projects.
global ABE_SRC "$ABEJW/data/source_census"
