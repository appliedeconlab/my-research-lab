# Data access and legal/technical constraints

## Chapter 1 — NFHS-3, NFHS-4 and NFHS-5

Official access portal: https://www.nfhsiips.in/nfhsuser/datarequest.php
The portal's current form asks for a research-purpose abstract and provides round-specific Individual Recode choices. The published notice includes privacy, non-redistribution and derivative-work restrictions; obtain any required written permission before distributing derived data or outputs.

1. Create/sign in to an account through the official NFHS/IIPS data request portal.
2. Select India and the relevant survey round and request the **Individual Recode** dataset.
3. Supply a research-purpose abstract/description as required by the portal.
4. Accept the current data-use and privacy terms; retain the approval notice privately.
5. Download the authorised Individual Recode files and place them in `data/raw/chapter_1_nfhs/` using the expected filenames listed in the README (renaming only when the official download is the same round/file under a different name).
6. Do not commit raw files, respondent-level extracts, credentials or approval correspondence to a public repository. Cite NFHS/IIPS as required. The current NFHS/IIPS notice says the data are for personal, educational or research use, prohibits unauthorised redistribution, and requires acknowledgement; it also states that derivative works require prior written permission. Check the terms for the particular download before publishing derived files.

The DHS Program also has an account/project request route for survey datasets. Follow the access route attached to the dataset you actually obtain; do not assume that approval from one portal automatically covers another.

## Chapter 2 — NSSO 61st Round

Official catalogue entry: https://microdata.gov.in/NADA/index.php/catalog/CEXP
The catalogue includes the July 2004–June 2005 NSS 61st Round Consumer Expenditure survey.
MoSPI access guidance: https://mospi.gov.in/faq
The current MoSPI FAQ describes registered-access unit-level data, one-time registration, an application and a Data Access Agreement/Undertaking for non-commercial research; it also specifies affiliation conditions for foreign applicants.

1. Open the official MoSPI Microdata Portal and search the Household Consumption Expenditure catalogue for **Household Consumer Expenditure, July 2004–June 2005, NSS 61st Round, Schedule 1**.
2. Register/sign in and complete the application and Data Access Agreement/Undertaking applicable to registered microdata.
3. Download the unit-level files and associated readme, data descriptions, codebooks and extraction documentation.
4. Identify the exact files/levels used to construct household aggregates, person records and item-level expenditure outcomes. Preserve their official names and release metadata in a private acquisition note.
5. Put raw licensed files in `data/raw/chapter_2_nsso/`; put the prepared aggregate files and `person_record.dta` in `data/interim/chapter_2_nsso/`.
6. Do not commit data to public GitHub unless the current licence/agreement expressly permits it. MoSPI's current guidance describes registered access for non-commercial research, an application and a binding data agreement; foreign users may need affiliation with a recognised institution. Confirm current conditions directly in the portal.

## Why no automatic downloader is included

Both acquisition routes are account/approval/agreement based. No stable public direct-download endpoint or licence allowing unattended retrieval was identified for the required files. The repository therefore uses explicit local input checks and fails with informative messages instead of asking users to embed passwords, bypass access controls or assume public download rights.

## Required input manifest

| Project | Expected input | Repository location | Status at audit |
|---|---|---|---|
| NFHS | IAIR52FL_2005_06.dta | data/raw/chapter_1_nfhs/ | Not supplied |
| NFHS | IAIR74FL_2015_16.DTA | data/raw/chapter_1_nfhs/ | Not supplied |
| NFHS | IAIR7EFL_2019_21.DTA | data/raw/chapter_1_nfhs/ | Not supplied |
| NSSO | AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta | data/interim/chapter_2_nsso/ | Not supplied |
| NSSO | AP_Aggregates_Merged_All_SubRound_Consistent_Sample.dta | data/interim/chapter_2_nsso/ | Not supplied |
| NSSO | person_record.dta | data/interim/chapter_2_nsso/ | Not supplied |
| NSSO | Block 4_Person records.dta | data/raw/chapter_2_nsso/ | Not supplied |
