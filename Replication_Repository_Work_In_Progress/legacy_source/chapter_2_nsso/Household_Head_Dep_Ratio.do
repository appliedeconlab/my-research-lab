*===============================================================================
* PROCESSING PERSON-LEVEL DATA TO CREATE HOUSEHOLD-LEVEL VARIABLES
* NSSO 61st Round - Block 4 Person Records
*===============================================================================

* Clear existing data
clear all
set more off

* Load your person-level data
use "Block 4_Person records.dta", clear

*-------------------------------------------------------------------------------
* STEP 0: DESTRING VARIABLES (Convert string to numeric)
*-------------------------------------------------------------------------------

* Check which variables are strings
describe State Gender Household_Head Age

* Destring the key variables we need
destring State, replace
destring Gender, replace
destring Household_Head, replace
destring Age, replace

* Verify they are now numeric
describe State Gender Household_Head Age

*-------------------------------------------------------------------------------
* STEP 1: FILTER FOR ANDHRA PRADESH (State Code = 28)
*-------------------------------------------------------------------------------
keep if State == 28

* Check how many observations
count
di "Number of person records in Andhra Pradesh: `r(N)'"

*-------------------------------------------------------------------------------
* STEP 2: IDENTIFY HOUSEHOLD HEAD AND THEIR GENDER
*-------------------------------------------------------------------------------

* Household_Head variable: 1 = Self (household head), 2 = Spouse, etc.
* Gender variable: 1 = Male, 2 = Female

* Create indicator for household head (Relation = 1 means "Self" = head)
gen is_head = (Household_Head == 1)
label var is_head "Is this person the household head?"
label define is_head_lbl 0 "No" 1 "Yes"
label values is_head is_head_lbl

* Get household head's gender for each household
* First, create a variable that holds head's gender (only for head, missing for others)
gen head_gender_temp = Gender if is_head == 1

* Now collapse to get the head's gender at household level
bysort HHID: egen hh_head_gender = max(head_gender_temp)
label var hh_head_gender "Gender of Household Head"
label define hh_head_gender_lbl 1 "Male" 2 "Female"
label values hh_head_gender hh_head_gender_lbl

* Create female-headed household indicator
gen female_headed = (hh_head_gender == 2)
label var female_headed "Female-Headed Household"
label define female_headed_lbl 0 "Male-Headed" 1 "Female-Headed"
label values female_headed female_headed_lbl

* Get household head's age
gen head_age_temp = Age if is_head == 1
bysort HHID: egen hh_head_age = max(head_age_temp)
label var hh_head_age "Age of Household Head"

*-------------------------------------------------------------------------------
* STEP 3: CREATE DEPENDENCY RATIO
*-------------------------------------------------------------------------------

* Standard definition:
* - Children: Age 0-14
* - Working Age: Age 15-64
* - Elderly: Age 65+
* Dependency Ratio = (Children + Elderly) / Working Age Adults

* Create age group indicators for each person
gen child = (Age >= 0 & Age <= 14)
gen working_age = (Age >= 15 & Age <= 64)
gen elderly = (Age >= 65 & Age <= 101)

label var child "Child (Age 0-14)"
label var working_age "Working Age (Age 15-64)"
label var elderly "Elderly (Age 65+)"

* Count number in each category per household
bysort HHID: egen num_children = total(child)
bysort HHID: egen num_working_age = total(working_age)
bysort HHID: egen num_elderly = total(elderly)

label var num_children "Number of Children (0-14) in HH"
label var num_working_age "Number of Working Age (15-64) in HH"
label var num_elderly "Number of Elderly (65+) in HH"

* Calculate dependency ratio
gen dependency_ratio = (num_children + num_elderly) / num_working_age
label var dependency_ratio "Dependency Ratio: (Children + Elderly) / Working Age"

* Handle edge case: households with zero working-age members
replace dependency_ratio = . if num_working_age == 0

* Check for problematic cases
count if num_working_age == 0
di "Number of persons in HHs with zero working-age members: `r(N)'"

*-------------------------------------------------------------------------------
* STEP 4: CREATE HOUSEHOLD SIZE
*-------------------------------------------------------------------------------
bysort HHID: egen hh_size = count(HHID)
label var hh_size "Household Size"

*-------------------------------------------------------------------------------
* STEP 5: COLLAPSE TO HOUSEHOLD LEVEL
*-------------------------------------------------------------------------------

* Keep only relevant variables
keep HHID SubRound hh_head_gender female_headed ///
     hh_head_age num_children num_working_age num_elderly ///
     dependency_ratio hh_size

* Remove duplicates - keep one row per household
bysort HHID: keep if _n == 1

* Verify we have one observation per household
isid HHID
di "Number of households in Andhra Pradesh: `c(N)'"

*-------------------------------------------------------------------------------
* STEP 6: FINAL LABELS AND CHECKS
*-------------------------------------------------------------------------------

* Summary statistics
summarize

* Check distribution of female-headed households
tab female_headed, missing

* Check dependency ratio distribution
summarize dependency_ratio, detail

*-------------------------------------------------------------------------------
* STEP 7: SAVE THE HOUSEHOLD-LEVEL DATASET
*-------------------------------------------------------------------------------

* Save the processed data
save "HH_level_AP_demographics.dta", replace

di ""
di "=============================================="
di "HOUSEHOLD-LEVEL DATASET CREATED SUCCESSFULLY"
di "=============================================="
di "File saved as: HH_level_AP_demographics.dta"
di "Number of households: `c(N)'"
di "=============================================="
