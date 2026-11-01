// ==============================================================================
// MASTER FILE: RELIGION HETEROGENEITY ANALYSIS
// ==============================================================================
// This master file runs the complete religion heterogeneity analysis for both
// Short-Run and Long-Run datasets, producing:
//   - 24 descriptive statistics Word documents (12 SR + 12 LR)
//   - 2 DiD results CSV files (1 SR + 1 LR)
// ==============================================================================
// Author: [Your Name]
// Date: December 2024
// ==============================================================================

clear all
set more off
* Sanitized: caller must run from repository root.

// ==============================================================================
// DEFINE GLOBAL MACROS
// ==============================================================================

// Full controls (includes religion - for gender analysis)
global controls HH_Type_Agri Social_Group_new Ration_Type_new ///
                HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
                Dependency_Ratio Dwelling_Unit_new_1 Dwelling_Unit_new_2 ///
                Religion_new_1 Religion_new_2 Religion_new_3 ///
                Sector_1 Sector_2

// Controls WITHOUT religion (for religion subsample analysis)
global controls_no_religion HH_Type_Agri Social_Group_new Ration_Type_new ///
                            HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
                            Dependency_Ratio Dwelling_Unit_new_1 Dwelling_Unit_new_2 ///
                            Sector_1 Sector_2 female_headed

// All expenditure variables for DiD analysis
global exp_vars Food Food_PC Fuel Fuel_PC Clothing Clothing_PC Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own

// Religion codes
// 1 = Hindu
// 2 = Muslim  
// 3 = Christian + Others

display _newline(3)
display "================================================================================"
display "         RELIGION HETEROGENEITY ANALYSIS - MASTER FILE"
display "================================================================================"
display ""
display "This analysis produces separate descriptive statistics and DiD estimates"
display "for THREE religion groups:"
display "  1. Hindu households (Religion_new == 1)"
display "  2. Muslim households (Religion_new == 2)"
display "  3. Christian + Others households (Religion_new == 3)"
display ""
display "================================================================================"

// ==============================================================================
// ==============================================================================
//                           PART 1: SHORT-RUN ANALYSIS
// ==============================================================================
// ==============================================================================

display _newline(3)
display "================================================================================"
display "                    PART 1: SHORT-RUN ANALYSIS"
display "================================================================================"

use "AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta", clear

// Sample size check
display _newline(2)
display "SHORT-RUN SAMPLE DISTRIBUTION BY RELIGION:"
tab Religion_new, missing
tab Religion_new robust_treat1, row
tab Religion_new after_tsunami, row

// ==============================================================================
// SR: HINDU HOUSEHOLDS - DESCRIPTIVE STATISTICS
// ==============================================================================

display _newline(2)
display "Processing: Hindu Households (Short-Run)..."

* Expenditures - Before
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 0 & Religion_new == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("SR Hindu HH: Before Tsunami - Expenditures") ///
       export("SR_Hindu_Before_Expenditure.docx", replace)

* Expenditures - After
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 1 & Religion_new == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("SR Hindu HH: After Tsunami - Expenditures") ///
       export("SR_Hindu_After_Expenditure.docx", replace)

* Controls - Before
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 0 & Religion_new == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("SR Hindu HH: Before Tsunami - Controls") ///
       export("SR_Hindu_Before_Controls.docx", replace)

* Controls - After
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 1 & Religion_new == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("SR Hindu HH: After Tsunami - Controls") ///
       export("SR_Hindu_After_Controls.docx", replace)

display "  ✓ Hindu household descriptives complete"

// ==============================================================================
// SR: MUSLIM HOUSEHOLDS - DESCRIPTIVE STATISTICS
// ==============================================================================

display _newline(1)
display "Processing: Muslim Households (Short-Run)..."

* Expenditures - Before
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 0 & Religion_new == 2, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("SR Muslim HH: Before Tsunami - Expenditures") ///
       export("SR_Muslim_Before_Expenditure.docx", replace)

* Expenditures - After
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 1 & Religion_new == 2, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("SR Muslim HH: After Tsunami - Expenditures") ///
       export("SR_Muslim_After_Expenditure.docx", replace)

* Controls - Before
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 0 & Religion_new == 2, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("SR Muslim HH: Before Tsunami - Controls") ///
       export("SR_Muslim_Before_Controls.docx", replace)

* Controls - After
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 1 & Religion_new == 2, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("SR Muslim HH: After Tsunami - Controls") ///
       export("SR_Muslim_After_Controls.docx", replace)

display "  ✓ Muslim household descriptives complete"

// ==============================================================================
// SR: CHRISTIAN + OTHERS HOUSEHOLDS - DESCRIPTIVE STATISTICS
// ==============================================================================

display _newline(1)
display "Processing: Christian+Others Households (Short-Run)..."

* Expenditures - Before
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 0 & Religion_new == 3, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("SR Christian+Others HH: Before Tsunami - Expenditures") ///
       export("SR_ChristianOthers_Before_Expenditure.docx", replace)

* Expenditures - After
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 1 & Religion_new == 3, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("SR Christian+Others HH: After Tsunami - Expenditures") ///
       export("SR_ChristianOthers_After_Expenditure.docx", replace)

* Controls - Before
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 0 & Religion_new == 3, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("SR Christian+Others HH: Before Tsunami - Controls") ///
       export("SR_ChristianOthers_Before_Controls.docx", replace)

* Controls - After
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 1 & Religion_new == 3, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("SR Christian+Others HH: After Tsunami - Controls") ///
       export("SR_ChristianOthers_After_Controls.docx", replace)

display "  ✓ Christian+Others household descriptives complete"

// ==============================================================================
// SR: DIFFERENCE-IN-DIFFERENCES ANALYSIS
// ==============================================================================

display _newline(2)
display "Running DiD Analysis (Short-Run)..."

capture file close relfile
file open relfile using "SR_DID_ByReligion_Results.csv", write replace
file write relfile "Religion,Variable,Controls,DiD_Coef,DiD_SE,DiD_PValue,PT_Chi2,PT_PValue,PT_Result,N,R2" _n

// ----- HINDU -----
preserve
keep if Religion_new == 1
display "  Hindu households: N = " _N

foreach var of global exp_vars {
    // Without controls
    capture {
        quietly didregress (`var') (did_robust1), group(District) time(SubRound)
        matrix b = e(b)
        matrix V = e(V)
        local did_coef = b[1,1]
        local did_se = sqrt(V[1,1])
        local did_p = 2*ttail(e(df_r), abs(`did_coef'/`did_se'))
        local n = e(N)
        local r2 = e(r2)
        quietly estat ptrends
        local pt_chi2 = r(chi2)
        local pt_p = r(p)
        local pt_result = cond(`pt_p' > 0.05, "PASS", "FAIL")
        file write relfile "Hindu,`var',No,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    }
    if _rc != 0 {
        file write relfile "Hindu,`var',No,.,.,.,.,.,FAILED,.,." _n
    }
    
    // With controls
    capture {
        quietly didregress (`var' $controls_no_religion) (did_robust1), group(District) time(SubRound)
        matrix b = e(b)
        matrix V = e(V)
        local did_coef = b[1,1]
        local did_se = sqrt(V[1,1])
        local did_p = 2*ttail(e(df_r), abs(`did_coef'/`did_se'))
        local n = e(N)
        local r2 = e(r2)
        quietly estat ptrends
        local pt_chi2 = r(chi2)
        local pt_p = r(p)
        local pt_result = cond(`pt_p' > 0.05, "PASS", "FAIL")
        file write relfile "Hindu,`var',Yes,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    }
    if _rc != 0 {
        file write relfile "Hindu,`var',Yes,.,.,.,.,.,FAILED,.,." _n
    }
}
restore
display "  ✓ Hindu DiD complete"

// ----- MUSLIM -----
preserve
keep if Religion_new == 2
display "  Muslim households: N = " _N

foreach var of global exp_vars {
    // Without controls
    capture {
        quietly didregress (`var') (did_robust1), group(District) time(SubRound)
        matrix b = e(b)
        matrix V = e(V)
        local did_coef = b[1,1]
        local did_se = sqrt(V[1,1])
        local did_p = 2*ttail(e(df_r), abs(`did_coef'/`did_se'))
        local n = e(N)
        local r2 = e(r2)
        quietly estat ptrends
        local pt_chi2 = r(chi2)
        local pt_p = r(p)
        local pt_result = cond(`pt_p' > 0.05, "PASS", "FAIL")
        file write relfile "Muslim,`var',No,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    }
    if _rc != 0 {
        file write relfile "Muslim,`var',No,.,.,.,.,.,FAILED,.,." _n
    }
    
    // With controls
    capture {
        quietly didregress (`var' $controls_no_religion) (did_robust1), group(District) time(SubRound)
        matrix b = e(b)
        matrix V = e(V)
        local did_coef = b[1,1]
        local did_se = sqrt(V[1,1])
        local did_p = 2*ttail(e(df_r), abs(`did_coef'/`did_se'))
        local n = e(N)
        local r2 = e(r2)
        quietly estat ptrends
        local pt_chi2 = r(chi2)
        local pt_p = r(p)
        local pt_result = cond(`pt_p' > 0.05, "PASS", "FAIL")
        file write relfile "Muslim,`var',Yes,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    }
    if _rc != 0 {
        file write relfile "Muslim,`var',Yes,.,.,.,.,.,FAILED,.,." _n
    }
}
restore
display "  ✓ Muslim DiD complete"

// ----- CHRISTIAN + OTHERS -----
preserve
keep if Religion_new == 3
display "  Christian+Others households: N = " _N

foreach var of global exp_vars {
    // Without controls
    capture {
        quietly didregress (`var') (did_robust1), group(District) time(SubRound)
        matrix b = e(b)
        matrix V = e(V)
        local did_coef = b[1,1]
        local did_se = sqrt(V[1,1])
        local did_p = 2*ttail(e(df_r), abs(`did_coef'/`did_se'))
        local n = e(N)
        local r2 = e(r2)
        quietly estat ptrends
        local pt_chi2 = r(chi2)
        local pt_p = r(p)
        local pt_result = cond(`pt_p' > 0.05, "PASS", "FAIL")
        file write relfile "ChristianOthers,`var',No,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    }
    if _rc != 0 {
        file write relfile "ChristianOthers,`var',No,.,.,.,.,.,FAILED,.,." _n
    }
    
    // With controls
    capture {
        quietly didregress (`var' $controls_no_religion) (did_robust1), group(District) time(SubRound)
        matrix b = e(b)
        matrix V = e(V)
        local did_coef = b[1,1]
        local did_se = sqrt(V[1,1])
        local did_p = 2*ttail(e(df_r), abs(`did_coef'/`did_se'))
        local n = e(N)
        local r2 = e(r2)
        quietly estat ptrends
        local pt_chi2 = r(chi2)
        local pt_p = r(p)
        local pt_result = cond(`pt_p' > 0.05, "PASS", "FAIL")
        file write relfile "ChristianOthers,`var',Yes,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    }
    if _rc != 0 {
        file write relfile "ChristianOthers,`var',Yes,.,.,.,.,.,FAILED,.,." _n
    }
}
restore
display "  ✓ Christian+Others DiD complete"

file close relfile

display _newline(1)
display "================================================================================"
display "✓✓✓ SHORT-RUN RELIGION HETEROGENEITY ANALYSIS COMPLETE ✓✓✓"
display "================================================================================"

// ==============================================================================
// ==============================================================================
//                           PART 2: LONG-RUN ANALYSIS
// ==============================================================================
// ==============================================================================

display _newline(3)
display "================================================================================"
display "                    PART 2: LONG-RUN ANALYSIS"
display "================================================================================"

use "AP_Aggregates_Merged_All_SubRound_Consistent_Sample.dta", clear

// Sample size check
display _newline(2)
display "LONG-RUN SAMPLE DISTRIBUTION BY RELIGION:"
tab Religion_new, missing
tab Religion_new robust_treat1, row
tab Religion_new after_tsunami, row

// ==============================================================================
// LR: HINDU HOUSEHOLDS - DESCRIPTIVE STATISTICS
// ==============================================================================

display _newline(2)
display "Processing: Hindu Households (Long-Run)..."

* Expenditures - Before
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 0 & Religion_new == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("LR Hindu HH: Before Tsunami - Expenditures") ///
       export("LR_Hindu_Before_Expenditure.docx", replace)

* Expenditures - After
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 1 & Religion_new == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("LR Hindu HH: After Tsunami - Expenditures") ///
       export("LR_Hindu_After_Expenditure.docx", replace)

* Controls - Before
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 0 & Religion_new == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("LR Hindu HH: Before Tsunami - Controls") ///
       export("LR_Hindu_Before_Controls.docx", replace)

* Controls - After
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 1 & Religion_new == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("LR Hindu HH: After Tsunami - Controls") ///
       export("LR_Hindu_After_Controls.docx", replace)

display "  ✓ Hindu household descriptives complete"

// ==============================================================================
// LR: MUSLIM HOUSEHOLDS - DESCRIPTIVE STATISTICS
// ==============================================================================

display _newline(1)
display "Processing: Muslim Households (Long-Run)..."

* Expenditures - Before
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 0 & Religion_new == 2, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("LR Muslim HH: Before Tsunami - Expenditures") ///
       export("LR_Muslim_Before_Expenditure.docx", replace)

* Expenditures - After
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 1 & Religion_new == 2, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("LR Muslim HH: After Tsunami - Expenditures") ///
       export("LR_Muslim_After_Expenditure.docx", replace)

* Controls - Before
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 0 & Religion_new == 2, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("LR Muslim HH: Before Tsunami - Controls") ///
       export("LR_Muslim_Before_Controls.docx", replace)

* Controls - After
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 1 & Religion_new == 2, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("LR Muslim HH: After Tsunami - Controls") ///
       export("LR_Muslim_After_Controls.docx", replace)

display "  ✓ Muslim household descriptives complete"

// ==============================================================================
// LR: CHRISTIAN + OTHERS HOUSEHOLDS - DESCRIPTIVE STATISTICS
// ==============================================================================

display _newline(1)
display "Processing: Christian+Others Households (Long-Run)..."

* Expenditures - Before
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 0 & Religion_new == 3, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("LR Christian+Others HH: Before Tsunami - Expenditures") ///
       export("LR_ChristianOthers_Before_Expenditure.docx", replace)

* Expenditures - After
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 1 & Religion_new == 3, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("LR Christian+Others HH: After Tsunami - Expenditures") ///
       export("LR_ChristianOthers_After_Expenditure.docx", replace)

* Controls - Before
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 0 & Religion_new == 3, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("LR Christian+Others HH: Before Tsunami - Controls") ///
       export("LR_ChristianOthers_Before_Controls.docx", replace)

* Controls - After
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 1 & Religion_new == 3, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("LR Christian+Others HH: After Tsunami - Controls") ///
       export("LR_ChristianOthers_After_Controls.docx", replace)

display "  ✓ Christian+Others household descriptives complete"

// ==============================================================================
// LR: DIFFERENCE-IN-DIFFERENCES ANALYSIS
// ==============================================================================

display _newline(2)
display "Running DiD Analysis (Long-Run)..."

capture file close relfile
file open relfile using "LR_DID_ByReligion_Results.csv", write replace
file write relfile "Religion,Variable,Controls,DiD_Coef,DiD_SE,DiD_PValue,PT_Chi2,PT_PValue,PT_Result,N,R2" _n

// ----- HINDU -----
preserve
keep if Religion_new == 1
display "  Hindu households: N = " _N

foreach var of global exp_vars {
    // Without controls
    capture {
        quietly didregress (`var') (did_robust1), group(District) time(SubRound)
        matrix b = e(b)
        matrix V = e(V)
        local did_coef = b[1,1]
        local did_se = sqrt(V[1,1])
        local did_p = 2*ttail(e(df_r), abs(`did_coef'/`did_se'))
        local n = e(N)
        local r2 = e(r2)
        quietly estat ptrends
        local pt_chi2 = r(chi2)
        local pt_p = r(p)
        local pt_result = cond(`pt_p' > 0.05, "PASS", "FAIL")
        file write relfile "Hindu,`var',No,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    }
    if _rc != 0 {
        file write relfile "Hindu,`var',No,.,.,.,.,.,FAILED,.,." _n
    }
    
    // With controls
    capture {
        quietly didregress (`var' $controls_no_religion) (did_robust1), group(District) time(SubRound)
        matrix b = e(b)
        matrix V = e(V)
        local did_coef = b[1,1]
        local did_se = sqrt(V[1,1])
        local did_p = 2*ttail(e(df_r), abs(`did_coef'/`did_se'))
        local n = e(N)
        local r2 = e(r2)
        quietly estat ptrends
        local pt_chi2 = r(chi2)
        local pt_p = r(p)
        local pt_result = cond(`pt_p' > 0.05, "PASS", "FAIL")
        file write relfile "Hindu,`var',Yes,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    }
    if _rc != 0 {
        file write relfile "Hindu,`var',Yes,.,.,.,.,.,FAILED,.,." _n
    }
}
restore
display "  ✓ Hindu DiD complete"

// ----- MUSLIM -----
preserve
keep if Religion_new == 2
display "  Muslim households: N = " _N

foreach var of global exp_vars {
    // Without controls
    capture {
        quietly didregress (`var') (did_robust1), group(District) time(SubRound)
        matrix b = e(b)
        matrix V = e(V)
        local did_coef = b[1,1]
        local did_se = sqrt(V[1,1])
        local did_p = 2*ttail(e(df_r), abs(`did_coef'/`did_se'))
        local n = e(N)
        local r2 = e(r2)
        quietly estat ptrends
        local pt_chi2 = r(chi2)
        local pt_p = r(p)
        local pt_result = cond(`pt_p' > 0.05, "PASS", "FAIL")
        file write relfile "Muslim,`var',No,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    }
    if _rc != 0 {
        file write relfile "Muslim,`var',No,.,.,.,.,.,FAILED,.,." _n
    }
    
    // With controls
    capture {
        quietly didregress (`var' $controls_no_religion) (did_robust1), group(District) time(SubRound)
        matrix b = e(b)
        matrix V = e(V)
        local did_coef = b[1,1]
        local did_se = sqrt(V[1,1])
        local did_p = 2*ttail(e(df_r), abs(`did_coef'/`did_se'))
        local n = e(N)
        local r2 = e(r2)
        quietly estat ptrends
        local pt_chi2 = r(chi2)
        local pt_p = r(p)
        local pt_result = cond(`pt_p' > 0.05, "PASS", "FAIL")
        file write relfile "Muslim,`var',Yes,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    }
    if _rc != 0 {
        file write relfile "Muslim,`var',Yes,.,.,.,.,.,FAILED,.,." _n
    }
}
restore
display "  ✓ Muslim DiD complete"

// ----- CHRISTIAN + OTHERS -----
preserve
keep if Religion_new == 3
display "  Christian+Others households: N = " _N

foreach var of global exp_vars {
    // Without controls
    capture {
        quietly didregress (`var') (did_robust1), group(District) time(SubRound)
        matrix b = e(b)
        matrix V = e(V)
        local did_coef = b[1,1]
        local did_se = sqrt(V[1,1])
        local did_p = 2*ttail(e(df_r), abs(`did_coef'/`did_se'))
        local n = e(N)
        local r2 = e(r2)
        quietly estat ptrends
        local pt_chi2 = r(chi2)
        local pt_p = r(p)
        local pt_result = cond(`pt_p' > 0.05, "PASS", "FAIL")
        file write relfile "ChristianOthers,`var',No,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    }
    if _rc != 0 {
        file write relfile "ChristianOthers,`var',No,.,.,.,.,.,FAILED,.,." _n
    }
    
    // With controls
    capture {
        quietly didregress (`var' $controls_no_religion) (did_robust1), group(District) time(SubRound)
        matrix b = e(b)
        matrix V = e(V)
        local did_coef = b[1,1]
        local did_se = sqrt(V[1,1])
        local did_p = 2*ttail(e(df_r), abs(`did_coef'/`did_se'))
        local n = e(N)
        local r2 = e(r2)
        quietly estat ptrends
        local pt_chi2 = r(chi2)
        local pt_p = r(p)
        local pt_result = cond(`pt_p' > 0.05, "PASS", "FAIL")
        file write relfile "ChristianOthers,`var',Yes,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    }
    if _rc != 0 {
        file write relfile "ChristianOthers,`var',Yes,.,.,.,.,.,FAILED,.,." _n
    }
}
restore
display "  ✓ Christian+Others DiD complete"

file close relfile

// ==============================================================================
// ==============================================================================
//                           FINAL SUMMARY
// ==============================================================================
// ==============================================================================

display _newline(3)
display "================================================================================"
display "================================================================================"
display "         ✓✓✓ ALL RELIGION HETEROGENEITY ANALYSES COMPLETE ✓✓✓"
display "================================================================================"
display "================================================================================"
display ""
display "FILES CREATED:"
display ""
display "SHORT-RUN DESCRIPTIVES (12 files):"
display "  HINDU:"
display "    - SR_Hindu_Before_Expenditure.docx"
display "    - SR_Hindu_After_Expenditure.docx"
display "    - SR_Hindu_Before_Controls.docx"
display "    - SR_Hindu_After_Controls.docx"
display ""
display "  MUSLIM:"
display "    - SR_Muslim_Before_Expenditure.docx"
display "    - SR_Muslim_After_Expenditure.docx"
display "    - SR_Muslim_Before_Controls.docx"
display "    - SR_Muslim_After_Controls.docx"
display ""
display "  CHRISTIAN+OTHERS:"
display "    - SR_ChristianOthers_Before_Expenditure.docx"
display "    - SR_ChristianOthers_After_Expenditure.docx"
display "    - SR_ChristianOthers_Before_Controls.docx"
display "    - SR_ChristianOthers_After_Controls.docx"
display ""
display "SHORT-RUN DiD RESULTS (1 file):"
display "    - SR_DID_ByReligion_Results.csv"
display ""
display "LONG-RUN DESCRIPTIVES (12 files):"
display "  Same structure as Short-Run with 'LR_' prefix"
display ""
display "LONG-RUN DiD RESULTS (1 file):"
display "    - LR_DID_ByReligion_Results.csv"
display ""
display "================================================================================"
display "TOTAL: 26 OUTPUT FILES"
display "================================================================================"
display ""
display "VARIABLES IN EXPENDITURE TABLES:"
display "  Food, Food_PC, Fuel, Fuel_PC, Clothing, Clothing_PC,"
display "  Footwear, Footwear_PC, Durable, Durable_PC, Misc, Misc_PC, MPCE_Own"
display ""
display "VARIABLES IN CONTROL TABLES:"
display "  HH_Type_Agri (Agricultural Household)"
display "  Social_Group_new (ST/SC/OBC)"
display "  Ration_Type_new (BPL/Antyodaya)"
display "  HHSize (Household Size)"
display "  HH_AdultFemaleProp (Adult Female Proportion)"
display "  HH_Head_Age (Head Age)"
display "  HH_Head_Education (Head Education)"
display "  Dependency_Ratio (Children + Elderly / Working Age)"
display "  female_headed (Female-Headed Household)"
display "  Dwelling_Unit_new_* (Dwelling Ownership)"
display "  Sector_* (Rural/Urban)"
display ""
display "VARIABLES IN DiD ANALYSIS:"
display "  Food_PC, Fuel_PC, Clothing_PC, Footwear_PC,"
display "  Durable_PC, Misc_PC, MPCE_Own"
display "================================================================================"
