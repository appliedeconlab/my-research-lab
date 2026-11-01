# Replication repository

This repository contains two separate replication workflows, with Stata as the reference implementation and R/Python counterparts where the available source materials support them.

**Correct chapter order:** Chapter 1 is the NFHS study of women's household decision-making; Chapter 2 is the NSSO 61st Round tsunami and household-consumption study.

## Repository structure

```text
.
├── README.md
├── RESEARCH_PORTFOLIO_NOTICE.md
├── requirements.txt
├── renv_packages.R
├── run_chapter_1.do
├── run_chapter_2.do
├── code/
│   ├── stata_setup.do
│   ├── chapter_1/{stata,r,python}/
│   │   ├── 01_cleaning.*
│   │   └── 02_analysis.*
│   └── chapter_2/{stata,r,python}/
│       ├── 01_cleaning.*
│       └── 02_analysis.*
├── data/
│   ├── raw/          # Data downloaded directly from the original sources
│   ├── interim/      # prepared source inputs; excluded from Git
│   └── processed/    # analysis-ready microdata; excluded from Git
├── docs/
│   ├── data_access.md
│   ├── variable_construction.md
│   ├── replication_limitations.md
│   ├── source_audit.md
│   └── source_inventory.csv
├── legacy_source/    # path-sanitised snapshots of supplied do-files
└── output/{tables,figures,logs,diagnostics}/
```

## Important: Scope and Reproducibility

This repository contains the Stata do-files, supporting documentation, and replication scripts developed as part of my University of Nottingham MPhil thesis in Economics.

The original datasets are not included in this repository. They must be downloaded separately from their respective official sources, subject to the applicable data-access and usage requirements.

The repository showcases my research workflow, including data cleaning, variable construction, econometric analysis, and implementations using Stata, R and Python. The scripts are organised by thesis chapter to demonstrate the empirical methods and programming skills used in my research.

The numerical results are dependent on access to the original survey datasets and the successful execution of the corresponding scripts. Therefore, this repository is primarily intended to document and showcase my quantitative research expertise and does not constitute a fully verified, end-to-end numerical replication.

The thesis and associated academic materials are referenced as the basis of the research but are not reproduced in this public repository.

## Software

- **Stata:** Stata 18+ recommended. The scripts use `didregress`, `estat ptrends`, and `dtable`. Run `do code/stata_setup.do` once; it checks Stata commands and installs `estout` and `outreg2` from SSC if absent.
- **R:** R 4.3+ recommended. Run `source("renv_packages.R")`. `fixest` is used for the DiD models; `marginaleffects` for probit average marginal effects.
- **Python:** Python 3.10+ recommended. Install dependencies:

```bash
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\\Scripts\\activate
pip install -r requirements.txt
```

No random sampling or simulation is used in the core workflows, so no random seed is required. If resampling is added later, set and record a fixed seed in every language.

## Chapter 1 — Women’s decision-making: NFHS-3/4/5

### Obtain raw data

The raw NFHS-3, NFHS-4 and NFHS-5 Individual Recode (IR) datasets are available through the official [Demographic and Health Surveys (DHS) Program data portal](https://dhsprogram.com/data/available-datasets.cfm?utm_source=chatgpt.com). Researchers can register for an account and submit a data-access request, specifying the research purpose. Access is subject to DHS data-use conditions. The datasets are not redistributed through this repository. Please follow the applicable terms and acknowledge the original data source when using the data.

The expected filenames for the supplied do-files are:
- `IAIR52FL_2005_06.dta`
- `IAIR74FL_2015_16.DTA`
- `IAIR7EFL_2019_21.DTA`

Place the authorised files in `data/raw/chapter_1_nfhs/`. Download is manual because the access process is account-based and approval/terms apply; the scripts do not automate credentialed downloads.

### Run

From the repository root:

**Stata**
```stata
do code/chapter_1/stata/01_cleaning.do
do code/chapter_1/stata/02_analysis.do
```

**R**
```r
source("code/chapter_1/r/01_cleaning.R")
source("code/chapter_1/r/02_analysis.R")
```

**Python**
```bash
python code/chapter_1/python/01_cleaning.py
python code/chapter_1/python/02_analysis.py
```

The cleaning stage creates `data/processed/chapter_1_nfhs/nfhs_analysis_ready.csv` and `.dta`. The analysis stage reads only the cleaned file. Outputs include descriptive shares by round/cohort, probit coefficients, average marginal effects, religion-specific estimates, and figures.

### Checks

The thesis reports large-purchase response Ns of 81,365 (NFHS-3), 81,480 (NFHS-4), and 72,450 (NFHS-5), pooled N=235,295. Compare the generated counts against these benchmarks after confirming the exact response-missingness rule. Cohorts are 1956–65, 1966–75, 1976–85 and 1986–2005; the final cohort is twice as wide as the first three.

## Chapter 2 — 2004 tsunami and household consumption: NSSO 61st Round

### Obtain raw/interim data

The original analysis do-files require these inputs in `data/interim/chapter_2_nsso/`:

- `AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta`
- `AP_Aggregates_Merged_All_SubRound_Consistent_Sample.dta`
- `person_record.dta`

The person-level preparation file also refers to `Block 4_Person records.dta`; place an authorised copy in `data/raw/chapter_2_nsso/` if reproducing the optional household-demographic construction. The supplied source does not show a complete item-level NSSO aggregation pipeline or the full construction of the aggregate files and `person_record.dta`. Do not infer those steps from the analysis files.

Request NSS 61st Round Schedule 1 Consumer Expenditure microdata and relevant documentation through the [MoSPI Microdata Portal catalogue](https://microdata.gov.in/NADA/index.php/catalog/CEXP) and review the [current MoSPI access FAQ](https://mospi.gov.in/faq). Registered research/non-commercial access currently requires portal registration, an application and a Data Access Agreement/Undertaking; follow the current MoSPI rules, including affiliation requirements for foreign users. The portal's catalogue lists the July 2004–June 2005 NSS 61st Round. Because access is registered and agreement-based, the repository deliberately does not automate login or data retrieval.

### Run

**Stata**
```stata
do code/chapter_2/stata/01_cleaning.do
do code/chapter_2/stata/02_analysis.do
```

**R**
```r
source("code/chapter_2/r/01_cleaning.R")
source("code/chapter_2/r/02_analysis.R")
```

**Python**
```bash
python code/chapter_2/python/01_cleaning.py
python code/chapter_2/python/02_analysis.py
```

The cleaning stage reports merge attrition before preserving the original `merge 1:1 HHID` / `_merge==3` rule, then applies the original nonmissing `robust_treat1` restriction. It creates `ln_* = ln(x+1)` and reports missing, `x<=-1`, and transformed-missing counts. Analysis outputs main DiD estimates, descriptives, household-size robustness for Original and caps 8–13, and subgroup estimates.

### Checks

The thesis reports N=1,658 for the short-run sample (SubRounds 1–2 vs 3) and N=2,180 for the longer horizon (SubRounds 1–2 vs 3–4), before any additional attrition caused by the household-person merge. The thesis Appendix A reports SR sample counts of 1,658 (Original), 1,627 (cap 8), 1,638 (cap 9), 1,644 (cap 10), 1,650 (cap 11), 1,654 (cap 12), and 1,655 (cap 13). Compare these only after establishing that the input samples and merge keys match.

## Cross-language comparison

- Stata `didregress` is the reference DiD implementation. R uses `fixest::feols` with district and sub-round fixed effects and district clustering. Python uses `statsmodels` OLS with the same fixed effects and clustered covariance. Finite-sample corrections and degrees-of-freedom conventions may cause standard errors/p-values to differ.
- Stata `estat ptrends` is retained as the reference parallel-trends diagnostic. R/Python do not claim an exact equivalent in this repository.
- Stata probit margins use `margins, dydx(*)`; R uses `marginaleffects::avg_slopes`; Python uses `statsmodels` `get_margeff(at="overall", dummy=True)`. Factor-variable base categories and categorical discrete-change calculations must be checked before asserting exact numerical parity.
- The NFHS outcome recodes in the supplied do-file conflict with the thesis prose. The primary workflow follows the thesis definitions and retains literal legacy-coded variables for full-sample/cohort comparison; religion-split models use the thesis-definition outcomes. The harmonised NFHS-5 sample filter is a documented repair because the supplied NFHS-5 block omits the filters visible in NFHS-3/4; see `docs/variable_construction.md`. Failed/singular probit models are recorded in `output/diagnostics/` rather than silently discarded.

## Public GitHub rules

Raw, interim and processed data folders are excluded from GitHub. The original NFHS/NSSO datasets should be downloaded directly from their respective official sources. Do not upload respondent-level microdata, restricted datasets, access credentials or confidential information to this repository. Only research code, documentation, non-confidential logs, diagnostics and outputs permitted for public sharing should be included.
