# Review request: new Section 4.4, "Comparison with a Second Human Transcription"

I want you to review a new subsection that was added to my paper draft. Please read critically. I am not asking you to polish the wording; I am asking whether the claims are supported, correctly worded, and not over-sold. Everything you need is in this message: the background, how the numbers were produced, the three tables, and the LaTeX of the subsection.

## The paper in brief

The paper is about fixing transcription errors in the full-count 1940 US census.
- Every 1940 record has been transcribed twice, by two commercial genealogy firms: Ancestry.com and FamilySearch.org. The two often disagree on the first or last name.
- We trained a machine-learning model that re-reads the first and last names from the scanned page images. It reads the image only. At inference it does not see either human transcription. It was trained on records where Ancestry and FamilySearch agree.
- We then link men in the 1940 census to the 1930 census with the ABE exact-name algorithm (as in Abramitzky, Boustan and Eriksson). Links must be unique on cleaned first name, last name and birthplace, with a ±2-year birth-year band.
- Link quality is measured by the "share validated": among links where the middle initial is recorded in both censuses, the share where the two initials agree. Middle initials are not used in linking.
- The "target set" is the 14,416,543 men aged 10 and above whose Ancestry and FamilySearch 1940 names disagree. "All" is the 51,036,859 men aged 10 and above with all four human name fields present.
- The paper's main table (Table 4) compares links built on Ancestry's names ("before") with links built on our model's names ("after"). Where our model produced no output for a field, Ancestry's is used for that field. On the target set, the linkage rate rises from 8.9% to 19.4% and the share validated from 65.4% to 83.6%.
- Section 2 of the paper reports, over all 35.1 million discordant records in the census (both sexes, all ages), how often the model's name matches each human transcription: Ancestry's only 14.3%, FamilySearch's only 51.8%, neither 24.3%, no model output 9.6%.

## Why this section exists

Referees asked two things. First, how our model compares with simply using the second human transcription, FamilySearch's, in place of Ancestry's. Second, whether the 24% of discordant records where the model's name matches neither human transcription add links. That 24% is the part a second human transcription could not give you.

## What was done

All computations ran on the same sample, linking algorithm and validation rule as the main table. Before writing any output, the code checks that its Ancestry and Ours columns reproduce Table 4 exactly; both checks passed.

**Three FamilySearch versions.** We re-ran the linkage with FamilySearch names substituted for Ancestry's:
- in the 1940 census only;
- in the 1930 census only;
- in both censuses.

Substitution is field by field: FamilySearch's first (or last) name where FamilySearch reports one, Ancestry's otherwise. Men only, exact-name ABE.

**Placebo check.** Running the FamilySearch path with no FamilySearch names substituted reproduces the Ancestry link file exactly.

**Two ways of scoring "share validated":**
- *Own initials*, as in the paper: each version is scored with its own transcription's middle initials.
- *Ancestry initials*: every version is scored against Ancestry's middle initials in both years, so all versions face the same yardstick.

**Four cells.** The target set is split by how the model's raw name strings compare with the two human transcriptions, using the Section 2 definitions:
1. The model's name matches Ancestry's only.
2. It matches FamilySearch's only.
3. It is complete and matches neither.
4. There is no model output in one or both name fields.

Two small residual groups (741 records, and 205,143 records "not classified", 1.4%) are reported but left out of the by-cell table.

## Things I would like you to check specifically

1. **The cell 1 paragraph.** In cell 1, our names link 21.4% of records at 83.0% validated; FamilySearch's 1940 names link 13.0% at 67.8%. The text says: "On these records FamilySearch's reading is the less useful of the two for linkage, and our model, which reads the image without seeing either human transcription, arrives at the more useful one." Is this supported? Is it over-sold?
   - A possible concern: cell 1 is defined by the model agreeing with Ancestry, so Ours ≈ Ancestry there by construction. The informative comparison is Ours/Ancestry against FamilySearch.
   - Another possible concern: is the Ancestry-initials comparison fair to FamilySearch in cell 1?
2. **The cell 3 paragraph,** where our model's reading matches neither human transcription. Our names raise linkage only from 6.7% to 8.9%; FamilySearch's 1940 names give 14.1%. Is the text honest about this without overstating either way?
3. **"Our transcriptions therefore deliver most of the gain in linkage that a second human transcription of the 1940 census provides on these records."** Arithmetic: (19.4 − 8.9) / (20.1 − 8.9) ≈ 94%.
4. **"This cell accounts for nearly all of our gain in linkage on the target set."** This is about cell 2. Arithmetic: (25.9 − 6.7) × 7.43M ≈ 1.43M of a total gain of (19.4 − 8.9)% × 14.42M ≈ 1.52M additional links, about 94%.
5. **The closing summary sentence.** It says our transcriptions do as well as FamilySearch's where they agree with it, better where they agree with Ancestry, and worse where they agree with neither. Is that a fair one-line summary of Table 11?
6. **Any number in the prose that does not match the tables below.**
7. **Interpretive risks.** For example:
   - selection into cells is not random, so the cells are not comparable to each other;
   - "share validated" with own initials mixes link quality with initial-reading differences;
   - FamilySearch-derived validation could be circular.
8. **Clarity of the table notes,** and whether a reader can tell what each column is.

Constraints, so you do not suggest them:
- Section 2 of the paper is not being edited.
- The model has not been applied to the 1930 census.
- The numbers come from generated files and are not to be hand-edited.

## The three tables (as they appear in the draft)

Table 9 ("Linkage with Ancestry, our, and FamilySearch transcriptions"), Table 10 ("Agreement of our transcription with the two human transcriptions, target set") and Table 11 ("... by agreement of our transcription with the human transcriptions"). The LaTeX tabulars follow, in that order.

```latex
\begin{tabular}{llccccc}
\toprule
 & & & & \multicolumn{3}{c}{FamilySearch names in} \\
\cmidrule(lr){5-7}
 & & Ancestry & Ours & 1930 \& 1940 & 1930 & 1940 \\
\midrule
Linkage rate (\%) & Target & 8.9 & 19.4 & 22.3 & 9.0 & 20.1 \\
 & All & 22.8 & 24.6 & 27.9 & 24.3 & 25.6 \\
\addlinespace
Share validated (\%) & Target & 65.4 & 83.6 & 83.7 & 65.3 & 83.4 \\
 & All & 86.0 & 87.1 & 87.9 & 86.1 & 87.9 \\
\quad links with both initials & Target & 308,513 & 618,732 & 743,260 & 329,561 & 651,573 \\
 & All & 2,512,418 & 2,665,324 & 3,160,041 & 2,752,524 & 2,817,937 \\
\addlinespace
Share validated, Ancestry initials (\%) & Target & 65.4 & 75.7 & 75.3 & 65.2 & 74.8 \\
 & All & 86.0 & 86.0 & 86.1 & 86.2 & 85.9 \\
\quad links with both initials & Target & 308,513 & 620,414 & 708,890 & 318,233 & 637,560 \\
 & All & 2,512,418 & 2,712,856 & 3,066,310 & 2,681,871 & 2,803,769 \\
\bottomrule
\end{tabular}
```

```latex
\begin{tabular}{lrc}
\toprule
 & Records & Share of target set (\%) \\
\midrule
1. Ours matches Ancestry's name only & 2,061,332 & 14.3 \\
2. Ours matches FamilySearch's name only & 7,428,567 & 51.5 \\
3. Ours is complete and matches neither & 3,465,034 & 24.0 \\
4. No model output in one or both name fields & 1,255,726 & 8.7 \\
\midrule
Discordant, but a human name field is empty & 741 & 0.0 \\
Not classified & 205,143 & 1.4 \\
\midrule
Target set & 14,416,543 & 100.0 \\
\bottomrule
\end{tabular}
```

```latex
\begin{tabular}{llccccc}
\toprule
 & & & & \multicolumn{3}{c}{FamilySearch names in} \\
\cmidrule(lr){5-7}
 & & Ancestry & Ours & 1930 \& 1940 & 1930 & 1940 \\
\midrule
\multicolumn{7}{l}{\textit{1. Ours matches Ancestry's name only (2,061,332 records, 14.3\% of target set)}} \\
Linkage rate (\%) &  & 21.6 & 21.4 & 14.2 & 22.8 & 13.0 \\
Share validated (\%) &  & 82.8 & 83.0 & 68.3 & 82.9 & 67.8 \\
\quad links with both initials &  & 98,918 & 98,195 & 71,274 & 108,493 & 63,211 \\
Share validated, Ancestry initials (\%) &  & 82.8 & 83.0 & 78.3 & 82.9 & 77.5 \\
\quad links with both initials &  & 98,918 & 98,204 & 72,294 & 105,482 & 66,119 \\
\midrule
\multicolumn{7}{l}{\textit{2. Ours matches FamilySearch's name only (7,428,567 records, 51.5\% of target set)}} \\
Linkage rate (\%) &  & 6.7 & 25.9 & 28.7 & 6.6 & 25.7 \\
Share validated (\%) &  & 53.0 & 87.5 & 87.8 & 52.2 & 87.6 \\
\quad links with both initials &  & 126,300 & 429,979 & 487,743 & 131,887 & 427,004 \\
Share validated, Ancestry initials (\%) &  & 53.0 & 76.1 & 76.6 & 51.9 & 76.2 \\
\quad links with both initials &  & 126,300 & 413,416 & 458,213 & 126,922 & 410,511 \\
\midrule
\multicolumn{7}{l}{\textit{3. Ours is complete and matches neither (3,465,034 records, 24.0\% of target set)}} \\
Linkage rate (\%) &  & 6.7 & 8.9 & 15.6 & 6.8 & 14.1 \\
Share validated (\%) &  & 59.8 & 63.9 & 76.3 & 59.5 & 76.1 \\
\quad links with both initials &  & 58,394 & 81,000 & 127,892 & 62,096 & 112,263 \\
Share validated, Ancestry initials (\%) &  & 59.8 & 64.8 & 68.9 & 59.4 & 68.4 \\
\quad links with both initials &  & 58,394 & 79,467 & 124,091 & 59,858 & 112,189 \\
\midrule
\multicolumn{7}{l}{\textit{4. No model output in one or both name fields (1,255,726 records, 8.7\% of target set)}} \\
Linkage rate (\%) &  & 6.9 & 8.4 & 16.4 & 7.1 & 15.0 \\
Share validated (\%) &  & 72.8 & 80.1 & 83.7 & 72.8 & 83.8 \\
\quad links with both initials &  & 22,061 & 9,531 & 49,812 & 24,044 & 43,406 \\
Share validated, Ancestry initials (\%) &  & 72.8 & 74.5 & 75.2 & 72.4 & 74.9 \\
\quad links with both initials &  & 22,061 & 26,489 & 48,080 & 23,060 & 43,111 \\
\bottomrule
\end{tabular}
```

## The new subsection, verbatim LaTeX (one sentence per line; table environments included)

```latex
\subsection{Comparison with a Second Human Transcription} \label{sec:fs_names}

Every record in our sample was transcribed twice, so a natural benchmark for our transcriptions is the second human transcription itself.
We therefore repeat the linkage behind Table \ref{tab:avg_performance} with FamilySearch's names in place of Ancestry's, holding the linking algorithm, the sample and the validation rule fixed.
FamilySearch's name is used wherever FamilySearch reports one and Ancestry's otherwise, field by field, and we make the substitution in the 1940 census alone, in the 1930 census alone, and in both.

Table \ref{tab:fs_versions} reports the results.
On the target set, FamilySearch's 1940 names link 20.1 percent of records, against 8.9 percent for Ancestry's and 19.4 percent for ours, and 83.4 percent of their links are validated, against 65.4 and 83.6 percent.
Our transcriptions therefore deliver most of the gain in linkage that a second human transcription of the 1940 census provides on these records, at the same share validated.
Substituting FamilySearch's names in both censuses raises the target-set linkage rate further, to 22.3 percent, a gain our transcriptions cannot yet match because we have not applied our model to the 1930 census.
Scored against Ancestry's middle initials in both censuses, so that every version is checked against the same initials, the share validated is 75.7 percent for our links and 74.8 percent for FamilySearch's 1940 links, against 65.4 percent for Ancestry's.

\begin{table}[H]
	\footnotesize
	\centering
	\begin{threeparttable}
		\setlength{\tabcolsep}{4pt}
		\caption{Linkage with Ancestry, our, and FamilySearch transcriptions}\label{tab:fs_versions}
		%GENERATED BY MATCHING/fs_avg_performance.do AND MATCHING/fs_draft_tables.py -- DO NOT EDIT THE NUMBERS BY HAND.
		\input{figures/fs_versions_allstates}
		\begin{tablenotes}
			\footnotesize
			\singlespacing
			\item Note: Sample, linking algorithm and definitions as in Table \ref{tab:avg_performance}: the target set is the 14,416,543 men aged 10 and above whose Ancestry and FamilySearch transcriptions of the 1940 name disagree, and all records are the 51,036,859 men aged 10 and above with all four name fields present. The Ancestry and Ours columns reproduce Table \ref{tab:avg_performance}. In the FamilySearch columns, each first and last name is taken from FamilySearch where FamilySearch reports it and from Ancestry otherwise, in the census years shown. Share validated scores each version against its own transcription of the middle initials; the Ancestry-initials rows score every version against Ancestry's middle initials in both census years.
		\end{tablenotes}
	\end{threeparttable}
\end{table}

These results do not mean that our model reproduces FamilySearch's transcription.
As Section \ref{sec:machine_learning} reports, on records where the two human transcriptions disagree our model's name matches Ancestry's in some cases, FamilySearch's in most, and neither in about a quarter.
Table \ref{tab:fs_cells_sizes} shows the same partition within the target set of our linkage sample, and Table \ref{tab:fs_cells} repeats the comparison of Table \ref{tab:fs_versions} within each cell.

The most informative cell is the first, the 14.3 percent of the target set where our model's reading coincides with Ancestry's rather than FamilySearch's.
There, Ancestry's names and ours link 21.6 and 21.4 percent of records, with 82.8 and 83.0 percent of links validated, while FamilySearch's 1940 names link only 13.0 percent, with 67.8 percent validated.
The gap persists when every version is scored against Ancestry's middle initials, at 83.0 percent for our links against 77.5 percent for FamilySearch's.
On these records FamilySearch's reading is the less useful of the two for linkage, and our model, which reads the image without seeing either human transcription, arrives at the more useful one.
In the second cell, half of the target set, our names coincide with FamilySearch's, and the two give nearly identical results: 25.9 and 25.7 percent linked, with 87.5 and 87.6 percent validated, against 6.7 and 53.0 percent for Ancestry's names.
This cell accounts for nearly all of our gain in linkage on the target set.

The third cell holds the records where our model returns a complete name that neither human transcriber gave.
Here our names raise the linkage rate only from 6.7 to 8.9 percent and the share validated from 59.8 to 63.9 percent, while FamilySearch's 1940 names link 14.1 percent with 76.1 percent validated.
A failure to link does not show that our reading is wrong, since the 1930 record may carry an error of its own, but where our transcription departs from both human readings it adds few links.
In the fourth cell the model produced no output for at least one name field, which our version fills from Ancestry's transcription, and its linkage rate stays close to Ancestry's, at 8.4 against 6.9 percent.

In short, our transcriptions do as well as FamilySearch's on the records where they agree with it, better on the records where they agree with Ancestry, and worse on the records where they agree with neither.

\begin{table}[H]
	\footnotesize
	\centering
	\begin{threeparttable}
		\caption{Agreement of our transcription with the two human transcriptions, target set}\label{tab:fs_cells_sizes}
		%GENERATED BY MATCHING/fs_cells.do AND MATCHING/fs_draft_tables.py -- DO NOT EDIT THE NUMBERS BY HAND.
		\input{figures/fs_cells_sizes_allstates}
		\begin{tablenotes}
			\footnotesize
			\singlespacing
			\item Note: The target set of Table \ref{tab:avg_performance}, partitioned by whether our transcription of the first and last name matches Ancestry's, FamilySearch's, neither, or is missing in one or both fields, using the definitions of Section \ref{sec:machine_learning}, which compare the raw name strings. Records whose raw Ancestry and FamilySearch strings agree, which cannot be matched to a transcribed record, or whose census identifier carries conflicting classifications are not classified.
		\end{tablenotes}
	\end{threeparttable}
\end{table}

\begin{table}[H]
	\footnotesize
	\centering
	\begin{threeparttable}
		\caption{Linkage with Ancestry, our, and FamilySearch transcriptions, by agreement of our transcription with the human transcriptions}\label{tab:fs_cells}
		%GENERATED BY MATCHING/fs_cells.do AND MATCHING/fs_draft_tables.py -- DO NOT EDIT THE NUMBERS BY HAND.
		\input{figures/fs_cells_allstates}
		\begin{tablenotes}
			\footnotesize
			\singlespacing
			\item Note: Columns and rows as in Table \ref{tab:fs_versions}, within the cells of Table \ref{tab:fs_cells_sizes}; the two residual groups of that table are omitted. In the fourth cell the share validated of our links rests on only 9,531 links with both initials in our own transcription, against 26,489 when scored against Ancestry's initials.
		\end{tablenotes}
	\end{threeparttable}
\end{table}

```

Please give your findings as a numbered list. For each one, quote the sentence or table cell, say what is wrong or risky, and propose replacement wording if relevant. Say explicitly if you think a claim should be dropped.
