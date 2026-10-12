# REQUEST — deposit the all-states ABE-JW and HLINK/MLP tables into git

> **DONE 2026-10-11** on the machine holding `F:\Deaglan\Census_Transcriptions\`.
> Paper repo commit `32355f1`: five tables copied byte-for-byte (SHA-256
> checked) into `deaglan_results/current/`, plus `PROVENANCE.md` answering all
> eight questions. Nothing regenerated; nothing in `deaglan_results/` touched.
>
> Read `PROVENANCE.md` before wiring the tables in. Three findings change the
> premise of this request:
>
> - **The current numbers were already in the paper repo.**
>   `deaglan_results/linkage_table_HLINK*.tex` and `deaglan_results/main.tex`
>   (ABE/JW) match `current/` exactly. Only `linkage_table_newlinks*.tex` is
>   retired.
> - **The package's HLINK captions are wrong** ("all men"). The denominator is
>   men and women aged 8+. Deaglan's 2026-08-28 copies in `deaglan_results/`
>   have the correct caption; use that one.
> - **`current/` reuses the old `\label`s.** `\input` only one copy of each.
>
> Coverage is 48 states + DC (no Alaska, no Hawaii). The `newlinks*`
> quarantine is still Sam's decision.

**Written 2026-10-11 from the D:\repos machine, for Claude Code on the machine
that holds `F:\Deaglan\Census_Transcriptions\`.**

Feed this file to Claude Code on that machine. It is self-contained; you should
not need any other context.

---

## The ask, in one sentence

Copy Deaglan's **four current** linkage tables (ABE-JW and HLINK/MLP, full and
restricted) out of his package and commit them to the **paper repo**, then
answer the eight questions at the bottom in a short committed note, so the
draft can `\input{}` them instead of anyone retyping numbers.

## Why this request exists

The draft is being updated to the all-states sample. The ABE-JW and HLINK
tables are needed for that, and **the machine writing the draft cannot see
Deaglan's package** — `F:\Deaglan\Census_Transcriptions\` does not exist there
(`F:`, `D:` and `E:` were all searched).

Worse, the copies that *are* in the paper repo are the wrong ones.
`deaglan_results/linkage_table_newlinks.tex` and `_restricted` report match
rates of **116.01 / 118.94** and **101.87 / 115.92** — over 100%. Those came
from `_archive/output_previous/`, i.e. the retired script that used
`dedup_rule "prob"` / `unique1940`. They must never reach the paper.

The project rule is **numbers come from committed files, never from typing**
(see `CLAUDE.md` in both repos). So the tables have to arrive as `.tex`.

---

## Step 1 — confirm you are on the right machine

```powershell
Test-Path 'F:\Deaglan\Census_Transcriptions\output\tables'
```

If that is `False`, stop: you are on the wrong machine and this request is not
for you. Say so rather than regenerating anything.

## Step 2 — list what is actually there

```powershell
Get-ChildItem 'F:\Deaglan\Census_Transcriptions\output\tables' -Filter '*.tex' |
    Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize
```

Expected (per `review/scopes/deaglan-census-transcriptions.md`):

| Linkage | Producing script | Table files |
|---|---|---|
| ABE + Jaro-Winkler, 1930↔1940 | `code/01_abe_jw/linkage_analysis.do` | `linkage_table_abe_jw*.tex` |
| HLINK (IPUMS MLP), 1930↔1940 | `code/02_hlink/linkage_analysis_newlinks.do` | `linkage_table_hlink*.tex` |
| Mortality, 1940↔BUNMD | `code/03_mortality/05_make_linkage_table.do` | `linkage_table_mortality_bunmd.tex` |

**Take the files from `output/tables/` only.** Do **not** take anything from
`_archive/output_previous/` — that is the retired 116–119% output.

If the filenames differ from the table above, report what you found and stop
before copying; do not guess which file is which.

## Step 3 — copy the four tables into the paper repo

Destination is a **new** subfolder, to avoid any collision with the retired
files already committed there (and note `linkage_table_HLINK.tex` already
exists with different capitalisation, which Windows treats as the same name):

```
F:\github_repos\6638fa0fd89fbec05130caeb\deaglan_results\current\
```

Copy, keeping the package's own filenames:

- `linkage_table_abe_jw.tex`
- `linkage_table_abe_jw_restricted.tex`
- `linkage_table_hlink.tex`
- `linkage_table_hlink_restricted.tex`

Also copy `linkage_table_mortality_bunmd.tex` into the same folder if it
exists. It has never been in the paper repo, and even if the draft does not use
it, having it committed costs nothing and closes a known gap.

Then pull, commit and push the **paper** repo:

```powershell
cd F:\github_repos\6638fa0fd89fbec05130caeb
git pull --ff-only
git add deaglan_results/current
git commit -m "Add Deaglan's current all-states ABE-JW and HLINK tables"
git push
```

### Two traps on this step

1. **`.gitignore` excludes `*.txt`, `*.csv`, `*.dta`.** `.tex` is fine, but run
   `git status` after adding and confirm each file is actually tracked. A table
   that is silently ignored will never reach the other machine.
2. **Do not overwrite, move or delete anything already in `deaglan_results/`.**
   Deaglan's outputs are frozen: neither machine can reproduce them. Adding a
   new subfolder is safe; touching the existing files is not. If you think the
   retired `linkage_table_newlinks*` files should be quarantined, *say so in
   your report* and let Sam decide — do not do it unasked.

## Step 4 — do NOT regenerate anything

Do not run `code/00_run_all_tables.do` or any table script. The package is
frozen, HLINK matching is third-party and cannot be regenerated, and two pieces
of producing code were previously lost and reconstructed. We want the committed
artefacts exactly as they stand, not a fresh run that might differ.

If a table appears wrong, **report it; do not rebuild it.**

## Step 5 — answer these eight questions

Write the answers to
`F:\github_repos\6638fa0fd89fbec05130caeb\deaglan_results\current\PROVENANCE.md`
and commit it with the tables. These are things the draft cannot state
correctly without you, and that cannot be inferred from the `.tex` files:

1. **Are these the all-states tables?** What is the state coverage of the "new"
   (ML) transcription used — 48, 49 or 50 states, and which are excluded?
   *This matters: Hawaii has no Ancestry extract at all (0 observations), so
   `hi\merged_data.dta` has no `namefrst`/`fs_namefrst` columns and Hawaii
   contributes 0 records to the transcription-comparison script on the other
   machine. Confirm whether Deaglan's run is in the same position, and whether
   Alaska is in or out.*
2. **When were these tables generated**, and from which input vintage of the ML
   transcription? File timestamps plus whatever `output/logs/` records.
3. **Exact denominator of each table.** The scope file already establishes that
   the HLINK denominator is built from
   `divided_file1940_true_cleaned_women_added.dta` — **men and women** aged 8+ —
   into a scalar still named `N_men_1940_full`, while ABE/JW uses
   `clean_names_1940_new.dta`, **men only**, and that both captions say "all men
   in the 1940 census". Confirm this is still true of the files you copied, and
   give the exact N for each.
4. **Is "Match Rate" pairs ÷ persons, or share of persons linked?** The link
   file is not one-to-one, so these differ. If it is pairs ÷ persons, say
   whether a `first40 == 1` version exists or could be stated.
5. **Does the HLINK numerator still count links outside its own denominator?**
   The Codex review put this at 58.08/59.55 → 58.06/59.52. Say whether the
   copied table has it.
6. **Confirm the age cutoff** in each copied table (expected `age >= 8` in both
   census-to-census scripts), and whether `keep if age >= 8` still retains
   *missing* ages.
7. **Is "Directly Contradicted" still a 1940-side-only truth check?** If so the
   draft must not call it a false-positive rate without saying so.
8. **Is the "byte-identical reproduction" claim verified?** The review found the
   master log has no comparison step. Say whether that is still the case, so the
   paper does not repeat an unverified claim.

Short answers are fine. "Unchanged from the review" is a fine answer where true.

## Step 6 — report back

In your final message, state plainly:

- which files you copied, with sizes and timestamps
- the commit SHA you pushed to the paper repo
- the answers to the eight questions, or which you could not answer
- anything that looked wrong but which you left alone

Do not edit `DHTS-2024-11-18.tex`. Wiring the tables into the draft is being
done on the other machine, and an unpushed `.tex` edited on both machines at
once is the one thing the paper's `CLAUDE.md` warns hardest about.

---

## Summary for a human

> On the machine with `F:\Deaglan\Census_Transcriptions\`: copy the four
> current tables from `output/tables/` (**not** `_archive/output_previous/`)
> into `deaglan_results/current/` in the paper repo, add a `PROVENANCE.md`
> answering the eight questions above, commit and push. Regenerate nothing.
