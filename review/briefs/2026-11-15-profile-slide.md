# Review brief: new slide 'Agreement with FamilySearch profiles' (2026-11-15)

A slide was added to the SSHA 2026 deck (paper repo D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex). Its numbers are copied from MATCHING/results/profile_names.md, section 'Death month on profile: men, first name and surname' (Target = group disc, All = group all), produced by MATCHING/profile_names_score.do from MATCHING/profile_names_build.do.

CHECK: (1) every number on the slide against profile_names.md; (2) that the slide's description of the sample, the target definition and the 'Ours' column matches the code (profile_names_build.do, profile_names_score.do), and that 'Ours' is the same name set the linkage tables call New (MATCHING/1_divide_and_clean_everyoneV5_women_addedV2.do); (3) that no slide statement overclaims, given the known bias stated in profile_names_score.do:26-33.

## Slide diff
```diff
diff --git a/slides_ssha2026.tex b/slides_ssha2026.tex
index ed6ff09..3d1a3be 100644
--- a/slides_ssha2026.tex
+++ b/slides_ssha2026.tex
@@ -332,6 +332,33 @@
 
 % ----
 
+\begin{frame}{Agreement with FamilySearch profiles}
+    % Numbers from fixing_transcription_errors MATCHING/results/profile_names.md (MATCHING/profile_names_score.do, run 2026-11-14/15),
+    % section "Death month on profile: men, first name and surname"; Target = group "disc", All = group "all".
+    % Sample: 1940 men, 49 model states, all four human name fields present, record attached one-to-one to a FamilySearch profile
+    % whose gender does not contradict census sex, profile has a death month; all ages. "Ours" = model names on every record (the linkage's New).
+    % Target = Ancestry and FamilySearch disagree on first or last name, as elsewhere. A missing model name counts as not agreeing.
+    \begin{itemize}
+        \item 1940 men attached to a FamilySearch family-tree profile that records a death month\vspace{0.3cm}
+        \item Share whose transcribed first name and surname both agree with the profile\vspace{0.3cm}
+    \end{itemize}
+    \begin{table}
+        \begin{tabular}{l r cc}
+            \toprule
+             & Records & Ancestry & Ours \\
+            \midrule
+            Target records & 6,897,127  & 17.1\% & 47.7\% \\
+            All records    & 27,334,035 & 58.4\% & 62.4\% \\
+            \bottomrule
+        \end{tabular}
+    \end{table}
+    \begin{itemize}
+        \item Agreement, not accuracy: profiles are often built from FamilySearch's transcription, which favours names that agree with FamilySearch's, as ours often do
+    \end{itemize}
+\end{frame}
+
+% ----
+
 \begin{frame}{Linked sample creation}
     \begin{itemize}
         \item Linking algorithms: ABE and MLP\vspace{0.3cm}
```
