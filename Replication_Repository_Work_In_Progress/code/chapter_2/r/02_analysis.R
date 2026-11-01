# DiD analysis stage; reads only cleaned SR/LR files.
suppressPackageStartupMessages({library(haven);library(dplyr);library(readr);library(fixest);library(ggplot2);library(tidyr)})
odir<-file.path("output","tables","chapter_2");fdir<-file.path("output","figures","chapter_2")
dir.create(odir,recursive=TRUE,showWarnings=FALSE);dir.create(fdir,recursive=TRUE,showWarnings=FALSE)
outcomes<-c("Food","Food_PC","Fuel","Fuel_PC","Clothing","Clothing_PC","Footwear","Footwear_PC",
            "Durable","Durable_PC","Misc","Misc_PC","MPCE_Own",
            paste0("ln_",c("Food","Food_PC","Fuel","Fuel_PC","Clothing","Clothing_PC","Footwear","Footwear_PC",
                           "Durable","Durable_PC","Misc","Misc_PC","MPCE_Own")))
controls<-c("HH_Type_Agri","Social_Group_new","Ration_Type_new","HHSize","HH_AdultFemaleProp",
            "HH_Head_Age","HH_Head_Education")
run_fit<-function(d,y,with_controls=FALSE){
  rhs<-c("did_robust1",if(with_controls)c(controls,"factor(Dwelling_Unit_new)","factor(Religion_new)","factor(Sector)"))
  f<-as.formula(paste(y,"~",paste(rhs,collapse=" + "),"| District + SubRound"))
  feols(f,data=d,cluster=~District,notes=FALSE)
}
all_did<-list();k<-1
for(h in c("SR","LR")){
  f<-file.path("data","processed","chapter_2_nsso",paste0("chapter_2_",tolower(h),"_analysis_ready.dta"))
  if(!file.exists(f)) stop("Run 01_cleaning.R first: ",f)
  d<-read_dta(f)
  for(y in intersect(outcomes,names(d))) for(c in c(FALSE,TRUE)){
    fit<-run_fit(d,y,c)
    ct<-coeftable(fit)
    if("did_robust1" %in% rownames(ct)){
      all_did[[k]]<-data.frame(horizon=h,outcome=y,controls=c,
        coefficient=ct["did_robust1","Estimate"],se=ct["did_robust1","Std. Error"],
        p_value=ct["did_robust1","Pr(>|t|)"],N=nobs(fit));k<-k+1
    }
  }
  write_csv(d %>% group_by(after_tsunami,robust_treat1) %>%
    summarise(N=n(),across(any_of(c("Food_PC","Fuel_PC","Clothing_PC","MPCE_Own","HHSize")),~mean(.x,na.rm=TRUE)),.groups="drop"),
    file.path(odir,paste0(tolower(h),"_descriptives_R.csv")))
  figdat<-d %>% group_by(SubRound,robust_treat1) %>%
    summarise(Clothing_PC=mean(Clothing_PC,na.rm=TRUE),.groups="drop")
  gp<-ggplot(figdat,aes(x=SubRound,y=Clothing_PC,colour=factor(robust_treat1),group=robust_treat1))+
    geom_line()+geom_point()+labs(title="Clothing per capita by sub-round",x="Survey sub-round",
      y="Rupees per capita",colour="Treatment group")+theme_minimal()
  ggsave(file.path(fdir,paste0(tolower(h),"_clothing_pc_by_subround_R.png")),gp,width=8,height=5,dpi=300)
  # Cross-sectional determinants regressions: robust (HC1) SEs, before/after,
  # control/treatment subsamples and pooled treatment-indicator models.
  det_out<-list()
  det_y<-intersect(paste0("ln_",c("Food_PC","Fuel_PC","Clothing_PC","Footwear_PC",
                                  "Durable_PC","Misc_PC","MPCE_Own")),names(d))
  det_controls<-c("HH_Type_Agri","Social_Group_new","Ration_Type_new","HHSize",
                  "HH_AdultFemaleProp","HH_Head_Age","HH_Head_Education",
                  "factor(Dwelling_Unit_new)","factor(Religion_new)","factor(Sector)")
  for(y in det_y) for(period in c(0,1)) for(sample in c("control","treatment","pooled")){
    dd<-filter(d,after_tsunami==period)
    rhs<-det_controls
    if(sample=="control") dd<-filter(dd,robust_treat1==0)
    if(sample=="treatment") dd<-filter(dd,robust_treat1==1)
    if(sample=="pooled") rhs<-c("robust_treat1",rhs)
    fit<-tryCatch(feols(as.formula(paste(y,"~",paste(rhs,collapse=" + "))),data=dd,vcov="hetero",notes=FALSE),error=function(e) NULL)
    if(!is.null(fit)){
      tt<-as.data.frame(coeftable(fit));tt$term<-rownames(tt)
      names(tt)[1:4]<-c("estimate","se","t_value","p_value")
      tt$outcome<-y;tt$period<-period;tt$sample<-sample;tt$horizon<-h;tt$N<-nobs(fit)
      det_out[[length(det_out)+1]]<-tt
    }
  }
  write_csv(bind_rows(det_out),file.path(odir,paste0(tolower(h),"_determinants_R.csv")))
  # Harmonised Appendix B descriptives by dwelling, sector and religion.
  for(v in intersect(c("Dwelling_Unit_new","Sector","Religion_new"),names(d))){
    appx<-d %>% group_by(.data[[v]],after_tsunami) %>%
      summarise(N=n(),across(any_of(c("Food_PC","Fuel_PC","Clothing_PC","MPCE_Own")),~mean(.x,na.rm=TRUE)),.groups="drop")
    write_csv(appx,file.path(odir,paste0(tolower(h),"_appendix_descriptives_",v,"_R.csv")))
  }
  # Household-size balance tests among controls, matching the supplied robustness do-file.
  bt<-list()
  for(cap in c(Inf,8,9,10,11,12,13)){
    dd<-if(is.infinite(cap)) d else filter(d,HHSize<=cap)
    test_p<-function(z1,z2){
      a<-dd$HHSize[z1 & !is.na(dd$HHSize)]
      b<-dd$HHSize[z2 & !is.na(dd$HHSize)]
      if(length(a)<2 || length(b)<2) return(NA_real_)
      tryCatch(t.test(a,b)$p.value,error=function(e) NA_real_)
    }
    p_before_after<-test_p(dd$robust_treat1==0 & dd$after_tsunami==0,
                           dd$robust_treat1==0 & dd$after_tsunami==1)
    p_sr13<-test_p(dd$robust_treat1==0 & dd$SubRound==1,
                   dd$robust_treat1==0 & dd$SubRound==3)
    p_sr12<-test_p(dd$robust_treat1==0 & dd$SubRound==1,
                   dd$robust_treat1==0 & dd$SubRound==2)
    bt[[length(bt)+1]]<-data.frame(cap=if(is.infinite(cap))"Original" else as.character(cap),
      horizon=h,N=nrow(dd),before_after_p=p_before_after,subround1_3_p=p_sr13,subround1_2_p=p_sr12)
  }
  write_csv(bind_rows(bt),file.path(odir,paste0(tolower(h),"_hhsize_balance_R.csv")))

  # Household-size caps: Original is the full matched, nonmissing-treatment sample.
  rb<-list()
  for(cap in c(Inf,8,9,10,11,12,13)){
    dd<-if(is.infinite(cap)) d else filter(d,HHSize<=cap)
    fit<-run_fit(dd,"Clothing_PC",FALSE)
    fitc<-run_fit(dd,"Clothing_PC",TRUE)
    b<-coef(fit)["did_robust1"];s<-se(fit)["did_robust1"]
    bc<-coef(fitc)["did_robust1"];sc<-se(fitc)["did_robust1"]
    rb[[length(rb)+1]]<-data.frame(cap=if(is.infinite(cap))"Original" else as.character(cap),
      horizon=h,N=nobs(fit),coef_no_controls=b,se_no_controls=s,
      coef_controls=bc,se_controls=sc)
  }
  write_csv(bind_rows(rb),file.path(odir,paste0(tolower(h),"_hhsize_robustness_R.csv")))
  # Harmonised heterogeneity estimates; subgroup variable excluded from own controls.
  hetvars<-c("female_headed","Religion_new","Social_Group_new","Dwelling_Unit_new","Sector","Ration_Type_new","HH_Type_Agri")
  het<-list()
  base_rhs<-c("HH_Type_Agri","Social_Group_new","Ration_Type_new","HHSize","HH_AdultFemaleProp",
              "HH_Head_Age","HH_Head_Education","factor(Dwelling_Unit_new)",
              "factor(Religion_new)","factor(Sector)")
  for(v in intersect(hetvars,names(d))){
    for(g in sort(unique(na.omit(d[[v]])))){
      dd<-filter(d,.data[[v]]==g)
      for(y in c("Food_PC","Fuel_PC","Clothing_PC","MPCE_Own")){
        for(c in c(FALSE,TRUE)){
          drop_term<-switch(v,
            "HH_Type_Agri"="HH_Type_Agri",
            "Social_Group_new"="Social_Group_new",
            "Ration_Type_new"="Ration_Type_new",
            "Dwelling_Unit_new"="factor(Dwelling_Unit_new)",
            "Religion_new"="factor(Religion_new)",
            "Sector"="factor(Sector)",
            "female_headed"="")
          rhs<-c("did_robust1",if(c)setdiff(base_rhs,drop_term))
          fit<-feols(as.formula(paste(y,"~",paste(rhs,collapse=" + "),"| District + SubRound")),
                     data=dd,cluster=~District,notes=FALSE)
          if("did_robust1"%in%names(coef(fit))) het[[length(het)+1]]<-data.frame(
            horizon=h,subgroup=v,group_value=g,outcome=y,controls=c,
            coefficient=coef(fit)["did_robust1"],se=se(fit)["did_robust1"],N=nobs(fit))
        }
      }
    }
  }
  write_csv(bind_rows(het),file.path(odir,paste0(tolower(h),"_heterogeneity_R.csv")))
}
write_csv(bind_rows(all_did),file.path(odir,"did_R.csv"))
message("R DiD completed. fixest cluster correction may differ from Stata didregress.")
message("Pre-trend test: no exact Stata estat ptrends equivalent is claimed in this script.")
