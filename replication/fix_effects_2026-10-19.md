# What the 2026-10-19 fixes to Deaglan's tables change

**Status: awaiting the author's sign-off.** The fixes are committed in
`LINKAGE/` and their reruns are done on machine B. Nothing in the paper repo
has changed: `figures/deaglan_*.tex`, `deaglan_results/current/` and the
draft are exactly as they were on 2026-10-19. The regenerated (fixed) tables
are in `F:\Deaglan\Census_Transcriptions\output\tables\`; until the paper
repo is updated, `Run-MachineB.ps1` will report them as DIFFERS. That is
expected, not a failure.

Each fix was rerun on its own so its effect is separable. "Before" is the
committed table; for fix 4 on HLINK, "before" is the table after fix 3.

## The fixes

| # | Commit | Fix | Tables it can move | Effect |
|---|---|---|---|---|
| 1 | `b257fa8` | runner compares all five tables by raw-byte SHA-256 | none | tooling only |
| 2 | `586606c` | `keep if age >= 8 & !missing(age)` | ABE/JW, HLINK | **none**: 0 missing ages in either input (denominators unchanged) |
| 3 | `fc410f7` | HLINK numerator restricted to the denominator population | HLINK | match rates -0.02 to -0.03 pp; small Panel B shifts |
| 4 | `1dad353` | "Directly Contradicted" made two-sided | ABE/JW, HLINK | **large**: Contradicted +60-70%, taken out of Unverifiable |
| 5 | `fb938da` | mortality numerator restricted to its denominator | mortality (not in draft) | linkage rates -0.3 to -0.5 pp |

Unchanged by every fix: denominators, Verified Correct, Recall, MI match
rates; and ABE/JW match rates.

## Fix 3: HLINK numerator (Tables 7-8)

| | Old | New |
|---|---|---|
| Match rate, full | 58.08 -> **58.06** | 59.55 -> **59.52** |
| Match rate, discordant | 49.70 -> **49.68** | 56.55 -> **56.53** |
| Unverifiable, full | 38,157,420 -> 38,131,655 | 39,338,039 -> 39,311,295 |
| Unverifiable, discordant | 9,102,506 -> 9,096,129 | 10,518,426 -> 10,510,888 |

Panel B moves by a few hundred per cell (e.g. added Verified 1,134,851 ->
1,135,269): removing an old link whose 1940 person is outside the
denominator turns that 1930 person's new link from "changed" into "added".
Exactly the effect the Codex review predicted on 2026-10-02.

## Fix 4: two-sided "Directly Contradicted" (Tables 5-8)

A link is now Contradicted if it is not a true pair and **either** of its
people is truly linked to someone else; Unverifiable only if **neither**
person is in the truth set. Before, only the 1940 side was checked.

Directly Contradicted, Panel A:

| Table | JW old | JW new | ABE old | ABE new |
|---|---|---|---|---|
| ABE/JW full | 190,805 -> **308,848** | 171,174 -> **275,442** | 210,054 -> **344,018** | 194,387 -> **313,846** |
| ABE/JW discordant | 57,802 -> **90,891** | 44,926 -> **74,389** | 40,919 -> **65,148** | 43,715 -> **71,863** |

| Table | HLINK old | HLINK new |
|---|---|---|
| HLINK full | 293,078 -> **501,010** | 296,657 -> **503,357** |
| HLINK discordant | 67,636 -> **116,233** | 70,375 -> **125,607** |

Panel B, share of **added** links that are contradicted: JW 2.2 -> 3.8%,
ABE 2.0 -> 3.4%; discordant JW 1.7 -> 2.8%, ABE 1.5 -> 2.5%; HLINK 1.6 ->
2.4%, discordant 1.1 -> 1.9%. Share of **removed** links that were
contradicted: JW 5.3 -> 9.0%, ABE 4.4 -> 7.8%; HLINK 2.4 -> 3.7%.

**The paper's direction survives.** The share of links contradicted still
falls from the old to the new transcription in all six columns (e.g. full JW
2.44 -> 2.04%, discordant ABE 5.07 -> 2.56%, HLINK 0.75 -> 0.74%), and the
new transcription still removes proportionally more contradicted links than
it adds.

## Fix 5: mortality (not in the draft)

1.6-1.7% of matched links had a BUNMD record outside the denominator (BUNMD
men born by 1940) and are now dropped. Exact-match linkage rate 27.55 ->
27.09 (old names), 29.52 -> 29.01 (new names); conservative 20.52 -> 20.22,
22.13 -> 21.79. Gain from new names +7.15% -> +7.08% (exact).

## What the draft would need (claim check on a scratch copy with the fixed tables)

| Draft line | Now says | Would say | Kind |
|---|---|---|---|
| 107 | 3.19, 1.56, 0.44, 0.43 | 5.07, 2.56, 0.75, 0.74 | numbers (contradicted shares) |
| 565 | 56.6 | 56.5 | HLINK discordant new rate (56.53) |
| 572 | "unverifiable when the person does not appear there at all" | neither person appears | definition |
| 575 | 190,805; 171,174; 293,078; 296,657; 40,919; 43,715 | 308,848; 275,442; 501,010; 503,357; 65,148; 71,863 | numbers (contradicted counts) |
| 577 | 1.51->1.27, 1.68->1.44, 2.59->1.36, 3.19->1.56, 0.44->0.43, 0.44->0.41 | 2.44->2.04, 2.75->2.33, 4.07->2.25, 5.07->2.56, 0.75->0.74, 0.76->0.72 | numbers; qualitative claim still holds |
| 582 | caveat that Contradicted is 1940-side only, a lower bound | caveat no longer applies; Contradicted is still a lower bound only where neither person is in the truth set | wording |
| 629 | "changes the match rates from 58.08 and 59.55 to 58.06 and 59.52" | the table now *is* 58.06 / 59.52; sentence to drop or rewrite | wording |

The five errors already listed in HANDOFF (lines 101, 577's 0.41, 719, 726,
756) are independent of these fixes.

## One correction found along the way

PROVENANCE.md Q4 (and HANDOFF item 6) say "Match Rate" is pairs / persons
because "the link file is not one-to-one". **That is wrong.** All six link
files behind Tables 5-8 are strictly one-to-one on both the 1930 and the
1940 ID (checked 2026-10-19: HLINK 66,807,539 / 68,498,407 pairs; JW
13,478,232 / 12,670,605; ABE 18,198,099 / 16,946,362). So the match rate is
the share of people linked.
