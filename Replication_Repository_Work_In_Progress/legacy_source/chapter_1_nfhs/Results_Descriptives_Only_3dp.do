/****************************************************************************************
 Descriptive tables only
 - Skips all regressions
 - Reports row percentages to 3 decimal places
 - Exports the descriptive tables to a Word document: Descriptive_Tables.docx
 - Only loads the data once at the top
****************************************************************************************/



* -----------------------------------------------------------------------------
* Variable lists
* -----------------------------------------------------------------------------
global ylist we_decide_hhpurch we_decide_health we_decide_visits
global xlist Education_respondent we_empl religion Education_partner hs_empl ///
             wealth_index massmedia sector State

* -----------------------------------------------------------------------------
* Helper program: creates one cross-tabulation table in Word
* -----------------------------------------------------------------------------
capture program drop add_crosstab
program define add_crosstab
    version 17
    syntax varlist(min=2 max=2) [if]

    tokenize `varlist'
    local xvar `1'
    local yvar `2'

    local xlab : variable label `xvar'
    if "`xlab'" == "" local xlab "`xvar'"

    local ylab : variable label `yvar'
    if "`ylab'" == "" local ylab "`yvar'"

    marksample touse

    preserve
        keep if `touse'
        keep if !missing(`xvar') & !missing(`yvar')

        quietly count
        local validN = r(N)

        putdocx paragraph, style(Heading3)
        putdocx text ("`xlab' by `ylab'"), bold

        if `validN' == 0 {
            putdocx paragraph
            putdocx text ("No valid observations for this table.")
            restore
            exit
        }

        contract `xvar' `yvar', freq(N)
        bysort `xvar': egen RowTotal = total(N)
        gen RowPct = 100 * N / RowTotal
        format RowPct %9.3f

        * Convert x-variable categories to readable labels where possible
        capture confirm string variable `xvar'
        if _rc == 0 {
            gen strL Category = `xvar'
        }
        else {
            local xvallab : value label `xvar'
            if "`xvallab'" != "" {
                decode `xvar', gen(Category)
            }
            else {
                gen strL Category = string(`xvar', "%12.0g")
            }
        }

        * Convert outcome categories to readable labels where possible
        capture confirm string variable `yvar'
        if _rc == 0 {
            gen strL Outcome = `yvar'
        }
        else {
            local yvallab : value label `yvar'
            if "`yvallab'" != "" {
                decode `yvar', gen(Outcome)
            }
            else {
                gen strL Outcome = string(`yvar', "%12.0g")
            }
        }

        keep Category Outcome N RowPct
        order Category Outcome N RowPct
        label variable Category "Category"
        label variable Outcome  "Outcome"
        label variable N        "Obs."
        label variable RowPct   "Row %"

        putdocx table Tbl${tblno} = data(Category Outcome N RowPct), varnames
        putdocx table Tbl${tblno}(1,.), bold shading(D9EAF7)
        putdocx table Tbl${tblno}(.,1), width(2.35)
        putdocx table Tbl${tblno}(.,2), width(2.00)
        putdocx table Tbl${tblno}(.,3), width(0.75)
        putdocx table Tbl${tblno}(.,4), width(0.85)
        putdocx paragraph

        global tblno = ${tblno} + 1
    restore
end

* -----------------------------------------------------------------------------
* Confirm variables required for descriptive tables
* -----------------------------------------------------------------------------
foreach var in $ylist $xlist DHSRound_num Birth_Cohort {
    capture confirm variable `var'
    if _rc != 0 {
        di as error "Variable `var' is missing from the dataset."
        exit 198
    }
}

* Capture levels for section tables
levelsof DHSRound_num, local(dhs_rounds)
levelsof Birth_Cohort, local(cohorts)

local dhs_lbl : value label DHSRound_num
local cohort_lbl : value label Birth_Cohort

global tblno = 1
capture putdocx clear
putdocx begin, pagesize(A4) font("Times New Roman", 10)

putdocx paragraph, style(Title)
putdocx text ("Descriptive Tables")
putdocx paragraph
putdocx text ("All row percentages are reported to three decimal places. Regressions are skipped."), italic

* -----------------------------------------------------------------------------
* FULL SAMPLE DESCRIPTIVES
* -----------------------------------------------------------------------------
putdocx paragraph, style(Heading1)
putdocx text ("Table 1: Full Sample Descriptive Statistics")

foreach yvar in $ylist {
    local ylab : variable label `yvar'
    if "`ylab'" == "" local ylab "`yvar'"

    putdocx paragraph, style(Heading2)
    putdocx text ("Outcome: `ylab'")

    foreach xvar in $xlist {
        add_crosstab `xvar' `yvar'
    }
}

* -----------------------------------------------------------------------------
* DESCRIPTIVES BY DHS ROUND
* -----------------------------------------------------------------------------
putdocx paragraph, style(Heading1)
putdocx text ("Table 2: Descriptive Statistics by DHS Round")

foreach round of local dhs_rounds {
    if "`dhs_lbl'" != "" {
        local round_label : label `dhs_lbl' `round'
    }
    else {
        local round_label "`round'"
    }

    putdocx paragraph, style(Heading2)
    putdocx text ("DHS Round: `round_label'")

    foreach yvar in $ylist {
        local ylab : variable label `yvar'
        if "`ylab'" == "" local ylab "`yvar'"

        putdocx paragraph, style(Heading3)
        putdocx text ("Outcome: `ylab'")

        foreach xvar in $xlist {
            add_crosstab `xvar' `yvar' if DHSRound_num == `round'
        }
    }
}

* -----------------------------------------------------------------------------
* DESCRIPTIVES BY BIRTH COHORT
* -----------------------------------------------------------------------------
putdocx paragraph, style(Heading1)
putdocx text ("Table 3: Descriptive Statistics by Birth Cohort")

foreach cohort of local cohorts {
    if "`cohort_lbl'" != "" {
        local cohort_label : label `cohort_lbl' `cohort'
    }
    else {
        local cohort_label "`cohort'"
    }

    putdocx paragraph, style(Heading2)
    putdocx text ("Birth Cohort: `cohort_label'")

    foreach yvar in $ylist {
        local ylab : variable label `yvar'
        if "`ylab'" == "" local ylab "`yvar'"

        putdocx paragraph, style(Heading3)
        putdocx text ("Outcome: `ylab'")

        foreach xvar in $xlist {
            add_crosstab `xvar' `yvar' if Birth_Cohort == `cohort'
        }
    }
}

putdocx save "Descriptive_Tables.docx", replace

di as result "Descriptive tables saved as: Descriptive_Tables.docx"
di as result "All row percentages are displayed to 3 decimal places. No regressions were run."
