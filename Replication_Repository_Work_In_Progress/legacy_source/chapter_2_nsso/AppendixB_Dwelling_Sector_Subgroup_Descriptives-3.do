*==============================================================================
* APPENDIX B: SUBGROUP DESCRIPTIVE TABLES FOR NEW HETEROGENEITY VARIABLES
* Dwelling Unit (Owned / Not-owned) and Sector (Rural / Urban)
* BOTH horizons: Short-Run (SR) and Long-Run (LR)
*
* Mirrors the Part 3 subgroup-descriptive blocks already in the master do-file
* (the gender / SC-ST / religion loops), so the exported tables match the
* format of the existing Appendix B tables B.5-B.8 cell-for-cell.
*
* For each subgroup x {Before, After} tsunami it produces a treatment-vs-control
* dtable of expenditures + household characteristics, which is
*   (a) echoed to a dedicated LOG FILE (one per horizon, created separately), and
*   (b) exported as a .docx Word table.
*==============================================================================

clear all
set more off
set linesize 255          // keep wide dtables from wrapping in the log

*------------------------------------------------------------------------------
* >>> SET THE DATA DIRECTORY <<<  (this fixes the r(601) "file not found" error)
* Point DATADIR to the folder that contains the .dta files -- the SAME folder
* the master do-file (MPhil_Thesis_MASTER_Analysis.do) is run from. The default
* below is taken from your master log; edit it if your data sit elsewhere.
*------------------------------------------------------------------------------
global DATADIR "."

capture cd "$DATADIR"
if _rc {
    display as error "----------------------------------------------------------------"
    display as error "Cannot change to the data folder:"
    display as error "    $DATADIR"
    display as error "Edit the 'global DATADIR' line at the top of this do-file."
    display as error "----------------------------------------------------------------"
    exit 170
}

* confirm the datasets are actually there before doing anything
foreach f in "AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta" ///
             "AP_Aggregates_Merged_All_SubRound_Consistent_Sample.dta" {
    capture confirm file "$DATADIR/`f'"
    if _rc {
        display as error "----------------------------------------------------------------"
        display as error "Data file not found in DATADIR:"
        display as error "    `f'"
        display as error "Check the 'global DATADIR' path at the top of this do-file."
        display as error "----------------------------------------------------------------"
        exit 601
    }
}

*------------------------------------------------------------------------------
* Program: run all dwelling & sector subgroup descriptives for one dataset,
*          writing its own separate log file named after the horizon.
*------------------------------------------------------------------------------
capture program drop appxB_desc
program define appxB_desc
    args dtafile horizon

    * ---- open a SEPARATE log file for this horizon --------------------------
    capture log close appxB
    log using "$DATADIR/AppendixB_Dwelling_Sector_`horizon'.log", replace text name(appxB)

    display _newline(2)
    display "=============================================================="
    display " APPENDIX B SUBGROUP DESCRIPTIVES  --  `horizon'"
    display " Data : `dtafile'"
    display " Start: $S_DATE $S_TIME"
    display "=============================================================="

    use "$DATADIR/`dtafile'", clear
    display ">>> `horizon' sample: N = " _N

    * ---- Dwelling Unit subgroups (1 = Owned, 2 = Not owned) -----------------
    * (dwelling indicator omitted from the table since it is constant within
    *  each subgroup; sector / religion / caste / gender shares retained)
    foreach dw in 1 2 {
        local dlabel = cond(`dw'==1, "Owned", "NotOwned")
        foreach period in 0 1 {
            local plabel = cond(`period'==0, "Before", "After")
            display _newline(1)
            display ">>> `horizon' Dwelling-`dlabel': `plabel' Tsunami"
            dtable Food_PC Fuel_PC Clothing_PC MPCE_Own                       ///
                   HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education     ///
                   female_headed Social_Group_new Religion_new_* Sector_*      ///
                   if after_tsunami == `period' & Dwelling_Unit_new == `dw',   ///
                   by(robust_treat1, tests testnotes totals)                   ///
                   sample(, statistic(frequency))                              ///
                   nformat(%9.3f mean sd)                                      ///
                   title("`horizon' Dwelling-`dlabel': `plabel' Tsunami")      ///
                   export("$DATADIR/`horizon'_Dwelling_`dlabel'_`plabel'.docx", replace)
        }
    }

    * ---- Sector subgroups (1 = Rural, 2 = Urban) ----------------------------
    * (sector indicator omitted; dwelling / religion / caste / gender retained)
    foreach sec in 1 2 {
        local slabel = cond(`sec'==1, "Rural", "Urban")
        foreach period in 0 1 {
            local plabel = cond(`period'==0, "Before", "After")
            display _newline(1)
            display ">>> `horizon' Sector-`slabel': `plabel' Tsunami"
            dtable Food_PC Fuel_PC Clothing_PC MPCE_Own                       ///
                   HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education     ///
                   female_headed Social_Group_new Religion_new_*               ///
                   Dwelling_Unit_new_*                                         ///
                   if after_tsunami == `period' & Sector == `sec',            ///
                   by(robust_treat1, tests testnotes totals)                   ///
                   sample(, statistic(frequency))                              ///
                   nformat(%9.3f mean sd)                                      ///
                   title("`horizon' Sector-`slabel': `plabel' Tsunami")        ///
                   export("$DATADIR/`horizon'_Sector_`slabel'_`plabel'.docx", replace)
        }
    }

    display _newline(2)
    display ">>> `horizon' DONE.  .docx files written to $DATADIR:"
    display "    `horizon'_Dwelling_{Owned,NotOwned}_{Before,After}.docx"
    display "    `horizon'_Sector_{Rural,Urban}_{Before,After}.docx"
    display " Finished: $S_DATE $S_TIME"

    * ---- close this horizon's log, then save it as PDF (optional) -----------
    log close appxB
    capture translate "$DATADIR/AppendixB_Dwelling_Sector_`horizon'.log" ///
                      "$DATADIR/AppendixB_Dwelling_Sector_`horizon'.pdf", replace
end

*------------------------------------------------------------------------------
* SHORT RUN  ->  AppendixB_Dwelling_Sector_SR.log  (+ SR_*.docx)
*------------------------------------------------------------------------------
appxB_desc "AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta" "SR"

*------------------------------------------------------------------------------
* LONG RUN   ->  AppendixB_Dwelling_Sector_LR.log  (+ LR_*.docx)
*------------------------------------------------------------------------------
appxB_desc "AP_Aggregates_Merged_All_SubRound_Consistent_Sample.dta" "LR"

display _newline(2)
display "=============================================================="
display " ALL APPENDIX B SUBGROUP DESCRIPTIVES COMPLETE (SR + LR)"
display " Separate logs (in $DATADIR):"
display "    AppendixB_Dwelling_Sector_SR.log"
display "    AppendixB_Dwelling_Sector_LR.log"
display " (PDF copies of each log are written alongside if translate works.)"
display "=============================================================="
*==============================================================================
