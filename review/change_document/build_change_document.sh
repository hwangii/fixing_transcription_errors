#!/usr/bin/env bash
# Rebuild DHTS-changes-since-2026-08-28.{tex,pdf} in the paper repo:
# a latexdiff of the current draft against the 2026-08-28 Overleaf version
# (paper repo commit 271626f, where the draft was DHTS-2024-11-18.tex).
#
# Tables are flattened from their \input files and treated as whole blocks:
# where a table changed, its 2026-08-28 version is printed in red, unnumbered,
# above the current one (restore_old_tables.py). Tables new since August
# appear once, as they are now.
#
# Run from Git Bash (needs latexdiff-so, latexmk and python on PATH):
#   bash review/change_document/build_change_document.sh [paper_repo]
set -euo pipefail

PAPER="${1:-/d/repos/6638fa0fd89fbec05130caeb}"
HERE="$(cd "$(dirname "$0")" && pwd)"
BASE_COMMIT=271626f
OUT=DHTS-changes-since-2026-08-28

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# the August tree, so the base draft's \input files resolve
mkdir "$WORK/old"
git -C "$PAPER" archive "$BASE_COMMIT" | tar -x -C "$WORK/old"

cd "$PAPER"
latexdiff-so --flatten \
  --config="PICTUREENV=(?:picture|DIFnomarkup|tabular|threeparttable)[\w\d*@]*" \
  "$WORK/old/DHTS-2024-11-18.tex" DHTS-2026-10-12.tex > "$WORK/raw.tex"
python -I "$HERE/restore_old_tables.py" "$WORK/raw.tex" "$OUT.tex"
latexmk -pdf -interaction=nonstopmode "$OUT.tex" > /dev/null
grep "Output written" "$OUT.log"
