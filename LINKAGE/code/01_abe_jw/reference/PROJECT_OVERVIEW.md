# ABE-JW Record Linkage Project

## Overview

This project implements the **ABE (Abramitzky-Boustan-Eriksson) matching algorithm** with **Jaro-Winkler string distance adjustments** to link individuals across US Census datasets. The code is adapted from the original ABE algorithm to work with historical census data, specifically linking individuals between 1930 and 1940 census records.

**Note on scale:** For full-count census data, the ABE methodology recommends splitting data by place of birth before matching. For example, when matching US-born men in 1930 to 1940, create separate files for each state (50 files × 2 years = 100 files) and run the matching process for each state separately. This implementation currently processes Delaware as a single state.

## Project Structure

```
abe_jw/
├── abe_original_code/       # Original ABE algorithm implementation
│   ├── ABE_matching_algorithm.do
│   ├── JW_decision_rules.do
│   ├── JW_within_dataset_uniqueness.do
│   ├── filtering.do
│   ├── gen_initials.do
│   ├── abeclean.ado
│   ├── abematch.ado
│   └── pairing.ado
├── code/                    # Adapted implementation
│   ├── 00_create_synthetic_dataset.do
│   ├── 01_clean_names.do
│   ├── 02_match_jw.do
│   └── ado/
│       ├── filtering.do
│       └── pairing_chunked_gtools.ado
└── data/                    # Data directories
    ├── raw_census/          # Original census extracts
    ├── clean_names/         # Cleaned datasets
    ├── candidate_pairs/     # Candidate match pairs
    └── BlocksAtoB/          # Blocked data for matching
```

## What is the ABE Algorithm?

The ABE matching algorithm, developed by Ran Abramitzky (Stanford), Leah Boustan (Princeton), and Katherine Eriksson (UC Davis), is a widely-used method for linking historical census records. It uses:

1. **Name standardization** (NYSIIS phonetic encoding)
2. **Age consistency** (with tolerance for reporting errors)
3. **Blocking variables** (geographic location, initials)
4. **Uniqueness requirements** (to ensure high-quality matches)

**What is NYSIIS?** The New York State Identification and Intelligence System (NYSIIS) is a phonetic encoding algorithm that converts names to standardized codes based on pronunciation. For example:
- "Smith" and "Smyth" → same NYSIIS code
- "John" and "Jon" → same NYSIIS code
- "Miller" and "Mueller" → same NYSIIS code

This allows exact matching on phonetically similar names, even when spelled differently.

### Two Variants of ABE

The ABE methodology has two main variants:

1. **ABE with Exact/NYSIIS Names** (simpler):
   - Matches on exact NYSIIS codes (not implemented in current code)
   - Requires perfect match on standardized names
   - Faster but less flexible
   - Used in Abramitzky et al. (2012, 2014)

2. **ABE with Jaro-Winkler** (this implementation):
   - Matches using JW string distance ≤ 0.1
   - Allows for additional spelling variation beyond NYSIIS
   - More flexible but computationally intensive
   - Better for records with high error rates

### Jaro-Winkler Extension

This project uses the Jaro-Winkler variant, which:
- Calculates **string distance** between names rather than requiring exact matches
- Allows for spelling variations and transcription errors
- Uses a threshold (typically ≤ 0.1 JW distance) to define potential matches
- Applies decision rules to select the best match among candidates

**Why JW instead of exact matching?** JW string distances are particularly useful for historical records because:
- Names may be spelled differently across censuses
- Transcription errors are common in handwritten records
- Allows matching "John" to "Jon" or "Smith" to "Smyth"
- More flexible than NYSIIS phonetic coding alone

## Workflow

### Stage 0: Data Extraction ([00_create_synthetic_dataset.do](code/00_create_synthetic_dataset.do))

Extracts state-specific subsets from full census files:
- Currently configured for **Delaware** (statefip == 10)
- Creates separate files for 1930 and 1940 census
- Pennsylvania code commented out but available

**Inputs:**
- `matching_intgen1930.dta` (full 1930 census)
- `matching_intgen1940.dta` (full 1940 census)

**Outputs:**
- `data/raw_census/delaware_1930.dta`
- `data/raw_census/delaware_1940.dta`

### Stage 1: Name Cleaning ([01_clean_names.do](code/01_clean_names.do))

Prepares datasets for linking by:
1. **Loading raw census data** for both time periods
2. **Cleaning names** using NYSIIS phonetic encoding
3. **Creating blocking variables:**
   - `bpl`: Birthplace (state × county)
   - `first_initial`: First letter of first name
   - `last_initial`: First letter of last name
4. **Computing derived variables:**
   - `age`: Age at census (census_yr - birthyr)
5. **Restricting sample:**
   - Males only (sex == 1)

**Key Variables:**
- **ID:** `histid` (unique census record identifier)
- **Names:** `namefrst_ans`, `namelast_ans` (raw) → `f_name_cleaned`, `l_name_cleaned` (NYSIIS)
- **Middle initial:** `mi`
- **Birthplace:** `statefip`, `countyicp` → `bpl`
- **Demographics:** `birthyr`, `age`, `race`, `sex`

**Outputs:**
- `data/clean_names/clean_names_1930.dta`
- `data/clean_names/clean_names_1940.dta`

### Stage 2: Generate Candidate Pairs ([02_match_jw.do](code/02_match_jw.do))

**Purpose:** Find all potential matches and calculate JW distances. This stage does NOT make final matching decisions—it only identifies candidates.

Uses the `pairing_chunked_gtools` command to:

1. **Block the data:**
   - Birthplace (`bpl`)
   - First initial (`first_initial`)
   - Last initial (`last_initial`)

   Only pairs within the same block are considered.

2. **Filter candidate pairs** (via [filtering.do](code/ado/filtering.do)):
   - Age difference ≤ 2 years (accounting for 10-year gap between censuses)
   - JW distance ≤ 0.1 for first names
   - JW distance ≤ 0.1 for last names

   Pairs failing any criterion are dropped.

3. **Calculate distance metrics:**
   - `jw_f_name_cleaned`: Jaro-Winkler distance for first names
   - `jw_l_name_cleaned`: Jaro-Winkler distance for last names
   - `age_diff`: Absolute difference in reported age

4. **Parallel processing with intelligent batching:**
   - Uses 12 clusters with 2 processors each (24 parallel processes)
   - **Splits large blocks:** Blocks >1M pairs are subdivided
   - **Combines small blocks:** Blocks <200K pairs are batched together (target: 2M pairs per batch)
   - Saves each block separately for memory efficiency

**Key Parameters:**
- **Time difference:** 10 years (1940 - 1930)
- **Age band:** ±2 years (stricter than typical ±5 years)
- **JW threshold:** 0.1 for both first and last names
- **Max pairs per block:** 1,000,000 (triggers split)
- **Batch threshold:** 200,000 (triggers combine)
- **Batch size:** 2,000,000 (target for combined blocks)

**Outputs:**
- **Block files:** `data/BlocksAtoB/Block1.dta`, `Block2.dta`, etc.
- **Block key:** `data/BlocksAtoB/Block_key.dta` (maps blocks to blocking variables)
- **Candidate pairs:** May be saved to `data/candidate_pairs/` (depending on options)

**Important Notes:**
- At this stage, individuals may appear in multiple candidate pairs. The decision rules (Stage 3) will select the best match from these candidates.
- **Resume functionality:** If the pairing process is interrupted, set `local resume "resume"` in [02_match_jw.do](code/02_match_jw.do:11) to continue from where it stopped rather than starting over.

## Key Adaptations from Original ABE Code

| Aspect | Original ABE | Current Implementation |
|--------|-------------|------------------------|
| **Name cleaning** | Uses `abeclean.ado` | Pre-cleaned NYSIIS variables in data |
| **Pairing command** | `pairing.ado` | `pairing_chunked_gtools.ado` (optimized) |
| **Blocking** | First/last initials + birthplace | Same, but with `fegen` for grouping |
| **Parallel processing** | Uses `parallel` package | Uses `gtools` with chunking |
| **Data structure** | Norwegian census example | US census (Delaware/Pennsylvania) |
| **ID variables** | Constructed from serial+pernum | Pre-existing `histid` |
| **Decision rules** | Separate post-processing via `JW_decision_rules.do` | Not yet implemented (TODO) |
| **Age band** | Typically ±5 years for candidates | Currently ±2 years (more restrictive) |

## Technical Details

### Blocking Strategy

Blocking reduces computational burden by only comparing records that:
- Were born in the same county (`bpl`)
- Have matching first initials (`first_initial`)
- Have matching last initials (`last_initial`)

**Why use initials for blocking?** Errors in name spelling and transcription are less likely to occur with the first letter of a name compared to middle or ending letters. This makes initials a reliable blocking variable.

**Impact:** Blocking dramatically reduces the number of pairwise comparisons from O(n²) to manageable sizes. For example, blocking on first initial alone reduces comparisons by ~96% (assuming 26 letters distributed roughly evenly).

**Alternative blocking strategies:**
- Add middle initial (if available and reliable)
- Add race (for datasets where race is reliably recorded)
- Use only state of birth (for smaller datasets)
- Use finer geographic detail (township, enumeration district)

### Filtering Criteria ([filtering.do](code/ado/filtering.do))

Candidate pairs must satisfy:
```stata
age_diff = abs((Bage - timediff) - Aage) <= age_band
jw_f_name_cleaned <= 0.1
jw_l_name_cleaned <= 0.1
```

Where:
- `Aage`, `Bage`: Age in 1930 and 1940
- `timediff`: 10 years
- `age_band`: 2 years (global parameter in current implementation)

**Note on age bands:** The original ABE methodology typically uses:
- **age_band = 5** for initial candidate filtering (finding potential matches)
- **age_band = 2** in the current implementation (more restrictive)
- **max_age_diff = 2** for final match acceptance (applied in decision rules)

The current implementation uses a tighter initial filter (±2 years) compared to the standard ABE approach (±5 years).

### Jaro-Winkler Distance

- **Range:** 0 (perfect match) to 1 (completely different)
- **Threshold:** 0.1 (names must be 90%+ similar)
- **Direction:** Flipped from similarity to distance metric
- **Application:** Applied independently to first and last names

## ABE-JW Decision Rules

After generating candidate pairs (individuals within the age band with JW distance ≤ 0.1), three scenarios can occur:

### Scenario 1: No Potential Match
Individual in dataset A has **no potential matches** in dataset B.
- **Action:** Drop this individual from the analysis

### Scenario 2: Unique Match
Individual in dataset A has **exactly one potential match** in B, and that individual in B has **no other potential matches** in A.
- **Action:** Accept as a successful match

### Scenario 3: Multiple Potential Matches
Individual has **more than one potential match** within the age band.
- **Action:** Apply the following decision rule:
  1. Calculate `d1` = age difference to the **closest** match
  2. Calculate `d2` = age difference to the **second closest** match
  3. Keep the match **only if** `d2 - d1 > x`

### The "x" Parameter

The parameter **x** controls how conservative the matching is:

- **x = 0** (Less conservative):
  - Keep the closest match by age, as long as it's unique
  - Used for broader samples
  - Typically combined with exact age uniqueness requirement

- **x = 2** (More conservative):
  - Drop any observation with more than one potential match within ±2 years
  - Second-best match must be >2 years farther than the best match
  - Higher quality matches, but lower match rate
  - Typically combined with ±2 year uniqueness requirement

### Maximum Age Difference

The `max_age_diff` parameter sets the maximum allowable age difference:
- **max_age_diff = 0**: Require exact age match (most conservative)
- **max_age_diff = 2**: Allow ±2 year age difference (standard)

**Note:** The initial age band (typically ±5 years) is for finding *candidates*, but `max_age_diff` is the final threshold for *accepting* matches.

## Within-Dataset Uniqueness

**Why is this needed?** Jaro-Winkler string distances are **not transitive**. This means:
- Person A might match Person B with JW distance ≤ 0.1
- But Person A might also be very similar to Person C *within their own dataset*
- If A and C are near-duplicates, the match A-B becomes less reliable

### Process:

1. **Find within-dataset JW distances:**
   - For all successfully matched individuals in dataset A, calculate JW distances to all other individuals in A within ±2 years of age
   - Repeat for dataset B

2. **Create uniqueness indicators:**
   - `unique_within_0_yr_band`: Unique by exact age
   - `unique_within_2_yr_band`: Unique within ±2 years

3. **Apply uniqueness filters:**
   - When using **x = 0**: Require uniqueness by exact age (0-year band)
   - When using **x = 2**: Require uniqueness within ±2 years (2-year band)

### Typical Match Quality Hierarchy

| Match Type | x | max_age_diff | Within-dataset uniqueness | Quality | Match Rate |
|------------|---|--------------|---------------------------|---------|------------|
| Least conservative | 0 | 2 | None | Lower | Highest |
| Standard | 0 | 2 | 0-year band | Medium | Medium-High |
| Conservative | 2 | 2 | 2-year band | High | Medium-Low |
| Most conservative | 2 | 0 | 2-year band | Highest | Lowest |

## Next Steps (Current Implementation Status)

The current code completes the **pairing stage** (Stage 2). To complete the matching workflow:

### Stage 3: Apply Decision Rules (TODO)
Implement the ABE-JW decision rules described above:
- Load candidate pairs from `data/candidate_pairs/` or `data/BlocksAtoB/`
- For each block, identify best matches using the three-scenario logic
- Generate matched datasets for different values of x (0 and 2)
- Save as `JW_matches_x0.dta` and `JW_matches_x2.dta`

### Stage 4: Within-Dataset Uniqueness (TODO)
Calculate within-dataset JW distances:
- For matched individuals, find JW distances within own dataset
- Create uniqueness indicators
- Filter matches based on uniqueness requirements
- Save final matched samples

### Stage 5: Quality Assessment
- Calculate match rates by age, birthplace, etc.
- Compare distributions of matched vs. unmatched individuals
- Validate using known matches if available
- Test robustness to different parameter choices

## Software Requirements

- **Stata** (version 14 or higher recommended)
- **User-written commands from SSC:**
  - `nysiis` - for phonetic name encoding (if using abeclean)
  - `jarowinkler` - for string distance calculations
  - `gtools` - fast data manipulation (replaces `parallel` from original)

  Install with: `ssc install <package_name>`

- **Custom .ado files:**
  - `pairing_chunked_gtools.ado` (adapted from original `pairing.ado`)
  - `filtering.do` (defines candidate pair filtering criteria)

**Note:** The original ABE code uses the `parallel` package for parallelization, but this implementation uses `gtools` with custom chunking for better performance on large datasets.

## Data Sources

- **IPUMS Full-Count Census Data** (inferred from variable names)
  - 1930 US Census
  - 1940 US Census
- **Variables used:**
  - `histid`: IPUMS unique identifier
  - `namefrst_ans`, `namelast_ans`: Answered name variables
  - `namefrst_ans_nysiis`, `namelast_ans_nysiis`: Pre-cleaned phonetic codes
  - `birthyr`, `age`: Age variables
  - `statefip`, `countyicp`: Geographic codes
  - `race`, `sex`: Demographics

## Contact Information

Original ABE algorithm authors:
- Ran Abramitzky (Stanford): ranabr@stanford.edu
- Leah Boustan (Princeton): lboustan@princeton.edu
- Katherine Eriksson (UC Davis): kaeriksson@ucdavis.edu

## References

### Core Methodology
- **Abramitzky, R., Boustan, L., Eriksson, K., Feigenbaum, J., & Pérez, S. (2019).** "Automated Linking of Historical Data." NBER Working Paper. [Link](https://ranabr.people.stanford.edu/sites/g/files/sbiybj5391/f/linking_may2019.pdf)
  - *Comprehensive guide to the ABE algorithm and related methods*

### Applications
- Abramitzky, R., Boustan, L., & Eriksson, K. (2012). "Europe's tired, poor, huddled masses: Self-selection and economic outcomes in the age of mass migration." *American Economic Review*, 102(5), 1832-1856.
- Abramitzky, R., Boustan, L., & Eriksson, K. (2014). "A nation of immigrants: Assimilation and economic outcomes in the age of mass migration." *Journal of Political Economy*, 122(3), 467-506.

---

*Last updated: February 7, 2026*
*Incorporates information from official ABE algorithm readme ([ABE_algorithm_readme.txt](ABE_algorithm_readme.txt))*