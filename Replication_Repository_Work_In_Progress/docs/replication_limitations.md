# Research Scope and Replication Limitations

## Data Availability and Sources

The original survey microdata are not included in this repository and must be obtained directly from the official sources:

- **NFHS-3, NFHS-4 and NFHS-5:** [Demographic and Health Surveys (DHS) Program – Available Datasets](https://dhsprogram.com/data/available-datasets.cfm)
- **NSSO Household Consumption Expenditure Surveys:** [Ministry of Statistics and Programme Implementation (MoSPI)](https://www.mospi.gov.in/)

Access to the datasets is subject to the respective registration, approval and data-use requirements. Users should consult the original sources for the relevant survey rounds and follow their data-use conditions.

Some supporting household-level datasets and intermediate files required for the original analysis were also unavailable. Consequently, numerical results and complete replication of the thesis findings have not been independently verified.

## Chapter 1: Women's Decision-Making in India

The analysis uses pooled NFHS-3, NFHS-4 and NFHS-5 data to examine women's household decision-making across survey rounds and birth cohorts.

The original scripts contain some inconsistencies in sample selection, variable construction and harmonisation across survey rounds. These have been addressed where possible in the accompanying scripts, with certain variable definitions remaining subject to verification against the original survey codebooks.

## Chapter 2: Indian Ocean Tsunami and Household Consumption

The analysis examines the short-run and long-run effects of the 2004 Indian Ocean tsunami on household consumption using NSSO data and a Difference-in-Differences framework.

The supplied source files rely on pre-aggregated household datasets and do not contain the complete expenditure aggregation and household-level data preparation process. Some treatment indicators, demographic variables and merge inputs also require further verification.

Differences in reported estimates and statistical significance across thesis tables and supporting outputs remain unresolved. The original estimation approach is documented, while parallel-trends assumptions and limitations associated with district-level clustering require careful interpretation.

## Scope of This Repository

This repository is primarily intended to showcase my MPhil research, empirical methodology and programming skills using Stata, R and Python.

It provides selected data-cleaning scripts, econometric analysis, supporting documentation and cross-language implementations. It should be viewed as a research and code portfolio rather than a fully verified, end-to-end replication package.

All scripts and results remain subject to the availability of the original datasets, verification of variable definitions and applicable data-use restrictions.
