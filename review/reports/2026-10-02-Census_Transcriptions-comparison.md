# Cross-reviewer comparison

| | Antigravity | Codex |
|---|---|---|
| findings | 8 | 8 |
| dimensions | correctness, claims-vs-code, replication, identification | correctness, claims-vs-code, replication, identification |
| verified clean | 4 | 7 |

**Same issue found by both: 4. Only Antigravity: 4. Only Codex: 4.**

## Found by both

| # | Antigravity | Codex | severity | confidence |
|---|---|---|---|---|
| 1 | HLINK denominator includes women while caption claims men only | HLINK counts links outside its eligible denominator population | **major / blocker** | verified / verified |
| 2 | Mortality table uses BUNMD denominator, unlike other tables | Mortality link counts do not enforce the denominator’s sex and birth-year restrictions | major / major | verified / likely |
| 3 | Package relies on external or missing inputs for complete replication | Upstream reconstruction still needs missing inputs and obsolete working-tree paths | major / major | verified / verified |
| 4 | Run log does not support 'byte-identical' claim | Successful table generation is documented, but the claimed equality checks lack accessible audit evidence | minor / minor | verified / verified |

Bold severity = the two reviewers disagree on how much it matters.

## Only Antigravity

- **blocker / verified** — 1940-centric verification masks false positives as 'Unverifiable'  
  `code/02_hlink/linkage_analysis_newlinks.do:295, code/01_abe_jw/linkage_analysis.do:607`
- **major / verified** — Evaluating accuracy on a linked sample creates an upper bound  
  `code/01_abe_jw/linkage_analysis.do:300`
- **minor / verified** — Match rate can exceed 100% due to one-to-many pairs  
  `code/02_hlink/linkage_analysis_newlinks.do:93, 270`
- **minor / verified** — Missing ages retained as positive infinity in denominator  
  `code/02_hlink/linkage_analysis_newlinks.do:182`

## Only Codex

- **major / verified** — Captions and documentation describe different populations from those tabulated  
  `F:/Deaglan/Census_Transcriptions/code/01_abe_jw/linkage_analysis.do:36-54, F:/Deaglan/Census_Transcriptions/code/01_abe_jw/linkage_analysis.do:388-394, F:/Deaglan/Census_Transcriptions/code/02_hlink/linkage_analysis_newlinks.do:179-198, F:/Deaglan/Census_Transcriptions/code/02_hlink/linkage_analysis_newlinks.do:490-495, F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:226-232, F:/github_repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:366, F:/github_repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:408-445`
- **major / verified** — The package does not establish the provenance or independence of its truth benchmark  
  `F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:69-77, F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:142-149, F:/Deaglan/Census_Transcriptions/code/02_hlink/linkage_analysis_newlinks.do:294-313, F:/github_repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:70, F:/github_repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:104-105, F:/github_repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:541`
- **major / verified** — Higher aggregate initial agreement is presented as proof that added mortality links are more accurate  
  `F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:206-214, F:/Deaglan/Census_Transcriptions/code/03_mortality/05_make_linkage_table.do:49-75`
- **minor / verified** — Published ABE counts retain blank-name links excluded by the reconstructed pipeline  
  `F:/Deaglan/Census_Transcriptions/code/01_abe_jw/linkage_analysis.do:115-126, F:/Deaglan/Census_Transcriptions/code/01_abe_jw/linkage/diagnose_abe_shortfall_step3.do:43-72, F:/Deaglan/Census_Transcriptions/output/logs/diagnose_abe_shortfall_step3.log:276-283, F:/Deaglan/Census_Transcriptions/output/logs/diagnose_abe_shortfall_step3.log:307-314, F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:298-303`

## Direct contradictions

_none detected_
