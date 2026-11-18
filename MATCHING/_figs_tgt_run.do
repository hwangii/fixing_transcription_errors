/*TARGET-ONLY VERSIONS OF THE SLIDES' HETEROGENEITY FIGURES (2026-11-18).    */
/*Runs CODE/create_figures_SSHA2025.do and CODE/compute_legibility_quartiles.do*/
/*with "after" links = link1930_1940_mltgt1940 (our names on target records  */
/*only). Every output carries the suffix _tgt: figures/*_tgt.pdf and         */
/*avg_performance_allstates_tgt.tex in the paper repo, replication/results/  */
/**_tgt.tex, and temp_tgt.dta. The paper's files are not touched.            */
/*                                                                           */
/*  powershell -File replication/Run-Stata.ps1 MATCHING/_figs_tgt_run.do      */

if `"$REP_REPO"'=="" do "D:/repos/fixing_transcription_errors/replication/config.do"
global FIG_NEWLINKS mltgt1940
capture noisily {
	do "$REP_REPO/CODE/create_figures_SSHA2025.do"
	do "$REP_REPO/CODE/compute_legibility_quartiles.do"
}
local rc = _rc
global FIG_NEWLINKS
exit `rc'
