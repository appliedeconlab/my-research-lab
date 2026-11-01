// ==============================================================================
// EXPORT DETERMINANTS OF CONSUMPTION TO LATEX FORMAT
// Both Short-Run and Long-Run Datasets
// Creates one LaTeX table per expenditure category with proper labels
// ==============================================================================

clear all
set more off

// ==============================================================================
// SECTION 1: SHORT-RUN DATASET ANALYSIS
// ==============================================================================

display "================================================================================"
display "PROCESSING SHORT-RUN DATASET"
display "================================================================================"
* Sanitized: caller must run from repository root.

use "AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta", clear
merge 1:1 HHID using "person_record.dta"
keep if _merge==3
drop _merge
keep if !missing(robust_treat1)

// Variable Preparation
foreach var in HH_Head_Education HH_Head_Age HH_AdultFemaleProp {
    capture confirm numeric variable `var'
    if _rc {
        destring `var', replace force
    }
}

capture drop ln_*
capture drop HH_Type_Agri Social_Group_new Ration_Type_new Religion_new Dwelling_Unit_new
capture drop Dwelling_Unit_new_* Religion_new_* Sector_*

foreach var in Food Food_PC Fuel Fuel_PC Clothing Clothing_PC Footwear Footwear_PC ///
               Durable Durable_PC Misc Misc_PC MPCE_Own {
    capture confirm variable `var'
    if !_rc {
        gen ln_`var' = ln(`var' + 1)
        label var ln_`var' "Log(`var')"
    }
}

// Create and label variables
gen HH_Type_Agri = (inlist(HH_Type, 12, 14))
label var HH_Type_Agri "Agricultural Household"

gen Social_Group_new = (inlist(Social_Group, 1, 2, 3))
label var Social_Group_new "ST/SC/OBC"

gen Ration_Type_new = (inlist(Ration_Type, 1, 2))
label var Ration_Type_new "BPL/Antyodaya Card"

gen Religion_new = 1 if Religion == 1
replace Religion_new = 2 if Religion == 2
replace Religion_new = 3 if inlist(Religion, 3, 9)
label var Religion_new "Religion"

gen Dwelling_Unit_new = 1 if Dwelling_Unit == 1
replace Dwelling_Unit_new = 2 if inlist(Dwelling_Unit, 2, 9)
label var Dwelling_Unit_new "Dwelling Unit"

// Label values for categorical variables
label define religion_label 1 "Hindu (Base)" 2 "Muslim" 3 "Others"
label values Religion_new religion_label

label define dwelling_label 1 "Owned (Base)" 2 "Rented/Others"
label values Dwelling_Unit_new dwelling_label

label define sector_label 1 "Rural (Base)" 2 "Urban"
label values Sector sector_label

label define treat_label 0 "Control (Base)" 1 "Treatment"
label values robust_treat1 treat_label

// Label continuous control variables with descriptive names
label var HHSize "Household Size"
label var HH_AdultFemaleProp "Proportion of Adult Females"
label var HH_Head_Age "Age of Household Head"
label var HH_Head_Education "Education of HH Head (Years)"

global det_controls HH_Type_Agri Social_Group_new Ration_Type_new ///
                    i.Dwelling_Unit_new HHSize HH_AdultFemaleProp ///
                    HH_Head_Age HH_Head_Education i.Religion_new i.Sector

display "✓ Short-run variables prepared"

// ==============================================================================
// RUN REGRESSIONS - SHORT RUN
// ==============================================================================

display _newline "Running regressions for SHORT-RUN dataset..."

// FOOD
quietly reg ln_Food_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store sr_food_c0
quietly reg ln_Food_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store sr_food_t0
quietly reg ln_Food_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store sr_food_pool0
quietly reg ln_Food_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store sr_food_c1
quietly reg ln_Food_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store sr_food_t1
quietly reg ln_Food_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store sr_food_pool1

// FUEL
quietly reg ln_Fuel_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store sr_fuel_c0
quietly reg ln_Fuel_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store sr_fuel_t0
quietly reg ln_Fuel_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store sr_fuel_pool0
quietly reg ln_Fuel_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store sr_fuel_c1
quietly reg ln_Fuel_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store sr_fuel_t1
quietly reg ln_Fuel_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store sr_fuel_pool1

// CLOTHING
quietly reg ln_Clothing_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store sr_cloth_c0
quietly reg ln_Clothing_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store sr_cloth_t0
quietly reg ln_Clothing_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store sr_cloth_pool0
quietly reg ln_Clothing_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store sr_cloth_c1
quietly reg ln_Clothing_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store sr_cloth_t1
quietly reg ln_Clothing_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store sr_cloth_pool1

// FOOTWEAR
quietly reg ln_Footwear_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store sr_footwear_c0
quietly reg ln_Footwear_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store sr_footwear_t0
quietly reg ln_Footwear_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store sr_footwear_pool0
quietly reg ln_Footwear_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store sr_footwear_c1
quietly reg ln_Footwear_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store sr_footwear_t1
quietly reg ln_Footwear_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store sr_footwear_pool1

// DURABLE
quietly reg ln_Durable_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store sr_durable_c0
quietly reg ln_Durable_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store sr_durable_t0
quietly reg ln_Durable_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store sr_durable_pool0
quietly reg ln_Durable_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store sr_durable_c1
quietly reg ln_Durable_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store sr_durable_t1
quietly reg ln_Durable_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store sr_durable_pool1

// MISCELLANEOUS
quietly reg ln_Misc_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store sr_misc_c0
quietly reg ln_Misc_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store sr_misc_t0
quietly reg ln_Misc_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store sr_misc_pool0
quietly reg ln_Misc_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store sr_misc_c1
quietly reg ln_Misc_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store sr_misc_t1
quietly reg ln_Misc_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store sr_misc_pool1

// MPCE
quietly reg ln_MPCE_Own $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store sr_mpce_c0
quietly reg ln_MPCE_Own $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store sr_mpce_t0
quietly reg ln_MPCE_Own robust_treat1 $det_controls if after_tsunami==0, robust
estimates store sr_mpce_pool0
quietly reg ln_MPCE_Own $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store sr_mpce_c1
quietly reg ln_MPCE_Own $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store sr_mpce_t1
quietly reg ln_MPCE_Own robust_treat1 $det_controls if after_tsunami==1, robust
estimates store sr_mpce_pool1

display "✓ All short-run regressions completed"

// ==============================================================================
// SECTION 2: LONG-RUN DATASET ANALYSIS
// ==============================================================================

display _newline(2)
display "================================================================================"
display "PROCESSING LONG-RUN DATASET"
display "================================================================================"

use "AP_Aggregates_Merged_All_SubRound_Consistent_Sample.dta", clear
merge 1:1 HHID using "person_record.dta"
keep if _merge==3
drop _merge
keep if !missing(robust_treat1)

// Variable Preparation
foreach var in HH_Head_Education HH_Head_Age HH_AdultFemaleProp {
    capture confirm numeric variable `var'
    if _rc {
        destring `var', replace force
    }
}

capture drop ln_*
capture drop HH_Type_Agri Social_Group_new Ration_Type_new Religion_new Dwelling_Unit_new
capture drop Dwelling_Unit_new_* Religion_new_* Sector_*

foreach var in Food Food_PC Fuel Fuel_PC Clothing Clothing_PC Footwear Footwear_PC ///
               Durable Durable_PC Misc Misc_PC MPCE_Own {
    capture confirm variable `var'
    if !_rc {
        gen ln_`var' = ln(`var' + 1)
        label var ln_`var' "Log(`var')"
    }
}

// Create and label variables
gen HH_Type_Agri = (inlist(HH_Type, 12, 14))
label var HH_Type_Agri "Agricultural Household"

gen Social_Group_new = (inlist(Social_Group, 1, 2, 3))
label var Social_Group_new "ST/SC/OBC"

gen Ration_Type_new = (inlist(Ration_Type, 1, 2))
label var Ration_Type_new "BPL/Antyodaya Card"

gen Religion_new = 1 if Religion == 1
replace Religion_new = 2 if Religion == 2
replace Religion_new = 3 if inlist(Religion, 3, 9)
label var Religion_new "Religion"

gen Dwelling_Unit_new = 1 if Dwelling_Unit == 1
replace Dwelling_Unit_new = 2 if inlist(Dwelling_Unit, 2, 9)
label var Dwelling_Unit_new "Dwelling Unit"

// Label values for categorical variables
label define religion_label 1 "Hindu (Base)" 2 "Muslim" 3 "Others"
label values Religion_new religion_label

label define dwelling_label 1 "Owned (Base)" 2 "Rented/Others"
label values Dwelling_Unit_new dwelling_label

label define sector_label 1 "Rural (Base)" 2 "Urban"
label values Sector sector_label

label define treat_label 0 "Control (Base)" 1 "Treatment"
label values robust_treat1 treat_label

// Label continuous control variables
label var HHSize "Household Size"
label var HH_AdultFemaleProp "Proportion of Adult Females"
label var HH_Head_Age "Age of Household Head"
label var HH_Head_Education "Education of HH Head (Years)"

global det_controls HH_Type_Agri Social_Group_new Ration_Type_new ///
                    i.Dwelling_Unit_new HHSize HH_AdultFemaleProp ///
                    HH_Head_Age HH_Head_Education i.Religion_new i.Sector

display "✓ Long-run variables prepared"

// ==============================================================================
// RUN REGRESSIONS - LONG RUN
// ==============================================================================

display _newline "Running regressions for LONG-RUN dataset..."

// FOOD
quietly reg ln_Food_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store lr_food_c0
quietly reg ln_Food_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store lr_food_t0
quietly reg ln_Food_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store lr_food_pool0
quietly reg ln_Food_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store lr_food_c1
quietly reg ln_Food_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store lr_food_t1
quietly reg ln_Food_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store lr_food_pool1

// FUEL
quietly reg ln_Fuel_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store lr_fuel_c0
quietly reg ln_Fuel_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store lr_fuel_t0
quietly reg ln_Fuel_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store lr_fuel_pool0
quietly reg ln_Fuel_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store lr_fuel_c1
quietly reg ln_Fuel_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store lr_fuel_t1
quietly reg ln_Fuel_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store lr_fuel_pool1

// CLOTHING
quietly reg ln_Clothing_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store lr_cloth_c0
quietly reg ln_Clothing_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store lr_cloth_t0
quietly reg ln_Clothing_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store lr_cloth_pool0
quietly reg ln_Clothing_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store lr_cloth_c1
quietly reg ln_Clothing_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store lr_cloth_t1
quietly reg ln_Clothing_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store lr_cloth_pool1

// FOOTWEAR
quietly reg ln_Footwear_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store lr_footwear_c0
quietly reg ln_Footwear_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store lr_footwear_t0
quietly reg ln_Footwear_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store lr_footwear_pool0
quietly reg ln_Footwear_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store lr_footwear_c1
quietly reg ln_Footwear_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store lr_footwear_t1
quietly reg ln_Footwear_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store lr_footwear_pool1

// DURABLE
quietly reg ln_Durable_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store lr_durable_c0
quietly reg ln_Durable_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store lr_durable_t0
quietly reg ln_Durable_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store lr_durable_pool0
quietly reg ln_Durable_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store lr_durable_c1
quietly reg ln_Durable_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store lr_durable_t1
quietly reg ln_Durable_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store lr_durable_pool1

// MISCELLANEOUS
quietly reg ln_Misc_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store lr_misc_c0
quietly reg ln_Misc_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store lr_misc_t0
quietly reg ln_Misc_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store lr_misc_pool0
quietly reg ln_Misc_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store lr_misc_c1
quietly reg ln_Misc_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store lr_misc_t1
quietly reg ln_Misc_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store lr_misc_pool1

// MPCE
quietly reg ln_MPCE_Own $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store lr_mpce_c0
quietly reg ln_MPCE_Own $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store lr_mpce_t0
quietly reg ln_MPCE_Own robust_treat1 $det_controls if after_tsunami==0, robust
estimates store lr_mpce_pool0
quietly reg ln_MPCE_Own $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store lr_mpce_c1
quietly reg ln_MPCE_Own $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store lr_mpce_t1
quietly reg ln_MPCE_Own robust_treat1 $det_controls if after_tsunami==1, robust
estimates store lr_mpce_pool1

display "✓ All long-run regressions completed"

// ==============================================================================
// EXPORT TO LATEX - SHORT RUN
// ==============================================================================

display _newline(2)
display "================================================================================"
display "EXPORTING SHORT-RUN RESULTS TO LATEX"
display "================================================================================"

// FOOD - SHORT RUN
esttab sr_food_c0 sr_food_t0 sr_food_pool0 sr_food_c1 sr_food_t1 sr_food_pool1 ///
       using "LaTeX_ShortRun_Determinants_Food_PC.tex", ///
       replace booktabs ///
       b(3) se(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       label nonumbers ///
       stats(N r2 r2_a, fmt(0 3 3) ///
             labels("Observations" "R-squared" "Adjusted R-squared")) ///
       mtitles("Control" "Treatment" "Pooled" "Control" "Treatment" "Pooled") ///
       mgroups("Before Tsunami" "After Tsunami", ///
               pattern(1 0 0 1 0 0) ///
               prefix(\multicolumn{@span}{c}{) suffix(}) ///
               span erepeat(\cmidrule(lr){@span})) ///
       title("Determinants of Food Expenditure Per Capita (Log) - Short Run") ///
       addnote("Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card, Hindu religion, Owned dwelling, Rural sector." ///
               "* \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\)")
display "✓ LaTeX_ShortRun_Determinants_Food_PC.tex"

// FUEL - SHORT RUN
esttab sr_fuel_c0 sr_fuel_t0 sr_fuel_pool0 sr_fuel_c1 sr_fuel_t1 sr_fuel_pool1 ///
       using "LaTeX_ShortRun_Determinants_Fuel_PC.tex", ///
       replace booktabs ///
       b(3) se(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       label nonumbers ///
       stats(N r2 r2_a, fmt(0 3 3) ///
             labels("Observations" "R-squared" "Adjusted R-squared")) ///
       mtitles("Control" "Treatment" "Pooled" "Control" "Treatment" "Pooled") ///
       mgroups("Before Tsunami" "After Tsunami", ///
               pattern(1 0 0 1 0 0) ///
               prefix(\multicolumn{@span}{c}{) suffix(}) ///
               span erepeat(\cmidrule(lr){@span})) ///
       title("Determinants of Fuel Expenditure Per Capita (Log) - Short Run") ///
       addnote("Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card, Hindu religion, Owned dwelling, Rural sector." ///
               "* \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\)")
display "✓ LaTeX_ShortRun_Determinants_Fuel_PC.tex"

// CLOTHING - SHORT RUN
esttab sr_cloth_c0 sr_cloth_t0 sr_cloth_pool0 sr_cloth_c1 sr_cloth_t1 sr_cloth_pool1 ///
       using "LaTeX_ShortRun_Determinants_Clothing_PC.tex", ///
       replace booktabs ///
       b(3) se(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       label nonumbers ///
       stats(N r2 r2_a, fmt(0 3 3) ///
             labels("Observations" "R-squared" "Adjusted R-squared")) ///
       mtitles("Control" "Treatment" "Pooled" "Control" "Treatment" "Pooled") ///
       mgroups("Before Tsunami" "After Tsunami", ///
               pattern(1 0 0 1 0 0) ///
               prefix(\multicolumn{@span}{c}{) suffix(}) ///
               span erepeat(\cmidrule(lr){@span})) ///
       title("Determinants of Clothing Expenditure Per Capita (Log) - Short Run") ///
       addnote("Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card, Hindu religion, Owned dwelling, Rural sector." ///
               "* \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\)")
display "✓ LaTeX_ShortRun_Determinants_Clothing_PC.tex"

// FOOTWEAR - SHORT RUN
esttab sr_footwear_c0 sr_footwear_t0 sr_footwear_pool0 sr_footwear_c1 sr_footwear_t1 sr_footwear_pool1 ///
       using "LaTeX_ShortRun_Determinants_Footwear_PC.tex", ///
       replace booktabs ///
       b(3) se(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       label nonumbers ///
       stats(N r2 r2_a, fmt(0 3 3) ///
             labels("Observations" "R-squared" "Adjusted R-squared")) ///
       mtitles("Control" "Treatment" "Pooled" "Control" "Treatment" "Pooled") ///
       mgroups("Before Tsunami" "After Tsunami", ///
               pattern(1 0 0 1 0 0) ///
               prefix(\multicolumn{@span}{c}{) suffix(}) ///
               span erepeat(\cmidrule(lr){@span})) ///
       title("Determinants of Footwear Expenditure Per Capita (Log) - Short Run") ///
       addnote("Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card, Hindu religion, Owned dwelling, Rural sector." ///
               "* \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\)")
display "✓ LaTeX_ShortRun_Determinants_Footwear_PC.tex"

// DURABLE - SHORT RUN
esttab sr_durable_c0 sr_durable_t0 sr_durable_pool0 sr_durable_c1 sr_durable_t1 sr_durable_pool1 ///
       using "LaTeX_ShortRun_Determinants_Durable_PC.tex", ///
       replace booktabs ///
       b(3) se(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       label nonumbers ///
       stats(N r2 r2_a, fmt(0 3 3) ///
             labels("Observations" "R-squared" "Adjusted R-squared")) ///
       mtitles("Control" "Treatment" "Pooled" "Control" "Treatment" "Pooled") ///
       mgroups("Before Tsunami" "After Tsunami", ///
               pattern(1 0 0 1 0 0) ///
               prefix(\multicolumn{@span}{c}{) suffix(}) ///
               span erepeat(\cmidrule(lr){@span})) ///
       title("Determinants of Durable Goods Expenditure Per Capita (Log) - Short Run") ///
       addnote("Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card, Hindu religion, Owned dwelling, Rural sector." ///
               "* \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\)")
display "✓ LaTeX_ShortRun_Determinants_Durable_PC.tex"

// MISCELLANEOUS - SHORT RUN
esttab sr_misc_c0 sr_misc_t0 sr_misc_pool0 sr_misc_c1 sr_misc_t1 sr_misc_pool1 ///
       using "LaTeX_ShortRun_Determinants_Misc_PC.tex", ///
       replace booktabs ///
       b(3) se(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       label nonumbers ///
       stats(N r2 r2_a, fmt(0 3 3) ///
             labels("Observations" "R-squared" "Adjusted R-squared")) ///
       mtitles("Control" "Treatment" "Pooled" "Control" "Treatment" "Pooled") ///
       mgroups("Before Tsunami" "After Tsunami", ///
               pattern(1 0 0 1 0 0) ///
               prefix(\multicolumn{@span}{c}{) suffix(}) ///
               span erepeat(\cmidrule(lr){@span})) ///
       title("Determinants of Miscellaneous Expenditure Per Capita (Log) - Short Run") ///
       addnote("Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card, Hindu religion, Owned dwelling, Rural sector." ///
               "* \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\)")
display "✓ LaTeX_ShortRun_Determinants_Misc_PC.tex"

// MPCE - SHORT RUN
esttab sr_mpce_c0 sr_mpce_t0 sr_mpce_pool0 sr_mpce_c1 sr_mpce_t1 sr_mpce_pool1 ///
       using "LaTeX_ShortRun_Determinants_MPCE.tex", ///
       replace booktabs ///
       b(3) se(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       label nonumbers ///
       stats(N r2 r2_a, fmt(0 3 3) ///
             labels("Observations" "R-squared" "Adjusted R-squared")) ///
       mtitles("Control" "Treatment" "Pooled" "Control" "Treatment" "Pooled") ///
       mgroups("Before Tsunami" "After Tsunami", ///
               pattern(1 0 0 1 0 0) ///
               prefix(\multicolumn{@span}{c}{) suffix(}) ///
               span erepeat(\cmidrule(lr){@span})) ///
       title("Determinants of Total Monthly Per Capita Expenditure (MPCE - Log) - Short Run") ///
       addnote("Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card, Hindu religion, Owned dwelling, Rural sector." ///
               "* \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\)")
display "✓ LaTeX_ShortRun_Determinants_MPCE.tex"

// ==============================================================================
// EXPORT TO LATEX - LONG RUN
// ==============================================================================

display _newline(2)
display "================================================================================"
display "EXPORTING LONG-RUN RESULTS TO LATEX"
display "================================================================================"

// FOOD - LONG RUN
esttab lr_food_c0 lr_food_t0 lr_food_pool0 lr_food_c1 lr_food_t1 lr_food_pool1 ///
       using "LaTeX_LongRun_Determinants_Food_PC.tex", ///
       replace booktabs ///
       b(3) se(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       label nonumbers ///
       stats(N r2 r2_a, fmt(0 3 3) ///
             labels("Observations" "R-squared" "Adjusted R-squared")) ///
       mtitles("Control" "Treatment" "Pooled" "Control" "Treatment" "Pooled") ///
       mgroups("Before Tsunami" "After Tsunami", ///
               pattern(1 0 0 1 0 0) ///
               prefix(\multicolumn{@span}{c}{) suffix(}) ///
               span erepeat(\cmidrule(lr){@span})) ///
       title("Determinants of Food Expenditure Per Capita (Log) - Long Run") ///
       addnote("Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card, Hindu religion, Owned dwelling, Rural sector." ///
               "* \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\)")
display "✓ LaTeX_LongRun_Determinants_Food_PC.tex"

// FUEL - LONG RUN
esttab lr_fuel_c0 lr_fuel_t0 lr_fuel_pool0 lr_fuel_c1 lr_fuel_t1 lr_fuel_pool1 ///
       using "LaTeX_LongRun_Determinants_Fuel_PC.tex", ///
       replace booktabs ///
       b(3) se(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       label nonumbers ///
       stats(N r2 r2_a, fmt(0 3 3) ///
             labels("Observations" "R-squared" "Adjusted R-squared")) ///
       mtitles("Control" "Treatment" "Pooled" "Control" "Treatment" "Pooled") ///
       mgroups("Before Tsunami" "After Tsunami", ///
               pattern(1 0 0 1 0 0) ///
               prefix(\multicolumn{@span}{c}{) suffix(}) ///
               span erepeat(\cmidrule(lr){@span})) ///
       title("Determinants of Fuel Expenditure Per Capita (Log) - Long Run") ///
       addnote("Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card, Hindu religion, Owned dwelling, Rural sector." ///
               "* \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\)")
display "✓ LaTeX_LongRun_Determinants_Fuel_PC.tex"

// CLOTHING - LONG RUN
esttab lr_cloth_c0 lr_cloth_t0 lr_cloth_pool0 lr_cloth_c1 lr_cloth_t1 lr_cloth_pool1 ///
       using "LaTeX_LongRun_Determinants_Clothing_PC.tex", ///
       replace booktabs ///
       b(3) se(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       label nonumbers ///
       stats(N r2 r2_a, fmt(0 3 3) ///
             labels("Observations" "R-squared" "Adjusted R-squared")) ///
       mtitles("Control" "Treatment" "Pooled" "Control" "Treatment" "Pooled") ///
       mgroups("Before Tsunami" "After Tsunami", ///
               pattern(1 0 0 1 0 0) ///
               prefix(\multicolumn{@span}{c}{) suffix(}) ///
               span erepeat(\cmidrule(lr){@span})) ///
       title("Determinants of Clothing Expenditure Per Capita (Log) - Long Run") ///
       addnote("Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card, Hindu religion, Owned dwelling, Rural sector." ///
               "* \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\)")
display "✓ LaTeX_LongRun_Determinants_Clothing_PC.tex"

// FOOTWEAR - LONG RUN
esttab lr_footwear_c0 lr_footwear_t0 lr_footwear_pool0 lr_footwear_c1 lr_footwear_t1 lr_footwear_pool1 ///
       using "LaTeX_LongRun_Determinants_Footwear_PC.tex", ///
       replace booktabs ///
       b(3) se(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       label nonumbers ///
       stats(N r2 r2_a, fmt(0 3 3) ///
             labels("Observations" "R-squared" "Adjusted R-squared")) ///
       mtitles("Control" "Treatment" "Pooled" "Control" "Treatment" "Pooled") ///
       mgroups("Before Tsunami" "After Tsunami", ///
               pattern(1 0 0 1 0 0) ///
               prefix(\multicolumn{@span}{c}{) suffix(}) ///
               span erepeat(\cmidrule(lr){@span})) ///
       title("Determinants of Footwear Expenditure Per Capita (Log) - Long Run") ///
       addnote("Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card, Hindu religion, Owned dwelling, Rural sector." ///
               "* \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\)")
display "✓ LaTeX_LongRun_Determinants_Footwear_PC.tex"

// DURABLE - LONG RUN
esttab lr_durable_c0 lr_durable_t0 lr_durable_pool0 lr_durable_c1 lr_durable_t1 lr_durable_pool1 ///
       using "LaTeX_LongRun_Determinants_Durable_PC.tex", ///
       replace booktabs ///
       b(3) se(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       label nonumbers ///
       stats(N r2 r2_a, fmt(0 3 3) ///
             labels("Observations" "R-squared" "Adjusted R-squared")) ///
       mtitles("Control" "Treatment" "Pooled" "Control" "Treatment" "Pooled") ///
       mgroups("Before Tsunami" "After Tsunami", ///
               pattern(1 0 0 1 0 0) ///
               prefix(\multicolumn{@span}{c}{) suffix(}) ///
               span erepeat(\cmidrule(lr){@span})) ///
       title("Determinants of Durable Goods Expenditure Per Capita (Log) - Long Run") ///
       addnote("Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card, Hindu religion, Owned dwelling, Rural sector." ///
               "* \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\)")
display "✓ LaTeX_LongRun_Determinants_Durable_PC.tex"

// MISCELLANEOUS - LONG RUN
esttab lr_misc_c0 lr_misc_t0 lr_misc_pool0 lr_misc_c1 lr_misc_t1 lr_misc_pool1 ///
       using "LaTeX_LongRun_Determinants_Misc_PC.tex", ///
       replace booktabs ///
       b(3) se(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       label nonumbers ///
       stats(N r2 r2_a, fmt(0 3 3) ///
             labels("Observations" "R-squared" "Adjusted R-squared")) ///
       mtitles("Control" "Treatment" "Pooled" "Control" "Treatment" "Pooled") ///
       mgroups("Before Tsunami" "After Tsunami", ///
               pattern(1 0 0 1 0 0) ///
               prefix(\multicolumn{@span}{c}{) suffix(}) ///
               span erepeat(\cmidrule(lr){@span})) ///
       title("Determinants of Miscellaneous Expenditure Per Capita (Log) - Long Run") ///
       addnote("Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card, Hindu religion, Owned dwelling, Rural sector." ///
               "* \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\)")
display "✓ LaTeX_LongRun_Determinants_Misc_PC.tex"

// MPCE - LONG RUN
esttab lr_mpce_c0 lr_mpce_t0 lr_mpce_pool0 lr_mpce_c1 lr_mpce_t1 lr_mpce_pool1 ///
       using "LaTeX_LongRun_Determinants_MPCE.tex", ///
       replace booktabs ///
       b(3) se(3) ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       label nonumbers ///
       stats(N r2 r2_a, fmt(0 3 3) ///
             labels("Observations" "R-squared" "Adjusted R-squared")) ///
       mtitles("Control" "Treatment" "Pooled" "Control" "Treatment" "Pooled") ///
       mgroups("Before Tsunami" "After Tsunami", ///
               pattern(1 0 0 1 0 0) ///
               prefix(\multicolumn{@span}{c}{) suffix(}) ///
               span erepeat(\cmidrule(lr){@span})) ///
       title("Determinants of Total Monthly Per Capita Expenditure (MPCE - Log) - Long Run") ///
       addnote("Robust standard errors in parentheses." ///
               "Base categories: Non-agricultural HH, General/Others caste, APL/None ration card, Hindu religion, Owned dwelling, Rural sector." ///
               "* \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\)")
display "✓ LaTeX_LongRun_Determinants_MPCE.tex"

// ==============================================================================
// COMPLETION SUMMARY
// ==============================================================================

display _newline(2)
display "================================================================================"
display "✓✓✓ LATEX EXPORT COMPLETE ✓✓✓"
display "================================================================================"
display ""
display "14 LATEX FILES CREATED:"
display ""
display "SHORT-RUN (7 files):"
display "  1. LaTeX_ShortRun_Determinants_Food_PC.tex"
display "  2. LaTeX_ShortRun_Determinants_Fuel_PC.tex"
display "  3. LaTeX_ShortRun_Determinants_Clothing_PC.tex"
display "  4. LaTeX_ShortRun_Determinants_Footwear_PC.tex"
display "  5. LaTeX_ShortRun_Determinants_Durable_PC.tex"
display "  6. LaTeX_ShortRun_Determinants_Misc_PC.tex"
display "  7. LaTeX_ShortRun_Determinants_MPCE.tex"
display ""
display "LONG-RUN (7 files):"
display "  1. LaTeX_LongRun_Determinants_Food_PC.tex"
display "  2. LaTeX_LongRun_Determinants_Fuel_PC.tex"
display "  3. LaTeX_LongRun_Determinants_Clothing_PC.tex"
display "  4. LaTeX_LongRun_Determinants_Footwear_PC.tex"
display "  5. LaTeX_LongRun_Determinants_Durable_PC.tex"
display "  6. LaTeX_LongRun_Determinants_Misc_PC.tex"
display "  7. LaTeX_LongRun_Determinants_MPCE.tex"
display ""
display "TABLE FEATURES:"
display "  ✓ Professional booktabs formatting"
display "  ✓ Proper variable labels from Stata variable labels"
display "  ✓ Column groupings (Before/After Tsunami)"
display "  ✓ 3 decimal places for coefficients"
display "  ✓ Robust standard errors in parentheses"
display "  ✓ R-squared and Adjusted R-squared"
display "  ✓ Significance stars (* p<0.10, ** p<0.05, *** p<0.01)"
display "  ✓ Base category footnotes"
display ""
display "TO USE IN LATEX:"
display "  1. Add to preamble: \usepackage{booktabs}"
display "  2. Include tables with: \input{filename.tex}"
display "  3. Or use \include{filename} for separate pages"
display ""
display "================================================================================"
