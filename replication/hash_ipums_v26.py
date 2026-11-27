"""SHA-256 of the two files sent to IPUMS for MLP linking (v26 base).

    python replication/hash_ipums_v26.py           # write replication/ipums_v26_manifest.md
    python replication/hash_ipums_v26.py --check   # recompute and compare
    ... --force                                    # replace the manifest (only for a new send)
    ... --dir <folder>                             # data elsewhere (default F:)

The manifest records exactly which bytes IPUMS received, so the links they
return can be tied to the files verify_mlp_v26_independent.do checked.
About 28 GB; a few minutes. A rebuild changes the bytes (Stata stamps the
save time in each .dta), so after a rebuild compare cells, not checksums.
"""

import hashlib
import re
import sys
import time
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
DIR = Path("F:/enum_date/DATA/INTERMEDIATE")
FILES = ["for_mlp1930_v26_combined.dta", "for_mlp1940_v26_combined.dta"]
OUT = REPO / "replication" / "ipums_v26_manifest.md"


def sha(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(1 << 24), b""):
            h.update(b)
    return h.hexdigest()


def main():
    global DIR
    if "--dir" in sys.argv:
        DIR = Path(sys.argv[sys.argv.index("--dir") + 1])
    if "--check" in sys.argv and not OUT.is_file():
        sys.exit(f"no manifest to check against: {OUT}")
    if "--check" not in sys.argv and OUT.is_file() and "--force" not in sys.argv:
        sys.exit(f"{OUT} exists (the checksums as sent); use --check, or --force to replace it")
    rows = []
    for n in FILES:
        p = DIR / n
        if not p.is_file():
            sys.exit(f"missing: {p}")
        rows.append((n, p.stat().st_size, sha(p)))
    if "--check" in sys.argv:
        old = dict(re.findall(r"\| `([^`]+)` \| [\d,]+ \| `([0-9a-f]{64})` \|", OUT.read_text(encoding="utf-8")))
        bad = [n for n, _, h in rows if old.get(n) != h]
        for n, _, h in rows:
            print(n, "OK" if old.get(n) == h else "CHANGED", h)
        sys.exit(1 if bad or len(old) != len(FILES) else 0)
    lines = [
        "# Files sent to IPUMS for MLP linking (v26 base)",
        "",
        f"Written by `replication/hash_ipums_v26.py` on {time.strftime('%Y-%m-%d')}, from `{DIR.as_posix()}`.",
        "Built by `replication/build_v26_machineA.do` steps 1, 2 and 2b and checked by step 3.",
        "",
        "| File | Bytes | SHA-256 |",
        "|---|---:|---|",
    ]
    lines += [f"| `{n}` | {s:,} | `{h}` |" for n, s, h in rows]
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(OUT.read_text(encoding="utf-8"))


if __name__ == "__main__":
    main()
