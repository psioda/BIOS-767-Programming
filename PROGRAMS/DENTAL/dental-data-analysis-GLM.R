library(tidyverse);
library(nlme);

setwd("C:/Users/psioda/Documents/GitHub/BIOS-767-Programming/R-FUNCTIONS")
source("gls-se.R");



setwd("C:/Users/psioda/Documents/GitHub/BIOS-767-Programming/DATA/DENTAL");

dental = read.table("dental-data.txt",header=F,sep=",")
colnames(dental)<-c("id","gender","age8","age10","age12","age14");

## transform data;
dental_vert <- as_tibble(dental) %>% 
  tidyr::pivot_longer(
    cols = starts_with("age"), 
    names_to = "age", 
    values_to = "result", 
    names_prefix = "age")
head(dental_vert)

## convert age to double precision
dental_vert$age <-
   as.numeric(dental_vert$age)
head(dental_vert)


########################## ML Unstructured ###############################
attach(dental_vert)
ml.unstructured <- gls(result~0+gender+gender:age,
                       method="ML",
                       correlation=corSymm(form=~1|id),
                       weights=varIdent(form=~1|age))

beta.un          <- coef(ml.unstructured)

## incorrect SE from GLS
sebeta.un        <- summary(ml.unstructured)$tTable[,"Std.Error"]

# correct standard errors from GLS
robust.un           <- robust.cov(ml.unstructured)
sebeta.un.corrected <- robust.un$se.model

rbind(beta.un,sebeta.un,sebeta.un.corrected)
detach(dental_vert)


########################## REML Unstructured ###############################
attach(dental_vert)
reml.unstructured <- gls(result~0+gender+gender:age,
                       method="REML",
                       correlation=corSymm(form=~1|id),
                       weights=varIdent(form=~1|age))

beta.un          <- coef(reml.unstructured)

## incorrect SE from GLS
sebeta.un        <- summary(reml.unstructured)$tTable[,"Std.Error"]

# correct standard errors from GLS
robust.un           <- robust.cov(reml.unstructured)
sebeta.un.corrected <- robust.un$se.model
sebeta.un.sand.corrected <- robust.un$se.robust

rbind(beta.un,sebeta.un,sebeta.un.corrected,robust.un$se.robust)
detach


########################## REML Unstructured - Parallelism #####################
attach(dental_vert)
reml.unstructured <- gls(result~0+gender+age+gender:age,
                         method="REML",
                         correlation=corCompSymm(form=~1|id),
                         weights=varIdent(form=~1))

beta.un          <- coef(reml.unstructured)

## incorrect SE from GLS
sebeta.un        <- summary(reml.unstructured)$tTable[,"Std.Error"]

# correct standard errors from GLS
robust.un           <- robust.cov(reml.unstructured)
sebeta.un.corrected <- robust.un$se.model
sebeta.un.sand.corrected <- robust.un$se.robust

rbind(beta.un,sebeta.un,sebeta.un.corrected,robust.un$se.robust)
detach(dental_vert)