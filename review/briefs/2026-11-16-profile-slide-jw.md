# Review brief: 'Agreement with FamilySearch profiles' slide, women and Jaro-Winkler added (2026-11-16)

The slide in the SSHA 2026 deck (paper repo D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex) now shows men (first name and surname) and women (first name only), exact agreement and mean Jaro-Winkler similarity, for Ancestry and Ours. Its numbers are copied from MATCHING/results/profile_names_jw.md, produced by MATCHING/profile_names_jw.do (run 2026-11-16, log MATCHING/profile_names_jw.log, CHECK PASSED). Men rows: section 'Men, death month on profile: first name and surname', columns exact Ancestry / ours+Anc and JW full name Ancestry / ours+Anc. Women rows: section 'Women, death month on profile: first name', columns exact first Ancestry / ours+Anc and JW first Ancestry / ours+Anc. Target = group disc, All = group all.

CHECK: (1) every number on the slide against profile_names_jw.md, including that the right columns (ours+Anc, not ours) and the JW full-name vs first-name columns were used; (2) that the slide text and its LaTeX comment describe the sample, the measures and 'Ours' as the code computes them; (3) that nothing overclaims, given the bias stated in MATCHING/profile_names_score.do:26-33; (4) that 'Jaro-Winkler' on the men's rows is clearly the full-name (mean of first and surname) measure, or flag it if a reader could not tell.

## Slide diff
```diff
diff --git a/slides_ssha2026.tex b/slides_ssha2026.tex
index d290d6b..3a3f5a1 100644
--- a/slides_ssha2026.tex
+++ b/slides_ssha2026.tex
@@ -333,29 +333,39 @@
 % ----
 
 \begin{frame}{Agreement with FamilySearch profiles}
-    % Numbers from fixing_transcription_errors MATCHING/results/profile_names.md (MATCHING/profile_names_score.do, run 2026-11-14/15),
-    % section "Death month on profile: men, first name and surname"; Target = group "disc", All = group "all".
-    % Sample: 1940 men, 49 model states, all four human name fields present, record attached one-to-one to a FamilySearch profile
-    % whose gender does not contradict census sex, profile has a death month and a usable first name and surname; all ages.
-    % "Ours" = raw model names (namefrst_ml, namelast_ml_ditto); a missing model name counts as not agreeing. NOT exactly the linkage's New,
-    % which falls back to Ancestry's field where the model's is missing (reviewed 2026-11-15; that version would score slightly higher).
+    % Numbers from fixing_transcription_errors MATCHING/results/profile_names_jw.md (MATCHING/profile_names_jw.do, run 2026-11-16),
+    % sections "Men, death month on profile: first name and surname" and "Women, death month on profile: first name";
+    % Target = group "disc", All = group "all"; columns Ancestry and ours+Anc (exact, and JW full name for men, JW first for women).
+    % Sample: 1940 records, 49 model states, all four human name fields present, attached one-to-one to a FamilySearch profile
+    % whose gender does not contradict census sex and which records a death month; all ages. Men: profile has a usable first name
+    % and surname, scored on both (JW = mean of first-name and surname JW). Women: usable profile first name, scored on first name only.
+    % "Ours" = model first name and ditto-resolved model surname, with Ancestry's field wherever the model's is empty (the linkage's New).
+    % Agree = normalised names identical; JW = Jaro-Winkler similarity (jarowinkler, ssc), 1 = identical.
     % Target = Ancestry and FamilySearch disagree on first or last name, as elsewhere.
     \begin{itemize}
-        \item 1940 men (all ages) attached to a FamilySearch family-tree profile that records a death month\vspace{0.3cm}
-        \item Share whose transcribed first name and surname both agree with the profile\vspace{0.3cm}
+        \item 1940 records attached to a FamilySearch family-tree profile with a death month
+        \item Men: first name and surname; women: first name only
+        \item Agree: names identical; Jaro-Winkler: similarity, 1 = identical
     \end{itemize}
     \begin{table}
-        \begin{tabular}{l r cc}
+        \small
+        \begin{tabular}{ll r cc cc}
             \toprule
-             & Records & Ancestry & Ours (model) \\
+             & & & \multicolumn{2}{c}{Agree} & \multicolumn{2}{c}{Jaro-Winkler} \\
+            \cmidrule(lr){4-5}\cmidrule(lr){6-7}
+             & & Records & Ancestry & Ours & Ancestry & Ours \\
             \midrule
-            Target records & 6,897,127  & 17.1\% & 47.7\% \\
-            All records    & 27,334,035 & 58.4\% & 62.4\% \\
+            Men   & Target & 6,897,127  & 17.1\% & 49.6\% & 0.904 & 0.935 \\
+                  & All    & 27,334,035 & 58.4\% & 64.1\% & 0.945 & 0.950 \\
+            \addlinespace
+            Women & Target & 6,250,365  & 53.0\% & 67.0\% & 0.894 & 0.916 \\
+                  & All    & 23,365,543 & 71.8\% & 74.9\% & 0.924 & 0.929 \\
             \bottomrule
         \end{tabular}
     \end{table}
     \begin{itemize}
-        \item Agreement, not accuracy: profiles are often built from FamilySearch's transcription, which favours names that agree with FamilySearch's, as ours often do
+        \item Ours: model names, Ancestry's where the model gave none
+        \item Agreement, not accuracy: profiles often draw on FamilySearch's transcription, which favours names that agree with it, as ours often do
     \end{itemize}
 \end{frame}
 
```
