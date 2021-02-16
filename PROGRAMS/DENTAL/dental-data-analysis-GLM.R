library(tidyverse);
library(nlme);


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


attach(dental_vert)

glsControl(tolerance=1e-9)


ml.unstructured <- gls(result~0+gender+gender:age,
                       method="ML",
                       correlation=corSymm(form=~1|id),
                       weights=varIdent(form=~1|age))
 
summary(ml.unstructured)



reml.unstructured <- gls(result~0+gender+gender:age,
                       method="REML",
                       correlation=corSymm(form=~1|id),
                       weights=varIdent(form=~1|age))

summary(reml.unstructured) 


reml.compsym <- gls(result~0+gender+age+gender:age,
                    method="REML",
                    correlation=corCompSymm(form=~1|id),
                    weights=varIdent(form=~1))

summary(reml.compsym) 
detach(dental_vert)