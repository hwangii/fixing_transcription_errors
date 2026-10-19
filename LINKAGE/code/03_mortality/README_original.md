# Replication Package: 1940 Census–Mortality Record Linkage

## Overview

This replication package implements a record linkage pipeline connecting the **1940 U.S. Census** to Social Security mortality records — specifically the **Berkeley Unified Numident Mortality Database (BUNMD)**. It uses the **ABE (Abramitzky–Boustan–Eriksson)** exact matching algorithm to link individuals across these two datasets.

The pipeline is implemented in **Stata** (`code/`) and is based on the methodology developed by the [CenSoc Project](https://censoc.berkeley.edu/) at UC Berkeley (Breen, Alexander, Joo, Goldstein, Yildirim, and Osborne). The `censocdev-master/` directory contains the original CenSoc R package for reference.

---

## Data Sources

| Dataset | Description | File |
|---|---|---|
| 1940 U.S. Census | Individual-level census records from IPUMS | `data/census_raw/1940_census_for_merge_with_bunmd.dta` |
| BUNMD v2 | Berkeley Unified Numident Mortality Database | `data/raw/bunmd_v2/bunmd_v2.csv` |
| CenSoc-Numident v3 | Pre-linked Census–Numident file (reference) | `data/raw/censoc_numident_v3.csv` |
| CenSoc-DMF v3 | Pre-linked Census–Death Master File (reference) | `data/raw/censoc_dmf_v3.csv` |

> **Note:** The raw data files are not included in this repository due to size and licensing restrictions. See [Data Access](#data-access) below.

---

## Software Requirements

| Software | Version | Purpose |
|---|---|---|
| Stata | 14 or higher | All pipeline steps (Unicode string functions required) |
| `abematch` | — | Stata command implementing ABE exact matching |
| `statastates` | — | Stata state FIPS code lookup |
| `gtools` | — | Fast group operations |
| `ftools` | — | Fast Stata functions |

Install Stata dependencies by running (once):
```stata
ssc install statastates
ssc install gtools
ssc install ftools
gtools, upgrade
```

---

## Directory Structure

```
Mortality_Census_Link/
├── code/                          # Main Stata pipeline
│   ├── 00_master_run_all.do       # Master script — run this
│   ├── 0_create_birthplace_crosswalk.do
│   ├── 0_merge_new_names.do
│   ├── 01_run_clean_names.do
│   ├── 02_1_split_census_by_bpl.do
│   ├── 02_2_split_bunmd_by_bpl.do
│   ├── 03_match.do
│   ├── 04_post_match.do
│   ├── 000_import_new_census_vars.do
│   └── 000_merge_new_census_vars.do
│
├── data/
│   ├── raw/                       # Input data (not included)
│   │   ├── bunmd_v2/bunmd_v2.csv
│   │   ├── censoc_numident_v3.csv
│   │   └── censoc_dmf_v3.csv
│   ├── census_raw/                # 1940 Census input (not included)
│   ├── intermediate/              # Name dictionaries and working files
│   │   └── titles_and_nicknames/  # titles.csv, male/female_nicknames.csv
│   └── output_sam/                # All output files written here
│       ├── 1940-census-by-bpl/    # Census split by birthplace
│       ├── bunmd-by-bpl/          # BUNMD split by birthplace
│       ├── matched-census-bunmd-oldnames/
│       ├── matched-census-bunmd-newnames/
│       └── log/
│
└── censocdev-master/              # CenSoc R package (reference implementation)
```

---

## Pipeline Steps

### Step 0a — Create Birthplace Crosswalk
**Script:** [code/0_create_birthplace_crosswalk.do](code/0_create_birthplace_crosswalk.do)

Harmonizes birthplace codes across the Census and BUNMD. The Census uses numeric BPL codes while BUNMD uses strings. This script:
- Extracts unique birthplace strings from both datasets
- Maps U.S. states to FIPS codes (format: `US-XX`)
- Retains non-U.S. locations as cleaned strings
- Outputs: `data/output_sam/bpl_crosswalk.dta`

### Step 0b — Merge Name Variants
**Script:** [code/0_merge_new_names.do](code/0_merge_new_names.do)

Combines "old" and "new" name cleaning variants for the 1940 Census into a single file for downstream processing. Merges on `histid`.

### Step 1 — Clean Names
**Script:** [code/01_run_clean_names.do](code/01_run_clean_names.do)

Standardizes names in both the Census and BUNMD using the `abeclean` command. The cleaning pipeline:
1. Transliterates Unicode characters to ASCII (removes accents)
2. Converts to lowercase and trims whitespace
3. Removes honorific titles (Dr., Mrs., Rev., etc.) using `data/intermediate/titles_and_nicknames/titles.csv`
4. Normalizes multi-word name prefixes (mc, st, mac, etc.)
5. Converts nicknames to formal names using sex-specific dictionaries (`male_nicknames.csv`, `female_nicknames.csv`)
6. Extracts first name, last name, and middle initial
7. Applies SOUNDEX and NYSIIS phonetic encoding

### Step 2 — Split by Birthplace
**Scripts:** [code/02_1_split_census_by_bpl.do](code/02_1_split_census_by_bpl.do), [code/02_2_split_bunmd_by_bpl.do](code/02_2_split_bunmd_by_bpl.do)

Splits the cleaned Census and BUNMD into separate `.dta` files, one per harmonized birthplace (`bpl_h`). This reduces matching to within-birthplace comparisons, dramatically shrinking the search space.

- Census: ~150+ files by birthplace
- BUNMD: Corresponding birthplace files
- Census `age` variable recoded as `census_age`: `1940 - byear` if born Jan–Mar, else `1939 - byear`

### Step 3 — ABE Matching
**Script:** [code/03_match.do](code/03_match.do)

Core record linkage step. Runs the `abematch` command on each birthplace pair (Census file A × BUNMD file B), matching on `fname_cleaned`, `lname_cleaned`, and `bpl_h`.

The script runs **twice** — once using "old" name cleaning and once using "new" name cleaning — enabling comparison of which approach yields better match quality.

For each birthplace, two output files are produced:

| Output | Description | Filter |
|---|---|---|
| `ABE_exact_matches_*` | Standard ABE matches | All bidirectional matches |
| `ABE_exact_matches_*_5yr_band.dta` | Conservative matches | `unique_file2 == 1` AND `unique_match2 == 1` |

**ABE matching logic:**
- **Exact match:** `(fname, lname, age)` combination appears exactly once in each dataset — a unique one-to-one match
- **Non-exact match:** No age-exact match, but the individual matches uniquely within ±1 or ±2 years
- **Conservative match:** Names are unique within ±2 years in the individual's *own* dataset (`unique_file2`) AND the individual matches to exactly one person in the *other* dataset within ±2 years (`unique_match2`)
- **Bidirectional:** Only matches found in both Census→BUNMD and BUNMD→Census directions are retained

### Step 4 — Post-Match Quality Assessment
**Script:** [code/04_post_match.do](code/04_post_match.do)

Evaluates and compares match quality across name-cleaning strategies. For each combination of (old/new names) × (exact/conservative):

1. Calculates **match rate** = matched records / total BUNMD male records born ≤ 1940
2. Identifies a **validation sample**: matched records where both Census middle initial and BUNMD middle name are non-missing
3. Calculates **validation rate** = share where Census middle initial matches BUNMD middle name initial

This allows comparison of whether "new" name cleaning improves match rates and/or match quality relative to "old" name cleaning.

---

## Running the Pipeline

### Configuration

Before running, open [code/00_master_run_all.do](code/00_master_run_all.do) and update the following global paths to match your system:

```stata
global base_path  "E:/Deaglan/Mortality_Census_Link"    // ← change this
global census_raw "...path to 1940_census_for_merge_with_bunmd..."
global bunmd_raw  "...path to bunmd_v2.csv..."
```

### Execution

Run all steps by executing the master script in Stata:

```stata
do "code/00_master_run_all.do"
```

Individual steps can be enabled or disabled by commenting/uncommenting lines 94–102 of the master script.

### Expected Runtime

| Step | Approximate Time |
|---|---|
| Step 0: Birthplace crosswalk | < 5 minutes |
| Step 1: Name cleaning | ~30–60 minutes |
| Step 2: Split by birthplace | ~15 minutes |
| Step 3: ABE matching (all BPL files × 2) | Several hours |
| Step 4: Post-match assessment | < 10 minutes |

---

## Outputs

All output files are written to `data/output_sam/`.

| Path | Contents |
|---|---|
| `1940-census-by-bpl/*.dta` | Census records split by birthplace |
| `bunmd-by-bpl/*.dta` | BUNMD records split by birthplace |
| `matched-census-bunmd-oldnames/ABE_exact_matches_old_*.dta` | Standard matches, old names |
| `matched-census-bunmd-oldnames/*_5yr_band.dta` | Conservative matches, old names |
| `matched-census-bunmd-newnames/ABE_exact_matches_new_*.dta` | Standard matches, new names |
| `matched-census-bunmd-newnames/*_5yr_band.dta` | Conservative matches, new names |
| `log/post_match.smcl` | Match quality log |

**Key variables in matched output files:**

| Variable | Source | Description |
|---|---|---|
| `id` | Census | IPUMS `histid` identifier |
| `ssn` | BUNMD | Social Security Number |
| `age_1940` | Census | Imputed Census age |
| `timediff_A`, `timediff_B` | Matching | Age difference at match |
| `unique_file2` | Matching | Name unique within ±2 yrs in own dataset |
| `unique_match2` | Matching | Uniquely matched within ±2 yrs in other dataset |
| `fname_cleaned`, `lname_cleaned` | Both | Standardized names used for matching |

---

## Data Access

The raw data files are available from the following sources:

- **1940 U.S. Census:** [IPUMS USA](https://usa.ipums.org/) — requires registration
- **BUNMD v2:** [CenSoc Project](https://censoc.berkeley.edu/) — available upon request
- **CenSoc-Numident / CenSoc-DMF:** [CenSoc Project](https://censoc.berkeley.edu/) — public download

---

## Reference Implementation

The `censocdev-master/` directory contains the original R package implementation of this pipeline, developed by the CenSoc team at UC Berkeley. The Stata code in `code/` is a translation of the R pipeline for users who prefer Stata. The underlying algorithm (`match_records.R`) and name-cleaning logic (`clean-names.R`) are documented in detail in that package.

For the R pipeline, see `censocdev-master/codebase/02_create_censoc/README.md`.

---

## Citation

If you use this code or the CenSoc methodology, please cite the CenSoc project:

> Breen, C., Alexander, M., Joo, W., Goldstein, J. R., Yildirim, U., & Osborne, M. *CenSoc: Linked Mortality Data*. University of California, Berkeley. [https://censoc.berkeley.edu](https://censoc.berkeley.edu)
