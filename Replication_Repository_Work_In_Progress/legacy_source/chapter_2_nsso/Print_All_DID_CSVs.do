*==============================================================================
* PRINT ALL DID RESULT CSVs TO THE LOG (so standard errors are visible)
*
* The earlier runs already wrote every DiD coefficient AND standard error to the
* *_DID_*_Results.csv files (column DiD_SE). The log only displayed the
* coefficient and p-value, and the religion block hid its display inside
* capture{}. This file re-reads nothing and re-runs no regression: it simply
* dumps each CSV verbatim into the output, so the full numbers (coef, SE,
* p-value, PT, N, R2) appear in one place.
*
* RUN from the directory that contains the CSV files (the same working directory
* the master + additional do-files wrote to). Then send the resulting log/PDF.
*==============================================================================

display _newline(2)
display "=================================================================="
display "  ALL DID RESULTS (coef, SE, p-value, PT, N) FROM CSV FILES"
display "=================================================================="

foreach f in ///
    SR_DID_FullSample_Results        LR_DID_FullSample_Results        ///
    SR_DID_Gender_Results            LR_DID_Gender_Results            ///
    SR_DID_Religion_Results          LR_DID_Religion_Results          ///
    SR_DID_SocialGroup_Results       LR_DID_SocialGroup_Results       ///
    SR_DID_Dwelling_Unit_new_Results LR_DID_Dwelling_Unit_new_Results ///
    SR_DID_Sector_Results            LR_DID_Sector_Results            ///
    SR_DID_Ration_Type_new_Results   LR_DID_Ration_Type_new_Results   ///
    SR_DID_HH_Type_Agri_Results      LR_DID_HH_Type_Agri_Results      {

    display _newline(1)
    display "===== `f'.csv ====="
    capture confirm file "`f'.csv"
    if _rc {
        display "  (file not found in this directory)"
    }
    else {
        type "`f'.csv"
    }
}

display _newline(1)
display "DONE - all available DID CSVs printed above."
*==============================================================================
