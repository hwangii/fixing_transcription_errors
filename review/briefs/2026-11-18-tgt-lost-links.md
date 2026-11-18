# Review brief: where did the lost non-target links go (2026-11-18)

Results (MATCHING/results/tgt_linkage_abe.md, from score_tgt_links.do, commit 367cbd6): on 1940 non-target records, target-only ABE links (model names on target records only) number 10,238,786 vs Old (Ancestry everywhere) 10,363,116. The author wants to know where the lost links went: did the 1930 person link to a corrected target record instead, or was the link dropped (e.g. ABE uniqueness tie)?

NEW MATCHING/tgt_lost_links.do (read-only; writes MATCHING/results/tgt_lost_links.md): classifies each lost Old non-target pair by what target-only did with its 1930 person (to target / other non-target / outside sample / unlinked), with truth class of old and new link, and whether the old 1940 partner was relinked; and gained pairs by the 1930 person's Old partner. Same links, sample and truth definitions as MATCHING/score_tgt_links.do; asserts its counts.

CHECK: (1) classification and merges correct (1:1 / m:1, keep(), keepusing on key var); (2) V/U/C identical to score_tgt_links.do; (3) the isid histid1930 / histid1940 asserts on deduplicated fiveyr_band==1 pairs: could ABE output legitimately violate them (a run killer after ~1h)? (4) anything else. Ignore MATCHING/_run__*.do and review/revision-notes-2026-11-13.md.
