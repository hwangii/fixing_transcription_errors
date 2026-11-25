# ABE exact on the v26 inputs, 1930-1940 men

Written by MATCHING/score_v26_links.do (definitions of LINKAGE/code/01_abe_jw/linkage_analysis.do; the paper's Old and New columns are checked against the main table).

Columns: **Old (paper)** and **New (paper)** = the paper's files, on names whose stored cleaning carried the pre-0.25 abeclean 'marshall' defect, from the men-only extracts. **Old (v26)**, **New (v26)**, **Target-only (v26)** = rebuilt from the 00655/00656 raw names with abeclean 0.26 (1f_v26_inputs.do), the same men and names as the MLP input; New (v26) has model names on every 1940 record with a per-field Ancestry fallback where the model field is empty, Target-only (v26) the same on target records only and Ancestry's elsewhere; 'InvalidPred' is blanked before the fallback. Same sample, denominators and truth as the paper.

Share validated uses each version's own 1930 and 1940 middle initials; the Ancestry-MI rows use the paper's Ancestry initials for every column. Verified/contradicted are against the FamilySearch-profile sample and cover only links it reaches.


## All records (N =   51,036,859)

| | Old (paper) | New (paper) | Old (v26) | New (v26) | Target-only (v26) |
|---|---:|---:|---:|---:|---:|
| Links | 11,643,699 | 12,555,546 | 11,796,897 | 12,762,851 | 13,228,715 |
| Match rate (%) | 22.81 | 24.60 | 23.11 | 25.01 | 25.92 |
| Share validated, MI (%) | 85.99 | 87.14 | 86.08 | 87.14 | 87.94 |
| Links with both initials | 2,512,418 | 2,665,324 | 2,549,402 | 2,779,135 | 2,866,289 |
| Share validated, Ancestry 1940 MI (%) | 85.99 | 86.01 | 86.08 | 86.08 | 86.27 |
| Links with both initials, Ancestry 1940 MI | 2,512,418 | 2,712,856 | 2,548,872 | 2,761,626 | 2,846,972 |
| Verified correct | 5,930,641 | 6,415,946 | 6,011,605 | 6,523,796 | 6,803,019 |
| Unverifiable | 5,394,195 | 5,848,625 | 5,473,536 | 5,955,789 | 6,145,918 |
| Directly contradicted | 318,863 | 290,975 | 311,756 | 283,266 | 279,778 |
| Contradicted / (verified + contradicted) (%) | 5.10 | 4.34 | 4.93 | 4.16 | 3.95 |
| Recall (%) | 31.69 | 34.28 | 32.12 | 34.86 | 36.35 |

## Target records (N =   14,416,543)

| | Old (paper) | New (paper) | Old (v26) | New (v26) | Target-only (v26) |
|---|---:|---:|---:|---:|---:|
| Links | 1,280,583 | 2,798,958 | 1,298,148 | 2,858,452 | 2,855,187 |
| Match rate (%) | 8.88 | 19.41 | 9.00 | 19.83 | 19.80 |
| Share validated, MI (%) | 65.41 | 83.60 | 65.41 | 83.32 | 83.34 |
| Links with both initials | 308,513 | 618,732 | 313,463 | 653,853 | 653,473 |
| Share validated, Ancestry 1940 MI (%) | 65.41 | 75.67 | 65.41 | 75.70 | 75.72 |
| Links with both initials, Ancestry 1940 MI | 308,513 | 620,414 | 313,383 | 634,984 | 634,601 |
| Verified correct | 523,091 | 1,319,555 | 530,698 | 1,346,754 | 1,346,534 |
| Unverifiable | 692,355 | 1,407,741 | 703,125 | 1,441,469 | 1,439,992 |
| Directly contradicted | 65,137 | 71,662 | 64,325 | 70,229 | 68,661 |
| Contradicted / (verified + contradicted) (%) | 11.07 | 5.15 | 10.81 | 4.96 | 4.85 |
| Recall (%) | 11.13 | 28.07 | 11.29 | 28.65 | 28.64 |

## Non-target records (N =   36,620,316)

| | Old (paper) | New (paper) | Old (v26) | New (v26) | Target-only (v26) |
|---|---:|---:|---:|---:|---:|
| Links | 10,363,116 | 9,756,588 | 10,498,749 | 9,904,399 | 10,373,528 |
| Match rate (%) | 28.30 | 26.64 | 28.67 | 27.05 | 28.33 |
| Share validated, MI (%) | 88.87 | 88.21 | 88.98 | 88.32 | 89.30 |
| Links with both initials | 2,203,905 | 2,046,592 | 2,235,939 | 2,125,282 | 2,212,816 |
| Share validated, Ancestry 1940 MI (%) | 88.87 | 89.07 | 88.98 | 89.18 | 89.30 |
| Links with both initials, Ancestry 1940 MI | 2,203,905 | 2,092,442 | 2,235,489 | 2,126,642 | 2,212,371 |
| Verified correct | 5,407,550 | 5,096,391 | 5,480,907 | 5,177,042 | 5,456,485 |
| Unverifiable | 4,701,840 | 4,440,884 | 4,770,411 | 4,514,320 | 4,705,926 |
| Directly contradicted | 253,726 | 219,313 | 247,431 | 213,037 | 211,117 |
| Contradicted / (verified + contradicted) (%) | 4.48 | 4.13 | 4.32 | 3.95 | 3.72 |
| Recall (%) | 38.59 | 36.37 | 39.11 | 36.94 | 38.93 |
