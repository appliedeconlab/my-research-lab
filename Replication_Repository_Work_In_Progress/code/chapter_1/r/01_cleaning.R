# NFHS pooled cross-section cleaning. Run from repository root:
# Rscript code/chapter_1/r/01_cleaning.R
suppressPackageStartupMessages({library(haven); library(dplyr); library(readr); library(purrr)})
raw_dir <- file.path("data","raw","chapter_1_nfhs")
out_dir <- file.path("data","processed","chapter_1_nfhs")
dir.create(out_dir, recursive=TRUE, showWarnings=FALSE)
files <- c("IAIR52FL_2005_06.dta","IAIR74FL_2015_16.DTA","IAIR7EFL_2019_21.DTA")
missing <- files[!file.exists(file.path(raw_dir,files))]
if(length(missing)) stop("Missing authorised NFHS files: ",paste(missing,collapse=", "))

state4 <- c(`14`=1,`13`=2,`28`=3,`6`=4,`34`=5,`12`=6,`25`=7,`29`=8,`33`=9,
            `5`=10,`30`=11,`3`=12,`24`=13,`21`=14,`23`=15,`32`=16,`22`=17,
            `4`=18,`35`=19,`15`=20,`26`=21,`7`=22,`19`=23,`11`=24,`8`=25,
            `20`=27,`2`=28,`16`=29,`10`=30,`18`=31,`17`=32,`31`=33,`27`=34,
            `1`=35,`36`=36)
make_round <- function(path, round) {
  x <- read_dta(path)
  required <- c("caseid","v005","v007","v011","v012","v024","v025","v130","v135",
                "v136","v151","v157","v158","v159","v190","v502","v704","v730",
                "v731","v743a","v743b","v743d")
  absent <- setdiff(required,names(x))
  if(length(absent)) stop("Round ",round," missing: ",paste(absent,collapse=", "))
  # Harmonised sample repair: apply v502==1 and v135==1 to all rounds.
  # The supplied file explicitly filters NFHS-3/4 but omits the filters in
  # NFHS-5. Thesis wording says ever-married; confirm v502 against codebooks.
  x <- x %>% filter(v502==1, v135==1)
  x <- x %>% mutate(
    DHSRound_num=round, DHSRound=paste0("NFHS_",round+2L),
    wt=as.numeric(v005)/1e6,
    we_empl=case_when(v731==0~0, v731 %in% 1:3~1, v731 %in% c(8,9)~NA_real_, TRUE~NA_real_),
    Birth_Year=floor((as.numeric(v011)-1)/12)+1900,
    Birth_Cohort=case_when(Birth_Year>=1956 & Birth_Year<=1965~1956,
                          Birth_Year>=1966 & Birth_Year<=1975~1966,
                          Birth_Year>=1976 & Birth_Year<=1985~1976,
                          Birth_Year>=1986 & Birth_Year<=2005~1986, TRUE~NA_real_),
    current_age=as.numeric(v012),
    age_difference=ifelse(is.na(v730)|v730>=98,NA_real_,as.numeric(v730)-as.numeric(v012)),
    hh_size=as.numeric(v136), wealth_index=as.numeric(v190),
    sector=as.numeric(v025),
    Religion_New=case_when(v130 %in% 1:3~as.numeric(v130),
                           v130 %in% 4:8~4, TRUE~NA_real_),
    religion=Religion_New,
    massmedia=as.integer(rowSums(cbind(v157==2,v158==2,v159==2),na.rm=TRUE)>0)
  )
  if(round==1) {
    if(!all(c("v149","v715") %in% names(x))) stop("NFHS-3 requires v149 and v715.")
    x <- x %>% mutate(Education_respondent=as.numeric(v149),
      Education_partner=case_when(v715==0~0, v715>=1 & v715<=5~1,
        v715>=6 & v715<=10~2, v715>=11 & v715<=97~3, TRUE~NA_real_))
  } else {
    if(!all(c("v106","v701") %in% names(x))) stop("NFHS-4/5 require v106 and v701.")
    x <- x %>% mutate(Education_respondent=as.numeric(v106),
      Education_partner=ifelse(v701 %in% 0:3,as.numeric(v701),NA_real_))
  }
  x <- x %>% mutate(
    hs_empl=case_when(v704 %in% c(0,96,97)~0,
                      v704>=1 & v704<=95~1, TRUE~NA_real_),
    State2=if(round==2) unname(state4[as.character(v024)]) else as.numeric(v024)
  )
  for(d in c("health","hhpurch","visits")) {
    rawvar <- switch(d,health="v743a",hhpurch="v743b",visits="v743d")
    z <- as.numeric(x[[rawvar]])
    z[z==9] <- NA_real_
    x[[paste0("we_decide_",d)]] <- z
    # Thesis definition: codes 1/2 are joint participation; 3-5 are no.
    x[[paste0("we_decide_",d,"_a")]] <- ifelse(z==1,1,ifelse(z %in% 2:5,0,NA_real_))
    x[[paste0("we_decide_",d,"_b")]] <- ifelse(z %in% 1:2,1,ifelse(z %in% 3:5,0,NA_real_))
    # Exact literal legacy coding retained as a separate diagnostic outcome.
    x[[paste0("we_decide_",d,"_a_legacy")]] <- ifelse(z==1,1,ifelse(z %in% c(2,4,5,6),0,NA_real_))
    x[[paste0("we_decide_",d,"_b_legacy")]] <- ifelse(z %in% 1:2,1,ifelse(z %in% c(4,5,6),0,NA_real_))
  }
  keep <- c("caseid","DHSRound","DHSRound_num","wt","Birth_Year","Birth_Cohort",
            "current_age","age_difference","hh_size","wealth_index","sector","State2",
            "religion","Religion_New","Education_respondent","Education_partner",
            "hs_empl","massmedia",grep("^we_decide_",names(x),value=TRUE))
  x %>% select(all_of(keep))
}
d <- bind_rows(
  make_round(file.path(raw_dir,files[1]),1),
  make_round(file.path(raw_dir,files[2]),2),
  make_round(file.path(raw_dir,files[3]),3)
)
if(anyDuplicated(paste(d$DHSRound_num,d$caseid))) stop("Duplicate respondent ID within survey round.")
write_csv(d,file.path(out_dir,"nfhs_analysis_ready.csv"),na="")
write_dta(d,file.path(out_dir,"nfhs_analysis_ready.dta"))
write_csv(count(d,DHSRound_num,DHSRound),file.path("output","diagnostics","chapter_1_round_counts_R.csv"))
message("Cleaned pooled file: ",nrow(d)," observations.")
message("Check expected large-purchase response counts by round: 81,365; 81,480; 72,450.")
message("Provisional assumptions and outcome coding discrepancies are documented in docs/variable_construction.md.")
