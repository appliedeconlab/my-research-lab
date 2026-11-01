// ==============================================================================
// HOUSEHOLD SIZE ROBUSTNESS ANALYSIS - CORRECTED CONTROL VARIABLES
// Using the correct variable names from the dataset
// ==============================================================================

clear all
set more off
* Sanitized: caller must run from repository root.

display "================================================================================"
display "HOUSEHOLD SIZE ROBUSTNESS ANALYSIS - CORRECTED VERSION"
display "================================================================================"

// ==============================================================================
// SECTION 1: DESCRIPTIVE STATISTICS - CAP AT 8 (SHORT-RUN)
// ==============================================================================

display _newline(2)
display "================================================================================"
display "TABLE 5: SHORT-RUN DESCRIPTIVE STATISTICS WITH HH SIZE CAP = 8"
display "================================================================================"

use "AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta", clear
keep if !missing(robust_treat1)

gen sample_cap8 = (HHSize <= 8)

quietly count
local n_total_sr = r(N)
quietly count if sample_cap8==1
local n_cap8_sr = r(N)
local excluded_sr = `n_total_sr' - `n_cap8_sr'

display ""
display "SHORT-RUN SAMPLE:"
display "  Total: " `n_total_sr'
display "  Cap ≤ 8: " `n_cap8_sr'
display "  Excluded: " `excluded_sr'

global expvars "MPCE_Own Food Food_PC Fuel Fuel_PC Clothing Clothing_PC Durable Durable_PC Misc Misc_PC HHSize"

dtable $expvars if after_tsunami==0 & sample_cap8==1, ///
    by(robust_treat1, tests testnotes totals) ///
    sample(, statistic(frequency)) ///
    nformat(%9.0f mean sd) ///
    title("Table 5: Before Tsunami - HH Size Cap 8") ///
    export("Table5_ShortRun_Before_Cap8.docx", replace)

dtable $expvars if after_tsunami==1 & sample_cap8==1, ///
    by(robust_treat1, tests testnotes totals) ///
    sample(, statistic(frequency)) ///
    nformat(%9.0f mean sd) ///
    title("Table 5: After Tsunami - HH Size Cap 8") ///
    export("Table5_ShortRun_After_Cap8.docx", replace)

display "✓ Table 5 exported"

// ==============================================================================
// SECTION 2: DESCRIPTIVE STATISTICS - CAP AT 8 (LONG-RUN)
// ==============================================================================

display _newline(2)
display "================================================================================"
display "TABLE 6: LONG-RUN DESCRIPTIVE STATISTICS WITH HH SIZE CAP = 8"
display "================================================================================"

use "AP_Aggregates_Merged_All_SubRound_Consistent_Sample.dta", clear
keep if !missing(robust_treat1)

gen sample_cap8 = (HHSize <= 8)

quietly count
local n_total_lr = r(N)
quietly count if sample_cap8==1
local n_cap8_lr = r(N)
local excluded_lr = `n_total_lr' - `n_cap8_lr'

display ""
display "LONG-RUN SAMPLE:"
display "  Total: " `n_total_lr'
display "  Cap ≤ 8: " `n_cap8_lr'
display "  Excluded: " `excluded_lr'

dtable $expvars if after_tsunami==0 & sample_cap8==1, ///
    by(robust_treat1, tests testnotes totals) ///
    sample(, statistic(frequency)) ///
    nformat(%9.0f mean sd) ///
    title("Table 6: Before Tsunami - HH Size Cap 8") ///
    export("Table6_LongRun_Before_Cap8.docx", replace)

dtable $expvars if after_tsunami==1 & sample_cap8==1, ///
    by(robust_treat1, tests testnotes totals) ///
    sample(, statistic(frequency)) ///
    nformat(%9.0f mean sd) ///
    title("Table 6: After Tsunami - HH Size Cap 8") ///
    export("Table6_LongRun_After_Cap8.docx", replace)

display "✓ Table 6 exported"

// ==============================================================================
// SECTION 3: T-TESTS FOR HOUSEHOLD SIZE IN CONTROL GROUP
// ==============================================================================

display _newline(2)
display "================================================================================"
display "CONTROL GROUP BALANCE TESTS - HOUSEHOLD SIZE"
display "================================================================================"

capture file close tfile
file open tfile using "Table8_10_HHSize_Balance_Tests.csv", write replace
file write tfile "Cap,Sample,N,Before_After_p,SR1_SR3_p,SR1_SR2_p,SR_Obs_Excluded,LR_Obs_Excluded" _n

local caps "Original 8 9 10 11 12 13"

foreach cap of local caps {
    
    display _newline "===== Household Size Cap: `cap' ====="
    
    // SHORT-RUN
    use "AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta", clear
    keep if !missing(robust_treat1)
    
    if "`cap'" != "Original" {
        keep if HHSize <= `cap'
    }
    
    quietly count
    local n_sr = r(N)
    local excl_sr = `n_total_sr' - `n_sr'
    
    quietly ttest HHSize if robust_treat1==0, by(after_tsunami)
    local p_ba = r(p)
    
    quietly ttest HHSize if robust_treat1==0 & (SubRound==1 | SubRound==3), by(SubRound)
    local p_sr13 = r(p)
    
    quietly ttest HHSize if robust_treat1==0 & (SubRound==1 | SubRound==2), by(SubRound)
    local p_sr12 = r(p)
    
    display "  Short-Run N: " `n_sr'
    display "  Balance tests: " %6.3f (`p_ba') ", " %6.3f (`p_sr13') ", " %6.3f (`p_sr12')
    
    // LONG-RUN
    use "AP_Aggregates_Merged_All_SubRound_Consistent_Sample.dta", clear
    keep if !missing(robust_treat1)
    
    if "`cap'" != "Original" {
        keep if HHSize <= `cap'
    }
    
    quietly count
    local n_lr = r(N)
    local excl_lr = `n_total_lr' - `n_lr'
    
    file write tfile "`cap',ShortRun,`n_sr'," %6.3f (`p_ba') "," %6.3f (`p_sr13') "," %6.3f (`p_sr12') ",`excl_sr',`excl_lr'" _n
}

file close tfile
display _newline "✓ Balance tests saved"

// ==============================================================================
// SECTION 4: SHORT-RUN DID ANALYSIS - TABLE 7 (Cap 8)
// CORRECTED: Merging with person_record.dta to get HH_AdultFemaleProp, HH_Head_Age, HH_Head_Education
// ==============================================================================

display _newline(2)
display "================================================================================"
display "TABLE 7: SHORT-RUN DID RESULTS (HH SIZE CAP = 8)"
display "================================================================================"

use "AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta", clear
merge 1:1 HHID using "person_record.dta"
keep if _merge==3
drop _merge
keep if !missing(robust_treat1)

// Create recoded control variables
gen HH_Type_Agri = (inlist(HH_Type, 12, 14))
gen Social_Group_new = (inlist(Social_Group, 1, 2, 3))
gen Ration_Type_new = (inlist(Ration_Type, 1, 2))
gen Religion_new = 1 if Religion == 1
replace Religion_new = 2 if Religion == 2
replace Religion_new = 3 if inlist(Religion, 3, 9)
gen Dwelling_Unit_new = 1 if Dwelling_Unit == 1
replace Dwelling_Unit_new = 2 if inlist(Dwelling_Unit, 2, 9)

// Ensure control variables are numeric
foreach var in HH_Head_Education HH_Head_Age HH_AdultFemaleProp {
    capture confirm numeric variable `var'
    if _rc {
        destring `var', replace force
    }
}

// NEW CONTROLS: Using HH_AdultFemaleProp, HH_Head_Age, HH_Head_Education
global xlist HH_Type_Agri Social_Group_new Ration_Type_new ///
             i.Dwelling_Unit_new HHSize HH_AdultFemaleProp ///
             HH_Head_Age HH_Head_Education i.Religion_new i.Sector

capture file close did7
file open did7 using "Table7_ShortRun_DID_Cap8.csv", write replace
file write did7 "Variable,Panel,ATET,SE,t_stat,p_value,PT_F,PT_p" _n

foreach var in Clothing Clothing_PC {
    
    display _newline "Analyzing: `var'"
    
    // Without Controls
    global ylist `var'
    quietly didregress ($ylist) (did_robust1) if HHSize<=8, group(District) time(SubRound)
    matrix b = e(b)
    matrix V = e(V)
    local atet_a = b[1,1]
    local se_a = sqrt(V[1,1])
    local t_a = `atet_a' / `se_a'
    local p_a = 2*ttail(e(df_r), abs(`t_a'))
    
    quietly estat ptrends
    local pt_f_a = r(F)
    local pt_p_a = r(p)
    
    file write did7 "`var',Without," %8.2f (`atet_a') "," %6.2f (`se_a') "," ///
                    %6.2f (`t_a') "," %6.3f (`p_a') "," %6.2f (`pt_f_a') "," %6.3f (`pt_p_a') _n
    
    display "  Without Controls: ATET=" %8.2f (`atet_a') " (SE=" %6.2f (`se_a') ", p=" %6.3f (`p_a') ")"
    
    // With Controls
    quietly didregress ($ylist $xlist) (did_robust1) if HHSize<=8, group(District) time(SubRound)
    matrix b = e(b)
    matrix V = e(V)
    local atet_b = b[1,1]
    local se_b = sqrt(V[1,1])
    local t_b = `atet_b' / `se_b'
    local p_b = 2*ttail(e(df_r), abs(`t_b'))
    
    quietly estat ptrends
    local pt_f_b = r(F)
    local pt_p_b = r(p)
    
    file write did7 "`var',With," %8.2f (`atet_b') "," %6.2f (`se_b') "," ///
                    %6.2f (`t_b') "," %6.3f (`p_b') "," %6.2f (`pt_f_b') "," %6.3f (`pt_p_b') _n
    
    display "  With Controls: ATET=" %8.2f (`atet_b') " (SE=" %6.2f (`se_b') ", p=" %6.3f (`p_b') ")"
}

file close did7
display "✓ Table 7 saved"

// ==============================================================================
// SECTION 5: SHORT-RUN DID - ALL CAPS (Table 8)
// ==============================================================================

display _newline(2)
display "================================================================================"
display "TABLE 8: SHORT-RUN DID (ALL CAPS) - Clothing_PC Only"
display "================================================================================"

use "AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta", clear
merge 1:1 HHID using "person_record.dta"
keep if _merge==3
drop _merge
keep if !missing(robust_treat1)

// Create recoded control variables
gen HH_Type_Agri = (inlist(HH_Type, 12, 14))
gen Social_Group_new = (inlist(Social_Group, 1, 2, 3))
gen Ration_Type_new = (inlist(Ration_Type, 1, 2))
gen Religion_new = 1 if Religion == 1
replace Religion_new = 2 if Religion == 2
replace Religion_new = 3 if inlist(Religion, 3, 9)
gen Dwelling_Unit_new = 1 if Dwelling_Unit == 1
replace Dwelling_Unit_new = 2 if inlist(Dwelling_Unit, 2, 9)

// Ensure control variables are numeric
foreach var in HH_Head_Education HH_Head_Age HH_AdultFemaleProp {
    capture confirm numeric variable `var'
    if _rc {
        destring `var', replace force
    }
}

global xlist HH_Type_Agri Social_Group_new Ration_Type_new ///
             i.Dwelling_Unit_new HHSize HH_AdultFemaleProp ///
             HH_Head_Age HH_Head_Education i.Religion_new i.Sector

capture file close did8
file open did8 using "Table8_ShortRun_DID_AllCaps.csv", write replace
file write did8 "Cap,N,ATET_NoControls,SE_NoControls,p_NoControls,ATET_Controls,SE_Controls,p_Controls,PT_p" _n

local caps "Original 8 9 10 11 12 13"

foreach cap of local caps {
    
    display _newline "===== Cap: `cap' ====="
    
    if "`cap'" == "Original" {
        local condition ""
        quietly count
        local n = r(N)
    }
    else {
        local condition "if HHSize <= `cap'"
        quietly count `condition'
        local n = r(N)
    }
    
    // Without Controls
    global ylist Clothing_PC
    quietly didregress ($ylist) (did_robust1) `condition', group(District) time(SubRound)
    matrix b = e(b)
    matrix V = e(V)
    local atet_nc = b[1,1]
    local se_nc = sqrt(V[1,1])
    local p_nc = 2*ttail(e(df_r), abs(`atet_nc'/`se_nc'))
    
    // With Controls
    quietly didregress ($ylist $xlist) (did_robust1) `condition', group(District) time(SubRound)
    matrix b = e(b)
    matrix V = e(V)
    local atet_c = b[1,1]
    local se_c = sqrt(V[1,1])
    local p_c = 2*ttail(e(df_r), abs(`atet_c'/`se_c'))
    
    quietly estat ptrends
    local pt_p = r(p)
    
    file write did8 "`cap',`n'," %8.2f (`atet_nc') "," %6.2f (`se_nc') "," %6.3f (`p_nc') "," ///
                    %8.2f (`atet_c') "," %6.2f (`se_c') "," %6.3f (`p_c') "," %6.3f (`pt_p') _n
    
    display "  Cap `cap': N=`n', ATET=" %8.2f (`atet_c') " (p=" %6.3f (`p_c') ")"
}

file close did8
display "✓ Table 8 saved"

// ==============================================================================
// SECTION 6: LONG-RUN DID - ALL CAPS (Table 9)
// ==============================================================================

display _newline(2)
display "================================================================================"
display "TABLE 9: LONG-RUN DID (ALL CAPS) - Clothing_PC Only"
display "================================================================================"

use "AP_Aggregates_Merged_All_SubRound_Consistent_Sample.dta", clear
merge 1:1 HHID using "person_record.dta"
keep if _merge==3
drop _merge
keep if !missing(robust_treat1)

// Create recoded control variables
gen HH_Type_Agri = (inlist(HH_Type, 12, 14))
gen Social_Group_new = (inlist(Social_Group, 1, 2, 3))
gen Ration_Type_new = (inlist(Ration_Type, 1, 2))
gen Dwelling_Unit_new = 1 if Dwelling_Unit == 1
replace Dwelling_Unit_new = 2 if inlist(Dwelling_Unit, 2, 9)

// Ensure control variables are numeric
foreach var in HH_Head_Education HH_Head_Age HH_AdultFemaleProp {
    capture confirm numeric variable `var'
    if _rc {
        destring `var', replace force
    }
}

// Long run controls (no Religion, no Sector)
global xlist HH_Type_Agri Social_Group_new Ration_Type_new ///
             i.Dwelling_Unit_new HHSize HH_AdultFemaleProp ///
             HH_Head_Age HH_Head_Education

capture file close did9
file open did9 using "Table9_LongRun_DID_AllCaps.csv", write replace
file write did9 "Cap,N,ATET_NoControls,SE_NoControls,p_NoControls,ATET_Controls,SE_Controls,p_Controls,PT_p" _n

local caps "Original 8 9 10 11 12 13"

foreach cap of local caps {
    
    display _newline "===== Cap: `cap' ====="
    
    if "`cap'" == "Original" {
        local condition ""
        quietly count
        local n = r(N)
    }
    else {
        local condition "if HHSize <= `cap'"
        quietly count `condition'
        local n = r(N)
    }
    
    // Without Controls
    global ylist Clothing_PC
    quietly didregress ($ylist) (did_robust1) `condition', group(District) time(SubRound)
    matrix b = e(b)
    matrix V = e(V)
    local atet_nc = b[1,1]
    local se_nc = sqrt(V[1,1])
    local p_nc = 2*ttail(e(df_r), abs(`atet_nc'/`se_nc'))
    
    // With Controls
    quietly didregress ($ylist $xlist) (did_robust1) `condition', group(District) time(SubRound)
    matrix b = e(b)
    matrix V = e(V)
    local atet_c = b[1,1]
    local se_c = sqrt(V[1,1])
    local p_c = 2*ttail(e(df_r), abs(`atet_c'/`se_c'))
    
    quietly estat ptrends
    local pt_p = r(p)
    
    file write did9 "`cap',`n'," %8.2f (`atet_nc') "," %6.2f (`se_nc') "," %6.3f (`p_nc') "," ///
                    %8.2f (`atet_c') "," %6.2f (`se_c') "," %6.3f (`p_c') "," %6.3f (`pt_p') _n
    
    display "  Cap `cap': N=`n', ATET=" %8.2f (`atet_c') " (p=" %6.3f (`p_c') ")"
}

file close did9
display "✓ Table 9 saved"

// ==============================================================================
// COMPLETION SUMMARY
// ==============================================================================

display _newline(3)
display "================================================================================"
display "✓✓✓ HOUSEHOLD SIZE ROBUSTNESS ANALYSIS COMPLETE ✓✓✓"
display "================================================================================"
display ""
display "FILES CREATED (8 total):"
display "------------------------"
display "DESCRIPTIVE STATISTICS:"
display "  1. Table5_ShortRun_Before_Cap8.docx"
display "  2. Table5_ShortRun_After_Cap8.docx"
display "  3. Table6_LongRun_Before_Cap8.docx"
display "  4. Table6_LongRun_After_Cap8.docx"
display ""
display "DID RESULTS:"
display "  5. Table7_ShortRun_DID_Cap8.csv"
display "  6. Table8_ShortRun_DID_AllCaps.csv"
display "  7. Table9_LongRun_DID_AllCaps.csv"
display "  8. Table8_10_HHSize_Balance_Tests.csv"
display ""
display "SAMPLE SIZES:"
display "  Short-Run Total: `n_total_sr'"
display "  Short-Run Cap ≤8: `n_cap8_sr' (Excluded: `excluded_sr')"
display "  Long-Run Total: `n_total_lr'"
display "  Long-Run Cap ≤8: `n_cap8_lr' (Excluded: `excluded_lr')"
display ""
display "CORRECTED CONTROL VARIABLES:"
display "  ✓ HH_Type_Agri (instead of i.HH_Type)"
display "  ✓ Social_Group_new (instead of i.Social_Group)"
display "  ✓ Ration_Type_new (instead of i.Ration_Type)"
display "  ✓ i.Dwelling_Unit_new (instead of i.Dwelling_Unit)"
display "  ✓ HH_AdultFemaleProp"
display "  ✓ HH_Head_Age"
display "  ✓ HH_Head_Education"
display "  ✓ i.Religion_new (short-run only)"
display ""
display "================================================================================"
