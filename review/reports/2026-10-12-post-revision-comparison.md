# Cross-reviewer comparison

| | codex | agy (gemini-3.8-flash-high) |
|---|---|---|
| findings | 4 | 8 |
| dimensions | claims-vs-code | claims-vs-code |
| verified clean | 7 | 6 |

**Same issue found by both: 4. Only codex: 0. Only agy (gemini-3.8-flash-high): 4.**

## Found by both

| # | codex | agy (gemini-3.8-flash-high) | severity | confidence |
|---|---|---|---|---|
| 1 | Key table generators include Hawaii despite the paper saying Hawaii is excluded throughout | Data cleaning scripts include Hawaii despite paper stating that Hawaii is excluded throughout and all tables cover 49 jurisdictions | major / major | likely / likely |
| 2 | The four reported model-performance percentages cannot be traced to executable repository code | The four reported model-performance percentages cannot be traced to executable repository code | major / major | verified / verified |
| 3 | National low-legibility claims are unsupported by the repository’s only quartile calculation, which is commented-out Rhode Island code | National low-legibility quartile statistics in text are not calculated in all-state code and exist only in commented-out Rhode Island code | minor / minor | verified / verified |
| 4 | Table 2 displays the full population count in its difference column rather than the compared sample size | Table 2 displays the full population count in its difference column rather than the compared sample size | minor / minor | verified / verified |

Bold severity = the two reviewers disagree on how much it matters.

## Only codex

_none_

## Only agy (gemini-3.8-flash-high)

- **blocker / verified** — Claim that directly contradicted links fall across the board is refuted by HLINK and by discordant-sample ABE  
  `D:/repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:104-106, D:/repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:559-561, D:/repos/6638fa0fd89fbec05130caeb/figures/deaglan_abe_jw.tex:17, D:/repos/6638fa0fd89fbec05130caeb/figures/deaglan_abe_jw_restricted.tex:17, D:/repos/6638fa0fd89fbec05130caeb/figures/deaglan_hlink.tex:17, D:/repos/6638fa0fd89fbec05130caeb/figures/deaglan_hlink_restricted.tex:17`
- **major / verified** — Table 2's identical 28.3% disagreement rate between US population and analysis sample is a Stata missing-value artifact, not an empirical finding  
  `CODE/munir_figures_for_nber.do:257, CODE/munir_figures_for_nber.do:326, CODE/munir_figures_for_nber.do:340, D:/repos/6638fa0fd89fbec05130caeb/figures/balance_allstates.tex:5, D:/repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:433-435`
- **major / verified** — Text and note for Figure 4 describe an obsolete layout and nonexistent 45-degree line instead of the actual combined plot  
  `D:/repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:671-686, CODE/create_figures_SSHA2025.do:354-361`
- **minor / verified** — Extrapolation of GPU-hours to full census is mathematically inconsistent with reported Rhode Island baseline  
  `D:/repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:368-371`

## Direct contradictions

_none detected_
