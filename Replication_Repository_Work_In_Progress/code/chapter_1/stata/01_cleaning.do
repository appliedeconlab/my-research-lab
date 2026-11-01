version 18.0
clear all
set more off
set linesize 200
set maxvar 32767

* Run from the repository root. All paths below are project-relative.
capture confirm file "README.md"
if _rc {
    display as error "Run this do-file from the repository root (the folder containing README.md)."
    exit 601
}
local raw "data/raw/chapter_1_nfhs"
local processed "data/processed/chapter_1_nfhs"
capture mkdir "`processed'"
capture mkdir "output/logs"
capture log close _all
log using "output/logs/chapter_1_cleaning_stata.log", text replace
display "Stata version: " c(stata_version)

foreach f in IAIR52FL_2005_06.dta IAIR74FL_2015_16.DTA IAIR7EFL_2019_21.DTA {
    capture confirm file "`raw'/`f'"
    if _rc {
        display as error "Required NFHS Individual Recode file missing: `raw'/`f'"
        log close
        exit 601
    }
}

tempfile nfhs3 nfhs4 nfhs5

program drop _all
program define clean_round
    syntax, FILE(string) ROUND(integer) SAVING(string)
    use "`file'", clear

    * Variables required by the common construction. A failure is preferable
    * to silently generating an incomplete harmonised file.
    foreach v in caseid v005 v007 v011 v012 v024 v025 v026 v130 v135 v136 ///
                 v151 v157 v158 v159 v190 v502 v704 v730 v743a v743b v743d {
        capture confirm variable `v'
        if _rc {
            display as error "Required source variable `v' is absent in round `round'."
            exit 111
        }
    }

    * Harmonised sample repair: apply the v502==1 and v135==1 restrictions
    * to all three rounds to align the stated thesis sample. The supplied
    * source explicitly shows these restrictions for NFHS-3/4 but omits them
    * in the NFHS-5 block. The thesis says ever-married; confirm v502 against
    * the round codebooks because v502==1 may not include all formerly married.
    keep if v502==1
    keep if v135==1

    gen byte DHSRound_num = `round'
    gen str8 DHSRound = "NFHS_`round'"
    if `round'==1 replace DHSRound = "NFHS_3"
    if `round'==2 replace DHSRound = "NFHS_4"
    if `round'==3 replace DHSRound = "NFHS_5"

    gen double wt = v005/1000000
    * Respondent employment in the last 12 months among those currently in union.
    capture confirm variable v731
    if _rc {
        display as error "Required source variable v731 is absent in round `round'."
        exit 111
    }
    gen byte we_empl = .
    replace we_empl=0 if v731==0
    replace we_empl=1 if inrange(v731,1,3)
    replace we_empl=. if inlist(v731,8,9)
    gen int Birth_Year = floor((v011-1)/12) + 1900
    gen int Birth_Cohort = .
    replace Birth_Cohort=1956 if inrange(Birth_Year,1956,1965)
    replace Birth_Cohort=1966 if inrange(Birth_Year,1966,1975)
    replace Birth_Cohort=1976 if inrange(Birth_Year,1976,1985)
    replace Birth_Cohort=1986 if inrange(Birth_Year,1986,2005)

    gen byte current_age = v012
    gen double age_difference = v730-v012
    replace age_difference = . if missing(v730) | v730>=98
    gen double hh_size = v136
    gen byte wealth_index = v190
    gen byte sector = v025
    gen byte Religion_New = v130
    replace Religion_New = . if v130>=9 & !missing(v130)
    replace Religion_New = 4 if inrange(v130,4,8)
    gen byte religion = Religion_New

    * Highest education: NFHS-3 uses v149 in the supplied script; NFHS-4/5 use v106.
    if `round'==1 {
        capture confirm variable v149
        if _rc {
            display as error "NFHS-3 variable v149 missing; cannot construct Education_respondent."
            exit 111
        }
        gen byte Education_respondent = v149
        * NFHS-3 partner education is available as years of schooling (v715).
        * Map to four broad levels to align with v701 in later rounds.
        capture confirm variable v715
        if _rc {
            display as error "NFHS-3 variable v715 missing; cannot construct Education_partner."
            exit 111
        }
        gen byte Education_partner = .
        replace Education_partner=0 if v715==0
        replace Education_partner=1 if inrange(v715,1,5)
        replace Education_partner=2 if inrange(v715,6,10)
        replace Education_partner=3 if inrange(v715,11,97)
    }
    else {
        foreach v in v106 v701 {
            capture confirm variable `v'
            if _rc {
                display as error "Round `round' requires `v'."
                exit 111
            }
        }
        gen byte Education_respondent = v106
        gen byte Education_partner = v701
        replace Education_partner = . if inlist(v701,8,9,98,99)
    }

    * Provisional husband employment indicator. The source file recodes v704
    * into occupation groups but does not create hs_empl, although Results.do
    * requires it. This binary derivation is explicitly flagged in docs.
    gen byte hs_empl = .
    replace hs_empl=0 if inlist(v704,0,96,97)
    replace hs_empl=1 if inrange(v704,1,95)

    * Media exposure follows the supplied source: any of the three media
    * variables equals 2. Missing-only records remain zero, as in that source.
    gen byte massmedia = 0
    foreach v in v157 v158 v159 {
        replace massmedia=1 if `v'==2
    }

    * Common state codes. NFHS-4 codes differ from NFHS-3/5 and are remapped.
    gen int State2 = v024
    if `round'==2 {
        replace State2=1  if v024==14
        replace State2=2  if v024==13
        replace State2=3  if v024==28
        replace State2=4  if v024==6
        replace State2=5  if v024==34
        replace State2=6  if v024==12
        replace State2=7  if v024==25
        replace State2=8  if v024==29
        replace State2=9  if v024==33
        replace State2=10 if v024==5
        replace State2=11 if v024==30
        replace State2=12 if v024==3
        replace State2=13 if v024==24
        replace State2=14 if v024==21
        replace State2=15 if v024==23
        replace State2=16 if v024==32
        replace State2=17 if v024==22
        replace State2=18 if v024==4
        replace State2=19 if v024==35
        replace State2=20 if v024==15
        replace State2=21 if v024==26
        replace State2=22 if v024==7
        replace State2=23 if v024==19
        replace State2=24 if v024==11
        replace State2=25 if v024==8
        replace State2=27 if v024==20
        replace State2=28 if v024==2
        replace State2=29 if v024==16
        replace State2=30 if v024==10
        replace State2=31 if v024==18
        replace State2=32 if v024==17
        replace State2=33 if v024==31
        replace State2=34 if v024==27
        replace State2=35 if v024==1
        replace State2=36 if v024==36
    }

    * Decision domains: raw categories are retained. Thesis definitions:
    * joint participation = respondent alone OR respondent with partner (1/2);
    * independent = respondent alone only (1). Codes 3-5 are no; 6+ remain
    * missing pending confirmation against round-specific value labels.
    foreach d in health hhpurch visits {
        local rawvar "v743a"
        if "`d'"=="hhpurch" local rawvar "v743b"
        if "`d'"=="visits" local rawvar "v743d"
        gen byte we_decide_`d' = `rawvar'
        replace we_decide_`d' = . if `rawvar'==9
        gen byte we_decide_`d'_a = .
        replace we_decide_`d'_a=1 if `rawvar'==1
        replace we_decide_`d'_a=0 if inrange(`rawvar',2,5)
        gen byte we_decide_`d'_b = .
        replace we_decide_`d'_b=1 if inlist(`rawvar',1,2)
        replace we_decide_`d'_b=0 if inrange(`rawvar',3,5)

        * Literal legacy recodes from the supplied do-file, retained for
        * comparison. They omit response code 3 and treat code 6 as zero.
        gen byte we_decide_`d'_a_legacy = .
        replace we_decide_`d'_a_legacy=1 if `rawvar'==1
        replace we_decide_`d'_a_legacy=0 if inlist(`rawvar',2,4,5,6)
        gen byte we_decide_`d'_b_legacy = .
        replace we_decide_`d'_b_legacy=1 if inlist(`rawvar',1,2)
        replace we_decide_`d'_b_legacy=0 if inlist(`rawvar',4,5,6)
    }

    keep caseid DHSRound DHSRound_num wt Birth_Year Birth_Cohort ///
         current_age age_difference hh_size wealth_index sector State2 ///
         religion Religion_New Education_respondent Education_partner ///
         we_empl hs_empl massmedia we_decide_*
    order caseid DHSRound DHSRound_num wt Birth_Year Birth_Cohort
    save "`saving'", replace
end

clean_round, file("`raw'/IAIR52FL_2005_06.dta") round(1) saving("`nfhs3'")
clean_round, file("`raw'/IAIR74FL_2015_16.DTA") round(2) saving("`nfhs4'")
clean_round, file("`raw'/IAIR7EFL_2019_21.DTA") round(3) saving("`nfhs5'")

use "`nfhs3'", clear
append using "`nfhs4'"
append using "`nfhs5'"
isid caseid DHSRound_num
compress
export delimited using "`processed'/nfhs_analysis_ready.csv", replace
save "`processed'/nfhs_analysis_ready.dta", replace

* Machine-readable sample checks and expected thesis benchmarks.
preserve
contract DHSRound_num
rename _freq n
export delimited using "output/diagnostics/chapter_1_round_counts_stata.csv", replace
restore
preserve
keep if !missing(we_decide_hhpurch)
contract DHSRound_num
rename _freq n_with_purchase_response
export delimited using "output/diagnostics/chapter_1_purchase_response_counts_stata.csv", replace
restore
display "Cleaning complete. Compare round N with thesis benchmarks: 81,365; 81,480; 72,450."
display "WARNING: partner employment and partner education harmonisation need validation; see docs/variable_construction.md."
log close
