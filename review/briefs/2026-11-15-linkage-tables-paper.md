# Review brief: paper and slides updated to the rebuilt linkage tables (2026-11-15)

Code commit 94a24c1 put the ABE/JW and HLINK tables on the main table's sample (1940 men 10+ with both an Ancestry and a FamilySearch transcription; target = Ancestry and FamilySearch disagree on first or last name; numerator restricted to the denominator; MI scored against each version's own 1940 initial). Machine B reran them (28af5f0, rc 0; the do-file exits 9 unless the ABE columns reproduce tab:avg_performance). The new tables were copied into the paper repo (D:/repos/6638fa0fd89fbec05130caeb/linkage_tables/), the tabulars extracted into figures/ by replication/extract_deaglan_tables.py, and the draft prose, table notes and slides updated by hand to the new numbers.

CHECK: every number in the draft/slides diff below against the NEW tables (section 2), that no sentence's claim (direction of change, 'all six columns', 'falls under all three algorithms', comparability) is false for the new numbers, and that the notes describe the sample and MI rule the code (LINKAGE/code/01_abe_jw/linkage_analysis.do, LINKAGE/code/02_hlink/linkage_analysis_newlinks.do) now uses. Contradicted share = contradicted/(verified+unverifiable+contradicted).

## 1. Paper-repo diff (draft, slides, README)

```diff
diff --git a/DHTS-2026-10-12.tex b/DHTS-2026-10-12.tex
index 2f54eec..8e49164 100644
--- a/DHTS-2026-10-12.tex
+++ b/DHTS-2026-10-12.tex
@@ -105,7 +105,7 @@ Third, we validate the links our transcriptions produce against a set of high-qu
 What this establishes is a claim about links rather than about names: no transcription is compared to a verified name anywhere in the exercise, so it speaks to whether the additional links are real, not to how accurate the underlying transcriptions are.
 The reference standard is also incomplete, covering roughly half of all linked pairs, so the remainder can be neither confirmed nor contradicted.
 It is also selected, since it covers only people whose genealogical profiles are attached to both censuses, a group that may under-represent the hard-to-read names our method targets.
-Among records where the two human transcriptions disagree, the number of links the genealogical data verify as correct rises from 523,399 to 1,320,314 and recall from 11.1 to 28.1 percent, while the share of links that the same data directly contradict falls in every specification we examine, from 5.13 to 2.59 percent on that sample under exact names and from 0.77 to 0.73 percent under the machine-learning linker.
+Among records where the two human transcriptions disagree, the number of links the genealogical data verify as correct rises from 523,091 to 1,319,555 and recall from 11.1 to 28.1 percent, while the share of links that the same data directly contradict falls in every specification we examine, from 5.09 to 2.56 percent on that sample under exact names and from 0.74 to 0.69 percent under the machine-learning linker.
 Our transcriptions thus recover links that genealogical evidence confirms faster than they add links it rejects; Section \ref{sec:algorithms} reports this for three linking algorithms.
 The gains carry over to linking the census to Social Security death records, where the number of links rises by 7.08 percent and the share whose middle initials agree rises with it (Section \ref{sec:mortality}).
 
@@ -563,12 +563,13 @@ Each is run twice over the full 1930--1940 universe, once on the Ancestry transc
 Tables \ref{tab:deaglan_abe_jw} and \ref{tab:deaglan_hlink} report the full sample; Tables \ref{tab:deaglan_abe_jw_restricted} and \ref{tab:deaglan_hlink_restricted} restrict to records whose two human transcriptions disagree, the set our method targets.
 
 The improvement survives every algorithm, and is largest where the transcription problem is most severe.
-On discordant records the exact-name algorithm links 8.6 percent of its denominator before our transcriptions and 18.7 percent after, a 118 percent increase that reproduces the 119 percent of Table \ref{tab:avg_performance} from an independent implementation on a different universe.
-Jaro-Winkler, which already tolerates small spelling differences and so has less to gain, rises from 14.9 to 22.1 percent.
-HLINK, which links roughly half of its population to begin with, rises from 49.7 to 56.5 percent.
+On discordant records the exact-name algorithm links 8.9 percent of its denominator before our transcriptions and 19.4 percent after, a 119 percent increase; these are the links and the sample of Table \ref{tab:avg_performance}, scored by separate code, and they reproduce its linkage rates and shares validated exactly.
+Jaro-Winkler, which already tolerates small spelling differences and so has less to gain, rises from 15.4 to 22.9 percent.
+HLINK, which links more than half of its population to begin with, rises from 53.8 to 61.8 percent.
 
 Link quality rises alongside quantity under all three.
-The share of links whose middle initials agree increases from 76.8 to 83.5 percent under exact names, from 79.7 to 83.8 percent under Jaro-Winkler, and from 82.7 to 83.4 percent under HLINK.
+The share of links whose middle initials agree increases from 65.4 to 83.6 percent under exact names, from 72.4 to 83.9 percent under Jaro-Winkler, and from 76.5 to 84.0 percent under HLINK.
+As in Table \ref{tab:avg_performance}, each version is scored against its own transcription of the 1940 middle initial, so part of each rise reflects our different reading of the initials rather than different links.
 That coverage and quality both improve under rules as different as exact string matching and a trained classifier is hard to reconcile with the gains being an artifact of any single linking rule.
 
 These tables also serve as our external validation, because the quality columns are not internal consistency checks but comparisons against evidence from outside the census: a set of high-quality genealogical links built from FamilySearch profiles, which we take as a reference standard.
@@ -578,17 +579,17 @@ FamilySearch users find the census records they attach through FamilySearch's ow
 Because our transcriptions agree with FamilySearch's far more often than with Ancestry's where the two disagree (Section \ref{sec:machine_learning}), any such dependence would tend to favor links built on our transcriptions over links built on Ancestry's.
 Each candidate link is classified by merging it against that standard, so a link is verified correct when the genealogical data confirm the same partner, directly contradicted when they name a different partner for either of its two people, and unverifiable when neither person appears there at all.
 This is what distinguishes genuine recovery from spurious matching: a method that merely loosened its criteria would add links the reference standard contradicts.
-Instead the verified-correct count rises in every column, from 523,399 to 1,320,314 on discordant records under exact names, and recall rises with it, from 11.1 to 28.1 percent, from 20.6 to 32.5 percent under Jaro-Winkler, and from 69.5 to 77.4 percent under HLINK.
-Links the reference standard directly contradicts require more care, because their count moves in both directions: in the full sample it falls under Jaro-Winkler and exact names, from 312,746 to 278,940 under Jaro-Winkler, but rises under HLINK, from 507,261 to 509,706, and on the discordant sample under exact names, from 65,907 to 72,769, and under HLINK, from 117,637 to 127,195.
+Instead the verified-correct count rises in every column, from 523,091 to 1,319,555 on discordant records under exact names, and recall rises with it, from 11.1 to 28.1 percent, from 20.6 to 32.5 percent under Jaro-Winkler, and from 72.7 to 81.6 percent under HLINK.
+Links the reference standard directly contradicts require more care, because their count moves in both directions: in the full sample it falls under all three algorithms, from 286,323 to 254,780 under Jaro-Winkler for example, but on the discordant sample it rises under exact names, from 65,137 to 71,662, and under HLINK, from 57,089 to 61,244.
 Taken alone those increases would be consistent with the new transcriptions buying coverage at the cost of accuracy.
-They are not, because the link counts grow far faster than the contradicted counts, so the share of links that the standard contradicts falls in all six columns of the four tables: from 2.47 to 2.07 percent under Jaro-Winkler and from 2.78 to 2.36 percent under exact names in the full sample, from 4.12 to 2.27 and from 5.13 to 2.59 percent on the discordant sample, and from 0.76 to 0.74 and from 0.77 to 0.73 percent under HLINK.
+They are not, because the link counts grow far faster than the contradicted counts, so the share of links that the standard contradicts falls in all six columns of the four tables: from 2.43 to 2.03 percent under Jaro-Winkler and from 2.74 to 2.32 percent under exact names in the full sample, from 4.08 to 2.24 and from 5.09 to 2.56 percent on the discordant sample, and from 0.70 to 0.68 and from 0.74 to 0.69 percent under HLINK.
 A given link in the improved sample is therefore less likely to be one the genealogical data reject, which is the sense in which the gains are not bought with spurious matches.
 
 Three features of these tables deserve emphasis, and apply to all four.
 First, the reported match rate is the number of linked pairs divided by the number of people in the denominator; because every link file is one-to-one in both census years, this is also the share of people who were linked.
 Second, a link is counted as directly contradicted when either of its two people appears in the genealogical truth set with a different partner, so only links neither of whose people appears there are recorded as unverifiable; because that set covers only part of the population, the contradicted column is still a lower bound on incorrect links and should not be read as a false-positive rate.
-Third, the denominators are not the same across tables: the ABE and Jaro-Winkler tables count men aged 8 and above, while the HLINK tables count men and women aged 8 and above, and both use an age cutoff of 8 rather than the cutoff of 10 used elsewhere in this paper.
-The three match rates are consequently not comparable to one another in levels, and we read only the before-and-after change within each column.
+Third, all four tables use the sample of Table \ref{tab:avg_performance}: the 51,036,859 men aged 10 and above in the 1940 census with all four name fields present, or the 14,416,543 of them whose two human transcriptions disagree, and only links whose 1940 record is in that sample are counted.
+The match rates are therefore comparable across the three algorithms in levels, and the exact-name columns reproduce Table \ref{tab:avg_performance}.
 
 \begin{table}[H]
 	\footnotesize
@@ -601,7 +602,7 @@ The three match rates are consequently not comparable to one another in levels,
 		\begin{tablenotes}
 			\footnotesize
 			\singlespacing
-			\item Note: Denominator is the 57,589,273 men aged 8 and above in the 1940 census. `Old' uses the Ancestry.com transcriptions distributed by IPUMS; `New' uses ours. Match rate is linked pairs divided by people in the denominator; the link files are one-to-one, so this is the share of people linked. Verified correct, unverifiable and directly contradicted are assessed against a set of high-quality FamilySearch genealogical links, matched on both the 1930 and the 1940 identifier; a link is unverifiable only when neither of its people appears in that set, so directly contradicted is a lower bound on incorrect links. Panel B decomposes the pairs added and removed when moving from the old transcription to the new.
+			\item Note: Denominator is the 51,036,859 men aged 10 and above in the 1940 census with all four name fields present, the sample of Table \ref{tab:avg_performance}; only links whose 1940 record is in this sample are counted. `Old' uses the Ancestry.com transcriptions distributed by IPUMS; `New' uses ours. Match rate is linked pairs divided by people in the denominator; the link files are one-to-one, so this is the share of people linked. MI match rate is the share of links with a middle initial in both censuses whose initials agree, scoring each version against its own transcription of the 1940 middle initial, as in Table \ref{tab:avg_performance}. Verified correct, unverifiable and directly contradicted are assessed against a set of high-quality FamilySearch genealogical links, matched on both the 1930 and the 1940 identifier; a link is unverifiable only when neither of its people appears in that set, so directly contradicted is a lower bound on incorrect links. Panel B decomposes the pairs added and removed when moving from the old transcription to the new.
 		\end{tablenotes}
 	\end{threeparttable}
 \end{table}
@@ -616,7 +617,7 @@ The three match rates are consequently not comparable to one another in levels,
 		\begin{tablenotes}
 			\footnotesize
 			\singlespacing
-			\item Note: As Table \ref{tab:deaglan_abe_jw}, but restricted throughout to the 15,003,537 men aged 8 and above whose Ancestry.com and FamilySearch.org transcriptions of the 1940 name disagree. This is the set our transcriptions are intended to improve.
+			\item Note: As Table \ref{tab:deaglan_abe_jw}, but restricted throughout to the 14,416,543 men aged 10 and above whose Ancestry.com and FamilySearch.org transcriptions of the 1940 name disagree. This is the set our transcriptions are intended to improve.
 		\end{tablenotes}
 	\end{threeparttable}
 \end{table}
@@ -627,13 +628,12 @@ The three match rates are consequently not comparable to one another in levels,
 	\begin{threeparttable}
 		\caption{Linkage quality under HLINK, old versus new transcription, 1930--1940}\label{tab:deaglan_hlink}
 		%TABULAR EXTRACTED MECHANICALLY from linkage_tables/linkage_table_hlink.tex.
-		%NB: that file's own caption says "all men in the 1940 census". It is wrong --
-		%the denominator is men AND women aged 8+. See PROVENANCE.md, Q3.
+		%Caption written here, not taken from that file: see linkage_tables/README.md.
 		\input{figures/deaglan_hlink}
 		\begin{tablenotes}
 			\footnotesize
 			\singlespacing
-			\item Note: HLINK is the machine-learning record linkage program distributed by IPUMS. Denominator is the 115,030,746 men and women aged 8 and above in the 1940 census, a wider population than that of Table \ref{tab:deaglan_abe_jw}, so the match rates are not comparable across the two tables in levels. Only linked pairs whose 1940 record is in this population are counted. Other definitions as in Table \ref{tab:deaglan_abe_jw}.
+			\item Note: HLINK is the machine-learning record linkage program distributed by IPUMS. Denominator and definitions as in Table \ref{tab:deaglan_abe_jw}.
 		\end{tablenotes}
 	\end{threeparttable}
 \end{table}
@@ -648,7 +648,7 @@ The three match rates are consequently not comparable to one another in levels,
 		\begin{tablenotes}
 			\footnotesize
 			\singlespacing
-			\item Note: As Table \ref{tab:deaglan_hlink}, but restricted throughout to the 30,754,309 men and women aged 8 and above whose Ancestry.com and FamilySearch.org transcriptions of the 1940 name disagree.
+			\item Note: As Table \ref{tab:deaglan_hlink}, but restricted throughout to the 14,416,543 men aged 10 and above whose Ancestry.com and FamilySearch.org transcriptions of the 1940 name disagree.
 		\end{tablenotes}
 	\end{threeparttable}
 \end{table}
@@ -740,7 +740,7 @@ With our transcriptions the number of exact matches rises from 5,658,793 to 6,05
 Under the conservative variant the linkage rate rises from 20.22 to 21.79 percent.
 Quality rises with quantity: among links with a middle initial recorded in both sources, about a quarter of all links, the share whose initials agree increases from 83.14 to 85.33 percent for exact matches and from 87.60 to 89.36 percent for conservative ones.
 Because middle initials play no part in the matching, this is an out-of-sample check on the quality of the linked sample as a whole; it is computed over all links with initials in both sources, not over the additional links alone.
-The denominator differs from those of Tables \ref{tab:deaglan_abe_jw} to \ref{tab:deaglan_hlink_restricted}, so the levels are not comparable across tables; as there, we read only the change from the old transcription to the new.
+The denominator differs from those of Tables \ref{tab:deaglan_abe_jw} to \ref{tab:deaglan_hlink_restricted}, so the levels are not comparable across tables, and we read only the change from the old transcription to the new.
 
 \begin{table}[H]
 	\footnotesize
diff --git a/linkage_tables/README.md b/linkage_tables/README.md
index 8c32856..e365542 100644
--- a/linkage_tables/README.md
+++ b/linkage_tables/README.md
@@ -45,3 +45,22 @@ link counts, match rates and middle-initial rows are unchanged, and the
 mortality table is byte-identical. The exact-name ABE columns reproduce machine
 A's independent scoring (`MATCHING/score_fs_links.do`) exactly. See the code
 repo's `LINKAGE/notes/truth_file_provenance.md`.
+
+## 2026-11-15: the main table's sample
+
+The four census-to-census tables now use the sample and definitions of the
+draft's main table (`tab:avg_performance`), code repo commit `94a24c1`, rerun
+on machine B (`28af5f0`):
+
+- denominator: 1940 men aged 10+ with both an Ancestry and a FamilySearch
+  transcription (51,036,859; 14,416,543 where the two disagree), from
+  `linkage_sample1940.dta` built on machine A. Was men aged 8+ (ABE/JW) and
+  men and women aged 8+ (HLINK);
+- target: Ancestry and FamilySearch disagree on the 1940 first or last name;
+- numerator: only links whose 1940 person is in the denominator, in every table;
+- MI match rate: each version scored against its own 1940 middle initial
+  (Ancestry's for Old, ours for New). Was ours for both.
+
+The ABE/JW do-file stops unless its ABE columns reproduce `tab:avg_performance`
+exactly; they do. The package captions are now correct, but the draft still
+writes its own. The mortality table is byte-identical.
diff --git a/slides_ssha2026.tex b/slides_ssha2026.tex
index 2a6de33..ed6ff09 100644
--- a/slides_ssha2026.tex
+++ b/slides_ssha2026.tex
@@ -370,7 +370,7 @@
 % ----
 
 \begin{frame}{Target records}
-    % Numbers from figures/deaglan_abe_jw_restricted.tex and figures/deaglan_hlink_restricted.tex (2026-11-09 tables; MLP = HLINK), counts rounded to thousands.
+    % Numbers from figures/deaglan_abe_jw_restricted.tex and figures/deaglan_hlink_restricted.tex (2026-11-15 tables: men 10+ with both transcriptions, each version's own 1940 MI; MLP = HLINK), counts rounded to thousands.
     \begin{table}
         \resizebox{1\linewidth}{!}{
         \begin{tabular}{l rrrr rr}
@@ -381,12 +381,12 @@
             \cmidrule(lr){2-3}\cmidrule(lr){4-5}
              & Old & New & Old & New & & \\
             \midrule
-            Match Rate (\%)       & 8.56 & 18.69 & 14.87 & 22.07 & 49.68 & 56.53 \\
-            MI Match Rate (\%)    & 76.81 & 83.51 & 79.65 & 83.83 & 82.73 & 83.39 \\
-            Verified Correct      & 523k & 1,320k & 968k & 1,527k & 6,206k & 6,905k \\
-            Unverifiable          & 695k & 1,412k & 1,171k & 1,709k & 8,954k & 10,352k \\
-            Directly Contradicted & 66k & 73k & 92k & 75k & 118k & 127k \\
-            Recall (\%)           & 11.13 & 28.07 & 20.58 & 32.47 & 69.52 & 77.35 \\
+            Match Rate (\%)       & 8.88 & 19.41 & 15.43 & 22.92 & 53.80 & 61.76 \\
+            MI Match Rate (\%)    & 65.41 & 83.60 & 72.39 & 83.91 & 76.54 & 84.04 \\
+            Verified Correct      & 523k & 1,320k & 968k & 1,527k & 3,417k & 3,835k \\
+            Unverifiable          & 692k & 1,408k & 1,166k & 1,704k & 4,282k & 5,007k \\
+            Directly Contradicted & 65k & 72k & 91k & 74k & 57k & 61k \\
+            Recall (\%)           & 11.13 & 28.07 & 20.58 & 32.47 & 72.68 & 81.58 \\
             \bottomrule
         \end{tabular}
         }
@@ -397,7 +397,7 @@
 % ----
 
 \begin{frame}{All records}
-    % Numbers from figures/deaglan_abe_jw.tex and figures/deaglan_hlink.tex (2026-11-09 tables; MLP = HLINK), counts rounded to thousands.
+    % Numbers from figures/deaglan_abe_jw.tex and figures/deaglan_hlink.tex (2026-11-15 tables: men 10+ with both transcriptions, each version's own 1940 MI; MLP = HLINK), counts rounded to thousands.
     \begin{table}
         \resizebox{1\linewidth}{!}{
         \begin{tabular}{l rrrr rr}
@@ -408,12 +408,12 @@
             \cmidrule(lr){2-3}\cmidrule(lr){4-5}
              & Old & New & Old & New & & \\
             \midrule
-            Match Rate (\%)       & 21.73 & 23.42 & 22.00 & 23.40 & 58.06 & 59.52 \\
-            MI Match Rate (\%)    & 86.27 & 87.00 & 86.25 & 87.00 & 86.11 & 86.34 \\
-            Verified Correct      & 6,284k & 6,794k & 6,319k & 6,730k & 28,787k & 29,301k \\
-            Unverifiable          & 5,883k & 6,376k & 6,039k & 6,469k & 37,488k & 38,661k \\
-            Directly Contradicted & 348k & 318k & 313k & 279k & 507k & 510k \\
-            Recall (\%)           & 31.79 & 34.37 & 31.97 & 34.04 & 78.48 & 79.88 \\
+            Match Rate (\%)       & 22.81 & 24.60 & 23.10 & 24.59 & 64.72 & 66.36 \\
+            MI Match Rate (\%)    & 85.99 & 87.14 & 85.94 & 87.14 & 86.33 & 87.25 \\
+            Verified Correct      & 5,931k & 6,416k & 5,965k & 6,358k & 15,569k & 15,855k \\
+            Unverifiable          & 5,394k & 5,849k & 5,539k & 5,938k & 17,231k & 17,782k \\
+            Directly Contradicted & 319k & 291k & 286k & 255k & 232k & 232k \\
+            Recall (\%)           & 31.69 & 34.28 & 31.87 & 33.97 & 83.18 & 84.72 \\
             \bottomrule
         \end{tabular}
         }
```

## 2. New tables (paper repo linkage_tables/)

### linkage_table_abe_jw.tex
```latex
\begin{table}[htbp]
\centering
\caption{Linkage Quality: Old vs.\ New Transcription, 1930--1940. Denominator is 1940 men aged 10 and above with both an Ancestry and a FamilySearch transcription. MI match rate scores each version against its own 1940 middle initial (Ancestry's for Old, ours for New), as in the main table.}
\label{tab:linkage_quality_full}
\begin{tabular}{lcccc}
\toprule
 & \multicolumn{2}{c}{Jaro-Winkler} & \multicolumn{2}{c}{ABE} \\
\cmidrule(lr){2-3}\cmidrule(lr){4-5}
 & Old & New & Old & New \\
\midrule
\multicolumn{5}{l}{\textit{Panel A: Coverage and Link Quality}} \\
Match Rate (\%)       & 23.10         & 24.59         & 22.81         & 24.60         \\
MI Match Rate (\%)    & 85.94      & 87.14      & 85.99      & 87.14      \\
Verified Correct      &    5,965,482     &    6,358,013     &    5,930,641     &    6,415,946     \\
Unverifiable          &    5,538,557 &    5,937,661 &    5,394,195 &    5,848,625 \\
Directly Contradicted &      286,323 &      254,780 &      318,863 &      290,975 \\
Recall (\%)           & 31.87       & 33.97       & 31.69       & 34.28       \\
\midrule
\multicolumn{5}{l}{\textit{Panel B: Net New Links (New Transcription vs.\ Old)}} \\
\multicolumn{5}{l}{\textit{\quad Added}} \\
\quad (Good) Verified Correct      & \multicolumn{2}{c}{  802,625 (43.8\%)}     & \multicolumn{2}{c}{1,021,087 (46.6\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{  959,160 (52.4\%)} & \multicolumn{2}{c}{1,096,767 (50.0\%)} \\
\quad (Bad) Directly Contradicted  & \multicolumn{2}{c}{   69,428 ( 3.8\%)} & \multicolumn{2}{c}{   74,387 ( 3.4\%)} \\
\multicolumn{5}{l}{\textit{\quad Removed}} \\
\quad (Bad) Verified Correct       & \multicolumn{2}{c}{  412,537 (38.5\%)}     & \multicolumn{2}{c}{  536,948 (41.9\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{  561,064 (52.4\%)} & \multicolumn{2}{c}{  642,990 (50.2\%)} \\
\quad (Good) Directly Contradicted & \multicolumn{2}{c}{   97,520 ( 9.1\%)} & \multicolumn{2}{c}{  100,456 ( 7.8\%)} \\
\bottomrule
\end{tabular}
\end{table}
```

### linkage_table_abe_jw_restricted.tex
```latex
\begin{table}[htbp]
\centering
\caption{Linkage Quality: Old vs.\ New Transcription, 1930--1940. Restricted to 1940 records where Ancestry and FamilySearch transcriptions disagree. Denominator is 1940 men aged 10 and above whose Ancestry and FamilySearch transcriptions disagree. MI match rate scores each version against its own 1940 middle initial (Ancestry's for Old, ours for New), as in the main table.}
\label{tab:linkage_quality_restr}
\begin{tabular}{lcccc}
\toprule
 & \multicolumn{2}{c}{Jaro-Winkler} & \multicolumn{2}{c}{ABE} \\
\cmidrule(lr){2-3}\cmidrule(lr){4-5}
 & Old & New & Old & New \\
\midrule
\multicolumn{5}{l}{\textit{Panel A: Coverage and Link Quality}} \\
Match Rate (\%)       & 15.43         & 22.92         &  8.88         & 19.41         \\
MI Match Rate (\%)    & 72.39      & 83.91      & 65.41      & 83.60      \\
Verified Correct      &      967,518     &    1,526,507     &      523,091     &    1,319,555     \\
Unverifiable          &    1,166,437 &    1,703,747 &      692,355 &    1,407,741 \\
Directly Contradicted &       90,834 &       74,110 &       65,137 &       71,662 \\
Recall (\%)           & 20.58       & 32.47       & 11.13       & 28.07       \\
\midrule
\multicolumn{5}{l}{\textit{Panel B: Net New Links (New Transcription vs.\ Old)}} \\
\multicolumn{5}{l}{\textit{\quad Added}} \\
\quad (Good) Verified Correct      & \multicolumn{2}{c}{  688,897 (45.2\%)}     & \multicolumn{2}{c}{  944,808 (48.2\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{  792,178 (52.0\%)} & \multicolumn{2}{c}{  966,500 (49.3\%)} \\
\quad (Bad) Directly Contradicted  & \multicolumn{2}{c}{   42,721 ( 2.8\%)} & \multicolumn{2}{c}{   49,794 ( 2.5\%)} \\
\multicolumn{5}{l}{\textit{\quad Removed}} \\
\quad (Bad) Verified Correct       & \multicolumn{2}{c}{  132,927 (29.9\%)}     & \multicolumn{2}{c}{  149,993 (33.9\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{  255,963 (57.6\%)} & \multicolumn{2}{c}{  251,798 (56.9\%)} \\
\quad (Good) Directly Contradicted & \multicolumn{2}{c}{   55,331 (12.5\%)} & \multicolumn{2}{c}{   40,936 ( 9.2\%)} \\
\bottomrule
\end{tabular}
\end{table}
```

### linkage_table_hlink.tex
```latex
\begin{table}[htbp]
\centering
\caption{Linkage Quality, HLINK Links: Old vs.\ New Transcription, 1930--1940. Denominator is 1940 men aged 10 and above with both an Ancestry and a FamilySearch transcription. MI match rate scores each version against its own 1940 middle initial (Ancestry's for Old, ours for New), as in the main table.}
\label{tab:linkage_quality_HLINK_full}
\begin{tabular}{lcc}
\toprule
 & \multicolumn{2}{c}{HLINK} \\
\cmidrule(lr){2-3}
 & Old & New \\
\midrule
\multicolumn{3}{l}{\textit{Panel A: Coverage and Link Quality}} \\
Match Rate (\%)       & 64.72         & 66.36         \\
MI Match Rate (\%)    & 86.33      & 87.25      \\
Verified Correct      &   15,568,832     &   15,855,350     \\
Unverifiable          &   17,230,855 &   17,782,327 \\
Directly Contradicted &      232,396 &      231,567 \\
Recall (\%)           & 83.18       & 84.72       \\
\midrule
\multicolumn{3}{l}{\textit{Panel B: Net New Links (New Transcription vs.\ Old)}} \\
\multicolumn{3}{l}{\textit{\quad Added}} \\
\quad (Good) Verified Correct      & \multicolumn{2}{c}{  653,860 (31.6\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{1,362,888 (65.9\%)} \\
\quad (Bad) Directly Contradicted  & \multicolumn{2}{c}{   50,355 ( 2.4\%)} \\
\multicolumn{3}{l}{\textit{\quad Removed}} \\
\quad (Bad) Verified Correct       & \multicolumn{2}{c}{  371,079 (30.2\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{  813,241 (66.1\%)} \\
\quad (Good) Directly Contradicted & \multicolumn{2}{c}{   45,622 ( 3.7\%)} \\
\bottomrule
\end{tabular}
\end{table}
```

### linkage_table_hlink_restricted.tex
```latex
\begin{table}[htbp]
\centering
\caption{Linkage Quality, HLINK Links: Old vs.\ New Transcription, 1930--1940. Restricted to 1940 records where Ancestry and FamilySearch transcriptions disagree. Denominator is 1940 men aged 10 and above whose Ancestry and FamilySearch transcriptions disagree. MI match rate scores each version against its own 1940 middle initial (Ancestry's for Old, ours for New), as in the main table.}
\label{tab:linkage_quality_HLINK_restr}
\begin{tabular}{lcc}
\toprule
 & \multicolumn{2}{c}{HLINK} \\
\cmidrule(lr){2-3}
 & Old & New \\
\midrule
\multicolumn{3}{l}{\textit{Panel A: Coverage and Link Quality}} \\
Match Rate (\%)       & 53.80         & 61.76         \\
MI Match Rate (\%)    & 76.54      & 84.04      \\
Verified Correct      &    3,417,186     &    3,835,344     \\
Unverifiable          &    4,282,465 &    5,007,075 \\
Directly Contradicted &       57,089 &       61,244 \\
Recall (\%)           & 72.68       & 81.58       \\
\midrule
\multicolumn{3}{l}{\textit{Panel B: Net New Links (New Transcription vs.\ Old)}} \\
\multicolumn{3}{l}{\textit{\quad Added}} \\
\quad (Good) Verified Correct      & \multicolumn{2}{c}{  552,442 (33.6\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{1,063,272 (64.6\%)} \\
\quad (Bad) Directly Contradicted  & \multicolumn{2}{c}{   30,476 ( 1.9\%)} \\
\multicolumn{3}{l}{\textit{\quad Removed}} \\
\quad (Bad) Verified Correct       & \multicolumn{2}{c}{  135,866 (27.2\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{  339,357 (68.0\%)} \\
\quad (Good) Directly Contradicted & \multicolumn{2}{c}{   24,044 ( 4.8\%)} \\
\bottomrule
\end{tabular}
\end{table}
```

## 3. Old tables (before this change), for the old-vs-new comparison

### linkage_table_abe_jw.tex (HEAD)
```latex
\begin{table}[htbp]
\centering
\caption{Linkage Quality: Old vs.\ New Transcription, 1930--1940. Denominator is all men in the 1940 census.}
\label{tab:linkage_quality_full}
\begin{tabular}{lcccc}
\toprule
 & \multicolumn{2}{c}{Jaro-Winkler} & \multicolumn{2}{c}{ABE} \\
\cmidrule(lr){2-3}\cmidrule(lr){4-5}
 & Old & New & Old & New \\
\midrule
\multicolumn{5}{l}{\textit{Panel A: Coverage and Link Quality}} \\
Match Rate (\%)       & 22.00         & 23.40         & 21.73         & 23.42         \\
MI Match Rate (\%)    & 86.25      & 87.00      & 86.27      & 87.00      \\
Verified Correct      &    6,318,838     &    6,729,814     &    6,283,801     &    6,794,104     \\
Unverifiable          &    6,039,021 &    6,469,478 &    5,883,324 &    6,375,502 \\
Directly Contradicted &      312,746 &      278,940 &      348,279 &      317,830 \\
Recall (\%)           & 31.97       & 34.04       & 31.79       & 34.37       \\
\midrule
\multicolumn{5}{l}{\textit{Panel B: Net New Links (New Transcription vs.\ Old)}} \\
\multicolumn{5}{l}{\textit{\quad Added}} \\
\quad (Good) Verified Correct      & \multicolumn{2}{c}{  848,742 (43.0\%)}     & \multicolumn{2}{c}{1,081,009 (45.8\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{1,049,082 (53.1\%)} & \multicolumn{2}{c}{1,199,711 (50.8\%)} \\
\quad (Bad) Directly Contradicted  & \multicolumn{2}{c}{   76,303 ( 3.9\%)} & \multicolumn{2}{c}{   81,640 ( 3.5\%)} \\
\multicolumn{5}{l}{\textit{\quad Removed}} \\
\quad (Bad) Verified Correct       & \multicolumn{2}{c}{  440,412 (37.8\%)}     & \multicolumn{2}{c}{  571,902 (41.1\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{  619,758 (53.1\%)} & \multicolumn{2}{c}{  708,243 (50.9\%)} \\
\quad (Good) Directly Contradicted & \multicolumn{2}{c}{  106,330 ( 9.1\%)} & \multicolumn{2}{c}{  110,183 ( 7.9\%)} \\
\bottomrule
\end{tabular}
\end{table}
```

### linkage_table_abe_jw_restricted.tex (HEAD)
```latex
\begin{table}[htbp]
\centering
\caption{Linkage Quality: Old vs.\ New Transcription, 1930--1940. Restricted to 1940 records where Ancestry and FamilySearch transcriptions disagree. Denominator is men in the 1940 census with discordant transcriptions.}
\label{tab:linkage_quality_restr}
\begin{tabular}{lcccc}
\toprule
 & \multicolumn{2}{c}{Jaro-Winkler} & \multicolumn{2}{c}{ABE} \\
\cmidrule(lr){2-3}\cmidrule(lr){4-5}
 & Old & New & Old & New \\
\midrule
\multicolumn{5}{l}{\textit{Panel A: Coverage and Link Quality}} \\
Match Rate (\%)       & 14.87         & 22.07         &  8.56         & 18.69         \\
MI Match Rate (\%)    & 79.65      & 83.83      & 76.81      & 83.51      \\
Verified Correct      &      968,151     &    1,527,466     &      523,399     &    1,320,314     \\
Unverifiable          &    1,170,727 &    1,708,674 &      694,933 &    1,411,579 \\
Directly Contradicted &       92,021 &       75,316 &       65,907 &       72,769 \\
Recall (\%)           & 20.58       & 32.47       & 11.13       & 28.07       \\
\midrule
\multicolumn{5}{l}{\textit{Panel B: Net New Links (New Transcription vs.\ Old)}} \\
\multicolumn{5}{l}{\textit{\quad Added}} \\
\quad (Good) Verified Correct      & \multicolumn{2}{c}{  689,284 (45.1\%)}     & \multicolumn{2}{c}{  945,322 (48.1\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{  794,656 (52.0\%)} & \multicolumn{2}{c}{  969,084 (49.3\%)} \\
\quad (Bad) Directly Contradicted  & \multicolumn{2}{c}{   43,413 ( 2.8\%)} & \multicolumn{2}{c}{   50,582 ( 2.6\%)} \\
\multicolumn{5}{l}{\textit{\quad Removed}} \\
\quad (Bad) Verified Correct       & \multicolumn{2}{c}{  133,009 (29.8\%)}     & \multicolumn{2}{c}{  150,060 (33.8\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{  257,802 (57.7\%)} & \multicolumn{2}{c}{  253,120 (56.9\%)} \\
\quad (Good) Directly Contradicted & \multicolumn{2}{c}{   55,985 (12.5\%)} & \multicolumn{2}{c}{   41,385 ( 9.3\%)} \\
\bottomrule
\end{tabular}
\end{table}
```

### linkage_table_hlink.tex (HEAD)
```latex
\begin{table}[htbp]
\centering
\caption{Linkage Quality, HLINK Links: Old vs.\ New Transcription, 1930--1940. Denominator is all men in the 1940 census.}
\label{tab:linkage_quality_HLINK_full}
\begin{tabular}{lcc}
\toprule
 & \multicolumn{2}{c}{HLINK} \\
\cmidrule(lr){2-3}
 & Old & New \\
\midrule
\multicolumn{3}{l}{\textit{Panel A: Coverage and Link Quality}} \\
Match Rate (\%)       & 58.06         & 59.52         \\
MI Match Rate (\%)    & 86.11      & 86.34      \\
Verified Correct      &   28,786,787     &   29,301,006     \\
Unverifiable          &   37,487,726 &   38,660,951 \\
Directly Contradicted &      507,261 &      509,706 \\
Recall (\%)           & 78.48       & 79.88       \\
\midrule
\multicolumn{3}{l}{\textit{Panel B: Net New Links (New Transcription vs.\ Old)}} \\
\multicolumn{3}{l}{\textit{\quad Added}} \\
\quad (Good) Verified Correct      & \multicolumn{2}{c}{1,152,356 (28.2\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{2,836,739 (69.4\%)} \\
\quad (Bad) Directly Contradicted  & \multicolumn{2}{c}{  100,205 ( 2.5\%)} \\
\multicolumn{3}{l}{\textit{\quad Removed}} \\
\quad (Bad) Verified Correct       & \multicolumn{2}{c}{  642,941 (26.8\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{1,666,815 (69.5\%)} \\
\quad (Good) Directly Contradicted & \multicolumn{2}{c}{   89,655 ( 3.7\%)} \\
\bottomrule
\end{tabular}
\end{table}
```

### linkage_table_hlink_restricted.tex (HEAD)
```latex
\begin{table}[htbp]
\centering
\caption{Linkage Quality, HLINK Links: Old vs.\ New Transcription, 1930--1940. Restricted to 1940 records where Ancestry and FamilySearch transcriptions disagree. Denominator is men in the 1940 census with discordant transcriptions.}
\label{tab:linkage_quality_HLINK_restr}
\begin{tabular}{lcc}
\toprule
 & \multicolumn{2}{c}{HLINK} \\
\cmidrule(lr){2-3}
 & Old & New \\
\midrule
\multicolumn{3}{l}{\textit{Panel A: Coverage and Link Quality}} \\
Match Rate (\%)       & 49.68         & 56.53         \\
MI Match Rate (\%)    & 82.73      & 83.39      \\
Verified Correct      &    6,206,332     &    6,904,891     \\
Unverifiable          &    8,954,224 &   10,351,822 \\
Directly Contradicted &      117,637 &      127,195 \\
Recall (\%)           & 69.52       & 77.35       \\
\midrule
\multicolumn{3}{l}{\textit{Panel B: Net New Links (New Transcription vs.\ Old)}} \\
\multicolumn{3}{l}{\textit{\quad Added}} \\
\quad (Good) Verified Correct      & \multicolumn{2}{c}{  926,571 (30.5\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{2,056,412 (67.6\%)} \\
\quad (Bad) Directly Contradicted  & \multicolumn{2}{c}{   59,650 ( 2.0\%)} \\
\multicolumn{3}{l}{\textit{\quad Removed}} \\
\quad (Bad) Verified Correct       & \multicolumn{2}{c}{  230,348 (24.6\%)}     \\
\quad (Neutral) Unverifiable       & \multicolumn{2}{c}{  659,984 (70.4\%)} \\
\quad (Good) Directly Contradicted & \multicolumn{2}{c}{   46,586 ( 5.0\%)} \\
\bottomrule
\end{tabular}
\end{table}
```
