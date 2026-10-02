# Review instructions — Deaglan's linkage replication package

You are an independent reviewer. You did not write this code and you have no
stake in it being correct. Your value here is finding what is wrong. The same
instructions are given to a second reviewer from a different lab; the two
reports will be compared finding by finding, so precision and honest
confidence marking matter more than volume.

## Read these first, in this order

1. `F:\github_repos\fixing_transcription_errors\review\scopes\deaglan-census-transcriptions.md`
   — **this governs the review.** It names the package, the active dimensions,
   facts already verified, six specific questions, and what is out of scope.
2. `F:\github_repos\fixing_transcription_errors\review\PROTOCOL.md`
   — the severity and confidence vocabulary you must use.
3. The four checklists, one per dimension:
   - `F:\github_repos\fixing_transcription_errors\review\checklists\replication.md`
   - `F:\github_repos\fixing_transcription_errors\review\checklists\claims-vs-code.md`
   - `F:\github_repos\fixing_transcription_errors\review\checklists\correctness.md`
   - `F:\github_repos\fixing_transcription_errors\review\checklists\identification.md`
4. `F:\github_repos\fixing_transcription_errors\AGENTS.md` for domain background
   on the census-transcription project. Where it describes *that* project's own
   code (under `CODE/`), it does not apply here: you are reviewing a coauthor's
   separate package. The scope file wins on any conflict.

## Review target

The ENTIRE tree at **`F:\Deaglan\Census_Transcriptions\`**. It is outside the
repository you start in and is not a git repository: read files directly by
absolute path; there is no diff. Start with its `README.md`,
`DOCUMENTATION.md` and `LINKAGE_README.md`, then `code/` (65 files),
`output/tables/` (5 tables) and `output/logs/`.

Do **not** open anything under `data/`, `_archive/data/`, or `abe_jw/data/`
beyond confirming a file exists — these are multi-gigabyte datasets. Do not
review `code/01_abe_jw/reference/` or `vendor/` (third-party, vendored).

## Paper

The draft that will cite these tables is
`F:\github_repos\6638fa0fd89fbec05130caeb\DHTS-2024-11-18.tex`. Read it for the
`claims-vs-code` dimension: check captions, denominators, age and sex
restrictions, and sample definitions against what the package's scripts
compute. The draft currently references none of the package's tables; the
scope file records which claims are already known to conflict.

## Rules

- You are **read-only**. Do not create, edit, move or delete anything, anywhere.
- **Terminal use is restricted.** In headless mode only directory listing and
  text search commands are permitted (`dir`, `ls`, `type`, `cat`, `head`,
  `tail`, `wc`, `grep`, `rg`, `findstr`, `Get-ChildItem`, `Get-Content`,
  `Select-String`). Any other command — `git`, `stata`, `python`, `cd`,
  pipelines into anything else — is auto-denied and will not be re-asked.
  Prefer your built-in file-reading and search tools; if a command is denied,
  continue with those rather than stopping. Never end the run without the
  JSON verdict.
- Cite every finding as `path:line`. A finding without a location is not a finding.
- Mark `confidence` honestly: `verified` only for what you traced in source.
  You cannot run Stata, cannot open the data, and cannot regenerate HLINK links
  (nobody can) — say so in `review_limits` rather than inferring runtime
  behaviour as fact.
- Stata's silent semantics are central: missing values exceed any number,
  `"" == ""` is true, `merge` without `assert` hides mismatches, `_N` after a
  merge counts pairs not persons. Prioritise anything that yields a wrong
  number without an error.
- Answer the scope file's six numbered questions explicitly, each as either a
  finding or an entry in `verified_clean`, with `path:line`.
- Do not pad. Three real defects beat twenty stylistic notes. Populate
  `verified_clean` with what you checked and found sound — a short findings
  list is only credible beside evidence of what was examined.
- Rank by what would change a number or a claim in the paper, not by what
  would make the code prettier. The author is submitting within months.

## Output

Return ONLY a JSON object conforming to
`F:\github_repos\fixing_transcription_errors\review\schema\verdict.schema.json`
(it is also enforced by the launcher). `dimensions_reviewed` must list every
dimension you actually examined.
