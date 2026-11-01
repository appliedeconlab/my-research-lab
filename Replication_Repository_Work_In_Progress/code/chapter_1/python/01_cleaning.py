"""NFHS cleaning stage. Run from repository root:
python code/chapter_1/python/01_cleaning.py"""
from pathlib import Path
import pandas as pd
import numpy as np

RAW=Path("data/raw/chapter_1_nfhs")
OUT=Path("data/processed/chapter_1_nfhs")
OUT.mkdir(parents=True,exist_ok=True)
FILES=["IAIR52FL_2005_06.dta","IAIR74FL_2015_16.DTA","IAIR7EFL_2019_21.DTA"]
for name in FILES:
    if not (RAW/name).exists():
        raise FileNotFoundError(f"Missing authorised NFHS input: {RAW/name}")

STATE4={14:1,13:2,28:3,6:4,34:5,12:6,25:7,29:8,33:9,5:10,30:11,3:12,24:13,
        21:14,23:15,32:16,22:17,4:18,35:19,15:20,26:21,7:22,19:23,11:24,8:25,
        20:27,2:28,16:29,10:30,18:31,17:32,31:33,27:34,1:35,36:36}
def make_round(path,round_no):
    x=pd.read_stata(path,convert_categoricals=False)
    required=["caseid","v005","v007","v011","v012","v024","v025","v130","v135","v136",
              "v151","v157","v158","v159","v190","v502","v704","v730","v731","v743a","v743b","v743d"]
    missing=[v for v in required if v not in x.columns]
    if missing: raise KeyError(f"Round {round_no} missing source variables: {missing}")
    # Harmonised sample repair: apply v502==1 and v135==1 to all rounds.
    # Supplied source filters NFHS-3/4 but omits these restrictions in NFHS-5.
    # Thesis says ever-married; confirm v502 against the round codebooks.
    x=x.loc[(x.v502==1)&(x.v135==1)].copy()
    x["DHSRound_num"]=round_no
    x["DHSRound"]=f"NFHS_{round_no+2}"
    x["wt"]=x.v005/1_000_000
    x["we_empl"]=np.select([x.v731.eq(0),x.v731.between(1,3),x.v731.isin([8,9])],
                           [0,1,np.nan],default=np.nan)
    x["Birth_Year"]=np.floor((x.v011-1)/12)+1900
    x["Birth_Cohort"]=np.select([
        x.Birth_Year.between(1956,1965),x.Birth_Year.between(1966,1975),
        x.Birth_Year.between(1976,1985),x.Birth_Year.between(1986,2005)],
        [1956,1966,1976,1986],default=np.nan)
    x["current_age"]=x.v012
    x["age_difference"]=x.v730-x.v012
    x.loc[x.v730.isna()|(x.v730>=98),"age_difference"]=np.nan
    x["hh_size"]=x.v136
    x["wealth_index"]=x.v190
    x["sector"]=x.v025
    x["Religion_New"]=x.v130.where(x.v130.between(1,3),np.nan)
    x.loc[x.v130.between(4,8),"Religion_New"]=4
    x["religion"]=x.Religion_New
    x["massmedia"]=((x.v157==2)|(x.v158==2)|(x.v159==2)).astype(int)
    if round_no==1:
        for v in ["v149","v715"]:
            if v not in x: raise KeyError(f"NFHS-3 requires {v}")
        x["Education_respondent"]=x.v149
        x["Education_partner"]=np.select([
            x.v715.eq(0),x.v715.between(1,5),x.v715.between(6,10),x.v715.between(11,97)],
            [0,1,2,3],default=np.nan)
    else:
        for v in ["v106","v701"]:
            if v not in x: raise KeyError(f"NFHS-{round_no+2} requires {v}")
        x["Education_respondent"]=x.v106
        x["Education_partner"]=x.v701.where(x.v701.isin([0,1,2,3]),np.nan)
    x["hs_empl"]=np.select([x.v704.isin([0,96,97]),x.v704.between(1,95)],[0,1],default=np.nan)
    x["State2"]=x.v024.map(STATE4) if round_no==2 else x.v024
    for domain,rawvar in [("health","v743a"),("hhpurch","v743b"),("visits","v743d")]:
        z=x[rawvar].where(x[rawvar]!=9,np.nan)
        x[f"we_decide_{domain}"]=z
        # Thesis prose definitions: 1/2 joint; 3-5 no; 1 independent; 2-5 no.
        x[f"we_decide_{domain}_a"]=np.select([z.eq(1),z.between(2,5)],[1,0],default=np.nan)
        x[f"we_decide_{domain}_b"]=np.select([z.between(1,2),z.between(3,5)],[1,0],default=np.nan)
        # Literal supplied do-file recodes for direct sensitivity comparison.
        x[f"we_decide_{domain}_a_legacy"]=np.select([z.eq(1),z.isin([2,4,5,6])],[1,0],default=np.nan)
        x[f"we_decide_{domain}_b_legacy"]=np.select([z.between(1,2),z.isin([4,5,6])],[1,0],default=np.nan)
    cols=["caseid","DHSRound","DHSRound_num","wt","Birth_Year","Birth_Cohort","current_age",
          "age_difference","hh_size","wealth_index","sector","State2","religion","Religion_New",
          "Education_respondent","Education_partner","we_empl","hs_empl","massmedia"]+[c for c in x if c.startswith("we_decide_")]
    return x[cols]
frames=[make_round(RAW/FILES[i],i+1) for i in range(3)]
d=pd.concat(frames,ignore_index=True)
if d.duplicated(["DHSRound_num","caseid"]).any(): raise ValueError("Duplicate caseid within round.")
d.to_csv(OUT/"nfhs_analysis_ready.csv",index=False)
d.to_stata(OUT/"nfhs_analysis_ready.dta",write_index=False,version=118)
counts=d.groupby(["DHSRound_num","DHSRound"]).size().reset_index(name="n")
counts.to_csv("output/diagnostics/chapter_1_round_counts_Python.csv",index=False)
print("Cleaned pooled rows:",len(d))
print("Check thesis purchase-response Ns: NFHS-3 81,365; NFHS-4 81,480; NFHS-5 72,450.")
print("See docs/variable_construction.md for provisional mappings and coding discrepancies.")
