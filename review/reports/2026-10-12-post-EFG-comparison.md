# Cross-reviewer comparison

| | codex | agy (gemini-3.8-flash-high) |
|---|---|---|
| findings | 4 | 5 |
| dimensions | claims-vs-code | claims-vs-code |
| verified clean | 7 | 9 |

**Same issue found by both: 4. Only codex: 0. Only agy (gemini-3.8-flash-high): 1.**

## Found by both

| # | codex | agy (gemini-3.8-flash-high) | severity | confidence |
|---|---|---|---|---|
| 1 | Validation of linked pairs is presented as proof of genuine transcription accuracy | Validation of linked pairs against genealogical links is presented as proof of transcription accuracy | major / major | verified / verified |
| 2 | The four out-of-sample model-performance percentages have no producing code in the repository | The four reported out-of-sample model performance percentages have no producing code in the repository | major / major | verified / verified |
| 3 | The national low-legibility statistics are not calculated by the active all-state analysis | National legibility quartile statistics and the 'up to 35 percent' linking gain claim have no producing code in the repository | major / major | verified / verified |
| 4 | The headline-results input imposes an undisclosed FamilySearch-age completeness restriction | Headline table input dataset imposes an undisclosed FamilySearch age completeness restriction | minor / minor | likely / likely |

Bold severity = the two reviewers disagree on how much it matters.

## Only codex

_none_

## Only agy (gemini-3.8-flash-high)

- **minor / verified** — Heterogeneity analysis describes the aggregated non-white racial category as Black residents  
  `D:/repos/6638fa0fd89fbec05130caeb/DHTS-2026-10-12.tex:703-704, CODE/create_figures_SSHA2025.do:271, CODE/label_socio_demo.do:14-15`

## Direct contradictions

_none detected_
