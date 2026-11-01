*==============================================================================
* ADDITIONAL HETEROGENEITY DID ANALYSES
* Dwelling Unit, Sector (Rural/Urban), Ration Type, Agricultural Household
*
* Drop-in extension of MPhil_Thesis_MASTER_Analysis.do
* Mirrors the existing gender/religion/social-group subsample loops exactly:
*   - didregress (outcome controls) (did_robust1), group(District) time(SubRound)
*   - district-clustered SEs (didregress default vce = cluster on group())
*   - controls drop the variable being subset on (and add female_headed,
*     consistent with controls_no_religion / controls_no_socialgroup)
*   - parallel-trends test via estat ptrends
* Output CSVs match SR/LR_DID_*_Results.csv column layout.
*
* RUN from the same working directory as the master do-file so the .dta files
* and the existing global $outcomes resolve. (Globals are re-declared below so
* this file can also be run standalone.)
*==============================================================================

* --- re-declare outcomes (same as master) --------------------------------
global outcomes Food_PC Fuel_PC Clothing_PC MPCE_Own

* --- subsample control sets: full controls MINUS the cut variable ----------
*     (female_headed added as a control, matching the religion/social macros)
global controls_no_dwelling  HH_Type_Agri Social_Group_new Ration_Type_new   ///
                             HHSize HH_AdultFemaleProp HH_Head_Age            ///
                             HH_Head_Education i.Religion_new i.Sector female_headed

global controls_no_sector    HH_Type_Agri Social_Group_new Ration_Type_new   ///
                             i.Dwelling_Unit_new HHSize HH_AdultFemaleProp    ///
                             HH_Head_Age HH_Head_Education i.Religion_new female_headed

global controls_no_ration    HH_Type_Agri Social_Group_new                   ///
                             i.Dwelling_Unit_new HHSize HH_AdultFemaleProp    ///
                             HH_Head_Age HH_Head_Education i.Religion_new      ///
                             i.Sector female_headed

global controls_no_agri      Social_Group_new Ration_Type_new                ///
                             i.Dwelling_Unit_new HHSize HH_AdultFemaleProp    ///
                             HH_Head_Age HH_Head_Education i.Religion_new      ///
                             i.Sector female_headed

*--- program: run all four heterogeneity cuts for one dataset/horizon -------
capture program drop het_did
program define het_did
    args dtafile prefix
    use "`dtafile'", clear

    * map each heterogeneity variable to its no-own-variable control macro
    foreach het in Dwelling_Unit_new Sector Ration_Type_new HH_Type_Agri {

        if      ("`het'"=="Dwelling_Unit_new") local ctrl "$controls_no_dwelling"
        else if ("`het'"=="Sector")            local ctrl "$controls_no_sector"
        else if ("`het'"=="Ration_Type_new")   local ctrl "$controls_no_ration"
        else if ("`het'"=="HH_Type_Agri")      local ctrl "$controls_no_agri"

        local fname "`prefix'_DID_`het'_Results.csv"
        capture file close hf
        file open hf using "`fname'", write replace
        file write hf "Group,GroupValue,GroupLabel,Variable,Controls,DiD_Coef,DiD_SE,DiD_PValue,PT_Chi2,PT_PValue,PT_Result,N,R2" _n

        display _newline(1)
        display "=== `prefix': `het' Heterogeneity DID ==="

        quietly levelsof `het', local(lvls)
        foreach L of local lvls {
            preserve
            keep if `het' == `L'
            local lbl : label (`het') `L'
            if ("`lbl'"=="") local lbl "`L'"
            display "  `het' = `L' (`lbl'): N = " _N

            foreach var in $outcomes {

                * ---- without controls ----
                quietly didregress (`var') (did_robust1), group(District) time(SubRound)
                matrix b = e(b)
                matrix V = e(V)
                local c  = b[1,1]
                local se = sqrt(V[1,1])
                local p  = 2*ttail(e(df_r), abs(`c'/`se'))
                local n  = e(N)
                local r2 = e(r2)
                quietly estat ptrends
                local ptc = r(chi2)
                local ptp = r(p)
                local ptr = cond(`ptp' > 0.05, "PASS", "FAIL")
                file write hf "`het',`L',`lbl',`var',No,`c',`se',`p',`ptc',`ptp',`ptr',`n',`r2'" _n
                display "    `var' (No Ctrl): DiD=" %7.2f (`c') " p=" %6.3f (`p')

                * ---- with controls (own variable dropped) ----
                quietly didregress (`var' `ctrl') (did_robust1), group(District) time(SubRound)
                matrix b = e(b)
                matrix V = e(V)
                local c  = b[1,1]
                local se = sqrt(V[1,1])
                local p  = 2*ttail(e(df_r), abs(`c'/`se'))
                local n  = e(N)
                local r2 = e(r2)
                quietly estat ptrends
                local ptc = r(chi2)
                local ptp = r(p)
                local ptr = cond(`ptp' > 0.05, "PASS", "FAIL")
                file write hf "`het',`L',`lbl',`var',Yes,`c',`se',`p',`ptc',`ptp',`ptr',`n',`r2'" _n
                display "    `var' (W Ctrl): DiD=" %7.2f (`c') " p=" %6.3f (`p')
            }
            restore
        }
        file close hf
        display "  -> wrote `fname'"
    }
end

*--- SHORT RUN -------------------------------------------------------------
het_did "AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta" "SR"

*--- LONG RUN --------------------------------------------------------------
het_did "AP_Aggregates_Merged_All_SubRound_Consistent_Sample.dta"    "LR"

display _newline(1)
display "DONE. New files: SR/LR_DID_{Dwelling_Unit_new,Sector,Ration_Type_new,HH_Type_Agri}_Results.csv"
*==============================================================================
