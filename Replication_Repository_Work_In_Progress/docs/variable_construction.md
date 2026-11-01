# Variable Construction and Research Notes

## Chapter 1 — NFHS: Women's Decision-Making Power

### 1. Sample and Birth Cohorts

The analysis uses NFHS-3, NFHS-4 and NFHS-5 data. The intended sample consists of ever-married women aged 15–49 who are usual residents.

The original Stata code applies the sample restrictions `v502==1` and `v135==1` in NFHS-3 and NFHS-4, but does not clearly apply both restrictions in NFHS-5. The revised scripts apply these restrictions consistently across all three rounds.

However, the meaning of `v502==1` should be checked against the survey codebooks to confirm whether it includes all ever-married women or only currently married women.

Birth year is calculated using the original formula:

`floor((v011-1)/12)+1900`

Four birth cohorts are used:

- 1956–1965
- 1966–1975
- 1976–1985
- 1986–2005

The final cohort covers 20 years, while the others cover 10 years.

### 2. Women's Decision-Making Outcomes

Three decision-making outcomes are considered:

- **Joint decision-making:** Respondent decides alone or jointly with her husband/partner (response codes 1 and 2).
- **Independent decision-making:** Respondent makes the decision alone (response code 1).
- **No decision-making power:** Husband/partner alone, someone else or other responses (codes 3–5).

The original Stata code leaves response code 3 missing in its binary outcome variables. This differs from the definitions described in the research.

The revised scripts therefore include two versions of the outcomes:

- Variables following the research definitions.
- Variables retaining the original coding, marked with the suffix `_legacy`.

Response code 6 is left missing until its meaning is confirmed using the relevant survey codebook. Response code 9 is treated as missing, following the original code.

### 3. Other Variables and Harmonisation

The following variables are used in the analysis:

- Respondent's age: `v012`
- Age difference with partner: `v730-v012`
- Household size: `v136`
- Wealth index: `v190`
- Place of residence: `v025`
- Media exposure: Based on `v157`, `v158` and `v159`

The survey weight is calculated as `v005/1e6`. However, the original probit models do not consistently use this weight.

Some variables differ across survey rounds and require harmonisation:

- Respondent's education is taken from `v149` in NFHS-3 and `v106` in NFHS-4 and NFHS-5.
- Partner's education is taken from `v715` in NFHS-3 and `v701` in NFHS-4 and NFHS-5. NFHS-3 years of schooling are grouped into four categories to make them broadly comparable.
- Partner's employment is required in the results code but is not directly created in the original preparation file. The revised scripts construct a provisional measure using `v704`, which should be checked against the relevant codebooks.
- State codes are harmonised across survey rounds. The revised scripts also create `State2`, which is required by the results code.

### 4. Data Preparation

The original NFHS preparation file has some gaps in the final data preparation process.

In particular, the final append step reopens the original survey files instead of appending the previously prepared datasets. It also saves the data before creating the birth cohort and selecting the final variables.

Some variables required by the results file are therefore not available in the saved dataset.

The revised scripts address these gaps by applying consistent sample restrictions, constructing the required outcomes and harmonising variables across all three survey rounds.

---

## Chapter 2 — NSSO: Impact of the 2004 Tsunami on Household Consumption

### 1. Sample and Treatment Groups

The analysis uses the NSSO 61st Round Household Consumer Expenditure Survey.

The study compares:

- **More severely affected districts:** Krishna, Prakasam and Nellore.
- **Less severely affected districts:** Guntur, West Godavari, East Godavari, Visakhapatnam and Srikakulam.

Two time periods are considered:

- **Short-run analysis:** SubRounds 1–2 before the tsunami and SubRound 3 after the tsunami. The reported thesis sample is 1,658 households.
- **Longer-horizon analysis:** SubRounds 1–2 before the tsunami and SubRounds 3–4 after the tsunami. The reported thesis sample is 2,180 households.

The original analysis files assume that the treatment, post-tsunami indicators, household identifiers and expenditure variables already exist. The complete process for constructing these variables from the original survey files is not available in the supplied analysis scripts.

### 2. Household Matching and Control Variables

The original analysis matches household data with person-level records using `HHID` and retains matched observations.

The following sample restrictions are preserved:

- Keep observations successfully matched across the two datasets.
- Exclude observations with missing treatment status.

The analysis also uses the following control variables:

- Household agricultural status.
- Social group.
- Ration card type.
- Religion.
- Type of dwelling.

The original coding is retained for these variables. Where missing source categories are treated as zero in the original code, this is documented rather than silently changed.

### 3. Log Transformations (Robustness Checks)

Log transformations using `ln(x+1)` were carried out as **robustness checks** to examine whether the results changed when expenditure variables were expressed in logarithmic form.

The main analysis uses the original expenditure measures. The log-transformed specifications provide an additional check on the results.

Values equal to or below -1 cannot be transformed using this formula. Such observations are identified and documented rather than changed to force the transformation.

### 4. Parallel Trends

The Difference-in-Differences analysis uses parallel-trends tests to examine whether the treatment and comparison groups followed similar trends before the tsunami.

Some original Stata files label p-values above 0.05 as `PASS`. This wording is not appropriate because a p-value above 0.05 only means that the test does not reject the hypothesis being examined. It does not prove that parallel trends hold.

The revised reporting therefore presents the test results more carefully, including the test statistic and p-value.

### 5. Household-Size Robustness Checks

The household-size robustness analysis examines whether the results change when households above certain size limits are excluded.

The original analysis considers:

- Original, uncapped sample.
- Household-size limits of 8, 9, 10, 11, 12 and 13 members.

The revised scripts retain the full sample as the original specification and apply the different household-size limits separately.

Sample sizes should be compared with the corresponding research tables before interpreting differences in the estimates.
