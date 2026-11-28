"""SHA-256 of everything machine A sends machine B for the v26 Jaro-Winkler rerun
(review/handoff_jw_inputs_machineA.md item 3).

    python replication/hash_jw_v26.py                 # write replication/jw_v26_manifest.md
    python replication/hash_jw_v26.py --check         # recompute here and compare
    python replication/hash_jw_v26.py --check --dir X # on B: X holds the copied folders/files

Covers the four v26 shard folders (norace*.dta) and jw_census_vars{1930,1940}_v26.dta.
Paths in the manifest are relative to the data folder, so B checks its copy
with --dir pointing at wherever the author put it. About 30 GB.
"""

import hashlib
import re
import sys
import time
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
DIR = Path("F:/enum_date/DATA/INTERMEDIATE")
FOLDERS = [
    "divided_file1930_v26_ans_cleaned",
    "divided_file1940_v26_ans_cleaned",
    "divided_file1940_v26_true_cleaned",
    "divided_file1940_v26_tgt_cleaned",
]
FILES = ["jw_census_vars1930_v26.dta", "jw_census_vars1940_v26.dta"]
OUT = REPO / "replication" / "jw_v26_manifest.md"
ROW = re.compile(r"\| `([^`]+)` \| ([\d,]+) \| `([0-9a-f]{64})` \|")


def sha(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(1 << 24), b""):
            h.update(b)
    return h.hexdigest()


def listing(root):
    rel = []
    for d in FOLDERS:
        fs = sorted((root / d).glob("norace*.dta"))
        if not fs:
            sys.exit(f"no shards in {root / d}")
        rel += [f"{d}/{f.name}" for f in fs]
    sets = {d: {f.split("/")[1] for f in rel if f.startswith(d + "/")} for d in FOLDERS[1:]}
    if len({frozenset(v) for v in sets.values()}) != 1:
        sys.exit("the three 1940 shard folders hold different file sets")
    for n in FILES:
        if not (root / n).is_file():
            sys.exit(f"missing: {root / n}")
        rel.append(n)
    return rel


def main():
    root = Path(sys.argv[sys.argv.index("--dir") + 1]) if "--dir" in sys.argv else DIR
    check = "--check" in sys.argv
    if check and not OUT.is_file():
        sys.exit(f"no manifest to check against: {OUT}")
    if not check and OUT.is_file() and "--force" not in sys.argv:
        sys.exit(f"{OUT} exists; use --check, or --force to replace it")
    rel = listing(root)
    if check:
        old = {n: h for n, _, h in ROW.findall(OUT.read_text(encoding="utf-8"))}
        bad = 0
        for n in sorted(set(old) | set(rel)):
            if n not in rel:
                print("MISSING", n); bad += 1; continue
            if n not in old:
                print("EXTRA", n); bad += 1; continue
            if sha(root / n) != old[n]:
                print("CHANGED", n); bad += 1
        print(f"{len(old)} in manifest, {len(rel)} on disk, {bad} problem(s)")
        sys.exit(1 if bad else 0)
    rows = [(n, (root / n).stat().st_size, sha(root / n)) for n in rel]
    lines = [
        "# Files machine A sends machine B for the v26 Jaro-Winkler rerun",
        "",
        f"Written by `replication/hash_jw_v26.py` on {time.strftime('%Y-%m-%d')}, from `{root.as_posix()}`;",
        "built by `MATCHING/1f_v26_inputs.do` (shards) and `MATCHING/1j_v26_jw_census_vars.do` (census variables).",
        f"{len(rows)} files, {sum(s for _, s, _ in rows):,} bytes. On B: `python replication/hash_jw_v26.py --check --dir <copy>`.",
        "",
        "| File | Bytes | SHA-256 |",
        "|---|---:|---|",
    ]
    lines += [f"| `{n}` | {s:,} | `{h}` |" for n, s, h in rows]
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {OUT}: {len(rows)} files")


if __name__ == "__main__":
    main()
