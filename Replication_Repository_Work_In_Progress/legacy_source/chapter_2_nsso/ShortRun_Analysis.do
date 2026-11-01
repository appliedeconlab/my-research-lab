// ==============================================================================
// FIXED VERSION - PARALLEL TRENDS EXPORT WORKING CORRECTLY
// SHORT-RUN DATASET
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
// DESCRIPTIVE STATISTICS
// ==============================================================================

display _newline(2)
display "================================================================================"
display "DESCRIPTIVE STATISTICS"
display "================================================================================"

dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami==0, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("Before Tsunami - Non-Log Expenditures") ///
       export("ShortRun_DTable_Before_NonLog.docx", replace)

dtable ln_Food ln_Food_PC ln_Fuel ln_Fuel_PC ln_Clothing ln_Clothing_PC ///
       ln_Footwear ln_Footwear_PC ln_Durable ln_Durable_PC ln_Misc ln_Misc_PC ln_MPCE_Own ///
       if after_tsunami==0, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("Before Tsunami - Log Expenditures") ///
       export("ShortRun_DTable_Before_Log.docx", replace)

dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dwelling_Unit_new_* Religion_new_* Sector_* ///
       if after_tsunami==0, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("Before Tsunami - Controls") ///
       export("ShortRun_DTable_Before_Controls.docx", replace)

dtable Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
       Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ///
       if after_tsunami==1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.2f mean sd) ///
       title("After Tsunami - Non-Log Expenditures") ///
       export("ShortRun_DTable_After_NonLog.docx", replace)

dtable ln_Food ln_Food_PC ln_Fuel ln_Fuel_PC ln_Clothing ln_Clothing_PC ///
       ln_Footwear ln_Footwear_PC ln_Durable ln_Durable_PC ln_Misc ln_Misc_PC ln_MPCE_Own ///
       if after_tsunami==1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("After Tsunami - Log Expenditures") ///
       export("ShortRun_DTable_After_Log.docx", replace)

dtable HH_Type_Agri Social_Group_new Ration_Type_new ///
       HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
       Dwelling_Unit_new_* Religion_new_* Sector_* ///
       if after_tsunami==1, ///
       by(robust_treat1, tests testnotes totals) ///
       sample(, statistic(frequency)) ///
       nformat(%9.3f mean sd) ///
       title("After Tsunami - Controls") ///
       export("ShortRun_DTable_After_Controls.docx", replace)

// ==============================================================================
// DID ANALYSIS WITH PARALLEL TRENDS EXPORT (FIXED!)
// ==============================================================================

display _newline(2)
display "================================================================================"
display "DIFFERENCE-IN-DIFFERENCES WITH PARALLEL TRENDS EXPORT"
display "================================================================================"

// Initialize parallel trends results file
capture file close ptfile
file open ptfile using "ShortRun_ParallelTrends_Results.csv", write replace
file write ptfile "Model,Variable,VarType,Controls,DiD_Coef,DiD_SE,DiD_PValue,PT_Chi2,PT_PValue,PT_Result,N,R2" _n

local modelnum = 1

// NON-LOG VARIABLES
foreach var in Food Food_PC Fuel Fuel_PC Clothing Clothing_PC ///
                Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own {
    
    capture confirm variable `var'
    if !_rc {
        display _newline "Model `modelnum': `var' (Non-Log)"
        
        // WITHOUT CONTROLS
        quietly didregress (`var') (did_robust1), group(District) time(SubRound)
        didregress
        estimates store m`modelnum'a
        
        // Extract DiD results
        matrix b = e(b)
        matrix V = e(V)
        local did_coef = b[1,1]
        local did_se = sqrt(V[1,1])
        local did_p = 2*ttail(e(df_r), abs(`did_coef'/`did_se'))
        local n = e(N)
        local r2 = e(r2)
        
        // Parallel trends test
        quietly estat ptrends
        local pt_chi2 = r(chi2)
        local pt_p = r(p)
        local pt_result = cond(`pt_p' > 0.05, "PASS", "FAIL")
        
        file write ptfile "`modelnum',`var',NonLog,No,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
        
        display "  DiD Coef: " %6.3f (`did_coef') "  PT p-value: " %6.4f (`pt_p') " [`pt_result']"
        
        // WITH CONTROLS
        quietly didregress (`var' $controls) (did_robust1), group(District) time(SubRound)
        didregress
        estimates store m`modelnum'b
        
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
        
        file write ptfile "`modelnum',`var',NonLog,Yes,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
        
        display "  With Controls - DiD Coef: " %6.3f (`did_coef') "  PT p-value: " %6.4f (`pt_p') " [`pt_result']"
        
        local modelnum = `modelnum' + 1
    }
}

// LOG VARIABLES
foreach var in ln_Food ln_Food_PC ln_Fuel ln_Fuel_PC ln_Clothing ln_Clothing_PC ///
                ln_Footwear ln_Footwear_PC ln_Durable ln_Durable_PC ln_Misc ln_Misc_PC ln_MPCE_Own {
    
    capture confirm variable `var'
    if !_rc {
        display _newline "Model `modelnum': `var' (Log)"
        
        // WITHOUT CONTROLS
        quietly didregress (`var') (did_robust1), group(District) time(SubRound)
        didregress
        estimates store m`modelnum'a
        
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
        
        file write ptfile "`modelnum',`var',Log,No,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
        
        display "  DiD Coef: " %6.3f (`did_coef') "  PT p-value: " %6.4f (`pt_p') " [`pt_result']"
        
        // WITH CONTROLS
        quietly didregress (`var' $controls) (did_robust1), group(District) time(SubRound)
        didregress
        estimates store m`modelnum'b
        
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
        
        file write ptfile "`modelnum',`var',Log,Yes,`did_coef',`did_se',`did_p',`pt_chi2',`pt_p',`pt_result',`n',`r2'" _n
        
        display "  With Controls - DiD Coef: " %6.3f (`did_coef') "  PT p-value: " %6.4f (`pt_p') " [`pt_result']"
        
        local modelnum = `modelnum' + 1
    }
}

file close ptfile

display _newline "✓ Parallel trends results saved to: ShortRun_ParallelTrends_Results.csv"

// ==============================================================================
// CLOTHING EXPERIMENTS WITH PT
// ==============================================================================

display _newline(2)
display "================================================================================"
display "CLOTHING PC EXPERIMENTS"
display "================================================================================"

capture file close clothfile
file open clothfile using "ShortRun_Clothing_PT_Results.csv", write replace
file write clothfile "Experiment,Description,DiD_Coef,DiD_SE,DiD_PValue,PT_Chi2,PT_PValue,PT_Result,N,R2" _n

// Experiment 1
quietly didregress (ln_Clothing_PC HHSize) (did_robust1), group(District) time(SubRound)
matrix b = e(b)
matrix V = e(V)
local d1 = b[1,1]
local s1 = sqrt(V[1,1])
local p1 = 2*ttail(e(df_r), abs(`d1'/`s1'))
local n1 = e(N)
local r21 = e(r2)
quietly estat ptrends
local pc1 = r(chi2)
local pp1 = r(p)
local pr1 = cond(`pp1' > 0.05, "PASS", "FAIL")
file write clothfile "1,Minimal (HHSize),`d1',`s1',`p1',`pc1',`pp1',`pr1',`n1',`r21'" _n
display "Exp 1: DiD=" %6.3f (`d1') " p=" %6.4f (`p1') " | PT p=" %6.4f (`pp1') " [`pr1']"
estimates store cloth_exp1

// Experiment 2
quietly didregress (ln_Clothing_PC HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education) ///
                   (did_robust1), group(District) time(SubRound)
matrix b = e(b)
matrix V = e(V)
local d2 = b[1,1]
local s2 = sqrt(V[1,1])
local p2 = 2*ttail(e(df_r), abs(`d2'/`s2'))
local n2 = e(N)
local r22 = e(r2)
quietly estat ptrends
local pc2 = r(chi2)
local pp2 = r(p)
local pr2 = cond(`pp2' > 0.05, "PASS", "FAIL")
file write clothfile "2,Demographic,`d2',`s2',`p2',`pc2',`pp2',`pr2',`n2',`r22'" _n
display "Exp 2: DiD=" %6.3f (`d2') " p=" %6.4f (`p2') " | PT p=" %6.4f (`pp2') " [`pr2']"
estimates store cloth_exp2

// Experiment 3
quietly didregress (ln_Clothing_PC HH_Type_Agri Ration_Type_new i.Sector) ///
                   (did_robust1), group(District) time(SubRound)
matrix b = e(b)
matrix V = e(V)
local d3 = b[1,1]
local s3 = sqrt(V[1,1])
local p3 = 2*ttail(e(df_r), abs(`d3'/`s3'))
local n3 = e(N)
local r23 = e(r2)
quietly estat ptrends
local pc3 = r(chi2)
local pp3 = r(p)
local pr3 = cond(`pp3' > 0.05, "PASS", "FAIL")
file write clothfile "3,Economic,`d3',`s3',`p3',`pc3',`pp3',`pr3',`n3',`r23'" _n
display "Exp 3: DiD=" %6.3f (`d3') " p=" %6.4f (`p3') " | PT p=" %6.4f (`pp3') " [`pr3']"
estimates store cloth_exp3

// Experiment 4
quietly didregress (ln_Clothing_PC Social_Group_new i.Religion_new i.Dwelling_Unit_new) ///
                   (did_robust1), group(District) time(SubRound)
matrix b = e(b)
matrix V = e(V)
local d4 = b[1,1]
local s4 = sqrt(V[1,1])
local p4 = 2*ttail(e(df_r), abs(`d4'/`s4'))
local n4 = e(N)
local r24 = e(r2)
quietly estat ptrends
local pc4 = r(chi2)
local pp4 = r(p)
local pr4 = cond(`pp4' > 0.05, "PASS", "FAIL")
file write clothfile "4,Social,`d4',`s4',`p4',`pc4',`pp4',`pr4',`n4',`r24'" _n
display "Exp 4: DiD=" %6.3f (`d4') " p=" %6.4f (`p4') " | PT p=" %6.4f (`pp4') " [`pr4']"
estimates store cloth_exp4

// Experiment 5
quietly didregress (ln_Clothing_PC HH_Type_Agri Social_Group_new Ration_Type_new ///
                    i.Dwelling_Unit_new HHSize HH_AdultFemaleProp ///
                    HH_Head_Age HH_Head_Education i.Religion_new) ///
                   (did_robust1), group(District) time(SubRound)
matrix b = e(b)
matrix V = e(V)
local d5 = b[1,1]
local s5 = sqrt(V[1,1])
local p5 = 2*ttail(e(df_r), abs(`d5'/`s5'))
local n5 = e(N)
local r25 = e(r2)
quietly estat ptrends
local pc5 = r(chi2)
local pp5 = r(p)
local pr5 = cond(`pp5' > 0.05, "PASS", "FAIL")
file write clothfile "5,Full-NoSector,`d5',`s5',`p5',`pc5',`pp5',`pr5',`n5',`r25'" _n
display "Exp 5: DiD=" %6.3f (`d5') " p=" %6.4f (`p5') " | PT p=" %6.4f (`pp5') " [`pr5']"
estimates store cloth_exp5

// Experiment 6
quietly didregress (ln_Clothing_PC HH_Type_Agri Social_Group_new Ration_Type_new ///
                    i.Dwelling_Unit_new HHSize HH_AdultFemaleProp ///
                    HH_Head_Age HH_Head_Education i.Sector) ///
                   (did_robust1), group(District) time(SubRound)
matrix b = e(b)
matrix V = e(V)
local d6 = b[1,1]
local s6 = sqrt(V[1,1])
local p6 = 2*ttail(e(df_r), abs(`d6'/`s6'))
local n6 = e(N)
local r26 = e(r2)
quietly estat ptrends
local pc6 = r(chi2)
local pp6 = r(p)
local pr6 = cond(`pp6' > 0.05, "PASS", "FAIL")
file write clothfile "6,Full-NoReligion,`d6',`s6',`p6',`pc6',`pp6',`pr6',`n6',`r26'" _n
display "Exp 6: DiD=" %6.3f (`d6') " p=" %6.4f (`p6') " | PT p=" %6.4f (`pp6') " [`pr6']"
estimates store cloth_exp6

// Experiment 7
quietly didregress (ln_Clothing_PC HH_Type_Agri Social_Group_new Ration_Type_new ///
                    HHSize HH_AdultFemaleProp ///
                    HH_Head_Age HH_Head_Education i.Religion_new i.Sector) ///
                   (did_robust1), group(District) time(SubRound)
matrix b = e(b)
matrix V = e(V)
local d7 = b[1,1]
local s7 = sqrt(V[1,1])
local p7 = 2*ttail(e(df_r), abs(`d7'/`s7'))
local n7 = e(N)
local r27 = e(r2)
quietly estat ptrends
local pc7 = r(chi2)
local pp7 = r(p)
local pr7 = cond(`pp7' > 0.05, "PASS", "FAIL")
file write clothfile "7,Full-NoDwelling,`d7',`s7',`p7',`pc7',`pp7',`pr7',`n7',`r27'" _n
display "Exp 7: DiD=" %6.3f (`d7') " p=" %6.4f (`p7') " | PT p=" %6.4f (`pp7') " [`pr7']"
estimates store cloth_exp7

// Experiment 8
quietly didregress (ln_Clothing_PC HH_Type_Agri Social_Group_new ///
                    HHSize HH_Head_Education i.Sector) ///
                   (did_robust1), group(District) time(SubRound)
matrix b = e(b)
matrix V = e(V)
local d8 = b[1,1]
local s8 = sqrt(V[1,1])
local p8 = 2*ttail(e(df_r), abs(`d8'/`s8'))
local n8 = e(N)
local r28 = e(r2)
quietly estat ptrends
local pc8 = r(chi2)
local pp8 = r(p)
local pr8 = cond(`pp8' > 0.05, "PASS", "FAIL")
file write clothfile "8,Core,`d8',`s8',`p8',`pc8',`pp8',`pr8',`n8',`r28'" _n
display "Exp 8: DiD=" %6.3f (`d8') " p=" %6.4f (`p8') " | PT p=" %6.4f (`pp8') " [`pr8']"
estimates store cloth_exp8

file close clothfile

display _newline "✓ Clothing experiments saved to: ShortRun_Clothing_PT_Results.csv"

// ==============================================================================
// DETERMINANTS
// ==============================================================================

display _newline(2)
display "================================================================================"
display "DETERMINANTS OF CONSUMPTION"
display "================================================================================"

global det_controls HH_Type_Agri Social_Group_new Ration_Type_new ///
                    i.Dwelling_Unit_new HHSize HH_AdultFemaleProp ///
                    HH_Head_Age HH_Head_Education i.Religion_new i.Sector

// FOOD
quietly reg ln_Food_PC $det_controls if after_tsunami==0 & robust_treat1==0, robust
estimates store det_food_c0
quietly reg ln_Food_PC $det_controls if after_tsunami==0 & robust_treat1==1, robust
estimates store det_food_t0
quietly reg ln_Food_PC $det_controls if after_tsunami==1 & robust_treat1==0, robust
estimates store det_food_c1
quietly reg ln_Food_PC $det_controls if after_tsunami==1 & robust_treat1==1, robust
estimates store det_food_t1
quietly reg ln_Food_PC robust_treat1 $det_controls if after_tsunami==0, robust
estimates store det_food_pool0
quietly reg ln_Food_PC robust_treat1 $det_controls if after_tsunami==1, robust
estimates store det_food_pool1

// FUEL
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

// CLOTHING
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

// ==============================================================================
// EXPORT ALL RESULTS
// ==============================================================================

display _newline(2)
display "================================================================================"
display "EXPORTING RESULTS"
display "================================================================================"

esttab m2a m2b m4a m4b m6a m6b m8a m8b m10a m10b m12a m12b ///
       using "ShortRun_DID_NonLog_PerCapita.csv", ///
       b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N r2 F) ///
       mtitles("Food" "Food+C" "Fuel" "Fuel+C" "Cloth" "Cloth+C" ///
               "Footwear" "Footwear+C" "Durable" "Durable+C" "Misc" "Misc+C") ///
       replace csv
display "✓ ShortRun_DID_NonLog_PerCapita.csv"

esttab m15a m15b m17a m17b m19a m19b m21a m21b m23a m23b m25a m25b ///
       using "ShortRun_DID_Log_PerCapita.csv", ///
       b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N r2 F) ///
       mtitles("Food" "Food+C" "Fuel" "Fuel+C" "Cloth" "Cloth+C" ///
               "Footwear" "Footwear+C" "Durable" "Durable+C" "Misc" "Misc+C") ///
       replace csv
display "✓ ShortRun_DID_Log_PerCapita.csv"

esttab cloth_exp1 cloth_exp2 cloth_exp3 cloth_exp4 cloth_exp5 cloth_exp6 cloth_exp7 cloth_exp8 ///
       using "ShortRun_Clothing_PC_Experiments.csv", ///
       b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N r2 F) ///
       replace csv
display "✓ ShortRun_Clothing_PC_Experiments.csv"

esttab det_food_c0 det_food_t0 det_food_c1 det_food_t1 det_food_pool0 det_food_pool1 ///
       using "ShortRun_Determinants_Food_PC.csv", ///
       b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N r2 F) ///
       replace csv
display "✓ ShortRun_Determinants_Food_PC.csv"

esttab det_fuel_c0 det_fuel_t0 det_fuel_c1 det_fuel_t1 det_fuel_pool0 det_fuel_pool1 ///
       using "ShortRun_Determinants_Fuel_PC.csv", ///
       b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N r2 F) ///
       replace csv
display "✓ ShortRun_Determinants_Fuel_PC.csv"

esttab det_cloth_c0 det_cloth_t0 det_cloth_c1 det_cloth_t1 det_cloth_pool0 det_cloth_pool1 ///
       using "ShortRun_Determinants_Clothing_PC.csv", ///
       b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N r2 F) ///
       replace csv
display "✓ ShortRun_Determinants_Clothing_PC.csv"

// ==============================================================================
// COMPLETION
// ==============================================================================

display _newline(2)
display "================================================================================"
display "✓✓✓ ANALYSIS COMPLETE ✓✓✓"
display "================================================================================"
display ""
display "14 FILES CREATED:"
display "  - 6 Word files (descriptive statistics)"
display "  - 8 CSV files (regression results)"
display ""
display "KEY NEW FEATURES:"
display "  ✓ ShortRun_ParallelTrends_Results.csv - ALL PT p-values!"
display "  ✓ ShortRun_Clothing_PT_Results.csv - Clothing experiments with PT!"
display "  ✓ F-statistics included in all CSV exports"
display ""
display "NEXT STEP: Open the CSV files to see parallel trends p-values!"
display "================================================================================"
