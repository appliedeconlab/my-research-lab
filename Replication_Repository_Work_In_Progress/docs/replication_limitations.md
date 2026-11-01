# Replication limitations and unresolved inputs

## Dataset availability

No raw or derived datasets were present among the supplied conversation uploads or the supporting thesis materials reviewed. The following are missing:
- NFHS-3/4/5 Individual Recode `.DTA` files.
- NSSO short-run and long-run aggregate household `.dta` files.
- `person_record.dta`.
- `Block 4_Person records.dta`.

Numerical reproduction, sample validation, merge attrition checks on actual records, table parity and figure parity therefore remain unverified.

## Chapter 1

1. The uploaded NFHS cleaning file's final append block reopens raw source files rather than appending the three cleaned round datasets.
2. `Main_Data.dta` is saved before `Birth_Cohort` and the final variable selection are applied.
3. The NFHS-5 source block omits the visible `v502==1` and `v135==1` filters and does not visibly create all three decision outcomes. The new cleaner applies the stated sample filters to all waves and constructs all three domains; this is an explicit harmonisation repair.
4. The thesis sample is described as ever-married, but the code uses `v502==1`; verify the exact round-specific meaning against codebooks before certifying sample parity.
5. The thesis outcome definition places husband/partner-only responses in the non-participation group; the literal code leaves response 3 missing. Both codings are retained in the new clean data.
6. NFHS-3 partner education is based on `v715` years, while NFHS-4/5 use `v701` categorical level. The harmonisation is provisional.
7. `hs_empl` is absent from the supplied cleaning script. The new scripts derive it provisionally from `v704`; confirm against the raw round codebooks and final analysis data.
8. The source generates `wt` but the results script estimates unweighted probits with model-based standard errors; it does not use `svyset`, probability weights, robust or clustered VCE. This is preserved for source-aligned estimation. Weighted survey-design results are a separate robustness analysis, not silently substituted.
9. The cohort intervals are unequal: three 10-year cohorts and one 20-year cohort.
10. Stata `margins, dydx(*)` and R/Python AME implementations can differ for categorical regressors; compare reference categories and discrete-change definitions.
11. The viva notes state that the attached NFHS preparation and results files are not a fully self-contained final pipeline and specifically note the missing NFHS-5 sample filters. The new pipeline's common NFHS-5 filter is therefore a documented repair, not a verified historical execution record.

## Chapter 2

1. The final thesis and viva notes report inconsistent short-run clothing significance across outputs: Table 4.4 marks the controlled estimate -45.743 (SE 22.410) at 5%; Table 5.10 reports p=0.081 and marks it at 10%; Appendix Table A.1 reports an Original-sample estimate -43.865 with p=0.074. These may reflect different specifications, sample versions or inference conventions. Do not force them into one value; reproduce each table's precise specification and reconcile against the original logs/data.
2. The final thesis text says the short-run parallel-trends p-value for clothing is about 0.15 and treats this as support for a causal interpretation. Report the test and interpret p>0.05 only as failure to reject the tested deviation; it is not proof of parallel trends. MPCE is reported to fail the parallel-trends check (p=0.002 in the short-run table).
3. The supplied files start from pre-aggregated household datasets. The complete item-level expenditure aggregation and household merge pipeline is not included.
2. `robust_treat1`, `did_robust1`, `after_tsunami`, `SubRound`, `District`, and treatment geography are assumed, not fully constructed in the supplied analysis scripts.
3. `person_record.dta` is required by the analysis but is not among the uploads. `Household_Head_Dep_Ratio.do` uses `Block 4_Person records.dta` and creates `HH_level_AP_demographics.dta`; it does not create the `person_record.dta` consumed by the main analyses. Its visible fields do not establish all of `HH_AdultFemaleProp` and `HH_Head_Education`. The new cleaning scripts optionally reproduce the visible Block 4 aggregation, but do not merge it into the main analysis or claim that it replaces `person_record.dta`.
4. All 1:1 HHID merge counts must be checked against the actual data; matched-only retention is preserved.
5. `LongRun_Analysis.do` contains a short-run header while loading the long-run aggregate file. Treat this as stale documentation unless a later version proves otherwise.
6. The three Appendix B dwelling/sector scripts are not identical: one is short-run only, one runs both horizons with separate logs, and one adds an absolute data-directory setting. All are retained as sanitized snapshots; exact parity with every historic appendix table is not asserted.
7. `Religion_Heterogeneity_Analysis_MASTER.do` and `2nd_December_Descriptives_DID.do` contain further subgroup/descriptive exports; their table layouts are not guaranteed by the harmonised outputs.
8. The source household-size script reports caps 8–13 and Original; the thesis appendix gives the Original sample size and cap Ns. Confirm the denominator and data version.
9. Several source files use `PASS` for `estat ptrends` p>.05. This is corrected in the new reporting language.
10. Eight district clusters limit inference; conventional cluster-robust standard errors may be unreliable with so few clusters. The repository preserves the thesis estimator and flags this limitation; small-cluster inference should be reported as an additional sensitivity analysis, not as if it were in the original output.

## Release status

The repository is structurally prepared for public GitHub, but the data-use terms must be checked before publishing any derived microdata, row-level output, or detailed logs. Only code, documentation, sanitised source snapshots and non-disclosive aggregate results should be published unless the relevant data agreements explicitly permit more.
