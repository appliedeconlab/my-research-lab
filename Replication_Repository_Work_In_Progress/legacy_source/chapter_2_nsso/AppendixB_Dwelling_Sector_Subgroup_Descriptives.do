*==============================================================================
* APPENDIX B: SUBGROUP DESCRIPTIVE TABLES FOR NEW HETEROGENEITY VARIABLES
* Dwelling Unit (Owned / Not-owned) and Sector (Rural / Urban)
*
* Mirrors the Part 3 subgroup-descriptive blocks already in the master do-file
* (the gender / SC-ST / religion loops), so the output .docx tables match the
* format of existing Appendix B tables B.5-B.8.
*
* Produces, for each subgroup x {Before, After} tsunami, a treatment-vs-control
* dtable of expenditures + household characteristics, exported to .docx and
* echoed to the log (so the numbers are visible if you send the log).
*
* Run from the master working directory (so the .dta files resolve).
*==============================================================================

display _newline(2)
display "--- Appendix B: Dwelling & Sector subgroup descriptives ---"

* Reload SR data (matches the Part 3 convention of SR-based appendix tables)
use "AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta", clear

* ---- Dwelling Unit subgroups (1 = Owned, 2 = Not owned) ---------------------
foreach dw in 1 2 {
    local dlabel = cond(`dw'==1, "Owned", "NotOwned")
    foreach period in 0 1 {
        local plabel = cond(`period'==0, "Before", "After")
        dtable Food_PC Fuel_PC Clothing_PC MPCE_Own                       ///
               HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education     ///
               female_headed Social_Group_new Religion_new_* Sector_*      ///
               if after_tsunami == `period' & Dwelling_Unit_new == `dw',   ///
               by(robust_treat1, tests testnotes totals)                   ///
               sample(, statistic(frequency))                              ///
               nformat(%9.3f mean sd)                                      ///
               title("SR Dwelling-`dlabel': `plabel' Tsunami")             ///
               export("SR_Dwelling_`dlabel'_`plabel'.docx", replace)
    }
}

* ---- Sector subgroups (1 = Rural, 2 = Urban) --------------------------------
foreach sec in 1 2 {
    local slabel = cond(`sec'==1, "Rural", "Urban")
    foreach period in 0 1 {
        local plabel = cond(`period'==0, "Before", "After")
        dtable Food_PC Fuel_PC Clothing_PC MPCE_Own                       ///
               HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education     ///
               female_headed Social_Group_new Religion_new_*               ///
               Dwelling_Unit_new_*                                         ///
               if after_tsunami == `period' & Sector == `sec',            ///
               by(robust_treat1, tests testnotes totals)                   ///
               sample(, statistic(frequency))                              ///
               nformat(%9.3f mean sd)                                      ///
               title("SR Sector-`slabel': `plabel' Tsunami")               ///
               export("SR_Sector_`slabel'_`plabel'.docx", replace)
    }
}

display _newline(1)
display "DONE. New .docx files: SR_Dwelling_{Owned,NotOwned}_{Before,After}.docx"
display "                       SR_Sector_{Rural,Urban}_{Before,After}.docx"
*==============================================================================
