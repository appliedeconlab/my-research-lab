version 18.0
clear all
set more off
set linesize 200
capture confirm file "README.md"
if _rc {
    display as error "Run from repository root."
    exit 601
}
local idir "data/interim/chapter_2_nsso"
local odir "data/processed/chapter_2_nsso"
capture mkdir "`odir'"
capture mkdir "output/logs"
capture log close
log using "output/logs/chapter_2_cleaning_stata.log", text replace
display "Stata version: " c(stata_version)

foreach f in AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta ///
             AP_Aggregates_Merged_All_SubRound_Consistent_Sample.dta person_record.dta {
    capture confirm file "`idir'/`f'"
    if _rc {
        display as error "Required input missing: `idir'/`f'"
        display as error "See docs/data_access.md and docs/replication_limitations.md."
        log close
        exit 601
    }
}

program drop _all
program define prepare_horizon
    syntax, AGGREGATE(string) PERSON(string) OUTFILE(string) HORIZON(string)
    use "`aggregate'", clear
    isid HHID
    quietly count
    local n_master=r(N)
    merge 1:1 HHID using "`person'"
    quietly count if _merge==1
    local master_only=r(N)
    quietly count if _merge==2
    local using_only=r(N)
    quietly count if _merge==3
    local matched=r(N)
    display "`horizon' merge counts: aggregate-only=`master_only'; person-only=`using_only'; matched=`matched'; master N=`n_master'"
    * Preserve the original rule: keep matched households only.
    keep if _merge==3
    drop _merge
    quietly count
    local n_after_merge=r(N)
    keep if !missing(robust_treat1)
    quietly count
    local n_after_treat=r(N)
    display "`horizon': after matched merge N=`n_after_merge'; nonmissing robust_treat1 N=`n_after_treat'"

    foreach v in HH_Head_Education HH_Head_Age HH_AdultFemaleProp {
        capture confirm numeric variable `v'
        if _rc destring `v', replace force
    }
    foreach v in District SubRound robust_treat1 did_robust1 after_tsunami HHSize ///
                 HH_Type Social_Group Ration_Type Religion Dwelling_Unit Sector ///
                 HH_AdultFemaleProp HH_Head_Age HH_Head_Education ///
                 Food Food_PC Fuel Fuel_PC Clothing Clothing_PC Footwear Footwear_PC ///
                 Durable Durable_PC Misc Misc_PC MPCE_Own {
        capture confirm variable `v'
        if _rc {
            display as error "`horizon': required variable `v' missing."
            exit 111
        }
    }

    * Preserve the exact recodes in the source analysis scripts.
    gen byte HH_Type_Agri = inlist(HH_Type,12,14)
    gen byte Social_Group_new = inlist(Social_Group,1,2,3)
    gen byte Ration_Type_new = inlist(Ration_Type,1,2)
    gen byte Religion_new = 1 if Religion==1
    replace Religion_new=2 if Religion==2
    replace Religion_new=3 if inlist(Religion,3,9)
    gen byte Dwelling_Unit_new=1 if Dwelling_Unit==1
    replace Dwelling_Unit_new=2 if inlist(Dwelling_Unit,2,9)

    * Source logs use ln(x+1). Report all invalid and missing source values.
    foreach v in Food Food_PC Fuel Fuel_PC Clothing Clothing_PC Footwear Footwear_PC ///
                 Durable Durable_PC Misc Misc_PC MPCE_Own {
        quietly count if missing(`v')
        local nmiss=r(N)
        quietly count if !missing(`v') & `v'<=-1
        local nbad=r(N)
        gen double ln_`v'=ln(`v'+1)
        quietly count if missing(ln_`v')
        local nlnmiss=r(N)
        display "`horizon' `v': source missing=`nmiss'; values <= -1=`nbad'; log missing after ln(x+1)=`nlnmiss'"
    }

    * Validate, but do not rebuild, assumed treatment/time variables.
    quietly count if after_tsunami != (SubRound>=3) & !missing(after_tsunami,SubRound)
    display "`horizon' after_tsunami/SubRound mismatches (expected post=SubRound>=3): " r(N)
    quietly count if did_robust1 != robust_treat1*after_tsunami & !missing(did_robust1,robust_treat1,after_tsunami)
    display "`horizon' did_robust1 != robust_treat1*after_tsunami: " r(N)

    gen str2 horizon="`horizon'"
    save "`outfile'", replace
end

* Optional reconstruction from Block 4 person records. This produces the
* HH_level_AP_demographics file used by the supplied appendix code; it does
* NOT create person_record.dta and is not substituted into the main merge.
capture confirm file "data/raw/chapter_2_nsso/Block 4_Person records.dta"
if !_rc {
    use "data/raw/chapter_2_nsso/Block 4_Person records.dta", clear
    foreach v in State Gender Household_Head Age {
        capture confirm numeric variable `v'
        if _rc destring `v', replace force
    }
    keep if State==28
    gen byte is_head=(Household_Head==1)
    gen byte head_gender_temp=Gender if is_head
    bysort HHID: egen hh_head_gender=max(head_gender_temp)
    gen byte female_headed=(hh_head_gender==2)
    gen double head_age_temp=Age if is_head
    bysort HHID: egen hh_head_age=max(head_age_temp)
    gen byte child=inrange(Age,0,14) if !missing(Age)
    gen byte working_age=inrange(Age,15,64) if !missing(Age)
    gen byte elderly=inrange(Age,65,101) if !missing(Age)
    bysort HHID: egen num_children=total(child)
    bysort HHID: egen num_working_age=total(working_age)
    bysort HHID: egen num_elderly=total(elderly)
    gen double dependency_ratio=(num_children+num_elderly)/num_working_age
    replace dependency_ratio=. if num_working_age==0
    bysort HHID: egen hh_size_block4=count(HHID)
    keep HHID SubRound hh_head_gender female_headed hh_head_age ///
         num_children num_working_age num_elderly dependency_ratio hh_size_block4
    bysort HHID: keep if _n==1
    isid HHID
    save "`odir'/HH_level_AP_demographics.dta", replace
    display "Optional Block 4 household demographics created."
}
else display "Optional Block 4 file not present; skipped household demographic extension."

prepare_horizon, aggregate("`idir'/AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta") ///
    person("`idir'/person_record.dta") outfile("`odir'/chapter_2_sr_analysis_ready.dta") horizon("SR")
prepare_horizon, aggregate("`idir'/AP_Aggregates_Merged_All_SubRound_Consistent_Sample.dta") ///
    person("`idir'/person_record.dta") outfile("`odir'/chapter_2_lr_analysis_ready.dta") horizon("LR")

* Export a public-safe schema and counts only; never export microdata.
foreach h in sr lr {
    use "`odir'/chapter_2_`h'_analysis_ready.dta", clear
    quietly count
    file open f using "output/diagnostics/chapter_2_`h'_cleaning_counts.txt", write replace
    file write f "Cleaned observations: `r(N)'" _n
    file close f
}
display "Chapter 2 cleaning complete. Raw NSSO item-level construction remains outside supplied source scope."
log close
