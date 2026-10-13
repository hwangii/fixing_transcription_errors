# Cross-reviewer comparison

| | codex | agy (gemini-3.8-flash-high) |
|---|---|---|
| findings | 5 | 7 |
| dimensions | claims-vs-code | claims-vs-code |
| verified clean | 5 | 6 |

**Same issue found by both: 4. Only codex: 1. Only agy (gemini-3.8-flash-high): 3.**

## Found by both

| # | codex | agy (gemini-3.8-flash-high) | severity | confidence |
|---|---|---|---|---|
| 1 | The headline table silently uses smaller denominators than the analysis sample described in the text | The headline linkage table silently uses smaller record counts than the analysis sample defined in the text | major / major | verified / verified |
| 2 | The paper claims profile-name validation results although that analysis remains an unfilled placeholder | Independent genealogical profile validation is claimed as an empirical result in the Abstract and Introduction but is unimplemented in code and marked forthcoming in text | major / major | verified / verified |
| 3 | Higher model agreement with FamilySearch is incorrectly interpreted as evidence that FamilySearch is more reliable | Model agreement with FamilySearch is interpreted as evidence of FamilySearch transcription reliability without ground truth | major / major | verified / verified |
| 4 | Test-set agreement with consensus commercial labels is reported as transcription accuracy | Test set sequence and token accuracy metrics evaluate consensus commercial agreement, not adjudicated ground truth | **major / minor** | verified / verified |

Bold severity = the two reviewers disagree on how much it matters.

## Only codex

- **major / verified** — The named headline-results generator excludes four jurisdictions while the paper claims all tables cover 49  
  `CODE/create_figures_SSHA2025.do:89-109, D:/repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:378-385, D:/repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:500-515`

## Only agy (gemini-3.8-flash-high)

- **minor / verified** — Table 2 observation count in the difference column displays total population instead of sample size  
  `D:/repos/6638fa0fd89fbec05130caeb/figures/incongruent_allstates.tex:25, D:/repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:450-464, CODE/munir_figures_for_nber.do:364-372`
- **minor / verified** — Socio-demographic heterogeneity figure description in text and caption describes obsolete layout and nonexistent 45-degree line  
  `D:/repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:653-656, D:/repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:667, CODE/create_figures_SSHA2025.do:354-361`
- **minor / verified** — Legibility quartile statistics in Section 4.3 are carried over from Rhode Island exploratory code rather than all-states analysis  
  `D:/repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:709-711, CODE/munir_figures_for_nber.do:566, CODE/munir_figures_for_nber.do:672-692`

## Direct contradictions

One reviewer passed what the other flagged. These need a human.

- agy (gemini-3.8-flash-high): _clean_ — Headline linkage table self-generates with 49-jurisdiction coverage  
  codex: **finding** — The named headline-results generator excludes four jurisdictions while the paper claims all tables cover 49
