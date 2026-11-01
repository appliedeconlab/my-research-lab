"""NSSO DiD analysis stage; reads only the cleaned SR/LR datasets."""
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
import statsmodels.formula.api as smf
from scipy.stats import ttest_ind

OUT=Path("output/tables/chapter_2");OUT.mkdir(parents=True,exist_ok=True)
OUTCOMES=["Food","Food_PC","Fuel","Fuel_PC","Clothing","Clothing_PC","Footwear","Footwear_PC",
          "Durable","Durable_PC","Misc","Misc_PC","MPCE_Own"] 
OUTCOMES += ["ln_"+x for x in OUTCOMES]
CONTROLS=["HH_Type_Agri","Social_Group_new","Ration_Type_new","HHSize","HH_AdultFemaleProp",
          "HH_Head_Age","HH_Head_Education"]
def formula(y,with_controls):
    rhs=["did_robust1"]
    if with_controls:
        rhs += [x for x in CONTROLS if x in d.columns]
        rhs += ["C(Dwelling_Unit_new)","C(Religion_new)","C(Sector)"]
    rhs += ["C(District)","C(SubRound)"]
    return f"{y} ~ "+" + ".join(rhs)
all_results=[];robust=[];heterogeneity=[]
for horizon in ["sr","lr"]:
    f=Path("data/processed/chapter_2_nsso")/f"chapter_2_{horizon}_analysis_ready.dta"
    if not f.exists(): raise FileNotFoundError(f"Run 01_cleaning.py first: {f}")
    d=pd.read_stata(f,convert_categoricals=False)
    for y in [x for x in OUTCOMES if x in d]:
        for c in [False,True]:
            fit=smf.ols(formula(y,c),data=d,missing="drop").fit(
                cov_type="cluster",cov_kwds={"groups":d.loc[smf.ols(formula(y,c),data=d,missing="drop").fit().model.data.row_labels,"District"]})
            all_results.append({"horizon":horizon.upper(),"outcome":y,"controls":c,
                "coefficient":fit.params.get("did_robust1"),"se":fit.bse.get("did_robust1"),
                "p_value":fit.pvalues.get("did_robust1"),"N":int(fit.nobs)})
    desc=d.groupby(["after_tsunami","robust_treat1"])[[x for x in ["Food_PC","Fuel_PC","Clothing_PC","MPCE_Own","HHSize"] if x in d]].agg(["mean","count"])
    desc.to_csv(OUT/f"{horizon}_descriptives_Python.csv")
    figdat=d.groupby(["SubRound","robust_treat1"])["Clothing_PC"].mean().unstack()
    ax=figdat.plot(marker="o",figsize=(8,5))
    ax.set_title("Clothing per capita by survey sub-round")
    ax.set_xlabel("Survey sub-round");ax.set_ylabel("Rupees per capita")
    ax.legend(["Control","Treatment"])
    plt.tight_layout()
    plt.savefig(Path("output/figures/chapter_2")/f"{horizon}_clothing_pc_by_subround_Python.png",dpi=300)
    plt.close()
    # Harmonised Appendix B descriptives by dwelling, sector and religion.
    for sub in ["Dwelling_Unit_new","Sector","Religion_new"]:
        if sub in d:
            appx=d.groupby([sub,"after_tsunami"])[["Food_PC","Fuel_PC","Clothing_PC","MPCE_Own"]].agg(["mean","count"])
            appx.to_csv(OUT/f"{horizon}_{sub}_appendix_descriptives_Python.csv")
    # Household-size balance tests among control districts/households.
    balance=[]
    for cap in [None,8,9,10,11,12,13]:
        dd=d if cap is None else d.loc[d.HHSize<=cap]
        def ptest(a,b):
            a=a.dropna();b=b.dropna()
            if len(a)<2 or len(b)<2: return float("nan")
            return float(ttest_ind(a,b,equal_var=False).pvalue)
        p1=ptest(dd.loc[(dd.robust_treat1==0)&(dd.after_tsunami==0),"HHSize"],
                 dd.loc[(dd.robust_treat1==0)&(dd.after_tsunami==1),"HHSize"])
        p2=ptest(dd.loc[(dd.robust_treat1==0)&(dd.SubRound==1),"HHSize"],
                 dd.loc[(dd.robust_treat1==0)&(dd.SubRound==3),"HHSize"])
        p3=ptest(dd.loc[(dd.robust_treat1==0)&(dd.SubRound==1),"HHSize"],
                 dd.loc[(dd.robust_treat1==0)&(dd.SubRound==2),"HHSize"])
        balance.append({"horizon":horizon.upper(),"cap":"Original" if cap is None else cap,
                        "N":len(dd),"before_after_p":p1,"subround1_3_p":p2,"subround1_2_p":p3})
    pd.DataFrame(balance).to_csv(OUT/f"{horizon}_hhsize_balance_Python.csv",index=False)
    # Cross-sectional determinants regressions using heteroskedasticity-robust HC1 SEs.
    det_out=[]
    det_y=[x for x in ["ln_Food_PC","ln_Fuel_PC","ln_Clothing_PC","ln_Footwear_PC",
                       "ln_Durable_PC","ln_Misc_PC","ln_MPCE_Own"] if x in d]
    det_rhs=("HH_Type_Agri + Social_Group_new + Ration_Type_new + C(Dwelling_Unit_new) + "
             "HHSize + HH_AdultFemaleProp + HH_Head_Age + HH_Head_Education + "
             "C(Religion_new) + C(Sector)")
    for y in det_y:
        for period in [0,1]:
            for sample in ["control","treatment","pooled"]:
                dd=d.loc[d.after_tsunami==period]
                rhs=det_rhs
                if sample=="control": dd=dd.loc[dd.robust_treat1==0]
                elif sample=="treatment": dd=dd.loc[dd.robust_treat1==1]
                else: rhs="robust_treat1 + "+rhs
                fit=smf.ols(f"{y} ~ {rhs}",data=dd,missing="drop").fit(cov_type="HC1")
                for term in fit.params.index:
                    det_out.append({"horizon":horizon.upper(),"outcome":y,"period":period,
                        "sample":sample,"term":term,"estimate":fit.params[term],"se":fit.bse[term],
                        "p_value":fit.pvalues[term],"N":int(fit.nobs)})
    pd.DataFrame(det_out).to_csv(OUT/f"{horizon}_determinants_Python.csv",index=False)
    for cap in [None,8,9,10,11,12,13]:
        dd=d if cap is None else d.loc[d.HHSize<=cap]
        y="Clothing_PC"
        for c in [False,True]:
            fit=smf.ols(formula(y,c),data=dd,missing="drop").fit(
                cov_type="cluster",cov_kwds={"groups":dd.loc[smf.ols(formula(y,c),data=dd,missing="drop").fit().model.data.row_labels,"District"]})
            robust.append({"horizon":horizon.upper(),"cap":"Original" if cap is None else cap,
                "controls":c,"coefficient":fit.params.get("did_robust1"),"se":fit.bse.get("did_robust1"),
                "p_value":fit.pvalues.get("did_robust1"),"N":int(fit.nobs)})
    hetvars=["female_headed","Religion_new","Social_Group_new","Dwelling_Unit_new","Sector","Ration_Type_new","HH_Type_Agri"]
    for v in [x for x in hetvars if x in d]:
        for g in sorted(d[v].dropna().unique()):
            dd=d.loc[d[v]==g]
            for y in ["Food_PC","Fuel_PC","Clothing_PC","MPCE_Own"]:
                for c in [False,True]:
                    # Omit the subgroup variable from its own control set.
                    rhs=["did_robust1"]
                    if c:
                        rhs += [x for x in CONTROLS if x in dd and x!=v]
                        if v!="Dwelling_Unit_new": rhs += ["C(Dwelling_Unit_new)"]
                        if v!="Religion_new": rhs += ["C(Religion_new)"]
                        if v!="Sector": rhs += ["C(Sector)"]
                    rhs += ["C(District)","C(SubRound)"]
                    fit=smf.ols(f"{y} ~ "+" + ".join(rhs),data=dd,missing="drop").fit(
                        cov_type="cluster",cov_kwds={"groups":dd.loc[smf.ols(f"{y} ~ "+" + ".join(rhs),data=dd,missing="drop").fit().model.data.row_labels,"District"]})
                    heterogeneity.append({"horizon":horizon.upper(),"subgroup":v,"group_value":g,
                        "outcome":y,"controls":c,"coefficient":fit.params.get("did_robust1"),
                        "se":fit.bse.get("did_robust1"),"p_value":fit.pvalues.get("did_robust1"),"N":int(fit.nobs)})
pd.DataFrame(all_results).to_csv(OUT/"did_Python.csv",index=False)
pd.DataFrame(robust).to_csv(OUT/"hhsize_robustness_Python.csv",index=False)
pd.DataFrame(heterogeneity).to_csv(OUT/"heterogeneity_Python.csv",index=False)
print("Python DiD analysis complete. No exact equivalent of Stata estat ptrends is claimed.")
