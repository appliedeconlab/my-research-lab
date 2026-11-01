version 18.0
clear all
set more off
set linesize 200
capture confirm file "README.md"
if _rc {
    display as error "Run from repository root."
    exit 601
}
local clean "data/processed/chapter_1_nfhs/nfhs_analysis_ready.dta"
capture confirm file "`clean'"
if _rc {
    display as error "Cleaned data not found. Run code/chapter_1/stata/01_cleaning.do first."
    exit 601
}
use "`clean'", clear
capture mkdir "output/tables/chapter_1"
capture mkdir "output/figures/chapter_1"
capture mkdir "output/logs"
capture log close
log using "output/logs/chapter_1_analysis_stata.log", text replace

* Source-aligned model controls. Stata factor notation defines categorical terms.
local controls "i.Education_respondent i.we_empl i.religion i.Education_partner i.hs_empl current_age age_difference hh_size i.wealth_index i.massmedia i.sector i.State2 i.DHSRound_num"
local controls_sub "i.Education_respondent i.we_empl i.Education_partner i.hs_empl current_age age_difference hh_size i.wealth_index i.massmedia i.sector i.State2 i.DHSRound_num"
local outcomes "we_decide_hhpurch_b we_decide_health_b we_decide_visits_b we_decide_hhpurch_a we_decide_health_a we_decide_visits_a"
local legacy_outcomes "we_decide_hhpurch_b_legacy we_decide_health_b_legacy we_decide_visits_b_legacy we_decide_hhpurch_a_legacy we_decide_health_a_legacy we_decide_visits_a_legacy"
tempname ph
postfile `ph' str32 outcome str20 specification str20 sample str100 term double estimate se p_value long N using "output/tables/chapter_1/probit_ame_stata.dta", replace

program drop _all
program define collect_ame
    syntax varname [if], RHS(string asis) OUTCOME(string) SPEC(string) SAMPLE(string) POST(name)
    marksample touse
    quietly probit `varlist' `rhs' if `touse'
    local n=e(N)
    quietly margins, dydx(*) post
    matrix B=e(b)
    matrix V=e(V)
    local terms : colnames B
    foreach term of local terms {
        local j=colnumb(B,"`term'")
        scalar bb=B[1,`j']
        scalar ss=sqrt(V[`j',`j'])
        scalar pp=.
        if ss>0 scalar pp=2*normal(-abs(bb/ss))
        post `post' ("`outcome'") ("`spec'") ("`sample'") ("`term'") (bb) (ss) (pp) (`n')
    }
end

foreach y of local outcomes {
    foreach spec in religion_only full_controls {
        local rhs "i.religion"
        if "`spec'"=="full_controls" local rhs "`controls'"
        collect_ame `y', rhs("`rhs'") outcome("`y'") spec("`spec'") sample("All") post(`ph')
        foreach cohort in 1956 1966 1976 1986 {
            collect_ame `y' if Birth_Cohort==`cohort', rhs("`rhs'") outcome("`y'") ///
                spec("`spec'") sample("`cohort'") post(`ph')
        }
    }
    * Religion-specific full-control models; religion is omitted from controls.
    foreach rel in 1 2 3 {
        local rlabel "Hindu"
        if `rel'==2 local rlabel "Muslim"
        if `rel'==3 local rlabel "Christian_Others"
        collect_ame `y' if Religion_New==`rel', rhs("`controls_sub'") outcome("`y'") ///
            spec("full_controls") sample("`rlabel'") post(`ph')
        foreach cohort in 1956 1966 1976 1986 {
            collect_ame `y' if Religion_New==`rel' & Birth_Cohort==`cohort', ///
                rhs("`controls_sub'") outcome("`y'") spec("full_controls") ///
                sample("`rlabel'_`cohort'") post(`ph')
        }
    }
}
* Literal legacy recodes are estimated for the full sample and each cohort
* only; religion splits above use the thesis-definition outcomes.
foreach y of local legacy_outcomes {
    foreach spec in religion_only full_controls {
        local rhs "i.religion"
        if "`spec'"=="full_controls" local rhs "`controls'"
        collect_ame `y', rhs("`rhs'") outcome("`y'") spec("`spec'") sample("All") post(`ph')
        foreach cohort in 1956 1966 1976 1986 {
            collect_ame `y' if Birth_Cohort==`cohort', rhs("`rhs'") outcome("`y'") ///
                spec("`spec'") sample("`cohort'") post(`ph')
        }
    }
}
postclose `ph'
use "output/tables/chapter_1/probit_ame_stata.dta", clear
export delimited using "output/tables/chapter_1/probit_ame_stata.csv", replace

* Descriptive response shares by round and cohort for each domain.
use "`clean'", clear
foreach d in hhpurch health visits {
    preserve
    keep DHSRound_num we_decide_`d'
    drop if missing(we_decide_`d')
    contract DHSRound_num we_decide_`d'
    bysort DHSRound_num: egen total=sum(_freq)
    gen share=_freq/total
    export delimited using "output/tables/chapter_1/`d'_raw_categories_by_round_stata.csv", replace
    restore
    preserve
    keep Birth_Cohort we_decide_`d'
    drop if missing(Birth_Cohort) | missing(we_decide_`d')
    contract Birth_Cohort we_decide_`d'
    bysort Birth_Cohort: egen total=sum(_freq)
    gen share=_freq/total
    export delimited using "output/tables/chapter_1/`d'_raw_categories_by_cohort_stata.csv", replace
    restore
}
* Cross-tabulation appendix tables: raw decision categories by each
* socio-economic characteristic, separately by NFHS round and birth cohort.
local xvars "Education_respondent we_empl religion Education_partner hs_empl wealth_index massmedia sector State2"
foreach dom in hhpurch health visits {
    local raw "we_decide_`dom'"
    foreach x of local xvars {
        capture confirm variable `x'
        if !_rc {
            preserve
            keep DHSRound_num `x' `raw'
            drop if missing(DHSRound_num) | missing(`x') | missing(`raw')
            contract DHSRound_num `x' `raw'
            bysort DHSRound_num `x': egen denominator=sum(_freq)
            gen row_share=_freq/denominator
            export delimited using "output/tables/chapter_1/`dom'_by_`x'_and_round_stata.csv", replace
            restore
            preserve
            keep Birth_Cohort `x' `raw'
            drop if missing(Birth_Cohort) | missing(`x') | missing(`raw')
            contract Birth_Cohort `x' `raw'
            bysort Birth_Cohort `x': egen denominator=sum(_freq)
            gen row_share=_freq/denominator
            export delimited using "output/tables/chapter_1/`dom'_by_`x'_and_cohort_stata.csv", replace
            restore
        }
    }
}

* Visual trend summaries: average joint and independent outcomes by survey round.
foreach d in hhpurch health visits {
    graph bar (mean) we_decide_`d'_b we_decide_`d'_a, over(DHSRound_num) ///
        title("Decision-making by NFHS round: `d'") ytitle("Share") ///
        legend(order(1 "Joint participation" 2 "Respondent alone"))
    graph export "output/figures/chapter_1/`d'_by_round_stata.png", replace
    graph bar (mean) we_decide_`d'_b we_decide_`d'_a, over(Birth_Cohort) ///
        title("Decision-making by birth cohort: `d'") ytitle("Share") ///
        legend(order(1 "Joint participation" 2 "Respondent alone"))
    graph export "output/figures/chapter_1/`d'_by_cohort_stata.png", replace
}
* Literal legacy-code models are separately exported for sensitivity comparison.
display "NOTE: Primary outcomes follow the thesis prose (1-2 joint; 3-5 no; 1 independent; 2-5 no)."
display "Legacy _legacy outcomes reproduce the supplied do-file recode, which leaves response 3 missing."
log close
