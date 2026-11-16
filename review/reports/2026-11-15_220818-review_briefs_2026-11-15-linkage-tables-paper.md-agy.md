# Antigravity review

*Rendered 2026-11-15 22:22. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-11-15_220818-review_briefs_2026-11-15-linkage-tables-paper.md-agy.json`*

**Dimensions:** claims-vs-code, correctness

**Result:** 2 minor, 1 nit

## Summary

All reported linkage numbers in the draft and presentation slides have been verified against the rebuilt 2026-11-15 tables and reproduce exactly, confirming the harmonization of denominators to 1940 men aged 10+ with both human transcriptions. The substantive claims regarding increased recall, higher match rates, improved middle-initial agreement, and falling contradicted shares hold across all specifications. The primary defects are terminology and presentation: the draft refers to 'all six columns of the four tables' when there are 12 columns across 6 pairwise specifications, and Table 8 Panel B shows net additions of contradicted links exceeding removals (+4,733) due to omitting changed links, superficially contradicting Panel A's net decrease (-829).

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | minor | verified | Text claims contradicted share falls in 'all six columns of the four tables', but the tables contain 12 columns and report 6 pairwise comparisons | `DHTS-2026-10-12.tex:585` || Fixed: 'every column'/'all six columns' now 'every comparison'/'all six old-to-new comparisons' (draft Sec. 4.2). |
| 2 | minor | verified | Table 8 Panel B shows net additions of contradicted links exceeding removals (+4,733), contradicting Panel A's fall (-829) and slide reporting (flat at 232k) | `DHTS-2026-10-12.tex:583, linkage_tables/linkage_table_hlink.tex:292-303, slides_ssha2026.tex:415` || Fixed: HLINK full-sample fall now quoted (232,396 to 231,567); ABE/JW note (applies to all four tables) now says Panel B covers 1930 people linked under one transcription only, excludes partner changes, and need not reconcile Panel A. Pre-existing table design, not changed. |
| 3 | nit | verified | Text claims ABE and Jaro-Winkler are run over the 'full 1930--1940 universe', but they are restricted to men | `DHTS-2026-10-12.tex:562` || Fixed: 'over the full 1930--1940 universe' now 'on the 1930 and 1940 censuses'; the denominators are stated in the notes. |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. Text claims contradicted share falls in 'all six columns of the four tables', but the tables contain 12 columns and report 6 pairwise comparisons

`six-columns-phrasing-mismatch` · **minor** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `DHTS-2026-10-12.tex:585`

**What the code does**  
DHTS-2026-10-12.tex line 585 states: 'so the share of links that the standard contradicts falls in all six columns of the four tables: from 2.43 to 2.03 percent under Jaro-Winkler...'. The four tables (Tables 6-9) contain 12 data columns total (4 + 4 + 2 + 2), representing 6 before-and-after specifications (3 algorithms x 2 samples). Furthermore, the contradicted share is a pairwise comparison across Old vs. New columns, not a column quantity, and is not reported as a row in any of the tables.

**Why it matters**  
A referee inspecting the four tables will find 12 columns rather than 6, and no row for contradicted share, making the text appear careless or confusing.

**How to check**  
Count columns across figures/deaglan_abe_jw.tex, figures/deaglan_abe_jw_restricted.tex, figures/deaglan_hlink.tex, and figures/deaglan_hlink_restricted.tex (4 + 4 + 2 + 2 = 12 columns total). Note also that no table contains a row for contradicted share.

**Suggested fix**  
Change 'so the share of links that the standard contradicts falls in all six columns of the four tables' to 'so the share of links that the standard contradicts falls across all six specifications of the four tables' (or 'in all six before-and-after comparisons across the four tables'). At line 582, change 'rises in every column' to 'rises across all specifications'.

---

### 2. Table 8 Panel B shows net additions of contradicted links exceeding removals (+4,733), contradicting Panel A's fall (-829) and slide reporting (flat at 232k)

`panel-b-contradicts-panel-a-hlink-contradicted` · **minor** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `DHTS-2026-10-12.tex:583, linkage_tables/linkage_table_hlink.tex:292-303, slides_ssha2026.tex:415`

**What the code does**  
Draft line 583 asserts: 'in the full sample it falls under all three algorithms'. In linkage_table_hlink.tex Panel A, Directly Contradicted falls by 829 (232,396 to 231,567). However, Panel B of the same table reports Added Directly Contradicted of 50,355 against Removed of 45,622, showing net additions exceeding removals by +4,733. This occurs because LINKAGE/code/02_hlink/linkage_analysis_newlinks.do:431-484 only includes 'net_added' and 'net_removed' in Panel B, omitting 'changed' links (where 5,562 more links stopped being contradicted than became contradicted). In slides_ssha2026.tex:415, the count is reported as 232k for both Old and New.

**Why it matters**  
A referee examining Table 8 Panel B will conclude that new transcriptions added more bad links than they removed, contradicting Panel A and the paper's narrative.

**How to check**  
Compare linkage_tables/linkage_table_hlink.tex Panel A (231,567 - 232,396 = -829) with Panel B (Added 50,355 - Removed 45,622 = +4,733). Check slides_ssha2026.tex:415 where HLINK Directly Contradicted is reported as 232k for both Old and New.

**Suggested fix**  
Add a note to Table 8 (and Table 6) explaining that Panel B tabulates links added and removed for newly matched or unmatched individuals, but excludes links where the 1930 individual is matched to a different 1940 individual ('changed links'). In the draft text, clarify that HLINK's contradicted link count in the full sample falls slightly (-829 links, or -0.36%, appearing unchanged at 232k when rounded to thousands).

---

### 3. Text claims ABE and Jaro-Winkler are run over the 'full 1930--1940 universe', but they are restricted to men

`full-universe-claim-for-male-only-linkers` · **nit** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `DHTS-2026-10-12.tex:562`

**What the code does**  
Line 562 states: 'Each is run twice over the full 1930--1940 universe, once on the Ancestry transcriptions and once on ours...'. In reality, ABE and Jaro-Winkler were run only on the male census population (standard in historical demography due to surname changes upon marriage), whereas only HLINK was run over the universe of men and women.

**Why it matters**  
Imprecise phrasing invites confusion over why women are absent from Tables 6 and 7 if the algorithms were ostensibly run over the full universe.

**How to check**  
Compare DHTS-2026-10-12.tex:562 with LINKAGE/code/01_abe_jw/linkage_analysis.do:5-7 and line 63, which demonstrate that ABE and Jaro-Winkler are run exclusively on men.

**Suggested fix**  
Clarify line 562 to state: 'Each is run twice over the 1930--1940 census universe (men for ABE and Jaro-Winkler; men and women for HLINK), once on the Ancestry transcriptions and once on ours...'

---

## Checked and sound

- **Exact-name reproduction of Table 3 (tab:avg_performance)** — Traced in figures/deaglan_abe_jw_restricted.tex and figures/avg_performance_allstates.tex. Target match rate before/after (8.88% vs 8.9%, 19.41% vs 19.4%, +119%) and share validated before/after (65.41% vs 65.4%, 83.60% vs 83.6%, +28%) match exactly, asserted in LINKAGE/code/01_abe_jw/linkage_analysis.do:404-450.
- **Discordant sample verified correct links and recall** — Traced in DHTS-2026-10-12.tex:19, 582 against linkage_tables/linkage_table_abe_jw_restricted.tex:256, 259 (ABE verified 523,091 to 1,319,555; recall 11.13% -> 11.1% to 28.07% -> 28.1%), Jaro-Winkler recall (20.58% -> 20.6% to 32.47% -> 32.5%), and linkage_tables/linkage_table_hlink_restricted.tex:327 (HLINK recall 72.68% -> 72.7% to 81.58% -> 81.6%).
- **Contradicted share fall across all six specifications** — Verified by calculating contradicted / (verified + unverifiable + contradicted) across all six columns of linkage_tables/linkage_table_abe_jw.tex, linkage_table_abe_jw_restricted.tex, linkage_table_hlink.tex, and linkage_table_hlink_restricted.tex. Contradicted share falls in every specification: JW full (2.43% to 2.03%), ABE full (2.74% to 2.32%), HLINK full (0.70% to 0.68%), JW discordant (4.08% to 2.24%), ABE discordant (5.09% to 2.56%), and HLINK discordant (0.74% to 0.69%), exactly matching lines 19, 51, and 585 of DHTS-2026-10-12.tex.
- **Slides numbers consistency with new tables** — Traced in slides_ssha2026.tex:384-389, 411-416 against linkage_tables/ and figures/. All 36 table cells across both slides (Target and All records) match the new tables exactly, with rounded integer counts in thousands and rates to two decimals accurately reported.
- **Middle initial match rate increases across all algorithms** — Traced in DHTS-2026-10-12.tex:571 against linkage_tables/linkage_table_abe_jw_restricted.tex:255 (ABE 65.41% -> 65.4% to 83.60% -> 83.6%; JW 72.39% -> 72.4% to 83.91% -> 83.9%) and linkage_tables/linkage_table_hlink_restricted.tex:323 (HLINK 76.54% -> 76.5% to 84.04% -> 84.0%).
- **Table notes denominator and middle initial rule descriptions** — Traced in DHTS-2026-10-12.tex:605, 620, 636, 651. The notes accurately state the harmonized denominator of 51,036,859 men aged 10+ with both transcriptions (14,416,543 discordant for restricted tables) and describe that MI match rate scores each version against its own 1940 middle initial, exactly matching LINKAGE/code/01_abe_jw/linkage_analysis.do:63-75, 244 and LINKAGE/code/02_hlink/linkage_analysis_newlinks.do:198-210, 376.
- **Directly contradicted count movements** — Traced in DHTS-2026-10-12.tex:583 against linkage_tables/linkage_table_abe_jw.tex:224 (JW full 286,323 to 254,780), linkage_tables/linkage_table_abe_jw_restricted.tex:258 (ABE discordant 65,137 to 71,662), and linkage_tables/linkage_table_hlink_restricted.tex:326 (HLINK discordant 57,089 to 61,244).

## What this review could not establish

- Data files in $D_FLAGS, $D_LINKS, and $D_TRUTH reside on external storage (F:/ and D:/Dropbox) and were not directly readable.
- Stata pipeline execution could not be run interactively; runtime behavior was verified by static code tracing, machine B execution logs, and output LaTeX tables.
