"""Say whether each regenerated figure in the paper repo reproduced.

A tracked PDF that git reports as modified is not necessarily a figure that
failed to reproduce. Stata 15 writes no timestamp into its PDFs, but the font
program it embeds can differ between sessions (found 2026-10-15: Figure 3
regenerated with an identical drawing and different embedded font bytes). So
for each modified PDF this compares the page content streams -- the drawing:
every point, line, label and coordinate -- separately from everything else.

    python replication/compare_figures.py [--paper-repo D:/repos/6638fa0fd89fbec05130caeb]

Prints one line per modified PDF:
    SAME DRAWING  page content identical; only fonts or other resources differ
    DIFFERS       the drawing changed -- the figure did not reproduce
Exit status is 1 if any figure DIFFERS. Standard library only.
"""

import argparse
import re
import subprocess
import sys
import zlib
from pathlib import Path

DEFAULT_PAPER = Path("D:/repos/6638fa0fd89fbec05130caeb")


def objects(pdf):
    """Map object number -> (dictionary bytes, decompressed stream or None)."""
    out = {}
    for m in re.finditer(rb"(\d+) 0 obj(.*?)endobj", pdf, re.S):
        body = m.group(2)
        s = re.search(rb"stream\r?\n(.*?)\r?\nendstream", body, re.S)
        data = None
        if s:
            try:
                data = zlib.decompress(s.group(1))
            except zlib.error:
                data = s.group(1)
        out[int(m.group(1))] = (body[: s.start()] if s else body, data)
    return out


def page_contents(pdf):
    """The decompressed content streams of every page, in page order."""
    objs = objects(pdf)
    streams = []
    for num, (head, _) in sorted(objs.items()):
        if re.search(rb"/Type\s*/Page\b", head):
            for ref in re.findall(rb"/Contents\s*\[?\s*((?:\d+ 0 R\s*)+)", head):
                for n in re.findall(rb"(\d+) 0 R", ref):
                    streams.append(objs.get(int(n), (b"", b""))[1])
    return streams


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--paper-repo", type=Path, default=DEFAULT_PAPER)
    args = ap.parse_args()
    repo = args.paper_repo

    changed = subprocess.run(
        ["git", "-C", str(repo), "diff", "--name-only", "--", "figures/*.pdf"],
        capture_output=True, text=True, check=True).stdout.split()
    if not changed:
        print("figures: no tracked PDF changed")
        return 0

    bad = 0
    for f in changed:
        old = subprocess.run(["git", "-C", str(repo), "show", f"HEAD:{f}"],
                             capture_output=True, check=True).stdout
        new = (repo / f).read_bytes()
        po, pn = page_contents(old), page_contents(new)
        if po and po == pn:
            print(f"SAME DRAWING  {f}  (page content identical; fonts/resources differ)")
        else:
            print(f"DIFFERS       {f}")
            bad += 1
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
