/****************************************************************************************
 Descriptive Statistics Tables Only
 - Produces Word tables in landscape format
 - Times New Roman, 12 pt
 - Percentages reported to 3 decimal places
 - Regressions skipped
 - Data loaded once only
****************************************************************************************/

clear all
set more off
set type double

* Load data only
use "Main_Data.dta", clear

* -------------------------------------------------------------------
* User settings: decision-making category codes
* Change these only if your coding is different.
* -------------------------------------------------------------------
global DM_CODES 1 2 3
global DM_COL1 "Resp. Only"
global DM_COL2 "Joint"
global DM_COL3 "Husb. Only"

* Decision-making outcomes
global YVARS  we_decide_hhpurch we_decide_health we_decide_visits
global YTITLES `""Large Household Purchases" "Healthcare" "Visits to Family or Relatives""'
global TSUFF   a b c

* Row variables, in the same order as the screenshot tables
global XVARLIST religion Education_respondent we_empl Education_partner hs_empl wealth_index massmedia sector

* -------------------------------------------------------------------
* Basic checks
* -------------------------------------------------------------------
foreach v in DHSRound_num Birth_Cohort $YVARS $XVARLIST {
    capture confirm variable `v'
    if _rc {
        di as error "Required variable `v' is missing. Please check variable names."
        exit 111
    }
}

* DHS round codes: first three sorted values are treated as NFHS 3, 4, 5
levelsof DHSRound_num if !missing(DHSRound_num), local(rounds)
local nrounds : word count `rounds'
if `nrounds' < 3 {
    di as error "DHSRound_num has fewer than three non-missing round codes."
    exit 459
}
global ROUND_CODE1 : word 1 of `rounds'
global ROUND_CODE2 : word 2 of `rounds'
global ROUND_CODE3 : word 3 of `rounds'
global ROUND_LABEL1 "NFHS 3 (DHS Round Wave 1: 2005-06)"
global ROUND_LABEL2 "NFHS 4 (DHS Round Wave 2: 2015-16)"
global ROUND_LABEL3 "NFHS 5 (DHS Round Wave 3: 2019-21)"

* Birth cohort codes: first four sorted values are reported after Full Sample
levelsof Birth_Cohort if !missing(Birth_Cohort), local(cohorts)
local ncohorts : word count `cohorts'
if `ncohorts' < 4 {
    di as error "Birth_Cohort has fewer than four non-missing cohort codes."
    exit 459
}
global COHORT_CODE1 : word 1 of `cohorts'
global COHORT_CODE2 : word 2 of `cohorts'
global COHORT_CODE3 : word 3 of `cohorts'
global COHORT_CODE4 : word 4 of `cohorts'
global COHORT_LABEL0 "Full Sample"
global COHORT_LABEL1 "1956-65"
global COHORT_LABEL2 "1966-75"
global COHORT_LABEL3 "1976-85"
global COHORT_LABEL4 "1986-2005"

* -------------------------------------------------------------------
* Helper program: returns row percentages for decision-making categories
* and the number of non-missing observations for the outcome.
* -------------------------------------------------------------------
capture program drop _dmstats
program define _dmstats, rclass
    syntax varname, Condition(string asis)

    local yvar `varlist'
    quietly count if (`condition') & !missing(`yvar')
    local den = r(N)
    return scalar N = `den'

    forvalues j = 1/3 {
        local code : word `j' of $DM_CODES
        if `den' > 0 {
            quietly count if (`condition') & !missing(`yvar') & `yvar' == `code'
            return scalar p`j' = 100*r(N)/`den'
        }
        else {
            return scalar p`j' = .
        }
    }
end

* -------------------------------------------------------------------
* Helper program: inserts one row of statistics into a putdocx table.
* -------------------------------------------------------------------
capture program drop _putstats
program define _putstats
    syntax, Table(name) Row(integer) Startcol(integer) Yvar(name) Condition(string asis)

    _dmstats `yvar', condition("`condition'")

    forvalues j = 1/3 {
        local c = `startcol' + `j' - 1
        if r(N) > 0 {
            local s = string(r(p`j'), "%9.3f")
        }
        else {
            local s ""
        }
        putdocx table `table'(`row',`c') = ("`s'"), halign(center) valign(center)
    }

    local cobs = `startcol' + 3
    if r(N) > 0 {
        local n = string(r(N), "%12.0f")
    }
    else {
        local n ""
    }
    putdocx table `table'(`row',`cobs') = ("`n'"), halign(center) valign(center)
end

* -------------------------------------------------------------------
* Helper program: returns display label for row variable headings.
* -------------------------------------------------------------------
capture program drop _rowheading
program define _rowheading, rclass
    args xvar
    if "`xvar'" == "religion"              return local heading "Religion"
    else if "`xvar'" == "Education_respondent" return local heading "Highest Education Level"
    else if "`xvar'" == "we_empl"          return local heading "Employment"
    else if "`xvar'" == "Education_partner" return local heading "Husband's Education"
    else if "`xvar'" == "hs_empl"          return local heading "Husband's Employment"
    else if "`xvar'" == "wealth_index"     return local heading "Wealth Index"
    else if "`xvar'" == "massmedia"        return local heading "Mass Media Exposure"
    else if "`xvar'" == "sector"           return local heading "Type of Residence"
    else                                    return local heading "`xvar'"
end

* -------------------------------------------------------------------
* Word document setup
* -------------------------------------------------------------------
putdocx clear
putdocx begin, pagesize(A4) landscape font("Times New Roman", 12)

* -------------------------------------------------------------------
* Program: DHS round table, screenshot style
* -------------------------------------------------------------------
capture program drop make_dhs_table
program define make_dhs_table
    syntax, Yvar(name) Title(string) Tnum(string)

    local nrows = 3
    foreach xvar of global XVARLIST {
        quietly levelsof `xvar' if !missing(`xvar'), local(levels)
        local nlev : word count `levels'
        local nrows = `nrows' + 1 + `nlev'
    }
    local ncols = 13

    putdocx paragraph, halign(center) spacing(before, 0) spacing(after, 0)
    putdocx text ("Table 1`tnum' - Descriptive Statistics Across Different DHS Rounds (`title')"), bold

    putdocx table T1`tnum' = (`nrows', `ncols'), border(all, single, black) layout(autofitwindow)
    putdocx table T1`tnum'(.,.), font("Times New Roman", 12)

    * Header row 1
    putdocx table T1`tnum'(1,1) = (""), bold halign(center) valign(center)
    forvalues g = 1/3 {
        local start = 2 + (`g' - 1)*4
        local glab "${ROUND_LABEL`g'}"
        putdocx table T1`tnum'(1,`start') = ("`glab'"), colspan(4) bold halign(center) valign(center)
    }

    * Header row 2
    putdocx table T1`tnum'(2,1) = ("Decision Making Power"), bold halign(center) valign(center)
    forvalues g = 1/3 {
        local start = 2 + (`g' - 1)*4
        putdocx table T1`tnum'(2,`start')     = ("$DM_COL1"), bold halign(center) valign(center)
        putdocx table T1`tnum'(2,`=`start'+1') = ("$DM_COL2"), bold halign(center) valign(center)
        putdocx table T1`tnum'(2,`=`start'+2') = ("$DM_COL3"), bold halign(center) valign(center)
        putdocx table T1`tnum'(2,`=`start'+3') = ("Obs."), bold halign(center) valign(center)
    }

    * Total row
    local row = 3
    putdocx table T1`tnum'(`row',1) = ("Total"), bold halign(center) valign(center)
    forvalues g = 1/3 {
        local start = 2 + (`g' - 1)*4
        local rcode ${ROUND_CODE`g'}
        _putstats, table(T1`tnum') row(`row') startcol(`start') yvar(`yvar') condition("DHSRound_num == `rcode'")
    }

    * Variable blocks
    foreach xvar of global XVARLIST {
        local ++row
        _rowheading `xvar'
        local heading "`r(heading)'"
        putdocx table T1`tnum'(`row',1) = ("`heading'"), bold halign(left) valign(center)

        quietly levelsof `xvar' if !missing(`xvar'), local(levels)
        local vallab : value label `xvar'
        foreach lev of local levels {
            local ++row
            local lab "`lev'"
            if "`vallab'" != "" {
                local tmp : label `vallab' `lev'
                if "`tmp'" != "" local lab "`tmp'"
            }
            putdocx table T1`tnum'(`row',1) = ("`lab'"), halign(left) valign(center)

            forvalues g = 1/3 {
                local start = 2 + (`g' - 1)*4
                local rcode ${ROUND_CODE`g'}
                _putstats, table(T1`tnum') row(`row') startcol(`start') yvar(`yvar') condition("DHSRound_num == `rcode' & `xvar' == `lev'")
            }
        }
    }

    putdocx paragraph, spacing(before, 2) spacing(after, 0)
    putdocx text ("Note: Resp. only refers to decisions made by the respondent alone; Joint refers to joint decision-making; Husb. only refers to decisions made by the husband alone; and Obs. denotes the number of observations."), italic
end

* -------------------------------------------------------------------
* Program: Birth cohort table, screenshot style
* -------------------------------------------------------------------
capture program drop make_cohort_table
program define make_cohort_table
    syntax, Yvar(name) Title(string) Tnum(string)

    local nrows = 3
    foreach xvar of global XVARLIST {
        quietly levelsof `xvar' if !missing(`xvar'), local(levels)
        local nlev : word count `levels'
        local nrows = `nrows' + 1 + `nlev'
    }
    local ncols = 21

    putdocx paragraph, halign(center) spacing(before, 0) spacing(after, 0)
    putdocx text ("Table 2`tnum' - Descriptive Statistics Across Different Birth Cohorts (`title')"), bold

    putdocx table T2`tnum' = (`nrows', `ncols'), border(all, single, black) layout(autofitwindow)
    putdocx table T2`tnum'(.,.), font("Times New Roman", 12)

    * Header row 1
    putdocx table T2`tnum'(1,1) = (""), bold halign(center) valign(center)
    forvalues g = 0/4 {
        local start = 2 + `g'*4
        local glab "${COHORT_LABEL`g'}"
        putdocx table T2`tnum'(1,`start') = ("`glab'"), colspan(4) bold halign(center) valign(center)
    }

    * Header row 2
    putdocx table T2`tnum'(2,1) = ("Decision Making Power"), bold halign(center) valign(center)
    forvalues g = 0/4 {
        local start = 2 + `g'*4
        putdocx table T2`tnum'(2,`start')     = ("$DM_COL1"), bold halign(center) valign(center)
        putdocx table T2`tnum'(2,`=`start'+1') = ("$DM_COL2"), bold halign(center) valign(center)
        putdocx table T2`tnum'(2,`=`start'+2') = ("$DM_COL3"), bold halign(center) valign(center)
        putdocx table T2`tnum'(2,`=`start'+3') = ("Obs."), bold halign(center) valign(center)
    }

    * Total row
    local row = 3
    putdocx table T2`tnum'(`row',1) = ("Total"), bold halign(center) valign(center)
    forvalues g = 0/4 {
        local start = 2 + `g'*4
        if `g' == 0 {
            local cond "1 == 1"
        }
        else {
            local ccode ${COHORT_CODE`g'}
            local cond "Birth_Cohort == `ccode'"
        }
        _putstats, table(T2`tnum') row(`row') startcol(`start') yvar(`yvar') condition("`cond'")
    }

    * Variable blocks
    foreach xvar of global XVARLIST {
        local ++row
        _rowheading `xvar'
        local heading "`r(heading)'"
        putdocx table T2`tnum'(`row',1) = ("`heading'"), bold halign(left) valign(center)

        quietly levelsof `xvar' if !missing(`xvar'), local(levels)
        local vallab : value label `xvar'
        foreach lev of local levels {
            local ++row
            local lab "`lev'"
            if "`vallab'" != "" {
                local tmp : label `vallab' `lev'
                if "`tmp'" != "" local lab "`tmp'"
            }
            putdocx table T2`tnum'(`row',1) = ("`lab'"), halign(left) valign(center)

            forvalues g = 0/4 {
                local start = 2 + `g'*4
                if `g' == 0 {
                    local cond "1 == 1"
                }
                else {
                    local ccode ${COHORT_CODE`g'}
                    local cond "Birth_Cohort == `ccode'"
                }
                _putstats, table(T2`tnum') row(`row') startcol(`start') yvar(`yvar') condition("`cond' & `xvar' == `lev'")
            }
        }
    }

    putdocx paragraph, spacing(before, 2) spacing(after, 0)
    putdocx text ("Note: Resp. only refers to decisions made by the respondent alone; Joint refers to joint decision-making; Husb. only refers to decisions made by the husband alone; and Obs. denotes the number of observations."), italic
end

* -------------------------------------------------------------------
* Generate six descriptive tables: 1a/2a, 1b/2b, 1c/2c
* -------------------------------------------------------------------
local i = 1
foreach yvar of global YVARS {
    local title : word `i' of $YTITLES
    local suff  : word `i' of $TSUFF

    make_dhs_table, yvar(`yvar') title("`title'") tnum("`suff'")
    putdocx pagebreak
    make_cohort_table, yvar(`yvar') title("`title'") tnum("`suff'")

    if `i' < 3 {
        putdocx pagebreak
    }
    local ++i
}

putdocx save "Descriptive_Tables.docx", replace

di as result "Done. Descriptive_Tables.docx has been created with tables in landscape format and percentages to 3 decimal places."
