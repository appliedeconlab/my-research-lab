# Source audit

## Materials reviewed

- 19 uploaded Stata do-files.
- Final MPhil thesis PDF and editable thesis document.
- Earlier Chapter 2 tsunami chapter draft.
- Thesis presentation.
- Viva detailed-answers document and variable-defence notes.
- No raw or derived dataset was supplied in the accessible materials.

## Correct chapter assignment

The final thesis order is:
- **Chapter 1:** Women’s Decision-Making Power in India: Time, Birth Cohort, and Religious Identity (NFHS-3/4/5).
- **Chapter 2:** Impact of the 2004 Tsunami on Household Consumption Expenditure in India: Evidence from Andhra Pradesh (NSSO 61st Round).

This corrects the chapter labels used in an earlier draft package.

## Source inventory

### Chapter 1 — NFHS (5 files)
- `Appending_Raw_Data(1).do`
- `Results(1).do`
- `Master_Do(1).do`
- `Results_Descriptives_Only_3dp(1).do`
- `Results_Descriptives_Tables_Landscape_3dp.do`

### Chapter 2 — NSSO (14 files)
- `ShortRun_Analysis.do`
- `LongRun_Analysis.do`
- `Heterogeneity_DID_AdditionalVariables(1).do`
- Three `AppendixB_Dwelling_Sector_Subgroup_Descriptives` variants
- `Religion_Heterogeneity_Analysis_MASTER.do`
- `HHSize_Robustness.do`
- `Household_Head_Dep_Ratio.do`
- `Determinants_Analysis_ShortRun.do`
- `Determinants_Analysis_LongRun.do`
- `Export_Determinants_to_LaTeX.do`
- `2nd_December_Descriptives_DID.do`
- `Print_All_DID_CSVs(1).do`

Sanitised source snapshots are under `legacy_source/`; the inventory records SHA-256 checksums of the uploaded originals.

## Principal defects

- NFHS preparation script reopens raw wave files in the final append block, saves before cohort construction and final variable selection, and does not produce several variables required by the probit script.
- NFHS source outcome recodes omit raw response code 3 although the thesis prose classifies husband/partner-only decision-making as no decision-making power.
- NFHS source generates `wt` but does not use it in the probit/margins models.
- NSSO analysis scripts depend on aggregate datasets and `person_record.dta` not supplied.
- The separate Block 4 script creates `HH_level_AP_demographics.dta`, not `person_record.dta`.
- NSSO treatment and post-period fields are assumed rather than reconstructed.
- Several source scripts contain absolute paths; sanitised snapshots remove them.
- Long-run file header says short run although it loads the long-run file.
- Parallel-trends output labels p>.05 as PASS; the new reporting corrects the interpretation.
- Three appendix variants differ in horizons/logging/path setup.

No numerical replication was run because no data were supplied.

## Additional checks from the viva notes and final thesis

- The viva notes independently identify the NFHS preparation/results pair as not fully self-contained and note that NFHS-5 does not visibly repeat the `v502==1` and `v135==1` sample restrictions.
- The thesis describes the NFHS sample as ever-married women aged 15–49 and usual residents. The code's `v502==1` filter must be checked against the round-specific codebooks before asserting that it operationalises all ever-married women.
- The final thesis defines joint participation as response 1 or 2 and independent decision-making as response 1. The supplied binary recodes omit response code 3 from the non-participation group; both versions are kept in the new data.
- The final thesis and viva notes flag inconsistent short-run clothing inference: -45.743 (SE 22.410) is marked at 5% in Table 4.4, while Table 5.10 reports p=0.081 (10% marker) and Appendix A.1 reports -43.865 with p=0.074 for the Original sample. The earlier Chapter 2 draft also marks -45.74 at 5% in its main table, while its appendix reports p=0.074. These are retained as unresolved output/specification discrepancies.
- The thesis reports a short-run clothing parallel-trends p-value around 0.15 and MPCE p=0.002. The former is not proof of parallel trends; the latter is a failed diagnostic under the reported test.
