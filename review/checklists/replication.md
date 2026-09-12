# Checklist — replication integrity

Could someone else reproduce the tables from raw inputs? Increasingly a condition
of acceptance, and the work is far cheaper done now than during a revision.

## Paths and portability

- Hardcoded absolute paths (`D:\Dropbox\...`, `F:\...`). Every one is a blocker
  for an external replicator. Are they at least centralised in one header, or
  scattered across files?
- The same logical directory reached by different literal paths in different
  files (a Dropbox path in one, a local drive in another) — these drift apart.
- `cd`-relative logic that depends on where the script was launched from.
- Windows-only path separators and drive letters in code meant to be archived.

## Pipeline order

- Can the `.do` files be ordered into a runnable sequence from a single master?
  Does the master actually call everything, or have files been added since?
- Scripts that depend on a dataset produced by a script the master does not run.
- Manual steps between scripts (an export opened in Excel, a file renamed by
  hand). Any of these that is undocumented is a replication break.
- Dead or superseded files: multiple versions (`V2`, `V3`, `V4`, `V5`,
  `_new_scrape2024_summer`, `_nber`, `_SSHA2025`). Which is current? An archive
  containing five variants with no statement of which produced the paper is a
  finding in itself.

## Determinism

- Randomness without `set seed`.
- Results depending on sort order where sorts are not unique (`sort` vs `gsort`
  with ties; `bysort` on a non-unique key).
- Anything depending on wall-clock time or on the current contents of a directory.
- Loops over `dir` listings, where output depends on what files happen to exist.

## Environment

- Stata version and `version` statement. User-written commands (`reghdfe`,
  `ftools`, `estout`, …) with no install instructions or version pins.
- Python dependencies with no `requirements.txt` or pinned versions.
- Data provenance: for each input, is it stated where it came from, when it was
  downloaded/scraped, and under what licence it may be redistributed?

## Outputs

- Tables and figures written to paths that exist only on the author's machine.
- Results pasted into the paper by hand rather than written by code — the path by
  which a stale number survives a rerun.
- Output files overwritten in place with no record of which code version produced
  them.

## What to output

Rank by what would actually stop a replicator: missing data provenance and
unrunnable master files outrank a hardcoded path that a replicator could fix in
one edit.
