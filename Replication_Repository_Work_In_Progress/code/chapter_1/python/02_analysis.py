"""NFHS analysis stage; reads only the cleaned file."""
from pathlib import Path
import pandas as pd
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt

f=Path("data/processed/chapter_1_nfhs/nfhs_analysis_ready.csv")
if not f.exists(): raise FileNotFoundError("Run 01_cleaning.py first.")
d=pd.read_csv(f)
out=Path("output/tables/chapter_1"); fig=Path("output/figures/chapter_1")
out.mkdir(parents=True,exist_ok=True);fig.mkdir(parents=True,exist_ok=True)
outcomes_primary=["we_decide_hhpurch_b","we_decide_health_b","we_decide_visits_b",
                  "we_decide_hhpurch_a","we_decide_health_a","we_decide_visits_a"]
outcomes_legacy=[x+"_legacy" for x in outcomes_primary]
outcomes=outcomes_primary+outcomes_legacy
categorical=["Education_respondent","we_empl","religion","Education_partner","hs_empl",
             "wealth_index","massmedia","sector","State2","DHSRound_num"]
rhs_full=" + ".join(f"C({v})" for v in categorical)
rhs_sub=" + ".join(f"C({v})" for v in categorical if v!="religion")
records=[];ames=[];failures=[]
def estimate(y,rhs,dd,spec,sample):
    try:
        fit=smf.probit(f"{y} ~ {rhs}",data=dd).fit(disp=False,maxiter=200)
    except Exception as exc:
        failures.append({"outcome":y,"specification":spec,"sample":sample,"stage":"probit",
                         "N_available":len(dd),"error":str(exc)})
        return
    for term,val in fit.params.items():
        records.append({"outcome":y,"specification":spec,"sample":sample,"term":term,
                        "coefficient":val,"se":fit.bse[term],"p_value":fit.pvalues[term],"N":int(fit.nobs)})
    try:
        me=fit.get_margeff(at="overall",dummy=True).summary_frame()
        for term,row in me.iterrows():
            ames.append({"outcome":y,"specification":spec,"sample":sample,"term":term,
                         "AME":row["dy/dx"],"se":row["Std. Err."],"p_value":row["Pr(>|z|)"],"N":int(fit.nobs)})
    except Exception as exc:
        failures.append({"outcome":y,"specification":spec,"sample":sample,"stage":"marginal_effects",
                         "N_available":len(dd),"error":str(exc)})
for y in outcomes:
    for spec,rhs in [("religion_only","C(religion)"),("full_controls",rhs_full)]:
        estimate(y,rhs,d,spec,"All")
        for cohort in [1956,1966,1976,1986]:
            estimate(y,rhs,d.loc[d.Birth_Cohort==cohort],spec,str(cohort))
    if y in outcomes_primary:
        for rel,label in [(1,"Hindu"),(2,"Muslim"),(3,"Christian_Others")]:
            sub=d.loc[d.Religion_New==rel]
            estimate(y,rhs_sub,sub,"full_controls",label)
            for cohort in [1956,1966,1976,1986]:
                estimate(y,rhs_sub,sub.loc[sub.Birth_Cohort==cohort],"full_controls",f"{label}_{cohort}")
pd.DataFrame(records).to_csv(out/"probit_coefficients_Python.csv",index=False)
pd.DataFrame(ames).to_csv(out/"probit_ame_Python.csv",index=False)
pd.DataFrame(failures).to_csv("output/diagnostics/chapter_1_model_failures_Python.csv",index=False)
for domain in ["hhpurch","health","visits"]:
    raw=f"we_decide_{domain}"
    for group in ["DHSRound","Birth_Cohort"]:
        tab=d.dropna(subset=[raw,group]).groupby([group,raw]).size().rename("n").reset_index()
        tab["share"]=tab["n"]/tab.groupby(group)["n"].transform("sum")
        tab.to_csv(out/f"{domain}_raw_categories_by_{group}_Python.csv",index=False)
    xvars=["Education_respondent","we_empl","religion","Education_partner","hs_empl",
           "wealth_index","massmedia","sector","State2"]
    for xv in [v for v in xvars if v in d]:
        for group in ["DHSRound_num","Birth_Cohort"]:
            tab=d.dropna(subset=[group,xv,raw]).groupby([group,xv,raw]).size().rename("n").reset_index()
            tab["row_share"]=tab["n"]/tab.groupby([group,xv])["n"].transform("sum")
            tab.to_csv(out/f"{domain}_by_{xv}_and_{group}_Python.csv",index=False)
    for group in ["DHSRound_num","Birth_Cohort"]:
        means=d.groupby(group)[[f"{raw}_b",f"{raw}_a"]].mean()
        ax=means.plot(kind="bar",figsize=(8,5))
        ax.set_ylabel("Share");ax.set_title(f"Decision-making: {domain}")
        plt.tight_layout();plt.savefig(fig/f"{domain}_by_{group}_Python.png",dpi=300);plt.close()
print("Python NFHS analysis complete.")
