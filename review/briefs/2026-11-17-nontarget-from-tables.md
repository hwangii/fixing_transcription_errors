# Review brief: non-target linkage numbers from the slide tables (2026-11-17)

The author wants linked-sample quality for non-target records (Ancestry and FamilySearch agree), to check that replacing names on all records, not just targets, did not hurt. MATCHING/nontarget_from_tables.py derives non-target = All - Target from the machine-B tables in the paper repo (D:\repos\6638fa0fd89fbec05130caeb\figures\deaglan_abe_jw{,_restricted}.tex, deaglan_hlink{,_restricted}.tex; _restricted = target). Ignore MATCHING/profile_names_jw.do (reviewed already, 2026-11-17_021352) and MATCHING/_run__*.do (temporary Run-Stata wrapper).

Output (already run once; it only reads the two tex files): non-target ABE exact match 28.30 -> 26.64%, verified 5.41M -> 5.10M, contradicted 254k -> 219k; JW and HLINK similar direction.

CHECK: (1) column mapping (abe_jw tables print Jaro-Winkler Old/New then ABE Old/New); (2) All - Target is valid for each quantity (are the target table's records a subset of the all table's, same denominators 51,036,859 / 14,416,543, same link definitions?); (3) recall approximation and its stated error; (4) parsing robustness; (5) whether any conclusion drawn (New worse than Old on non-target records) is overstated.
