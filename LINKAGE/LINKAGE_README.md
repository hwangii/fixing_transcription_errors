# Linkage steps — how the links themselves were produced

`README.md` covers layout; `DOCUMENTATION.md` covers the **tables**. This file
covers the step *before* the tables: how each set of linked pairs was created.

> **What has and has not been re-run.** Paths have been repaired and every input
> verified present on disk. The HLINK and mortality link files in
> `data/links/derived/` and `data/mortality/` are the **originals** — no matching
> step was re-executed to produce them, so treat their runtimes below as
> estimates from the original runs.
>
> **The ABE matcher is the exception.** It is a reconstruction
> (`code/01_abe_jw/linkage/run_abe_match.do`), so it has been run here: first on
> Massachusetts alone, where it reproduced the originals exactly, and then on the
> full count for both transcriptions. Its output is written under a distinct
> `_RECONSTRUCTED` name and **never overwrites** the original
> `link1930_1940_*_noraceblock0.dta`, so the two can be compared. See
> "Reconstructing the ABE links" below.
>
> The **table** scripts have been re-run in full: all five tables reproduce
> byte-identically after the data reorganisation (`DOCUMENTATION.md` §5).

---

## Why this is separate from the tables

The three table scripts (`code/00_run_all_tables.do`) read already-linked pairs
and take minutes to hours. The linkage steps below **create** those pairs and
take hours to days, need extra Stata packages, and in one case cannot be run here
at all. Keeping them separate means a reader can reproduce every published number
without re-running a match.

| Linkage | Matching done by | Re-runnable here? |
|---|---|---|
| ABE + Jaro-Winkler | us | Yes — full pipeline present |
| HLINK | **third party** | **No** — see below |
| Mortality (census↔BUNMD) | us | Yes — full pipeline present |

---

## 1. ABE / Jaro-Winkler — `code/01_abe_jw/`

Links 1930 census men to 1940 census men using the ABE algorithm with
Jaro-Winkler string distance. Imported into this package from `F:\Deaglan\abe_jw`.

```
code/01_abe_jw/
├── linkage/      the pipeline that produces the links
├── ado/          pairing_chunked_gtools.ado, filtering.do  (required)
├── comparison/   ABE-exact vs ABE-JW side-by-side comparison
├── reference/    original ABE algorithm + abematch/abeclean ados + docs
└── linkage_analysis.do   the TABLE script (see DOCUMENTATION.md)
```

### Pipeline order

| Step | Script | Does |
|---|---|---|
| 0 | `linkage/00_merge_names_to_census.do` | Merges transcription shards onto the raw census extracts |
| 1 | `linkage/run_full_census_prep.do` | Generates initials, filters to males, drops missing blocking vars, splits into one file per birthplace, writes `bpl_list.dta` |
| 2-4 | `linkage/run_full_census_match.do` | Loops over birthplaces running stages 2-4 independently, then appends. Resumable — skips birthplaces that already have output |
| — | `linkage/0{1..5}_*.do` | The individual stages the runner calls: clean names → match → decision rules → within-dataset uniqueness → wrap up |

That is the **Jaro-Winkler** half. The **ABE** half is separate:

| Step | Script | Does |
|---|---|---|
| A | `linkage/run_abe_match.do` | RECONSTRUCTED ABE matcher: `abematch` on cleaned names per birthplace, then appends and merges middle initials. Produces `link1930_1940_*_noraceblock0*.dta` |
| A′ | `linkage/validate_abe_reconstruction.do` | Checks that reconstruction against the original link files, pair by pair |

Run the `_new_transcription` variants (`run_full_census_prep_new_transcription.do`,
`run_full_census_match_new_transcription.do`) to produce the "new" side. The two
variants differ only in which cleaned-name file they read.

**Why birthplace-by-birthplace:** `bpl` is a blocking variable, so matching never
crosses a birthplace boundary. Each can be processed independently with identical
results, which is what makes the job parallelizable and resumable.

### Configuration

`run_full_census_match.do` lines 38-48: 12 parallel clusters × 2 processors,
5,000,000 max pairs before a block is split, 2-year maximum age difference,
cleanup of block files after each birthplace.

### Outputs → the package

| Produced at | Copied into package as |
|---|---|
| `$ABEJW/data/matched/JW_matches_x2_unique.dta` | `data/links/derived/JW_matches_x2_unique_old.dta` |
| `$ABEJW/data/matched_new_transcription/JW_matches_x2_unique.dta` | `data/links/derived/JW_matches_x2_unique_new.dta` |

Verified byte-for-byte: 1,026,322,760 and 1,091,740,547 respectively.

### Reconstructing the ABE links

The JW half of this linkage has its producing code. The **ABE** half did not —
nothing on any drive referenced `noraceblock`, the string in the output
filenames. `linkage/run_abe_match.do` fills that gap. Its parameters were
inferred from the surviving artifacts (see the inference table in its header),
then tested rather than assumed.

`linkage/validate_abe_reconstruction.do` runs the test. Matching row counts
would be weak evidence — different parameterisations can land on similar
totals — so it compares the **pairs themselves**. The originals are full-census
with no `bpl` column, but `bpl` is a blocking variable, so every link's A-side
record lives in exactly one `by_bpl` file; restricting the originals to A-side
ids from `bpl_25` recovers precisely the original's Massachusetts links.

Result on Massachusetts, 2026-09-06:

| | |
|---|---|
| original links, bpl 25 only | 488,439 |
| reconstruction pairs | 488,439 |
| in both | 488,439 (100.0% both ways) |
| reconstruction only | 0 |
| original only | 0 |
| `f_name_A` `l_name_A` `f_name_B` `l_name_B` `fiveyr_band` `mi1930` `mi1940` | all identical |

Two details fell out of the string widths and are worth recording, because they
pin choices that would otherwise stay guesses:

- `mi` is **str13** in `clean_names_1930_old` and **str14** in
  `clean_names_1940_old` — exactly the widths of `mi1930`/`mi1940` in *both*
  target files. That identifies the middle-initial sources and confirms the
  old/new vintage mapping.
- `abematch` suffixes the **source variable name**, so `id_A(histid)` emits
  `histid_A`. The originals carry `id_A`/`id_B`, so the original author renamed
  `histid`→`id` before matching. The script does this in its prep step.

**What this does and does not establish.** One birthplace reproducing exactly is
strong evidence for the parameter set as a whole, since every parameter is
exercised on 1.6M × 1.8M records. It is not proof that the other 135 birthplaces
reproduce. Still open: whether `f_name_A` carries cleaned or raw names — both are
str16, and on bpl 25 the cleaned and raw values are identical on all 488,439
rows, so the comparison could not discriminate. Output is unaffected either way.

### Running the ABE match on the full count

`linkage/run_abe_match.do` ships configured for exactly this: `vintage "both"`,
`bpl_subset ""`. Run it and it processes all 136 birthplaces for both
transcriptions.

**Runtime: 6.9 h for both vintages** (3.19 h old, 3.41 h new), measured end to
end on 2026-09-06/07, serial, zero birthplace failures. An earlier projection of
5.5 h from the first two birthplaces was optimistic by about 25%.

### Full-count result

|  | reconstruction | original | difference |
|---|---|---|---|
| `ans_cleaned` (old) | 16,944,747 | 16,946,362 | −1,615 |
| `true_cleaned` (new) | 18,197,078 | 18,198,099 | −1,021 |

99.99% agreement, and a **strict subset** both times — the reconstruction
produces **zero** pairs the original lacks. So the matching rule is right, and
the difference is upstream: which 1930 records reach the matcher at all.

**Every missing pair, 100% of them in both vintages, is a one-name join.**
Diagnosed by `linkage/diagnose_abe_shortfall*.do` in three steps:

1. Strict subset, and every missing pair's A-side id is absent from the `by_bpl`
   inputs entirely.
2. All those ids *are* in `clean_names_1930_old`, and are male with birthplace
   and race — but have a blank **first** name (791 old / 563 new) or a blank
   **last** name (947 / 593). `run_full_census_prep.do` drops them because a
   record with no initial cannot be blocked.
3. In the original link file, those pairs are blank on the *same field on both
   sides*: `george <blank>` ↔ `george <blank>`, `<blank> smith` ↔
   `<blank> smith`. ABE matches names exactly, so a blank can only ever have
   matched another blank.

The reconstruction is therefore not losing real links — it declines to make
links resting on a single name field. **845 (old) and 630 (new) of them carry
`fiveyr_band == 1`**, so the original link files, and the published table built
from them, contain that many one-name links. Against 12.5M and 13.5M
`fiveyr_band` pairs that is 0.007% — far too small to move any published number,
but a property of the originals worth knowing.

Do **not** close the gap by loosening the matcher. It is a deliberate
prep-stage exclusion; reproducing it would mean re-admitting blank-name blocking.

**Schema.** Both reconstructed files carry the originals' nine variables in the
originals' order, with matching types. Two remaining differences, neither
affecting any value:

- The original `true_cleaned` file has a **tenth** variable,
  `name_true_cleaned_exists`, which the reconstruction does not produce. Nothing
  in this package reads it, and no surviving script shows how it was built.
- String widths follow Stata's `compress`, so they reflect the longest value
  actually present: `mi1940` is str11 in the reconstructed new-vintage file
  against str14 in the original. Same values, narrower storage.

The estimate is insensitive to how cost scales with block size, because the
birthplace distribution is flat: the largest bpl is 2.89× Massachusetts and the
top five hold 29% of 128,090,207 records.

Three things make a long run survivable, all on by default:

| Setting | Effect |
|---|---|
| `overwrite 0` | Birthplaces already done are skipped, so an interrupted run resumes rather than restarting |
| `stop_on_error 0` | One failing birthplace is recorded and the run continues; all failures are listed at the end |
| `allow_partial 0` | The combined file is **not** written from an incomplete set — a link file quietly missing three states looks exactly like a correct one downstream |

The completeness check treats a birthplace as incomplete if it failed *this run*,
not merely if its output file is absent. That distinction matters: with
`overwrite 1`, a failing birthplace still has last run's output on disk, and an
existence test alone would append a stale result beside fresh ones and report
success. This was found by deliberately failing one birthplace in a test.

A full run writes to `data/links/derived/link1930_1940_*_noraceblock0_RECONSTRUCTED.dta`
and compares its row count against the originals' 16,946,362 / 18,198,099,
reporting an exact match or the difference. It never overwrites the originals.

**It is serial by choice.** The JW runner beside it uses 12 parallel clusters and
birthplaces are independent by construction, so the same treatment would cut this
to well under an hour per vintage. That is deliberately not done: the
reconstruction was validated serially, and adding concurrency would put
unvalidated machinery between the inputs and a result we can currently prove is
exact. Parallelise once a full serial run has been checked against the originals.

---

## 2. HLINK — `code/02_hlink/`

**The HLINK matching was performed by a third party and its code is not in this
package.** A search of all six drives found no code of any language referencing
`hlink`. What arrived here is its raw output:

```
data/links/raw_hlink/step1_matches_{before,after}.csv    (35.9 GB, four files)
```

What *is* ours is the cleanup that turns those into usable pairs:

| Script | Does |
|---|---|
| `code/02_hlink/build_matched_links.do` | Imports the four CSVs, keeps `prediction == 1`, renames to `histid1930`/`histid1940`, and arbitrates step 1 against step 2 |

**Conflict rule: step 2 supersedes step 1.** A step-1 pair survives only if
*neither* of its records appears anywhere in step 2. That catches both collision
types — one 1930 record linked to two different 1940 records, and two 1930
records linked to the same 1940 record.

Outputs `data/links/derived/matches_{before,after}.dta` — 66,807,539 and 68,498,407 pairs.

> `build_matched_links.do` is a **reconstruction** from a log echo, not the
> original file. Its SETTINGS block is inferred. See `DOCUMENTATION.md` §6.

---

## 3. Mortality (census ↔ BUNMD) — `code/03_mortality/`

Links the 1940 census to Berkeley Unified Numident mortality records, once on old
names and once on new.

| Step | Script | Runtime |
|---|---|---|
| 0a | `000_import_new_census_vars.do` → `000_merge_new_census_vars.do` | Builds the census extract from IPUMS + marital status |
| 0b | `0_create_birthplace_crosswalk.do` | Harmonized birthplace codes via `statastates` |
| 0c | `0_merge_new_names.do` | Merges old/new transcription shards onto the census |
| 1 | `01_run_clean_names.do` | `abeclean` on census (twice) and BUNMD | ~30-60 min |
| 2 | `02_1_split_census_by_bpl.do`, `02_2_split_bunmd_by_bpl.do` | Split both sides by birthplace | ~15 min |
| **3** | **`03_match.do`** | **`abematch` over ~140 birthplace pairs, twice** | **several hours** |
| 4 | `04_post_match.do` | Appends 448 matched shards into four consolidated files; writes the denominator `temp.dta` | ~10 min |

`00_master_run_all.do` drives all of it. Steps 0-3 are currently commented out at
lines 101-109 — only steps 4 and 5 are live, which is the state you want for
rebuilding tables without re-matching.

**Conservative vs exact:** `03_match.do` lines 65-66. A conservative match
additionally requires `unique_file2 == 1` and `unique_match2 == 1` — no competing
candidate within ±2 years of birth on either side.

---

## Data locations

Everything the linkage steps read, and whether it is inside the package:

**Everything the linkage steps read is now inside the package.** Nothing reaches
outside it, and no drive letter appears in any script.

| Data | Location | Size |
|---|---|---|
| ABE/JW working tree (per-bpl splits, prep intermediates, matched output) | `$ABEJW` = `abe_jw/data/` | 76 GB |
| Source census extracts | `$ABE_SRC` = `abe_jw/data/source_census/` | 21 GB |
| Cleaned name files | `data/names/cleaned/clean_names_*.dta` | 17 GB |
| Transcription shards (women added) | `data/transcriptions/` | 41 GB |
| Transcription shards (men only, ABE/JW vintage) | `abe_jw/data/full_census/names/` | 20 GB |
| HLINK raw CSVs | `data/links/raw_hlink/step{1,2}_matches_*.csv` | 36 GB |
| Ground truth + its source crosswalk | `data/truth/` | 19 GB |
| BUNMD + mortality working tree | `data/mortality/` | 127 GB |

### Why the working tree sits at the root, not under `data/`

`abe_jw/` is a working tree with its own internal conventions: its scripts
`cd "$ABEJW"` and then use relative paths like `"data\matched\..."`, with mixed
`/` and `\` separators. Preserving that layout means the single `ABEJW` global
relocates the entire tree. Flattening it into `data/` would read marginally
better but would require rewriting 60+ path literals across 15 files of working
pipeline code — real risk for a cosmetic gain, so it was not done.

| Subdir | Size | Regenerable? |
|---|---|---|
| `by_bpl/` + `by_bpl_new_transcription/` | 28 GB | Yes, from `full_census/` — direct input to both matchers |
| `full_census/` + `full_census_new_transcription/` | 38 GB | Yes, from `source_census/` + shards |
| `source_census/` | 21 GB | **No** — raw IPUMS-derived input |
| `matched/` + `matched_new_transcription/` | 10 GB | The JW outputs; `JW_matches_x2_unique` is also in `data/links/derived/` |
| `matched_abe_old/` | 0.2 GB | The ABE reconstruction's test output |

---

## Paths

Every imported script was repointed off the dead `E:\Deaglan\abe_jw` root onto
package globals — 19 files patched, ~50 path literals. Two globals in
`code/shared/paths.do` govern the linkage steps:

```stata
global ABEJW   "$ROOT/abe_jw"             // ABE/JW working tree (now in-package)
global ABE_SRC "$ABEJW/data/source_census" // source census extracts
```

Each script keeps its original `cd "$ABEJW"` plus relative paths, so the working
tree layout is unchanged from the original run.

---

## Software requirements

The table scripts need none of these. The linkage steps need all of them:

| Package | Used by | Source |
|---|---|---|
| `abematch`, `abeclean` | ABE/JW and mortality matching | Vendored at `code/01_abe_jw/reference/`; also unpacked at `F:\Deaglan\abe_algorithm_code_july2020_0_0\` |
| `pairing_chunked_gtools` | ABE/JW blocking | `code/01_abe_jw/ado/` |
| `gtools`, `ftools` | Throughout | `ssc install` |
| `statastates` | Birthplace crosswalk | `ssc install` |
| `parallel` | ABE/JW multi-cluster runs | SSC |

---

## Known gaps

- **HLINK matching code does not exist here.** Third-party. Only its raw CSV
  output and our cleanup script are present. The HLINK links cannot be
  regenerated from this package.
- **The ABE links had no producing code on disk — now reconstructed and
  validated.** `data/links/derived/link1930_1940_{true,ans}_cleaned_noraceblock0.dta`
  (2.8 / 3.1 GB, dated 2026-03-18) feed the ABE columns of table 1, but no
  script on any drive references `noraceblock`. `linkage/run_abe_match.do` is a
  reconstruction whose parameters were inferred from the surviving artifacts,
  then **verified to reproduce the originals exactly on Massachusetts** — the
  identical 488,439-pair set with every field identical, not merely matching
  totals. See "Reconstructing the ABE links" below. The `comparison/` scripts
  run ABE-exact vs ABE-JW but write differently-named outputs
  (`ABE_exact_matches*.dta`), so they are related work, not the missing producer.
- **`usa_00015.dat` is missing** — the IPUMS extract behind the mortality census
  vars. Its output is present, so no table is blocked.
- **Transcription vintages differ.** `abe_jw/data/full_census/names/` holds
  `divided_file{1930,1940}_{ans,true}_cleaned` while `data/transcriptions/` holds
  `..._cleaned_women_added`. These are different vintages — the ABE/JW pipeline
  filters to males, so its shards are the men-only originals. The mortality
  pipeline's `0_merge_new_names.do` additionally wants
  `divided_file1940_true_cleaned_third_batch`, which exists in neither location.
- **`comparison/abeclean.ado:518`** contains `cd "C:\Users\mjdcu\..."`, a path
  from the original author's machine. Left as-is: it is third-party code and
  editing it would fork a vendored dependency.
