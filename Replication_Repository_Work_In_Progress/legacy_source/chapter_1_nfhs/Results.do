** Summary Statistics (Table 1a, 1b and 1c and Table 2a, 2b and 2c) **

cap log close _all
clear all
macro drop _all
set more off
set type double
set linesize 120
         

di "Loading data from: $data_dir"

* Ensure file directory exists
capture mkdir "$data_dir"

* Check if file exists before loading data
capture confirm file "$data_dir/Appended Data/Main_Data.dta"
if _rc != 0 {
    di "ERROR: File `Main_Data.dta` not found in $data_dir"
    exit 198
}

* Load dataset
use "$data_dir/Appended Data/Main_Data.dta", clear

* Check if dataset is loaded
describe

* Ensure `DHSRound_num` exists before proceeding
capture confirm variable DHSRound_num
if _rc != 0 {
    di "ERROR: `DHSRound_num` variable is missing from the dataset."
    exit 198
}

* Get unique DHS rounds
levelsof DHSRound_num, local(dhs_rounds)
di "DHS Rounds found: `dhs_rounds'"

* Define lists of variables
global ylist we_decide_hhpurch we_decide_health  we_decide_visits
global xlist Education_respondent we_empl religion Education_partner hs_empl wealth_index massmedia sector State

foreach round in `dhs_rounds' {
    di "Processing DHS Round: `round'"

    * Reload dataset
    use "$data_dir/Appended Data/Main_Data.dta", clear

    * Keep only the current DHS Round
    keep if DHSRound_num == `round'

    * Ensure there are observations before proceeding
    if _N == 0 {
        di "Skipping DHS Round `round' (no observations)"
        continue
    }

    foreach yvar in $ylist {
        di ""
        di "---------------------------------------------------------"
        di "Decision Making Power on `yvar' - DHS Round `round'"
        di "---------------------------------------------------------"

        foreach xvar in $xlist {
            di "Tabulating `xvar' by `yvar' for DHS Round `round'"

            * Perform cross-tabulation and show total observations
            
             tab `xvar' `yvar', row matcell(obs_result)

            di "---------------------------------------------------------"
        }
    }
}

di "✅ All DHS rounds processed successfully."

** +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  **

set more off
clear all

di "Loading data from: $data_dir"

* Ensure directory exists
capture mkdir "$data_dir"

* Check if file exists before loading
capture confirm file "$data_dir/Appended Data/Main_Data.dta"
if _rc != 0 {
    di as error "ERROR: File `Main_Data.dta` not found in $data_dir"
    exit 198
}

* Load the dataset
use "$data_dir/Appended Data/Main_Data.dta", clear

* Confirm Birth_Cohort variable exists
capture confirm variable Birth_Cohort
if _rc != 0 {
    di as error "ERROR: Birth_Cohort variable not found."
    exit 198
}

* Display tabulation with and without labels
tab Birth_Cohort
tab Birth_Cohort, nolabel

* Capture numeric codes (for looping)
levelsof Birth_Cohort, local(cohorts)
di "Numeric Birth Cohort codes found: `cohorts'"

* Store value label name
local cohort_lbl : value label Birth_Cohort

* Define variable lists
global ylist we_decide_hhpurch we_decide_health  we_decide_visits
global xlist Education_respondent we_empl religion Education_partner hs_empl wealth_index massmedia sector State

* ==== FULL SAMPLE ====
di ""
di "========================================================="
di "Descriptive statistics for FULL SAMPLE"
di "========================================================="

foreach yvar in $ylist {
    di ""
    di ">>> Outcome variable: `yvar' (Full sample)"
    foreach xvar in $xlist {
        di "Tabulating: `xvar' by `yvar'"
        tab `xvar' `yvar', row matcell(obs_result)
        di "---------------------------------------------------------"
    }
}

* ==== LOOP OVER COHORTS ====
foreach cohort in `cohorts' {
    * Get label from value label
    local cohort_label : label `cohort_lbl' `cohort'

    di ""
    di "========================================================="
    di "Descriptive statistics for Birth Cohort: `cohort_label'"
    di "========================================================="

    * Reload dataset
    use "$data_dir/Appended Data/Main_Data.dta", clear
    keep if Birth_Cohort == `cohort'

    if _N == 0 {
        di "⚠️ No data for cohort: `cohort_label' (code=`cohort')"
        continue
    }

    foreach yvar in $ylist {
        di ""
        di ">>> Outcome variable: `yvar' - Cohort: `cohort_label'"
        foreach xvar in $xlist {
            di "Tabulating: `xvar' by `yvar' - Cohort: `cohort_label'"
            tab `xvar' `yvar', row matcell(obs_result)
            di "---------------------------------------------------------"
        }
    }
}

di "✅ All birth cohorts processed successfully."



** Full Sample Regression **
set more off
clear all


////  RESPONDENT + JOINT (TABLE 3a, 3b and 3c in the Paper) ////

* Load data
use "$data_dir/Appended Data/Main_Data.dta", clear

* Define full control variable list
global controls i.Education_respondent i.we_empl i.religion i.Education_partner i.hs_empl ///
                current_age age_difference hh_size i.wealth_index i.massmedia i.sector ///
                i.State2 i.DHSRound_num

* ----------------------------
* we_decide_hhpurch_b → hhpurch_b.doc
* ----------------------------
global ylist we_decide_hhpurch_b
global xlist i.religion

probit $ylist $xlist
margins, dydx(*) post
outreg2 using hhpurch_b.doc, replace label ctitle("Religion") title("Table 1: HH Purchase B")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using hhpurch_b.doc, append label ctitle("`yr'")
}

global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using hhpurch_b.doc, append label ctitle("All_Controls")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using hhpurch_b.doc, append label ctitle("`yr'")
}

* ----------------------------
* we_decide_health_b → health_b.doc
* ----------------------------
global ylist we_decide_health_b
global xlist i.religion

probit $ylist $xlist
margins, dydx(*) post
outreg2 using health_b.doc, replace label ctitle("Religion") title("Table 2: Health B")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using health_b.doc, append label ctitle("`yr'")
}

global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using health_b.doc, append label ctitle("All_Controls")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using health_b.doc, append label ctitle("`yr'")
}

* ----------------------------
* we_decide_visits_b → visits_b.doc
* ----------------------------
global ylist we_decide_visits_b
global xlist i.religion

probit $ylist $xlist
margins, dydx(*) post
outreg2 using visits_b.doc, replace label ctitle("Religion") title("Table 3: Visits B")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using visits_b.doc, append label ctitle("`yr'")
}

global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using visits_b.doc, append label ctitle("All_Controls")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using visits_b.doc, append label ctitle("`yr'")
}



//// RESPONDENT ONLY (TABLE 4a, 4b and 4c in the Paper)/////

* Load data
use "$data_dir/Appended Data/Main_Data.dta", clear

* Define full control variable list
global controls i.Education_respondent i.we_empl i.religion i.Education_partner i.hs_empl ///
                current_age age_difference hh_size i.wealth_index i.massmedia i.sector ///
                i.State2 i.DHSRound_num

* ----------------------------
* we_decide_hhpurch_a → hhpurch_a.doc
* ----------------------------
global ylist we_decide_hhpurch_a
global xlist i.religion

probit $ylist $xlist
margins, dydx(*) post
outreg2 using hhpurch_a.doc, replace label ctitle("Religion") title("Table 4: HH Purchase A")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using hhpurch_a.doc, append label ctitle("`yr'")
}

global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using hhpurch_a.doc, append label ctitle("All_Controls")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using hhpurch_a.doc, append label ctitle("`yr'")
}

* ----------------------------
* we_decide_health_a → health_a.doc
* ----------------------------
global ylist we_decide_health_a
global xlist i.religion

probit $ylist $xlist
margins, dydx(*) post
outreg2 using health_a.doc, replace label ctitle("Religion") title("Table 5: Health A")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using health_a.doc, append label ctitle("`yr'")
}

global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using health_a.doc, append label ctitle("All_Controls")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using health_a.doc, append label ctitle("`yr'")
}

* ----------------------------
* we_decide_visits_a → visits_a.doc
* ----------------------------
global ylist we_decide_visits_a
global xlist i.religion

probit $ylist $xlist
margins, dydx(*) post
outreg2 using visits_a.doc, replace label ctitle("Religion") title("Table 6: Visits A")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using visits_a.doc, append label ctitle("`yr'")
}

global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using visits_a.doc, append label ctitle("All_Controls")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using visits_a.doc, append label ctitle("`yr'")
}



** Muslim Sample **
set more off
clear all


////  RESPONDENT + JOINT  ////

* Load data
use "$data_dir/Appended Data/Main_Data.dta", clear
tab Religion_New
keep if  Religion_New==2

* Define full control variable list
global controls i.Education_respondent i.we_empl i.Education_partner i.hs_empl ///
                current_age age_difference hh_size i.wealth_index i.massmedia i.sector ///
                i.State2 i.DHSRound_num

* ----------------------------
* we_decide_hhpurch_b → hhpurch_m.doc
* ----------------------------
global ylist we_decide_hhpurch_b
global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using hhpurch_m.doc, replace label ctitle("All_Controls")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using hhpurch_m.doc, append label ctitle("`yr'")
}

* ----------------------------
* we_decide_health_b → health_m.doc
* ----------------------------
global ylist we_decide_health_b
global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using health_m.doc, replace label ctitle("All_Controls")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using health_m.doc, append label ctitle("`yr'")
}

* ----------------------------
* we_decide_visits_b → visits_m.doc
* ----------------------------
global ylist we_decide_visits_b
global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using visits_m.doc, replace label ctitle("All_Controls")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using visits_m.doc, append label ctitle("`yr'")
}



//// RESPONDENT ONLY /////

* Load data
use "$data_dir/Appended Data/Main_Data.dta", clear
tab Religion_New
keep if  Religion_New==2


* Define full control variable list
global controls i.Education_respondent i.we_empl i.Education_partner i.hs_empl ///
                current_age age_difference hh_size i.wealth_index i.massmedia i.sector ///
                i.State2 i.DHSRound_num

* ----------------------------
* we_decide_hhpurch_a → hhpurch_m.doc
* ----------------------------
global ylist we_decide_hhpurch_a
global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using hhpurch_m.doc, append label ctitle("All_Controls")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using hhpurch_m.doc, append label ctitle("`yr'")
}

* ----------------------------
* we_decide_health_a → health_m.doc
* ----------------------------
global ylist we_decide_health_a
global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using health_m.doc, append label ctitle("All_Controls")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using health_m.doc, append label ctitle("`yr'")
}

* ----------------------------
* we_decide_visits_a → visits_m.doc
* ----------------------------
global ylist we_decide_visits_a
global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using visits_m.doc, append label ctitle("All_Controls")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using visits_m.doc, append label ctitle("`yr'")
}


** Other Religion Sample **
set more off
clear all


////  RESPONDENT + JOINT  ////

* Load data
use "$data_dir/Appended Data/Main_Data.dta", clear
tab Religion_New
keep if  Religion_New==1

* Define full control variable list
global controls i.Education_respondent i.we_empl i.Education_partner i.hs_empl ///
                current_age age_difference hh_size i.wealth_index i.massmedia i.sector ///
                i.State2 i.DHSRound_num

* ----------------------------
* we_decide_hhpurch_b → hhpurch_o.doc
* ----------------------------
global ylist we_decide_hhpurch_b
global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using hhpurch_o.doc, replace label ctitle("Respondent + Joint")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using hhpurch_o.doc, append label ctitle("`yr'")
}

* ----------------------------
* we_decide_health_b → health_o.doc
* ----------------------------
global ylist we_decide_health_b
global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using health_o.doc, replace label ctitle("Respondent + Joint")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using health_o.doc, append label ctitle("`yr'")
}

* ----------------------------
* we_decide_visits_b → visits_o.doc
* ----------------------------
global ylist we_decide_visits_b
global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using visits_o.doc, replace label ctitle("Respondent + Joint")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using visits_o.doc, append label ctitle("`yr'")
}



//// RESPONDENT ONLY /////

* Load data
use "$data_dir/Appended Data/Main_Data.dta", clear
tab Religion_New
keep if  Religion_New==1


* Define full control variable list
global controls i.Education_respondent i.we_empl i.Education_partner i.hs_empl ///
                current_age age_difference hh_size i.wealth_index i.massmedia i.sector ///
                i.State2 i.DHSRound_num

* ----------------------------
* we_decide_hhpurch_a → hhpurch_o.doc
* ----------------------------
global ylist we_decide_hhpurch_a
global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using hhpurch_o.doc, append label ctitle("Respondent")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using hhpurch_o.doc, append label ctitle("`yr'")
}

* ----------------------------
* we_decide_health_a → health_o.doc
* ----------------------------
global ylist we_decide_health_a
global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using health_o.doc, append label ctitle("Respondent")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using health_o.doc, append label ctitle("`yr'")
}

* ----------------------------
* we_decide_visits_a → visits_o.doc
* ----------------------------
global ylist we_decide_visits_a
global xlist $controls

probit $ylist $xlist
margins, dydx(*) post
outreg2 using visits_o.doc, append label ctitle("Respondent")

foreach yr in 1956 1966 1976 1986 {
    probit $ylist $xlist if Birth_Cohort==`yr'
    margins, dydx(*) post
    outreg2 using visits_o.doc, append label ctitle("`yr'")
}

