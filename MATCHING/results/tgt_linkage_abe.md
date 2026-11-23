# Target-only ABE links, 1930-1940 men

Written by MATCHING/score_tgt_links.do (definitions of LINKAGE/code/01_abe_jw/linkage_analysis.do; ans and true checked against the main table).

Columns: **Old** = Ancestry names; **New (paper)** = model names on every record, the paper's file; **New (rerun)** = the same, rerun 2026-11-17 by the code that made Target-only; **Target-only** = model names on target records only; **Target-only, no sentinel** = the same with the model's literal 'InvalidPred' replaced by Ancestry's field (2026-11-22), with the middle initial the pipeline's fallback gives; that changes the own 1940 initial of       596 sample records from Target-only's. Own initials of fallback records: where the model gave no first name, New (paper), New (rerun) and the target records of both Target-only columns have an empty initial (1_divide re-cleans Ancestry's already-cleaned first name), so those records enter the Ancestry-MI rows but not the own-MI rows; the non-target records of both Target-only columns carry Ancestry's initial. The Ancestry-MI rows hold the yardstick fixed across columns. Comparing Target-only with New (rerun) isolates the target-only restriction (both with the sentinel); comparing Target-only, no sentinel with Target-only isolates the sentinel fix on target records. New (paper) and New (rerun) still carry the sentinel on every record.

Share validated uses each version's own 1940 middle initial (Old: Ancestry's; New: ours; Target-only: ours on target records, Ancestry's elsewhere), as the paper does; the Ancestry-MI row uses Ancestry's 1940 initial for every version. Verified/contradicted are against the FamilySearch-profile sample and cover only links it reaches (unverifiable excluded).

Rerun vs paper's file, all pairs (fiveyr_band==1): in both   13,487,436, paper's only            0, rerun only            0.

Rerun vs paper's file, pairs whose 1940 person is in the sample (fiveyr_band==1): in both   12,555,546, paper's only            0, rerun only            0.


## All records (N =   51,036,859)

| | Old | New (paper) | New (rerun) | Target-only | Target-only, no sentinel |
|---|---:|---:|---:|---:|---:|
| Links | 11,643,699 | 12,555,546 | 12,555,546 | 13,033,944 | 13,044,642 |
| Match rate (%) | 22.81 | 24.60 | 24.60 | 25.54 | 25.56 |
| Share validated, MI (%) | 85.99 | 87.14 | 87.14 | 87.96 | 87.96 |
| Links with both initials | 2,512,418 | 2,665,324 | 2,665,324 | 2,799,255 | 2,799,836 |
| Share validated, Ancestry 1940 MI (%) | 85.99 | 86.01 | 86.01 | 86.20 | 86.18 |
| Links with both initials, Ancestry 1940 MI | 2,512,418 | 2,712,856 | 2,712,856 | 2,800,910 | 2,803,439 |
| Verified correct | 5,930,641 | 6,415,946 | 6,415,946 | 6,702,286 | 6,707,216 |
| Unverifiable | 5,394,195 | 5,848,625 | 5,848,625 | 6,044,092 | 6,049,730 |
| Directly contradicted | 318,863 | 290,975 | 290,975 | 287,566 | 287,696 |
| Contradicted / (verified + contradicted) (%) | 5.10 | 4.34 | 4.34 | 4.11 | 4.11 |
| Recall (%) | 31.69 | 34.28 | 34.28 | 35.81 | 35.84 |

## Target records (N =   14,416,543)

| | Old | New (paper) | New (rerun) | Target-only | Target-only, no sentinel |
|---|---:|---:|---:|---:|---:|
| Links | 1,280,583 | 2,798,958 | 2,798,958 | 2,795,158 | 2,807,053 |
| Match rate (%) | 8.88 | 19.41 | 19.41 | 19.39 | 19.47 |
| Share validated, MI (%) | 65.41 | 83.60 | 83.60 | 83.62 | 83.62 |
| Links with both initials | 308,513 | 618,732 | 618,732 | 618,327 | 619,158 |
| Share validated, Ancestry 1940 MI (%) | 65.41 | 75.67 | 75.67 | 75.69 | 75.66 |
| Links with both initials, Ancestry 1940 MI | 308,513 | 620,414 | 620,414 | 619,982 | 622,761 |
| Verified correct | 523,091 | 1,319,555 | 1,319,555 | 1,319,218 | 1,324,461 |
| Unverifiable | 692,355 | 1,407,741 | 1,407,741 | 1,405,954 | 1,412,232 |
| Directly contradicted | 65,137 | 71,662 | 71,662 | 69,986 | 70,360 |
| Contradicted / (verified + contradicted) (%) | 11.07 | 5.15 | 5.15 | 5.04 | 5.04 |
| Recall (%) | 11.13 | 28.07 | 28.07 | 28.06 | 28.17 |

## Non-target records (N =   36,620,316)

| | Old | New (paper) | New (rerun) | Target-only | Target-only, no sentinel |
|---|---:|---:|---:|---:|---:|
| Links | 10,363,116 | 9,756,588 | 9,756,588 | 10,238,786 | 10,237,589 |
| Match rate (%) | 28.30 | 26.64 | 26.64 | 27.96 | 27.96 |
| Share validated, MI (%) | 88.87 | 88.21 | 88.21 | 89.19 | 89.19 |
| Links with both initials | 2,203,905 | 2,046,592 | 2,046,592 | 2,180,928 | 2,180,678 |
| Share validated, Ancestry 1940 MI (%) | 88.87 | 89.07 | 89.07 | 89.19 | 89.19 |
| Links with both initials, Ancestry 1940 MI | 2,203,905 | 2,092,442 | 2,092,442 | 2,180,928 | 2,180,678 |
| Verified correct | 5,407,550 | 5,096,391 | 5,096,391 | 5,383,068 | 5,382,755 |
| Unverifiable | 4,701,840 | 4,440,884 | 4,440,884 | 4,638,138 | 4,637,498 |
| Directly contradicted | 253,726 | 219,313 | 219,313 | 217,580 | 217,336 |
| Contradicted / (verified + contradicted) (%) | 4.48 | 4.13 | 4.13 | 3.88 | 3.88 |
| Recall (%) | 38.59 | 36.37 | 36.37 | 38.41 | 38.41 |
