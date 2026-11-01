"""NSSO cleaning stage from the pre-aggregated analysis datasets."""
from pathlib import Path
import pandas as pd
import numpy as np

IDIR=Path("data/interim/chapter_2_nsso")
ODIR=Path("data/processed/chapter_2_nsso")
ODIR.mkdir(parents=True,exist_ok=True)
FILES={"SR":"AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta",
       "LR":"AP_Aggregates_Merged_All_SubRound_Consistent_Sample.dta"}
PERSON=IDIR/"person_record.dta"
if not PERSON.exists(): raise FileNotFoundError(f"Missing {PERSON}; see docs/data_access.md.")
p=pd.read_stata(PERSON,convert_categoricals=False)
p["HHID"]=p["HHID"].astype(str)
if p.HHID.duplicated().any(): raise ValueError("person_record HHID is not unique.")
base=["Food","Food_PC","Fuel","Fuel_PC","Clothing","Clothing_PC","Footwear","Footwear_PC",
      "Durable","Durable_PC","Misc","Misc_PC","MPCE_Own"]
for horizon,name in FILES.items():
    f=IDIR/name
    if not f.exists(): raise FileNotFoundError(f"Missing {f}; see docs/data_access.md.")
    a=pd.read_stata(f,convert_categoricals=False)
    a["HHID"]=a["HHID"].astype(str)
    if a.HHID.duplicated().any(): raise ValueError("Aggregate HHID is not unique.")
    n_master=len(a);n_person=len(p)
    d=a.merge(p,on="HHID",how="left",indicator=True,validate="one_to_one")
    matched=int((d._merge=="both").sum())
    left=int((d._merge=="left_only").sum())
    right=n_person-matched
    print(f"{horizon} merge counts: aggregate={n_master}; person={n_person}; matched={matched}; aggregate-only={left}; person-only={right}")
    d=d.loc[d._merge=="both"].drop(columns="_merge").copy() # preserve source keep if _merge==3
    d=d.loc[d.robust_treat1.notna()].copy()
    required=["District","SubRound","robust_treat1","did_robust1","after_tsunami","HHSize",
              "HH_Type","Social_Group","Ration_Type","Religion","Dwelling_Unit","Sector",
              "HH_AdultFemaleProp","HH_Head_Age","HH_Head_Education"]
    missing=[v for v in required if v not in d]
    if missing: raise KeyError(f"{horizon} missing variables: {missing}")
    for v in ["HH_Head_Education","HH_Head_Age","HH_AdultFemaleProp"]:
        if v in d: d[v]=pd.to_numeric(d[v],errors="coerce")
    d["HH_Type_Agri"]=d.HH_Type.isin([12,14]).astype(int)
    d["Social_Group_new"]=d.Social_Group.isin([1,2,3]).astype(int)
    d["Ration_Type_new"]=d.Ration_Type.isin([1,2]).astype(int)
    d["Religion_new"]=d.Religion.map({1:1,2:2,3:3,9:3})
    d["Dwelling_Unit_new"]=d.Dwelling_Unit.map({1:1,2:2,9:2})
    diagnostics=[]
    for v in base:
        if v not in d: raise KeyError(f"Missing outcome {v}")
        raw_missing=int(d[v].isna().sum())
        invalid=int((d[v].notna()&(d[v]<=-1)).sum())
        d["ln_"+v]=np.log(d[v]+1)
        diagnostics.append({"horizon":horizon,"variable":v,"missing_raw":raw_missing,
                            "values_le_minus1":invalid,"missing_log":int(d["ln_"+v].isna().sum())})
    pd.DataFrame(diagnostics).to_csv(f"output/diagnostics/chapter_2_{horizon.lower()}_log_diagnostics_Python.csv",index=False)
    mismatch_after=int(((d.after_tsunami!=(d.SubRound>=3))&d.after_tsunami.notna()&d.SubRound.notna()).sum())
    mismatch_did=int(((d.did_robust1!=d.robust_treat1*d.after_tsunami)&d.did_robust1.notna()&d.robust_treat1.notna()&d.after_tsunami.notna()).sum())
    print(f"{horizon}: after_tsunami/SubRound mismatches={mismatch_after}; did interaction mismatches={mismatch_did}")
    d["horizon"]=horizon
    d.to_stata(ODIR/f"chapter_2_{horizon.lower()}_analysis_ready.dta",write_index=False,version=118)
    d.to_csv(ODIR/f"chapter_2_{horizon.lower()}_analysis_ready.csv",index=False)
    print(f"{horizon} cleaned N={len(d)}")
# Optional Block 4 demographic aggregation, matching the supplied household-
# head/dependency-ratio do-file. It does not create person_record.dta.
block4=Path("data/raw/chapter_2_nsso/Block 4_Person records.dta")
if block4.exists():
    b=pd.read_stata(block4,convert_categoricals=False)
    req=["State","Gender","Household_Head","Age","HHID","SubRound"]
    miss=[v for v in req if v not in b]
    if miss: raise KeyError(f"Block 4 file missing: {miss}")
    for v in ["State","Gender","Household_Head","Age"]:
        b[v]=pd.to_numeric(b[v],errors="coerce")
    b=b.loc[b.State==28].copy()
    b["is_head"]=(b.Household_Head==1)
    b["head_gender_temp"]=b.Gender.where(b.is_head)
    b["head_age_temp"]=b.Age.where(b.is_head)
    b["child"]=b.Age.between(0,14)
    b["working_age"]=b.Age.between(15,64)
    b["elderly"]=b.Age.between(65,101)
    agg=b.groupby("HHID").agg(
        SubRound=("SubRound","first"),hh_head_gender=("head_gender_temp","max"),
        hh_head_age=("head_age_temp","max"),num_children=("child","sum"),
        num_working_age=("working_age","sum"),num_elderly=("elderly","sum"),
        hh_size_block4=("HHID","size")).reset_index()
    agg["female_headed"]=(agg.hh_head_gender==2).astype(int)
    agg["dependency_ratio"]=(agg.num_children+agg.num_elderly)/agg.num_working_age
    agg.loc[agg.num_working_age==0,"dependency_ratio"]=np.nan
    agg.to_stata(ODIR/"HH_level_AP_demographics.dta",write_index=False,version=118)
print("Thesis reference Ns before merge attrition: SR=1,658; LR=2,180.")
