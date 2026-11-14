# Rhode Island: does the current code reproduce the August 2026-08-28 results?

Run 2026-11-13 on machine A by `replication/diagnostics/ri_replication.do` (rc 0, 2 min), on the analysis file `temp.dta` written by `CODE/create_figures_SSHA2025.do` in the 2026-11-01 full run. Reviewed before running by Codex and Antigravity (`review/reports/2026-11-13_164947-working-*`): one shared minor finding, rebutted there.

| Rhode Island | Aug N | Aug before → after | Now N | Now before → after |
|---|---|---|---|---|
| Linkage rate, target | 84,538 | 0.084 → 0.208 (+147%) | 84,226 | 0.085 → 0.220 (+159%) |
| Linkage rate, all | 299,880 | 0.270 → 0.302 (+12%) | 281,760 | 0.273 → 0.297 (+9%) |
| Share validated, target | 2,078 → 4,835 | 0.608 → 0.839 (+38%) | 2,083 → 5,260 | 0.609 → 0.827 (+36%) |
| Share validated, all | 21,663 → 24,265 | 0.857 → 0.876 (+2%) | 20,454 → 22,483 | 0.858 → 0.865 (+1%) |

Target share of the RI sample now: 29.9%. The August text quoted 29.9% (from the balance table), while its own table implied 28.2% (84,538 / 299,880).

**Judgement (by hand): close.**
- The "before" side matches to within 0.001 on every rate, and the target N within 0.4%, so the sample construction and the baseline (Ancestry) links reproduce.
- The "after" side drifts by about one percentage point in either direction. The RI-era link files (no `0` suffix) no longer exist; the current pair was rebuilt 2026-02-15 over all states. The split of the drift between new model output and relinking cannot be identified from these files.
- The 18,120 extra records in August's "all" fit the one known sample-rule change: the old script (`CODE/create_figures.do:32-33`) counted records without a FamilySearch transcription as congruent, while the current sample requires both transcriptions with all four names. The target group, which those records could not enter, barely moved.
