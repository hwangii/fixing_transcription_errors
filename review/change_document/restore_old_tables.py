"""Make latexdiff's deleted tables visible.

latexdiff comments out deleted non-text blocks (lines prefixed '%DIFDELCMD < ').
For each such block that contains a table, un-comment it and render it in red,
with an unnumbered caption marked as the 2026-08-28 version and no \\label, so
table numbering and cross-references follow the current draft.

usage: python restore_old_tables.py in.tex out.tex
"""
import re
import sys

PREFIX = "%DIFDELCMD < "
TABLE_RE = re.compile(r"\\begin\{(tabular|threeparttable|table)")


def restore(lines):
    out, i, n_restored = [], 0, 0
    while i < len(lines):
        line = lines[i]
        m = re.match(r"^(\s*\\DIFdelbegin(?:FL)? )%DIFDELCMD < (.*)$", line, re.S)
        if not m:
            out.append(line)
            i += 1
            continue
        # collect the commented block
        head, body = m.group(1), [m.group(2)]
        j = i + 1
        # read through to latexdiff's end-of-deletion marker; flattened
        # \input files leave blank lines inside the block
        while j < len(lines) and not lines[j].lstrip().startswith("\\DIFdelend"):
            if lines[j].startswith(PREFIX):
                body.append(lines[j][len(PREFIX):])
            elif lines[j].strip() == "" or lines[j].lstrip().startswith("%"):
                body.append(lines[j])
            else:
                break  # live text: not a pure deleted block, leave untouched
            j += 1
        if j >= len(lines) or not lines[j].lstrip().startswith("\\DIFdelend"):
            out.append(line)
            i += 1
            continue
        block = "".join(body)
        if not TABLE_RE.search(block):
            out.append(line)
            out.extend(lines[i + 1:j])
            i = j
            continue
        block = re.sub(r"\\label\{[^}]*\}", "", block)
        block = block.replace(
            "\\caption{",
            "\\caption*{\\textbf{[2026-08-28 version, replaced]} ",
        )
        block = re.sub(r"(?m)^%%%\s*$", "", block)
        # old table sits in the same float as the new one: keep it compact
        block = block.replace("\\renewcommand{\\arraystretch}{", "\\def\\DIFunusedstretch{")
        tag = ""
        if "\\caption*{" not in block:
            tag = ("{\\centering\\textbf{[2026-08-28 version, replaced by the table below]}"
                   "\\par\\smallskip}\n")
        out.append(head + "%DIF restored old table\n")
        out.append("{\\color{red}\\scriptsize\\renewcommand{\\arraystretch}{1.05}\n"
                   + tag + block + "}\\par\\medskip\n")
        if "FL" in head:
            # inside a table float: close it after the old table and open a
            # second one for the current table, so a long pair can break
            out.append("\\end{table}\n\\begin{table}[H]\\footnotesize\\centering\n")
        n_restored += 1
        i = j
    return out, n_restored


if __name__ == "__main__":
    src, dst = sys.argv[1], sys.argv[2]
    with open(src, encoding="utf-8") as f:
        lines = f.readlines()
    out, n = restore(lines)
    with open(dst, "w", encoding="utf-8", newline="") as f:
        f.writelines(out)
    print(f"restored {n} old table block(s)")
