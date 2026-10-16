"""Check every number the draft quotes against the code that produces it.

Reads replication/claims.toml (the registry), replication/results/*.tex (the
numbers the scripts wrote via repnum), the exhibit tables in the paper repo,
and the draft itself. Writes nothing except the report. Never edits the draft.

    python replication/check_claims.py              # report to console + claims_report.md
    python replication/check_claims.py --paper-repo D:/repos/6638fa0fd89fbec05130caeb

Exit status is 1 if any number disagrees with its source, any claim's text is
no longer in the draft, or any assertion fails; otherwise 0. PENDING (script
not yet run on this machine) and UNCHECKED (no producing code) do not fail the
run, but both are listed, because neither is verified.

Standard library only (Python 3.11+ for tomllib), so it runs on either machine.
"""

import argparse
import re
import socket
import sys
import tomllib
from decimal import Decimal, ROUND_HALF_UP
from pathlib import Path

HERE = Path(__file__).resolve().parent

# A number as the draft prints it: 51,066,203 / 28.3 / 0.06 / 119. The lookbehind
# keeps "V2" or "1.4.2" fragments from being read as numbers.
NUM = re.compile(r"(?<![\w.])(\d{1,3}(?:,\d{3})+|\d+)(\.\d+)?")
RESULT_LINE = re.compile(r"\\newcommand\{\\([A-Za-z]+)\}\{([^}]*)\}% raw=(\S+)")


class Pending(Exception):
    """A result key the expression needs has not been produced on this machine."""


def load_results(results_dir):
    vals, where = {}, {}
    for f in sorted(results_dir.glob("*.tex")):
        for line in f.read_text(encoding="utf-8").splitlines():
            m = RESULT_LINE.match(line)
            if not m:
                continue
            key, _shown, raw = m.groups()
            if key in vals:
                sys.exit(f"duplicate result key \\{key} in {f.name} and {where[key]}")
            vals[key] = float(raw)
            where[key] = f.name
    return vals, where


class Tables:
    """Read numbers out of the exhibit .tex tables in the paper repo."""

    def __init__(self, paper_repo):
        self.root = paper_repo
        self.cache = {}

    def rows(self, file):
        if file not in self.cache:
            path = self.root / file
            if not path.exists():
                raise FileNotFoundError(f"table {file} not in paper repo")
            rows = {}
            for line in path.read_text(encoding="utf-8").splitlines():
                if "&" not in line or line.lstrip().startswith("%"):
                    continue
                cells = [c.strip() for c in line.split("&")]
                label = cells[0]
                rows.setdefault(label, cells[1:])  # first occurrence wins
            self.cache[file] = rows
        return self.cache[file]

    def cell(self, file, row, col):
        rows = self.rows(file)
        hits = [lab for lab in rows if lab.startswith(row)]
        if not hits:
            raise KeyError(f'no row starting "{row}" in {file}')
        raw = rows[hits[0]][col - 1]
        clean = re.sub(r"\\\\|\\%|[,*+$]", "", raw).strip()
        return float(clean)

    def contra(self, file, col):
        c = self.cell(file, "Directly Contradicted", col)
        v = self.cell(file, "Verified Correct", col)
        u = self.cell(file, "Unverifiable", col)
        return 100 * c / (v + u + c)


def evaluate(expr, results, tables):
    names = set(re.findall(r"\b[A-Za-z]+\b", re.sub(r'"[^"]*"', "", expr)))
    missing = sorted(n for n in names - {"cell", "contra", "and", "or", "not", "abs"} if n not in results)
    if missing:
        raise Pending(", ".join(missing))
    env = {"__builtins__": {}, "cell": tables.cell, "contra": tables.contra, "abs": abs}
    env.update(results)
    return eval(expr, env)  # expressions come from our own tracked registry


def rounds_to(value, number_text):
    """Does value, rounded half-up to the draft's printed precision, equal the draft?"""
    shown = Decimal(number_text.replace(",", ""))
    places = -shown.as_tuple().exponent if "." in number_text else 0
    got = Decimal(repr(value)).quantize(Decimal(1).scaleb(-places), rounding=ROUND_HALF_UP)
    return got == shown, got


def draft_lines(draft):
    """1-based line numbers of non-comment lines, and the text of each."""
    out = {}
    for i, line in enumerate(draft.splitlines(), 1):
        if not line.lstrip().startswith("%"):
            out[i] = line
    return out


def find_text(text, lines):
    return [i for i, line in lines.items() if text in line]


def check(registry, draft, results, tables):
    lines = draft_lines(draft)
    rows = []
    covered = {}  # line -> list of (start, end) spans covered by registered claims

    for c in registry["claim"]:
        cid, text = c["id"], c["text"]
        hits = find_text(text, lines)
        row = {"id": cid, "lines": hits, "status": c["status"], "machine": c.get("machine", "?"),
               "script": c.get("script", ""), "issue": c.get("issue", ""), "checks": []}
        rows.append(row)
        if not hits:
            in_comment = text in draft
            row["result"] = "IN COMMENT ONLY" if in_comment else "TEXT NOT FOUND"
            continue
        for i in hits:
            start = lines[i].index(text)
            covered.setdefault(i, []).append((start, start + len(text)))

        numbers = ["".join(m.groups(default="")) for m in NUM.finditer(text)]
        values = c.get("values", [])
        if len(values) != len(numbers):
            row["result"] = "REGISTRY ERROR"
            row["checks"].append(f"text has {len(numbers)} numbers {numbers}, values has {len(values)}")
            continue

        outcomes = []
        for num, expr in zip(numbers, values):
            if expr == "":
                outcomes.append("UNCHECKED")
                row["checks"].append(f"{num}: unchecked")
                continue
            try:
                v = evaluate(expr, results, tables)
            except Pending as e:
                outcomes.append("PENDING")
                row["checks"].append(f"{num}: pending ({e})")
                continue
            except Exception as e:  # a table or row that has moved is a finding, not a crash
                outcomes.append("ERROR")
                row["checks"].append(f"{num}: {type(e).__name__}: {e}")
                continue
            ok, got = rounds_to(v, num)
            outcomes.append("MATCH" if ok else "MISMATCH")
            row["checks"].append(f"{num}: {'ok' if ok else f'MISMATCH, source gives {got} (raw {v:.6g})'}")

        if "assert" in c:
            try:
                ok = bool(evaluate(c["assert"], results, tables))
                outcomes.append("MATCH" if ok else "ASSERT FAILED")
                row["checks"].append("assert: " + ("holds" if ok else "FAILS") + f"  [{c['assert']}]")
            except Pending as e:
                outcomes.append("PENDING")
                row["checks"].append(f"assert: pending ({e})")
            except Exception as e:
                outcomes.append("ERROR")
                row["checks"].append(f"assert: {type(e).__name__}: {e}")

        for verdict in ("MISMATCH", "ASSERT FAILED", "ERROR", "PENDING", "UNCHECKED", "MATCH"):
            if verdict in outcomes:
                row["result"] = verdict
                break
        else:
            row["result"] = "UNCHECKED"
        if c["status"] == "nocode":
            row["result"] = "UNCHECKED"

    # Ignored text counts as covered: the decision that it is not a result is recorded.
    for ig in registry.get("ignore", []):
        hits = find_text(ig["text"], lines)
        if not hits:
            print(f"  note: ignore text not in draft (remove it from claims.toml): {ig['text'][:60]}")
        for i in hits:
            for m in re.finditer(re.escape(ig["text"]), lines[i]):
                covered.setdefault(i, []).append((m.start(), m.end()))

    return rows, unregistered(lines, covered)


# Numbers that look like results: decimals, comma-grouped counts, or followed by % / percent.
RESULTISH = re.compile(r"(?<![\w.{])(\d{1,3}(?:,\d{3})+|\d+\.\d+|\d+(?=\s*(?:\\%|%|\s?percent)))")


def unregistered(lines, covered):
    """Result-like numbers in the body that no claim's text covers."""
    found = []
    in_body = False
    for i, line in lines.items():
        if r"\begin{document}" in line:
            in_body = True
        if not in_body or r"\bibliography" in line:
            continue
        for m in RESULTISH.finditer(line):
            if any(a <= m.start() < b for a, b in covered.get(i, [])):
                continue
            found.append((i, m.group(1), line.strip()[:110]))
    return found


def check_exhibits(registry, draft, paper_repo):
    lines = draft_lines(draft)
    out = []
    for e in registry.get("exhibit", []):
        f = e["file"]
        stem = f.rsplit(".", 1)[0]
        exists = (paper_repo / f).exists()
        used = [i for i, line in lines.items() if stem in line]
        note = ""
        if exists and f.endswith(".tex"):
            head = (paper_repo / f).read_text(encoding="utf-8")[:300]
            if "GENERATED BY" in head:
                note = "header: generated"
            elif "EXTRACTED MECHANICALLY" in head:
                note = "header: extracted from Deaglan's package"
            else:
                note = "NO GENERATED-BY HEADER"
        out.append({**e, "exists": exists, "used": used, "note": note})
    return out


def render(rows, unreg, exhibits, draft_name, results_where, out):
    from collections import Counter
    tally = Counter(r["result"] for r in rows)
    order = ["MISMATCH", "ASSERT FAILED", "TEXT NOT FOUND", "IN COMMENT ONLY", "REGISTRY ERROR",
             "ERROR", "PENDING", "UNCHECKED", "MATCH"]
    md = [f"# Claim check: `{draft_name}`", "",
          "Generated by `replication/check_claims.py` -- do not edit by hand.", "",
          "| result | claims |", "|---|---|"]
    md += [f"| {k} | {tally[k]} |" for k in order if tally[k]]
    md += ["", f"Result files read: {', '.join(sorted(set(results_where.values()))) or 'none yet'}", ""]
    md += ["## Claims", "", "| result | id | draft line | machine | checks | known issue |", "|---|---|---|---|---|---|"]
    for r in sorted(rows, key=lambda r: (order.index(r["result"]), r["lines"][:1] or [0])):
        lns = ",".join(map(str, r["lines"])) or "-"
        checks = "<br>".join(r["checks"]).replace("|", "\\|")
        md.append(f"| **{r['result']}** | `{r['id']}` | {lns} | {r['machine']} | {checks} | {r['issue'].replace('|', '/')} |")
    md += ["", "## Exhibits", "", "| file | label | exists | used at line | machine | note | known issue |",
           "|---|---|---|---|---|---|---|"]
    for e in exhibits:
        md.append(f"| `{e['file']}` | {e['label']} | {'yes' if e['exists'] else '**NO**'} | "
                  f"{','.join(map(str, e['used'])) or '**not used**'} | {e['machine']} | {e['note']} | {e.get('issue', '')} |")
    md += ["", f"## Result-like numbers no claim covers ({len(unreg)})", "",
           "Each is either a number to add to `claims.toml`, or one that is not an empirical result",
           "(a parameter, a year, a citation). Either way, decide once and record it.", "",
           "| line | number | context |", "|---|---|---|"]
    md += [f"| {i} | {n} | {ctx.replace('|', '/')} |" for i, n, ctx in unreg]
    out.write_text("\n".join(md) + "\n", encoding="utf-8")

    print(f"claims: " + ", ".join(f"{tally[k]} {k}" for k in order if tally[k]))
    for r in rows:
        if r["result"] in ("MISMATCH", "ASSERT FAILED", "TEXT NOT FOUND", "REGISTRY ERROR", "ERROR"):
            print(f"  {r['result']:15s} {r['id']} (line {','.join(map(str, r['lines'])) or '-'})")
            for ch in r["checks"]:
                if "ok" not in ch and "unchecked" not in ch and "holds" not in ch:
                    print(f"      {ch}")
    missing = [e["file"] for e in exhibits if not e["exists"] or not e["used"]]
    print(f"exhibits: {len(exhibits)} registered, {len(missing)} missing or unused {missing if missing else ''}")
    print(f"unregistered result-like numbers in the draft: {len(unreg)}")
    print(f"report: {out}")
    bad = sum(tally[k] for k in ("MISMATCH", "ASSERT FAILED", "TEXT NOT FOUND", "REGISTRY ERROR", "ERROR"))
    return 1 if bad or missing else 0


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--registry", type=Path, default=HERE / "claims.toml")
    ap.add_argument("--results", type=Path, default=HERE / "results")
    ap.add_argument("--paper-repo", type=Path)
    ap.add_argument("--report", type=Path, default=HERE / "claims_report.md")
    args = ap.parse_args()

    registry = tomllib.loads(args.registry.read_text(encoding="utf-8"))
    paper = args.paper_repo
    if paper is None:
        host = socket.gethostname()
        try:
            paper = Path(registry["machines"][host]["paper_repo"])
        except KeyError:
            sys.exit(f"no paper_repo for machine {host} in claims.toml [machines]; pass --paper-repo")
    draft_path = paper / registry["draft"]
    draft = draft_path.read_text(encoding="utf-8")

    results, where = load_results(args.results)
    rows, unreg = check(registry, draft, results, Tables(paper))
    exhibits = check_exhibits(registry, draft, paper)
    sys.exit(render(rows, unreg, exhibits, registry["draft"], where, args.report))


if __name__ == "__main__":
    main()
