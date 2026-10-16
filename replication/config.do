/*****************************************************************************/
/*REPLICATION PACKAGE CONFIGURATION -- THE ONE PLACE PATHS ARE SET.           */
/*                                                                           */
/*Run by replication/run_machineA.do. A script run on its own loads this     */
/*file itself if $REP_REPO is empty (globals survive `clear all`; tested on  */
/*Stata/MP 15.1, 2026-10-15).                                                */
/*                                                                           */
/*The analysis scripts in CODE/ still carry their own hardcoded data paths.  */
/*Those have NOT been rewritten to use the globals below -- CLAUDE.md asks   */
/*that path changes across files be agreed first. The globals here are used  */
/*by the package's own files and by the preflight check, which confirms that */
/*every frozen input the scripts read exists before anything runs.           */
/*****************************************************************************/

version 15.1

/*ONE BLOCK PER MACHINE. A machine with no block stops here, rather than     */
/*running with paths that silently point at nothing.                         */
if c(hostname) == "ARTS-ECON-CM" {
	global REP_MACHINE "A"
	global REP_REPO    "D:/repos/fixing_transcription_errors"
	global REP_PAPER   "D:/repos/6638fa0fd89fbec05130caeb"
	global REP_SNU     "D:/SNU ECON Dropbox/sam hwang"
	global REP_F       "F:"
}
else {
	display as error "replication/config.do: no paths for machine `c(hostname)'."
	display as error "Add a block for it at the top of this file."
	exit 198
}

global REP_RESULTS "$REP_REPO/replication/results"
adopath ++ "$REP_REPO/replication/stata"

/*`version` SET IN A DO-FILE REVERTS WHEN THAT FILE ENDS, SO THE ONE ABOVE  */
/*COVERS ONLY THIS FILE. run_machineA.do SETS IT FOR THE SCRIPTS. Results    */
/*were produced on Stata/MP 15.1; record what this run uses.                */
display as text "config: machine $REP_MACHINE (`c(hostname)'), Stata `c(stata_version)' `c(edition_real)', `c(current_date)' `c(current_time)'"
