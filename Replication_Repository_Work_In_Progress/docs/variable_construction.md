# Variable construction and specification notes

## Chapter 1 — NFHS women's decision-making

### Sample and time/cohort

The thesis describes the target as ever-married women aged 15–49 and usual residents. The supplied preparation do-file explicitly applies `v502==1` and `v135==1` in the NFHS-3 and NFHS-4 blocks, but the NFHS-5 block does not visibly repeat either final restriction. The new scripts apply both restrictions to all three rounds as a harmonised repair to align the stated sample, but this is not literal source parity. Also confirm the meaning of `v502==1` against each round's codebook: it may denote currently in union rather than all ever-married women. The final analysis sample cannot be certified until this is resolved against the thesis observation counts and the codebooks.

Birth year follows the source formula `floor((v011-1)/12)+1900`. Cohorts are 1956–65, 1966–75, 1976–85, and 1986–2005. The last cohort spans 20 years, unlike the other 10-year cohorts.

### Outcomes: a material source/thesis discrepancy

The thesis text defines:
- joint participation: respondent alone or respondent with husband/partner (raw response 1 or 2);
- independent decision-making: respondent alone (raw response 1);
- non-participation/other: husband alone, someone else, or others (raw response 3, 4 or 5).

The supplied `Appending_Raw_Data.do` instead codes `_b=0` for raw codes 4, 5, 6 and leaves raw code 3 missing; `_a=0` for 2, 4, 5, 6 and leaves 3 missing. This excludes the husband/partner-alone category, despite the thesis prose saying it belongs to the non-participation category. The primary cleaned outcomes follow the thesis prose (1/2 vs 3–5; 1 vs 2–5), while variables ending `_legacy` reproduce the literal supplied recode. Compare both before deciding which version generated the thesis tables. Raw category 6 is left missing in the thesis-definition variables until the round-specific value labels establish its meaning. Raw code 9 is set to missing, as in the supplied recode statements.

### Covariates and unresolved harmonisation

- `wt = v005/1e6`; the supplied probit models do not use this weight or `svyset`.
- Respondent education: source uses `v149` in NFHS-3 and `v106` in NFHS-4/5.
- Partner education: NFHS-3 `v715` is years of schooling; NFHS-4/5 `v701` is a categorical education level. The cleaning code maps NFHS-3 years to four broad categories (0, 1–5, 6–10, 11+) to align approximately with `v701`. This is a transparent harmonisation assumption, not a verified exact equivalence.
- Partner employment: `Results.do` requires `hs_empl`, but the supplied cleaning file does not create it. It does create partner occupation groups from `v704`. The new scripts provisionally derive `hs_empl=0` for v704 codes 0/96/97 and `1` for 1–95. Confirm this against the round codebooks and the data version used for the thesis.
- `current_age` is taken from `v012`; `age_difference` from `v730-v012`; `hh_size` from `v136`; `wealth_index` from `v190`; `sector` from `v025`.
- `massmedia` is one if any of `v157`, `v158`, `v159` equals 2, following the supplied code.
- NFHS-4 state codes are remapped to common state codes using the explicit map in the supplied file. `State2` is created because `Results.do` requires it but the supplied preparation file creates `State`, not `State2`.

### Pipeline defects in the supplied NFHS preparation do-file

The supplied preparation file processes NFHS rounds separately, but its final append block reopens the original raw NFHS-5, NFHS-4 and NFHS-3 files and appends those raw files, then saves `Main_Data.dta`. The save occurs before `Birth_Cohort` is generated and before the final `keep` statement. The NFHS-5 block also does not visibly repeat the NFHS-3/4 sample filters and only visibly constructs the large-purchase outcome, whereas the thesis and results require all three domains. `Results.do` then expects `Birth_Cohort`, `current_age`, `hs_empl`, `State2`, and `Religion_New`. Thus the supplied preparation and results files are not a self-contained executable pipeline as uploaded. The new scripts harmonise all three outcomes and apply the stated sample restriction to each wave, explicitly treating the NFHS-5 filter as a repair rather than source-literal parity.

## Chapter 2 — NSSO tsunami and consumption

### Sample, treatment and timing

The thesis compares three more severely affected districts (Krishna, Prakasam, Nellore) with five less severely affected coastal districts (Guntur, West Godavari, East Godavari, Visakhapatnam, Srikakulam). It defines short run as SubRounds 1–2 before versus SubRound 3 after (thesis N=1,658); longer horizon as SubRounds 1–2 before versus SubRounds 3–4 after (thesis N=2,180).

The analysis files assume `robust_treat1`, `did_robust1`, `after_tsunami`, `SubRound`, `District`, and the expenditure aggregates already exist. The supplied analysis do-files do not establish the complete raw-to-aggregate process or the authoritative treatment coding. The new cleaning scripts validate but do not rebuild these fields.

### Merge and controls

The source analysis uses `merge 1:1 HHID using person_record.dta`, then `keep if _merge==3`, then `keep if !missing(robust_treat1)`. This exact sample rule is preserved. Merge counts are written to the log before matched-only restriction.

The following source recodes are retained:
- `HH_Type_Agri = inlist(HH_Type,12,14)`
- `Social_Group_new = inlist(Social_Group,1,2,3)`
- `Ration_Type_new = inlist(Ration_Type,1,2)`
- `Religion_new`: 1 Hindu, 2 Muslim, 3 when Religion is 3 or 9
- `Dwelling_Unit_new`: 1 when Dwelling_Unit is 1, 2 when it is 2 or 9

The original binary constructions turn missing source categories into zero for agricultural/social/ration indicators; the new scripts preserve that behaviour and document it rather than silently changing it.

### Log transformations

The source uses `ln(x+1)`. Values `x<=-1` make this undefined. Each cleaning implementation counts raw missing values, nonmissing values `<=-1`, and missing transformed values. No values are recoded to force the transformation.

### Parallel trends

Several original files label `estat ptrends` p-values above .05 as `PASS`. This repository replaces that wording. A p-value above .05 is a failure to reject the tested deviation from parallel trends; it is not proof that parallel trends holds. The Stata analysis should report the test statistic, p-value, model outcome, horizon and control status. R/Python do not claim an exact equivalent.

### Household-size robustness

The thesis Appendix A defines “Original” as the uncapped sample and reports caps at 8, 9, 10, 11, 12 and 13. The supplied robustness file implements the same cap sequence. The new scripts use the full cleaned sample for Original and apply `HHSize<=cap` for capped samples. Compare sample Ns to the thesis table before interpreting estimates.
