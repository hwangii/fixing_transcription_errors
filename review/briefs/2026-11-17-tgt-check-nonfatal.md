# Review brief: make 1c's fallback check non-fatal (2026-11-17)

Author's decision: the 436 of 1,031,654 records where divided_file1940_true_cleaned's Ancestry fallback differs from divided_file1940_ans_cleaned are to be reconciled later; produce the target-only links now. MATCHING/1c_tgt_divided_files.do: the check now prints a NOTE and stops only if mismatches exceed 0.1% of checked records. Nothing else changed since commit 35afea9 (reviewed). Ignore MATCHING/_run__*.do.

CHECK: the edit is correct Stata and does what is described; any consequence for the target-only vs all-records comparison that should be stated.
