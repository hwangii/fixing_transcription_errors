# Codex review

*Rendered 2026-11-10 01:34. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-11-10_012232-review_profile_links-full-agy.json`*

**Dimensions:** correctness, claims-vs-code, replication, identification

**Result:** 1 blocker, 2 major, 2 minor, 2 nit

## Summary

The pipeline's SQL joins, 1:1 checks, and Stage-1 reconciliation are technically sound, but the evaluation design suffers from a severe econometric circularity on Census Tree recall. CT recall is reported as 88.1% alongside MLP's 69.5%, yet over two-thirds of CT's recalled links are mechanically ingested from FamilySearch tree records (ct_family_tree=1), dropping CT's true algorithmic recall to 28.6%. The single most important fix is to split CT recall by ct_family_tree (mirroring the precision split) so machine linkage is not credited with discovering records it imported from the benchmark.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | BLOCKER | verified | Census Tree recall against profile links is mechanically inflated by unflagged family tree links | `profile_links_vs_machine.py:123-134` | |
| 2 | MAJOR | verified | Census Tree 'unflagged' precision split still includes FamilySearch profile and direct hints | `profile_links_vs_machine.py:207-217` | |
| 3 | MAJOR | verified | Pooled summary table indiscriminately pools the 20-year span (1880-1900) into 10-year pairs | `profile_links_vs_machine.py:218-224` | |
| 4 | minor | verified | Precision formatting performs unguarded float division that will crash on zero judged links | `profile_links_vs_machine.py:204, profile_links_vs_machine.py:224` | |
| 5 | minor | verified | Writing OUT_MD fails if REPO_ROOT/documents directory does not exist | `profile_links_vs_machine.py:58, profile_links_vs_machine.py:225` | |
| 6 | nit | verified | Pooled summary table omits unlinked profile links, obscuring the recall partition | `profile_links_vs_machine.py:218-224` | |
| 7 | nit | verified | Stage-1 parser relies on rigid character slice line[3:5] for section detection | `profile_links_vs_machine.py:76-78` | |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. Census Tree recall against profile links is mechanically inflated by unflagged family tree links

`ct-recall-circularity-family-tree` · **BLOCKER** · identification · confidence: **verified** (traced in source)

**Where:** `profile_links_vs_machine.py:123-134`

**What the code does**  
Computes recall for CT over all links without splitting by ct_family_tree: 'SELECT count(*) FILTER (WHERE l1.histid_2 = p.h2) AS found ... FROM prof p LEFT JOIN lk l1 ON l1.histid_1 = p.h1'. In contrast, lines 207-217 split precision by ct_family_tree because 'Links CT flags as taken from the FamilySearch tree are not an independent test against FamilySearch attachments.'

**Why it matters**  
In 1850_1860, CT's reported recall is 88.1% (6,296,183 found) compared to MLP's 69.5%. However, 4,249,457 of those found links (59.5% of all profile links, and 67.5% of CT found links) carry ct_family_tree=1. Excluding family tree links, CT's algorithmic recall drops to 28.6% (2,046,726 links). Presenting CT recall alongside MLP recall without splitting on ct_family_tree creates a wildly misleading comparison.

**How to check**  
Run: con.execute('SELECT count(*) FILTER (WHERE l1.histid_2 = p.h2 AND l1.ft = 1) AS found_ft, count(*) FILTER (WHERE l1.histid_2 = p.h2 AND l1.ft = 0) AS found_no_ft FROM prof p LEFT JOIN lk l1 ON l1.histid_1 = p.h1').fetchone() on 1850_1860.

**Suggested fix**  
In the recall query, add 'count(*) FILTER (WHERE l1.histid_2 = p.h2 AND l1.ft = 1) AS found_ft' and split Table 1 and Table 4 for CT by ct_family_tree (or report recall among unflagged CT links), mirroring the precision split.

---

### 2. Census Tree 'unflagged' precision split still includes FamilySearch profile and direct hints

`ct-precision-split-ignores-profile-hints` · **MAJOR** · identification · confidence: **verified** (traced in source)

**Where:** `profile_links_vs_machine.py:207-217`

**What the code does**  
Defines unflagged links solely by ct_family_tree = 0 ('jn = (r.same - r.ft_same) + (r.diff - r.ft_diff)'), asserting that 'Links CT flags as taken from the FamilySearch tree are not an independent test' and treating the remainder as an independent test.

**Why it matters**  
In CT 1850_1860, 1,784,887 links with ct_family_tree = 0 (28.1% of unflagged links) have ct_profile_hint = 1, and 1,079,288 have ct_direct_hint = 1. These hints originate from FamilySearch user attachments. Presenting unflagged CT links as an independent benchmark against FamilySearch attachments is incorrect because over a quarter of unflagged links were guided by FamilySearch hints.

**How to check**  
Run: con.execute('SELECT count(*) FROM read_parquet(...) WHERE ct_family_tree = 0 AND (ct_profile_hint = 1 OR ct_direct_hint = 1)').fetchone() on any CT pair.

**Suggested fix**  
Incorporate ct_profile_hint and ct_direct_hint into the flagged filter, or provide a strictly algorithmic CT category (ct_family_tree=0 AND ct_profile_hint=0 AND ct_direct_hint=0).

---

### 3. Pooled summary table indiscriminately pools the 20-year span (1880-1900) into 10-year pairs

`pooled-table-conflates-20yr-span` · **MAJOR** · correctness · confidence: **verified** (traced in source)

**Where:** `profile_links_vs_machine.py:218-224`

**What the code does**  
Sums across all 8 pairs indiscriminately: 'tot = df.groupby(\"linkage\")[[\"profile_links\", \"found\", \"contradicted\", \"same\", \"diff\", \"machine_links\"]].sum()', pooling the 20-year span 1880-1900 with the seven adjacent 10-year pairs.

**Why it matters**  
Per SPEC ┬º2 and config.py:28,43-46, 1880-1900 is an approved 20-year span exception across the destroyed 1890 census with structurally higher mortality, lower recall, and much higher error rates (e.g. CT precision drops from 93-97% to 84.0%, with 2.7M diff links). Pooling it with 10-year pairs skews the aggregate recall and precision numbers that readers and referees will cite as headline decade-to-decade performance.

**How to check**  
Compare tot precision vs df[df.span == 10].groupby('linkage')[['same', 'diff']].sum().apply(lambda r: r['same'] / (r['same'] + r['diff']), axis=1).

**Suggested fix**  
In Table 4, report separate pooled rows for 'Pooled 10-year pairs (7 pairs)' and '1880-1900 (span 20)', or add a span==10 filter row before the grand total.

---

### 4. Precision formatting performs unguarded float division that will crash on zero judged links

`zero-division-unhandled-in-precision-table` · **minor** · correctness · confidence: **verified** (traced in source)

**Where:** `profile_links_vs_machine.py:204, profile_links_vs_machine.py:224`

**What the code does**  
Computes '{100*r.same/j:.2f}' and '{1000*r.diff/j:.1f}' in line 204, and '{100*r.same/(r.same+r[\"diff\"]):.2f}' in line 224 without checking if j > 0, unlike pct() which guards with 'if b else \"--\"'.

**Why it matters**  
If the script is executed on a test subset, sparse pair, or future census pair where no machine links have both ends attached to a profile (j == 0), the entire script crashes with ZeroDivisionError after running all heavy DuckDB queries.

**How to check**  
Run write_md() on a DataFrame row where same=0 and diff=0.

**Suggested fix**  
Change line 204 to use a guarded expression: f'{100*r.same/j:.2f}' if j else '--', and similarly in line 224.

---

### 5. Writing OUT_MD fails if REPO_ROOT/documents directory does not exist

`missing-parent-dir-creation-out-md` · **minor** · replication · confidence: **verified** (traced in source)

**Where:** `profile_links_vs_machine.py:58, profile_links_vs_machine.py:225`

**What the code does**  
Opens OUT_MD directly with 'with open(OUT_MD, \"w\", encoding=\"utf-8\") as f:' without ensuring that os.path.dirname(OUT_MD) exists. config.py creates INTER_ROOT, OUT_ROOT, and SCRATCH, but not REPO_ROOT/documents.

**Why it matters**  
On any environment or fresh clone where REPO_ROOT/documents has not been manually created in advance, the script crashes at the final step with FileNotFoundError.

**How to check**  
Run os.makedirs(os.path.dirname(OUT_MD), exist_ok=True) before open(OUT_MD, 'w').

**Suggested fix**  
Add 'os.makedirs(os.path.dirname(OUT_MD), exist_ok=True)' immediately before opening OUT_MD.

---

### 6. Pooled summary table omits unlinked profile links, obscuring the recall partition

`pooled-table-omits-unlinked-profile-share` · **nit** · correctness · confidence: **verified** (traced in source)

**Where:** `profile_links_vs_machine.py:218-224`

**What the code does**  
Table 1 reports found, contradicted, and both records unlinked (summing to 100%), but Table 4 reports only recall (%) and contradicted (%), omitting unlinked records.

**Why it matters**  
Readers examining the pooled table see recall (e.g. 69.5%) and contradicted (1.4%) which sum to 70.9%, without seeing that the remaining 29.1% represents records unlinked by the machine.

**How to check**  
Inspect Table 4 headers and columns in write_md().

**Suggested fix**  
Add 'missing_both' to the groupby sum and include 'unlinked (%)' in Table 4.

---

### 7. Stage-1 parser relies on rigid character slice line[3:5] for section detection

`stage1-parser-rigid-slice` · **nit** · replication · confidence: **verified** (traced in source)

**Where:** `profile_links_vs_machine.py:76-78`

**What the code does**  
Extracts section number via 'sec = line[3:5].strip(\". \")' from lines starting with '## '.

**Why it matters**  
While it currently parses diagnostics_stage1.md, any slight formatting variation (such as double spaces, section numbering beyond 9 with periods, or alternative Markdown styles) silently corrupts section tracking.

**How to check**  
Test parsing on '##  1. Four-way' or '## 10. Table'.

**Suggested fix**  
Use regex matching: m = re.match(r'^##\s+(\d+[a-z]?)\.?\s*', line); if m: sec = m.group(1).

---

## Checked and sound

- **One-to-one integrity of the FamilySearch backbone crosswalks** — Checked r[0] == r[1] == r[2] and r[3] == 0 in profile_links_vs_machine.py:96-100 across all years. Confirmed that each xwalk_clean_<y> parquet has identical unique counts of histid and unique_ID with zero nulls.
- **One-to-one integrity of machine linkage input pairs** — Checked n == n1 == n2 in profile_links_vs_machine.py:119-121. Confirmed on 1850_1860 that histid_1 and histid_2 are strictly unique in both MLP and CT partitions.
- **Exhaustive and mutually exclusive recall categorization** — Traced in profile_links_vs_machine.py:125-138 and verified on 1850_1860 data that found, contradicted, and missing_both partition prof exactly (summing to n_prof) with zero overlap.
- **Mathematical identity between found (recall) and 11same (precision)** — Traced relational identity in profile_links_vs_machine.py:155: prof is defined as x1 JOIN x2 on unique_ID, so (h1, h2) in prof found in lk is mathematically identical to (h1, h2) in lk resolving to the same profile in x1 and x2. Checked found == s.
- **Exact replication of Stage-1 diagnostic totals** — Verified in profile_links_vs_machine.py:157-158 that (n, s, d) computed from parquet exactly equals total_links, n_11same, and n_11diff from diagnostics_stage1.md for 1850_1860 (MLP: 7,966,485 / 4,963,450 / 152,622; CT: 10,911,035 / 6,296,183 / 441,466).
- **SQL NULL handling in precision four-way class partition** — Traced DuckDB SQL expressions in profile_links_vs_machine.py:143-146; confirmed that s, d, one, and none properly handle SQL ternary logic and mutually partition n without missing-value leakage.

## What this review could not establish

- No paper draft was supplied; claims-vs-code evaluated docstrings, comments, and markdown table text only, not paper text.
- Full multi-pair end-to-end pipeline was verified via targeted DuckDB queries on available 1850_1860 intermediate parquet partitions rather than running the full multi-hour pipeline across all 8 pairs.
