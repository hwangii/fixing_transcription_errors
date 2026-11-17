"""Non-target linkage numbers, derived as All minus Target (2026-11-17).

The slides' 'Target records' and 'All records' tables come from machine B
(paper repo figures/deaglan_abe_jw{,_restricted}.tex and
figures/deaglan_hlink{,_restricted}.tex; _restricted = target records).
Non-target = records where Ancestry and FamilySearch agree = All - Target.

Exact: counts (Verified Correct, Unverifiable, Directly Contradicted) are
additive; Match Rate = (V + U + C) / records, checked against each table's
printed rate before it is used. Approximate: recall, whose denominator
(true links available) is backed out as V / (printed recall / 100), so it
carries the rounding of the printed recall. MI match rate cannot be derived
(its denominator, links with both initials, is not printed).

    python MATCHING/nontarget_from_tables.py [paper_repo]
"""
import re
import sys
from pathlib import Path

PAPER = Path(sys.argv[1] if len(sys.argv) > 1 else r"D:\repos\6638fa0fd89fbec05130caeb")
N_ALL, N_TGT = 51_036_859, 14_416_543  # linkDenomAbe, linkDenomAbeDisc
N_NON = N_ALL - N_TGT
ROWS = {"Match Rate": "mr", "Verified Correct": "V", "Unverifiable": "U",
        "Directly Contradicted": "C", "Recall": "rec"}


def panel_a(path):
    """Panel A rows -> {key: [values per column]} (columns as printed)."""
    out = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith(r"\midrule") and out:
            break  # end of Panel A
        for lab, key in ROWS.items():
            if line.startswith(lab):
                cells = line.split("&")[1:]
                out[key] = [float(re.sub(r"[^\d.]", "", c)) for c in cells]
    assert set(out) == set(ROWS.values()), (path, out.keys())
    return out


def check_rate(t, n, name):
    for j in range(len(t["V"])):
        mr = 100 * (t["V"][j] + t["U"][j] + t["C"][j]) / n
        assert abs(mr - t["mr"][j]) < 0.006, (name, j, mr, t["mr"][j])


fig = PAPER / "figures"
# (method, file stem, column index of Old, of New) as each table prints them.
specs = [("ABE exact", "deaglan_abe_jw", 2, 3),
         ("ABE Jaro-Winkler", "deaglan_abe_jw", 0, 1),
         ("MLP (HLINK)", "deaglan_hlink", 0, 1)]
for method, stem, io, inew in specs:
    a = panel_a(fig / f"{stem}.tex")
    t = panel_a(fig / f"{stem}_restricted.tex")
    check_rate(a, N_ALL, stem)
    check_rate(t, N_TGT, stem + "_restricted")
    for ver, j in (("Old", io), ("New", inew)):
        V, U, C = (a[k][j] - t[k][j] for k in "VUC")
        assert min(V, U, C) >= 0
        den = a["V"][j] / (a["rec"][j] / 100) - t["V"][j] / (t["rec"][j] / 100)
        print(f"{method:17s} {ver}: match {100*(V+U+C)/N_NON:6.2f}%  V {V:>12,.0f}  U {U:>12,.0f}"
              f"  C {C:>9,.0f}  C/(V+C) {100*C/(V+C):5.2f}%  recall~ {100*V/den:4.1f}%")
print(f"non-target records: {N_NON:,}")
