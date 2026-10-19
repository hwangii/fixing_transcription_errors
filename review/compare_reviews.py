#!/usr/bin/env python3
"""Compare two reviewers' verdicts of the same target, finding by finding.

Usage: python compare_reviews.py <a.json> <b.json> <out.md> [labelA] [labelB]

Two findings are treated as the same issue when they cite the same file and
their cited line ranges overlap or sit within a few lines, or when their titles
share most of their meaningful words. Everything else is reported as unique to
one reviewer. Agreement between models from different labs is evidence;
disagreement is a question for the author.
"""
import io
import json
import re
import sys
from collections import OrderedDict

SEV = {"blocker": 0, "major": 1, "minor": 2, "nit": 3}
STOP = set("the a an of in on to for and or is are as with by from that this it its be can "
           "not no vs than into at when which while rather both into are was were does".split())


def locs(s):
    """-> list of (basename, lo, hi) from a location string like 'a/b.do:12-20, c.do:5'."""
    out = []
    for part in re.split(r"[,;]\s*", s or ""):
        m = re.match(r"\s*(.*?)[:#]\s*(\d+)(?:\s*[-–]\s*(\d+))?\s*$", part)
        if m:
            base = m.group(1).replace("\\", "/").split("/")[-1].lower()
            lo = int(m.group(2)); hi = int(m.group(3) or lo)
            out.append((base, lo, hi))
        else:
            base = part.strip().replace("\\", "/").split("/")[-1].lower()
            if base:
                out.append((base, None, None))
    return out


def words(t):
    return {w for w in re.findall(r"[a-z0-9]+", (t or "").lower()) if w not in STOP and len(w) > 2}


def same_issue(f, g):
    """Same file AND overlapping lines is the primary test. Title similarity
    is only a fallback when at least one side cites no line numbers; on its
    own it over-pairs (two different HLINK findings share most title words)."""
    la, lb = locs(f.get("location")), locs(g.get("location"))
    both_numeric = any(lo is not None for _, lo, _ in la) and any(lo is not None for _, lo, _ in lb)

    def sim(x, y):
        wx, wy = words(x), words(y)
        return len(wx & wy) / min(len(wx), len(wy)) if wx and wy else 0.0

    body = lambda h: " ".join([h.get("title", ""), h.get("what_the_code_does", ""), h.get("why_it_matters", "")])

    overlap = False
    for a, lo, hi in la:
        for b, lo2, hi2 in lb:
            if a != b:
                continue
            if lo is None or lo2 is None:
                if not both_numeric:
                    return True
                continue
            if lo <= hi2 + 6 and lo2 <= hi + 6:
                overlap = True
    if both_numeric:
        # Same lines is necessary but not sufficient: two reviewers can cite
        # the same block for different defects. Require the prose to agree too.
        return overlap and (sim(f.get("title"), g.get("title")) >= 0.2 or sim(body(f), body(g)) >= 0.25)
    return sim(f.get("title"), g.get("title")) >= 0.6


def load(p):
    return json.load(io.open(p, encoding="utf-8"))


def main():
    if len(sys.argv) < 4:
        print(__doc__, file=sys.stderr); return 2
    A, B = load(sys.argv[1]), load(sys.argv[2])
    la = sys.argv[4] if len(sys.argv) > 4 else "A"
    lb = sys.argv[5] if len(sys.argv) > 5 else "B"
    fa, fb = A.get("findings", []), B.get("findings", [])

    pairs, used_b = [], set()
    for i, f in enumerate(fa):
        for j, g in enumerate(fb):
            if j in used_b:
                continue
            if same_issue(f, g):
                pairs.append((f, g)); used_b.add(j); break
    only_a = [f for f in fa if not any(f is p[0] for p in pairs)]
    only_b = [g for j, g in enumerate(fb) if j not in used_b]

    o = []
    o.append("# Cross-reviewer comparison")
    o.append("")
    o.append("| | %s | %s |" % (la, lb))
    o.append("|---|---|---|")
    o.append("| findings | %d | %d |" % (len(fa), len(fb)))
    o.append("| dimensions | %s | %s |" % (", ".join(A.get("dimensions_reviewed", [])), ", ".join(B.get("dimensions_reviewed", []))))
    o.append("| verified clean | %d | %d |" % (len(A.get("verified_clean", [])), len(B.get("verified_clean", []))))
    o.append("")
    o.append("**Same issue found by both: %d. Only %s: %d. Only %s: %d.**" % (len(pairs), la, len(only_a), lb, len(only_b)))
    o.append("")

    if pairs:
        o.append("## Found by both")
        o.append("")
        o.append("| # | %s | %s | severity | confidence |" % (la, lb))
        o.append("|---|---|---|---|---|")
        for n, (f, g) in enumerate(pairs, 1):
            sev = "%s / %s" % (f["severity"], g["severity"])
            if f["severity"] != g["severity"]:
                sev = "**" + sev + "**"
            conf = "%s / %s" % (f["confidence"], g["confidence"])
            o.append("| %d | %s | %s | %s | %s |" % (
                n, f["title"].replace("|", "/"), g["title"].replace("|", "/"), sev, conf))
        o.append("")
        o.append("Bold severity = the two reviewers disagree on how much it matters.")
        o.append("")

    for label, items in ((la, only_a), (lb, only_b)):
        o.append("## Only %s" % label)
        o.append("")
        if not items:
            o.append("_none_")
        for f in sorted(items, key=lambda x: SEV.get(x["severity"], 9)):
            o.append("- **%s / %s** — %s  \n  `%s`" % (f["severity"], f["confidence"], f["title"], f.get("location", "")))
        o.append("")

    # Things one reviewer called clean that the other flagged.
    conflicts = []
    for X, Y, lx, ly in ((A, B, la, lb), (B, A, lb, la)):
        for c in X.get("verified_clean", []):
            for g in Y.get("findings", []):
                if same_issue({"title": c.get("item"), "location": c.get("evidence")}, g):
                    conflicts.append((lx, c.get("item"), ly, g["title"]))
    o.append("## Direct contradictions")
    o.append("")
    if conflicts:
        o.append("One reviewer passed what the other flagged. These need a human.")
        o.append("")
        for lx, item, ly, title in conflicts:
            o.append("- %s: _clean_ — %s  \n  %s: **finding** — %s" % (lx, item, ly, title))
    else:
        o.append("_none detected_")
    o.append("")

    io.open(sys.argv[3], "w", encoding="utf-8").write("\n".join(o))
    print("both=%d only-%s=%d only-%s=%d contradictions=%d -> %s" % (
        len(pairs), la, len(only_a), lb, len(only_b), len(conflicts), sys.argv[3]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
