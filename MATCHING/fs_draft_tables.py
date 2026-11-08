"""Draft exhibits for the FamilySearch-name comparison (2026-11-08).

Reformats, without recomputing, the two tables written by Stata:
  MATCHING/results/fs_avg_performance.tex  (MATCHING/fs_avg_performance.do)
  MATCHING/results/fs_cells.tex            (MATCHING/fs_cells.do)
into the three tabulars the draft \\input{}s:
  figures/fs_versions_allstates.tex     five link versions, target and all
  figures/fs_cells_sizes_allstates.tex  size of each model-agreement cell
  figures/fs_cells_allstates.tex        cell x link version
Every number is copied as a string from the Stata output; the script only
selects and rearranges rows, and stops if a row or panel it expects is missing.

usage: python MATCHING/fs_draft_tables.py <paper repo>
"""
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
RESULTS = REPO / "MATCHING" / "results"
NCOL = 5
HEADER = [
    r"\toprule",
    r" & & & & \multicolumn{3}{c}{FamilySearch names in} \\",
    r"\cmidrule(lr){5-7}",
    r" & & Ancestry & Ours & 1930 \& 1940 & 1930 & 1940 \\",
    r"\midrule",
]


def rows(path):
    """(block, own label, group, [values]) for every data row. Blank labels and
    the indented N rows belong to the block of the rate row above them."""
    out, label = [], None
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line.startswith("%") or not line.endswith(r"\\") or line.startswith(r"\multicolumn"):
            continue
        cells = [c.strip() for c in line[:-2].split("&")]
        if len(cells) != NCOL + 2 or cells[2] == "Ancestry":
            continue
        if cells[0] and not cells[0].startswith(r"\quad"):
            label = cells[0]
        out.append((label, cells[0], cells[1], cells[2:]))
    return out


def fmt(cells):
    return " & ".join(cells) + r" \\"


def versions(paper):
    src = rows(RESULTS / "fs_avg_performance.tex")
    keep = ["Linkage rate (\\%)", "Share validated (\\%)", "Share validated, Ancestry initials (\\%)"]
    lines = list(HEADER)
    for k in keep:
        block = [r for r in src if r[0] == k]
        expect = 2 if k == keep[0] else 4  # shares carry an N row each for Target and All
        assert len(block) == expect, f"{k}: expected {expect} rows, got {len(block)}"
        if k != keep[0]:
            lines.append(r"\addlinespace")
        for lab, own, grp, vals in block:
            lines.append(fmt([own, grp] + vals))
    lines += [r"\bottomrule"]
    write(paper / "figures" / "fs_versions_allstates.tex", "llccccc", lines, "fs_avg_performance.tex")


PANEL = re.compile(r"\\textit\{(.+): ([\d,]+) records \(([\d.]+)\\% of target\)\}")
CELLS = [
    ("Model = Ancestry only", "1. Ours matches Ancestry's name only"),
    ("Model = FamilySearch only", "2. Ours matches FamilySearch's name only"),
    ("Model = neither", "3. Ours is complete and matches neither"),
    ("No model output", "4. No model output in one or both name fields"),
    ("A human field empty", "Discordant, but a human name field is empty"),
    ("Not classified", "Not classified"),
]


def panels():
    """{cell label: (records, share, [rows])} from fs_cells.tex."""
    text = (RESULTS / "fs_cells.tex").read_text(encoding="utf-8").splitlines()
    out, cur = {}, None
    for line in text:
        m = PANEL.search(line)
        if m:
            cur = m.group(1)
            out[cur] = (m.group(2), m.group(3), [])
            continue
        s = line.strip()
        if cur and s.endswith(r"\\") and not s.startswith(r"\multicolumn"):
            cells = [c.strip() for c in s[:-2].split("&")]
            if len(cells) == NCOL + 2:
                out[cur][2].append((cells[0], cells[2:]))
    assert [c for c, _ in CELLS] == list(out), f"panels in fs_cells.tex: {list(out)}"
    return out


def sizes(paper, p):
    lines = [r"\toprule", r" & Records & Share of target set (\%) \\", r"\midrule"]
    total = 0
    for i, (key, lab) in enumerate(CELLS):
        n, sh, _ = p[key]
        if i == 4:
            lines.append(r"\midrule")
        lines.append(fmt([lab, n, sh]))
        total += int(n.replace(",", ""))
    assert total == 14416543, f"cells sum to {total}, not the target set"
    lines += [r"\midrule", fmt(["Target set", f"{total:,}", "100.0"]), r"\bottomrule"]
    write(paper / "figures" / "fs_cells_sizes_allstates.tex", "lrc", lines, "fs_cells.tex")


def by_cell(paper, p):
    want = ["Linkage rate (\\%)", "Share validated (\\%)", r"\quad links with both initials",
            "Share validated, Ancestry initials (\\%)", r"\quad links with both initials"]
    lines = list(HEADER)
    for i, (key, lab) in enumerate(CELLS[:4]):
        n, sh, body = p[key]
        assert [r[0] for r in body] == want, f"{key}: rows {[r[0] for r in body]}"
        if i:
            lines.append(r"\midrule")
        lines.append(r"\multicolumn{7}{l}{\textit{" + lab + f" ({n} records, {sh}\\% of target set)" + r"}} \\")
        for lab_r, vals in body:
            lines.append(fmt([lab_r, ""] + vals))
    lines += [r"\bottomrule"]
    write(paper / "figures" / "fs_cells_allstates.tex", "llccccc", lines, "fs_cells.tex")


def write(path, spec, lines, src):
    head = [f"% Written by MATCHING/fs_draft_tables.py from MATCHING/results/{src}; do not edit by hand.",
            r"\begin{tabular}{" + spec + "}"]
    path.write_text("\n".join(head + lines + [r"\end{tabular}", ""]), encoding="utf-8")
    print("wrote", path)


if __name__ == "__main__":
    paper = Path(sys.argv[1])
    assert (paper / "figures").is_dir(), f"no figures/ under {paper}"
    versions(paper)
    p = panels()
    sizes(paper, p)
    by_cell(paper, p)
