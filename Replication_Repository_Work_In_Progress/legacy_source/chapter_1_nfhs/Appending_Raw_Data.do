******************************************************************************** 
******************************************************************************** 
** Original author **
// Chapter One : Generational Trends of Women's Household Decision-Making : The influence of socio-economic and demographic factors in the Indian context. 
** Data Cleaning ** // Working only with the sample which has occupation data
******************************************************************************** 
** (1) NFHS-3 **
******************************************************************************** 
clear
// Survey Year 2005-06
set maxvar 32767 
use "$data_dir/Raw Data - Individual Recode Files/IAIR52FL_2005_06.dta", clear

** Label Yes / No **
cap label define yesno 0"No" 1"Yes"
** Generate DHS Round **
gen DHSRound = "NFHS_3"
*** To generate weight ***
gen wt= v005/1000000
** Re-coding Birth Year **
gen Birth_Year = int((v011-1) / 12) + 1900

//Employment in the last 12 months
recode v731 (0=0 "No") (1/3=1 "Yes") (8/9=.) if v502==1, gen(we_empl)
label var we_empl "Employment status in the last 12 months among those currently in a union"
tab we_empl
//Employment by type of earnings
tab v741
recode v741 (9=.)
gen we_empl_earn=v741 if inlist(v731,1,2,3) & v502==1
codebook v741
label values we_empl_earn v741
label var we_empl_earn "Type of earnings among those employed in the past 12 months and currently in a union"
tab we_empl_earn
//Control over earnings
tab v739
recode v739 (9=.)
gen we_earn_wm_decide=v739 if inlist(v731,1,2,3) & inlist(v741,1,2) & v502==1
label values we_earn_wm_decide v739
label var we_earn_wm_decide "Who decides on wife's cash earnings for employment in the last 12 months"
tab we_earn_wm_decide
//Comparison of earnings with husband/partner
tab v746
recode v746 (9=.)
gen we_earn_wm_compare=v746 if inlist(v731,1,2,3) & inlist(v741,1,2) & v502==1
label values we_earn_wm_compare v746
replace we_earn_wm_compare=4 if v743f==7 & v746!=. & v502==1
label var we_earn_wm_compare "Comparison of cash earnings with husband's cash earnings"
tab we_earn_wm_compare
//Who decides on how husband's cash earnings are used
gen we_earn_hs_decide=v743f if v746!=4 & v743f!=7 & v502==1
replace we_earn_hs_decide=9 if v743f==8
cap label define v743f 9"Don't know/Missing", modify
label values we_earn_hs_decide v743f
label var we_earn_hs_decide	"Who decides on husband's cash earnings for employment in the last 12 months among women currently in a union"
tab we_earn_hs_decide
tab we_earn_hs_decide, nolabel
recode we_earn_hs_decide (9=.)
tab we_earn_hs_decide
** Decision making **
//Decides on own health
tab v743a
recode v743a (9=.)
codebook v743a
gen we_decide_health= v743a if v502==1
label values we_decide_health LABDZ
label var we_decide_health "Decides on own health care"
tab we_decide_health
//Decides on household purchases
tab v743b
recode v743b (9=.)
codebook v743b
gen we_decide_hhpurch= v743b if v502==1
label values we_decide_hhpurch LABDZ
label var we_decide_hhpurch "Decides on large household purchases"
tab we_decide_hhpurch
//Decides on visits
tab v743d
recode v743d (9=.)
codebook v743d
gen we_decide_visits= v743d if v502==1
label values we_decide_visits LABDZ
label var we_decide_visits "Decides on visits to family or relatives"
tab we_decide_visits
** Highest Educational Level **
tab v149
recode v149 (9=.)
codebook v149
gen rc_edu= v149
label values rc_edu v149
label var rc_edu "Highest level of schooling attended or completed"
tab rc_edu
** Education Levels **
tab v133
recode v133 (99=.)
gen education_category = .
replace education_category = 0 if v133 == 0
replace education_category = 1 if v133 >= 1 & v133 <= 5
replace education_category = 2 if v133 >= 6 & v133 <= 8
replace education_category = 3 if v133 >= 9 & v133 <= 10
replace education_category = 4 if v133 >= 11 & v133 <= 12
replace education_category = 5 if v133 >= 13 & v133 <= 15
replace education_category = 6 if v133 >= 16 & v133 <= 23
label define education_labels 0 "No Education" 1 "Lower Primary" 2 "Upper Primary" 3 "Lower Secondary" 4 "Higher Secondary" 5 "Undergraduate" 6 "Higher Studies"
label values education_category education_labels
label var education_category "Women's Education Category by Years"
** Binary Decision Making **
// Cash Earnings - Women
* (1) Only Women 
tab we_earn_wm_decide
tab we_earn_wm_decide, nolabel
generate we_earn_wm_decision_a = .
replace we_earn_wm_decision_a = 1 if we_earn_wm_decide == 1  
replace we_earn_wm_decision_a = 0 if we_earn_wm_decide == 2 | we_earn_wm_decide == 4 | we_earn_wm_decide == 5
label define yn10 0 "No" 1 "Yes"
label values we_earn_wm_decision_a yn10
tab we_earn_wm_decision_a
* (2) Women and Husband Jointly
tab we_earn_wm_decide
tab we_earn_wm_decide, nolabel
generate we_earn_wm_decision_b = .
replace we_earn_wm_decision_b = 1 if we_earn_wm_decide == 1 | we_earn_wm_decide == 2
replace we_earn_wm_decision_b = 0 if we_earn_wm_decide == 4 | we_earn_wm_decide == 5
label define yn11 0 "No" 1 "Yes"
label values we_earn_wm_decision_b yn11
tab we_earn_wm_decision_b
// Cash Earnings - Over Husband's Earnings
* (1) Only Women
tab we_earn_hs_decide
tab we_earn_hs_decide, nolabel
generate we_earn_hs_decide_a = .
replace we_earn_hs_decide_a = 1 if we_earn_hs_decide == 1  
replace we_earn_hs_decide_a = 0 if we_earn_hs_decide == 2 | we_earn_hs_decide == 4 | we_earn_hs_decide == 6
label define yn20 0 "No" 1 "Yes"
label values we_earn_hs_decide_a yn20
tab we_earn_hs_decide_a
* (2) Women and Husband Jointly
tab we_earn_hs_decide
tab we_earn_hs_decide, nolabel
generate we_earn_hs_decide_b = .
replace we_earn_hs_decide_b = 1 if we_earn_hs_decide == 1 | we_earn_hs_decide == 2
replace we_earn_hs_decide_b = 0 if we_earn_hs_decide == 4 | we_earn_hs_decide == 6
label define yn21 0 "No" 1 "Yes"
label values we_earn_hs_decide_b yn21
tab we_earn_hs_decide_b
// Family Visits
* (1) Only Women
tab we_decide_visits
tab we_decide_visits, nolabel
generate we_decide_visits_a = .
replace we_decide_visits_a = 1 if we_decide_visits == 1  
replace we_decide_visits_a = 0 if we_decide_visits == 2 | we_decide_visits == 4 | we_decide_visits == 5 | we_decide_visits == 6
label define yn30 0 "No" 1 "Yes"
label values we_decide_visits_a yn30
tab we_decide_visits_a
* (2) Women and Husband Jointly
tab we_decide_visits
tab we_decide_visits, nolabel
generate we_decide_visits_b = .
replace we_decide_visits_b = 1 if we_decide_visits == 1 | we_decide_visits == 2
replace we_decide_visits_b = 0 if we_decide_visits == 4 | we_decide_visits == 5 | we_decide_visits == 6
label define yn31 0 "No" 1 "Yes"
label values we_decide_visits_b yn31
tab we_decide_visits_b
// Health Decision
* (1) Only Women
tab we_decide_health
tab we_decide_health, nolabel
generate we_decide_health_a = .
replace we_decide_health_a = 1 if we_decide_health == 1 
replace we_decide_health_a = 0 if we_decide_health == 2 | we_decide_health == 4 | we_decide_health == 5 | we_decide_health == 6
label define yn40 0 "No" 1 "Yes"
label values we_decide_health_a yn40
tab we_decide_health_a
* (2) Women and Husband Jointly
tab we_decide_health
tab we_decide_health, nolabel
generate we_decide_health_b = .
replace we_decide_health_b = 1 if we_decide_health == 1 | we_decide_health == 2
replace we_decide_health_b = 0 if we_decide_health == 4 | we_decide_health == 5 | we_decide_health == 6
label define yn41 0 "No" 1 "Yes"
label values we_decide_health_b yn41
tab we_decide_health_b
// Household Purchase
* (1) Only Women
tab we_decide_hhpurch
tab we_decide_hhpurch, nolabel
generate we_decide_hhpurch_a = .
replace we_decide_hhpurch_a = 1 if we_decide_hhpurch == 1 
replace we_decide_hhpurch_a = 0 if we_decide_hhpurch == 2 | we_decide_hhpurch == 4 | we_decide_hhpurch == 5 | we_decide_hhpurch == 6
label define yn50 0 "No" 1 "Yes"
label values we_decide_hhpurch_a yn50
tab we_decide_hhpurch_a
* (2) Women and Husband Jointly
tab we_decide_hhpurch
tab we_decide_hhpurch, nolabel
generate we_decide_hhpurch_b = .
replace we_decide_hhpurch_b = 1 if we_decide_hhpurch == 1 | we_decide_hhpurch == 2
replace we_decide_hhpurch_b = 0 if we_decide_hhpurch == 4 | we_decide_hhpurch == 5 | we_decide_hhpurch == 6
label define yn51 0 "No" 1 "Yes"
label values we_decide_hhpurch_b yn51
tab we_decide_hhpurch_b
** Recode Variables **
* Caste *
tab s118
recode s118 (8/9=.)
tab s118
recode s118 (1/3=1 "SC/ST/OBC") (4=2 "Non-SC/ST/0BC"),g(caste)
tab caste
tab caste [iw=wt]
* Religion *
tab v130
tab v130, nolabel
recode v130 (9/99=.)
tab v130
recode v130 (1=1 "Hindu")(2=2 "Muslim")(3=3 "Christian") (4/8=4 "Others"),g(religion)
tab religion
tab religion [iw=wt]
** Media Exposure **
generate massmedia=0
replace massmedia=1 if v157==2
replace massmedia=1 if v158==2
replace massmedia=1 if v159==2
label define mediaexposure 0 "Without Media Exposure" 1 "With Media Exposure"
label values massmedia mediaexposure
tab massmedia
** Mother's socio-economic empowerment **
// 1 if the mother has taken decision alone in any of the three indicators, and 0 if the mother has not taken the decision alone in any of the three indicators //
// v743a (final say on own health care)
// v743b (final say on making large household purchases)
// v743d (final say on visits to family or relatives)
generate empower=0
replace empower=1 if v743a==1
replace empower=1 if v743b==1
replace empower=1 if v743d==1
label define empowerment 0 "Not making decision alone" 1 "Makes alone decision"
label values empower empowerment
tab empower
/// women and joint decision
generate empower_joint=0
replace empower_joint=1 if inlist(v743a,1,2)  
replace empower_joint=1 if inlist(v743b,1,2) 
replace empower_joint=1 if inlist(v743d,1,2)
label define empowerment_j 0 "Not making decision" 1 "Makes decision alone and jointly"
label values empower_joint empowerment_j
tab empower_joint
*IPV
*binary -  1 if yes to any wife beating justification, otherwise 0
gen combined_ipv=0
replace combined_ipv=1 if v744a==1|v744b==1|v744c==1|v744d==1|v744e==1 
*SON PREFERENCE
*ideal number of boys - ideal number of girls
gen son_difference=v627-v628
replace son_difference=. if v627==96 | v628==96
replace son_difference=. if v627==99 | v628==99
**** Year of survey ****
qui sum v007
scalar year_num = r(mean)
scalar year1=string(r(min))
scalar year2=string(r(max))

if (year1==year2) {
	scalar year3 = " "
	}
else if (year1!=year2) {
	scalar year3 = "-" + substr(year2,3,4)
	}
                                             
gen yr=year1 + year3
*****
* Health Insurance *
gen rc_hins=0
	foreach i in a b c d e f g h x {
	replace rc_hins=1 if v481`i'==1
	}
label var rc_hins "Have any health insurance"
label define ny 0 "No" 1 "Yes"
label values rc_hins ny
** Education Levels of Husband **
tab v715
tab v715, nolabel
recode v715 (98/99=.)
gen education_category_husband = .
replace education_category_husband = 0 if v715 == 0
replace education_category_husband = 1 if v715 >= 1 & v715 <= 5
replace education_category_husband = 2 if v715 >= 6 & v715 <= 8
replace education_category_husband = 3 if v715 >= 9 & v715 <= 10
replace education_category_husband = 4 if v715 >= 11 & v715 <= 12
replace education_category_husband = 5 if v715 >= 13 & v715 <= 15
replace education_category_husband = 6 if v715 >= 16 & v715 <= 24
label define education_labels_p 0 "No Education" 1 "Lower Primary" 2 "Upper Primary" 3 "Lower Secondary" 4 "Higher Secondary" 5 "Undergraduate" 6 "Higher Studies"
label values education_category_husband education_labels_p
label var education_category_husband "Husband's Education Category by Years"
** Number of living children **
recode v218 (4/max = 4 "4+"), gen(numchild)
* Step 1: Calculate the total number of sons (both at home and elsewhere)
gen total_sons = v202 + v204
* Step 2: Calculate the proportion of sons for each woman
gen prop_sons = total_sons /  numchild
* Step 3: Handle cases where no children were born (v201 == 0)
replace prop_sons = . if  numchild == 0
* Step 4: Display the summary statistics for proportion of sons
summarize prop_sons
///////
* Step 1: Calculate the total number of daughters (both at home and elsewhere)
gen total_girls = v203 + v205
* Step 2: Calculate the proportion of sons for each woman
gen prop_girls = total_girls /  numchild
* Step 3: Handle cases where no children were born (v201 == 0)
replace prop_girls = . if  numchild == 0
* Step 4: Display the summary statistics for proportion of sons
summarize prop_girls
** Gender of the First Child **
rename b*_0* b*_*
//
gen sex_of_first_child=.
//
local li=1
while `li'<=20 {
replace sex_of_first_child=b4_`li' if bord_`li'==1
local li=`li'+1
}

replace sex_of_first_child=0 if sex_of_first_child==.

label define first_child 0 "No children" 1 "Boy" 2 "Girl"
label values sex_of_first_child first_child
tab sex_of_first_child
** Household Size **
gen hh_size= v136

********
encode DHSRound, generate(DHSRound_num)
///

****** Occupation Category (Respondents')********
recode v716 (96/97=0 "No Occupation") (1/59=1 "Non-agriculture") (71/95=1 "Non-agriculture") (60=2 "farm plantation, dairy and other") (61=3 "cultivators") (62=4 "farmers, other than cultivators") (63=5 "agricultural labourer") (64=6 "plantation labourers & related workers") (65=7 "other farm workers") (66=8 "forestry workers") (67=9 "hunters and related workers ") (68=10 "fishermen and related workers"), gen(wm_occupation) 
recode wm_occupation (98/999 =.)
**
recode wm_occupation (0=0 "No Occupation") (1=1 "Non-agriculture") (3/5=2 "Cultivators and Agri-workers") (2=3 "Plantation and Farm Workers") (6/7=3 "Plantation and Farm Workers") (8/10=4 "Forestry, hunting and fishing"), gen(wm_occupation2)

///

****** Occupation Category (Husbands')********
recode v704 (96/97=0 "No Occupation") (1/59=1 "Non-agriculture") (71/95=1 "Non-agriculture") (60=2 "farm plantation, dairy and other") (61=3 "cultivators") (62=4 "farmers, other than cultivators") (63=5 "agricultural labourer") (64=6 "plantation labourers & related workers") (65=7 "other farm workers") (66=8 "forestry workers") (67=9 "hunters and related workers ") (68=10 "fishermen and related workers"), gen(hs_occupation) 
recode hs_occupation (98/999 =.)
**
recode hs_occupation (0=0 "No Occupation") (1=1 "Non-agriculture") (3/5=2 "Cultivators and Agri-workers") (2=3 "Plantation and Farm Workers") (6/7=3 "Plantation and Farm Workers") (8/10=4 "Forestry, hunting and fishing"), gen(hs_occupation2)

///


**********



** Age Difference **
gen age_difference = (v730 - v012)
tab  age_difference
** Household Head **
tab v151
gen sex_of_hhld_head = v151
label define hhld_head2 1 "male" 2"female" 3 "transgender"
label values sex_of_hhld_head hhld_head2
** Relationship to the head of household **
tab v150
recode v150 (99=.)
clonevar relationship = v150 
codebook relationship, tab (20)
recode relationship (1=1)(2=2)(3=3)(11=3)(4/10=4)(15/16=4)(12=5) (17=5) (98=.)
label define lab_relation2 1 "head" 2"spouse" 3"child" 4"extended family" 5"not related" 
label values relationship lab_relation2
label var relationship "Relationship to the head of household"
tab v150  relationship, miss
** State **
tab v024
label list  LABD
           1 [jm] jammu and kashmir
           2 [hp] himachal pradesh
           3 [pj] punjab
           5 [uc] uttaranchal
           6 [hr] haryana
           7 [dl] delhi
           8 [rj] rajasthan
           9 [up] uttar pradesh
          10 [bh] bihar
          11 [sk] sikkim
          12 [ar] arunachal pradesh
          13 [na] nagaland
          14 [mn] manipur
          15 [mz] mizoram
          16 [tr] tripura
          17 [mg] meghalaya
          18 [as] assam
          19 [wb] west bengal
          20 [jh] jharkhand
          21 [or] orissa
          22 [ch] chhattisgarh
          23 [mp] madhya pradesh
          24 [gj] gujarat
          27 [mh] maharashtra
          28 [ap] andhra pradesh
          29 [ka] karnataka
          30 [go] goa
          32 [ke] kerala
          33 [tn] tamil nadu


* Recode the states
recode v024 (1=1 "jammu & kashmir") (2=2 "himachal pradesh") (3=3 "punjab") (5=5 "uttarakhand") (6=6 "haryana") (7=7 "nct of delhi") (8=8 "rajasthan") (9=9 "uttar pradesh") (10=10 "bihar") (11=11 "sikkim") (12=12 "arunachal pradesh") (13=13 "nagaland") (14=14 "manipur") (15=15 "mizoram") (16=16 "tripura") (17=17 "meghalaya") (18=18 "assam") (19=19 "west bengal") (20=20 "jharkhand") (21=21 "odisha") (22=22 "chhattisgarh") (23=23 "madhya pradesh") (24=24 "gujarat") (27=27 "maharashtra") (28=28 "andhra pradesh") (29=29 "karnataka") (30=30 "goa") (32=32 "kerala") (33=33 "tamil nadu"), gen(State)  
**
tab State
** Sector : rural / urban **
clonevar sector = v025
tab sector
***
**FIRST BIRTH
recode v212 (0/22=1 "<23") (23/29=2 "23-29") (30/39=3 "30-39") (40/49=4 "40-49"), gen(age_at_first_birth)
**FIRST MARRIAGE
tab s310c
recode s310c (0/22=1 "<23") (23/29=2 "23-29") (30/39=3 "30-39") (40/49=4 "40-49"), gen(age_at_first_marriage)
*** Please Note : Due to coding, keep only ever-married sample.
keep if v502==1
*** Please Note : Due to coding, keep only ever-married sample.
keep if v502==1
/// Please keep ususal residents only
tab v135
tab v135, nolabel
keep if v135==1


******************************************************************************** 
** (2) NFHS-4 **
******************************************************************************** 
clear
// Survey Year 2015-16
set maxvar 32767 
use "$data_dir/Raw Data - Individual Recode Files/IAIR74FL_2015_16.DTA"
** Label Yes / No **
cap label define yesno 0"No" 1"Yes"
** Generate DHS Round **
gen DHSRound = "NFHS_4"
*** To generate weight ***
gen wt= v005/1000000
** Re-coding Birth Year **
gen Birth_Year = int((v011-1) / 12) + 1900
** Run all the codes as before till relationship to household head. The codes need to be changed for State variable.
*** Please Note : Due to coding, keep only ever-married sample.
keep if v502==1
/// Please keep ususal residents only
tab v135
tab v135, nolabel
keep if v135==1
///

//Employment in the last 12 months
recode v731 (0=0 "No") (1/3=1 "Yes") (8/9=.) if v502==1, gen(we_empl)
label var we_empl "Employment status in the last 12 months among those currently in a union"
tab we_empl


//Decides on household purchases
gen we_decide_hhpurch= v743b if v502==1
label values we_decide_hhpurch V743B
label var we_decide_hhpurch "Decides on large household purchases"
tab we_decide_hhpurch


** Highest Educational Level **
clonevar Education_respondent = v106
clonevar Education_partner = v701
recode Education_partner (8=.)

// Household Purchase
* (1) Only Women
tab we_decide_hhpurch
tab we_decide_hhpurch, nolabel
generate we_decide_hhpurch_a = .
replace we_decide_hhpurch_a = 1 if we_decide_hhpurch == 1 
replace we_decide_hhpurch_a = 0 if we_decide_hhpurch == 2 | we_decide_hhpurch == 4 | we_decide_hhpurch == 5 | we_decide_hhpurch == 6
label define yn50 0 "No" 1 "Yes"
label values we_decide_hhpurch_a yn50
tab we_decide_hhpurch_a

* (2) Women and Husband Jointly
tab we_decide_hhpurch
tab we_decide_hhpurch, nolabel
generate we_decide_hhpurch_b = .
replace we_decide_hhpurch_b = 1 if we_decide_hhpurch == 1 | we_decide_hhpurch == 2
replace we_decide_hhpurch_b = 0 if we_decide_hhpurch == 4 | we_decide_hhpurch == 5 | we_decide_hhpurch == 6
label define yn51 0 "No" 1 "Yes"
label values we_decide_hhpurch_b yn51
tab we_decide_hhpurch_b


** Recode Other Variables **
* Caste *
tab s116
recode s116 (1/3=1 "SC/ST/OBC") (4=2 "Non-SC/ST/0BC"),g(caste)
tab caste
recode caste (8=.)
tab caste
tab caste [iw=wt]
* Religion *
V130:
           1 hindu
           2 muslim
           3 christian
           4 sikh
           5 buddhist/neo-buddhist
           6 jain
           7 jewish
           8 parsi/zoroastrian
           9 no religion
          96 other
tab v130
recode v130 (1=1 "Hindu")(2=2 "Muslim")(3=3 "Christian") (4/8=4 "Others"),g(religion)
recode religion (9/96=.)
tab religion
tab religion [iw=wt]


*SON PREFERENCE
*ideal number of boys - ideal number of girls
gen son_difference=v627-v628
replace son_difference=. if v627==96 | v628==96
replace son_difference=. if v627==99 | v628==99

**** Year of survey ****
qui sum v007
scalar year_num = r(mean)
scalar year1=string(r(min))
scalar year2=string(r(max))

if (year1==year2) {
	scalar year3 = " "
	}
else if (year1!=year2) {
	scalar year3 = "-" + substr(year2,3,4)
	}
                                             
gen yr=year1 + year3
*****


** Household Size **
gen hh_size= v136

///

****** Occupation Category (Respondents')********
recode v716 (0=0 "No Occupation") (96=0 "No Occupation") (1/59=1 "Non-agriculture") (71/95=1 "Non-agriculture") (60=2 "farm plantation, dairy and other") (61=3 "cultivators") (62=4 "farmers, other than cultivators") (63=5 "agricultural labourer") (64=6 "plantation labourers & related workers") (65=7 "other farm workers") (66=8 "forestry workers") (67=9 "hunters and related workers ") (68=10 "fishermen and related workers"), gen(wm_occupation) 
recode wm_occupation (98 =.)
**
recode wm_occupation (0=0 "No Occupation") (1=1 "Non-agriculture") (3/5=2 "Cultivators and Agri-workers") (2=3 "Plantation and Farm Workers") (6/7=3 "Plantation and Farm Workers") (8/10=4 "Forestry, hunting and fishing"), gen(wm_occupation2)

///

****** Occupation Category (Husbands')********
recode v704 (96/97=0 "No Occupation") (1/59=1 "Non-agriculture") (71/95=1 "Non-agriculture") (60=2 "farm plantation, dairy and other") (61=3 "cultivators") (62=4 "farmers, other than cultivators") (63=5 "agricultural labourer") (64=6 "plantation labourers & related workers") (65=7 "other farm workers") (66=8 "forestry workers") (67=9 "hunters and related workers ") (68=10 "fishermen and related workers"), gen(hs_occupation) 
recode hs_occupation (98 =.)
**
recode hs_occupation (0=0 "No Occupation") (1=1 "Non-agriculture") (3/5=2 "Cultivators and Agri-workers") (2=3 "Plantation and Farm Workers") (6/7=3 "Plantation and Farm Workers") (8/10=4 "Forestry, hunting and fishing"), gen(hs_occupation2)

///
///

** Age Difference **
gen age_difference = (v730 - v012)
tab  age_difference

** Household Head **
gen sex_of_hhld_head = v151
label define hhld_head 1 "male" 2"female" 3 "transgender"
label values sex_of_hhld_head hhld_head


** State Variable **
clonevar State = v024
* Note the codes for each states *
label list  V024


* Recode the states
recode v024 (14=1 "jammu & kashmir") (13=2 "himachal pradesh") (28=3 "punjab") (6=4 "chandigarh") (34=5 "uttarakhand") (12=6 "haryana") (25=7 "nct of delhi") (29=8 "rajasthan") (33=9 "uttar pradesh") (5=10 "bihar") (30=11 "sikkim") (3=12 "arunachal pradesh") (24=13 "nagaland") (21=14 "manipur") (23=15 "mizoram") (32=16 "tripura") (22=17 "meghalaya") (4=18 "assam") (35=19 "west bengal") (15=20 "jharkhand") (26=21 "odisha") (7=22 "chhattisgarh") (19=23 "madhya pradesh") (11=24 "gujarat") (8=25 "dadra & nagar haveli and daman & diu") (20=27 "maharashtra") (2=28 "andhra pradesh") (16=29 "karnataka") (10=30 "goa") (18=31 "lakshadweep") (17=32 "kerala") (31=33 "tamil nadu") (27=34 "puducherry") (1=35 "andaman & nicobar islands") (36=36 "telangana"), gen(State)  
* Apply the labels
label values State V024
** Sector : rural / urban **
clonevar sector = v025
tab sector
***
** Sector : rural / urban **
clonevar sector = v025
tab sector
***
** Wealth Index Combined
clonevar wealth_index = v190

******************************************************************************** 
** (1) NFHS-5 **
clear
******************************************************************************** 
// Survey Year 2019-21
set maxvar 32767 
// Open the file.
use "$data_dir/Raw Data - Individual Recode Files/IAIR7EFL_2019_21.DTA"

** Label Yes / No **
cap label define yesno 0"No" 1"Yes"
** Generate DHS Round **
gen DHSRound = "NFHS_5"

*** To generate weight ***
gen wt= v005/1000000

** Re-coding Birth Year **
gen Birth_Year = int((v011-1) / 12) + 1900

//Employment in the last 12 months
recode v731 (0=0 "No") (1/3=1 "Yes") (8/9=.) if v502==1, gen(we_empl)
label var we_empl "Employment status in the last 12 months among those currently in a union"
tab we_empl


//Decides on household purchases
gen we_decide_hhpurch= v743b if v502==1
label values we_decide_hhpurch V743B
label var we_decide_hhpurch "Decides on large household purchases"
tab we_decide_hhpurch


** Highest Educational Level **
clonevar Education_respondent = v106
clonevar Education_partner = v701
recode Education_partner (8=.)

// Household Purchase
* (1) Only Women
tab we_decide_hhpurch
tab we_decide_hhpurch, nolabel
generate we_decide_hhpurch_a = .
replace we_decide_hhpurch_a = 1 if we_decide_hhpurch == 1 
replace we_decide_hhpurch_a = 0 if we_decide_hhpurch == 2 | we_decide_hhpurch == 4 | we_decide_hhpurch == 5 | we_decide_hhpurch == 6
label define yn50 0 "No" 1 "Yes"
label values we_decide_hhpurch_a yn50
tab we_decide_hhpurch_a

* (2) Women and Husband Jointly
tab we_decide_hhpurch
tab we_decide_hhpurch, nolabel
generate we_decide_hhpurch_b = .
replace we_decide_hhpurch_b = 1 if we_decide_hhpurch == 1 | we_decide_hhpurch == 2
replace we_decide_hhpurch_b = 0 if we_decide_hhpurch == 4 | we_decide_hhpurch == 5 | we_decide_hhpurch == 6
label define yn51 0 "No" 1 "Yes"
label values we_decide_hhpurch_b yn51
tab we_decide_hhpurch_b


** Recode Other Variables **
* Caste *
tab s116
recode s116 (1/3=1 "SC/ST/OBC") (4=2 "Non-SC/ST/0BC"),g(caste)
tab caste
recode caste (8=.)
tab caste
tab caste [iw=wt]
* Religion *
V130:
           1 hindu
           2 muslim
           3 christian
           4 sikh
           5 buddhist/neo-buddhist
           6 jain
           7 jewish
           8 parsi/zoroastrian
           9 no religion
          96 other
tab v130
recode v130 (1=1 "Hindu")(2=2 "Muslim")(3=3 "Christian") (4/8=4 "Others"),g(religion)
recode religion (9/96=.)
tab religion
tab religion [iw=wt]


*SON PREFERENCE
*ideal number of boys - ideal number of girls
gen son_difference=v627-v628
replace son_difference=. if v627==96 | v628==96
replace son_difference=. if v627==99 | v628==99

**** Year of survey ****
qui sum v007
scalar year_num = r(mean)
scalar year1=string(r(min))
scalar year2=string(r(max))

if (year1==year2) {
	scalar year3 = " "
	}
else if (year1!=year2) {
	scalar year3 = "-" + substr(year2,3,4)
	}
                                             
gen yr=year1 + year3
*****


** Household Size **
gen hh_size= v136

///

****** Recode Occupation Category (Respondents')********
recode v716 (0=0 "No Occupation")(1/59=1 "Non-agriculture") (71/95=1 "Non-agriculture") (60=2 "farm plantation, dairy and other") (61=3 "cultivators") (62=4 "farmers, other than cultivators") (63=5 "agricultural labourer") (64=6 "plantation labourers & related workers") (65=7 "other farm workers") (66=8 "forestry workers") (67=9 "hunters and related workers ") (68=10 "fishermen and related workers"), gen(wm_occupation) 
recode wm_occupation (96/ 99998 =.)
**
recode wm_occupation (0=0 "No Occupation") (1=1 "Non-agriculture") (3/5=2 "Cultivators and Agri-workers") (2=3 "Plantation and Farm Workers") (6/7=3 "Plantation and Farm Workers") (8/10=4 "Forestry, hunting and fishing"), gen(wm_occupation2)

///

****** Recode Occupation Category (Husbands')********
recode v704 (96/97=0 "No Occupation") (1/59=1 "Non-agriculture") (71/95=1 "Non-agriculture") (60=2 "farm plantation, dairy and other") (61=3 "cultivators") (62=4 "farmers, other than cultivators") (63=5 "agricultural labourer") (64=6 "plantation labourers & related workers") (65=7 "other farm workers") (66=8 "forestry workers") (67=9 "hunters and related workers ") (68=10 "fishermen and related workers"), gen(hs_occupation) 
recode hs_occupation (98 =.)
**
recode hs_occupation (0=0 "No Occupation") (1=1 "Non-agriculture") (3/5=2 "Cultivators and Agri-workers") (2=3 "Plantation and Farm Workers") (6/7=3 "Plantation and Farm Workers") (8/10=4 "Forestry, hunting and fishing"), gen(hs_occupation2)

///

** Age Difference **
gen age_difference = (v730 - v012)
tab  age_difference

** Household Head **
gen sex_of_hhld_head = v151
label define hhld_head 1 "male" 2"female" 3 "transgender"
label values sex_of_hhld_head hhld_head


** State Variable **
clonevar State = v024
* Note the codes for each states *
label list  V024
**
V024:
           1 jammu & kashmir
           2 himachal pradesh
           3 punjab
           4 chandigarh
           5 uttarakhand
           6 haryana
           7 nct of delhi
           8 rajasthan
           9 uttar pradesh
          10 bihar
          11 sikkim
          12 arunachal pradesh
          13 nagaland
          14 manipur
          15 mizoram
          16 tripura
          17 meghalaya
          18 assam
          19 west bengal
          20 jharkhand
          21 odisha
          22 chhattisgarh
          23 madhya pradesh
          24 gujarat
          25 dadra & nagar haveli and daman & diu
          27 maharashtra
          28 andhra pradesh
          29 karnataka
          30 goa
          31 lakshadweep
          32 kerala
          33 tamil nadu
          34 puducherry
          35 andaman & nicobar islands
          36 telangana
          37 ladakh
** Sector : rural / urban **
clonevar sector = v025
tab sector
***
** Wealth Index Combined
clonevar wealth_index = v190

*******************************************************************************
*******************************************************************************
/// Next Step is to append all the three rounds.

use "$data_dir/Raw Data - Individual Recode Files/IAIR7EFL_2019_21.DTA"
append using "$data_dir/Raw Data - Individual Recode Files/IAIR74FL_2015_16.DTA"
append using "$data_dir/Raw Data - Individual Recode Files/IAIR52FL_2005_06.dta"

save "$data_dir/Appended Data/Main_Data.dta"


*******************************************************************************
*******************************************************************************
gen Birth_Cohort = .
foreach year of numlist 1956(10)1985 {
	quietly replace Birth_Cohort = `year' if Birth_Year >= `year' & Birth_Year < `year' + 10
}

foreach year of numlist 1986(20)2005 {
	quietly replace Birth_Cohort = `year' if Birth_Year >= `year' & Birth_Year < `year' + 20
}

* Label the birth cohorts for better readability
label define Cohort_Labels 1956 "1956-1965" 1966 "1966-1975" 1976 "1976-1985" 1986 "1986-2005" 
label values Birth_Cohort Cohort_Labels


*******************************************************************************
*** Keep only the variables needed **
*******************************************************************************
keep caseid v000 v001 v002 v003 v004 v005 v007 v012 v013 v015 v020 v026 v027 v028 v029 v030 v031 v032 v034 v040 v102 v103 v104 v105 v106 v107 v119 v120 v121 v122 v123 v124 v125 v127 v128 v129 v130 v131 v133 v134 v135 v136 v137 v138 v139 v140 v141 v149 v150 v151 v152 v153 awfactt awfactu awfactr awfacte awfactw v155 v156 v157 v158 v159 v160 v161 v190 v191 v501 v502 v503 v504 v505 v627 v628 v715 v716 v717 v719 v721 v729 v730 v731 v732 v739 v740 v741 v743a v743b v743c v743d v743e v743f v744a v744b v744c v744d v744e v746 DHSRound wt Birth_Year we_empl we_empl_earn we_earn_wm_decide we_earn_wm_compare we_earn_hs_decide we_decide_health we_decide_hhpurch we_decide_visits rc_edu education_category we_earn_wm_decision_a we_earn_wm_decision_b we_earn_hs_decide_a we_earn_hs_decide_b we_decide_visits_a we_decide_visits_b we_decide_health_a we_decide_health_b we_decide_hhpurch_a we_decide_hhpurch_b caste religion massmedia empower empower_joint combined_ipv son_difference yr rc_hins education_category_husband numchild total_sons prop_sons total_girls prop_girls sex_of_first_child hh_size wm_occupation wm_occupation2 hs_occupation hs_occupation2 age_difference sex_of_hhld_head relationship State sector age_at_first_marriage age_at_first_birth Birth_Cohort v135


***
tab State 
rename State State_Old
tab State_Old
* Recode the states
recode State_Old (1=1 "jammu & kashmir") (2=2 "himachal pradesh") (2=3 "punjab") (4=4 "chandigarh") (5=5 "uttarakhand") (6=6 "haryana") (7=7 "nct of delhi") (8=8 "rajasthan") (9=9 "uttar pradesh") (10=10 "bihar") (11=11 "sikkim") (12=12 "arunachal pradesh") (13=13 "nagaland") (14=14 "manipur") (15=15 "mizoram") (16=16 "tripura") (17=17 "meghalaya") (18=18 "assam") (19=19 "west bengal") (20=20 "jharkhand") (21=21 "odisha") (22=22 "chhattisgarh") (23=23 "madhya pradesh") (24=24 "gujarat") (25=25 "dadra & nagar haveli and daman & diu") (27=27 "maharashtra") (28=28 "andhra pradesh") (29=29 "karnataka") (30=30 "goa") (31=31 "lakshadweep") (32=32 "kerala") (33=33 "tamil nadu") (34=34 "puducherry") (35=35 "andaman & nicobar islands") (36=36 "telangana") (37=37 "ladakh"), gen(State)  

// Codes applicable only for specific Rounds //

**** Region for NFHS5  ****
tab v024
rename v024 State

generate region=.
replace region=0 if State==1 & DHSRound=="NFHS_5"
replace region=0 if State==2 & DHSRound=="NFHS_5"
replace region=0 if State==3 & DHSRound=="NFHS_5"
replace region=0 if State==4 & DHSRound=="NFHS_5"
replace region=0 if State==5 & DHSRound=="NFHS_5"
replace region=0 if State==6 & DHSRound=="NFHS_5"
replace region=0 if State==7 & DHSRound=="NFHS_5"
replace region=0 if State==8 & DHSRound=="NFHS_5"
replace region=0 if State==37 & DHSRound=="NFHS_5"

replace region=1 if State==22 & DHSRound=="NFHS_5"
replace region=1 if State==23 & DHSRound=="NFHS_5"
replace region=1 if State==9 & DHSRound=="NFHS_5"


replace region=2 if State==10 & DHSRound=="NFHS_5"
replace region=2 if State==20 & DHSRound=="NFHS_5"
replace region=2 if State==21 & DHSRound=="NFHS_5"
replace region=2 if State==19 & DHSRound=="NFHS_5"


replace region=3 if State==12 & DHSRound=="NFHS_5"
replace region=3 if State==18 & DHSRound=="NFHS_5"
replace region=3 if State==14 & DHSRound=="NFHS_5"
replace region=3 if State==17 & DHSRound=="NFHS_5" 
replace region=3 if State==15 & DHSRound=="NFHS_5"
replace region=3 if State==13 & DHSRound=="NFHS_5"
replace region=3 if State==11 & DHSRound=="NFHS_5"
replace region=3 if State==16 & DHSRound=="NFHS_5"


replace region=4 if State==25 & DHSRound=="NFHS_5"
replace region=4 if State==30 & DHSRound=="NFHS_5"
replace region=4 if State==24 & DHSRound=="NFHS_5"
replace region=4 if State==27 & DHSRound=="NFHS_5"

replace region=5 if State==35 & DHSRound=="NFHS_5"
replace region=5 if State==28 & DHSRound=="NFHS_5"
replace region=5 if State==29 & DHSRound=="NFHS_5"
replace region=5 if State==32 & DHSRound=="NFHS_5"
replace region=5 if State==31 & DHSRound=="NFHS_5" 
replace region=5 if State==34 & DHSRound=="NFHS_5"
replace region=5 if State==33 & DHSRound=="NFHS_5"
replace region=5 if State==36 & DHSRound=="NFHS_5"


label define region 0 "North" 1 "Central" 2 "East" 3 "Northeast" 4 "West" 5 "South",replace
label values region region
tab region



// Codes applicable only for specific Rounds (ALL Rounds)//

**** Region for NFHS5  ****
tab v024
rename v024 State

generate region=.
replace region=0 if State==1 
replace region=0 if State==2 
replace region=0 if State==3 
replace region=0 if State==4 
replace region=0 if State==5 
replace region=0 if State==6 
replace region=0 if State==7 
replace region=0 if State==8 
replace region=0 if State==37 

replace region=1 if State==22 
replace region=1 if State==23 
replace region=1 if State==9 


replace region=2 if State==10 
replace region=2 if State==20 
replace region=2 if State==21 
replace region=2 if State==19 


replace region=3 if State==12 
replace region=3 if State==18 
replace region=3 if State==14 
replace region=3 if State==17  
replace region=3 if State==15 
replace region=3 if State==13 
replace region=3 if State==11 
replace region=3 if State==16 


replace region=4 if State==25 
replace region=4 if State==30 
replace region=4 if State==24 
replace region=4 if State==27 

replace region=5 if State==35 
replace region=5 if State==28 
replace region=5 if State==29 
replace region=5 if State==32 
replace region=5 if State==31  
replace region=5 if State==34 
replace region=5 if State==33 
replace region=5 if State==36 


label define region 0 "North" 1 "Central" 2 "East" 3 "Northeast" 4 "West" 5 "South",replace
label values region region
tab region

** Husband Away Variable
recode s907 (8/9=.)
recode s909 (8/9=.)

**
gen husband_away = .
replace husband_away = 1 if s907 == 1 | s908 == 1 | s909 == 1
replace husband_away = 0 if s907 == 0 | s908 == 0 | s909 == 0

* Handling missing values
replace husband_away = . if missing(s907) & missing(s908) & missing(s909)

* Check distribution
tab husband_away

*
* Define value labels
label define husband_away_lbl 0 "No" 1 "Yes"

* Assign labels to the variable
label values husband_away husband_away_lbl


