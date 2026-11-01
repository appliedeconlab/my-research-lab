# Prepare NSSO analysis-ready datasets from the supplied pre-aggregated files.
suppressPackageStartupMessages({library(haven);library(dplyr);library(readr);library(purrr)})
idir<-file.path("data","interim","chapter_2_nsso")
odir<-file.path("data","processed","chapter_2_nsso")
dir.create(odir,recursive=TRUE,showWarnings=FALSE)
required<-c("AP_Aggregates_Merged_All_SubRound_SR_Consistent_Sample.dta",
            "AP_Aggregates_Merged_All_SubRound_Consistent_Sample.dta","person_record.dta")
missing<-required[!file.exists(file.path(idir,required))]
if(length(missing)) stop("Missing NSSO analysis inputs: ",paste(missing,collapse=", "),
                         ". See docs/data_access.md.")
prepare<-function(aggregate,horizon){
  a<-read_dta(file.path(idir,aggregate));p<-read_dta(file.path(idir,"person_record.dta"))
  a$HHID<-as.character(a$HHID);p$HHID<-as.character(p$HHID)
  if(anyDuplicated(a$HHID)||anyDuplicated(p$HHID)) stop("HHID must be unique for the original 1:1 merge.")
  n_master<-nrow(a);n_person<-nrow(p)
  matched_ids<-intersect(a$HHID,p$HHID)
  message(horizon," merge: aggregate=",n_master,", person=",n_person,", matched=",length(matched_ids),
          ", aggregate-only=",n_master-length(matched_ids),", person-only=",n_person-length(matched_ids))
  d<-inner_join(a,p,by="HHID")
  d<-filter(d,!is.na(robust_treat1))
  needed<-c("District","SubRound","robust_treat1","did_robust1","after_tsunami","HHSize",
            "HH_Type","Social_Group","Ration_Type","Religion","Dwelling_Unit","Sector",
            "HH_AdultFemaleProp","HH_Head_Age","HH_Head_Education")
  miss<-setdiff(needed,names(d));if(length(miss)) stop("Missing fields: ",paste(miss,collapse=","))
  for(v in c("HH_Head_Education","HH_Head_Age","HH_AdultFemaleProp")) d[[v]]<-suppressWarnings(as.numeric(d[[v]]))
  # Literal source recodes: missing source categories are not separately set to NA.
  d<-d %>% mutate(
    HH_Type_Agri=as.integer(HH_Type %in% c(12,14)),
    Social_Group_new=as.integer(Social_Group %in% c(1,2,3)),
    Ration_Type_new=as.integer(Ration_Type %in% c(1,2)),
    Religion_new=case_when(Religion==1~1,Religion==2~2,Religion %in% c(3,9)~3,TRUE~NA_real_),
    Dwelling_Unit_new=case_when(Dwelling_Unit==1~1,Dwelling_Unit %in% c(2,9)~2,TRUE~NA_real_))
  base<-c("Food","Food_PC","Fuel","Fuel_PC","Clothing","Clothing_PC","Footwear","Footwear_PC",
          "Durable","Durable_PC","Misc","Misc_PC","MPCE_Own")
  logdiag<-list()
  for(v in base){
    if(!v %in% names(d)) stop("Missing outcome ",v)
    invalid<-sum(!is.na(d[[v]]) & d[[v]]<=-1)
    miss_raw<-sum(is.na(d[[v]]))
    d[[paste0("ln_",v)]]<-log(d[[v]]+1)
    logdiag[[v]]<-data.frame(horizon=horizon,variable=v,missing_raw=miss_raw,
      values_le_minus1=invalid,missing_log=sum(is.na(d[[paste0("ln_",v)]])))
  }
  write_csv(bind_rows(logdiag),file.path("output","diagnostics",paste0("chapter_2_",horizon,"_log_diagnostics_R.csv")))
  mismatch_after<-sum(!is.na(d$after_tsunami)&!is.na(d$SubRound)&d$after_tsunami!=(d$SubRound>=3))
  mismatch_did<-sum(!is.na(d$did_robust1)&!is.na(d$robust_treat1)&!is.na(d$after_tsunami)&
                      d$did_robust1!=d$robust_treat1*d$after_tsunami)
  message(horizon," after_tsunami/SubRound mismatches=",mismatch_after,
          "; did_robust1 != robust_treat1*after_tsunami=",mismatch_did)
  d$horizon<-horizon
  write_dta(d,file.path(odir,paste0("chapter_2_",tolower(horizon),"_analysis_ready.dta")))
  write_csv(d,file.path(odir,paste0("chapter_2_",tolower(horizon),"_analysis_ready.csv")))
  d
}
sr<-prepare(required[1],"SR");lr<-prepare(required[2],"LR")
# Optional Block 4 household-level demographic file. This mirrors the supplied
# Household_Head_Dep_Ratio.do; it does not generate person_record.dta.
block4<-file.path("data","raw","chapter_2_nsso","Block 4_Person records.dta")
if(file.exists(block4)){
  b<-read_dta(block4)
  req<-c("State","Gender","Household_Head","Age","HHID","SubRound")
  miss<-setdiff(req,names(b));if(length(miss)) stop("Block 4 missing: ",paste(miss,collapse=","))
  b<-b %>% mutate(across(c(State,Gender,Household_Head,Age),~suppressWarnings(as.numeric(.x)))) %>%
    filter(State==28) %>% mutate(is_head=Household_Head==1,
      head_gender_temp=ifelse(is_head,Gender,NA_real_),head_age_temp=ifelse(is_head,Age,NA_real_),
      child=Age>=0 & Age<=14,working_age=Age>=15 & Age<=64,elderly=Age>=65 & Age<=101) %>%
    group_by(HHID) %>% mutate(hh_head_gender=max(head_gender_temp,na.rm=TRUE),
      female_headed=as.integer(hh_head_gender==2),hh_head_age=max(head_age_temp,na.rm=TRUE),
      num_children=sum(child,na.rm=TRUE),num_working_age=sum(working_age,na.rm=TRUE),
      num_elderly=sum(elderly,na.rm=TRUE),hh_size_block4=n(),
      dependency_ratio=ifelse(num_working_age>0,(num_children+num_elderly)/num_working_age,NA_real_)) %>%
    slice(1) %>% ungroup()
  b<-b %>% mutate(hh_head_gender=ifelse(is.infinite(hh_head_gender),NA_real_,hh_head_gender),
                  hh_head_age=ifelse(is.infinite(hh_head_age),NA_real_,hh_head_age))
  write_dta(b,file.path(odir,"HH_level_AP_demographics.dta"))
}
message("Prepared SR N=",nrow(sr),"; LR N=",nrow(lr),". Thesis reference N: 1,658 and 2,180 before any additional merge attrition.")
