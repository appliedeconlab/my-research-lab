// ==============================================================================
// DETERMINANTS OF CONSUMPTION EXPENDITURE ANALYSIS
// SHORT-RUN DATASET
// Focus: Cross-sectional determinants before and after tsunami
// ==============================================================================

clear all
set more off
* Sanitized: caller must run from repository root.

use "AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta", clear
merge 1:1 HHID using "person_record.dta"
keep if _merge==3
drop _merge
keep if !missing(robust_treat1)

display "================================================================================"
display "VARIABLE PREPARATION"
display "================================================================================"

foreach var in HH_Head_Education HH_Head_Age HH_AdultFemaleProp {
    capture confirm numeric variable `var'
    if _rc {
        destring `var', replace force
    }
}

capture drop ln_*
capture drop HH_Type_Agri Social_Group_new Ration_Type_new Religion_new Dwelling_Unit_new did_robust1
capture drop Dwelling_Unit_new_* Religion_new_* Sector_*

foreach var in Food Food_PC Fuel Fuel_PC Clothing Clothing_PC Footwear Footwear_PC ///
               Durable Durable_PC Misc Misc_PC MPCE_Own {
    capture confirm variable `var'
    if !_rc {
        gen ln_`var' = ln(`var' + 1)
        label var ln_`var' "Log(`var')"
    }
}

// UPDATED VARIABLE DEFINITIONS
gen HH_Type_Agri = (inlist(HH_Type, 12, 14))
label var HH_Type_Agri "Agricultural Household"

gen Social_Group_new = (inlist(Social_Group, 1, 2, 3))
label var Social_Group_new "ST/SC/OBC"

gen Ration_Type_new = (inlist(Ration_Type, 1, 2))
label var Ration_Type_new "BPL/Antyodaya"

gen Religion_new = 1 if Religion == 1
replace Religion_new = 2 if Religion == 2
replace Religion_new = 3 if inlist(Religion, 3, 9)
label var Religion_new "Religion"

gen Dwelling_Unit_new = 1 if Dwelling_Unit == 1
replace Dwelling_Unit_new = 2 if inlist(Dwelling_Unit, 2, 9)
label var Dwelling_Unit_new "Dwelling Unit"

tab Dwelling_Unit_new, gen(Dwelling_Unit_new_)
tab Religion_new, gen(Religion_new_)
tab Sector, gen(Sector_)

global controls HH_Type_Agri Social_Group_new Ration_Type_new ///
                i.Dwelling_Unit_new HHSize HH_AdultFemaleProp ///
                HH_Head_Age HH_Head_Education i.Religion_new i.Sector

display "✓ Variables created successfully"

// ==============================================================================
// DEFINE AND LABEL BASE CATEGORIES
// ==============================================================================

display _newline(2)
display "================================================================================"
display "BASE CATEGORY DEFINITIONS"
display "================================================================================"

// Label binary variables with clear base categories
label define agri_label 0 "Non-Agricultural (Base)" 1 "Agricultural Household"
label values HH_Type_Agri agri_label

label define social_label 0 "General/Others (Base)" 1 "ST/SC/OBC"
label values Social_Group_new social_label

label define ration_label 0 "APL/None (Base)" 1 "BPL/Antyodaya"
label values Ration_Type_new ration_label

// Label categorical variables
label define religion_label 1 "Hindu (Base)" 2 "Muslim" 3 "Others"
label values Religion_new religion_label

label define dwelling_label 1 "Owned (Base)" 2 "Rented/Others"
label values Dwelling_Unit_new dwelling_label

label define sector_label 1 "Rural (Base)" 2 "Urban"
label values Sector sector_label

// Label treatment variable
label define treat_label 0 "Control Group (Base)" 1 "Treatment Group"
label values robust_treat1 treat_label

// Display base category information
display _newline
display "BASE CATEGORIES DEFINED:"
display "  - Household Type: Non-Agricultural"
display "  - Social Group: General/Others"
display "  - Ration Card: APL/None"
display "  - Religion: Hindu"
display "  - Dwelling: Owned"
display "  - Sector: Rural"
display "  - Treatment Status: Control Group"
display _newline

// ==============================================================================
// DETERMINANTS OF CONSUMPTION EXPENDITURE
// ==============================================================================

display _newline(2)
display "================================================================================"
display "DETERMINANTS OF CONSUMPTION EXPENDITURE ANALYSIS"
display "================================================================================"

global det_controls HH_Type_Agri Social_Group_new Ration_Type_new ///
                    i.Dwelling_Unit_new HHSize HH_AdultFemaleProp ///
                    HH_Head_Age HH_Head_Education i.Religion_new i.Sector

// ==============================================================================
// FOOD EXPENDITURE PER CAPITA (LOG)
// ==============================================================================

display _newline
display "ANALYZING: Food Expenditure Per Capita (Log)"
display "=============================================="

// Before Tsunami - Control Group
quietly reg ln_Food_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store det_food_c0
display "✓ Before Tsunami - Control Group"

// Before Tsunami - Treatment Group
quietly reg ln_Food_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store det_food_t0
display "✓ Before Tsunami - Treatment Group"

// After Tsunami - Control Group
quietly reg ln_Food_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store det_food_c1
display "✓ After Tsunami - Control Group"

// After Tsunami - Treatment Group
quietly reg ln_Food_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store det_food_t1
display "✓ After Tsunami - Treatment Group"

// Before Tsunami - Pooled with Treatment Indicator
quietly reg ln_Food_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store det_food_pool0
display "✓ Before Tsunami - Pooled"

// After Tsunami - Pooled with Treatment Indicator
quietly reg ln_Food_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store det_food_pool1
display "✓ After Tsunami - Pooled"

// ==============================================================================
// FUEL EXPENDITURE PER CAPITA (LOG)
// ==============================================================================

display _newline
display "ANALYZING: Fuel Expenditure Per Capita (Log)"
display "============================================="

quietly reg ln_Fuel_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store det_fuel_c0
quietly reg ln_Fuel_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store det_fuel_t0
quietly reg ln_Fuel_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store det_fuel_c1
quietly reg ln_Fuel_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store det_fuel_t1
quietly reg ln_Fuel_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store det_fuel_pool0
quietly reg ln_Fuel_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store det_fuel_pool1
display "✓ All fuel models estimated"

// ==============================================================================
// CLOTHING EXPENDITURE PER CAPITA (LOG)
// ==============================================================================

display _newline
display "ANALYZING: Clothing Expenditure Per Capita (Log)"
display "================================================="

quietly reg ln_Clothing_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store det_cloth_c0
quietly reg ln_Clothing_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store det_cloth_t0
quietly reg ln_Clothing_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store det_cloth_c1
quietly reg ln_Clothing_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store det_cloth_t1
quietly reg ln_Clothing_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store det_cloth_pool0
quietly reg ln_Clothing_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store det_cloth_pool1
display "✓ All clothing models estimated"

// ==============================================================================
// FOOTWEAR EXPENDITURE PER CAPITA (LOG)
// ==============================================================================

display _newline
display "ANALYZING: Footwear Expenditure Per Capita (Log)"
display "================================================="

quietly reg ln_Footwear_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store det_footwear_c0
quietly reg ln_Footwear_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store det_footwear_t0
quietly reg ln_Footwear_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store det_footwear_c1
quietly reg ln_Footwear_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store det_footwear_t1
quietly reg ln_Footwear_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store det_footwear_pool0
quietly reg ln_Footwear_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store det_footwear_pool1
display "✓ All footwear models estimated"

// ==============================================================================
// DURABLE EXPENDITURE PER CAPITA (LOG)
// ==============================================================================

display _newline
display "ANALYZING: Durable Expenditure Per Capita (Log)"
display "================================================"

quietly reg ln_Durable_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store det_durable_c0
quietly reg ln_Durable_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store det_durable_t0
quietly reg ln_Durable_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store det_durable_c1
quietly reg ln_Durable_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store det_durable_t1
quietly reg ln_Durable_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store det_durable_pool0
quietly reg ln_Durable_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store det_durable_pool1
display "✓ All durable models estimated"

// ==============================================================================
// MISCELLANEOUS EXPENDITURE PER CAPITA (LOG)
// ==============================================================================

display _newline
display "ANALYZING: Miscellaneous Expenditure Per Capita (Log)"
display "======================================================"

quietly reg ln_Misc_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store det_misc_c0
quietly reg ln_Misc_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store det_misc_t0
quietly reg ln_Misc_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store det_misc_c1
quietly reg ln_Misc_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store det_misc_t1
quietly reg ln_Misc_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store det_misc_pool0
quietly reg ln_Misc_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store det_misc_pool1
display "✓ All miscellaneous models estimated"

// ==============================================================================
// TOTAL EXPENDITURE (MPCE - LOG)
// ==============================================================================

display _newline
display "ANALYZING: Total Monthly Per Capita Expenditure (MPCE - Log)"
display "============================================================="

quietly reg ln_MPCE_Own $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store det_mpce_c0
quietly reg ln_MPCE_Own $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store det_mpce_t0
quietly reg ln_MPCE_Own $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store det_mpce_c1
quietly reg ln_MPCE_Own $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store det_mpce_t1
quietly reg ln_MPCE_Own robust_treat1 $det_controls if after_tsunami==0, robust
estimates store det_mpce_pool0
quietly reg ln_MPCE_Own robust_treat1 $det_controls if after_tsunami==1, robust
estimates store det_mpce_pool1
display "✓ All MPCE models estimated"

// ==============================================================================
// EXPORT RESULTS TO WORD DOCUMENTS
// ==============================================================================

display _newline(2)
display "================================================================================"
display "EXPORTING RESULTS TO WORD DOCUMENTS"
display "================================================================================"

// FOOD EXPENDITURE
esttab det_food_c0 det_food_t0 det_food_pool0 det_food_c1 det_food_t1 det_food_pool1 ///
       using "ShortRun_Determinants_Food_PC.rtf", ///
       replace b(3) se(3) r2(3) ar2(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       stats(N r2 r2_a F, fmt(0 3 3 2) ///
             labels("Observations" "R-squared" "Adjusted R-squared" "F-statistic")) ///
       mtitles("Before: Control" "Before: Treatment" "Before: Pooled" ///
               "After: Control" "After: Treatment" "After: Pooled") ///
       title("Table: Determinants of Food Expenditure Per Capita (Log)") ///
       addnote("Note: Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card," ///
               "Hindu religion, Owned dwelling, Rural sector, Control group." ///
               "* p<0.10, ** p<0.05, *** p<0.01")
display "✓ ShortRun_Determinants_Food_PC.rtf"

// FUEL EXPENDITURE
esttab det_fuel_c0 det_fuel_t0 det_fuel_pool0 det_fuel_c1 det_fuel_t1 det_fuel_pool1 ///
       using "ShortRun_Determinants_Fuel_PC.rtf", ///
       replace b(3) se(3) r2(3) ar2(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       stats(N r2 r2_a F, fmt(0 3 3 2) ///
             labels("Observations" "R-squared" "Adjusted R-squared" "F-statistic")) ///
       mtitles("Before: Control" "Before: Treatment" "Before: Pooled" ///
               "After: Control" "After: Treatment" "After: Pooled") ///
       title("Table: Determinants of Fuel Expenditure Per Capita (Log)") ///
       addnote("Note: Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card," ///
               "Hindu religion, Owned dwelling, Rural sector, Control group." ///
               "* p<0.10, ** p<0.05, *** p<0.01")
display "✓ ShortRun_Determinants_Fuel_PC.rtf"

// CLOTHING EXPENDITURE
esttab det_cloth_c0 det_cloth_t0 det_cloth_pool0 det_cloth_c1 det_cloth_t1 det_cloth_pool1 ///
       using "ShortRun_Determinants_Clothing_PC.rtf", ///
       replace b(3) se(3) r2(3) ar2(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       stats(N r2 r2_a F, fmt(0 3 3 2) ///
             labels("Observations" "R-squared" "Adjusted R-squared" "F-statistic")) ///
       mtitles("Before: Control" "Before: Treatment" "Before: Pooled" ///
               "After: Control" "After: Treatment" "After: Pooled") ///
       title("Table: Determinants of Clothing Expenditure Per Capita (Log)") ///
       addnote("Note: Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card," ///
               "Hindu religion, Owned dwelling, Rural sector, Control group." ///
               "* p<0.10, ** p<0.05, *** p<0.01")
display "✓ ShortRun_Determinants_Clothing_PC.rtf"

// FOOTWEAR EXPENDITURE
esttab det_footwear_c0 det_footwear_t0 det_footwear_pool0 det_footwear_c1 det_footwear_t1 det_footwear_pool1 ///
       using "ShortRun_Determinants_Footwear_PC.rtf", ///
       replace b(3) se(3) r2(3) ar2(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       stats(N r2 r2_a F, fmt(0 3 3 2) ///
             labels("Observations" "R-squared" "Adjusted R-squared" "F-statistic")) ///
       mtitles("Before: Control" "Before: Treatment" "Before: Pooled" ///
               "After: Control" "After: Treatment" "After: Pooled") ///
       title("Table: Determinants of Footwear Expenditure Per Capita (Log)") ///
       addnote("Note: Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card," ///
               "Hindu religion, Owned dwelling, Rural sector, Control group." ///
               "* p<0.10, ** p<0.05, *** p<0.01")
display "✓ ShortRun_Determinants_Footwear_PC.rtf"

// DURABLE EXPENDITURE
esttab det_durable_c0 det_durable_t0 det_durable_pool0 det_durable_c1 det_durable_t1 det_durable_pool1 ///
       using "ShortRun_Determinants_Durable_PC.rtf", ///
       replace b(3) se(3) r2(3) ar2(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       stats(N r2 r2_a F, fmt(0 3 3 2) ///
             labels("Observations" "R-squared" "Adjusted R-squared" "F-statistic")) ///
       mtitles("Before: Control" "Before: Treatment" "Before: Pooled" ///
               "After: Control" "After: Treatment" "After: Pooled") ///
       title("Table: Determinants of Durable Goods Expenditure Per Capita (Log)") ///
       addnote("Note: Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card," ///
               "Hindu religion, Owned dwelling, Rural sector, Control group." ///
               "* p<0.10, ** p<0.05, *** p<0.01")
display "✓ ShortRun_Determinants_Durable_PC.rtf"

// MISCELLANEOUS EXPENDITURE
esttab det_misc_c0 det_misc_t0 det_misc_pool0 det_misc_c1 det_misc_t1 det_misc_pool1 ///
       using "ShortRun_Determinants_Misc_PC.rtf", ///
       replace b(3) se(3) r2(3) ar2(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       stats(N r2 r2_a F, fmt(0 3 3 2) ///
             labels("Observations" "R-squared" "Adjusted R-squared" "F-statistic")) ///
       mtitles("Before: Control" "Before: Treatment" "Before: Pooled" ///
               "After: Control" "After: Treatment" "After: Pooled") ///
       title("Table: Determinants of Miscellaneous Expenditure Per Capita (Log)") ///
       addnote("Note: Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card," ///
               "Hindu religion, Owned dwelling, Rural sector, Control group." ///
               "* p<0.10, ** p<0.05, *** p<0.01")
display "✓ ShortRun_Determinants_Misc_PC.rtf"

// TOTAL EXPENDITURE (MPCE)
esttab det_mpce_c0 det_mpce_t0 det_mpce_pool0 det_mpce_c1 det_mpce_t1 det_mpce_pool1 ///
       using "ShortRun_Determinants_MPCE.rtf", ///
       replace b(3) se(3) r2(3) ar2(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       stats(N r2 r2_a F, fmt(0 3 3 2) ///
             labels("Observations" "R-squared" "Adjusted R-squared" "F-statistic")) ///
       mtitles("Before: Control" "Before: Treatment" "Before: Pooled" ///
               "After: Control" "After: Treatment" "After: Pooled") ///
       title("Table: Determinants of Total Monthly Per Capita Expenditure (MPCE - Log)") ///
       addnote("Note: Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card," ///
               "Hindu religion, Owned dwelling, Rural sector, Control group." ///
               "* p<0.10, ** p<0.05, *** p<0.01")
display "✓ ShortRun_Determinants_MPCE.rtf"

// ==============================================================================
// ALSO EXPORT TO CSV FOR ADDITIONAL FLEXIBILITY
// ==============================================================================

display _newline
display "EXPORTING CSV VERSIONS..."

esttab det_food_c0 det_food_t0 det_food_pool0 det_food_c1 det_food_t1 det_food_pool1 ///
       using "ShortRun_Determinants_Food_PC.csv", ///
       replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
       stats(N r2 r2_a F) csv
display "✓ ShortRun_Determinants_Food_PC.csv"

esttab det_fuel_c0 det_fuel_t0 det_fuel_pool0 det_fuel_c1 det_fuel_t1 det_fuel_pool1 ///
       using "ShortRun_Determinants_Fuel_PC.csv", ///
       replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
       stats(N r2 r2_a F) csv
display "✓ ShortRun_Determinants_Fuel_PC.csv"

esttab det_cloth_c0 det_cloth_t0 det_cloth_pool0 det_cloth_c1 det_cloth_t1 det_cloth_pool1 ///
       using "ShortRun_Determinants_Clothing_PC.csv", ///
       replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
       stats(N r2 r2_a F) csv
display "✓ ShortRun_Determinants_Clothing_PC.csv"

esttab det_footwear_c0 det_footwear_t0 det_footwear_pool0 det_footwear_c1 det_footwear_t1 det_footwear_pool1 ///
       using "ShortRun_Determinants_Footwear_PC.csv", ///
       replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
       stats(N r2 r2_a F) csv
display "✓ ShortRun_Determinants_Footwear_PC.csv"

esttab det_durable_c0 det_durable_t0 det_durable_pool0 det_durable_c1 det_durable_t1 det_durable_pool1 ///
       using "ShortRun_Determinants_Durable_PC.csv", ///
       replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
       stats(N r2 r2_a F) csv
display "✓ ShortRun_Determinants_Durable_PC.csv"

esttab det_misc_c0 det_misc_t0 det_misc_pool0 det_misc_c1 det_misc_t1 det_misc_pool1 ///
       using "ShortRun_Determinants_Misc_PC.csv", ///
       replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
       stats(N r2 r2_a F) csv
display "✓ ShortRun_Determinants_Misc_PC.csv"

esttab det_mpce_c0 det_mpce_t0 det_mpce_pool0 det_mpce_c1 det_mpce_t1 det_mpce_pool1 ///
       using "ShortRun_Determinants_MPCE.csv", ///
       replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
       stats(N r2 r2_a F) csv
display "✓ ShortRun_Determinants_MPCE.csv"

// ==============================================================================
// COMPLETION SUMMARY
// ==============================================================================

display _newline(2)
display "================================================================================"
display "✓✓✓ DETERMINANTS ANALYSIS COMPLETE ✓✓✓"
display "================================================================================"
display ""
display "FILES CREATED: 14 output files (7 RTF + 7 CSV)"
display ""
display "WORD DOCUMENTS (Academic format):"
display "  1. ShortRun_Determinants_Food_PC.rtf"
display "  2. ShortRun_Determinants_Fuel_PC.rtf"
display "  3. ShortRun_Determinants_Clothing_PC.rtf"
display "  4. ShortRun_Determinants_Footwear_PC.rtf"
display "  5. ShortRun_Determinants_Durable_PC.rtf"
display "  6. ShortRun_Determinants_Misc_PC.rtf"
display "  7. ShortRun_Determinants_MPCE.rtf"
display ""
display "CSV FILES (For additional processing):"
display "  1-7. Corresponding CSV versions"
display ""
display "KEY FEATURES:"
display "  ✓ Properly labeled base categories"
display "  ✓ Robust standard errors"
display "  ✓ R-squared, Adjusted R-squared, F-statistics"
display "  ✓ Six models per expenditure category:"
display "    - Before tsunami: Control, Treatment, Pooled"
display "    - After tsunami: Control, Treatment, Pooled"
display "  ✓ Academic-quality formatting with footnotes"
display ""
display "BASE CATEGORIES:"
display "  - Non-agricultural household"
display "  - General/Others social group"
display "  - APL/None ration card"
display "  - Hindu religion"
display "  - Owned dwelling"
display "  - Rural sector"
display "  - Control group (for pooled models)"
display ""
display "================================================================================"
