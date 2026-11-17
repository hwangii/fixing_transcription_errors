# Review brief: profile slide restricted to records with model names (2026-11-16)

At the author's request the slide 'Agreement with FamilySearch profiles' (paper repo slides_ssha2026.tex) now uses only records where our model produced every name scored (men: first name and surname; women: first name), with no Ancestry fallback. Numbers come from MATCHING/results/profile_names_jw.md, sections 'Men, death month on profile, model names present: first name and surname' and 'Women, death month on profile, model first name present: first name' (Target = disc, All = all; columns Ancestry and ours, exact and JW full name for men / JW first for women). Run 2026-11-16, log MATCHING/profile_names_jw.log, CHECK PASSED. After the run, MATCHING/profile_names_jw.do got two output-only edits (md sentence on group 4; '-' for empty cells); the md was edited by hand to match exactly what they would write.

CHECK: (1) every slide number against the md, right sections and columns; (2) slide text and comment match the code; (3) the two post-run edits change no number and the hand-edited md matches what the do-file would write; (4) no overclaim.

## Slide diff
```diff
diff --git a/slides_ssha2026.tex b/slides_ssha2026.tex
index ad82263..f12dee8 100644
--- a/slides_ssha2026.tex
+++ b/slides_ssha2026.tex
@@ -334,12 +334,15 @@
 
 \begin{frame}{Agreement with FamilySearch profiles}
     % Numbers from fixing_transcription_errors MATCHING/results/profile_names_jw.md (MATCHING/profile_names_jw.do, run 2026-11-16),
-    % sections "Men, death month on profile: first name and surname" and "Women, death month on profile: first name";
-    % Target = group "disc", All = group "all"; columns Ancestry and ours+Anc (exact, and JW full name for men, JW first for women).
+    % sections "Men, death month on profile, model names present: first name and surname" and
+    % "Women, death month on profile, model first name present: first name";
+    % Target = group "disc", All = group "all"; columns Ancestry and ours (exact, and JW full name for men, JW first for women).
+    % 2026-11-16, at the author's request: only records where the model produced every name scored (both names for men,
+    % first name for women); Ancestry is scored on the same records. No fallback to Ancestry.
     % Sample: 1940 records, 49 model states, all four human name fields present, attached one-to-one to a FamilySearch profile
     % whose gender does not contradict census sex and which records a death month; all ages. Men: profile has a usable first name
     % and surname, scored on both (JW = mean of first-name and surname JW). Women: usable profile first name, scored on first name only.
-    % "Ours" = model first name and ditto-resolved model surname, with Ancestry's field wherever the model's is empty (the linkage's New).
+    % "Ours" = model first name and ditto-resolved model surname.
     % Agree = normalised names identical; JW = Jaro-Winkler similarity (jarowinkler, ssc), 1 = identical.
     % Target = Ancestry and FamilySearch disagree on first or last name, as elsewhere; for women this includes records
     % whose first names agree and surnames differ, which is why Ancestry's women's target agreement is far above the men's.
@@ -356,16 +359,16 @@
             \cmidrule(lr){4-5}\cmidrule(lr){6-7}
              & & Records & Ancestry & Ours & Ancestry & Ours \\
             \midrule
-            Men   & Target & 6,897,127  & 17.1\% & 49.6\% & 0.904 & 0.935 \\
-                  & All    & 27,334,035 & 58.4\% & 64.1\% & 0.945 & 0.950 \\
+            Men   & Target & 6,344,776  & 17.0\% & 51.9\% & 0.906 & 0.939 \\
+                  & All    & 26,230,508 & 59.1\% & 65.0\% & 0.946 & 0.951 \\
             \addlinespace
-            Women & Target & 6,250,365  & 53.0\% & 67.0\% & 0.894 & 0.916 \\
-                  & All    & 23,365,543 & 71.8\% & 74.9\% & 0.924 & 0.929 \\
+            Women & Target & 6,020,539  & 53.7\% & 68.2\% & 0.896 & 0.919 \\
+                  & All    & 22,952,453 & 72.2\% & 75.4\% & 0.925 & 0.930 \\
             \bottomrule
         \end{tabular}
     \end{table}
     \begin{itemize}
-        \item Ours: model names, Ancestry's where the model gave none
+        \item Only records where our model produced every name compared
         \item Agreement, not accuracy: profiles often draw on FamilySearch's transcription, which ours often match
     \end{itemize}
 \end{frame}
```

## Script diff since last review
```diff
+	}
 	/*SURNAMES ARE SCORED FOR MEN ONLY.*/
 	replace cl_`s' = "" if !men
 	jwpair cl_`s' ref_last  jl_`s'
@@ -140,6 +145,15 @@ foreach s in anc fs ml mf {
 	drop cf_`s' cl_`s'
 }
 
+/*hasml (2026-11-16): THE MODEL PRODUCED EVERY NAME SCORED: FIRST NAME AND  */
+/*SURNAME FOR MEN, FIRST NAME FOR WOMEN. THE SLIDE USES THESE RECORDS ONLY.  */
+gen byte hasml = (men & hm_f & hm_l) | (wom & hm_f)
+drop hm_f hm_l
+count if men & has_dmonth & hasml
+display "men with a death month and model names: " r(N)
+count if wom & has_dmonth & hasml
+display "women with a death month and a model first name: " r(N)
+
 /*CHECK: EXACT AGREEMENT EQUALS profile_names.md, "Men: first name and      */
 /*surname" AND "Death month on profile: men, first name and surname".      */
 /*(sample, group, anc fs ml) as printed there, to one decimal.             */
@@ -180,9 +194,9 @@ capture file close md
 file open md using `"`md'"', write replace text
 file write md "# Jaro-Winkler similarity of 1940 transcriptions to FamilySearch profile names" _n _n
 file write md "Generated by MATCHING/profile_names_jw.do. Do not edit by hand." _n _n
-file write md "Mean Jaro-Winkler similarity (0 to 1; jarowinkler, prefix weight 0.1) between each source's name and the FamilySearch profile's, after the normalisation of MATCHING/profile_names_score.do. Sample: 1940 records in the 49 model states with all four human name fields present, attached one-to-one to a profile whose gender does not contradict the census sex. Men: profile has a usable first name and surname, scored on both (the 'first name and surname' sample of profile_names.md). Women: profile has a usable first name, scored on first names only, since a woman's profile surname may be her maiden or married name ('All women: first name'). The exact-agreement shares of profile_names.md are reproduced here as a check. Full name = mean of the first-name and surname similarities. A name the source does not have scores 0. Ours = the model's first name (namefrst_ml) and its surname with ditto marks resolved to the surname they refer to (namelast_ml_ditto), as in profile_names.md; no fallback to Ancestry. Ours+Anc = ours with Ancestry's name wherever the model field is empty, field by field, as the linkage tables' New transcription; group 4 (missing) refers to the model names alone. Agreement with a selected, FamilySearch-linked reference, not accuracy. Cell 0 = Ancestry and FamilySearch agree; 1-4 = they disagree and our name matches Ancestry's (1), FamilySearch's (2), neither (3), or is missing (4)." _n
+file write md "Mean Jaro-Winkler similarity (0 to 1; jarowinkler, prefix weight 0.1) between each source's name and the FamilySearch profile's, after the normalisation of MATCHING/profile_names_score.do. Sample: 1940 records in the 49 model states with all four human name fields present, attached one-to-one to a profile whose gender does not contradict the census sex. Men: profile has a usable first name and surname, scored on both (the 'first name and surname' sample of profile_names.md). Women: profile has a usable first name, scored on first names only, since a woman's profile surname may be her maiden or married name ('All women: first name'). The exact-agreement shares of profile_names.md are reproduced here as a check. Full name = mean of the first-name and surname similarities. A name the source does not have scores 0. Ours = the model's first name (namefrst_ml) and its surname with ditto marks resolved to the surname they refer to (namelast_ml_ditto), as in profile_names.md; no fallback to Ancestry. Sections marked 'model names present' keep only records where the model produced every name scored (both names for men, first name for women), so no source is scored on an empty model name; for men group 4 is then empty (shown as -), while for women it holds those whose model surname is missing, their first names being scored. Ours+Anc = ours with Ancestry's name wherever the model field is empty, field by field, as the linkage tables' New transcription; group 4 (missing) refers to the model names alone. Agreement with a selected, FamilySearch-linked reference, not accuracy. Cell 0 = Ancestry and FamilySearch agree; 1-4 = they disagree and our name matches Ancestry's (1), FamilySearch's (2), neither (3), or is missing (4)." _n
 
-foreach spec in "men&has_dmonth|Men, death month on profile: first name and surname" "men|Men, all profiles: first name and surname" "wom&has_dmonth|Women, death month on profile: first name" "wom|Women, all profiles: first name" {
+foreach spec in "men&has_dmonth&hasml|Men, death month on profile, model names present: first name and surname" "wom&has_dmonth&hasml|Women, death month on profile, model first name present: first name" "men&has_dmonth|Men, death month on profile: first name and surname" "men|Men, all profiles: first name and surname" "wom&has_dmonth|Women, death month on profile: first name" "wom|Women, all profiles: first name" {
 	gettoken cond title : spec, parse("|")
 	local title = substr("`title'", 2, .)
 	if strpos("`cond'", "men") & !strpos("`cond'", "wom") {
@@ -208,6 +222,7 @@ foreach spec in "men&has_dmonth|Men, death month on profile: first name and surn
 				quietly sum `m'_`s' if (`cond') & `gc'
 				if inlist("`m'","ex","xf") local v = string(100*r(mean), "%5.1f")
 				else           local v = string(r(mean), "%5.3f")
+				if r(N)==0 local v "-"
 				local row "`row' `v' |"
 			}
 		}
```
