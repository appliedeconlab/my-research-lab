// ==============================================================================
// SHORT-RUN ANALYSIS - DESCRIPTIVES AND DID ONLY
// ==============================================================================

clear all
set more off
* Sanitized: caller must run from repository root.

use "AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta", clear

// ==============================================================================
// SR: DESCRIPTIVE STATISTICS - FEMALE-HEADED HOUSEHOLDS
// ==============================================================================

* Before Tsunami - Female Headed - Expenditures
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 0 & female_headed == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("SR Female-Headed: Before Tsunami - Expenditures") ///
       export("SR_FemaleHeaded_Before_Expenditure.docx", replace)

* After Tsunami - Female Headed - Expenditures
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 1 & female_headed == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("SR Female-Headed: After Tsunami - Expenditures") ///
       export("SR_FemaleHeaded_After_Expenditure.docx", replace)

* Before Tsunami - Female Headed - Controls
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio ///
       Dwelling_Unit_new_* Religion_new_* Sector_* ///
       if after_tsunami == 0 & female_headed == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("SR Female-Headed: Before Tsunami - Controls") ///
       export("SR_FemaleHeaded_Before_Controls.docx", replace)

* After Tsunami - Female Headed - Controls
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio ///
       Dwelling_Unit_new_* Religion_new_* Sector_* ///
       if after_tsunami == 1 & female_headed == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("SR Female-Headed: After Tsunami - Controls") ///
       export("SR_FemaleHeaded_After_Controls.docx", replace)

// ==============================================================================
// SR: DESCRIPTIVE STATISTICS - MALE-HEADED HOUSEHOLDS
// ==============================================================================

* Before Tsunami - Male Headed - Expenditures
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 0 & female_headed == 0, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("SR Male-Headed: Before Tsunami - Expenditures") ///
       export("SR_MaleHeaded_Before_Expenditure.docx", replace)

* After Tsunami - Male Headed - Expenditures
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 1 & female_headed == 0, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("SR Male-Headed: After Tsunami - Expenditures") ///
       export("SR_MaleHeaded_After_Expenditure.docx", replace)

* Before Tsunami - Male Headed - Controls
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio ///
       Dwelling_Unit_new_* Religion_new_* Sector_* ///
       if after_tsunami == 0 & female_headed == 0, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("SR Male-Headed: Before Tsunami - Controls") ///
       export("SR_MaleHeaded_Before_Controls.docx", replace)

* After Tsunami - Male Headed - Controls
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio ///
       Dwelling_Unit_new_* Religion_new_* Sector_* ///
       if after_tsunami == 1 & female_headed == 0, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("SR Male-Headed: After Tsunami - Controls") ///
       export("SR_MaleHeaded_After_Controls.docx", replace)

// ==============================================================================
// SR: DESCRIPTIVE STATISTICS - HINDU HOUSEHOLDS
// ==============================================================================

* Hindu - Before
dtable Food_PC Fuel_PC Clothing_PC MPCE_Own ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       HH_Type_Agri Social_Group_new Ration_Type_new Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 0 & Religion_new == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("SR Hindu HH: Before Tsunami") ///
       export("SR_Hindu_Before.docx", replace)

* Hindu - After
dtable Food_PC Fuel_PC Clothing_PC MPCE_Own ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       HH_Type_Agri Social_Group_new Ration_Type_new Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 1 & Religion_new == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("SR Hindu HH: After Tsunami") ///
       export("SR_Hindu_After.docx", replace)

// ==============================================================================
// SR: DESCRIPTIVE STATISTICS - MUSLIM HOUSEHOLDS
// ==============================================================================

* Muslim - Before
dtable Food_PC Fuel_PC Clothing_PC MPCE_Own ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       HH_Type_Agri Social_Group_new Ration_Type_new Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 0 & Religion_new == 2, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("SR Muslim HH: Before Tsunami") ///
       export("SR_Muslim_Before.docx", replace)

* Muslim - After
dtable Food_PC Fuel_PC Clothing_PC MPCE_Own ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       HH_Type_Agri Social_Group_new Ration_Type_new Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 1 & Religion_new == 2, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("SR Muslim HH: After Tsunami") ///
       export("SR_Muslim_After.docx", replace)

// ==============================================================================
// SR: DID - FEMALE-HEADED HOUSEHOLDS
// ==============================================================================

capture file close ptfile
file open ptfile using "SR_DID_ByGender_Results.csv", write replace
file write ptfile "Gender,Variable,Controls,DiD_Coef,DiD_SE,DiD_PValue,PT_Chi2,PT_PValue,PT_Result,N,R2" _n

preserve
keep if female_headed == 1

foreach var in Food_PC Fuel_PC Clothing_PC MPCE_Own {
    
    * Without controls
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
    file write ptfile "Female,`var',No,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    
    * With controls
    quietly didregress (`var' $controls) (did_robust1), group(District) time(SubRound)
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
    file write ptfile "Female,`var',Yes,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
}

restore

// ==============================================================================
// SR: DID - MALE-HEADED HOUSEHOLDS
// ==============================================================================

preserve
keep if female_headed == 0

foreach var in Food_PC Fuel_PC Clothing_PC MPCE_Own {
    
    * Without controls
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
    file write ptfile "Male,`var',No,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    
    * With controls
    quietly didregress (`var' $controls) (did_robust1), group(District) time(SubRound)
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
    file write ptfile "Male,`var',Yes,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
}

restore
file close ptfile

// ==============================================================================
// SR: DID - HINDU HOUSEHOLDS
// ==============================================================================

capture file close relfile
file open relfile using "SR_DID_ByReligion_Results.csv", write replace
file write relfile "Religion,Variable,Controls,DiD_Coef,DiD_SE,DiD_PValue,PT_Chi2,PT_PValue,PT_Result,N,R2" _n

preserve
keep if Religion_new == 1

foreach var in Food_PC Fuel_PC Clothing_PC MPCE_Own {
    
    * Without controls
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
    
    * With controls (excluding Religion)
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

restore

// ==============================================================================
// SR: DID - MUSLIM HOUSEHOLDS
// ==============================================================================

preserve
keep if Religion_new == 2

foreach var in Food_PC Fuel_PC Clothing_PC MPCE_Own {
    
    * Without controls
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
    
    * With controls (excluding Religion)
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

restore
file close relfile

display "✓✓✓ SHORT-RUN ANALYSIS COMPLETE ✓✓✓"


// ==============================================================================
// LONG-RUN ANALYSIS - DESCRIPTIVES AND DID ONLY
// ==============================================================================

clear all
set more off
* Sanitized: caller must run from repository root.

use "AP_Aggregates_Merged_All_SubRound_Consistent_Sample.dta", clear


// ==============================================================================
// LR: DESCRIPTIVE STATISTICS - FEMALE-HEADED HOUSEHOLDS
// ==============================================================================

* Before Tsunami - Female Headed - Expenditures
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 0 & female_headed == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("LR Female-Headed: Before Tsunami - Expenditures") ///
       export("LR_FemaleHeaded_Before_Expenditure.docx", replace)

* After Tsunami - Female Headed - Expenditures
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 1 & female_headed == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("LR Female-Headed: After Tsunami - Expenditures") ///
       export("LR_FemaleHeaded_After_Expenditure.docx", replace)

* Before Tsunami - Female Headed - Controls
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio ///
       Dwelling_Unit_new_* Religion_new_* Sector_* ///
       if after_tsunami == 0 & female_headed == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("LR Female-Headed: Before Tsunami - Controls") ///
       export("LR_FemaleHeaded_Before_Controls.docx", replace)

* After Tsunami - Female Headed - Controls
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio ///
       Dwelling_Unit_new_* Religion_new_* Sector_* ///
       if after_tsunami == 1 & female_headed == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("LR Female-Headed: After Tsunami - Controls") ///
       export("LR_FemaleHeaded_After_Controls.docx", replace)

// ==============================================================================
// LR: DESCRIPTIVE STATISTICS - MALE-HEADED HOUSEHOLDS
// ==============================================================================

* Before Tsunami - Male Headed - Expenditures
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 0 & female_headed == 0, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("LR Male-Headed: Before Tsunami - Expenditures") ///
       export("LR_MaleHeaded_Before_Expenditure.docx", replace)

* After Tsunami - Male Headed - Expenditures
dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami == 1 & female_headed == 0, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("LR Male-Headed: After Tsunami - Expenditures") ///
       export("LR_MaleHeaded_After_Expenditure.docx", replace)

* Before Tsunami - Male Headed - Controls
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio ///
       Dwelling_Unit_new_* Religion_new_* Sector_* ///
       if after_tsunami == 0 & female_headed == 0, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("LR Male-Headed: Before Tsunami - Controls") ///
       export("LR_MaleHeaded_Before_Controls.docx", replace)

* After Tsunami - Male Headed - Controls
dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio ///
       Dwelling_Unit_new_* Religion_new_* Sector_* ///
       if after_tsunami == 1 & female_headed == 0, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("LR Male-Headed: After Tsunami - Controls") ///
       export("LR_MaleHeaded_After_Controls.docx", replace)

// ==============================================================================
// LR: DESCRIPTIVE STATISTICS - HINDU HOUSEHOLDS
// ==============================================================================

* Hindu - Before
dtable Food_PC Fuel_PC Clothing_PC MPCE_Own ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       HH_Type_Agri Social_Group_new Ration_Type_new Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 0 & Religion_new == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("LR Hindu HH: Before Tsunami") ///
       export("LR_Hindu_Before.docx", replace)

* Hindu - After
dtable Food_PC Fuel_PC Clothing_PC MPCE_Own ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       HH_Type_Agri Social_Group_new Ration_Type_new Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 1 & Religion_new == 1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("LR Hindu HH: After Tsunami") ///
       export("LR_Hindu_After.docx", replace)

// ==============================================================================
// LR: DESCRIPTIVE STATISTICS - MUSLIM HOUSEHOLDS
// ==============================================================================

* Muslim - Before
dtable Food_PC Fuel_PC Clothing_PC MPCE_Own ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       HH_Type_Agri Social_Group_new Ration_Type_new Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 0 & Religion_new == 2, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("LR Muslim HH: Before Tsunami") ///
       export("LR_Muslim_Before.docx", replace)

* Muslim - After
dtable Food_PC Fuel_PC Clothing_PC MPCE_Own ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dependency_Ratio female_headed ///
       HH_Type_Agri Social_Group_new Ration_Type_new Dwelling_Unit_new_* Sector_* ///
       if after_tsunami == 1 & Religion_new == 2, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("LR Muslim HH: After Tsunami") ///
       export("LR_Muslim_After.docx", replace)

// ==============================================================================
// LR: DID - FEMALE-HEADED HOUSEHOLDS
// ==============================================================================

capture file close ptfile2
file open ptfile2 using "LR_DID_ByGender_Results.csv", write replace
file write ptfile2 "Gender,Variable,Controls,DiD_Coef,DiD_SE,DiD_PValue,PT_Chi2,PT_PValue,PT_Result,N,R2" _n

preserve
keep if female_headed == 1

foreach var in Food_PC Fuel_PC Clothing_PC MPCE_Own {
    
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
    file write ptfile2 "Female,`var',No,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    
    quietly didregress (`var' $controls) (did_robust1), group(District) time(SubRound)
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
    file write ptfile2 "Female,`var',Yes,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
}

restore

// ==============================================================================
// LR: DID - MALE-HEADED HOUSEHOLDS
// ==============================================================================

preserve
keep if female_headed == 0

foreach var in Food_PC Fuel_PC Clothing_PC MPCE_Own {
    
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
    file write ptfile2 "Male,`var',No,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    
    quietly didregress (`var' $controls) (did_robust1), group(District) time(SubRound)
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
    file write ptfile2 "Male,`var',Yes,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
}

restore
file close ptfile2

// ==============================================================================
// LR: DID - HINDU HOUSEHOLDS
// ==============================================================================

capture file close relfile2
file open relfile2 using "LR_DID_ByReligion_Results.csv", write replace
file write relfile2 "Religion,Variable,Controls,DiD_Coef,DiD_SE,DiD_PValue,PT_Chi2,PT_PValue,PT_Result,N,R2" _n

preserve
keep if Religion_new == 1

foreach var in Food_PC Fuel_PC Clothing_PC MPCE_Own {
    
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
    file write relfile2 "Hindu,`var',No,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    
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
    file write relfile2 "Hindu,`var',Yes,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
}

restore

// ==============================================================================
// LR: DID - MUSLIM HOUSEHOLDS
// ==============================================================================

preserve
keep if Religion_new == 2

foreach var in Food_PC Fuel_PC Clothing_PC MPCE_Own {
    
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
    file write relfile2 "Muslim,`var',No,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
    
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
    file write relfile2 "Muslim,`var',Yes,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
}

restore
file close relfile2

display "✓✓✓ LONG-RUN ANALYSIS COMPLETE ✓✓✓"

// ==============================================================================
// FILES CREATED
// ==============================================================================

display _newline(2)
display "================================================================================"
display "FILES CREATED:"
display "================================================================================"
display ""
display "SHORT-RUN DESCRIPTIVES (12 files):"
display "  SR_FemaleHeaded_Before/After_Expenditure.docx"
display "  SR_FemaleHeaded_Before/After_Controls.docx"
display "  SR_MaleHeaded_Before/After_Expenditure.docx"
display "  SR_MaleHeaded_Before/After_Controls.docx"
display "  SR_Hindu_Before/After.docx"
display "  SR_Muslim_Before/After.docx"
display ""
display "SHORT-RUN DID (2 files):"
display "  SR_DID_ByGender_Results.csv"
display "  SR_DID_ByReligion_Results.csv"
display ""
display "LONG-RUN: Same structure with LR_ prefix"
display "================================================================================"
