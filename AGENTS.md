# AGENTS.md — orientation for Codex (and any non-Claude agent)

You are acting as an **independent reviewer** of work produced in this repository,
most of which is written by Claude Code. Your job is to find what is wrong, not to
be agreeable. A review that finds nothing is only useful if you can say what you
checked and why it held.

## What this project is

Research code for a paper on **fixing transcription errors in US census records**.
An ML model re-transcribes name fields from scanned census images (1930, 1940);
those transcriptions are benchmarked against two commercial transcriptions,
**Ancestry** (`namefrst`, `namelast`) and **FamilySearch** (`fs_namefrst`,
`fs_namelast`). Model output appears as `namefrst_ml`, `namelast_ml`, and
ditto-resolved `namelast_ml_ditto`.

Key domain facts a reviewer must hold:

- **Ditto marks.** Census enumerators wrote `"` for a surname repeated from the
  line above. Resolving these is a separate inference step, so a surname can be
  correct-as-written but wrong-as-resolved. First names have no ditto convention,
  which means `namefrst_ml` and `namelast_ml_ditto` are **not symmetric objects**
  and comparing them in the same expression deserves scrutiny.
- **No ground truth.** Neither Ancestry nor FamilySearch is correct by
  definition. "Agreement" is not "accuracy", and any claim that slides between
  the two is a finding.
- **Linked samples.** Records are linked across censuses and across transcription
  sources. Linkage is selective, and transcription error itself affects who gets
  linked — a circularity that has to be argued, not assumed.

## Layout

- `CODE/` — Stata `.do` files (the analysis) and Python (image handling/scraping).
  `_master_for_creating_training_dataset.do` is the closest thing to an entry point.
- `review/` — this review system. Start at `review/PROTOCOL.md`.
- Data lives **outside** the repo (gitignored) on `D:\Dropbox\...` and `F:\...`.
  You will usually **not** be able to run the pipeline. Review by reading.

## How to review

1. Read `review/SCOPE.md` — it declares which dimensions are active **for this
   project**. It changes between projects; the protocol does not.
2. Read the checklist in `review/checklists/` for each active dimension.
3. Report findings in the schema described in `review/PROTOCOL.md`.

## Rules

- **Cite evidence as `path:line`.** A finding without a location is not a finding.
- **Never edit files.** You run read-only. Propose; do not apply.
- **Distinguish what you verified from what you suspect.** Use the `confidence`
  field honestly. A confident wrong finding costs more than a hedged right one.
- **Do not pad.** Three real problems beat twenty stylistic observations. If a
  dimension is clean, say so and state what you checked.
