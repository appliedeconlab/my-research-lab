version 18.0
clear all
set more off
set linesize 200
capture confirm file "README.md"
if _rc {
    display as error "Run from repository root."
    exit 601
}
capture which didregress
if _rc {
    display as error "didregress is unavailable; Stata 18+ is required."
    exit 199
}
capture which dtable
if _rc display as error "dtable is unavailable in this Stata release; update Stata to 18+."

capture mkdir "output/tables/chapter_2"
capture mkdir "output/figures/chapter_2"
capture mkdir "output/logs"
capture log close
log using "output/logs/chapter_2_analysis_stata.log", text replace

local controls "HH_Type_Agri Social_Group_new Ration_Type_new i.Dwelling_Unit_new HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education i.Religion_new i.Sector"
local outcomes "Food Food_PC Fuel Fuel_PC Clothing Clothing_PC Footwear Footwear_PC Durable Durable_PC Misc Misc_PC MPCE_Own ln_Food ln_Food_PC ln_Fuel ln_Fuel_PC ln_Clothing ln_Clothing_PC ln_Footwear ln_Footwear_PC ln_Durable ln_Durable_PC ln_Misc ln_Misc_PC ln_MPCE_Own"

tempname ph
postfile `ph' str2 horizon str32 outcome byte controls double did_coef did_se did_p long N str5 pt_type double pt_stat pt_p using "output/tables/chapter_2/did_stata.dta", replace

foreach h in sr lr {
    local H = upper("`h'")
    use "data/processed/chapter_2_nsso/chapter_2_`h'_analysis_ready.dta", clear
    foreach y of local outcomes {
        capture confirm variable `y'
        if !_rc {
            foreach c in 0 1 {
                if `c'==0 quietly didregress (`y') (did_robust1), group(District) time(SubRound)
                else quietly didregress (`y' `controls') (did_robust1), group(District) time(SubRound)
                matrix B=e(b)
                matrix V=e(V)
                scalar bb=B[1,1]
                scalar ss=sqrt(V[1,1])
                scalar pp=2*ttail(e(df_r),abs(bb/ss))
                local nn=e(N)
                quietly estat ptrends
                local pt_type "F"
                scalar ptstat=.
                scalar ptp=.
                capture scalar ptstat=r(F)
                if _rc {
                    local pt_type "chi2"
                    capture scalar ptstat=r(chi2)
                }
                capture scalar ptp=r(p)
                post `ph' ("`H'") ("`y'") (`c') (bb) (ss) (pp) (`nn') ("`pt_type'") (ptstat) (ptp)
            }
        }
    }

    * Descriptive table outputs by pre/post and treatment/control.
    preserve
    collapse (mean) Food_PC Fuel_PC Clothing_PC MPCE_Own HHSize ///
             (count) N=HHID, by(after_tsunami robust_treat1)
    export delimited using "output/tables/chapter_2/`h'_descriptives.csv", replace
    restore
    preserve
    collapse (mean) Food_PC Fuel_PC Clothing_PC MPCE_Own, by(SubRound robust_treat1)
    twoway (line Clothing_PC SubRound if robust_treat1==0, sort) ///
           (line Clothing_PC SubRound if robust_treat1==1, sort), ///
           title("Clothing per capita by sub-round and treatment group") ///
           ytitle("Rupees per capita") xtitle("Survey sub-round") ///
           legend(order(1 "Control" 2 "Treatment"))
    graph export "output/figures/chapter_2/`h'_clothing_pc_by_subround_stata.png", replace
    restore

    * Harmonised appendix subgroup descriptives for dwelling, sector and religion.
    foreach sub in Dwelling_Unit_new Sector Religion_new {
        capture confirm variable `sub'
        if !_rc {
            preserve
            collapse (mean) Food_PC Fuel_PC Clothing_PC MPCE_Own ///
                     (count) N=HHID, by(`sub' after_tsunami)
            export delimited using "output/tables/chapter_2/`h'_appendix_descriptives_`sub'.csv", replace
            restore
        }
    }

    * Household-size balance tests among controls, matching the source do-file.
    tempname bh
    postfile `bh' str8 cap str2 horizon long N double before_after_p subround1_3_p subround1_2_p using ///
        "output/tables/chapter_2/`h'_hhsize_balance.dta", replace
    foreach cap in Original 8 9 10 11 12 13 {
        preserve
        if "`cap'"!="Original" keep if HHSize<=`cap'
        local nn=_N
        quietly ttest HHSize if robust_treat1==0, by(after_tsunami)
        local p1=r(p)
        quietly ttest HHSize if robust_treat1==0 & inlist(SubRound,1,3), by(SubRound)
        local p2=r(p)
        quietly ttest HHSize if robust_treat1==0 & inlist(SubRound,1,2), by(SubRound)
        local p3=r(p)
        post `bh' ("`cap'") ("`H'") (`nn') (`p1') (`p2') (`p3')
        restore
    }
    postclose `bh'
    use "output/tables/chapter_2/`h'_hhsize_balance.dta", clear
    export delimited using "output/tables/chapter_2/`h'_hhsize_balance.csv", replace
    use "data/processed/chapter_2_nsso/chapter_2_`h'_analysis_ready.dta", clear

    * Determinants of per-capita expenditure, estimated separately before/after
    * and for control, treatment, and pooled samples as in the supplied files.
    tempname dh
    postfile `dh' str2 horizon str24 outcome byte period str12 sample str80 term ///
        double estimate se p_value long N using "output/tables/chapter_2/`h'_determinants.dta", replace
    foreach y in ln_Food_PC ln_Fuel_PC ln_Clothing_PC ln_Footwear_PC ln_Durable_PC ln_Misc_PC ln_MPCE_Own {
        foreach period in 0 1 {
            foreach sample in control treatment pooled {
                local qualifier "if after_tsunami==`period'"
                local rhs "`controls'"
                if "`sample'"=="control" local qualifier "`qualifier' & robust_treat1==0"
                if "`sample'"=="treatment" local qualifier "`qualifier' & robust_treat1==1"
                if "`sample'"=="pooled" local rhs "robust_treat1 `controls'"
                quietly regress `y' `rhs' `qualifier', vce(robust)
                local nn=e(N)
                matrix B=e(b)
                matrix V=e(V)
                local terms : colnames B
                foreach term of local terms {
                    local j=colnumb(B,"`term'")
                    scalar bb=B[1,`j']
                    scalar ss=sqrt(V[`j',`j'])
                    scalar pp=2*normal(-abs(bb/ss))
                    post `dh' ("`H'") ("`y'") (`period') ("`sample'") ("`term'") (bb) (ss) (pp) (`nn')
                }
            }
        }
    }
    postclose `dh'
    use "output/tables/chapter_2/`h'_determinants.dta", clear
    export delimited using "output/tables/chapter_2/`h'_determinants.csv", replace
    use "data/processed/chapter_2_nsso/chapter_2_`h'_analysis_ready.dta", clear

    * Household-size robustness: Original means no cap; caps 8-13 are literal.
    tempname rh
    postfile `rh' str8 cap str2 horizon double N did_coef se p using ///
        "output/tables/chapter_2/`h'_hhsize_robustness.dta", replace
    foreach cap in Original 8 9 10 11 12 13 {
        local cond ""
        if "`cap'"!="Original" local cond "if HHSize<=`cap'"
        quietly didregress (Clothing_PC) (did_robust1) `cond', group(District) time(SubRound)
        matrix B=e(b)
        matrix V=e(V)
        scalar bb=B[1,1]
        scalar ss=sqrt(V[1,1])
        scalar pp=2*ttail(e(df_r),abs(bb/ss))
        local nn=e(N)
        post `rh' ("`cap'") ("`H'") (`nn') (bb) (ss) (pp)
    }
    postclose `rh'
    use "output/tables/chapter_2/`h'_hhsize_robustness.dta", clear
    export delimited using "output/tables/chapter_2/`h'_hhsize_robustness.csv", replace
}
postclose `ph'
use "output/tables/chapter_2/did_stata.dta", clear
export delimited using "output/tables/chapter_2/did_stata.csv", replace

* Heterogeneity: estimate Clothing_PC, Food_PC, Fuel_PC and MPCE_Own by
* subgroup. The subgroup variable is excluded from the control set.
foreach h in sr lr {
    local H = upper("`h'")
    use "data/processed/chapter_2_nsso/chapter_2_`h'_analysis_ready.dta", clear
    tempname hh
    postfile `hh' str2 horizon str24 subgroup double subgroup_value str24 outcome ///
        byte controls double coef se p long N using "output/tables/chapter_2/`h'_heterogeneity.dta", replace
    foreach sub in female_headed Religion_new Social_Group_new Dwelling_Unit_new Sector Ration_Type_new HH_Type_Agri {
        capture confirm variable `sub'
        if !_rc {
            quietly levelsof `sub', local(levels)
            foreach lev of local levels {
                foreach y in Food_PC Fuel_PC Clothing_PC MPCE_Own {
                    foreach c in 0 1 {
                        local rhs ""
                        if `c'==1 {
                            local rhs "`controls'"
                            if "`sub'"=="Religion_new" local rhs "HH_Type_Agri Social_Group_new Ration_Type_new i.Dwelling_Unit_new HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education i.Sector"
                            if "`sub'"=="Dwelling_Unit_new" local rhs "HH_Type_Agri Social_Group_new Ration_Type_new HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education i.Religion_new i.Sector"
                            if "`sub'"=="Sector" local rhs "HH_Type_Agri Social_Group_new Ration_Type_new i.Dwelling_Unit_new HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education i.Religion_new"
                            if "`sub'"=="Ration_Type_new" local rhs "HH_Type_Agri Social_Group_new i.Dwelling_Unit_new HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education i.Religion_new i.Sector"
                            if "`sub'"=="HH_Type_Agri" local rhs "Social_Group_new Ration_Type_new i.Dwelling_Unit_new HHSize HH_AdultFemaleProp HH_Head_Age HH_Head_Education i.Religion_new i.Sector"
                            if "`sub'"=="female_headed" local rhs "`controls'"
                        }
                        if `c'==0 quietly didregress (`y') (did_robust1) if `sub'==`lev', group(District) time(SubRound)
                        else quietly didregress (`y' `rhs') (did_robust1) if `sub'==`lev', group(District) time(SubRound)
                        matrix B=e(b)
                        matrix V=e(V)
                        scalar bb=B[1,1]
                        scalar ss=sqrt(V[1,1])
                        scalar pp=2*ttail(e(df_r),abs(bb/ss))
                        local nn=e(N)
                        post `hh' ("`H'") ("`sub'") (`lev') ("`y'") (`c') (bb) (ss) (pp) (`nn')
                    }
                }
            }
        }
    }
    postclose `hh'
    use "output/tables/chapter_2/`h'_heterogeneity.dta", clear
    export delimited using "output/tables/chapter_2/`h'_heterogeneity.csv", replace
}
display "Parallel-trends interpretation: p>0.05 = fail to reject the tested deviation; not proof of parallel trends."
log close
