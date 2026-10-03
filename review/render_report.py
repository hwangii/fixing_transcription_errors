#!/usr/bin/env python3
"""Render a Codex verdict JSON into a readable markdown report.

Usage: python render_report.py <verdict.json> <out.md>

The markdown carries a Disposition column that is deliberately blank. Claude (or
you) fills it in with Fixed / Rebutted / Accepted risk. A finding with no
disposition is the one that reaches the referee.
"""
import json
import sys
from datetime import datetime

SEV_ORDER = {"blocker": 0, "major": 1, "minor": 2, "nit": 3}
SEV_MARK = {"blocker": "BLOCKER", "major": "MAJOR", "minor": "minor", "nit": "nit"}
CONF_NOTE = {
    "verified": "traced in source",
    "likely": "implied, depends on unseen data",
    "speculative": "a question, not an established defect",
}


def main():
    if len(sys.argv) != 3:
        print(__doc__, file=sys.stderr)
        return 2

    src, dst = sys.argv[1], sys.argv[2]
    with open(src, "r", encoding="utf-8") as fh:
        raw = fh.read()

    # Codex may wrap the JSON in a fenced block; tolerate it.
    text = raw.strip()
    if text.startswith("```"):
        lines = [l for l in text.splitlines() if not l.strip().startswith("```")]
        text = "\n".join(lines)

    try:
        v = json.loads(text)
    except json.JSONDecodeError as exc:
        print(f"Could not parse verdict JSON: {exc}", file=sys.stderr)
        return 1

    findings = v.get("findings", []) or []
    findings.sort(key=lambda f: SEV_ORDER.get(f.get("severity", "nit"), 9))

    counts = {}
    for f in findings:
        s = f.get("severity", "nit")
        counts[s] = counts.get(s, 0) + 1
    tally = ", ".join(
        f"{counts[s]} {s}" for s in ["blocker", "major", "minor", "nit"] if s in counts
    )
    if not tally:
        tally = "no findings"

    o = []
    o.append("# Codex review")
    o.append("")
    o.append(f"*Rendered {datetime.now():%Y-%m-%d %H:%M}. Source: `{src}`*")
    o.append("")
    o.append(f"**Dimensions:** {', '.join(v.get('dimensions_reviewed', []) or ['(none reported)'])}")
    o.append("")
    o.append(f"**Result:** {tally}")
    o.append("")
    o.append("## Summary")
    o.append("")
    o.append(v.get("summary", "_(none)_"))
    o.append("")

    # Triage table ------------------------------------------------------------
    if findings:
        o.append("## Triage")
        o.append("")
        o.append("| # | Sev | Conf | Finding | Location | Disposition |")
        o.append("|---|-----|------|---------|----------|-------------|")
        for i, f in enumerate(findings, 1):
            title = (f.get("title", "") or "").replace("|", r"\|")
            loc = (f.get("location", "") or "").replace("|", r"\|")
            o.append(
                f"| {i} | {SEV_MARK.get(f.get('severity','nit'), '?')} "
                f"| {f.get('confidence','?')} | {title} | `{loc}` | |"
            )
        o.append("")
        o.append("> Fill the Disposition column: **Fixed** (with commit) / "
                 "**Rebutted** (with reason) / **Accepted risk** (with why).")
        o.append("")

        o.append("## Findings")
        o.append("")
        for i, f in enumerate(findings, 1):
            sev = f.get("severity", "nit")
            conf = f.get("confidence", "?")
            o.append(f"### {i}. {f.get('title','(untitled)')}")
            o.append("")
            o.append(
                f"`{f.get('id','no-id')}` · **{SEV_MARK.get(sev, sev)}** · "
                f"{f.get('dimension','?')} · confidence: **{conf}** "
                f"({CONF_NOTE.get(conf,'')})"
            )
            o.append("")
            o.append(f"**Where:** `{f.get('location','(none)')}`")
            o.append("")
            o.append(f"**What the code does**  \n{f.get('what_the_code_does','')}")
            o.append("")
            o.append(f"**Why it matters**  \n{f.get('why_it_matters','')}")
            o.append("")
            o.append(f"**How to check**  \n{f.get('how_to_check','')}")
            o.append("")
            o.append(f"**Suggested fix**  \n{f.get('suggested_fix','')}")
            o.append("")
            o.append("---")
            o.append("")
    else:
        o.append("## Findings")
        o.append("")
        o.append("None reported. Read the section below before trusting that.")
        o.append("")

    clean = v.get("verified_clean", []) or []
    o.append("## Checked and sound")
    o.append("")
    if clean:
        for c in clean:
            o.append(f"- **{c.get('item','')}** — {c.get('evidence','')}")
    else:
        o.append("_Nothing listed. A review reporting few findings without saying "
                 "what it checked is weak evidence of correctness._")
    o.append("")

    limits = v.get("review_limits", []) or []
    o.append("## What this review could not establish")
    o.append("")
    if limits:
        for l in limits:
            o.append(f"- {l}")
    else:
        o.append("_None stated — treat that itself as suspect: Codex cannot run "
                 "Stata or read the gitignored data._")
    o.append("")

    with open(dst, "w", encoding="utf-8") as fh:
        fh.write("\n".join(o))

    print(f"Rendered {len(findings)} finding(s) -> {dst}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
