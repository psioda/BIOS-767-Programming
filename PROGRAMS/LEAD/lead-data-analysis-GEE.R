require(tidyverse);
require(geepack);

setwd("C:/Users/psioda/Documents/GitHub/BIOS-767-Programming/DATA/LEAD");


lead = read.table("tlc-data.txt",header=F)
colnames(lead)<-c("id","trt","week0","week1","week4","week6");

## transform data;
lead_vert <- as_tibble(lead) %>% 
  tidyr::pivot_longer(
    cols = starts_with("week"), 
    names_to = "week", 
    values_to = "bloodLead", 
    names_prefix = "week")


lead_vert$week     <- as.numeric(lead_vert$week)
lead_vert$lowLead  <- ifelse(lead_vert$bloodLead<20,1,0)
lead_vert$succimer <- ifelse(lead_vert$trt=="A",1,0)
lead_vert          <- lead_vert %>% filter(week>0)

head(lead_vert)


### GEE Analysis
gee.fit=geeglm( lowLead~succimer+week+week:succimer, 
                data=lead_vert, id=id, family=binomial(logit),
                corstr="exchangeable",waves=week)

summary(gee.fit)


gee.fit2 =geeglm( lowLead~succimer+week+week:succimer, 
                  data=lead_vert, id=id, family=binomial(logit),
                  corstr="exchangeable",waves=week,std.err="fij")

summary(gee.fit2)


