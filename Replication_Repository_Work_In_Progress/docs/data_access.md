# Data Sources, Access and Management

This document provides information on the original survey datasets used in the two empirical chapters of my MPhil thesis in Economics at the University of Nottingham. It outlines the official data sources, access procedures and the original survey files required for the research.

The datasets are not included in this repository and must be obtained separately from their respective official sources.

---

## 1. Chapter 1 — Women's Decision-Making in India: NFHS-3, NFHS-4 and NFHS-5

### Official data sources

The first chapter uses data from three rounds of India's National Family Health Survey (NFHS), focusing on women's household decision-making, time trends and birth-cohort differences.

The required Individual Recode (IR) datasets are available through the following official sources:

- [NFHS/IIPS Data Request Portal](https://www.nfhsiips.in/nfhsuser/datarequest.php)
- [Demographic and Health Surveys (DHS) Program – Available Datasets](https://dhsprogram.com/data/available-datasets.cfm)
- [National Family Health Survey – IIPS](https://www.nfhsiips.in/)

### Survey rounds

| Survey | Survey period | Dataset required |
|---|---|---|
| NFHS-3 | 2005–06 | Individual Recode (IR) |
| NFHS-4 | 2015–16 | Individual Recode (IR) |
| NFHS-5 | 2019–21 | Individual Recode (IR) |

### Data access procedure

1. Register or sign in through the official NFHS/IIPS or DHS data-access portal.
2. Select India and the required survey rounds: NFHS-3, NFHS-4 and NFHS-5.
3. Request the corresponding Individual Recode datasets.
4. Provide a research-purpose abstract or project description, where required.
5. Complete the applicable data-access and usage requirements.
6. Download the authorised datasets and store them locally in `data/raw/chapter_1_nfhs/`.

Access is subject to the relevant registration, approval and data-use conditions. The NFHS/IIPS data-use notice includes restrictions on redistribution, respondent privacy and the use of derivative materials. Users should consult the applicable terms before accessing or sharing any data or research outputs.

### Data management

The original NFHS datasets are retained separately for each survey round. Their official filenames, formats and survey identifiers should be checked against the accompanying documentation before running the research scripts.

---

## 2. Chapter 2 — Impact of the 2004 Indian Ocean Tsunami on Household Consumption: NSSO 61st Round

### Official data sources

The second chapter examines the short-run and long-run effects of the 2004 Indian Ocean tsunami on household consumption in Andhra Pradesh, using data from the National Sample Survey Organisation (NSSO) 61st Round Household Consumer Expenditure Survey.

The survey was conducted between July 2004 and June 2005.

The original survey datasets and supporting documentation are available through:

- [MoSPI Microdata Portal – NSS 61st Round Household Consumer Expenditure Survey](https://microdata.gov.in/NADA/index.php/catalog/108)
- [MoSPI Microdata Catalogue – Household Consumer Expenditure](https://microdata.gov.in/NADA/index.php/catalog/CEXP)
- [Ministry of Statistics and Programme Implementation (MoSPI)](https://www.mospi.gov.in/)
- [NSS 61st Round Survey Report – Report No. 512](https://mospi.gov.in/sites/default/files/publication_reports/512_final_0.pdf)

### Survey details

| Description | Details |
|---|---|
| Survey | Household Consumer Expenditure |
| Survey round | NSS 61st Round |
| Schedule | Schedule 1.0 |
| Survey period | July 2004 – June 2005 |
| Data provider | National Sample Survey Office (NSSO) |
| Research application | Household consumption and expenditure analysis |

### Original NSSO raw data files

The NSS 61st Round Schedule 1.0 survey is organised into different blocks covering household identification, household characteristics, individual demographics and consumption expenditure.

The following original survey files are relevant to the research:

| Original survey file | Description |
|---|---|
| Blocks 1, 2 and 12 | Household identification, field-operation details and food sufficiency |
| Block 3 Part 1 | Household characteristics |
| Block 3 Part 2 | Additional household characteristics |
| Block 4 | Person-level demographic records |
| Block 5 | Food, pan, tobacco and intoxicants |
| Block 6 | Fuel and lighting consumption |
| Block 7 | Clothing and bedding consumption |
| Block 8 | Footwear consumption |
| Block 9 | Education and medical expenditure |
| Block 10 | Miscellaneous goods and services expenditure |
| Block 11 | Purchase, construction and repair expenditure |

For further information, consult the official [NSS 61st Round Data Dictionary](https://microdata.gov.in/NADA/index.php/catalog/108/data-dictionary) and [Related Materials](https://microdata.gov.in/NADA/index.php/catalog/108/related-materials), which provide survey documentation and supporting information.

### Data access procedure

1. Visit the official MoSPI Microdata Portal.
2. Open the NSS 61st Round Household Consumer Expenditure Survey catalogue.
3. Review the available original survey files and accompanying documentation.
4. Follow the access and download procedures specified by MoSPI, including any applicable registration and data-use requirements.
5. Download the required survey blocks and associated documentation.
6. Store the original downloaded files locally in `data/raw/chapter_2_nsso/`.

The downloaded files should retain their original names and formats wherever possible. Refer to the official data dictionary and survey documentation when identifying variables and understanding the structure of the different survey blocks.

---

## 3. Data Organisation and Management

The repository uses a structured directory system to keep research data separate from the publicly accessible code and documentation.

| Directory | Description |
|---|---|
| `data/raw/` | Original survey datasets downloaded directly from official sources |
| `data/interim/` | Intermediate research data |
| `data/processed/` | Data used for empirical analysis |

The original NFHS and NSSO datasets are not included in this public repository. All data folders are excluded from Git tracking.

Respondent-level microdata, restricted extracts, confidential records, data-access credentials and approval correspondence must not be uploaded.

Only original research code, documentation, permitted supporting materials and non-disclosive research outputs should be included in the public repository.

---

## 4. Data Acknowledgement and Usage

All survey datasets remain subject to the ownership, copyright, access conditions and data-use requirements of their respective providers.

Researchers accessing these datasets are responsible for:

- Following the applicable registration and approval procedures.
- Complying with the relevant data-use and confidentiality requirements.
- Respecting restrictions on redistribution and disclosure of respondent-level information.
- Acknowledging the original survey providers in research outputs.
- Checking whether any tables, figures or other research outputs may be publicly shared.

Users should consult the original survey documentation and applicable data-use agreements before undertaking further research or distributing materials based on these datasets.

---

## 5. Scope of This Documentation

This document identifies the original survey sources and describes the data requirements for the two empirical chapters of my MPhil thesis.

The accompanying research scripts demonstrate selected aspects of my work in data management, variable construction, econometric analysis and statistical programming using Stata, R and Python.

This repository is primarily intended as a **professional research portfolio showcasing my quantitative research experience and technical expertise**. It provides an overview of the empirical methods and programming approaches used in my thesis and is not presented as a complete, independently verified replication package.
