# Brief: fs_avg_performance.do, new mode `slidestgt` (2026-11-18)

Change: `MATCHING/fs_avg_performance.do` gains a mode `slidestgt` for the slides' "Adding FamilySearch names" table, now that the slides use our names on 1940 target records only.

- Adds two link versions to the columns: `mltgt` (link1930_1940_mltgt1940: our names on 1940 target records, Ancestry's elsewhere) and `fs30mltgt` (FamilySearch 1930 names x the same 1940 names). Keeps the existing columns, including `fs30ml`, so the header matches `combos`.
- Gate: in this mode `mltgt` must also reproduce create_figures_SSHA2025_tgt.tex (linkage rate, links with both initials, share validated, target and all), in addition to `ans`/`true` reproducing the paper.
- Writes MATCHING/results/fs_avg_performance_slides_tgt.tex; default and `slides` modes unchanged.
- Rejects an unknown mode.

Check: header columns vs combos order in each mode; fsv for fs30mltgt (fs_used1930 is carried by FS 1930 link files); gate values match the cited file; no other mode's behaviour changes.
