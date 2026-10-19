"""Write the paper's figures/deaglan_*.tex from Deaglan's linkage tables.

Each of Deaglan's tables is a complete table float with his own caption and
label. The paper supplies its own caption (his HLINK caption says "all men";
the denominator is men AND women aged 8+), so only the tabular is taken. This
script does mechanically what was done by hand on 2026-10-12.

    # default: extract from the committed copies, deaglan_results/current/
    python replication/extract_deaglan_tables.py

    # after a rerun on machine B: compare the regenerated tables with the
    # committed ones, then extract
    python replication/extract_deaglan_tables.py --regenerated F:/Deaglan/Census_Transcriptions/output/tables

    # test: change nothing, only report whether figures/ would change
    python replication/extract_deaglan_tables.py --check

With --regenerated, a table whose regenerated text equals the committed copy
is extracted from the committed copy, so figures/ does not change. A table
that differs is extracted from the regenerated file, and its header names that
file. So, as on machine A, a changed figures/deaglan_*.tex in the paper repo
means the table did NOT reproduce. Line endings are ignored when comparing:
git stores both with LF.

Exit status: 0 if every table reproduced and (with --check) figures/ is
unchanged; 1 otherwise. Standard library only.
"""

import argparse
import socket
import sys
import tomllib
from pathlib import Path

HERE = Path(__file__).resolve().parent
TABLES = ["abe_jw", "abe_jw_restricted", "hlink", "hlink_restricted"]
COMMITTED = "deaglan_results/current"

HEADER = [
    "% EXTRACTED MECHANICALLY from {source} -- DO NOT EDIT BY HAND.",
    "% Tabular only. Deaglan's file is a complete table float; its caption and",
    "% label stay there. The paper supplies its own caption, because the package",
    "% caption on the HLINK tables says 'all men' when the denominator is men AND",
    "% women aged 8+. See deaglan_results/current/PROVENANCE.md, Q3.",
]


def read(path):
    """Text with LF line endings, and the line ending the file itself uses."""
    raw = path.read_bytes().decode("utf-8")
    eol = "\r\n" if "\r\n" in raw else "\n"
    return raw.replace("\r\n", "\n"), eol


def tabular(text, path):
    lines = text.split("\n")
    starts = [i for i, l in enumerate(lines) if l.startswith(r"\begin{tabular}")]
    ends = [i for i, l in enumerate(lines) if l.startswith(r"\end{tabular}")]
    if len(starts) != 1 or len(ends) != 1 or ends[0] < starts[0]:
        sys.exit(f"{path}: expected exactly one tabular, found {len(starts)} begin / {len(ends)} end")
    return lines[starts[0]:ends[0] + 1]


def build(source_label, body, eol):
    lines = [h.format(source=source_label) for h in HEADER] + body
    return eol.join(lines) + eol


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--paper-repo", type=Path)
    ap.add_argument("--regenerated", type=Path, help="folder holding a fresh run's linkage_table_*.tex")
    ap.add_argument("--check", action="store_true", help="write nothing; report what would change")
    args = ap.parse_args()

    paper = args.paper_repo
    if paper is None:
        registry = tomllib.loads((HERE / "claims.toml").read_text(encoding="utf-8"))
        host = socket.gethostname()
        try:
            paper = Path(registry["machines"][host]["paper_repo"])
        except KeyError:
            sys.exit(f"no paper_repo for machine {host} in claims.toml [machines]; pass --paper-repo")

    failed = False
    for name in TABLES:
        fname = f"linkage_table_{name}.tex"
        committed = paper / COMMITTED / fname
        ctext, eol = read(committed)
        source_label, text = f"{COMMITTED}/{fname}", ctext

        if args.regenerated:
            regen = args.regenerated / fname
            if not regen.exists():
                print(f"  MISSING     {fname}: not in {args.regenerated}")
                failed = True
                continue
            rtext, _ = read(regen)
            if rtext == ctext:
                print(f"  REPRODUCED  {fname}")
            else:
                print(f"  DIFFERS     {fname}: regenerated table is not the committed one")
                source_label, text = regen.as_posix(), rtext
                failed = True

        target = paper / "figures" / f"deaglan_{name}.tex"
        new = build(source_label, tabular(text, committed), eol)
        old = target.read_bytes().decode("utf-8") if target.exists() else None
        same = old == new
        if args.check:
            print(f"  {'unchanged' if same else 'WOULD CHANGE'}  figures/{target.name}")
            failed |= not same
        elif not same:
            target.write_bytes(new.encode("utf-8"))
            print(f"  wrote       figures/{target.name}")
        else:
            print(f"  unchanged   figures/{target.name}")

    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
