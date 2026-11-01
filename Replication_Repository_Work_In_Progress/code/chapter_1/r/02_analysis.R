# Analysis stage: reads only the cleaned file produced by 01_cleaning.R.
suppressPackageStartupMessages({library(readr);library(dplyr);library(tidyr);library(ggplot2);library(marginaleffects);library(broom)})
f <- file.path("data","processed","chapter_1_nfhs","nfhs_analysis_ready.csv")
if(!file.exists(f)) stop("Run code/chapter_1/r/01_cleaning.R first.")
d <- read_csv(f,show_col_types=FALSE)
dir.create("output/tables/chapter_1",recursive=TRUE,showWarnings=FALSE)
dir.create("output/figures/chapter_1",recursive=TRUE,showWarnings=FALSE)
outcomes_primary <- c("we_decide_hhpurch_b","we_decide_health_b","we_decide_visits_b",
                       "we_decide_hhpurch_a","we_decide_health_a","we_decide_visits_a")
outcomes_legacy <- paste0(outcomes_primary,"_legacy")
outcomes <- c(outcomes_primary,outcomes_legacy)
factor_vars <- c("Education_respondent","we_empl","religion","Education_partner","hs_empl",
                 "wealth_index","massmedia","sector","State2","DHSRound_num")
# Convert categorical controls to factors, matching Stata i.var syntax.
for(v in factor_vars) d[[v]] <- factor(d[[v]])
controls <- paste0("`",factor_vars,"`",collapse=" + ")
controls <- paste(factor_vars,collapse=" + ")
controls_sub <- paste(setdiff(factor_vars,"religion"),collapse=" + ")
specs <- list(religion_only="religion", full_controls=controls)
samples <- c(list(All=quote(TRUE)),setNames(lapply(c(1956,1966,1976,1986),function(z) substitute(Birth_Cohort==Z,list(Z=z))),paste0("Cohort_",c(1956,1966,1976,1986))))
coef_out <- list(); ame_out <- list(); model_failures <- list(); k<-1; j<-1; q<-1
fit_one <- function(y, rhs, dd, outcome, spec, sample) {
  formula <- as.formula(paste(y,"~",rhs))
  fit <- tryCatch(glm(formula,data=dd,family=binomial(link="probit")),error=function(e) e)
  if(inherits(fit,"error")) return(list(error=conditionMessage(fit)))
  ct <- broom::tidy(fit)
  ct$outcome<-outcome;ct$specification<-spec;ct$sample<-sample;ct$N<-nobs(fit)
  ame <- tryCatch(as.data.frame(avg_slopes(fit)),error=function(e) e)
  if(inherits(ame,"error")) return(list(coef=ct,error=conditionMessage(ame)))
  ame$outcome<-outcome;ame$specification<-spec;ame$sample<-sample;ame$N<-nobs(fit)
  list(coef=ct,ame=ame)
}
for(y in outcomes) {
  for(spec in names(specs)) {
    rhs <- specs[[spec]]
    for(sn in names(samples)) {
      dd <- if(sn=="All") d else filter(d,Birth_Cohort==as.numeric(sub("Cohort_","",sn)))
      z <- fit_one(y,rhs,dd,y,spec,sn)
      if(!is.null(z$coef)){coef_out[[k]]<-z$coef;k<-k+1}
      if(!is.null(z$ame)){ame_out[[j]]<-z$ame;j<-j+1}
      if(!is.null(z$error)){model_failures[[q]]<-data.frame(outcome=y,specification=spec,sample=sn,error=z$error);q<-q+1}
    }
  }
  if(y %in% outcomes_primary) for(rel in c(1,2,3)) {
    lab<-c("Hindu","Muslim","Christian_Others")[rel]
    for(sn in c("All",paste0("Cohort_",c(1956,1966,1976,1986)))) {
      dd<-filter(d,Religion_New==rel)
      if(sn!="All") dd<-filter(dd,Birth_Cohort==as.numeric(sub("Cohort_","",sn)))
      z<-fit_one(y,controls_sub,dd,y,"full_controls",paste(lab,sn,sep="_"))
      if(!is.null(z$coef)){coef_out[[k]]<-z$coef;k<-k+1}
      if(!is.null(z$ame)){ame_out[[j]]<-z$ame;j<-j+1}
      if(!is.null(z$error)){model_failures[[q]]<-data.frame(outcome=y,specification="full_controls",sample=paste(lab,sn,sep="_"),error=z$error);q<-q+1}
    }
  }
}
write_csv(bind_rows(coef_out),"output/tables/chapter_1/probit_coefficients_R.csv")
write_csv(bind_rows(ame_out),"output/tables/chapter_1/probit_ame_R.csv")
write_csv(bind_rows(model_failures),"output/diagnostics/chapter_1_model_failures_R.csv")
for(dom in c("hhpurch","health","visits")) {
  raw<-paste0("we_decide_",dom)
  for(g in c("DHSRound","Birth_Cohort")) {
    tab<-d %>% filter(!is.na(.data[[g]]),!is.na(.data[[raw]])) %>%
      count(.data[[g]],.data[[raw]],name="n") %>%
      group_by(.data[[g]]) %>% mutate(share=n/sum(n)) %>% ungroup()
    write_csv(tab,paste0("output/tables/chapter_1/",dom,"_raw_categories_by_",g,"_R.csv"))
  }
  xvars<-c("Education_respondent","we_empl","religion","Education_partner","hs_empl",
           "wealth_index","massmedia","sector","State2")
  for(xv in intersect(xvars,names(d))){
    for(g in c("DHSRound_num","Birth_Cohort")){
      tab<-d %>% filter(!is.na(.data[[g]]),!is.na(.data[[xv]]),!is.na(.data[[raw]])) %>%
        count(.data[[g]],.data[[xv]],.data[[raw]],name="n") %>%
        group_by(.data[[g]],.data[[xv]]) %>% mutate(row_share=n/sum(n)) %>% ungroup()
      write_csv(tab,paste0("output/tables/chapter_1/",dom,"_by_",xv,"_and_",g,"_R.csv"))
    }
  }
  for(g in c("DHSRound_num","Birth_Cohort")) {
    plotdat<-d %>% group_by(.data[[g]]) %>%
      summarise(joint=mean(.data[[paste0(raw,"_b")]],na.rm=TRUE),
                independent=mean(.data[[paste0(raw,"_a")]],na.rm=TRUE),.groups="drop") %>%
      pivot_longer(c(joint,independent),names_to="outcome",values_to="share")
    p<-ggplot(plotdat,aes(x=factor(.data[[g]]),y=share,fill=outcome))+
      geom_col(position="dodge")+labs(x=g,y="Share",title=paste("Decision-making:",dom))+theme_minimal()
    ggsave(paste0("output/figures/chapter_1/",dom,"_by_",g,"_R.png"),p,width=8,height=5,dpi=300)
  }
}
message("R analysis complete. See README for factor-reference and AME comparability checks.")
